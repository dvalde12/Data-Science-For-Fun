proc import file= 'C:\Users\DVALDE12\Desktop\carpred\ford.csv'
out=ford
dbms=csv
replace;
run;

proc print data=ford;
run;

data new_ford;
set ford;
new_year =(year);
new_engineSize = sqrt(engineSize);
new_tax = sqrt(tax);
new_mileage = log(mileage);
new_price=log(price);

fuelType_d1 =(fuelType= 'Diesel');
fuelType_d2 =(fuelType= 'Electr');
fuelType_d3 =(fuelType= 'Hybrid');
fuelType_d4 =(fuelType= 'Petrol');

model_d1 = (model='B-MAX');
model_d2 = (model='C-MAX');
model_d3 = (model='EcoSport');
model_d4 = (model='Edge');
model_d5 = (model='Escort');
model_d6 = (model='Fiesta');
model_d7 = (model='Focus');
model_d8 = (model='Fusion');
model_d9 = (model='Galaxy');
model_d10 = (model='Grand C-');
model_d11 = (model='Grand To');
model_d12 = (model='KA');
model_d13 = (model='Ka+');
model_d14 = (model='Kuga');
model_d15 = (model='Mondeo');
model_d16 = (model='Mustang');
model_d17 = (model='Puma');
model_d18 = (model='Ranger S-');
model_d19 = (model='MAX');
model_d20 = (model='Streetka');
model_d21 = (model='Tourneo');

transmission_d1 = (transmission='Automatic');
transmission_d2 = (transmission='Manual');
run;

*log if y>0 sqrt if Y>=0 inv if Y!= 0;
*tax sqrt engineSize sqrt


*unique var;
proc freq data=new_ford;
tables model / missing; 
run;
 
proc sql;
   select distinct(model) as uModel
   from new_ford;
quit;
 
proc iml;
use new_ford;
   read all var "Model";
close;
 
uModel = unique(Model);
print uModel;

proc freq data=new_ford;
tables transmission / missing; 
run;
 
proc sql;
   select distinct(transmission) as uTransmission
   from new_ford;
quit;
 
proc iml;
use new_ford;
   read all var "transmission";
close;
 
uTransmission = unique(transmission);
print uTransmission;

proc freq data=new_ford;
tables fuelType / missing; 
run;
 
proc sql;
   select distinct(fuelType) as uFuelType
   from new_ford;
quit;
 
proc iml;
use new_ford;
   read all var "fuelType";
close;
 
uFuelType = unique(fuelType);
print uFuelType;
*dummies;
*model:22 obs transmission: 3 obs fuelType: 5 obs;

*descriptive statistics;
title'Descriptive Statistics';
proc means mean mode std stderr min p25 p50 p75 max;
var year price mileage tax mpg engineSize;
run;

*explore;
title 'explore';
proc sgplot data =ford;
scatter y=price x=year;
reg y=price x=year;
run;

title 'explore';
proc sgplot data =ford;
scatter y=price x=mileage;
reg y=price x=mileage;
run;

title 'explore';
proc sgplot data =ford;
scatter y=price x=tax;
reg y=price x=tax;
run;

title 'explore';
proc sgplot data =ford;
scatter y=price x=mpg;
reg y=price x=mpg;
run;

title 'explore';
proc sgplot data =ford;
scatter y=price x=engineSize;
reg y=price x=engineSize;
run;

*histogram: no transform;
proc univariate data=ford;
title 'Histogram: No Transform';
var year price mileage tax mpg engineSize;
histogram;
run; 

*histogram:transform;
proc univariate data=new_ford;
title 'Histogram: Transform';
var year new_price new_mileage new_tax mpg new_engineSize;
histogram;
run; 

title 'explore';
proc sgplot data =new_ford;
scatter y=price x=new_mileage;
reg y=price x=new_mileage;
run;

title 'explore';
proc sgplot data =new_ford;
scatter y=price x=new_tax;
reg y=price x=new_tax;
run;

title 'explore';
proc sgplot data =new_ford;
scatter y=price x=new_engineSize;
reg y=price x=new_engineSize;
run;
title 'explore';
proc sgplot data =new_ford;
scatter y=price x=new_year;
reg y=price x=new_year;
run;

proc reg data=new_ford;
title 'dummies';
	model price = year new_mileage new_tax mpg new_engineSize model_d1 model_d2 model_d3 model_d4 model_d5 model_d6 model_d7 
	model_d8  model_d9 model_d10 model_d11 model_d12  model_d13 model_d14 model_d15 model_d16 model_d17 
	 model_d20 model_d21 transmission_d1 transmission_d2 fuelType_d1 fuelType_d2 fuelType_d3 fuelType_d4;
	run;

proc sgscatter data=new_ford;
title ' scatterplot matrix';
matrix price year mileage tax mpg engineSize;
run;
ods graphics / antialias=on antialiasmax=18000;
proc sgscatter data=new_ford;
title ' scatterplot matrix';
matrix price new_year new_mileage new_tax mpg new_engineSize;
run;

proc univariate data = new_ford;
title'Q-Q Plots: Transform';
var new_price new_year new_mileage new_tax mpg new_engineSize;
qqplot;
run;
*outliers and influential pts;
proc reg data = new_ford;
title 'Outliers & Influential Obs With Transformed Model';
	model price = year new_mileage new_tax mpg new_engineSize model_d1 model_d2 model_d3 model_d4 model_d5 model_d6 model_d7 
	model_d8  model_d9 model_d10 model_d11 model_d12  model_d13 model_d14 model_d15 model_d16 model_d17 
	 model_d20 model_d21 transmission_d1 transmission_d2 fuelType_d1 fuelType_d2 fuelType_d3 fuelType_d4/ influence r;
plot student.*(year new_mileage new_tax mpg new_engineSize model_d1 model_d2 model_d3 model_d4 model_d5 model_d6 model_d7 
	model_d8  model_d9 model_d10 model_d11 model_d12  model_d13 model_d14 model_d15 model_d16 model_d17 
	 model_d20 model_d21 transmission_d1 transmission_d2 fuelType_d1 fuelType_d2 fuelType_d3 fuelType_d4 predicted.);
plot npp.*student.;
run;

proc reg data = new_ford plots(only label)=(CooksD RStudentByLeverage);
title 'influence';
model new_price=year new_mileage new_tax mpg new_engineSize model_d1 model_d2 model_d3 model_d4 model_d5 model_d6 model_d7 
	model_d8  model_d9 model_d10 model_d11 model_d12  model_d13 model_d14 model_d15 model_d16 model_d17 
	 model_d20 model_d21 transmission_d1 transmission_d2 fuelType_d1 fuelType_d2 fuelType_d3 fuelType_d4;
run;

proc reg data=new_ford  plots=none;
model new_price=year new_mileage new_tax mpg new_engineSize model_d1 model_d2 model_d3 model_d4 model_d5 model_d6 model_d7 
	model_d8  model_d9 model_d10 model_d11 model_d12  model_d13 model_d14 model_d15 model_d16 model_d17 
	 model_d20 model_d21 transmission_d1 transmission_d2 fuelType_d1 fuelType_d2 fuelType_d3 fuelType_d4;
output out=RegOut predicted=Pred student=RStudent cookd=CookD H=Leverage;
quit;

%let p = 31;  /* number of parameter in model, including intercept */
%let n = 17966; /* Number of Observations Used */
title "Influential (Cook's D)";
proc print data=RegOut;
   where CookD > 4/&n;
   var new_price year new_mileage new_tax mpg new_engineSize model_d1 model_d2 model_d3 model_d4 model_d5 model_d6 model_d7 
	model_d8  model_d9 model_d10 model_d11 model_d12  model_d13 model_d14 model_d15 model_d16 model_d17 
	 model_d20 model_d21 transmission_d1 transmission_d2 fuelType_d1 fuelType_d2 fuelType_d3 fuelType_d4 CookD;
run;

data new_ford;
set new_ford;
if _n_ in (7,44,53,92,95,107,117,135,136,261,319,339,340,354,
509,1040,1056,1143,1163,1349,1370,1390,1401,1460,1527,1619,1689
,1724,1725,1736,1794,1801,1802,1810,1811,1826,1906,1934,1952,1963,
1984,1985,1986,1997,2023,2076,2077,2099,2109,2112,2161,2179,2197,
2213,2233,2265,2287,2302,2411,2426,2459,2732,2734,2743,2805,2869,
2950,3062,3122,3187,3216,3441,3483,3538,3548,3562,3593,3612,3648,
3655,3688,3696,3745,3784,3851,3926,3927,3928,3933,4084,4179,4295,4296,4354,
5464,4586,4607,4808,4887,4898,4902,4912,4917,4936,4988,5016,5021,5029,5124,
5154,5210,5278,5343,5374,5377,5473,5524,5603,5653,5770,5771,5859,5889,5987,
6030,6104,6105,6109,6137,6177,6191,6221,6282,6347,6398,6520,6537,6575,6680,
6692,6761,6766,6769,6770,6817,6838,6866,6894,6931,6976,6977,7099,7134,7165,
7169,7183,7230,7240,7248,7292,7314,7354,7610,7653,7681,7691,7699,7708,7812,
7886,7895,7899,7992,8258,8261,8357,8481,8567,8571,8675,8712,8856,8862,9056,
9057,9058,9165,9233,9317,9346,9407,9463,9481,9499,9580,9607,9641,9753,9791,
9800,9819,9845,9937,9975,10032,10097,10323,10360,10408,10412,10419,10525,10537,
10554,10555,10601,10661,10684,10736,10753,10776,10780,10795,10828,10902,10948,
10973,10991,10997,11012,11019,11069,11098,11105,11109,11130,11174,11235,11282,
11289,11386,11424,11444,11530,11758,11759,11796,11863,11879,11901,11911,11913,
11914,11920,12013,12028,12029,12107,12108,12120,12122,12186,12349,12352,12367,
12373,12509,12528,12546,12571,12575,12579,12593,12594,12600,12601,12609,12641,
12663,12697,12791,12804,12862,12863,12962,12963,12964,12968,12996,13055,13061,
13087,13088,13095,13124,13125,13134,13136,13178,13182,13184,13186,13187,13205,
13208,13231,13313,13329,13331,13336,13350,13357,13358,13383,13392,13418,13423,
13423,13467,13483,13484,13486,13490,13531,13532,13545,13546,13549,13560,13561,
13570,13575,13578,13579,13580,13581,13582,13584,13594,13595,13602,13606,13608,
13632,13637,13656,13658,13663,13695,13714,13731,13732,13761,13820,13825,13827,
13832,13834,13837,13841,13852,13863,13909,13920,14004,14011,14048,14065,14083,
14106,14139,14208,14214,14223,14238,14264,14364,14368,14374,14467,14472,14479,
14491,14496,14497,14499,14501,14506,14508,14509,14512,14516,14524,14529,14530,
14552,14556,14558,14587,14598,14621,14648,14678,14690,14692,14694,14701,14744,
14762,14786,14821,14837,14858,14859,14887,14900,14907,14960,15019,15020,15021,
15083,15208,15254,15259,15276,15286,15287,15295,15304,15344,15438,15468,15501,
15543,15626,15673,15679,15680,15681,15683,15684,15685,15686,15687,15710,15730,
15776,15808,15812,15835,15849,15862,15895,15896,15952,16033,16060,16072,16111,
16127,16140,16143,16188,16210,16244,16248,16251,16254,16267,16272,16274,16280,
16281,16282,16283,16313,16314,16322,16323,16324,16325,16326,16327,16328,16329,
16330,16331,16332,16333,16334,16335,16336,16337,16338,16339,16340,16341,16342,
16343,16345,16349,16353,16354,16355,16356,16357,16358,16359,16360,16361,16362,
16363,16364,16365,16369,16372,16375,16376,16387,16396,16397,16405,16421,16429,
16433,16434,16435,16436,16472,16473,16474,16475,16476,16477,16478,16479,16480,
16481,16492,16500,16507,16515,16516,16517,16525,16575,16578,16611,16619,16652,
16653,16654,16655,16657,16658,16659,16670,16678,16695,16705,16706,16709,16713,
16714,16715,16729,16731,16732,16733,16736,16741,15760,16790,16799,16812,16816,
16820,16829,16830,16840,16841,16842,16843,16850,16858,16863,16870,16874,16900,
16901,16903,16905,16906,16907,16908,16926,16936,16940,16941,16946,16947,16948,
16950,16951,16966,16974,16977,16988,17005,17009,17017,17022,17030,17036,17049,
17056,17060,17067,17072,17076,17077,17081,17101,17104,17138,17139,17162,17166,
17167,17182,17187,17194,17204,17220,17247,17249,17251,17256,17268,17278,17283,
17299,17313,17326,17343,17345,17347,17348,17349,17353,17365,17371,17372,17373,
17374,17375,17377,17378,17379,17388,17412,17414,17415,17419,17420,17421,17433,
17437,17441,17444,17447,17448,17451,17454,17469,1786,17493,17495,17526,17532,
17535,17538,17577,17651,17672,17727,17732,17737,17743,17747,17755,17757,17758,
17775,17795,17803,17805,17816,17824,17850,17867,17913) then delete;

proc reg data = new_ford;
title 'full model';
model new_price=year new_mileage new_tax mpg new_engineSize model_d1 model_d2 model_d3 model_d4 model_d5 model_d6 model_d7 
	model_d8  model_d9 model_d10 model_d11 model_d12  model_d13 model_d14 model_d15 model_d16 model_d17 
	  model_d21 transmission_d1 transmission_d2 fuelType_d1 fuelType_d2 fuelType_d3/vif tol;
run;
*remove model_d6 and d7 for collinearity;
proc reg data = new_ford;
title 'full model';
model new_price=year new_mileage new_tax mpg new_engineSize model_d1 model_d2 model_d3 model_d4 model_d5 
	model_d8  model_d9 model_d10 model_d11 model_d12  model_d13 model_d14 model_d15 model_d16 model_d17 
	  model_d21 transmission_d1 transmission_d2 fuelType_d1 fuelType_d2 fuelType_d3/vif tol;
run;
*selecton method;
proc reg data = new_ford;
title 'full model';
model new_price=year new_mileage new_tax mpg new_engineSize model_d1 model_d2 model_d3 model_d4 model_d5 
	model_d8  model_d9 model_d10 model_d11 model_d12  model_d13 model_d14 model_d15 model_d16 model_d17 
	  model_d21 transmission_d1 transmission_d2 fuelType_d1 fuelType_d2 fuelType_d3/selection=stepwise;
*cv fold;
*cross validation full model with train/test set at 80/20;
title '5-fold CV with Full Model Stepwise at 80/20';
proc glmselect data= new_ford
plots= (asePlot Criteria);
partition fraction (test=0.20);
model new_price=year new_mileage new_tax mpg new_engineSize model_d1 model_d2 model_d3 model_d4 model_d5 
	model_d8  model_d9 model_d10 model_d11 model_d12  model_d13 model_d14 model_d15 model_d16 model_d17 
	  model_d21 transmission_d1 transmission_d2 fuelType_d1 fuelType_d2 fuelType_d3/
selection=stepwise (stop=cv) cvMethod=split(5) cvDetails=all;
run;
*creates a next dataset bike_train_test_set, split data into train and test sets;
*selected =1 -> Train
 selected =0 -> Test;
title 'Test and Train Sets for bike count';
proc surveyselect data = new_ford
out = ford_train_test_set seed=495857
samprate = 0.80 outall;
run;
*creates new variable new_bike_count for training set, and =NA;
data ford_train_test_set;
set ford_train_test_set;
if selected then price1 = new_price;
run;
proc print data = ford_train_test_set;
run;

title 'validation - test set: Model 1';
proc reg data = ford_train_test_set;
*Model 1: Stepwise;
model new_price=year new_mileage new_tax mpg new_engineSize model_d1 model_d2 model_d4 model_d9 model_d11 model_d12 model_d13 model_d14 model_d15 model_d17 model_d21 transmission_d2 fuelType_d3;
output out=outm1 (where=(price1=.)) p=yhat;
run;

*test;
*summarizes the results of cross-validatin for model 1;
title 'difference between obs and pred in test set M1';
data outm1_sum;
set outm1;
d=new_price-yhat;
absd = abs(d);
run;

*compute predictive stats: rmse and mae;
proc summary data =outm1_sum;
var d absd;
output out = outm1_stats std (d)=rmse mean(absd)=mae;
run;
proc print data =outm1_stats;
title 'Validation stats for model 1';
run;
*computes correlation of obs and pred in test set;
proc corr data = outm1;
var new_price yhat;
run;
