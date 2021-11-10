*##################### POVERTY


*!!!!! No es per capita

******** HOUSEHOLDS CURRENTLY IN POVERTY

** Pobreza Monetaria
gen 	PHouPobMon = 0 & UMicroIngPer~=.
replace PHouPobMon = 1 if ( UMicroIngPer~=. & UMicroIngPer < ${PLinPobMon} )
label var PHouPobMon "El hogar esta en pobreza monetaria?"
label val PHouPobMon lasino


*gen 	Prueba = 0
*replace Prueba = 1 if UMicroIngPer < ${PLinPobMon}



** Pobreza extrema (linea Indigencia)
gen 	PHouPobExt = 0 if UMicroIngPer~=.
replace PHouPobExt = 1 if (UMicroIngPer~=. & UMicroIngPer < ${PLinPobExt})
label var PHouPobExt "El hogar esta en pobreza extrema?"
label val PHouPobExt lasino

* Validar
tab PHouPobMon [fweight = CFexTab]
tab PHouPobExt [fweight = CFexTab]
*! Da 39%, en el reporte DANE 2019 da 35%, aunque da muy alto con respecto a 2018
* PNonPoor es el negativo de PHouPobMon






******** HHs PUSHED INTO POVERTY AVERTED

*! En absoluto no hay problema con lo de unidad de gasto, pero si se mide como 
*proporcion, si es proporcion de individuos deben ser solo los individuos que 
*hacen parte de la unidad de gasto, y si es proporcion de unidades de gasto ahi no hay problema
*(como proporcion de hogares si hay lio porque un hogar podria tener variaas unidades de gasto)

** Total Out of Pocket  healthcare expenditure in the household
*order $iid HDeathAver HNcdDeaAver HDiePreTax HDiePosTax ECostTotal ECostOop ECostOohs
bysort $hid: egen ECostOopH = total(ECostOop), m
*order ECostOopH 
*???? Sohuld I use the Household Expenditure or the Unidad de Gasto Expenditure?

* Must be nonpoor to become poor (and therefore to be averted from poverty)
gen PAverPobMon = 0 if (PHouPobMon==0)
replace PAverPobMon = 1 if  (PAverPobMon == 0 & (UMicroIngTot-ECostOopH)/UCanPerso < ${PLinPobMon})
label var PAverPobMon "El hogar fue averted de pobreza monetaria por healthcare costs?"
label val PAverPobMon lasino






******** HHs PUSHED CINTO CATASTROPHIC EXPENDITURE AVERTED
gen PPropGasCat = ECostOopH/UMicroIngTot

gen PAverGasCas = 0 if UMicroIngTot~=.
replace PAverGasCas = 1 if (PPropGasCat~=. &  PPropGasCat> ${PGasCat})
label var PAverGasCas "El hogar fue averted de gasto catastrofico por healthcare costs?"
label val PAverGasCas lasino



*** Guardar
cd "$lbecea"
dis "${Simu}"
gsort $iid

* Calculos nacionales
gen Nal = 1


* Order
global vmicro  id $iid CFex* CParente CAge CAgeGroup CSex  SFumaSino SFumaFrec SFumaCuan  ///
	RIngHogar RIngUGasto RCanPerso UCanPerso RIngPercapita  RIngQuin  RIngQuinCut   ///
	HMicroIngTot HMicroIngPer UMicroIngTot UMicroIngPer ///
	Ing1Labo Ing2Cap Ing3TransInd Ing4Venb Ing3TransHog  Ing5ImpViv /// 
	Ing1Labo IngLabMon1 IngLabMon2 IngLabMon3 IngLabEsp IngLabSub ///
	Ing3TransInd IngTransDesAlmuRefriMen5 IngTransAlimEs IngTransBecaEs IngTransSubsiEs IngTransPenVeSos    ///
	Ing3TransHog IngTransSubViv IngTransSubHog  
dis "$vmicro"	

order id $iid CFex* CParente CAge CAgeGroup SPriElas CIntenProp HIQuin CQuitProp CSex SFumaSino SFumaFrec SFumaCuan 	 ///
	CVRegion CVDepar CVCabece CEduYe ///   
	HDiePreTax HRiskRedu HAgeLiYe CQuit SFumaCuanPos HQuitDie  HLiYeGainPosTaxQuit  ///
	HDiePosTax HDeathAver HNcdDeaAver  ///
	EUtiGrad EUtiHCare ECostTotal ECostOop ECostOohs /// 
	RCanPerso UCanPerso RIngHogar RIngUGasto  RIngPercapita   ///
	HMicroIngTot HMicroIngPer UMicroIngTot UMicroIngPer ///
	PHouPobMon PHouPobExt ECostOopH PAverPobMon PPropGasCat PAverGasCas 


* Guardar
save SSimS${Simu}, replace

* Limpiar
rm TempMicSimConsu${Simu}.dta
rm TempMicSimHealth${Simu}.dta
rm TempMicSimHCare${Simu}.dta
 


