*%%%%%%%%%%%%%%%%%%%%%%%%%   INPUTS - I

**** CONVENTIONS (Prefixes and Suffixes)
* Pre: Pre  Tax increase
* Pos: Post Tax increase

clear


*&&&&&&&&&&&& STRUCTURAL - S (PRICES)


**************** PRICE MODEL 

******** Taxes

** Values
* Specific (excise)
global STaxVaSpePre = 2563
global STaxVaSpePos = 7000

* AdValorem (excise)
*global STaxVaAdvPre = 455.1 
global STaxVaAdvPre = 606.91
global STaxVaAdvPos = $STaxVaAdvPre

* Value Added Vat
*global STaxVaVatPre = 573 
global STaxVaVatPre = 524.13 
global STaxVaVatPos = $STaxVaVatPre

* Total
global STaxVaTotPre = $STaxVaSpePre + $STaxVaAdvPre + $STaxVaVatPre
global STaxVaTotPos = $STaxVaSpePos + $STaxVaAdvPos + $STaxVaVatPos



** Rates
* AdValorem (excise)
global STaxRaAdvPre = 0.10 
global STaxRaAdvPos = $STaxRaAdvPre

*Value Added Vat
global STaxRaVatPre = 0.19 
global STaxRaVatPos = $STaxRaVatPre

* Pass-Through Specific (excise)
*global STaxPassSpePre = 1.88
global STaxPassSpePre = 1.2
global STaxPassSpePos = $STaxPassSpePre



** Implicit Baseline Prices

* Ibp Vat
global STaxIbpVatPre = $STaxVaVatPre/$STaxRaVatPre
global STaxIbpVatPos = $STaxVaVatPos/$STaxRaVatPos

* Ibp AdValorem
global STaxIbpAdvPre = $STaxVaAdvPre/$STaxRaAdvPre
global STaxIbpAdvPos = $STaxVaAdvPos/$STaxRaAdvPos




******** Exwork
* Manufacturing Cost
global SExwManCoPre = 1000
global SExwManCoPos = $SExwManCoPre

* Manufacturing Profit Rate
global SExwMinProRaPre = 0.2
global SExwMinProRaPos = $SExwMinProRaPre

* Manufacturing Profit
global SExwManProPre = $SExwManCoPre*$SExwMinProRaPre + ($STaxPassSpePre-1)*$STaxVaSpePre

global SExwManProPos = $SExwManCoPos*$SExwMinProRaPos + ($STaxPassSpePos-1)*$STaxVaSpePos

* Price Exwork with no taxes (excise)
global SExwPriNoExciPre = $SExwManCoPre + $SExwManProPre
global SExwPriNoExciPos = $SExwManCoPos + $SExwManProPos

* Profit Rate
global SExwProRaPre = ($SExwPriNoExciPre - $SExwManCoPre) / $SExwManCoPre 
global SExwProRaPos = ($SExwPriNoExciPos - $SExwManCoPos) / $SExwManCoPos 



******** Price
* Price Exwork with Taxes
global SPriPrExwTaxPre = $SExwPriNoExciPre + ($STaxVaSpePre + $STaxVaAdvPre + $STaxVaVatPre)

global SPriPrExwTaxPos = $SExwPriNoExciPos + ($STaxVaSpePos + $STaxVaAdvPos + $STaxVaVatPos)

* Distribution Margin
global SPriDisMaPre = 0.15
global SPriDisMaPos = $SPriDisMaPre

* Retail Margin
global SPriRetMaPre = 0.15
global SPriRetMaPos = $SPriRetMaPre

* Retail Price 
global SPriPrRetaPre = $SPriPrExwTaxPre*(1 + $SPriRetMaPre + $SPriRetMaPre)
 
global SPriPrRetaPos = $SPriPrExwTaxPos*(1 + $SPriRetMaPos + $SPriRetMaPos)
*Rounded
global SPriPrRetaPreRou = round(${SPriPrRetaPre},0.01)
global SPriPrRetaPosRou = round(${SPriPrRetaPos},0.01)

* Retail Price Increase
global SPriceIncrease = ($SPriPrRetaPos - $SPriPrRetaPre)/$SPriPrRetaPre







*** Impact on Elasticities (kind of half of elasticity for quitting, half for intensity)
* At the extensive margin
global SImpaElasExtensive = 0.5

* At the intensive margin (based on DEICS)
*??? Estimate elasticity with DEICS. -0.4524 is just change in prices vs. change in intensity
global SImpaElasIntensive = -0.4524638

* Increase Impact Extensive Margin Youth 
global CQuitYouth = 2

macro dir 




******** ELASTICITIES

** Quintiles
gen HIQuin = .
forvalues k = 1/5 {
	insobs 1
	dis "`k'"  "Q`k'"
	replace HIQuin = `k' in `=_N'
}
label var HIQuin "Structural - Income Quintile"

** Elasticities
global SPriElasQ1 = -0.635
global SPriElasQ5 = -0.122 

* Linear interpolation
gen SPriElas = .
forvalues k = 1/5 {
	replace SPriElas = $SPriElasQ1 + (`k'-1)*( ( $SPriElasQ5-$SPriElasQ1 ) /4 ) in `k'
	* /4 to get quintiles 
}
label var SPriElas "Structural - Price Elasticities"


* Limpiar
global SPriElasQ1
global SPriElasQ5


** Probability of Quitting

* Consumption - Quitting Proportion
gen CQuitProp = -SPriElas*$SImpaElasExtensive*$SPriceIncrease
label var CQuitProp "Proportion of smokers expected to quit"

* Consumption - Reduction on smoking intensity on those who remain smoking
gen CIntenProp = -SPriElas*$SImpaElasIntensive*$SPriceIncrease
label var CIntenProp "Reduction of smoking intensity (percentage of current consumption) "

** Guardar
cd "$lbecea"
save PElasQuit, replace







*##################### CONSUMPTION

* Ajusta numero de fumadores de acuerdo con factores de ajuste calculados de la encsp2019
* 1 Lower-bound age, 2 Upper bound Age, 3 Sex, 4 Factor of adjustment
program AdjNumSmo


	global nage CAge>=`1' & CAge<=`2' & CSex==`3'
	qui egen RanNume = total(CFex) if ($nage & SFumaSino==1), m
	sum RanNume

	* Calcular numero de nuevos fumadores
	global nsmo = `r(mean)'*(`4'-1)
	dis "Extra Smokers $nage:   $nsmo"

	* Probability of being selected (same for all in the group)
	*the additive term (8) is useful to avoid confusion between random numbers and probabilities (proportions and cutoff values)
	gsort $iid
	qui generate RanU = 8+runiform() if ($nage & SFumaSino==0 ) 
	*order RanU CAge SFumaSino

	
	* Number of Smokers (gsort in RanU must go BEFORE the cumulative sum)
	gsort -RanU
	qui gen  RanPop = sum(CFex)   if ($nage & SFumaSino==0)
	qui gen RanW = 1 if RanPop<=$nsmo
	
	*! Con RanW, por numeros grandes, es posible que se llegue a menos fumadores que los ajustados (es decir, si la siguiente observacion me añade 2000 fumadores pero yo solo necesito 500, entonces me quedo sin los 500)
	* Para no subestimar sino sobreestimar, lo siguiente (con RanV)
	qui gen long RanObsn = _n 
	qui sum RanObsn if RanPop>$nsmo, meanonly 
	* La minima observacion que se pasa del numero critico
	*dis "RanV ========== `r(min)'"
	qui gen RanV = 1 if _n<=`r(min)'
	*order Ran* CFex 
	qui replace SFumaSino = 1 if RanW == 1

	qui sum RanW
	*dis "RanW ========== `r(N)'"

	*** Colocar Frecuencia y numero de cigarrillos con mediana
	*??? Pendiente hacer esto usando la distribucion, no la mediana de cada grupo

	* Frecuencia
	tab SFumaFrec [fw = CFexTab] if ($nage & SFumaSino==1)
	qui sum SFumaFrec [fw = CFexTab] if ($nage & SFumaSino==1), detail
	dis "`r(p50)'"
	qui replace SFumaFrec = `r(p50)' if RanW == 1
	
	* Intensidad
	qui sum SFumaCuan [fw = CFexTab] if ($nage & SFumaSino==1), detail
	dis "`r(p50)'"
	qui replace SFumaCuan = `r(p50)' if RanW == 1
	*order SFuma* RanV

	*??? Cuidado puede que la mediana por separado en cada grupo para frecuencia y para intensidad de cosas incoherentes, es decir, que me de una frecuencia de Diario y una intensidad de algunas veces a la semana

	* Limpiar
	gsort $iid
	drop Ran*
	global nsmo
	global nage

end







******* IMPORTS
* Cajetillas de 20 segun registro de importacion Dane 2019
global SCigaImpo = 425.155924



******** ILLICIT TRADE (PRE-TAX)
global SIlliTraPre =  0.064   



*##################### HEALTH

* Smokers deaths caused by tobacco
global HDeathTob = 0.5

* Shares of Averted deaths by NCD
global HShareHear = 0.52336165	
global HShareStro = 0.223907767
global HShareCopd = 0.185072816
global HShareCanc = 0.067657767

* Second-Hand Smoke Shares of Averted deaths by NCD
global HShsShareHear = 0.39574816
global HShsShareStro = 0.108160262
global HShsShareCopd = 0.412755519
global HShsShareCanc = 0.083336059



**** RISK REDUCTION
clear 
input CAgeGroup	HRiskRedu
	
		1	1
		2	1
		3	1
		4	0.968811722
		5	0.947662258
		6	0.92098104
		7	0.892470978
		8	0.865640471
		9	0.836784324
		10	0.794983743
		11	0.729006299
		12	0.628344949
		13	0.499176461
		14	0.364361418
		15	0.246916804
		16	0.156773014
		17	0.090773853
		18	0.045194143
		19	0.016308707
		20	0.000392369
		21	0.000392369
end
label var CAgeGroup "Age Group"
label var HRiskRedu "Risk Reduction"

** Guardar
cd "$lbecea"
save HRiskRedu, replace




** LIFE YEARS 

* Life Years Gained
clear
input HAgeLiYe HLiYeGain	 
	0	0.00
	15	10.00
	25	9.00
	45	6.00
	65	3.00
	105	0.00
end
label var HAgeLiYe "Health - Age for Life Years"
label var HLiYeGain "Health - Life Years Gained"

** Guardar
cd "$lbecea"
save HLiYeGain, replace


** Cubic 
*??? Cubic spline in stata. Data taken from excel (macro in visual)
clear

input CAge	HAgeLiYe
		0	0	
		1	0.90168
		2	1.79706
		3	2.67985
		4	3.54376
		5	4.38248
		6	5.18973
		7	5.95922
		8	6.68464
		9	7.35970
		10	7.97810
		11	8.53356
		12	9.01977
		13	9.43045
		14	9.75929
		15	10.00000
		16	10.14911
		17	10.21446
		18	10.20669
		19	10.13645
		20	10.01442
		21	9.85122
		22	9.65753
		23	9.44399
		24	9.22127
		25	9.00000
		26	8.78894
		27	8.58918
		28	8.39992
		29	8.22034
		30	8.04962
		31	7.88695
		32	7.73152
		33	7.58252
		34	7.43914
		35	7.30056
		36	7.16596
		37	7.03454
		38	6.90549
		39	6.77798
		40	6.65122
		41	6.52438
		42	6.39665
		43	6.26722
		44	6.13527
		45	6.00000
		46	5.86080
		47	5.71788
		48	5.57169
		49	5.42264
		50	5.27117
		51	5.11771
		52	4.96268
		53	4.80651
		54	4.64964
		55	4.49248
		56	4.33548
		57	4.17906
		58	4.02364
		59	3.86966
		60	3.71755
		61	3.56774
		62	3.42064
		63	3.27670
		64	3.13635
		65	3.00000
		66	2.86800
		67	2.74034
		68	2.61689
		69	2.49754
		70	2.38219
		71	2.27073
		72	2.16304
		73	2.05902
		74	1.95854
		75	1.86151
		76	1.76781
		77	1.67732
		78	1.58995
		79	1.50557
		80	1.42408
		81	1.34536
		82	1.26930
		83	1.19580
		84	1.12474
		85	1.05601
		86	0.98950
		87	0.92510
		88	0.86270
		89	0.80219
		90	0.74345
		91	0.68637
		92	0.63085
		93	0.57678
		94	0.52403
		95	0.47251
		96	0.42209
		97	0.37268
		98	0.32415
		99	0.27640
		100	0.22932
		101	0.18279
		102	0.13670
		103	0.09095
		104	0.04542
		105	0.00000
		106	0.00000
		107	0.00000
		108	0.00000
		109	0.00000
		110	0.00000
		111	0.00000
		112	0.00000
		113	0.00000
		114	0.00000
		115	0.00000
		116	0.00000
		117	0.00000		
end
label var CAge "Age"
label var HAgeLiYe "Health - Life Years Gained"

** Guardar
cd "$lbecea"
save HLiYeGainCubSpli, replace







*##################### HEALTHCARE


* Healthcare Utilization Gradient
clear
input HIQuin EUtiGrad	 
		1		1.002717
		2		1.092391
		3		1.000000
		4		1.058424
		5		1.173913
end
label var HIQuin "Structural - Income Quintile"
label var EUtiGrad "Healthcare Utilization Gradient"


* Probability of utilization
global EUti 0.7

* Calculate probability of using healthcare
replace EUtiGrad = ${EUti}*EUtiGrad

** Guardar
cd "$lbecea"
save EUtiGradi, replace



** COSTS (Million COP$ per year per peson - Annual)
* Heart disease
global ECost1		 4.703103 
* Stroke
global ECost2		 9.548821 
* Copd
global ECost3		 5.744358
* Cancer
global ECost4		14.665237

**** COPAYMENTS (for Out Of Pocket expenditure)
* Reimbursement
global ECopayReim = 1

* Fraction of population insured
global ECopayInsu = 0.91

* Proportion of healthcare expenditures as Out Of Pocket
global ECopayProOop = ${ECopayInsu}*(1-${ECopayReim}) + (1- ${ECopayInsu})*${ECopayReim}
*dis "${ECopayProOop}"









*##################### POVERTY

* Linea de pobreza monetaria
global PLinPobMon = 0.257433

* Linea de Indigencia o pobreza extrema
global PLinPobExt = 0.117605

*??? Heterogeneidad de Linea de Pobreza por cabecera, centro poblado, rural, etc

*??? Update to 2019 using Consumer Price Index

* Gasto Catastrofico
global PGasCat = 0.1