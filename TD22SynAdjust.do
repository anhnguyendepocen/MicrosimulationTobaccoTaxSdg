///////////////////////// ADJUSTMENTS TO THE SYNTHETIC DATASET   ///// 





/*    */  
*######################################### SMOKING INTENSITY 
*(para los que no fuman diariamente)




* Synthetic Dataset
cd "$lbecea" 
use RSynS${Simu}, clear


** Intensidad de consumo
sum SFumaCuan, detail
dis `r(min)'

* Valores para frecuencias que no tienen  numero de cigarrillos, sacadas de encuesta de consumo de sustancias psicoactivas 2013, que tiene informacion para esas categorias (ver codigo abajo)
*Ver abajo validacion de supuestos
replace SFumaCuan =  1.5  if SFumaFrec == 2
replace SFumaCuan =  0.13 if SFumaFrec == 3
*gsort -SFumaSino SFumaFrec


cd "$lbecea" 
justabit
save RSynS${Simu}, replace
*/







/*    */   
*######################################### NUMERO DE FUMADORES 
*factores de ajuste de subreporte calculados con modelo Probit usando ECSP2019 vs ECV2019
*global Simu = 1

* Synthetic Dataset
cd "$lbecea" 
use RSynS${Simu}, clear



** INICIAL
tab SFumaSino  [fw = CFexTab]
*tab SFumaSino  [fw = CFexTab],  m




*** * AJUSTAR
quietly {

	AdjNumSmo 10 16 1 2.75
	AdjNumSmo 10 16 2 4.46

	AdjNumSmo 17 21 1 1.56
	AdjNumSmo 17 21 2 4.73

	AdjNumSmo 22 26 1 1.31
	AdjNumSmo 22 26 2 3.23

	AdjNumSmo 27 31 1 1.41
	AdjNumSmo 27 31 2 2.91

	AdjNumSmo 32 35 1 1.22
	AdjNumSmo 32 35 2 2.51

	AdjNumSmo 36 49 1 1.14
	AdjNumSmo 36 49 2 2.01

	AdjNumSmo 50 64 1 1.07
	AdjNumSmo 50 64 2 1.69

}

**** VALIDAR
tab SFumaSino  [fw = CFexTab]
*tab SFumaSino  [fw = CFexTab],  m


* Guardar
cd "$lbecea" 
justabit
save RSynS${Simu}, replace




/*      */
*###################### HOGARES EN DONDE HAY FUMADORES 
*(Clave para Second-Hand Smoke y otros household mechanisms)
*(Toca hacerlo despues del ajuste de fumadores)

* Synthetic Dataset
cd "$lbecea" 
use RSynS${Simu}, clear


* En el hogar hay alguien que fuma?
tab SFumaSino, nolabel
bysort $hid: egen SFumaHSino = total(SFumaSino)
mdesc SFumaHSino
replace SFumaHSino = 1 if SFumaHSino>0
label var SFumaHSino "En el hogar alguien fuma?"
label val SFumaHSino lasino
*order SFumaSino SFumaHSino
*gsort $iid SFumaSino SFumaHSino
tab SFumaHSino [fw=CFexTab]
order SFumaHSino, after(SFumaFrec)

cd "$lbecea" 
justabit
save RSynS${Simu}, replace
*/



/* 
*######################################### SECOND-HAND SMOKE
cd "$lbecea" 
use RSynS${Simu}, clear

gen SShsPre = 0 if SFumaHSino == 1
label var SShsPre "Second-Hand Smoke en el hogar Pre-Tax?"
label val SShsPre lasino



/*
***** DEATHS PRE TAX
gen HDiePreTax = 0 if (SFumaSino==1)
label var HDiePreTax "Expected to die for smoking before tax?"
label val HDiePreTax  lasino 

* Probability of being selected (same for all in the group)
gsort $iid
generate RanU = runiform() if (SFumaSino==1) 
gsort -RanU

* Smokers: Population, Total, Proportion
gen  RanPop = sum(CFex)   if (SFumaSino==1)
egen RanTot = total(CFex) if (SFumaSino==1)
gen RanPro = RanPop/RanTot

* Deaths Pre Tax
replace HDiePreTax = 1 if RanPro <= $HDeathTob

order $iid Ran* HDiePreTax
gsort -RanU

* Limpiar
drop Ran*
gsort $iid

* Validar
tab HDiePreTax [fweight = CFexTab]
tab HDiePreTax 
tab HDiePreTax [fweight = CFexTab]  if CQuit==0
*Same random variable also applies for those who do not quit
*/




















/*  

*====================================== ENCSP 2013
* Llenar los de otras frecuencias con base en ENCSP
cd "${lpencsp13}"
use BASE_COLOMBIA_2013_1, clear

* Labels
label define lasino 1 "Si" 0 "No"
label define lafresmo 1 "Diariamente"   2 "Algunos dias a la semana"  ///
	3 "Menos de una vez por semana"
	
	
* Expansion factor
egen fextot = total(fexp3), m
replace fextot = fextot/1000000
sum fextot

gen FexTab = fexp3
gen FexTab10 = round(FexTab*10)

tab p30 p29, m
*Solo responden a la de cuantos los que dicen que si han fumado en ultimos 30 dias
destring p29 p30 p30a, replace

tab p30a
gen 	SFumaDia = 0 if p29==1
replace SFumaDia = 1 if (SFumaDia==0 & p30a >=30 & p30a ~= 99)
label var SFumaDia "Fuma diariamente?"
label val SFumaDia lasino
tab SFumaDia


* Algunos dias a la semana (pero no diario) == < 30 dias & > 5 dias (30/7=4.28), redondeo en 5

** Variables Synthetic
gen SFumaSino = p29
replace SFumaSino = 0 if (SFumaSino  == 2 | SFumaSino  == 9)
label var SFumaSino "Actualmente fuma?"

gen SFumaFrec = . 
replace SFumaFrec = 1 if SFumaDia==1
replace SFumaFrec = 2 if (SFumaSino==1 & p30a <30 & p30a >5)
replace SFumaFrec = 3 if (SFumaSino==1 & p30a <=5)
label var SFumaFrec "Con que frecuencia fuma?"
label val SFumaFrec lafresmo 
tab  SFumaFrec 

gen SFumaCuan = p30
label var SFumaCuan "Aproximadamente, ¿cuántos cigarrillos ha fumado diariamente en los últimos 30 días?"
bysort SFumaFrec: sum SFumaCuan , detail


**** Relevantes

** Variables
keep cabezote municipio dane departamento vivienda hogar  fexp3  ///
	p1-p15 /// 
	p25-p30 p30a SFuma* Fex*
	

order cabezote municipio dane departamento vivienda hogar  fexp3 ///
	p25-p30 p30a  SFuma* ///
	p1-p15  
	
* Observaciones
keep if SFumaSino == 1	

**** ALGUNOS DIAS A LA SEMANA

sum p30 if SFumaFrec ==2, detail
* Quitar observaciones raras
drop if SFumaFrec ==2 & p30>800
*hist p30 if SFumaFrec ==2, kdensity
sum p30 if SFumaFrec==2, detail
* Mediana 3 cigarrillos
gen numcig  = p30*p30a if SFumaFrec==2
sum numcig if SFumaFrec==2, detail
sum numcig  if SFumaFrec==2 [fweight = FexTab10], detail
order numcig p30 p30a
gsort SFumaFrec numcig p30 p30a

*La mediana es 45, y en todos los casos de 45 son 3 cigarrillos, y fuman 15 dias en el mes, es decir, cada dos dias 3 cigarrillos, equivale  1.5 diarios, es decir, 1.5x30 = 45. Voy con esa frecuencia
drop numcig


**** MENOS DE UNA VEZ POR SEMANA
sum p30 if SFumaFrec ==3, detail
* Quitar observaciones raras
drop if SFumaFrec ==3 & p30>88
*hist p30 if SFumaFrec ==3, kdensity
sum p30 if SFumaFrec==3, detail
* Mediana 3 cigarrillos
gen numcig  = p30*p30a if SFumaFrec==3
sum numcig if SFumaFrec==3, detail
sum numcig  if SFumaFrec==3 [fweight = FexTab10], detail
order numcig p30 p30a
gsort SFumaFrec numcig p30 p30a
* La mediana es 4, y la mayoria de observaciones en 4 es 1 cigarrillo y fumo 4 dias o 2 cigarrillos  y fumo 2 dias. En cualquier caso, son 0.13 (4/30)


hhhh

*hist p30 if SFumaFrec ==2
hist p2 if SFumaFrec ==2, kdensity


sssss


* Numero de cigarrillos que se fuma en una sesion de fumado

sum p30 if SFumaFrec ==3, detail
* quitar observaciones raras
drop if SFumaFrec ==3 & p30>88
*hist p30 if SFumaFrec ==3
hist p2 if SFumaFrec ==3
gggggg


* cuando fuma muy esporadicamente es rarisimo que se fumen 1 o 2 cajetillas, biologicamente no


cd "$lbecea" 
preserve  
	drop if _n>=2
	export excel using Encsp13Inte.xlsx, replace sheet("Encsp13") firstrow(varlabels) 
restore
export excel using Encsp13Inte.xlsx, sheet("Encsp13", modify)  cell(A4) firstrow(variables) 

 

cd "${lpencsp19}"

use personas, clear
order DIREC* SECUENCIA_ENCUESTA ORDEN PER_SELECCIONADA


use personas_seleccionadas, clear

egen v = total(FEX_C), m
replace v = v/1000000
sum v

use e_capitulos, clear
tab E_07, m
merge 1:1 DIRECTORIO SECUENCIA_ENCUESTA using personas_seleccionadas, nogen
gen FexTab = FEX_C
gen FexTab10 = round(10*FexTab)
order FexTab*
tab E_07 [fweight = FexTab10], m 

egen NumFum = total(FexTab) if E_07==1
replace NumFum=NumFum/1000000
sum NumFum
ffff












/*   
*####################### ADJUSTMENT FACTORS FOR NUMBER OF SMOKERS

clear 
input CAgeLow CAgeUp AdjuFac
	
		10		11		2.19
		12		16		2.19
		17		21		1.86
		22		26		1.48
		27		31		1.5
		32		36		1.34
		36		64		1.2
end
label var CAgeLow "Lower bound Age"
label var CAgeUp  "Upper bound Age"
label var AdjuFac "Adjustment Factor"

** Guardar
cd "$lbecv19"
save HSmoAdjFac, replace

*rangejoin CAge CAgeLow CAgeUp using IHSynthetic








******** 10-16
egen v1 = total(CFex) if (CAge >=10 & CAge<16 & SFumaSino==1)
sum v1
global v1 = `r(mean)'
global v2 = `r(mean)'*(2.19-1)
global v3 = `r(mean)'*(2.19)


** Probability of being selected (same for all in the group)
gsort $iid
generate RanU = 5+3*runiform() if (CAge >=10 & CAge<16 & SFumaSino==0)
*sum RanU
gsort -RanU

*order RanU CAge SFumaSino


** Cumulative sum vs. total (esto es por numero, no por proporciones/probabilidades)
gen  RanPop = sum(CFex)   if (CAge >=10 & CAge<16 & SFumaSino==0)
order RanPop

replace SFumaSino = 8 if (RanPop<=$v2)
tab SFumaSino [fweight = CFexTab]  if (CAge >=10 & CAge<16 & SFumaSino~=0)
dis "Inicial $v1     Nuevos $v2     Totales $v3"

*2 efectos: primero, error de redondeo del factor de expansion, el efecto es minimo.
*Segundo, efecto indivisibilidad. Si necesito 6230 y en el acumulado llevo 6220 y la siguiente observacion tiene factor de expansion de mas de 10 (que es lo que me falta), entonces quedo 10 por debajo. Si el factor de expansion es mucho mas alto (me acaba de ocurri un caso donde necesito llegar a 6964.7 pero la siguiente observacion tiene factor de expansion de 1320.30) entonces el desajuste es mayor. No veo nada que pueda hacer, queda con ese pequeño sesgo. 
replace SFumaSino = 1 if (SFumaSino==8 & CAge >=10 & CAge<16 & SFumaSino~=0)

** Limpiar
drop v1 RanU RanPop
global v1
global v2
global v3





******** 17-21
global agel = 17
global ageu = 21
egen v1 = total(CFex) if (CAge >=$agel & CAge<$agea & SFumaSino==1)
sum v1
global v1 = `r(mean)'
global v2 = `r(mean)'*(1.86-1)
global v3 = `r(mean)'*(1.86)


** Probability of being selected (same for all in the group)
gsort $iid
generate RanU = 5+3*runiform() if (CAge >=17 & CAge<21 & SFumaSino==0)
*sum RanU
gsort -RanU

*order RanU CAge SFumaSino


** Cumulative sum vs. total (esto es por numero, no por proporciones/probabilidades)
gen  RanPop = sum(CFex)   if (CAge >=17 & CAge<21 & SFumaSino==0)
order RanPop

replace SFumaSino = 8 if (RanPop<=$v2)
tab SFumaSino [fweight = CFexTab]  if (CAge >=17 & CAge<16 & SFumaSino~=0)
dis "Inicial $v1     Nuevos $v2     Totales $v3"
replace SFumaSino = 1 if (SFumaSino==8 & CAge >=10 & CAge<16 & SFumaSino~=0)

** Limpiar
drop v1 RanU RanPop
global v1
global v2
global v3

ddddd


egen RanTot = total(CFex) if (SFumaSino==1)
gen RanPro = RanPop/RanTot

* Deaths Pre Tax
replace HDiePreTax = 1 if RanPro <= $HDeathTob

order $iid Ran* HDiePreTax
gsort -RanU

* Limpiar
drop Ran*
gsort $iid

* Validar
tab HDiePreTax [fweight = CFexTab]
tab HDiePreTax 
tab HDiePreTax [fweight = CFexTab]  if CQuit==0
*Same random variable also applies for those who do not quit









ddd

*??? Se calcula factor de ajuste sobre numero de fumadores o sobre prevalencia? 
*(prevalencia puede eliminar el efecto de diseño muestral)



*??? Ajustar sesgo de subreporte de menores



***** DEATHS PRE TAX
gen HDiePreTax = 0 if (SFumaSino==1)
label var HDiePreTax "Expected to die for smoking before tax?"
label val HDiePreTax  lasino 

* Probability of being selected (same for all in the group)
gsort $iid
generate RanU = runiform() if (SFumaSino==1) 
gsort -RanU

* Smokers: Population, Total, Proportion
gen  RanPop = sum(CFex)   if (SFumaSino==1)
egen RanTot = total(CFex) if (SFumaSino==1)
gen RanPro = RanPop/RanTot

* Deaths Pre Tax
replace HDiePreTax = 1 if RanPro <= $HDeathTob

order $iid Ran* HDiePreTax
gsort -RanU

* Limpiar
drop Ran*
gsort $iid

* Validar
tab HDiePreTax [fweight = CFexTab]
tab HDiePreTax 
tab HDiePreTax [fweight = CFexTab]  if CQuit==0
*Same random variable also applies for those who do not quit


*/


