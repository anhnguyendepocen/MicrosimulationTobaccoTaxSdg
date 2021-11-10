*%%%%%%%%%%%%%%%%%%% MICROSIMULATION - MASTER

* Dropping all Macros
macro drop _all

*** GENERAL LOCATION
*global lge  = "D:/usuarios/80088802/Universidad Icesi (@icesi.edu.co)/"
global lge  = "C:/Users/norma/Universidad Icesi (@icesi.edu.co)/"
*global lge  = "C:/Users/CASA/OneDrive/Universidad Icesi (@icesi.edu.co)/"


** CODIGO
global lco  = "${lge}Proesa - C20-206-EceaMoniTabaco/"
disp "$lco"
cd "$lco"
do TB0Macro

** IDENTIFICADORES
global hid vid hid
global iid vid hid iid


* Number of simulations
global NSimIn = 1
global NSimFi = 30

** DESAGREGACIONES
global Desag CSex HIQuin CVRegion 
*Nal CSex HIQuin CVRegion 



**** 1. SYNTHETIC DATASET

	cd "$lco"
	do TD10Inputs
sss
	cd "$lco"
	*do TD20Synthetic

**** 2. SIMULATION

	* Monte Carlo simulations with parallel computing
	cd "$lco"
	do TD30Simu


**** 3. OUTPUTS

	cd "$lco"
	do TD40Outputs

**** 4. EXPORT

	cd "$lco"
	do TD50Expor

**** 5. DESCRIPTIVE