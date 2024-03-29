// -----------------------------	
// NAME
// Jan. 2024
// -----------------------------	
// *********
//Intro formalities

clear all
capture drop _all
capture log close
log using output.log, replace

// Options
set linesize 255
set more off
set maxiter 100
// Timer
timer on 1

// *********
// Load Data, Covert all to Monthly
// *********

// Collaspe
clear
import delimited CDataM.csv
generate time=tm(1972m1)+_n-1 
format %tm time
tsset time



//****************************************************************************************************

// a) Test for additive and multiplicative seasonality in CPI after 1992m1. Is there evidence?

// Additive seasonality test by regressing cpi on monthly seasonality
regress cpi i.month if time>=tm(1992m1) 
// The monthly p-value is higher than 0.05. The F-test is significant. Overall, there is evidence of weak additive seasonality.

// Multiplictive  seasonality test by regressing the ln(cpi) on monthly seasonality
gen lcpi = ln(cpi)
regress lcpi i.month if time>=tm(1992m1)
// The monthly p-value is higher than 0.05. The F-static is significant. Overall, there is evidence of weak multiplicative seasonality. 


// Multiplictive  seasonality test by taking the month-over-month growth in cpi on monthly seasonality
gen dcpi= cpi/l.cpi-1
regress dcpi i.month if time>=tm(1992m1)
// The monthly p-value is lower than 0.05 near the end of the year. The F-static is significant. Overall, there is evidence of some multiplicative seasonality around the holiday season.

// Overall there is evidence of some seasonality in the month-over-month growth rate of CPI however, it is not conclusive evidence of additive or multiplicative seasonality in the CPI data.



//****************************************************************************************************

// b)  Provide a graph of the month-over-month growth rates of both CPI. and total BCPI, 1972M1–2023M12.

//Percentage change Y-o-Y
gen gp12= 100*(cpi/L12.cpi-1)
gen gbcpi12= 100*(bcpi/L12.bcpi-1)


// label variable gy12 "Real GDP"
label variable gp12 "Headline CPI"
label variable gbcpi12 "BCPI"

//Graphs of month-over-month growth rates of both CPI and total BCPI

twoway (tsline gp12) (tsline gbcpi12, yaxis(2)),  ytitle("Percent Change") ytitle("Percent Change (BCPI)", axis(2)) legend( bmargin(small) nobox region(lstyle(none) lcolor(white)) cols(2)) xtitle("Years") graphregion(color(white)) 
graph export "FiguresYoY.png", replace width(4000) // save graph



//****************************************************************************************************

// c) The Bank of Canada in February 1991 shifted it's approach to monetary policy by moving to inflation targeting within a range of 1% to 3%. This would have a significant impact on CPI through the Bank's new monetary policy approach as inflation was now being anchored at a low and stable rate, influencing how businesses and consumers make their day-to-day decisions. 
// We are testing whether there was a statistically significant change in the behaviour of CPI before and after that Bank of Canada's policy change. 



//****************************************************************************************************

// d) ADF TEST - Null hypothesis H0 : CPI data is non-stationary.
// ADF test on the level data
// Choose lags of the DF test using dfgls
dfgls cpi // By default, a trend is included.
dfuller cpi, lags(12)  // based on a Opt lag(12) from above
// Results: The ADF test shows that the test statistic of -0.188 is not more negative than any of the critical values at 1%, 5%, or at 10%. Thus we fail to reject the null hypothesis that the CPI time series is stationary. The p-value is 0.9399, higher than the conventional threshold of 5% which also indicates that there is not sufficient statistical evidence to conclude that the CPI data is stationary as we fail to reject the null hypothesis.

// ADF test on the transformed data (first difference)
gen diff_cpi = D.cpi
dfuller diff_cpi, lags(12)
// Results: The ADF test statistic has a value of -4.089 and is more nagative than the critical values at 1%, 3%, and at 5%. Additionally, the p-value of 0.0010 is below the threshold of 5%. This indicates that there is enough statistical significance to reject the null hypothesis, implying that the differenced CPI is stationary. 


// KPSS TEST - Null hypothesis H0 : CPI data is non-stationary.
// KPSS test on the level data with trend
kpss cpi, trend
// Results:

// KPSS test on the level data without trend
kpss cpi, maxlag(12) notrend
// Results:

// KPSS test on the transformed data (first difference) without trend
kpss diff_cpi, maxlag(12) notrend
// Results:



//****************************************************************************************************
ac d.cpi
// e) Generate ACF and PACF plots for the diff_CPI series

ac diff_cpi, title("diff_CPI Autocorrelation, ARMA(p,q), {it:{&rho}}=0.05, {it:{&alpha}}=0", size(medlarge)) lags(20) level(95) graphregion(color(white)) ytitle("Autocorrelations")
graph export "FIGURES/ac_arma11_acdiff.png", replace // save graph

pac diff_cpi, title("diff_CPI Partial Autocorrelation, ARMA(p,q), {it:{&rho}}=0.05, {it:{&alpha}}=0", size(medlarge)) lags(20) level(95) graphregion(color(white)) ytitle("Partial autocorrelations")
graph export "FIGURES/pac_arma11_pacdiff.png", replace // save graph


// What is the appropriate ARMA(p,q) for each series?   
// AC determines 'q' and PAC determines 'p'. Based on the ac results from first differences in CPI an ARMA(12,12) or ARMA (19,19)model is appropriate???????





//****************************************************************************************************

// f) What is the most parsimonious ARMA(p, q) model for CPI using AIC?

// Testing the first model
arima cpi, arima(1,1,1)
estat ic

// Testing the second model
arima cpi, arima(12,1,12)
estat ic

// t-test:
// f-test:

// Null Hypothesis:
// Alternative Hypothesis:
// Conclusion of the testing:

// Summarize output in a table:


//****************************************************************************************************

// g) Report the one-step ahead MSFE from the model as well as the monthly average no change forecast. Which forecast does better in terms of the MSFE?






//****************************************************************************************************

// h) 


// ***************************
// Close and save log file
log close
timer off 1
timer list 1
