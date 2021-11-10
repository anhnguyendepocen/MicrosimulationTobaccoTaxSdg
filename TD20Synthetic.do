*######################## SYNTHETIC DATASET


* Seed for random allocation
set seed 20150406

* Preparing clusters of cores for parallel
*parallel setclusters 2
set processors 2



*label define lasino 1 "Si" 0 "No"
timer clear


forvalues s = $NSimIn/$NSimFi {
*forvalues s = 8/8 {
		
		global Simu = `s'
		
		dis "1. SYNTHETIC DATASET S = ${Simu}"
		
		* Start timing
		timer on 1
		
		quietly {
				** CORE DATASET: ECV
				cd "$lco"
				do TD21SynCoreData


				** ADJUSTMENTS FOR MEASUREMENT ERROR AND UNDERREPORTING
				cd "$lco"
				do TD22SynAdjust


				** MATCHING FOR DATA FROM OTHER SURVEYS
				*cd "$lco"
				*do TD23SynMatch
				
		* Quietly
		}
				
		* Timing
		timer off 1
		timer list 1

}