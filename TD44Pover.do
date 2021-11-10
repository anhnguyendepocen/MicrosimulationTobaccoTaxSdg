qui cd "$lbecea"

*############################## POVERTY


global lindi "# People Averted from Poverty caused by Out-Of-Pocket Healthcare (thousand people)"
global indi  PAverPovCostOop
preserve 
	* Calcular
	bysort ${d}: egen ${indi} = total(CFex) if PAverPobMon==1, m
	replace ${indi} = ${indi}/1000
	label var ${indi} "${lindi}"
	
	dataindi
	
restore

		
global lindi "# People Averted from Catasthrophic Expenditure caused by Out-Of-Pocket Healthcare (thousand people)"
global indi  PAverCatasCostOop
preserve 
	* Calcular
	bysort ${d}: egen ${indi} = total(CFex) if PAverGasCas==1, m
	replace ${indi} = ${indi}/1000
	label var ${indi} "${lindi}"
	
	dataindi
	
restore


