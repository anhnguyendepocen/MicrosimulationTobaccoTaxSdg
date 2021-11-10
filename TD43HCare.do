qui cd "$lbecea"

*############################## HEALTHCARE



********************* TOTAL COST


global lindi "Total Healthcare Costs Averted: Heart Disease (Million COP$/year)"
global indi  ECostHeartAver
preserve 
	* Calcular
	gen CosTot = CFex*ECostTotal*12
	bysort ${d}: egen ${indi} = total(CosTot) if HNcdDeaAver==1, m
	label var ${indi} "${lindi}"
	
	dataindi
	
restore



global lindi "Total Healthcare Costs Averted: Stroke (Million COP$/year)"
global indi  ECostStroAver
preserve 
	* Calcular
	gen CosTot = CFex*ECostTotal*12
	bysort ${d}: egen ${indi} = total(CosTot) if HNcdDeaAver==2, m
	label var ${indi} "${lindi}"
	
	dataindi
restore



global lindi "Total Healthcare Costs Averted: COPD (Million COP$/year)"
global indi  ECostCopdAver
preserve 
	* Calcular
	gen CosTot = CFex*ECostTotal*12
	bysort ${d}: egen ${indi} = total(CosTot) if HNcdDeaAver==3, m
	label var ${indi} "${lindi}"
	
	dataindi
	
restore


global lindi "Total Healthcare Costs Averted: Cancer (Million COP$/year)"
global indi  ECostCancAver
preserve 
	* Calcular
	gen CosTot = CFex*ECostTotal*12
	bysort ${d}: egen ${indi} = total(CosTot) if HNcdDeaAver==4, m
	label var ${indi} "${lindi}"
	
	dataindi
	
restore




********************* COST OUT-OF-POCKET 


global lindi "Out-Of-Pocket Healthcare Costs Averted: Heart Disease (Million COP$/year)"
global indi  ECostHeartOopAver
preserve 
	* Calcular
	gen CosTot = CFex*ECostOop*12
	bysort ${d}: egen ${indi} = total(CosTot) if HNcdDeaAver==1, m
	label var ${indi} "${lindi}"
	
	dataindi
	
restore




global lindi "Out-Of-Pocket Healthcare Costs Averted: Stroke (Million COP$/year)"
global indi  ECostStroOopAver
preserve 
	* Calcular
	gen CosTot = CFex*ECostOop*12
	bysort ${d}: egen ${indi} = total(CosTot) if HNcdDeaAver==2, m
	label var ${indi} "${lindi}"
	
	dataindi
	
restore




global lindi "Out-Of-Pocket Healthcare Costs Averted: COPD (Million COP$/year)"
global indi  ECostCopdOopAver
preserve 
	* Calcular
	gen CosTot = CFex*ECostOop*12
	bysort ${d}: egen ${indi} = total(CosTot) if HNcdDeaAver==3, m
	label var ${indi} "${lindi}"
	
	dataindi
restore



global lindi "Out-Of-Pocket Healthcare Costs Averted: Cancer (Million COP$/year)"
global indi  ECostCancOopAver
preserve 
	* Calcular
	gen CosTot = CFex*ECostOop*12
	bysort ${d}: egen ${indi} = total(CosTot) if HNcdDeaAver==4, m
	label var ${indi} "${lindi}"
	
	dataindi
	
restore






********************* COST OUT-OF THE HEALTH-SYSTEM


global lindi "Out-Ofthe-Health-System Healthcare Costs Averted: Heart Disease (Million COP$/year)"
global indi  ECostHeartOohsAver
preserve 
	* Calcular
	gen CosTot = CFex*ECostOohs*12
	bysort ${d}: egen ${indi} = total(CosTot) if HNcdDeaAver==1, m
	label var ${indi} "${lindi}"
	
	dataindi
	
restore


global lindi "Out-Ofthe-Health-System Healthcare Costs Averted: Stroke (Million COP$/year)"
global indi  ECostStroOohsAver
preserve 
	* Calcular
	gen CosTot = CFex*ECostOohs*12
	bysort ${d}: egen ${indi} = total(CosTot) if HNcdDeaAver==2, m
	label var ${indi} "${lindi}"
	
	dataindi
	
restore



global lindi "Out-Ofthe-Health-System Healthcare Costs Averted: COPD (Million COP$/year)"
global indi  ECostStroOohsAver
preserve 
	* Calcular
	gen CosTot = CFex*ECostOohs*12
	bysort ${d}: egen ${indi} = total(CosTot) if HNcdDeaAver==2, m
	label var ${indi} "${lindi}"
	
	dataindi
	
restore




global lindi "Out-Ofthe-Health-System Healthcare Costs Averted: Cancer (Million COP$/year)"
global indi  ECostCopdOohsAver
preserve 
	* Calcular
	gen CosTot = CFex*ECostOohs*12
	bysort ${d}: egen ${indi} = total(CosTot) if HNcdDeaAver==3, m
	label var ${indi} "${lindi}"
	
	dataindi
	
restore



global lindi "Out-Ofthe-Health-System Healthcare Costs Averted: Cancer (Million COP$/year)"
global indi  ECostCancOohsAver
preserve 
	* Calcular
	gen CosTot = CFex*ECostOohs*12
	bysort ${d}: egen ${indi} = total(CosTot) if HNcdDeaAver==4, m
	label var ${indi} "${lindi}"
	
	dataindi
	
restore



