*************************
***** Open data set *****
*************************

clear all
clear matrix
use "Flygskam.dta" 
tsset Numeric_Id Year, yearly 


*********************
***** THE MODEL *****
*********************

* The main model #1
synth passengerpc lnGDPpc HCPI train_pc percent_p area_per_airport TaxesperGDP unempop_work passengerpc(2005) passengerpc(2010) passengerpc(2014), mspeperiod(2003(1)2017) trunit(12) trperiod(2018) resultsperiod(2003(1)2019) keep(Main_results, replace) nested figure

* Effect graphs #2 
synth_runner passengerpc lnGDPpc HCPI train_pc percent_p area_per_airport TaxesperGDP unempop_work passengerpc(2005) passengerpc(2010) passengerpc(2014), mspeperiod(2003(1)2017) trunit(12) trperiod(2018) gen_vars nested

effect_graphs, trlinediff(0)


******************************************
*** getting p values with synth_runner ***
******************************************

*1
clear all
clear matrix
use "Flygskam.dta"
tsset Numeric_Id Year, yearly 

*2
tempfile keepfile
synth_runner passengerpc lnGDPpc HCPI train_pc percent_p area_per_airport TaxesperGDP unempop_work passengerpc(2005) passengerpc(2010) passengerpc(2014), mspeperiod(2003(1)2017) trunit(12) trperiod(2018) nested gen_vars
merge 1:1 Numeric_Id Year using `keepfile', nogenerate
gen flightspc_synthhh = passengerpc-effect 

*3
ereturn list


*******************************
*********** PLACEBO ***********
*******************************
		
* Placebotest (in-time-placebo) * 

*2015
synth passengerpc lnGDPpc HCPI train_pc percent_p area_per_airport TaxesperGDP unempop_work passengerpc(2005) passengerpc(2010) passengerpc(2014), mspeperiod(2003(1)2014) trunit(12) trperiod(2015) keep(in_time_placebo_2015) nested figure

*2016
synth passengerpc lnGDPpc HCPI train_pc percent_p area_per_airport TaxesperGDP unempop_work passengerpc(2005) passengerpc(2010) passengerpc(2014), mspeperiod(2003(1)2015) trunit(12) trperiod(2016) keep(in_time_placebo_2016) nested figure

*2017
synth passengerpc lnGDPpc HCPI train_pc percent_p area_per_airport TaxesperGDP unempop_work passengerpc(2005) passengerpc(2010) passengerpc(2014), mspeperiod(2003(1)2016) trunit(12) trperiod(2017) keep(in_time_placebo_2017) nested figure


***

use "Main_results.dta" 
rename _Y_synthetic _Y_synthetic_Original

merge 1:1  _time using "in_time_placebo_2015.dta"
rename _Y_synthetic _Y_synthetic_2015
drop _merge

merge 1:1 _time using "in_time_placebo_2016.dta"
rename _Y_synthetic _Y_synthetic_2016
drop _merge

merge 1:1 _time using "in_time_placebo_2017.dta"
rename _Y_synthetic _Y_synthetic_2017
drop _merge

twoway (line _Y_treated _time, lcolor(black) lwidth(medthick) lpattern(solid)) (line _Y_synthetic_Original _time, lcolor(gray) lpattern(dash)) (line _Y_synthetic_2015 _time, lcolor(green) lpattern(dash)) (line _Y_synthetic_2016 _time, lcolor(blue) lpattern(dash)) (line _Y_synthetic_2017 _time, lcolor(red) lpattern(dash))


**** Across-space-placebo

clear all
clear matrix
use "Flygskam.dta"
tsset Numeric_Id Year, yearly 

synth_runner passengerpc lnGDPpc HCPI train_pc percent_p area_per_airport TaxesperGDP unempop_work passengerpc(2005) passengerpc(2010) passengerpc(2014), mspeperiod(2003(1)2017) trunit(12) trperiod(2018) gen_vars nested

single_treatment_graphs


***************************
***** Sensitivty test *****
***************************

clear
clear matrix
use "Flygskam.dta"
tsset Numeric_Id Year, yearly 
drop if Numeric_Id==4
synth passengerpc lnGDPpc HCPI train_pc percent_p area_per_airport TaxesperGDP unempop_work passengerpc(2005) passengerpc(2010) passengerpc(2014), mspeperiod(2003(1)2017) trunit(12) trperiod(2018) keep(Sweden_without_Finland) fig resultsperiod(2003(1)2019) nested

* Drop Norway
clear all
clear matrix
use "Flygskam.dta"
tsset Numeric_Id Year, yearly 
drop if Numeric_Id==13
synth passengerpc lnGDPpc HCPI train_pc percent_p area_per_airport TaxesperGDP unempop_work passengerpc(2005) passengerpc(2010) passengerpc(2014), mspeperiod(2003(1)2017) trunit(12) trperiod(2018) keep(Sweden_without_Norway) fig resultsperiod(2003(1)2019) nested

* Drop UK
clear all
clear matrix
use "Flygskam.dta"
tsset Numeric_Id Year, yearly 
drop if Numeric_Id==10
synth passengerpc lnGDPpc HCPI train_pc percent_p area_per_airport TaxesperGDP unempop_work passengerpc(2005) passengerpc(2010) passengerpc(2014), mspeperiod(2003(1)2017) trunit(12) trperiod(2018) keep(Sweden_without_UK) fig resultsperiod(2003(1)2019) nested


* Make the graph 

use "Main_results.dta" 
rename _Y_synthetic _Y_synthetic_Original
 
merge 1:1 _time using "Sweden_without_Finland.dta"
rename _Y_synthetic _Y_synthetic_Finland
drop _merge

merge 1:1 _time using "Sweden_without_Norway.dta"
rename _Y_synthetic _Y_synthetic_Norway
drop _merge

merge 1:1 _time using "Sweden_without_UK.dta"
rename _Y_synthetic _Y_synthetic_Norway
drop _merge

twoway (line _Y_treated _time, lcolor(black) lwidth(medthick) lpattern(solid)) (line _Y_synthetic_Original _time, lcolor(gray) lpattern(dash)) (line _Y_synthetic_Finland _time, lcolor(green) lpattern(dash)) (line _Y_synthetic_Norway _time, lcolor(red) lpattern(dash)) (line _Y_synthetic_UK _time, lcolor(dknavy) lpattern (dash)), ytitle(Numbers of passengers per capita) xtitle(Year) xline(2018, lpattern(dash) lcolor(black))


