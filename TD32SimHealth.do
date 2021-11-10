*################### HEALTH

***** DEATHS PRE TAX
gen HDiePreTax = 0 if (SFumaSino==1)
label var HDiePreTax "Expected to die for smoking before tax?"
label val HDiePreTax  lasino 

* Probability of being selected (same for all in the group)
gsort $iid
generate RanU = runiform() if (SFumaSino==1) 
gsort -RanU

* Smokers: Population, Total, Proportion
gen  RanPop = sum(CFex)   if (SFumaSino==1)
egen RanTot = total(CFex) if (SFumaSino==1)
gen RanPro = RanPop/RanTot

* Deaths Pre Tax
replace HDiePreTax = 1 if RanPro <= $HDeathTob

order $iid Ran* HDiePreTax
gsort -RanU

* Limpiar
drop Ran*
gsort $iid

* Validar
tab HDiePreTax [fweight = CFexTab]
tab HDiePreTax 
tab HDiePreTax [fweight = CFexTab]  if CQuit==0
*Same random variable also applies for those who do not quit






************ DEATHS FROM SECOND-HAND SMOKE (SHS) PRE-TAX
* Number of smokers in the household
bysort $hid: egen SFumaSmoHh = total(SFumaSino), m
order SFumaSmoHh 

* Number of smokers in non single-person households & not all HH members smoke
gen   	SmoNonUni = 0 if (SFumaSino==1 & RCanPerso<2 )
replace	SmoNonUni = 1 if (SFumaSino==1 & RCanPerso>=2 & SFumaSmoHh<RCanPerso)
*gen v = 1 if  SFumaSmoHh ==RCanPerso
*order v SmoNonUni
*gsort -v $hid


quietly sum CFex if SmoNonUni==1
global TSmoNonUni = `r(sum)'
dis  "# Smokers in non-single-person HHs:  ${TSmoNonUni}"
*order SFumaHSino SmoNonUni  CFex SFumaSino  RCanPerso 
*gsort -SFumaHSino $hid CFex SFumaHSino  RCanPerso  $hid


* Number of deaths due to SHS
global TDeShsPre = ${TSmoNonUni}/56.1
dis "$TDeShsPre"



** RANDOM ALLOCATION OF DEATHS FOR SHS

** Identify population exposed (Non-smokers in non-single-person HHs with smokers)
*gsort $iid
* Identify all people in the HH
bysort $hid: egen SExpoShs0 = total(SmoNonUni), m
* Identify exposed members (non smokers)
gen SExpoShs1 = 1 if (SExpoShs0~=. & SExpoShs0>0 & SFumaSino ~=. & SFumaSino==0)
order SExpoShs* 

* Random numbers for those in the lottery
generate RanU = runiform() if (SExpoShs1==1) 
gsort -RanU

* Count
gen  RanPop = sum(CFex)   if (SExpoShs1==1)

* Shs Deaths Pre Tax
gen HDiePreShs = 0 if SExpoShs1 == 1
label var HDiePreShs "Expected to die for Second-Hand Smoke Pre tax? (missing for those who are not exposed to SHS)"
label val HDiePreShs  lasino 
replace HDiePreShs = 1 if RanPop <= ${TDeShsPre}


** Validar
*order HDiePreShs SFumaSmoHh SmoNonUni SExpoShs0 SExpoShs1 Ran*
*tab HDiePreShs [fw=CFexTab]
*dis "${TDeShsPre}"
*Not exactly ${TDeShsPre} because of the indivisibility issue with frequency weights
*Es decir, la siguiente observacion puede tener un factor de expansion mas grande de lo 
*que me falta para llenar la cuota


* Limpiar
drop SFumaSmoHh SmoNonUni SExpoShs0 SExpoShs1 RanPop RanU
gsort $iid

global TSmoNonUni
global TDeShsPre 















************ DEATHS POST-TAX 

**** IN QUITTERS & RISK REDUCTION
cd "$lbecea"
merge m:1 CAgeGroup using HRiskRedu, nogen

* Only applies to smokers
replace HRiskRedu = . if SFumaSino~=1

* Probability of smoker to die after quitting (risk reduction)
*gen ProbDie= $HDeathTob*(1-HRiskRedu) if CQuit==1
*But since it already has HDeathTob, it must be conditional on expected to die (HDeathTob==1). So ProbDie was generating a new chance of dying, which does not make sense

** Death
gen HQuitDie = 0 if CQuit==1 
label var HQuitDie "Will ___ die after quitting?"
label val HQuitDie lasino

*local k = 5
forvalues k = 1/21 {
	* Probability of being selected (same for all in the group)
	gsort $iid
	generate RanU = runiform() if (CQuit==1 & CAgeGroup==`k')
	gsort -RanU

	* Population, Total, Proportion
	gen  RanPop = sum(CFex)   if (CQuit==1 & CAgeGroup==`k')
	egen RanTot = total(CFex) if (CQuit==1 & CAgeGroup==`k')
	gen RanPro = RanPop/RanTot

	* Rule of allocation (if under the threshold, then the event happens)
	replace HQuitDie = 1 if (CQuit==1  & HDiePreTax==1 & RanPro <= (1-HRiskRedu) )
*	order  HQuitDie HDiePreTax Ran* HRiskRedu CQuit SFumaSino CAgeGroup $iid CFex
*	gsort  -CQuit CAgeGroup -RanU
	
	* Limpiar
	drop Ran*
	gsort $iid
}

*gsort  -CQuit CAgeGroup 

* Validar
tab SFumaSino [fweight = CFexTab]
tab CQuit [fweight = CFexTab]
tab HQuitDie [fweight = CFexTab]

* Limpiar 
*drop ProbDie





**** IN NON-SMOKERS FROM SECOND-HAND-SMOKE
* Nadie puede morir si no estaba condenado a morir

gen HQuitDieShs = 1 if HDiePreShs==1 
label var HQuitDieShs "Will NON-SMOKER ___ die Post Tax?"
label val HQuitDieShs lasino

* Calculate number of smokers in the Household Post-Tax
bysort $hid: egen TSmoHh = total(SFumaSino == 1 & CQuit == 0), m

*!!! We assume that smoking Pre-Tax does not cause SHS deaths after the smokers in the HH quit
* Does not die if he was going to die b/c of SHS but then after the tax everyone in the HH quit, so there is no exposition to SHS
replace HQuitDieShs = 0 if (HQuitDieShs==1 & TSmoHh==0)

** SHS DEATHS AVERTED 
gen HDeathShsAver = 0 if HDiePreShs==1 
replace HDeathShsAver  = 1 if (HDiePreShs==1  & HQuitDieShs == 0)
label var HDeathShsAver "Was NON-SMOKER __'s death averted by the tax?'"
label val  HDeathShsAver  lasino





**** LIFE YEARS GAINED
cd "$lbecea"
merge m:1 CAge using HLiYeGainCubSpli, keep(mas match) nogen
*tab CAge _merge

* Only applies to smokers
replace HAgeLiYe = . if SFumaSino~=1

* Life Years Gained
gen HLiYeGainPosTaxQuit = HAgeLiYe if CQuit==1
label var HLiYeGainPosTaxQuit "Life years gained b/c tax moved people to quit"

order HLiYeGainPosTaxQuit CQuit HAgeLiYe  HRiskRedu SFumaSino CAge CAgeGroup
gsort -SFumaSino ${iid}
gsort $iid

*??? Life Years Gained in quitters who still die

*??? Life years gained in non-smokers from SHS in HHs with quitters ?








**** DEATHS AVERTED
* Nadie puede morir si no estaba condenado a morir

* Dies after the tax
gen HDiePosTax = 0 if HDiePreTax~=. 
replace HDiePosTax  = 1 if (HQuitDie == 1 | (CQuit==0 & HDiePreTax==1) )
label var HDiePosTax  "Is the SMOKER __ dead after the tax?"
label val  HDiePosTax  lasino

* Death averted
gen HDeathAver = 0 if HDiePreTax==1
replace HDeathAver = 1 if (HDiePreTax==1 & HQuitDie==0) 
label var HDeathAver "Was SMOKERS __'s death averted by the tax?"
label val  HDeathAver lasino

***** Validar

* Microvalidacion
order SFumaSino HDiePreTax CQuit HQuitDie HDiePosTax HDeathAver   
gsort HDiePreTax CQuit HQuitDie -HDeathAver HDiePosTax  $iid

* A story....
tab SFumaSino [fweight = CFexTab]
tab HDiePreTax [fweight = CFexTab]
tab CQuit [fweight = CFexTab]
tab CQuit HDiePreTax [fweight = CFexTab]
tab HQuitDie [fweight = CFexTab]
tab HDiePosTax [fweight = CFexTab]
tab HDeathAver [fweight = CFexTab]
bysort HIQuin: tab HDeathAver [fweight = CFexTab]

gsort $iid







**************** CAUSE OF DEATH (NCD) FOR SMOKERS AVERTED


** HEART DISEASE

gen HNcdDeaAver = .
label var HNcdDeaAver "Ncd Death Averted"
label define lncd 1 "Heart Disease" 2 "Stroke" 3 "COPD" 4  "Cancer"
label val HNcdDeaAver lncd

* Probability of being selected (same for all in the group)
gsort $iid
generate RanU = runiform() if (HDeathAver==1 & HNcdDeaAver==.)
gsort -RanU

* Population, Total, Proportion
gen  RanPop  = sum(CFex)   if (HDeathAver==1 & HNcdDeaAver==.)
egen RanTot  = total(CFex) if (HDeathAver==1)
gen  RanPro1 = RanPop/RanTot

* Rule of allocation (if under the threshold, then the event happens)
replace HNcdDeaAver = 1 if (HDeathAver==1  & RanPro1 <= $HShareHear )


** STROKE
drop RanPop 
gsort $iid

* Random draw (same random number for all NCDs work and it is more transparent)
gsort $iid
gen  RanPop  = sum(CFex)   if (HDeathAver==1 & HNcdDeaAver==.)
gen  RanPro2 = RanPop/RanTot

* Rule of allocation (if under the threshold, then the event happens)
replace HNcdDeaAver = 2 if (HDeathAver==1  & RanPro2 <= $HShareStro )





** COPD
drop RanPop 
gsort $iid


* Random draw 
gen  RanPop  = sum(CFex)   if (HDeathAver==1 & HNcdDeaAver==.)
gen  RanPro3 = RanPop/RanTot

* Rule of allocation (if under the threshold, then the event happens)
replace HNcdDeaAver = 3 if (HDeathAver==1  & RanPro3 <= $HShareCopd )





** CANCER
drop RanPop 
gsort $iid

* Random draw 
gen  RanPop  = sum(CFex)   if (HDeathAver==1 & HNcdDeaAver==.)
gen  RanPro4 = RanPop/RanTot

* Rule of allocation (if under the threshold, then the event happens)
replace HNcdDeaAver = 4 if (HDeathAver==1  & RanPro4 <= $HShareCanc )

** Rounding Error

* Number of missing
mdesc HNcdDeaAver if (HNcdDeaAver== . & HDeathAver==1)
gen xmiss = 1 if (HNcdDeaAver== . & HDeathAver==1)
gsort xmiss -HDeathAver HNcdDeaAver $iid
replace xmiss = _n if xmiss~=.
order HDeathAver HNcdDeaAver xmiss $iid
gsort $iid




tab HNcdDeaAver
tab HNcdDeaAver, nolabel

** Reasignar casos que quedan vacios por errores de redondeo

sum xmiss
dis `r(N)'
local ce1 = ceil(${HShareCanc}*`r(N)')
dis "`ce1'"
replace HNcdDeaAver = 1 if (HNcdDeaAver==. & xmiss<=`ce1')

local ce2 = ceil(${HShareCopd}*`r(N)')
dis "`ce2'"
replace HNcdDeaAver = 2 if (HNcdDeaAver==. & xmiss<=`ce1'+`ce2')

local ce3 = ceil(${HShareStro}*`r(N)')
dis "`ce3'"
replace HNcdDeaAver = 3 if (HNcdDeaAver==. & xmiss<=`ce1'+`ce2'+`ce3')

local ce4 = ceil(${HShareHear}*`r(N)')
dis "`ce4'"
replace HNcdDeaAver = 4 if (HNcdDeaAver==. & xmiss<=`ce1'+`ce2'+ `ce3'+`ce4')

mdesc HNcdDeaAver if (HNcdDeaAver== . & HDeathAver==1)

* Limpiar
local ce1
local ce2
local ce3
local ce4
drop xmiss RanPro* RanPop RanTot RanU









**************** CAUSE OF DEATH (NCD) FOR SECOND HAND SMOKE



** HEART DISEASE

gen HNcdShsDeaAver = .
label var HNcdShsDeaAver "SHS Ncd Death Averted"
label val HNcdShsDeaAver lncd


* Probability of being selected (same for all in the group)
gsort $iid
generate RanU = runiform() if (HDeathShsAver==1 & HNcdShsDeaAver==.)
gsort -RanU

* Population, Total, Proportion
gen  RanPop  = sum(CFex)   if (HDeathShsAver==1 & HNcdShsDeaAver==.)
egen RanTot  = total(CFex) if (HDeathShsAver==1)
gen  RanPro1 = RanPop/RanTot

* Rule of allocation (if under the threshold, then the event happens)
replace HNcdShsDeaAver = 1 if (HDeathShsAver==1  & RanPro1 <= $HShsShareHear )


** STROKE
drop RanPop 
gsort $iid

* Random draw (same random number for all NCDs work and it is more transparent)
gsort $iid
gen  RanPop  = sum(CFex)   if (HDeathShsAver==1 & HNcdShsDeaAver==.)
gen  RanPro2 = RanPop/RanTot

* Rule of allocation (if under the threshold, then the event happens)
replace HNcdShsDeaAver = 2 if (HDeathShsAver==1  & RanPro2 <= $HShsShareStro )





** COPD
drop RanPop 
gsort $iid


* Random draw 
gen  RanPop  = sum(CFex)   if (HDeathShsAver==1 & HNcdShsDeaAver==.)
gen  RanPro3 = RanPop/RanTot

* Rule of allocation (if under the threshold, then the event happens)
replace HNcdShsDeaAver = 3 if (HDeathShsAver==1  & RanPro3 <= $HShsShareCopd )





** CANCER
drop RanPop 
gsort $iid

* Random draw 
gen  RanPop  = sum(CFex)   if (HDeathShsAver==1 & HNcdShsDeaAver==.)
gen  RanPro4 = RanPop/RanTot

* Rule of allocation (if under the threshold, then the event happens)
replace HNcdShsDeaAver = 4 if (HDeathShsAver==1  & RanPro4 <= $HShsShareCanc )

** Rounding Error

* Number of missing
mdesc HNcdShsDeaAver if (HNcdShsDeaAver== . & HDeathShsAver==1)


gen xmiss = 1 if (HNcdShsDeaAver== . & HDeathShsAver==1)
gsort xmiss -HDeathShsAver HNcdShsDeaAver $iid
replace xmiss = _n if xmiss~=.
order HDeathShsAver HNcdShsDeaAver xmiss $iid
gsort $iid




tab HNcdShsDeaAver
tab HNcdShsDeaAver, nolabel

** Reasignar casos que quedan vacios por errores de redondeo

sum xmiss
dis `r(N)'
local ce1 = ceil(${HShsShareCanc}*`r(N)')
dis "`ce1'"
replace HNcdShsDeaAver = 1 if (HNcdShsDeaAver==. & xmiss<=`ce1')

local ce2 = ceil(${HShsShareCopd}*`r(N)')
dis "`ce2'"
replace HNcdShsDeaAver = 2 if (HNcdShsDeaAver==. & xmiss<=`ce1'+`ce2')

local ce3 = ceil(${HShsShareStro}*`r(N)')
dis "`ce3'"
replace HNcdShsDeaAver = 3 if (HNcdShsDeaAver==. & xmiss<=`ce1'+`ce2'+`ce3')

local ce4 = ceil(${HShsShareHear}*`r(N)')
dis "`ce4'"
replace HNcdShsDeaAver = 4 if (HNcdShsDeaAver==. & xmiss<=`ce1'+`ce2'+ `ce3'+`ce4')

mdesc HNcdShsDeaAver if (HNcdShsDeaAver== . & HDeathShsAver==1)

* Limpiar
local ce1
local ce2
local ce3
local ce4
drop xmiss RanPro* RanPop RanTot RanU






* Guardar
cd "$lbecea"
gsort $iid
save TempMicSimHealth${Simu}, replace

