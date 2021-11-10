*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SYNTHETIC DATASET


/*  
* Dropping all Macros
macro drop _all

*** GENERAL LOCATION
global lge  = "D:/usuarios/80088802/Universidad Icesi (@icesi.edu.co)/"
*global lge  = "C:/Users/norma/Universidad Icesi (@icesi.edu.co)/"


** CODIGO
global lco  = "${lge}Proesa - C20-206-EceaMoniTabaco/"
disp "$lco"
cd "$lco"
do TB0Macro

** IDENTIFICADORES
global hid vid hid
global iid vid hid iid
*/





/* */
*######################## HOUSEHOLD SYNTHETIC DATASET

******************** SUBSIDIOS VIVIENDA
cd "$lpecv19"
use "Tenencia y financiación de la vivienda que ocupa el hogar.dta", clear

** Identificadores
rename DIRECTORIO 			vid
rename SECUENCIA_ENCUESTA 	hid
rename FEX_C TFex
label var TFex "Factor de expansion (Hogar)"
order $hid 
duplicates report $hid


* Subsidio dinero especie para vivienda 
order P5160* 
egen 	IngTransSubViv = rowtotal(P5160S1A1 P5160S2A1), m
replace IngTransSubViv = (IngTransSubViv /12) /1000000
label var IngTransSubViv "K8 (K9 en 2019): Subsidio Dinero Especie Vivienda? (Million COP$/mes)" 


**************** IMPUTACION INGRESO VIVIENDA
* P5095 La vivienda ocupada es (K1)
* P5130 Si tuviera que pagar por el arriendo de esta vivienda (K6)
* P5100 Cuanto paga por valor mensual amortizacion (K2)
order P5095 P5130 P5100
gen 	Ing5ImpViv  = .
replace Ing5ImpViv  = P5130 		if (P5095==1|P5095==4|P5095==5)
replace Ing5ImpViv  = 0 			if (P5095==2 & (P5100==. | P5100==99))
replace Ing5ImpViv  = P5130-P5100	if (P5095==2 & Ing5ImpViv ==. & P5130-P5100>0)
replace Ing5ImpViv  = 0 			if (P5095==2 & Ing5ImpViv ==. & P5130-P5100<0)
replace Ing5ImpViv  = 0  			if (P5095==2 & (P5100~=. & P5130==.) & Ing5ImpViv ==.)
replace Ing5ImpViv = Ing5ImpViv/1000000
label var Ing5ImpViv "Imputacion ingreso vivienda amortizacion (Million COP$/mes)"

* Relevantes
keep  $hid Ing* TFex
order $hid Ing* TFex

** Guardar
cd "$lbecea"
justabit
save HSynthetic, replace




**************** VIVIENDA (UBICACION GEOGRAFICA)
cd "$lpecv19"
use "Datos de la vivienda.dta", clear

** Identificadores
rename DIRECTORIO 		vid
rename REGION 			CVRegion 
label var 				CVRegion "Region"
rename P1_DEPARTAMENTO 	CVDepar
label var 				CVDepar "Departamento"
rename CLASE 			CVCabece
label var 				CVCabece "Cabecera/Centro Poblado"


** Departamentos
destring CVDepar, replace
gsort CVDepar
label define ladepa  5 "Antioquia"   8 "Atlantico"   11 "Bogota D.C." ///
					 13 "Bolivar"   15 "Boyaca"   17 "Caldas"   18 "Caqueta"  ///
					 19 "Cauca"   20 "Cesar"   23 "Cordoba"   25 "Cundinamarca" ///
					 27 "Choco"   41 "Huila"   44 "Guajira"   47 "Magdalena" /// 
					 50 "Meta"   52 "Nariño"   54 "Norte de Santander" ///
					 63 "Quindio"   66 "Risaralda"   68 "Santander"  ///  
					 70 "Sucre"   73 "Tolima"   76 "Valle del Cauca"  ///  
					 81 "Arauca"   85 "Casanare"   86 "Putumayo"   ///  
					 88 "San Andres, Providencia"   91 "Amazonas"   94 "Guainia" ///
					 95 "Guaviare"   97 "Vaupes"   99 "Vichada"
label val CVDepar ladepa
tab CVDepar

* Relevantes
keep vid CV*

** Guardar
cd "$lbecea"
merge 1:m vid using HSynthetic, nogen
order vid hid 
justabit
save HSynthetic, replace





******************** SUBSIDIOS HOGAR
cd "$lpecv19"
use "Condiciones de vida del hogar y tenencia de bienes.dta", clear

** Identificadores
rename DIRECTORIO 			vid
rename SECUENCIA_ENCUESTA 	hid
rename FEX_C VFex
label var VFex "Factor de expansion (Hogar)"
order $hid 
duplicates report $hid

* Subsidios familias accion 
order P784* 
egen 	IngTransSubHog = rowtotal(P784S1A2 P784S2A2), m
replace IngTransSubHog = (IngTransSubHog/12)/1000000
label var IngTransSubHog "L9/12: Subsidios Familias Accion Colombia Mayor (Million COP$/month)"
*! No esta el valor de la tercera opcion "otros programas"

* Relevantes
keep $hid VFex Ing*

* Añadir a Synthetic
cd "$lbecea"
merge 1:1 $hid using HSynthetic, nogen

* Guardar
cd "$lbecea"
justabit
save HSynthetic, replace













*%%%%%%%%% SERVICIOS HOGAR - R
cd "$lpecv19"
use "Servicios del hogar", clear

** Identificadores (Vivienda, Hogar)
rename DIRECTORIO vid 
rename SECUENCIA_ENCUESTA hid
duplicates report vid hid


**** Relevantes
rename FEX_C 		RFex 
rename I_HOGAR 		RIngHogar
rename I_UGASTO 	RIngUGasto
rename PERCAPITA 	RIngPercapita
rename CANT_PER 	RCanPerso

keep vid hid R*

label var RFex "Factor de expansion"


* Million COP$
replace RIngHogar = RIngHogar/1000000
replace RIngUGasto = RIngUGasto/1000000
replace RIngPercapita = RIngPercapita/1000000
label var RIngPercapita "Per-capita income (Mes Million COP$)"

* Calculos per capita
gen RIngHogarPerCap = RIngHogar/RCanPerso
label var RIngHogarPerCap "Calculated Per-capita income Hogar (Mes Million COP$)"




** Factor expansion
gen fe = RFex/1000000
egen fe1 = total(fe)
sum fe1
drop fe*
gen RFexTab = round(RFex)
gen RFexTab10 = round(RFex*10)
label var RFexTab "Factor expansion para tablas (rounded)"
label var RFexTab10 "Factor expansion *10 para tablas (rounded)"
order $hid RFe* R*


** Quintiles
gsort RIngPercapita $hid
xtile RIngQuin = RIngPercapita [fweight=RFexTab],  n(5)
label var RIngQuin "Household's Income Quintile"

pctile RIngQuinCut = RIngPercapita [fweight=RFexTab],  n(5) 
label var RIngQuinCut "Cutpoints of Quintiles"
*drop RIngQuinCut 

** Relevantes
keep $hid RIng* RFex* RCanPerso
order RFex*, last

** Añadir a Synthetic
cd "$lbecea" 
merge 1:1 $hid using HSynthetic, nogen

** Guardar
cd "$lbecea" 
justabit
save HSynthetic, replace
*/











/*   */
*################################### INDIVIDUAL SYNTHETIC DATASET


*%%%%%%%%%% CARACTERISTICAS - C
cd "$lpecv19" 
use "Caracteristicas y composicion del hogar.dta", clear

label define lasino 1 "Si" 0 "No"
label define laparen 1 "Head" 2 "Spouse" 3 "Son/Daughter" ///
					 4 "Grandson/Granddaughter" 5 "Parent/Stepparent" ///
					 6 "Parent in Law" 7 "Sibling" 8 "Son/Daughter in Law" ///
					 9 "Another Head´s Relative" 10 "Housekeeper" /// 
					 11 "Housekeeper´s Relative" ///
					 12 "Employee" 13 "Tenant" 14 "Another Relative"
* Pocas categorias
*label define laparpo 1 "Head" 2 "Spouse" 3 "Son/Daughter" ///
*					 4 "Grandson/Granddaughter" 59 "Another Head´s Relative" ///
*					 1014 "Other Role"
		 

** Identificadores
rename DIRECTORIO 			vid
rename SECUENCIA_P 			hid
rename SECUENCIA_ENCUESTA 	iid
order $iid 
duplicates report $iid

**** Relevantes
rename P6051 CParente
rename P6020 CSex
rename P6040 CAge
rename FEX_C CFex
label var CFex "Factor de expansion"
label var CSex "Sex"
label var CParente "Cual es el parentesco de...con el jefe/a de este hogar?"
 

* Labels
label var CAge "Age (years)"
label val CParente laparen


** Otras relevantes
* Etnia 
rename P6080 CEtnia

* Reducir variables
keep $iid C*


* Factor expansion
gen CFex1 = CFex/1000000
egen tfex = total(CFex1)
sum tfex
drop tfex CFex1
gen CFexTab = round(CFex)
gen CFexTab10 = round(CFex*10)
label var CFexTab "Factor Expansion para tablas (rounded)"
label var CFexTab10 "Factor Expansion *10 para tablas (rounded)"
order $iid CFe* C*


** AGE GROUPS
gen CAgeGroup = .
local age = 4
forvalues k = 1/21 {
	dis "Age `age'   Group `k'"
	replace CAgeGroup = `k' if (CAgeGroup==. & CAge<=`age')
	local age = `age'+5
}
replace CAgeGroup = 21 if (CAgeGroup==. & CAge<=140)
label var CAgeGroup "Age Group"
*order CAge CAgeGroup

** Guardar
cd "$lbecea"
justabit
save ISynthetic, replace








*%%%%%%%%%%  SALUD - S
cd "$lpecv19" 
use Salud, clear
rename DIRECTORIO vid
rename SECUENCIA_P hid
rename SECUENCIA_ENCUESTA iid
rename FEX_C SFex
duplicates report $iid
order $iid

*??? Mujeres embarazadas

* Relevantes
rename P3008S1   SFumaSino
rename P3008S1A1 SFumaFrec
rename P3008S1A2 SFumaCuan
keep $iid S*

label var SFumaSino "Actualmente fuma?"
label var SFumaFrec "Con que frecuencia fuma?"
label var SFumaCuan "Cuantos fuma al dia?"

* Redefinir Si/no
label define lasino 1 "Si" 0 "No"
replace SFumaSino = 0 if SFumaSino ==2
label val SFumaSino  lasino


* Factor de Expansion
gen SFexTab = round(SFex)
gen SFexTab10 = round(SFex*10)
label var SFexTab "Factor Expansion para tablas (rounded)"
label var SFexTab10 "Factor Expansion para tablas (rounded) (x 10 for precision)"

* Prevalencia
order SFe*, last
tab SFumaSino 
tab SFumaSino [fweight = SFexTab]
tab SFumaSino [fweight = SFexTab], m


* Numero de fumadores
egen t = total(SFex) if SFumaSino==1
sum t
drop t

* Supuesto: Menores de 10 años no fuman (que son missing values en la encuesta)
replace SFumaSino = 0 if SFumaSino ==.

* Añadir a Synthetic
cd "$lbecea" 
merge 1:1 ${iid} using ISynthetic, nogen

* Revisar factores expansion
gen d = CFex - SFex
sum d
*Son el mismo, eliminar uno
drop d SFex*


* Guardar
cd "$lbecea"
order $iid C* S* 
order CFex*, last
justabit
save ISynthetic, replace















*%%%%%%%%% TRANSFERENCIAS (AUXILIOS SUBSIDIOS) 
******* ALIMENTOS  MENORES 5 AÑOS
cd "$lpecv19"
use "Atención integral de los niños y niñas menores de 5 años.dta", clear

**** Identificadores
rename DIRECTORIO vid
rename SECUENCIA_P hid
rename SECUENCIA_ENCUESTA iid
rename FEX_C AFex
duplicates report $iid
order $iid

order P774* P776*
gen IngTransDesAlmuRefriMen5 = ( (P774S2-P774S1)*15 + P774S3 *15 + (P776S2-P776S1)*15 + P776S3*15 )/1000000
label var IngTransDesAlmuRefriMen5  "F62b F62a F63a F82a F82b F83a: Desayuno Almuerzo Refrigerio (Million COP$/month)"

* Relevantes
keep $iid Ing* 

* Añadir a Synthetic
cd "$lbecea" 
merge 1:1 ${iid} using ISynthetic, nogen

* Guardar
cd "$lbecea"
order $iid Ing*
justabit
justabit
save ISynthetic, replace








******* MAYORES 5 AÑOS EDUCACION 
cd "$lpecv19"
use "Educación.dta", clear


**** Identificadores
rename DIRECTORIO vid
rename SECUENCIA_P hid
rename SECUENCIA_ENCUESTA iid
rename FEX_C EFex

duplicates report $iid
order $iid

** Nivel educativo
rename P8587 	CENivEdAlto
rename P8587S1	CENivEdAltoGradoApro


** Years of Education. Media Max 13
gen		CEduYe = 0  if CENivEdAlto ~= . 
replace CEduYe = CENivEdAltoGradoApro  if CENivEdAlto ~=. &  CENivEdAlto<=5
* Tecnico 1.5 a 2 años
replace CEduYe = 14 if CENivEdAlto == 6
replace CEduYe = 15 if CENivEdAlto == 7
* Tecnologico 2.5 a 3.5 años
replace CEduYe = 15 if CENivEdAlto == 8
replace CEduYe = 16 if CENivEdAlto == 9
* Universitario: 5
replace CEduYe = 17 if CENivEdAlto == 10
replace CEduYe = 18 if CENivEdAlto == 11
* Posgrado: 2
replace CEduYe = 19 if CENivEdAlto == 12
replace CEduYe = 20 if CENivEdAlto == 13

label var CEduYe "Years of Education"

* Limpiar
drop CENivEdAlto CENivEdAltoGradoApro



* Alimentos Plantel educativo (en especie menos lo que paga)
gen IngTransAlimEs = (P6180S2-P6180S1)*15/1000000
label var IngTransAlimEs "G16a G16b: Alimentos plantel educativo (mes Million COP$)"

* Beca en dinero o especie para estudiar G17
gen 	IngTransBecaEs = .
replace IngTransBecaEs = P8610S1    if P8610S2==1
replace IngTransBecaEs = P8610S1/2  if P8610S2==2
replace IngTransBecaEs = P8610S1/6  if P8610S2==3
replace IngTransBecaEs = P8610S1/12 if P8610S2==4
replace IngTransBecaEs = IngTransBecaEs/1000000
label var IngTransBecaEs "G17: Beca dinero especie para estudiar? (Million COP$/month)"

* Subsidio en dinero o especie para estudiar G19
gen 	IngTransSubsiEs = .
replace IngTransSubsiEs = P8612S1    if P8612S2==1
replace IngTransSubsiEs = P8612S1/2  if P8612S2==2
replace IngTransSubsiEs = P8612S1/6  if P8612S2==3
replace IngTransSubsiEs = P8612S1/12 if P8612S2==4
replace IngTransSubsiEs  = IngTransSubsiEs/1000000
label var IngTransSubsiEs "G19: Subsidio dinero especie para estudiar? (Million COP$/month)"

* Relevantes
keep $iid Ing* CEduYe

* Añadir a Synthetic
cd "$lbecea" 
merge 1:1 ${iid} using ISynthetic, nogen

* Guardar
cd "$lbecea"
order $iid Ing*
justabit
save ISynthetic, replace


















*######## FUERZA DE TRABAJO - F 
cd "$lpecv19"
use "Fuerza de trabajo", clear


**** Identificadores
rename DIRECTORIO vid
rename SECUENCIA_P hid
rename SECUENCIA_ENCUESTA iid
rename FEX_C FFex
duplicates report $iid
order $iid


**************** INGRESOS LABORALES 

**** MONETARIOS

** MENSUALES
order P8624 P8631S1 P8636S1 P8640S1
egen x = rowtotal(P8624 P8631S1 P8636S1 P8640S1), m
gen IngLabMon1 = x/1000000
label var IngLabMon1 "H22+H30+H41+H45: IngLaboralesMon-Salarios (Million COP$/month)" 
order $iid IngLabMon1 P8624 P8631S1 P8636S1 P8640S1   
gsort -IngLabMon1  $iid 
drop x

** ANUALES
* Primas y pagos extraordinarios
order P1087S1A1 P1087S2A1 P1087S3A1 P1087S4A1 P1087S5A1
egen x = rowtotal(P1087S1A1 P1087S2A1 P1087S3A1 P1087S4A1 P1087S5A1), m
gen IngLabMon2 = (x/12)/1000000
label var IngLabMon2 "H31: IngLaboralesMon-PrimasBonif (Million COP$/month)" 
order $iid IngLabMon2  P1087S1A1 P1087S2A1 P1087S3A1 P1087S4A1 P1087S5A1 
gsort -IngLabMon2  $iid


** Independientes y trabajadores de fincas
order P550 P6750 P6435
gen IngLabMon3 = P550/12 if (P550/12) > P6750
replace IngLabMon3 = P6750 if (P550/12) < P6750 & (P6435==4 | P6435==5 | P6435==7)
replace IngLabMon3 = IngLabMon3 /1000000
label var IngLabMon3 "H33vsH32: IngLaboralesMon-Ganancia(Million COP$/month)"
order $iid IngLabMon3 P550 P6750 P6435
gsort -IngLabMon3 $iid 


**** EN ESPECIE
order P6595S1 P6605S1 P6623S1 P6615S1
egen IngLabEsp = rowtotal(P6595S1 P6605S1 P6623S1 P6615S1), m
replace IngLabEsp  = IngLabEsp /1000000
label var IngLabEsp "H23+H24+H25+H26: IngLaboralesEspecie(Million COP$/month)"
order $iid IngLabEsp P6595S1 P6605S1 P6623S1 P6615S1
gsort -IngLabEsp $iid


*** EN SUBSIDIOS
order P8626S1 P8628S1 P8630S1
egen IngLabSub = rowtotal(P8626S1 P8628S1 P8630S1), m
replace IngLabSub = IngLabSub /1000000
label var IngLabSub "H27+H28+H29: IngLaboralesSubsi(Million COP$/Month)"
order $iid IngLabSub  P8626S1 P8628S1 P8630S1
gsort -IngLabSub $iid



******************* INGRESOS DE CAPITAL
order P8646 P8646S1 P8654 P8654S1 P550 P6750 P6435 
gen x1 = P8654S1/12
gen x2 = P550/12 if (P550/12) > P6750
replace x2 = P6750 if P6435==6
egen x3 = rowtotal(P8646S1 x1 x2), m
gen Ing2Cap = x3/1000000
label var Ing2Cap "H50+H54+H33\H32: Ingresos Mensuales Capital (Million COP$)"
order $iid Ing2Cap P8654S1 P550  P6750 P6435 x1 x2 x3 
gsort -Ing2Cap $iid
drop x*


********** TRANSFERENCIAS

**** Pension, vejez sostenimiento
order P8642* P8648* P8644* P8650*
gen P8648S112 = P8648S1/12
gen P8650S1A112 = P8650S1A1/12
egen IngTransPenVeSos = rowtotal(P8642S1 P8644S1  P8648S112 P8650S1A112), m
replace IngTransPenVeSos = IngTransPenVeSos/1000000
label var IngTransPenVeSos "H48+H49+H51/12+H52/12: Pension jubilacion sostenimiento (mes Million COP$)"
drop P8648S112 P8650S1A112


*********** VENTA DE BIENES
order P8652*
gen 	Ing4Venb = (P8652S1/12)/1000000
label var Ing4Venb "H53: Venta bienes (Million COP$/month)"


*** Relevantes
keep $iid Ing* FFex

*** Añadir a Synthetic
cd "$lbecea"
merge 1:1 $iid using ISynthetic, nogen


* Guardar
cd "$lbecea"
order $iid Ing*
justabit
save ISynthetic, replace

*/










*######################## INDIVIDUAL HOUSEHOLD SYNTHETIC DATASET
cd "$lbecea" 
use ISynthetic, clear
merge m:1 $hid using HSynthetic, nogen


***** CATEGORIAS INGRESOS
order IngLabMon1 IngLabMon2 IngLabMon3 IngLabEsp IngLabSub
egen Ing1Labo = rowtotal(IngLabMon1 IngLabMon2 IngLabMon3 IngLabEsp IngLabSub), m
label var Ing1Labo "Ingresos Laborales (Million COP$/month)"

order IngTransDesAlmuRefriMen5 IngTransAlimEs IngTransBecaEs IngTransSubsiEs IngTransPenVeSos IngTransSubViv IngTransSubHog

egen Ing3TransInd = rowtotal(IngTransDesAlmuRefriMen5 IngTransAlimEs IngTransBecaEs IngTransSubsiEs IngTransPenVeSos), m
label var Ing3TransInd "Ingresos Transferencias Individuo (Million COP$/month)"

egen Ing3TransHog = rowtotal(IngTransSubViv IngTransSubHog), m
label var Ing3TransHog "Ingresos Transferencias Hogar (Million COP$/month)"


order $iid Ing1Labo Ing2Cap Ing3Trans* Ing4Venb Ing5ImpViv


**************** REPLICAR INGRESOS

******** HOGAR
* Ingresos totales de cada individuo (solo los de individuo, no los de hogar)
egen HI1 = rowtotal(Ing1Labo Ing2Cap Ing3TransInd Ing4Venb), m  

* Ingresos individuales totales en el hogar
bysort $hid: egen HI2 = total(HI1), m 

* Añadir ingresos del hogar (los que no son por individuo)
egen HMicroIngTot = rowtotal(HI2 Ing3TransHog Ing5ImpViv), m
label var HMicroIngTot "Micro: Ingreso total hogar (Million COP$/month)"
replace HMicroIngTot = 0 if (HMicroIngTot==. & RIngHogar==0)

* Hogar - Ingreso Per Capita
gen HMicroIngPer = HMicroIngTot/RCanPerso 
label var HMicroIngPer "Micro: Ingreso hogar Per Capita (Million COP$/month)"

* Limpiar
drop HI1 HI2


******** UNIDAD DE GASTO
* Ingresos totales de cada individuo (solo los de individuo, no los de hogar)
egen UI1 = rowtotal(Ing1Labo Ing2Cap Ing3TransInd Ing4Venb) if CParente<=9, m  

* Ingresos individuales totales en la unidad de gasto
bysort $hid: egen UI2 = total(UI1), m 

* Añadir ingresos del hogar (los que no son por individuo)
egen UMicroIngTot = rowtotal(UI2 Ing3TransHog Ing5ImpViv), m
label var UMicroIngTot "Micro: Ingreso total unidad de gasto (Million COP$/month)"
replace UMicroIngTot = 0 if (UMicroIngTot==. & RIngUGasto==0)

* Unidad de gasto - numero de personas
gen v = 1
bysort $hid: egen ugas = total(v) if CParente<=9, m
bysort $hid: egen UCanPerso = max(ugas)
drop ugas
label var UCanPerso  "Cantidad de personas en la Unidad de gasto"

* Ingreso Per capita unidad de gasto 
gen UMicroIngPer = UMicroIngTot/UCanPerso
label var UMicroIngPer "Micro: Ingreso unidad de gasto per capita (Million COP$/month)"

* Calculos per capita del dato que ya venia en la base de datos
gen RIngUGastoPerCap = RIngUGasto/UCanPerso
label var RIngUGastoPerCap "Calculated Per-capita income UGasto (Mes Million COP$)"


* Limpiar
drop v UI1 UI2



**** VALIDACION

order $iid HMicro* UMicro* RIngHogar RIngPercapita RIngUGasto RIngUGastoPerCap Ing1* Ing2* Ing3* Ing4* Ing5* RCanPerso UCanPerso IngLabMon1 IngLabMon2 IngLabMon3 IngLabEsp IngLabSub IngTransDesAlmuRefriMen5 IngTransAlimEs IngTransBecaEs IngTransSubsiEs IngTransPenVeSos IngTransSubViv IngTransSubHog

preserve
	*keep if HMicroIngPer==.
	mdesc HMic* UMic* RIng* Ing*
	gsort HMicroIngPer $hid 
	sum UMicro*
	gen xrating = UMicroIngPer/RIngUGastoPerCap
	*hist xrating, percent
	mdesc
	order RIngHogar RIngUGasto   HMicroIngTot UMicroIngTot  xrating
	gen xingtotratio = UMicroIngTot/RIngUGasto
	replace xingtotratio = 1 if (RIngUGasto==0 & UMicroIngTot==0)
	mdesc xingtotratio
	order $iid UMicroIngTot RIngUGasto xingtotratio
	gsort xingtotratio UMicroIngTot RIngUGasto
*	sssss
	
restore




********** LIMPIAR
gsort $iid

*cls

** IID
tostring vid, gen(v1)
tostring hid, gen(v2)
tostring iid, gen(v3)
gen id = v1 + "-" + v2 + " " + v3
drop v1 v2 v3


* Variables relevates con orden
global vmicro  id $iid CFex* CVRegion CVDepar CVCabece CParente CAge CAgeGroup /// 
	CSex  CEduYe  SFuma*  ///
	RIngHogar RIngPercapita RIngUGasto RIngUGastoPerCap RCanPerso UCanPerso   RIngQuin    ///
	HMicroIngTot HMicroIngPer UMicroIngTot UMicroIngPer ///
	Ing1Labo Ing2Cap Ing3TransInd Ing4Venb Ing3TransHog  Ing5ImpViv /// 
	Ing1Labo IngLabMon1 IngLabMon2 IngLabMon3 IngLabEsp IngLabSub ///
	Ing3TransInd IngTransDesAlmuRefriMen5 IngTransAlimEs IngTransBecaEs /// 
	IngTransSubsiEs IngTransPenVeSos Ing3TransHog IngTransSubViv IngTransSubHog  
dis "$vmicro"	

* Limpiar y ordenar
keep  $vmicro
order $vmicro 




* Guardar
cd "$lbecea" 
*justabit
*save IHSynthetic, replace
justabit
save RSynS${Simu}, replace
rm HSynthetic.dta
rm ISynthetic.dta