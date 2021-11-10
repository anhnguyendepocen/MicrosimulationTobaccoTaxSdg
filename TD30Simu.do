*######################## MICROSIMULATION

* Seed for random allocation
set seed 20150406

* Preparing clusters of cores for parallel
*parallel setclusters 2
set processors 2


timer clear


forvalues s = $NSimIn/$NSimFi {
*forvalues s = 8/8 {
			
		global Simu = `s'
		dis "Simulation = `s'"
		
		* Start timing
		timer on 1
		
		quietly {	
				********* SYNTHETIC DATASET
				cd "$lbecea" 
				use RSynS${Simu}, clear
				rename RIngQuin HIQuin

				* ELASTICITIES & PROBABILITY OF QUITTING
				cd "$lbecea" 
				merge m:1 HIQuin using PElasQuit, nogen
				gsort $iid

				* Adjust Probability of quitting for young population
				replace CQuitProp = CQuitProp*$CQuitYouth if CAgeGroup<=5
				
				
				
				************** MODULES
		
		    
				* Consumption
				cd "$lco"
				do TD31SimConsu
				
				
				* Health
				cd "$lco"
				do TD32SimHealth
				
				
				* Healthcare
				cd "$lco"
				do TD33SimHCare
				
				
				* Poverty
				cd "$lco"
				do TD34SimPover
				
		* Quietly
		}
		
		
		
		* Timing
		timer off 1
		timer list 1
		
}

