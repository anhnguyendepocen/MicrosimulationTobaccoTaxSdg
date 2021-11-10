qui cd "$lbecea"

*############################## DEVELOPMENT


************* TOTAL LOST YEARS OF EDUCATION AVERTED

global lindi "Total Years of Education lost Averted (million years)"
global indi  TEduYeAve
preserve 
	
	** Total Years of Education
	gen YeEduEx = (CFex*CEduYe) if (HDeathAver==1)
	bysort ${d}: egen ${indi} = total(YeEduEx), m
	replace ${indi} = ${indi}/1000000
	label var ${indi} "${lindi}"
	
	dataindi
	
restore




************* MEAN YEARS OF EDUCATION AVERTED

global lindi "Median Years of Education lost Averted (years)"
global indi  TEduYeMedi
preserve 

	** Median Years of Education
	levelsof ${d}, local(desd)
	*dis "Levels:  `desd' "
	
	* Initialize
	gen ${indi} = .
	
	* Loop en valores de desagregacion
	foreach des of local desd {
		sum CEduYe [fw = CFexTab] if (${d}==`des' & HDeathAver==1), detail 		
		replace ${indi} = `r(p50)'  if ${d}==`des'
		*dis "Condition   ${d}==`des'  `r(p50)' "
	}
	label var ${indi} "${lindi}"
	*tab ${d} ${indi}
	
	dataindi
	
restore



************* AVERAGE YEARS OF EDUCATION AVERTED

global lindi "Average Years of Education lost Averted (years)"
global indi  TEduYeAver
preserve 

	** Categories of disaggregation
	levelsof ${d}, local(desd)
	
	* Initialize
	gen ${indi} = .
	
	* Loop en valores de desagregacion
	foreach des of local desd {
		sum CEduYe [fw = CFexTab] if (${d}==`des' & HDeathAver==1), detail 		
		replace ${indi} = `r(mean)'  if ${d}==`des'
	}
	label var ${indi} "${lindi}"
	
	dataindi
	
restore





