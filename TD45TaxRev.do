qui cd "$lbecea"

*############################## TAX REVENUES



************* CIGARETTES SMOKED IN COLOMBIA

global lindi "Tax Revenues from Specific component Pre-Tax from licit cigarettes smoked in Colombia (million million COP)"
global indi  TRevPreSpeSmo
preserve 
	** Calcular
	* Consumption
	gen Con = (CFex*SFumaCuan*(30*12)/20)
	bysort ${d}: egen TCon = total(Con), m
	
	* Consumption net of illicit trade
	gen ConNetIll = TCon*(1-${SIlliTraPre})
	
	* Tax Revenues from consumption net of illicit trade
	gen ${indi} = (ConNetIll*${STaxVaSpePre})/1000000000000
	label var ${indi} "${lindi}"

	dataindi
	
restore




global lindi "Tax Revenues from Specific component Post-Tax from licit cigarettes smoked in Colombia (million million COP)"
global indi  TRevPosSpeSmo
preserve 
	** Calcular
	* Illicit trade (level pre-tax)
	gen ConsPre = (CFex*SFumaCuan*(30*12)/20)
	bysort ${d}: egen TConsPre = total(ConsPre), m
	gen ConsPreIlli = TConsPre*${SIlliTraPre}
	
	* Consumption Post-Tax
	gen ConsPos = (CFex*SFumaCuanPos*(30*12)/20) if (SFumaSino==1 & CQuit==0)
	bysort ${d}: egen TConsPos = total(ConsPos) , m
	
	* Consumption Post-tax net of illicit trade
	gen ConsNetIll = TConsPos - ConsPreIlli
	*${STaxVaSpePos}
	
	* Tax Revenues (only from licit cigarettes)
	gen ${indi} = (ConsNetIll*${STaxVaSpePos})/1000000000000
	label var ${indi} "${lindi}"
	
	dataindi
	
restore






********** CIGARETTES LEGALLY IMPORTED TO COLOMBIA


global lindi "Tax Revenues from Specific component Pre-Tax from cigarettes entering Colombia (million million COP) (imports)"
global indi  TRevPreSpeCol
preserve 
	* Calcular
	gen TRev = (${SCigaImpo}*1000000)*${STaxVaSpePre}
	gen ${indi} = TRev/1000000000000
	label var ${indi} "${lindi}"

	dataindi
	
restore




global lindi "Tax Revenues from Specific component Post-Tax from cigarettes entering Colombia (million million COP) (imports)"
global indi  TRevPosSpeCol
preserve 
	* Calcular
	gen CigPre = CFex*SFumaCuan*(30*12)/20 if  (SFumaSino==1)
	bysort ${d}: egen TCigPre = total(CigPre) , m

	gen CigPos = CFex*SFumaCuanPos*(30*12)/20 if  (SFumaSino==1 & CQuit==0)
	bysort ${d}: egen TCigPos = total(CigPos) , m
	gen ${indi} = (${SCigaImpo}*1000000 - (TCigPre-TCigPos))*${STaxVaSpePos}
	replace ${indi} = ${indi}/1000000000000
	label var ${indi} "${lindi}"
	
	dataindi
	
restore






*###################    INDUSTRY PROFITS  (INCLUDE PROFITS FROM ILLICIT TRADE)


global lindi "Industry Profits Pre-Tax from cigarettes smoked in Colombia (million million COP)"
global indi  TProfPreSmo
preserve 
	* Calcular
	gen Prof = (CFex*SFumaCuan*(30*12)/20)*${SExwManProPre}
	bysort ${d}: egen ${indi} = total(Prof) , m
	replace ${indi} = ${indi}/1000000000000
	label var ${indi} "${lindi}"

	dataindi
	
restore



global lindi "Industry Profits Pre-Tax from cigarettes smoked in Colombia (million million COP)"
global indi  TProfPosSmo
preserve 
	* Calcular
	gen Prof = (CFex*SFumaCuanPos*(30*12)/20)*${SExwManProPos} if  (SFumaSino==1 & CQuit==0)
	bysort ${d}: egen ${indi} = total(Prof) , m
	replace ${indi} = ${indi}/1000000000000
	label var ${indi} "${lindi}"

	dataindi
	
restore


