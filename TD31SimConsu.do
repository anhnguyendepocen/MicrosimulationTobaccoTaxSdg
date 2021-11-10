*############################ CONSUMPTION

*&&&&&&&&&&&& QUITTING
dis "`s'"
gen CQuit = 0 if SFumaSino==1
label var CQuit "Did ____ quit after the tax?"
label val CQuit lasino

order $iid HIQuin CAge CAgeGroup SFuma* CQuit

*local i = 1
forvalues i = 1/5 {

	* Probability of being selected (same for all in the group)
	gsort $iid
	generate RanU`i' = runiform() if (SFumaSino==1 & HIQuin == `i') 
	*??? Probabilities should take sampling weights into account? 
	
	* Smokers: Population, Total, Proportion (gsort in Ranu must go before the cumulative sum)
	gsort -RanU`i'
	gen  RanPop`i' = sum(CFex)   if (SFumaSino==1 & HIQuin == `i')
	egen RanTot`i' = total(CFex) if (SFumaSino==1 & HIQuin == `i')
	gen RanPro`i' = RanPop`i'/RanTot`i'
	*Cambios en el numero total debido a que la aleatoriedad pude poner mas
	*poblacion joven o menos, y ellos tienen un punto de corte distinto
	*order $iid SFumaSino CFexTab Ran* CQuitProp HIQuin CAge CAgeGroup
	
	* Quitting 
	replace CQuit = 1 if RanPro`i' <= CQuitProp
	
	* Limpiar
	drop Ran*
	gsort $iid
}

* Verify random numbers
*rename Ran* ConsuRan*


/* 
*** Validate (vs. Open Access Version)

cls
tab CQuit HIQuin [fweight = CFexTab] if CAgeGroup>5, col
tab CQuitProp if CAgeGroup>5
bysort HIQuin: tab CQuit [fweight = CFexTab]
*Higher because quitting probability for CAgeGroup<=5 is twice higher 

* 
gsort $iid 
order $iid SFuma*  HIQuin Ran*  CQuit CQuitProp
keep if HIQuin == 4 & HSFuma==1
gsort -RanU4
*/



*&&&&&&&&&&&& REDUCTION IN SMOKING INTENSITY (CIntenProp es negativa)
gen SFumaCuanPos = SFumaCuan*(1+CIntenProp) if CQuit==0




*############
* Guardar 
cd "$lbecea"
save TempMicSimConsu${Simu}, replace

