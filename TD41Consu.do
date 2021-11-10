qui cd "$lbecea"


******** POPULATION
global lindi "# People  (million)"
global indi  CPopulation
preserve 
	* Calcular
	bysort ${d}: egen ${indi} = total(CFex)
	replace ${indi} = ${indi} /1000000
	label var ${indi} "${lindi}"

	* Ordenar
	keep ${d} ${indi} 
	duplicates drop ${d} ${indi}, force
	drop if ${indi} ==.

	* Save
	gen S = ${s}
	order S ${d} 
	save TD${d}S${s}, replace
	
	* Limpiar
	global indi
	global lindi
restore








*############################## CONSUMPTION

******** NUMBER OF SMOKERS
global lindi "# smokers Pre-Tax (million)"
global indi  CPreTaxSmok
preserve 
	* Calcular
	bysort ${d}: egen ${indi} = total(CFex) if SFumaSino==1, m
	replace ${indi} = ${indi} /1000000
	label var ${indi} "${lindi}"

	dataindi
restore


global lindi "# smokers Post-Tax (million)"
global indi  CPosTaxSmok
preserve 
	* Calcular
	bysort ${d}: egen ${indi} = total(CFex) if (SFumaSino==1 & CQuit==0), m
	replace ${indi} = ${indi} /1000000
	label var ${indi} "${lindi}"

	dataindi
restore



global lindi "Smoking Intensity Pre-Tax (median) (cigarettes per day)"
global indi  CPreInteMedian
preserve 
	* Initialize
	gen ${indi} = .
	label var ${indi} "${lindi}"
	
	* Categories of Disaggregation
	levelsof ${d}, local(desd)
	
	* Loop en valores de desagregacion
	foreach des of local desd {
		sum SFumaCuan [fw = CFexTab] if ${d}==`des', detail 		
		replace ${indi} = `r(p50)'   if ${d}==`des'
	}

	dataindi
restore




global lindi "Smoking Intensity Pos-Tax (median) (cigarettes per day)"
global indi  CPosInteMedian
preserve 
	
	* Initialize
	gen ${indi} = .
	label var ${indi} "${lindi}"
	
	* Categories of Disaggregation
	levelsof ${d}, local(desd)
	
	* Loop en valores de desagregacion
	foreach des of local desd {
		sum SFumaCuanPos [fw = CFexTab] if ${d}==`des', detail 		
		replace ${indi} = `r(p50)'   if ${d}==`des'
	}

	
	
	dataindi
restore







******** NUMBER OF CIGARETTES
global lindi "# Cigarettes smoked in Colombia Pre-Tax (million 20-Sticks packs)"
global indi  CPreTaxCigSmo
preserve 
	* Calcular
	gen Cig = CFex*SFumaCuan*(30*12)/20
	bysort ${d}: egen ${indi} = total(Cig), m
	replace ${indi} = ${indi}/1000000
	label var ${indi} "${lindi}"

	dataindi
restore


global lindi "# Cigarettes smoked in Colombia Post-Tax (million 20-Sticks packs)"
global indi  CPosTaxCigSmo
preserve 
	* Calcular
	gen Cig = CFex*SFumaCuanPos*(30*12)/20 if  (SFumaSino==1 & CQuit==0)
	bysort ${d}: egen ${indi} = total(Cig), m
	replace ${indi} = ${indi}/1000000
	label var ${indi} "${lindi}"
	
	dataindi
restore

** REDUCTIONS

global lindi "Reduction in Cigarettes Because of smoking intensity (intensive margin) (million 20-Sticks packs)"
global indi  CPrePosCigSmoInDif
preserve 
	* Calcular
	gen Cig = CFex*SFumaCuan*(30*12)/20 - CFex*SFumaCuanPos*(30*12)/20 if  (SFumaSino==1 & CQuit==0)
	bysort ${d}: egen ${indi} = total(Cig), m
	replace ${indi} = ${indi}/1000000
	label var ${indi} "${lindi}"
	
	dataindi
restore



global lindi "Reduction in Cigarettes Because of less smokers (extensive margin) (million 20-Sticks packs)"
global indi  CPrePosCigSmoExDif
preserve 
	* Calcular
	gen Cig = CFex*SFumaCuan*(30*12)/20 if  (SFumaSino==1 & CQuit==1)
	bysort ${d}: egen ${indi} = total(Cig), m
	replace ${indi} = ${indi}/1000000
	label var ${indi} "${lindi}"
	
	dataindi
restore



**** CAJETILLAS TOTALES (Consumo Colombia + Exceso de Importaciones)
*! Asumo que impuesto no cambia el exceso de cajetillas (las que pagan impuesto aca y se van a otros mercados. Relajar ese supuesto requeriria modelo regional)


global lindi "# Cigarettes paying taxes Pre-Tax (million 20-Sticks packs). Imports"
global indi  CPreTaxCigTot
preserve 
	* Calcular (Fumaba y no quit)
	gen ${indi} = ${SCigaImpo}
	label var ${indi} "${lindi}"
	
	* Ordenar
	keep ${d} ${indi} 
	duplicates drop ${d} ${indi}, force
	drop if ${indi} ==.

	dataindi
	
restore		



global lindi "# Cigarettes paying taxes Post-Tax (million 20-Sticks packs). Imports"
global indi  CPosTaxCigTot
preserve 
	
	* Calcular
	gen CigPre = CFex*SFumaCuan*(30*12)/20 if  (SFumaSino==1)
	bysort ${d}: egen TCigPre = total(CigPre) , m

	gen CigPos = CFex*SFumaCuanPos*(30*12)/20 if  (SFumaSino==1 & CQuit==0)
	bysort ${d}: egen TCigPos = total(CigPos) , m
	
	gen ${indi} = ${SCigaImpo} - ((TCigPre-TCigPos)/1000000)
	label var ${indi} "${lindi}"
	
	dataindi
	
restore		


************* ILLICIT TRADE  

global lindi "Illicit Trade PrePos-Tax (annual Million 20-stick packs)"
global indi  CPrePosCigIllTra
preserve 
	* Calcular
	gen TIlli = (CFex*SFumaCuan*(30*12)/20)*${SIlliTraPre}
	bysort ${d}: egen ${indi} = total(TIlli), m
	replace ${indi} = ${indi}/1000000
	label var ${indi} "${lindi}"

	dataindi
	
restore



