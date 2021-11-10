*###################### OUTPUTS 


****************************




* Preparing clusters of cores for parallel
*parallel setclusters 2
set processors 2


*%%%%%%%%%% CALCULO INDICADORES

program dataindi
	
	* Ordenar
	keep ${d} ${indi} 
	duplicates drop ${d} ${indi}, force
	drop if ${indi} ==.

	* Save
	gen S = ${s}
	merge 1:1 S ${d} using TD${d}S${s}, nogen
	order ${indi}, last
	*justabit
	save TD${d}S${s}, replace
	
	* Limpiar
	global indi
	global lindi
end


timer clear

forvalues s = $NSimIn/$NSimFi {
*forvalues s = 11/$NSimFi {

	dis "                                             SIMULACION  S = `s'"

	* Timer
	timer on 1
	
	** DESAGREGACIONES
	foreach d of global Desag {
		global d `d'
		global s `s'
		
		
		timer on 2
		* Data
		qui cd "$lbecea"
		qui use SSimS`s', clear
		dis "0 Datos s=`s'  "
	
		dis "1 Indicadores s=${s}    d=${d} "
		
		
			quietly {
		
				************ CONSUMPTION
				cd "${lco}"
				do TD41Consu

				************ HEALTH
				cd "${lco}"
				do TD42Heal
				
				************ HEALTHCARE
				cd "${lco}"
				do TD43HCare
				
				************ POVERTY
				cd "${lco}"
				do TD44Pover
				
				************ TAX REVENUE
				cd "${lco}"
				do TD45TaxRev
				
				************ TAX REVENUE
				cd "${lco}"
				do TD46Deve
				
				
				******** ACTUALIZAR Y GUARDAR

				if `s' == 1 {
					use  TD`d'S1, clear
					save TD`d', replace
					rm TD`d'S1.dta
					dis "111111"
					}
				else if `s' > 1 {
					use TD`d', clear
					append using TD`d'S`s'
					save TD`d', replace
					rm TD`d'S`s'.dta
					dis "222222"
					}	
				
				* Timing Desag d
				timer off 2
				timer list 2
	
			* Quietly	
			}
			
		* Desag
		}
	
	
		
	* Timing
	timer off 1
	timer list 1	
}



		
	