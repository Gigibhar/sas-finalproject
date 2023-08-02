**********************************************************************************************************
**	P8483: Spring 2022														     						**
**	Final Project															    						**
**  Names: Gwyneth Wei, Olivia Wang, Nahiyan Taufiq, Jeremy Chiu, Girisha Bharadwaj, Jeffannie O'Garro  **                                                        
**  UNIs: gw2442, hw2852, nmt2137, jc4346, gb2762, jo2672					        					**
**********************************************************************************************************
RESEARCH PROJECT BACKGROUND
Population of Interest: US adults age 21 to 79 years
Data source: NHANES 2017-2018 

Research Questions:
  i. Does mean LDL level vary between different smoking levels?
 ii. Does the prevalence of elevated LDL differ between increasing smoking levels?
iii. Does any observed relationship in 1 and 2 remain after adjusting for sex, age, and BMI?

Variables of Interest
- Age in years (RIDAGEYR)
- Sex (RIAGENDR)
- BMI (BMXBMI)
- Average number of cigarettes smoked per day during the past 30 days (SMD650)
- LDL cholesterol levels in mg/dL (LBDLBL)
- Unique ID (SEQN)

**********************************************************************************************************
PART I: Creating an analytic database with which we will test our research questions. 
In this section, we imported the relevant data files (DEMO_J, SMQ_J, TRIGLY_J, and BMX_J) from the NHANES 
2017-2018 survey data. All our variables of interests are found within these datasets. We conducted a 
fully restricted merge on the data files and restricted the data file to our population of interest.

Our population of interest are US adults 21-79 years of age (variable RIDAGEYR from "DEMO_J" data file). 
We applied the following inclusion criteria:
- Must answer question on average number of cigarettes smoked per day during the past 30 days 
  (variable SMD650 from "SMQ_J" data file)
- Must have LDL cholesterol measurements (variable LBDLBL from "TRIGLY_J" data file)
- Must have non-missing BMI (variable BMXBMI from "BMX_J" data file)
- Must have non-missing gender (variable RIAGENDR from "DEMO_J" data file);

filename DEMO_J "/home/u60716953/sasuser.v94/DEMO_J.xpt"; 
proc http 
url = "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/DEMO_J.XPT"
out = DEMO_J;
run;

libname files xport "/home/u60716953/sasuser.v94/DEMO_J.xpt"; 
data DEMO_J; set files.DEMO_J; 
run; 

filename SMQ_J "/home/u60716953/sasuser.v94/SMQ_J.xpt"; 
proc http 
url = "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/SMQ_J.XPT"
out = SMQ_J;
run;

libname files xport "/home/u60716953/sasuser.v94/SMQ_J.xpt"; 
data SMQ_J; set files.SMQ_J; 
run;

filename TRIGLY_J "/home/u60716953/sasuser.v94/TRIGLY_J.xpt"; 
proc http 
url = "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/TRIGLY_J.XPT"
out = TRIGLY_J;
run;

libname files xport "/home/u60716953/sasuser.v94/TRIGLY_J.xpt"; 
data TRIGLY_J; set files.TRIGLY_J; 
run;

filename BMX_J "/home/u60716953/sasuser.v94/BMX_J.xpt";
proc http
url = "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/BMX_J.XPT"
out = BMX_J;
run;

libname files xport "/home/u60716953/sasuser.v94/BMX_J.xpt"; 
data BMX_J; set files.BMX_J; 
run;

proc sort data = DEMO_J; by SEQN; 
proc sort data = SMQ_J; by SEQN; 
proc sort data = TRIGLY_J; by SEQN;
proc sort data = BMX_J; by SEQN; 
run; 

data Project;
merge DEMO_J (in = a) SMQ_J (in = b) TRIGLY_J (in = c) BMX_J (in = d); by SEQN;
if a and b and c and d;
run; 

*To determine whether it is appropriate to proceed with variable LBDLDL as an outcome variable to be later
operationalized as a continuous variable for this analysis, the variable was analyzed for approximate 
normality.;

proc univariate data = Project plots; 
var LBDLDL; 
histogram LBDLDL/normal; 
run; 

*Based on a visual inspection of the histogram produced in the output, we can conclude that variable 
LBDLDL is approximately normally distributed, and it is appropriate to proceed and use the variable in 
this analysis.;

data Project; set Project;
keep RIDAGEYR RIAGENDR SMD650 LBDLDL BMXBMI SEQN;
if RIAGENDR = . then delete; 
if RIDAGEYR < 21 or RIDAGEYR > 79 then delete; 
if LBDLDL = . then delete; 
if SMD650 in (777 999 .) then delete;
if BMXBMI = . then delete; 
run;

proc freq data = Project; 
table RIAGENDR RIDAGEYR LBDLDL SMD650 BMXBMI; 
run;

proc contents data = Project; 
run;

*After merging all relevant files and restricting the data set, dataset "Project" contains 6 variables 
and 397 observations. As such, we have a total study population of 397. This is recorded in the 
Background section and Table 1 of the attached abstract.

**********************************************************************************************************
PART II: Operationalizations of Exposure, Outcome, and Confounding Variables of Interest  
For this analysis, the exposure of interest, i.e., smoking level, was operationalized as a 3-level 
categorical variable: 
  i. Light Smoker: reported have smoked, on average, 10 or fewer cigarettes per day in the last month. 
 ii. Moderate Smoker: reported to have smoked, on average, 11-19 cigarettes per day in the last month.
iii. Heavy Smoker: reported to have smoked, on average, 20 or more cigarettes per day in the last month. 
These cutoffs are in accordance with definitions of light, moderate and heavy smokers developed by the 
Public Health Agency of Canada.

The outcome of interest, i.e., LDL cholesterol level, was operationalized in the following 2 ways:
 i. LDL Cholesterol Level: Continuous variable, measured in mg/dL
ii. Elevated LDL Cholesterol Level: Binary variable, categorised as elevated if the reported LDL cholesterol
    level is greater than or equal to 100mg/dL, and not elevated if the reported LDL cholesterol level 
    is less than 100 mg/dL. This cutoff is in accordance with the medical standards prescribed by CDC. 

Formats were applied to the categorical variables of interest, to facilitate interpretation of results.;

data Project; set Project; 
if LBDLDL < 100 then Elevated_LDL = 0;
if LBDLDL >= 100 then Elevated_LDL = 1; 
if SMD650 <= 10 then Smoking_Level = 0; 
if 11 <= SMD650 <= 19 then Smoking_Level = 1; 
if SMD650 >= 20 then Smoking_Level = 2; 
format Elevated_LDL Elevated_LDLf. Smoking_Level Smoking_Levelf. RIAGENDR RIAGENDRf.; 
run; 

proc format; 
value  Elevated_LDLf 0 = "Not Elevated LDL Level"
					 1 = "Elevated LDL Level";
value Smoking_Levelf 0 = "Light Smoker"
					 1 = "Moderate Smoker"
					 2 = "Heavy Smoker";
value 	   RIAGENDRf 1 = "Male"
	 		         2 = "Female";
run; 

proc freq data = Project; 
table Elevated_LDL Smoking_Level RIAGENDR; 
run;

**********************************************************************************************************
PART III: Creating Table 1 to Describe Our Study Population
We used the tabulate procedure generate a comprehensive collection of information on our study population. 
Chi-Square and ANOVA tests were used to determine whether there were statistically significant differences 
across exposure groups at baseline.; 

proc tabulate data = Project; 
class RIAGENDR Smoking_Level Elevated_LDL;
var RIDAGEYR BMXBMI; 
table N RowPctN RIAGENDR*(N RowPctN) RIDAGEYR*(mean std) BMXBMI*(mean std), all Smoking_Level; 
run; 

proc freq data = Project order = data; 
table RIAGENDR*Elevated_LDL/measures chisq; 
run; 

proc anova data = Project;
class Smoking_Level;
model RIDAGEYR = Smoking_Level;
means Smoking_Level; 
run;

proc anova data = Project;
class Smoking_Level;
model BMXBMI = Smoking_Level;
means Smoking_Level; 
run;

*Table displays the distribution of sex, age, and BMI by smoking level (light smoker, moderate smoker, 
heavy smoker). Information within the table includes the number of individuals within each category 
across potential confounders. The percentage distribution across smoking level for gender is included. 
Mean values across smoking levels for both age and BMI, as well as its relevant standard deviation is 
included. P-values were determined using the calculated chi-squared and F test statistics are included 
for each potential confounder variable. All values listed are reported in Table 1.

Total N = 397 
	Light smoker N = 253 (63.73%)
	Moderate smoker N = 42 (10.58%)
	Heavy smoker N = 102 (25.69%)
	
*********************Gender*********************
Male: 
Total N = 228 (57.43% - Col Pct)
	Light smoker N = 146 (64.04% - Row Pct)
	Moderate smoker N = 24 (10.43% - Row Pct)
	Heavy smoker N = 58 (25.44% - Row Pct)
	
Female:
Total N = 169 (42.57% - Col Pct)
	Light smoker N = 107 (63.31% - Row Pct)
	Moderate smoker N = 18 (10.65% - Row Pct)
	Heavy smoker N = 44 (26.04% - Row Pct)

P-value: 0.7891

***********************Age***********************	
Mean (Years) = 48.25 (SD = 14.36)
	Light Smoker Mean Age = 47.17 (SD = 14.81)
	Moderate Smoker Mean Age = 49.29 (SD = 13.80)
	Heavy Smoker Mean Age = 50.49 (SD = 13.24)

P-value: 0.1272

***********************BMI***********************
Mean (kg/m^2) = 29.61 (SD = 8.44)
	Light Smoker Mean BMI = 30.26 (SD = 8.59)
	Moderate Smoker Mean BMI = 27.81 (SD = 7.26)
	Heavy Smoker Mean BMI = 28.72 (SD = 8.42)

P-value: 0.1027

**********************************************************************************************************
PART IV: Testing Operationalized Hypothesis Using Crude & Adjusted Logistic Regression Models
As previously discussed, the exposure of interest was operationalized as a 3-level categorical variable 
(light, moderate and heavy smokers), and the outcome of interest was operationalized both as a continuous
variable, and as a 2-level categorical variable (elevated vs. not elevated). To test our study hypothesis, 
we will first apply a GLM procedure for our continuous outcome variable, i.e., LDL cholesterol level, 
measured in mg/dL. The crude model contains only the exposure (Smoking_Level) and outcome (LBDLDL) of 
interest, and the adjusted model contains the exposure, outcome, and potential confounders (Age, Sex, BMI).; 

title1 'Smoking Level vs. LDL Cholesterol Level';
title2 'Crude Model';
proc glm data = Project; 
class Smoking_Level (ref = 'Light Smoker');
model LBDLDL = Smoking_Level/ solution clparm; 
run;

title1 'Smoking Level vs. LDL Cholesterol Level';
title2 'Adjusted Model';
proc glm data = Project; 
class Smoking_Level (ref = 'Light Smoker');
class RIAGENDR (ref = 'Male');
model LBDLDL = Smoking_Level RIDAGEYR RIAGENDR BMXBMI/ solution clparm; 
run;

***CRUDE ANALYSIS***
Crude linear regression model includes parameter estimates and corresponding 95% confidence intervals 
illustrating change in LDL cholesterol levels across exposure groups (light smoker, moderate smoker, 
heavy smoker). Light smoker is the reference group.

Parameter Estimates (Mean Difference):
	Heavy Smoker: 0.1481 (95% CI: -8.1814, 8.4778) (reported in Table 2)
	Moderate Smoker: -6.2733 (95% CI: -18.1063, 5.5596) (reported in Table 2)
	
Heavy smokers have 0.1481 mg/dL higher LDL level than light smokers on average. We are 95% confident that
the mean difference in LDL between heavy and light smokers is between -8.1814 and 8.4778. Since this 95%
confidence interval contains the null value of 0, we have insufficient evidence to conclude that mean LDL
levels between heavy and light smokers differ. 
Moderate smokers have 6.2733 mg/dL lower LDL level than light smokers on average. We are 95% confident that
the mean difference in LDL between heavy and light smokers is between -18.1063, 5.5596. Since this 95%
confidence interval contains the null value of 0, we have insufficient evidence to conclude that mean LDL
levels between moderate and light smokers differ. 


***ADJUSTED ANALYSIS***
Adjusted linear regression model includes parameter estimates and corresponding 95% confidence intervals 
illustrating change in LDL cholesterol levels across exposure groups (light smoker, moderate smoker, 
heavy smoker), as well as all confounder variables (age, sex, BMI). Light smoker is the reference group 
for smoking level. Male is the refernce group for sex. 

Parameter Estimates (Mean Difference): 
	Heavy Smoker: 0.0967 (95% CI: -8.3156, 8.5090) (reported in Table 2)
	Moderate Smoker: -6.1787 (95% CI: -18.0983, 5.7410) (reported in Table 2)
	RIDAGEYR: 0.0492 (95% CI: -0.2048, 0.3033)
	RIAGENDR Female: 2.6573 (95% CI: -4.7640, 10.0597)
	BMXBMI: 0.0871 (95% CI: -0.3559, 0.5302)

Heavy smokers have 0.0967 mg/dL higher LDL than light smokers on average, adjusting for age, sex, and BMI.
We are 95% confident that the mean difference in LDL between heavy and light smokers, adjusting for age, sex
and BMI, is between -8.3156 and 8.5090. Since this 95% confidence interval contains the null value of 0, we have 
insufficient evidence to conclude that mean LDL levels between heavy and light smokers differ, adjusting for
age, sex, and BMI. 

Moderate smokers have 6.1787 mg/dL lower LDL than light smokers on average, adjusting for age, sex, and BMI. 
We are 95% confident that the mean difference in LDL between heavy and light smokers, adjusting for age, sex
and BMI, is between -18.0983 and 5.7410. Since this 95% confidence interval contains the null value of 0, we have 
insufficient evidence to conclude that mean LDL levels between moderate and light smokers differ, adjusting for
age, sex, and BMI. 

*Next, we will apply a logistic procedure for our categorical outcome variable, i.e., Elevated LDL 
Cholesterol (elevated vs. not elevated). Consistent with the approach taken earlier with the continous 
outcome variable, the crude model contains only the exposure (Smoking_Level) and outcome (Elevated_LDL), 
and the adjusted model contains the exposure, outcome, and potential confounders (Age, Sex, BMI).;

title1 'Smoking Level vs. Elevated LDL Level';
title2 'Crude Model';
proc logistic data = Project; 
class Smoking_Level (ref = "Light Smoker") / param = ref; 
class Elevated_LDL (ref = "Not Elevated LDL Level") / param = ref; 
model Elevated_LDL = Smoking_Level; 
run; 

title1 'Smoking Level vs. Elevated LDL Level';
title2 'Adjusted Model';
proc logistic data = Project; 
class Smoking_Level (ref = "Light Smoker") / param = ref; 
class Elevated_LDL (ref = "Not Elevated LDL Level") / param = ref; 
class RIAGENDR (ref = "Male") / param = ref; 
model Elevated_LDL = Smoking_Level RIDAGEYR RIAGENDR BMXBMI;  
run; 

***CRUDE ANALYSIS***
Crude logistic regression model includes odds ratio and corresponding 95% confidence intervals 
illustrating the odds of elevated LDL cholesterol comparing heavy smoker to light smokers, and moderate
smokers to light smokers. Light smoker is the reference group. 

Odds Ratio:
	Heavy vs Light Smoker: 0.901 (95% CI: 0.562, 1.445) (reported in Table 2)
	Moderate vs Light Smoker: 0.775 (95% CI: 0.400, 1.503) (reported in Table 2)

The odds of elevated LDL cholesterol among heavy smokers is 0.901 times the odds of  elevated LDL cholesterol 
among light smokers. We are 95% confident the true odds ratio lies between 0.562 and 1.445. Since this odds 
ratio contains the null value of 1, we can conclude that we have insufficient evidence to reject the null
hypothesis of no association. 

The odds of elevated LDL cholesterol for moderates smokers is 0.775 times the odds of elevated LDL 
cholesterol for light smokers. We are 95% confident the true odds ratio lies between 0.400 and 1.503. Since 
this odds ratio contains the null value of 1, we can conclude that we have insufficient evidence to reject 
the null hypothesis of no association. 

***ADJUSTED ANALYSIS***
Adjusted logistic regression model includes odds ratio and corresponding 95% confidence intervals 
illustrating the odds of elevated LDL cholesterol between heavy smoker/moderate smoker and light smokers. 
Light smoker is the reference group. It also includes confounder variables age, sex, and BMI. 

Odds Ratio:
	Heavy vs Light Smoker: 0.926 (95% CI: 0.575, 1.490) (reported in Table 2)
	Moderate vs Light Smoker: 0.794 (95% CI: 0.408, 1.546) (reported in Table 2)
	RIDAGEYR: 0.994 (95% CI: 0.980, 1.009)
	RIDAGENDR Female vs Male: 1.033 (95% CI: 0.678, 1.574)
	BMXBMI: 1.006 (95% CI: 0.980, 1.032)

The odds of elevated LDL cholesterol for heavy smokers is 0.926 times the odds of  elevated LDL cholesterol 
for light smokers, after adjusting for age, sex and BMI. We are 95% confident the true odds ratio lies 
between 0.575 and 1.490. Since this odds ratio contains the null value of 1, we can conclude that we have 
insufficient evidence to reject the null hypothesis of no association. 

The odds of elevated LDL cholesterol for moderates smokers is 0.794 times the odds of elevated LDL 
cholesterol for light smokers, after adjusting for age, sex and BMI. We are 95% confident the true odds 
ratio lies between 0.408 and 1.546. Since this odds ratio contains the null value of 1, we can conclude that 
we have insufficient evidence to reject the null hypothesis of no association. 
