proc import file = 'C:\Users\DVALDE12\Desktop\boston project\boston.csv'
out = boston
dbms = csv
replace;
run;

proc print data = boston;
run;

data new_boston;
set boston (rename=(CRIME=crime ZN=zn INDUS=indus CHAS=chas NOX=nox RM=rm AGE=age DIS=dis RAD=rad TAX=tax PTRATIO=ptRatio Minor=minor LSTAT=lstat MEDV=medv));  
*log if y>0 sqrt if Y>=0 inv if Y!= 0;
*log-crime sqrt-zone log-indus log-nox log-rm log-age log-dis log-rad log-tax 
log-ptratio log-minor log-lstat log-medv;

crime2 = log(crime);
zone2=sqrt(zn);
indus2 = log(indus);
nox2=sqrt(nox);
rm2 = log(rm);
age2 = sqrt(age);
dis2 = log(dis);
rad2=log(rad);
tax2=log(tax);
ptratio2=log(ptratio);
minor2=log(minor);
lstat2=log(lstat);
medv2=log(medv);
run;

proc print data=new_boston;
run;

*explore;
title 'explore';
proc sgplot data = new_boston;
scatter y= medv x=crime;
reg y=medv x=crime;
run;

proc sgplot data = new_boston;
scatter y= medv x=zn;
reg y=medv x=zn;
run;

proc sgplot data = new_boston;
scatter y= medv x=indus;
reg y=medv x=indus;
run;

proc sgplot data = new_boston;
scatter y= medv x=chas;
reg y=medv x=chas;
run;

proc sgplot data = new_boston;
scatter y= medv x=nox;
reg y=medv x=nox;
run;

proc sgplot data = new_boston;
scatter y= medv x=rm;
reg y=medv x=rm;
run;

proc sgplot data = new_boston;
scatter y= medv x=age;
reg y=medv x=age;
run;

proc sgplot data = new_boston;
scatter y= medv x=dis;
reg y=medv x=dis;
run;

proc sgplot data = new_boston;
scatter y= medv x=rad;
reg y=medv x=rad;
run;

proc sgplot data = new_boston;
scatter y= medv x=tax;
reg y=medv x=tax;
run;

proc sgplot data = new_boston;
scatter y= medv x=ptratio;
reg y=medv x=ptratio;
run;

proc sgplot data = new_boston;
scatter y= medv x=minor;
reg y=medv x=minor;
run;

proc sgplot data = new_boston;
scatter y= medv x=lstat;
reg y=medv x=lstat;
run;

*descriptive statistics;
title'Descriptive Statistics';
proc means mean mode std stderr min p25 p50 p75 max;
var crime zn indus chas nox rm age dis rad tax ptratio minor lstat medv;
run;

*non transformed histogram;
proc univariate data=new_boston;
title 'Histogram: No transformation';
var crime zn indus chas nox rm age dis rad tax ptratio minor lstat medv;
histogram;
run;

*transformed histogram;
proc univariate data=new_boston;
title 'Histogram: transformation';
var crime2 zone2 indus2 chas nox2 rm2 age2 dis2 rad2 tax2 ptratio2 minor2 lstat2 medv2;
histogram;
run;
*scatterplot matrix;
proc sgscatter data = new_boston;
title 'Scatterplot: Matrix Transformed';
matrix  medv2 crime2 zone2 indus2 nox2 rm2 age2 dis2 rad2 tax2 ptratio2 minor2 lstat2 ;
run;

*not transformed q-q plot;
proc univariate data = new_boston;
title 'Q-Q plot: Not Transformed';
var crime zn indus chas nox rm age dis rad tax ptratio minor lstat medv;
qqplot;
run;

*transformed q-q plot;
proc univariate data = new_boston;
title 'Q-Q plot: Transformed';
var crime2 zone2 indus2 chas nox2 rm2 age2 dis2 rad2 tax2 ptratio2 minor2 lstat2 medv2;
qqplot;
run;

*transformed, checking the residual;
proc reg data = new_boston;
title 'Checking Residual: Transformed Full Model';
model medv2 = crime2 zone2 indus2 chas nox2 rm2 age2 dis2 rad2 tax2 ptratio2 minor2 lstat2/ influence r;
plot student.*(crime2 zone2 indus2 chas nox2 rm2 age2 dis2 rad2 tax2 ptratio2 minor2 lstat2 predicted.);
plot npp.*student;
run;

*removing outliers and influential points;
proc reg data=new_boston  plots=none;
model medv2 = crime2 zone2 indus2 chas nox2 rm2 age2 dis2 rad2 tax2 ptratio2 minor2 lstat2/ influence r;
output out=RegOut predicted=Pred student=RStudent cookd=CookD H=Leverage;
quit;
 
%let p = 14;  /* number of parameter in model, including intercept */
%let n = 375; /* Number of Observations Used */
title "Influential (Cook's D)";
proc print data=RegOut;
   where CookD > 4/&n;
	var medv2 crime2 zone2 indus2 chas nox2 rm2 age2 dis2 rad2 tax2 ptratio2 minor2 lstat2 CookD;
run;
*removing outiers;
data new_boston;
set new_boston;
if _n_ in (8,65,143,145,153,156,182,215,254,266,285,311,365,366,368,369,370,372,373,374) then delete;

*full model no outliers + transformation + checking for multicolinearity;
proc reg data = new_boston;
title 'full model transformed: no outlers or influential points';
model medv2 = crime2 zone2 indus2 chas nox2 rm2 age2 dis2 rad2 tax2 ptratio2 minor2 lstat2/ vif tol;
run;
*no multicollinearity;
*variable selection method;
proc reg data = new_boston;
title 'full model transformed: no outlers or influential points';
model medv2 = crime2 zone2 indus2 chas nox2 rm2 age2 dis2 rad2 tax2 ptratio2 minor2 lstat2/ selection=forward;
run;
proc reg data = new_boston;
title 'full model transformed: no outlers or influential points';
model medv2 = crime2 zone2 indus2 chas nox2 rm2 age2 dis2 rad2 tax2 ptratio2 minor2 lstat2/ selection=stepwise;
run;
*Both selection fitted models: rm2, lstat2, ptratio2, dis2, nox2, rad2, tax2, minor2, chas, indus2, age2, crime2;
proc reg data = new_boston;
title 'full model transformed: no outlers or influential points';
model medv2 = crime2 indus2 chas nox2 rm2 age2 dis2 rad2 tax2 ptratio2 minor2 lstat2/stb;
run;
*cross validation full model, train/test set 70/30;
title '5-fold cv with full model stepwise at 70/30';
proc glmselect data= new_boston
plots= (asePlot Criteria);
partition fraction (test=0.30);
model medv2 = crime2 indus2 chas nox2 rm2 age2 dis2 rad2 tax2 ptratio2 minor2 lstat2/
selection=stepwise (stop=cv) cvMethod=split(5) cvDetails=all;
run;

proc surveyselect data= new_boston
out=boston_train_test seed=495857
samprate=0.70 outall;
run;

data boston_train_test;
set boston_train_test;
if selected then new_medv = medv2;
run;
proc print data = boston_train_test;
run;

title ' validation - test set';
proc reg data = boston_train_test;
model medv2 = crime2 indus2 chas nox2 rm2 age2 dis2 rad2 tax2 ptratio2 minor2 lstat2;
output out=out_m1 (where=(new_medv=.)) p=yhat;
run;

*summary;
data outm1_sum;
set out_m1;
d=medv2-yhat;
absd= abs(d);
run;

*compute predictive stats';
proc summary data=outm1_sum;
var d absd;
output out=outm1_stats std (d)=rmse mean (absd)=mae;
run;
proc print data=outm1_stats;
title 'validation stats';
run;
*compute correlation of obs and pred in test set';
proc corr data=out_m1;
var medv2 yhat;
run;

data pred;
input medv2 crime2 indus2 chas nox2 rm2 age2 dis2 rad2 tax2 ptratio2 minor2 lstat2;
datalines;
. 0.1543 7.22 0 0.22 10.213 24.5 4.237 4 302 55 388.21 6.07
;
run;
data new;
set pred boston_train_test;
run;

proc reg data=new;
title 'CI: Prediction 1';
model medv2 = crime2 indus2 chas nox2 rm2 age2 dis2 rad2 tax2 ptratio2 minor2 lstat2/p cli;
run;



