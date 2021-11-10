qui cd "$lbecea"

*############################## HEALTH

global lindi "# Deaths of smokers Pre-Tax (thousand people)"
global indi  HDeathPreTax
preserve 
	* Calcular
	bysort ${d}: egen ${indi} = total(CFex) if HDiePreTax==1, m
	replace ${indi} = ${indi}/1000
	label var ${indi} "${lindi}"
	
	dataindi
	
restore


global lindi "# Deaths of non-smokers Pre-Tax due to Second-Hand Smoke (thousand people)"
global indi  HDeathPreShs
preserve 
	* Calcular
	bysort ${d}: egen ${indi} = total(CFex) if HDiePreShs==1, m
	replace ${indi} = ${indi}/1000
	label var ${indi} "${lindi}"
	
	dataindi
	
restore


global lindi "# Years of life Gained from quitting Post-Tax (million years of life)"
global indi  HLiYearGainPosTaxQuit
preserve 
	* Calcular (Fumaba y no quit)
	gen LiYe = CFex*HLiYeGainPosTaxQuit
	bysort ${d}: egen ${indi} = total(LiYe) , m
	replace ${indi} = ${indi}/1000000
	label var ${indi} "${lindi}"

	dataindi
	
restore


global lindi "# Deaths of smokers who quit b/c of the tax (Post-Tax) but still die (thousand people)"
global indi  HDeathPosTaxQuit
preserve 
	* Calcular (Fumaba y no quit)
	bysort ${d}: egen ${indi} = total(CFex) if HQuitDie==1, m
	replace ${indi} = ${indi}/1000
	label var ${indi} "${lindi}"
	
	dataindi
	
restore		


global lindi "# Deaths of those who keep smoking Post-Tax (thousand people)"
global indi  HDeathPosTaxSmokQuit
preserve 
	* Calcular (Fumaba y no quit)
	bysort ${d}: egen ${indi} = total(CFex) if HDiePosTax==1, m
	replace ${indi} = ${indi}/1000
	label var ${indi} "${lindi}"
	
	dataindi
	
restore	


global lindi "# Deaths of smokers averted by the tax (thousand people)"
global indi  HDeathsAver
preserve 
	* Calcular (Fumaba y no quit)
	bysort ${d}: egen ${indi} = total(CFex) if HDeathAver==1, m
	replace ${indi} = ${indi}/1000
	label var ${indi} "${lindi}"
	
	dataindi
	
restore	




global lindi "# Deaths averted: Heart Disease (thousand people)"
global indi  HDeathsAverHear
preserve 
	* Calcular 
	bysort ${d}: egen ${indi} = total(CFex) if HNcdDeaAver==1, m
	replace ${indi} = ${indi}/1000
	label var ${indi} "${lindi}"
	
	dataindi
	
restore	


global lindi "# Deaths averted: Stroke (thousand people)"
global indi  HDeathsAverStro
preserve 
	* Calcular 
	bysort ${d}: egen ${indi} = total(CFex) if HNcdDeaAver==2, m
	replace ${indi} = ${indi}/1000
	label var ${indi} "${lindi}"
	
	dataindi
	
restore	




global lindi "# Deaths averted: COPD (thousand people)"
global indi  HDeathsAverCopd
preserve 
	* Calcular 
	bysort ${d}: egen ${indi} = total(CFex) if HNcdDeaAver==3 , m
	replace ${indi} = ${indi}/1000
	label var ${indi} "${lindi}"

	dataindi
	
restore	



global lindi "# Deaths averted: Cancer (thousand people)"
global indi  HDeathsAverCanc
preserve 
	* Calcular 
	bysort ${d}: egen ${indi} = total(CFex)  if HNcdDeaAver==4, m
	replace ${indi} = ${indi}/1000
	label var ${indi} "${lindi}"
	
	dataindi
restore	





global lindi "# Deaths of Non-Smokers for SHS averted by the tax (thousand people)"
global indi  HDeathsShsAv
preserve 
	* Calcular (Fumaba y no quit)
	bysort ${d}: egen ${indi} = total(CFex) if HDeathShsAver==1, m
	replace ${indi} = ${indi}/1000
	label var ${indi} "${lindi}"
	
	dataindi
	
restore	
