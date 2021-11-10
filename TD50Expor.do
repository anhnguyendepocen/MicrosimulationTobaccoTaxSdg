/*   */   
*%%%%%%%%%%%%%%%%%%% EXCEL 

cd "$lbecea"
	
** Indicadores
foreach d of global Desag {
*local d Nal

	* Guardar
	use TD`d', clear
		preserve
		drop if _n>1
		export excel TD`d'.xlsx, sheet("`d'",replace) firstrow(varlabels) 
	restore
	export excel TD`d'.xlsx, sheet("`d'",modify) cell(A2) firstrow(variables)
}




/* 
** Microdatos
use SSimS1, clear
preserve
	keep if _n<=1
	export excel SSimS1.xlsx, sheet("S1",replace ) firstrow(varlabels) 
restore
*export excel SSimS1.xlsx, sheet("S1",modify) cell(A2) firstrow(variables) 


	
*/