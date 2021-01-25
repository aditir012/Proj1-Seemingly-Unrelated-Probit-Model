//FDIC Survey on unbanked and underbanked//
//Incorporating Weights//
clear all
use "/Users/aditirouth/Downloads/prepaidmultiyearcoded.dta"

use "/Users/aditirouth/Downloads/weights.dta"

*merge single year replicate weights for each year of data in multiyear file
use "/Users/aditirouth/Downloads/prepaidmultiyearcoded.dta"
merge 1:1 hryear4 qstnum  using weights

*Weighting the data
svyset [iweight= hsupwgtk], sdrweight(repwgt1- repwgt160) vce(sdr)

//prepaid use variable only 2013-2017
tab hryear4 //survey year 265,846  obs
drop if hryear4<2013 //(107,572 observations deleted)
tab hryear4 // 158,274 obs

gen y2013=0
gen y2015=0
gen y2017=0

replace y2013=1 if hryear4==2013
replace y2015=1 if hryear4==2015
replace y2017=1 if hryear4==2017

tab y2013
tab y2015
tab y2017

//region//
tab gereg
/*      gereg |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        831       13.45       13.45
          2 |      1,081       17.50       30.95
          3 |      2,897       46.89       77.84
          4 |      1,369       22.16      100.00
------------+-----------------------------------
      Total |      6,178      100.00


1	Northeast
2	Midwest 
3	South
4	West

*/
gen northeast=0
gen midwest=0
gen south=0
gen west=0

replace northeast=1 if gereg==1
replace midwest=1 if gereg==2
replace south=1 if gereg==3
replace west=1 if gereg==4

tab northeast
tab midwest 
tab south
tab west

/*hbankstatv3	Unbanked and underbanked
1	Unbanked
2	Banked: Underbanked
3	Banked: Fully banked
4	Banked: Underbanked status unknown

*/
tab hbankstatv3
keep if hbankstatv3==1 //(212,726 observations deleted)



*Dependent variable
tab hbnkfutrv2	
/*Likelihood of opening account in next 12 months
-1	NIU 
1	Very likely
2	Somewhat likely
3	Not very likely
4	Not at all likely


drop if hbnkfutrv2==-1

 hbnkfutrv2 |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        695       11.25       11.25
          2 |      1,168       18.91       30.16
          3 |      1,217       19.70       49.85
          4 |      3,098       50.15      100.00
------------+-----------------------------------
      Total |      6,178      100.00

*/*PROBIT BINARY DV

gen openacct=0
replace openacct=1 if hbnkfutrv2==1 | hbnkfutrv2==2
tab openacct

*0PROBIT ORDERED DV REVERSE CODED, HIGHER MEANS VERY LIKELY //APRIL 30, 2020
gen bankintent=5-hbnkfutrv2

/* 5 minus hbnkfutrv2 Likelihood of opening account in next 12 months
1	Very likely
2	Somewhat likely
3	Not very likely
4	Not at all likely

*/tab bankintent

/*
 bankintent |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      3,098       50.15       50.15 not at all likely
          2 |      1,217       19.70       69.84 not very likely
          3 |      1,168       18.91       88.75 somewhat likely
          4 |        695       11.25      100.00 very likely
------------+-----------------------------------
      Total |      6,178      100.00



*Measures from FDIC multiyear
/*husepp	Prepaid card use 2013 only
huse12pp	Used prepaid card in past 12 months //2013-2017//
1	Yes
2	No
99	Unknown

   huse12pp |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      1,763       28.54       28.54
          2 |      4,415       71.46      100.00
------------+-----------------------------------
      Total |      6,178      100.00


*/
drop if huse12pp==99

tab huse12pp

gen prepaid=0
replace prepaid=1 if huse12pp==1
tab prepaid

/*

      prepaid |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      4,415       71.46       71.46
          1 |      1,763       28.54      100.00
------------+-----------------------------------
      Total |      6,178      100.00


Prior banking experience

hbnkprevv2	Previously banked	Excludes households with missing information on previous banking status.
hbnkprevv2	Previously banked	Unbanked households
hbnkprevlyv2	Previously banked (within last year)	Excludes households with missing information on previous banking status.
hbnkprevlyv2	Previously banked (within last year)	Unbanked households

-1	NIU
1	Had bank account within last year
2	Had bank account more than 1 year ago
3	Never had bank account

*/

tab hbnkprevv2
drop if hbnkprevv2==-1

gen prevbankyr=0
replace prevbankyr=1 if hbnkprevv2==1

gen prevbankyrs=0
replace prevbankyrs=1 if hbnkprevv2==2

tab prevbankyr
tab prevbankyrs
*************************************************************
///attitudes about banking and other financial services

/*Main reason unbanked 2015 and 2017
-1	NIU
1	Inconvenient hours
2	Inconvenient locations
3	Account fees too high
4	Account fees unpredictable
5	Banks do not offer needed products or services
6	Do not trust banks
7	Do not have enough money to keep in account
8	Avoiding bank gives more privacy
9	ID, credit, or former bank account problems
10	Other reason
99	Unknown 

hunbnkrmv3	Freq.	Percent	Cum.
			
1	158		3.95	3.95
2	93		2.33	6.28
3	365		9.13	15.40
4	71		1.77	17.18
5	65		1.63	18.80
6	464		11.60	30.40
7	1,548	38.70	69.10
8	134		3.35	72.45
9	210		5.25	77.70
10	496		12.40	90.10
99	396		9.90	100.00
			
Total		4,000	100.00
*/
gen notrust=0 if hryear4!=2013
replace notrust=1 if hunbnkrmv3==6
tab notrust

gen lomoney=0 if hryear4!=2013
replace lomoney=1 if hunbnkrmv3==7
tab lomoney 

//huse12afsnbr	Number of AFS used
//Number of AFS used is based on the following AFS: check cashing, money order, remittance, payday loan, 
//pawn shop loan, rent-to-own service, refund anticipation loan, and auto title loan.
tab huse12afsnbr
gen AFSuse=huse12afsnbr
tab AFSuse
replace AFSuse=0 if huse12afsnbr==99
tab AFSuse

/*AFS for selection variable
huse12AFST	Used AFS transaction in past 12 months
AFS transaction use is based on the following AFS: check cashing, money order, and remittance.
1	Yes
2	No
99	Unknown
*/
tab huse12afst
gen AFStransact=0
replace AFStransact=1 if huse12afst==1
tab AFStransact
/*
huse12afstype	Type of AFS used in past 12 months	1	Used only transaction AFS
huse12afstype	Type of AFS used in past 12 months	2	Used transaction and credit AFS
huse12afstype	Type of AFS used in past 12 months	3	Used only credit AFS 
huse12afstype	Type of AFS used in past 12 months	4	Did not use any AFS in past 12 months
huse12afstype	Type of AFS used in past 12 months	98	AFS used, type unknown
huse12afstype	Type of AFS used in past 12 months	99	Use unknown

huse12afsty |
         pe |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      2,748       44.48       44.48
          2 |        873       14.13       58.61
          3 |        232        3.76       62.37
          4 |      2,270       36.74       99.11
         98 |         21        0.34       99.45
         99 |         34        0.55      100.00
------------+-----------------------------------
      Total |      6,178      100.00

*/
tab huse12afstype
gen transAFS=0
replace transAFS=1 if huse12afstype==1

gen bothAFS=0
replace bothAFS=1 if huse12afstype==2 

gen creditAFS=0
replace creditAFS=1 if huse12afstype==3

gen noAFS=0
replace noAFS=1 if  huse12afstype==4

summarize transAFS creditAFS noAFS bothAFS

*impute missing
replace noAFS=1 if huse12afstype==98 | huse12afstype==99

gen allAFS = creditAFS+bothAFS
summarize transAFS allAFS noAFS
tab allAFS


//Controls
/*source of prepaid card...only 2013 2015
hppwhere1	Prepaid card, where from: Bank location or bank website 2%
hppwhere2	Prepaid card, where from: Store or website that is not a bank 13%
hppwhere3	Prepaid card, where from: Government agency 8%
hppwhere4	Prepaid card, where from: Employer payroll card 4%
hppwhere5	Prepaid card, where from: Family or friends 1%
hppwhere6	Prepaid card, where from: Other 1%
hppwhere99	Prepaid card, where from: Unknown 0.14%

tab hppwhere1
tab hppwhere2
tab hppwhere3
tab hppwhere4
tab hppwhere5
tab hppwhere6
tab hppwhere99
*/
drop ppstoreweb ppgovt ppbankother

gen ppstoreweb=0 if hryear4!=2017 //store or non-bank website//
replace ppstoreweb=1 if hppwhere2==1
tab ppstoreweb

gen ppgovt=0 if hryear4!=2017
replace ppgovt=1 if hppwhere3==1
tab ppgovt

gen ppbankother=0 if hryear4!=2017 //bank other=job family other unknown//
replace ppbankother=1 if hppwhere1==1 | hppwhere4==1 | hppwhere5==1 | hppwhere6==1 | hppwhere99==1
tab ppbankother

/*hrloadpp	Prepaid card, reloaded in past 12 months	1	Card was reloaded
hrloadpp	Prepaid card, reloaded in past 12 months	2	Card was not reloaded
hrloadpp	Prepaid card, reloaded in past 12 months	-1	NIU
hrloadpp	Prepaid card, reloaded in past 12 months	99	Unknown
*/
tab hrloadpp hryear4
gen ppreload=0 if hryear4==2013
replace ppreload=1 if hrloadpp==1
tab ppreload

//typical income payment
tab htypincchkmo hryear4  //paper check money order
tab htypincddbnk //direct deposit or etf into bank
tab htypincddpp hryear4 //direct deposit to prepaid card
tab htypinccash hryear4 //in cash
tab htypincoth //other method
tab htypinccc  //non-bank check casher
tab htypincnone //none selected
tab htypincbnka //any bank method
tab htypincbnko //only bank methods

/*htypincddpp |      Freq.     Percent        Cum.
------------+-----------------------------------
         -1 |        117        3.14        3.14r
          1 |        363        9.74       12.88
          2 |      2,732       73.28       86.16
         98 |        516       13.84      100.00
------------+-----------------------------------
      Total |      3,728      100.00

. tab htypinccash

htypinccash |      Freq.     Percent        Cum.
------------+-----------------------------------
         -1 |        132        3.54        3.54
          1 |        705       18.91       22.45
          2 |      2,891       77.55      100.00
------------+-----------------------------------
      Total |      3,728      100.00
	  
*/
gen incprepaid=0 if hryear4!=2013
replace incprepaid=1 if htypincddpp==1
tab incprepaid

gen inccash=0 if hryear4!=2013
replace inccash=1 if htypinccash==1
tab inccash

gen checkmopay=0 if hryear4!=2013
replace checkmopay=1 if htypincchkmo==1
tab checkmopay

/*typical bill pyament//
htyppaym	1	Cash
htyppaym	2	Personal check
htyppaym	3	Debit card
htyppaym	4	Credit card
htyppaym	5	Prepaid card
htyppaym	6	Electronic payment from bank account
htyppaym	7	Nonbank money order
htyppaym	8	Bank money order or cashiers check
htyppaym	9	Other
htyppaym	99	Unknown
htyppaym	-1	NIU
*/

gen cashbill=0 if hryear4==2015
replace cashbill=1 if htyppaym==1
tab cashbill

gen ppbill=0 if hryear4==2015
replace ppbill=1 if htyppaym==5
tab ppbill

gen nbmobill=0 if hryear4==2015
replace nbmobill=1 if htyppaym==7
tab nbmobill



///LIFESTYLE AND CULTURE VARIABLES//
//have mobile phone
tab hmphone
/*
1 Yes 
2 No
99 Unknown

 hmphone |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      4,698       76.04       76.04
          2 |      1,480       23.96      100.00
------------+-----------------------------------
      Total |      6,178      100.00

*/

drop if hmphone==99
/*

hfinedu	Attended financial education classes or counseling sessions in past 12 months	1	Yes
hfinedu	Attended financial education classes or counseling sessions in past 12 months	2	No
hfinedu	Attended financial education classes or counseling sessions in past 12 months	99	Unknown
  hfinedu |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |         27        1.37        1.37
          2 |      1,938       98.43       99.80
         99 |          4        0.20      100.00
------------+-----------------------------------
      Total |      1,969      100.00

. tab hfinedu hryear4

           |  hryear4
   hfinedu |      2015 |     Total
-----------+-----------+----------
         1 |        27 |        27 
         2 |     1,938 |     1,938 
        99 |         4 |         4 
-----------+-----------+----------
     Total |     1,969 |     1,969 

	  
	  */
gen mobile=0
replace mobile=1 if hmphone==1
tab mobile

/*smartphone
  hsmphone |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      2,725       44.11       44.11
          2 |      1,943       31.45       75.56
          3 |      1,480       23.96       99.51
         99 |         30        0.49      100.00
------------+-----------------------------------
      Total |      6,178      100.00
	  
hsmphone	Smartphone		1	Smartphone
hsmphone	Smartphone		2	Non-smartphone
hsmphone	Smartphone		3	No mobile phone
hsmphone	Smartphone		99	Unknown


*/
gen smtphone=0
replace smtphone=1 if hsmphone==1
	  
gen ftmphone=0
replace ftmphone=1 if hsmphone==2

gen nomphone=0
replace nomphone=1 if hsmphone==3 | hsmphone==99

summarize smtphone ftmphone nomphone

//homeowner
tab hhtenure

gen homeowner=0
replace homeowner=1 if hhtenure==1
tab homeowner

//DEMOGRAPHICS
tab pagegrp 
/*age
1	15 to 24 years
2	25 to 34 years
3	35 to 44 years
4	45 to 54 years
5	55 to 64 years
6	65 years or more
*/
gen pagegrp2=(pagegrp)*(pagegrp)
tab pagegrp2

gen age15=0
replace age15=1 if pagegrp==1
gen age25=0
replace age25=1 if pagegrp==2
gen age35=0
replace age35=1 if pagegrp==3
gen age45=0
replace age45=1 if pagegrp==4
gen age55=0
replace age55=1 if pagegrp==5
gen age65=0
replace age65=1 if pagegrp==6

tab age15
tab age25
tab age35
tab age45
tab age55
tab age65


///household type//
tab hhtype
/*
1	Married couple
2	Unmarried female-headed family
3	Unmarried male-headed family
4	Female individual
5	Male individual
6	Other

  hhtype |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      1,260       20.28       20.28
          2 |      1,812       29.17       49.45
          3 |        488        7.86       57.31
          4 |      1,184       19.06       76.37
          5 |      1,434       23.08       99.45
          6 |         34        0.55      100.00
------------+-----------------------------------
      Total |      6,212      100.00

*/
gen married=0
replace married=1 if hhtype==1

gen singlemother=0
replace singlemother=1 if hhtype==2

gen singlefather=0
replace singlefather=1 if hhtype==3

gen singlewm=0
replace singlewm=1 if hhtype==4

gen singlem=0
replace singlem=1 if hhtype==5

gen hhother=0
replace hhother=1 if hhtype==6

drop if hhother==1 //only keep specific hhtypes//
/*drop hhother*/

tab married
tab singlemother
tab singlefather
tab singlewm
tab singlem
tab hhother

gen fatherother=0
replace fatherother=1 if singlefather==1 | hhother==1
tab fatherother

tab peducgrp
/*
1	No high school diploma
2	High school diploma
3	Some college
4	College degree
*/
gen nohighsch=0
replace nohighsch=1 if peducgrp==1

gen highsch=0
replace highsch=1 if peducgrp==2

gen somecoll=0
replace somecoll=1 if peducgrp==3

gen colldeg=0
replace colldeg=1 if peducgrp==4

tab nohighsch
tab highsch
tab somecoll
tab colldeg

///income///
tab hhincome
/*1	Less than $15,000
2	$15,000 to $30,000
3	$30,000 to $50,000
4	$50,000 to $75,000
5	At least $75,000
*/
gen inc1=0
gen inc2=0
gen inc3=0
gen inc4=0
gen inc5=0

replace inc1=1 if hhincome==1
replace inc2=1 if hhincome==2
replace inc3=1 if hhincome==3
replace inc4=1 if hhincome==4
replace inc5=1 if hhincome==5

summarize inc*

/*pempstat	Employment status
1	Employed
2	Unemployed
3	Not in labor force
*/
tab pempstat
gen employed=0
replace employed=1 if pempstat==1
gen unemplyd=0
replace unemplyd=1 if pempstat==2
gen notlabor=0
replace notlabor=1 if pempstat==3

tab employed
tab unemplyd
tab notlabor


/*praceeth2	Race/Ethnicity
1	Black
2	Hispanic
3	Asian
4	White
5	Other

*/

tab praceeth2
gen black=0
replace black=1 if praceeth2==1
gen hispanic=0
replace hispanic=1 if praceeth2==2
gen asian=0
replace asian=1 if praceeth2==3
gen white=0
replace white=1 if praceeth2==4
gen other=0
replace other=1 if praceeth2==5

tab black
tab hispanic
tab asian
tab white
tab other

gen asianother=0
replace asianother=1 if asian==1 | other==1
tab asianother

/*Immigrant status
   pnativ2 |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      4,939       79.94       79.94
          2 |      1,239       20.06      100.00
------------+-----------------------------------
      Total |      6,178      100.00

1	Native (born in U.S., in U.S. territory, or abroad of U.S. parent)
2	Foreign-born citizen or non-citizen

*/
gen native=0
replace native=1 if pnativ2==1
tab native

tab pnum //number of persons in household

tab gtmetsta5yr13
/*
1	Metropolitan area
2	Not in metropolitan area
3	Not identified

gtmetsta5yr |
         13 |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      4,751       76.90       76.90
          2 |      1,354       21.92       98.82
          3 |         73        1.18      100.00
------------+-----------------------------------
      Total |      6,178      100.00

*/
gen metro=0
replace metro=1 if gtmetsta5yr13==1
tab metro

/*label variable hhsupwgt "Household supplement weight"
label variable hryear4 "Survey year"
label variable hsupwgtk "Household-level weight (1000s)"*/


sum openacct prepaid prevbankyrs transAFS creditAFS allAFS noAFS  ///
homeowner mobile smtphone ftmphone nomphone y2013 y2015 y2017 native age* married ///
singlemother singlefather singlewm singlem pnum white black ///
hispanic asianother nohighsch highsch somecoll colldeg inc* employed ///
notlabor unemplyd metro northeast midwest south west [iweight= hsupwgtk]

bysort openacct: summarize openacct prepaid prevbankyrs transAFS creditAFS allAFS noAFS  ///
homeowner mobile smtphone ftmphone nomphone y2013 y2015 y2017 native ///
age* married singlemother singlefather singlewm singlem pnum ///
white black hispanic asianother  nohighsch highsch ///
somecoll colldeg inc* employed notlabor unemplyd ///
metro northeast midwest south west [iweight= hsupwgtk]

summarize openacct prepaid prevbankyrs notrust lomoney transAFS creditAFS allAFS noAFS  ///
homeowner mobile smtphone ftmphone nomphone y2013 y2015 y2017 native ///
age* married singlemother singlefather singlewm singlem pnum ///
white black hispanic asianother  nohighsch highsch ///
somecoll colldeg inc* employed notlabor unemplyd ///
metro northeast midwest south west [iweight= hsupwgtk] if y2015==1 | y2017==1

bysort openacct: summarize openacct prepaid prevbankyrs notrust lomoney transAFS creditAFS allAFS noAFS  ///
homeowner mobile smtphone ftmphone nomphone y2013 y2015 y2017 native ///
age* married singlemother singlefather singlewm singlem pnum ///
white black hispanic asianother  nohighsch highsch ///
somecoll colldeg inc* employed notlabor unemplyd ///
metro northeast midwest south west [iweight= hsupwgtk] if y2015==1 | y2017==1




//comparison chisq2 & ttests//
/*ttest openacct, by(prepaid)
ttest prevbankyrs, by(prepaid)
ttest transAFS, by(prepaid)
ttest allAFS, by(prepaid)
ttest noAFS, by(prepaid)
ttest AFStransact, by(prepaid)
ttest notrust , by(prepaid)
ttest lomoney, by(prepaid)
tab homeowner prepaid, column chi2 nofreq
tab mobile prepaid, column chi2 nofreq
tab smtphone prepaid, column chi2 nofreq
tab nomphone prepaid, column chi2 nofreq
tab hryear4 prepaid, column chi2 nofreq
tab pagegrp prepaid, column chi2 nofreq
tab hhtype prepaid, column chi2 nofreq
tab singlemother prepaid, column chi2 nofreq 
tab singlefather  prepaid, column chi2 nofreq 
tab singlewm prepaid, column chi2 nofreq 
tab singlem  prepaid, column chi2 nofreq 
tab fatherother  prepaid, column chi2 nofreq 
tab white prepaid, column chi2 nofreq
tab black prepaid, column chi2 nofreq
tab hispanic prepaid, column chi2 nofreq
tab asianother prepaid, column chi2 nofreq
tab nohighsch prepaid, column chi2 nofreq
tab highsch prepaid, column chi2 nofreq
tab somecoll prepaid, column chi2 nofreq
tab colldeg prepaid, column chi2 nofreq
tab inc1 prepaid, column chi2 nofreq
tab inc2 prepaid, column chi2 nofreq
tab inc3 prepaid, column chi2 nofreq
tab inc4 prepaid, column chi2 nofreq
tab inc5 prepaid, column chi2 nofreq
tab employed prepaid, column chi2 nofreq
tab notlabor prepaid, column chi2 nofreq
tab unemplyd prepaid, column chi2 nofreq
ttest pnum, by(prepaid)
tab metro prepaid, column chi2 nofreq
tab northeast prepaid, column chi2 nofreq
tab midwest prepaid, column chi2 nofreq
tab south prepaid, column chi2 nofreq
tab west prepaid, column chi2 nofreq
*/
//comparison chisq2 & ttests...6178//
tab prepaid openacct, column chi2 nofreq
tab prevbankyrs openacct, column chi2 nofreq
ttest transAFS, by(openacct)
ttest creditAFS, by(openacct)
ttest allAFS, by(openacct)
ttest noAFS, by(openacct)
ttest notrust , by(openacct)
ttest lomoney, by(openacct)
tab homeowner openacct, column chi2 nofreq
tab mobile openacct, column chi2 nofreq
tab smtphone openacct, column chi2 nofreq
tab ftmphone openacct, column chi2 nofreq
tab nomphone openacct, column chi2 nofreq
tab married openacct, column chi2 nofreq 
tab singlemother openacct, column chi2 nofreq 
tab singlefather  openacct, column chi2 nofreq 
tab singlewm openacct, column chi2 nofreq 
tab singlem  openacct, column chi2 nofreq 
tab fatherother openacct, column chi2 nofreq 
tab white openacct, column chi2 nofreq
tab black openacct, column chi2 nofreq
tab hispanic openacct, column chi2 nofreq
tab asianother openacct, column chi2 nofreq
tab nohighsch openacct, column chi2 nofreq
tab highsch openacct, column chi2 nofreq
tab somecoll openacct, column chi2 nofreq
tab colldeg openacct, column chi2 nofreq
tab inc1 openacct, column chi2 nofreq
tab inc2 openacct, column chi2 nofreq
tab inc3 openacct, column chi2 nofreq
tab inc4 openacct, column chi2 nofreq
tab inc5 openacct, column chi2 nofreq
tab employed openacct, column chi2 nofreq
tab notlabor openacct, column chi2 nofreq
tab unemplyd openacct, column chi2 nofreq
ttest pnum, by(openacct)
tab metro openacct, column chi2 nofreq
tab northeast openacct, column chi2 nofreq
tab midwest openacct, column chi2 nofreq
tab south openacct, column chi2 nofreq
tab west openacct, column chi2 nofreq
tab y2013 openacct, column chi2 nofreq
tab y2015 openacct, column chi2 nofreq
tab y2017 openacct, column chi2 nofreq
tab native openacct, column chi2 nofreq
tab age15 openacct, column chi2 nofreq
tab age25 openacct, column chi2 nofreq
tab age35 openacct, column chi2 nofreq
tab age45 openacct, column chi2 nofreq
tab age55 openacct, column chi2 nofreq
tab age65 openacct, column chi2 nofreq


//comparison chisq2 & ttests...3728//
*drop if y2013==1
tab prepaid openacct, column chi2 nofreq
tab prevbankyrs openacct, column chi2 nofreq
ttest transAFS, by(openacct)
ttest creditAFS, by(openacct)
ttest allAFS, by(openacct)
ttest noAFS, by(openacct)
ttest notrust , by(openacct)
ttest lomoney, by(openacct)
tab homeowner openacct, column chi2 nofreq
tab mobile openacct, column chi2 nofreq
tab smtphone openacct, column chi2 nofreq
tab ftmphone openacct, column chi2 nofreq
tab nomphone openacct, column chi2 nofreq
tab married openacct, column chi2 nofreq 
tab singlemother openacct, column chi2 nofreq 
tab singlefather  openacct, column chi2 nofreq 
tab singlewm openacct, column chi2 nofreq 
tab singlem  openacct, column chi2 nofreq 
tab fatherother openacct, column chi2 nofreq 
tab white openacct, column chi2 nofreq
tab black openacct, column chi2 nofreq
tab hispanic openacct, column chi2 nofreq
tab asianother openacct, column chi2 nofreq
tab nohighsch openacct, column chi2 nofreq
tab highsch openacct, column chi2 nofreq
tab somecoll openacct, column chi2 nofreq
tab colldeg openacct, column chi2 nofreq
tab inc1 openacct, column chi2 nofreq
tab inc2 openacct, column chi2 nofreq
tab inc3 openacct, column chi2 nofreq
tab inc4 openacct, column chi2 nofreq
tab inc5 openacct, column chi2 nofreq
tab employed openacct, column chi2 nofreq
tab notlabor openacct, column chi2 nofreq
tab unemplyd openacct, column chi2 nofreq
ttest pnum, by(openacct)
tab metro openacct, column chi2 nofreq
tab northeast openacct, column chi2 nofreq
tab midwest openacct, column chi2 nofreq
tab south openacct, column chi2 nofreq
tab west openacct, column chi2 nofreq
tab y2013 openacct, column chi2 nofreq
tab y2015 openacct, column chi2 nofreq
tab y2017 openacct, column chi2 nofreq
tab native openacct, column chi2 nofreq
tab age15 openacct, column chi2 nofreq
tab age25 openacct, column chi2 nofreq
tab age35 openacct, column chi2 nofreq
tab age45 openacct, column chi2 nofreq
tab age55 openacct, column chi2 nofreq
tab age65 openacct, column chi2 nofreq


/*/initial probits_Oct 2018 will use margins command in final//
dprobit openacct prepaid AFStransact y2013 y2015 y2017 pagegrp black hispanic asianother nohighsch highsch somecoll colldeg employed notlabor pnum metro, robust
outreg2 openacct prepaid prevbankyrs AFStransact notrust y2013 y2015 y2017 pagegrp black hispanic asianother nohighsch highsch somecoll colldeg employed notlabor pnum metro using prevprobits.txt, excel label(insert) dec(3)

//initial probits_Oct 2018 will use margins command in final//
dprobit openacct prepaid notrust AFStransact y2013 y2015 y2017 pagegrp black hispanic asianother nohighsch highsch somecoll colldeg employed notlabor pnum metro, robust
outreg2 openacct prepaid notrust AFStransact y2013 y2015 y2017 pagegrp black hispanic asianother nohighsch highsch somecoll colldeg employed notlabor pnum metro using prevprobits.txt, excel label(insert) dec(3)

dprobit openacct prepaid prevbankyrs notrust AFStransact y2013 y2015 y2017 pagegrp black hispanic asianother nohighsch highsch somecoll colldeg employed notlabor pnum metro, robust
outreg2 openacct prepaid prevbankyrs notrust AFStransact y2013 y2015 y2017 pagegrp black hispanic asianother nohighsch highsch somecoll colldeg employed notlabor pnum metro using prevprobits.txt, excel label(insert) dec(3)

dprobit openacct prepaid prevbankyrs prepaid#prevbankyrs notrust AFStransact y2013 y2015 y2017 pagegrp black hispanic asianother nohighsch highsch somecoll colldeg employed notlabor pnum metro, robust
outreg2 openacct prepaid prevbankyrs prepaid#prevbankyrs notrust AFStransact y2013 y2015 y2017 pagegrp black hispanic asianother nohighsch highsch somecoll colldeg employed notlabor pnum metro using prevprobits.txt, excel label(insert) dec(3)


//initial probits_Oct 2018//
dprobit openacct prevbankyrs AFStransact notrust y2013 y2015 y2017 pagegrp black hispanic asianother nohighsch highsch somecoll colldeg employed notlabor pnum metro if prepaid==0, robust
outreg2 openacct prevbankyrs AFStransact y2013 y2015 y2017 pagegrp black hispanic asianother nohighsch highsch somecoll colldeg employed notlabor pnum metro using prevprobits.txt, excel label(insert) dec(3)

//initial probits_Oct 2018//
dprobit openacct prevbankyrs AFStransact notrust y2013 y2015 y2017 pagegrp black hispanic asianother nohighsch highsch somecoll colldeg employed notlabor pnum metro if prepaid==1, robust
outreg2 openacct prevbankyrs AFStransact y2013 y2015 y2017 pagegrp black hispanic asianother nohighsch highsch somecoll colldeg employed notlabor pnum metro using prevprobits.txt, excel label(insert) dec(3)

//selection bias//
heckoprobit openacct prepaid AFStransact y2013 y2015 y2017 pagegrp black hispanic asianother nohighsch highsch somecoll colldeg employed notlabor pnum metro ,///
select(prevbankyrs = AFStransact notrust lomoney ///
pagegrp black hispanic asianother nohighsch highsch somecoll colldeg employed notlabor metro)



/*robustness checks
incprepaid
inccash
checkmopay
cashbill
ppbill prepaid card bill payment
nbmobil //nonbank money order
ppreload
banking attitudes
*/
///typical income payout reasons..2017 2015///
biprobit (openacct = prepaid incprepaid prevbankyrs AFStransact mobile homeowner y2013 y2015 y2017 pagegrp married black hispanic asianother white nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south) ///
(prepaid =  AFStransact mobile y2013 y2015 y2017 pagegrp married black hispanic asianother white nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south), vce(robust)
outreg2 using prepaidoutput.txt, excel label (insert) dec(3)
margins, dydx(*) post
outreg2 using prepaidoutput.txt, excel cti(dydx) dec(3)

biprobit (openacct = prepaid incprepaid prevbankyrs AFStransact mobile homeowner y2013 y2015 y2017 pagegrp married black hispanic asianother white nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south) ///
(prepaid =  nbmobill AFStransact mobile y2013 y2015 y2017 pagegrp married black hispanic asianother white nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south), vce(robust)
margins, dydx(*)
outreg2 using prepaidoutput.txt, excel label (insert) dec(3)


//typical bill payment & reload//
biprobit (openacct = prepaid ppbill prevbankyrs AFStransact mobile homeowner y2013 y2015 y2017 pagegrp married black hispanic asianother white nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south) ///
(prepaid =  nbmobill AFStransact mobile y2013 y2015 y2017 pagegrp married black hispanic asianother white nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south), vce(robust)
margins, dydx(*)
outreg2 using prepaidoutput.txt, excel label (insert) dec(3)

///attitudes..2015..17///
biprobit (openacct = prepaid incprepaid prevbankyrs notrust lomoney AFStransact mobile homeowner y2015 y2017 pagegrp married black hispanic asianother white nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south) ///
(prepaid = nbmobill AFStransact mobile y2015 y2017 pagegrp black hispanic asianother white nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south), vce(robust)
margins, dydx(*)
outreg2 using prepaidoutput.txt, excel label (insert) dec(3)


///for paper check: on issue of selection and endogeneity///https://www.statalist.org/forums/forum/general-stata-discussion/general/1402338-2sls-with-sample-selection 

///march 2020
////eemingly unrelated no bootstrap//
/*

biprobit (openacct = prepaid AFStransact prevbankyrs mobile y2013 y2015 y2017 age15 age25 age35 age45 age55 singlemother singlefather singlewm singlem pnum black hispanic asianother white nohighsch highsch somecoll colldeg employed notlabor unemplyd metro northeast midwest west south) ///
(prepaid =  openacct prevbankyrs y2013 y2015 y2017 age15 age25 age35 age45 age55 singlemother singlefather singlewm singlem black hispanic asianother white nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south), vce(robust)
outreg2 using biprobit_prepaid.txt, excel label (insert) dec(3)
margins, dydx(*) atmeans
outreg2 using biprobit_prepaid.txt, excel cti(dydx) dec(3)

biprobit (openacct = prepaid mobile prevbankyrs y2013 y2015 y2017 pagegrp singlemother singlefather singlewm singlem black hispanic asianother white nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south) ///
(prepaid = openacct AFStransact y2013 y2015 y2017 pagegrp singlemother singlefather singlewm singlem black hispanic asianother white nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south), vce(robust)
margins, dydx(*)
outreg2 using biprobit_prepaid.txt, excel label (insert) dec(3)

///robustness checks...prepaid correlates ///
biprobit (openacct = prepaid lomoney mobile prevbankyrs y2013 y2015 y2017 pagegrp singlemother singlefather singlewm singlem black hispanic asianother white nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south) ///
(prepaid = openacct AFStransact y2013 y2015 y2017 pagegrp singlemother singlefather singlewm singlem black hispanic asianother white nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south), vce(robust)
margins, dydx(*)
outreg2 using biprobit_prepaid.txt, excel label (insert) dec(3)


*/ERM //more robust but covariates all endogenous, find good instruments for each.
/*model///
eprobit y w1 w2 w3 x1 x2 x5, ///
endogenous(w1 = w2 z1 z2 x1 x2 x5, nomain) ///
endogenous(w2 = w1 z1 z3 x1 x2 x5, nomain) ///
endogenous(w3 = w1 z4 z5 x1 x2 x5, nomain probit) ///
endogenous(z1 = z5 x1 x2 x4, nomain probit)

y=BI
w1=pp
w2=prevbankyrs //previous banking history//
w3=AFSuse //number of different products used
x= //demographics  ge15 age25 age35 age45 age55 singlemother singlefather singlewm singlem pnum black hispanic asianother white nohighsch highsch somecoll colldeg employed notlabor unemplyd metro northeast midwest west south y2013 y2015 y2017 

endogenous(w1 = w2 z1 z2 x1 x2 x5, nomain) ///
endogenous(w2 = w1 z1 z3 x1 x2 x5, nomain) ///
endogenous(w3 = w1 z4 z5 x1 x2 x5, nomain probit) ///
endogenous(z1 = z5 x1 x2 x4, nomain probit)
*/

selvar=prepaid //sample selection variable, those using AFS for banklike functions will self-select//
z=notrust? //find variable correlated with AFStransact but not with y except thru AFStransact
y2= //unbanked length will be endogenous with pp because pp may be substituting bank-like functions, also with attitudes//
z2=lomoney? //bank attitudes 2015 17, covariate but also endogenous with pp//

*/

*///seemingly unrelated no bootstrap JULY 2020///
//no attitudes all years//
biprobit (openacct = prepaid prevbankyrs transAFS allAFS noAFS smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg hhincome employed notlabor unemplyd pnum metro northeast midwest west south) ///
(prepaid = prevbankyrs homeowner smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg hhincome employed notlabor unemplyd pnum metro northeast midwest west south), vce(robust)
outreg2 using prepaidoutputJEPFINAL.txt, excel label (insert) dec(3)
margins, dydx(*) post
outreg2 using prepaidoutputJEPFINAL.txt, excel cti(dydx) dec(3)

probit openacct prevbankyrs transAFS  allAFS noAFS smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg hhincome employed notlabor unemplyd pnum metro northeast midwest west south, vce(robust)
outreg2 using prepaidoutputJEPFINAL.txt, excel label (insert) dec(3)
margins, dydx(*) post
outreg2 using prepaidoutputJEPFINAL.txt, excel cti(dydx) dec(3)
probit prepaid prevbankyrs homeowner smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg hhincome employed notlabor unemplyd pnum metro northeast midwest west south, vce(robust)
outreg2 using prepaidoutputJEPFINAL.txt, excel label (insert) dec(3)
margins, dydx(*) post
outreg2 using prepaidoutputJEPFINAL.txt, excel cti(dydx) dec(3)
//with attitudes 2 years//
biprobit (openacct = prepaid prevbankyrs notrust lomoney  transAFS  allAFS noAFS smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg hhincome employed notlabor unemplyd pnum metro northeast midwest west south) ///
(prepaid = prevbankyrs homeowner smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg hhincome employed notlabor unemplyd pnum metro northeast midwest west south), vce(robust)
outreg2 using prepaidoutputJEPFINAL.txt, excel label (insert) dec(3)
margins, dydx(*) post
outreg2 using prepaidoutputJEPFINAL.txt, excel cti(dydx) dec(3)

probit openacct prepaid prevbankyrs notrust lomoney transAFS  allAFS noAFS smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg hhincome employed notlabor unemplyd pnum metro northeast midwest west south, vce(robust)
outreg2 using prepaidoutputJEPFINAL.txt, excel label (insert) dec(3)
margins, dydx(*) post
outreg2 using prepaidoutputJEPFINAL.txt, excel cti(dydx) dec(3)
probit prepaid prevbankyrs notrust lomoney transAFS  allAFS noAFS homeowner smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg hhincome employed notlabor unemplyd pnum metro northeast midwest west south, vce(robust)
outreg2 using prepaidoutputJEPFINAL.txt, excel label (insert) dec(3)
margins, dydx(*) post
outreg2 using prepaidoutputJEPFINAL.txt, excel cti(dydx) dec(3)

*robust with scaled intent variable*
/*
 bankintent |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      3,098       50.15       50.15 not at all likely
          2 |      1,217       19.70       69.84 not very likely
          3 |      1,168       18.91       88.75 somewhat likely
          4 |        695       11.25      100.00 very likely
------------+-----------------------------------
      Total |      6,178      100.00
	  
*/
oprobit bankintent prepaid prevbankyrs transAFS  allAFS noAFS smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg hhincome employed notlabor unemplyd pnum metro northeast midwest west south, vce(robust)
outreg2 using bankintentoprobit.txt, excel label (insert) dec(3)
margins, dydx(*) post
outreg2 using bankintentoprobit.txt, excel cti(dydx) dec(3)

probit prepaid i.bankintent prevbkyrs homeowner smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg hhincome employed notlabor unemplyd pnum metro northeast midwest west south, vce(robust)
outreg2 using prepaidbankintentJEP.txt, excel label (insert) dec(3)
margins, dydx(*) post
outreg2 using prepaidbankintentJEP.txt, excel cti(dydx) dec(3)

*robust scaled intent and attitudes*
oprobit bankintent prepaid prevbankyrs notrust lomoney transAFS  allAFS noAFS smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg hhincome employed notlabor unemplyd pnum metro northeast midwest west south, vce(robust)
*outreg2 using bankintentoprobit.txt, excel label (insert) dec(3)
margins, dydx(*) post
*outreg2 using bankintentoprobit.txt, excel cti(dydx) dec(3)

probit prepaid i.bankintent prevbankyrs notrust lomoney homeowner smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg hhincome employed notlabor unemplyd pnum metro northeast midwest west south, vce(robust)
outreg2 using prepaidbankintentJEP.txt, excel label (insert) dec(3)
margins, dydx(*) post
outreg2 using prepaidbankintentJEP.txt, excel cti(dydx) dec(3)



/*payment methods
biprobit (openacct = prepaid prevbankyrs notrust lomoney  transAFS creditAFS bothAFS smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south) ///
(prepaid = homeowner smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south), vce(robust)
outreg2 using prepaidoutputFINAL.txt, excel label (insert) dec(3)
margins, dydx(*) post
outreg2 using prepaidoutputFINAL.txt, excel cti(dydx) dec(3)

biprobit (openacct = prepaid prevbankyrs checkmopay notrust lomoney  transAFS creditAFS bothAFS smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south) ///
(prepaid = homeowner inccash smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south), vce(robust)
outreg2 using prepaidoutputFINAL.txt, excel label (insert) dec(3)
margins, dydx(*) post
outreg2 using prepaidoutputFINAL.txt, excel cti(dydx) dec(3)
///STOP FOR JEP_July 2020!!!




///erm test..1 endogenous prepaid///
/*eprobit y w1 w2 w3 x1 x2 x5, 
*endogenous(w1 = w2 z1 z2 x1 x2 x5, nomain) ///
eprobit openacct prepaid prevbankyrs transAFS allAFS smtphone ftmphone nomphone y2013 y2015 y2017  age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south, ///
endogenous (prepaid = prevbankyrs homeowner transAFS allAFS smtphone ftmphone nomphone y2013 y2015 y2017  age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south, nomain probit) vce(robust)


/*erm test..2 endogenous prepaid prevbankyrs
eprobit y w1 w2 w3 x1 x2 x5, ///
endogenous(w1 = w2 z1 z2 x1 x2 x5, nomain) ///
endogenous(w2 = w1 z1 z3 x1 x2 x5, nomain) ///
endogenous(w3 = w1 z4 z5 x1 x2 x5, nomain probit) ///

*/
eprobit openacct prepaid prevbankyrs notrust lomoney y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south, ///
endogenous (prepaid = prevbankyrs homeowner  transAFS allAFS noAFS smtphone ftmphone nomphone notrust lomoney y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south, nomain probit) ///
endogenous (prevbankyrs = inccash checkmopay notrust lomoney transAFS allAFS noAFS smtphone ftmphone nomphone y2013 y2015 y2017 age* married singlemother singlefather singlewm singlem black hispanic asianother white native nohighsch highsch somecoll colldeg employed notlabor unemplyd pnum metro northeast midwest west south, nomain probit)


//robustness variables..GET FULL SAMPLE...ADITI July 2020//
tab hbnknew  

*END REGRESSIONS



**********************************************************************************************************
*focus group profile table ///
tabstat age-prepaid, by(senior) stat(n min mean max) col(stat) long save
putexcel set focusprofile.xls 
return list
/*macros:
              r(name2) : "1"
              r(name1) : "0"

matrices:
              r(Stat2) :  4 x 23
              r(Stat1) :  4 x 23
          r(StatTotal) :  4 x 23
*/

matrix senior = r(Stat2)'
matrix younger = r(Stat1)'
putexcel A3 = matrix(younger), rownames nformat(number_d2)
putexcel F3 = matrix(senior),  nformat(number_d2)
