*################# HEALTHCARE


** UTILIZATION OF HEALTHCARE

* Gradient by income quintile
cd "$lbecea"
merge m:1 HIQuin using EUtiGradi, nogen
replace EUtiGrad = . if (HNcdDeaAver==. & HNcdShsDeaAver==.)


* Utilization of Healthcare
gen EUtiHCare = .
label var EUtiHCare "Will __ use healthcare for NCD Treatment?"
label val EUtiHCare lasino

*!!! No comorbidities

* Probability of being selected (same for all in the group)
gsort $iid
generate RanU = runiform() if (HNcdDeaAver~=. | HNcdShsDeaAver~=.)
replace EUtiHCare = 0 if RanU~=.
gsort -RanU

* Population, Total, Proportion
gen  RanPop = sum(CFex)   if (RanU~=.)
egen RanTot = total(CFex) if (RanU~=.)
gen  RanPro = RanPop/RanTot

* Rule of allocation (if under the threshold, then the event happens)
replace EUtiHCare = 1 if (RanU~=. & RanPro <= EUtiGrad)
*order  EUtiHCare HIQuin Ran* EUtiGrad  $iid CFex
*	gsort  -CQuit CAgeGroup -RanU
order Ran* EUt* HNcd* HNcdShs*

* Limpiar
drop Ran*
gsort $iid




******** COSTS OF TREATMENT
gen ECostTotal = .
label var ECostTotal "Cost of healthcare (Million COP$/month)"

replace ECostTotal = EUtiHCare*${ECost1}/12 if ( (HNcdDeaAver==1 | HNcdShsDeaAver==1) & EUtiHCare==1)
replace ECostTotal = EUtiHCare*${ECost2}/12 if ( (HNcdDeaAver==2 | HNcdShsDeaAver==2) & EUtiHCare==1)
replace ECostTotal = EUtiHCare*${ECost3}/12 if ( (HNcdDeaAver==3 | HNcdShsDeaAver==3) & EUtiHCare==1)
replace ECostTotal = EUtiHCare*${ECost4}/12 if ( (HNcdDeaAver==4 | HNcdShsDeaAver==4) & EUtiHCare==1)

* Ordenar
order ECostTotal EUtiHCare HIQuin EUtiGrad  $iid CFex


** Out of Pocket
gen ECostOop = ${ECopayProOop}*ECostTotal
label var ECostOop "Out-Of-Pocket cost of Healthcare (Million COP$/month)"

** Out of Health system
gen ECostOohs = (1-${ECopayProOop})*ECostTotal
label var ECostOohs "Out-Of-HealthSystem cost of Healthcare (Million COP$/month)"

*dis "${ECopayProOop}"
*order $iid ECostOop ECostOohs



*??? Proportion of uninsured ($ECopayInsu) could be randomly distributed to increase precision (more real). But that should not be copayment

*??? For copayment, it would be necessary to model this: https://pospopuli.minsalud.gov.co/PospopuliWeb/files/cuotas-moderadoras-copagos-2020.pdf



* Guardar
cd "$lbecea"
gsort $iid
save TempMicSimHCare${Simu}, replace

