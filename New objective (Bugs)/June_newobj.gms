
$ontext
Title Optimization model for Glen Canyon Dam releases to favor Bugs population. (June 2018)

###################################
Created By: Moazzam Ali Rind
Email: moazzamalirind@gmail.com

Created : 4/24/2019
Last updated: 2/26/2020

Description: Daily High flow & low flow release concept with an aim to minimize the difference between two daily flows.
             Whereas, the overall objective of the model is to get the daily flow release outer bounds which is not only favourable for bugs
             but also accounts the hydropower objective to its best. Conversely, the total monthly release amount is maintained same as per colorado river compact or Constrainted amount.

######################################

#new Metric for Bug Suitability

$offtext

****Model code:

Set

          d                             days in June
          p                             time period during a day /pLow "Low flow period",pHigh "High flow period"/
          f                             objective functions/BugIndex "Bug Flow objective", Hydro "Hydropower Objective"/
          All_cases                     Joining All senarios in one set i.e. Extreme points cases and intermediate point cases/Min,sc1 * sc6,Max/
          tot_vol                       Total montly release volume (acre-ft)/V1*V5/
          Scen(All_cases)               objective function scenario values /sc1 * sc6/
          modpar                        Saving model parameter for each of the solutions for each of the scenario/ ModStat "Model Statistics", SolStat "solve Statistics"/
          Ext_points                    Defining Extreme Points/Min, Max/
;

*creating a copy of set f as f2.
Alias (f,f2);


*======================================
*Parameters
*======================================

PARAMETERS

FtoUse(f)                               Objective functions to use (1=yes 0=no)
FLevel(f)                               Right hand side of constraint when the objective is constrained or value of constrainted objective

FStore(f2,f,tot_vol)                    Storing objective function values over different scenarios of f
XStore(f2,d,tot_vol,p)                  Store Energy Generated at extreme values over different scenarios (MWH)
RStore(f2,d,tot_vol,p)                  Store Release values at extreme values over different scenarios  (cfs)
Sstore(f2,d,tot_vol)                    Store Storage Values over different scenarios (ac-ft)


Scen_store(f,Scen,tot_vol)              Store objective function values under different senarios
ReleaseSave(tot_vol,Scen,d,p)           Saving release from each of the senarios  (cfs)
EnergyGen_save(tot_vol,Scen,d,p)       Saving Energy Generated from each of the senarios (MWH)
Storage_Save(tot_vol,Scen,d)           Saving Storage values from each of the senarios(ac-ft)

ExtModeL_Stat(tot_vol,f2,modpar)        Extreme Points Model Results for the scenarios
ModelResults(tot_vol,Scen,modpar)      Model Results for the scenarios

MinVal(tot_vol,f)                      Extracting the Minimum objectives values
MaxVal(tot_vol,f)                      Extracting the Maximum objectives values

MinVal_a(tot_vol)                      Extracting the Minimum objective value (BugIndex objective in this case)
MaxVal_a(tot_vol)                      Extracting the Maximum objective value (BugIndex objective in this case)

initstorage                           Initial reservoir storage 1st June 2018 (acre-ft)
maxstorage                            Reservoir capacity (acre-ft)
minstorage                            Minimum reservoir storage to maintain hydropower level(acre-ft)
Inflow(d)                             Inflow to reservoir (cfs)
maxRel                                Maximum release in a day d at any timeperiod p(cfs)
minRel                                Minimum release in a day d at any timeperiod p(cfs)
evap                                  evaporation (ac-ft per day Considered constant throughout the month
EnergyRate(p)                         Energy revenue ($ per MWH) /pLow 24.56, pHigh 62.21/

*Obj_dir(f)                            To set objective directions inorder to set the maximization and minimization of the objectives /BugNew 1,Hydro 1/

Duration(p)                           Duration of period (hours)
Vol_monthlyrelease(tot_vol)           Different Total volumes of water to be released in the month i.e. June2018 in presented case (acre-ft)/V1 700000,V2 793857.12,V3 900000,V4 1000000,V5 1100000/
TotMonth_volume                       To represent total monthly volume (acre-ft)

Levels(f,tot_vol,Scen)                Selected objective function levels

;


Duration("pLow")= 8;
* low period weightage in a day(08 Hours or 8 by 24 i.e:0.33 of day)

Duration("pHigh")= 16;
*  High period weightage in a day( 16 Hours or 16 by 24 i.e:0.67 of day)

*===================================================
* Read data from Excel
*===================================================
$CALL GDXXRW.EXE input=June2018.xls output=newmetric_June18.gdx set=d rng=day!A1 Rdim=1  par=Inflow rng=inflow!A1 Rdim=1  par=initstorage rng=initstorage!A1 Rdim=0  par=maxstorage rng=maxstorage!A1 Rdim=0   par=minstorage rng=minstorage!A1 Rdim=0  par=maxRel rng=maxRel!A1 Rdim=0 par=minRel rng=minRel!A1 Rdim=0  par=evap rng=evap!A1 Rdim=0
*Write the input Data into a GDX file
$GDXIN newmetric_June18.gdx

* parameters and input data from the GDX file into the model
$LOAD d
$LOAD inflow
$LOAD initstorage
$LOAD maxstorage
$LOAD minstorage
$LOAD maxRel
$LOAD minRel
$LOAD evap

*Close the GDX file
$GDXIN

Display d,inflow, initstorage, maxstorage, minstorage, maxRel, minRel, evap, p, Duration, Scen;
*===============================================
SCALAR
conver                        conversion factor from cfs to ac-ft per day /1.98348/
factor_foracftperHr           conversion factor from cfs to ac-ft per hour (0.0014*60)/0.084/
Numdays                       Number of days in month/30/
Num_of_timesteps              Total Number of timesteps used /60/
Daily_Ramprate                Allowable daily ramp rate (cfs)/8000/


VARIABLES

ObjectiveVal(f)               Objective functions calculation
CombineObjective              Combine objective functions for each senario

Positive Variables
storage(d)                    reservoir storage on any day d (acre-ft)
release(d,p)                  reservoir release on any day d in any period p (cfs)
*Energyrate_vari(d,p)          Rate of hydropower with respect to day and period of day ($ per MWH)
Energy_Gen(d,p)               Hydropower Generated at a each time step (MWH)
ReleaseVol(d,p)               volume of water released per time step(acre-ft)
* DER - I suggest to rename Threshold to MinRelease (more clear)
Threshold                     Minimum release value of the hydrograph
* DER - unclear definition. I think better IsMinFlow   (1= flow value is very close to Minimum release value, 0 = not close).
*                                           This is defined as continuous variable to avoid having to solve a MINLP
*
check(d,p)                    function values
;



EQUATIONS
*AND CONSTRAINTS

EQ1__ResMassBal(d)           Reservoir mass balance (acre-ft)
EQ2__reqpowerstorage(d)      The minimum storage equivalent to reservoir level required for hydropower generation (acre-ft)
EQ3__maxstor(d)              res storage max (acre-ft)
EQ4__MaxR(d,p)               Max Release (cfs)
EQ5__MinR(d,p)               Min Release  (cfs)
*EQ6_Energyrate(d,p)          Defination of Energy rate as per period of day and day of week ($ per MWH)
EQ7_Rampup_rate(d,p)         Constraining the daily ramp up rate between the timesteps(cfs) ..(with in same day)
EQ7a_Rampdown_rate(d,p)      Constraining the daily ramp down rate between the timesteps(cfs) ..(with in same day)
EQ7b_Rampup_ratenext(d,p)    Constraining the daily ramp up rate between the last timestep of current day and next timestep for next day(cfs)
EQ7c_Rampdown_ratenext(d,p)  Constraining the daily ramp down rate between the last timestep of current day and next timestep for next day(cfs)
EQ7d_FlowVolume(d,p)         volume of water released per time step (acre-ft)
EQ8__Monthtlyrel             Constraining Total monthly volume of water released in "May" as per WAPA information(acre-ft)
EQ9_Threshold                Minimun release value within the hydrograph(cfs)
EQ9a_check(d,p)              forcing model to get the desired relase value(cfs)
EQ10_function(f)             Fitting Arctangent Function to the release values (New Bug Metric)
EQ12_EnergyGen(d,p)          Amount of energy generated in each time step (MWH)
EQ12a_EnergyGen_Max(d,p)     Maximum Energy Generation Limit of the Glen Caynon Dam(MW)for Low Period
EQ13_EnergyRevenue(f)        Total monthly Hydropower Revenue generated ($)
EQ15_CombinedObjectives      Defining all objective in single equation
;

*------------------------------------------------------------------------------*

EQ1__ResMassBal(d)..         storage(d) =e= initstorage$(ord(d)eq 1)+ storage(d-1)$(ord(d)gt 1)+ (inflow(d)*conver)- sum(p,ReleaseVol(d,p))-evap;
EQ2__reqpowerstorage(d)..    storage(d) =g= minstorage;
EQ3__maxstor(d)..            storage(d)=l= maxstorage;
EQ4__MaxR(d,p)..             release(d,p)=l= maxRel;
EQ5__MinR(d,p)..             release(d,p)=g= minRel;
*EQ6_Energyrate(d,p)..        Energyrate_vari(d,p)=e= EnergyRate(p);
*Equation 6 is just making the energy rate same for all days. However in future we can change it as per different rates for different days.

EQ7_Rampup_rate(d,p)..          release(d,"pHigh")-release(d,"pLow")=l=Daily_Ramprate;
EQ7a_Rampdown_rate(d,p)..       release(d,"pHigh")-release(d,"pLow")=g= -1*Daily_Ramprate ;
EQ7b_Rampup_ratenext(d,p)$(ord(d) lt Numdays)..     release(d,"pHigh")-release(d+1,"pLow")=l=Daily_Ramprate;
EQ7c_Rampdown_ratenext(d,p)$(ord(d) lt Numdays)..   release(d,"pHigh")-release(d+1,"pLow")=g= -1*Daily_Ramprate;

EQ7d_FlowVolume(d,p)..       ReleaseVol(d,p) =e= release(d,p)*factor_foracftperHr*Duration(p);
EQ8__Monthtlyrel..           sum(d,sum(p,ReleaseVol(d,p)))=e= TotMonth_volume;
*EQ8_  constraining the overall monthly released volume..

* EQ9_ constraining the threshold value to be the minimimum value of the hydrograph
EQ9_Threshold..              Threshold =e= smin((d,p),release(d,p));

* DER - Needs a definition and explanation. Also why round? Remove so check will be a continous variable.
*EQ9a_check(d,p)..           check(d,p)=e= round((-1/2)*(arctan(((release(d,p)-Threshold)-0.65)/0.001)/(pi/2)+1)+1,2);
*EQ9a_check(d,p)..           check(d,p)=e= ((-1/2)*(arctan(((release(d,p)-Threshold)-0.65)/0.001)/(pi/2)+1)+1);
* Or more explicitly because we are already using DNLP. If greater than a 300 cfs deviation from the threshold
 EQ9a_check(d,p)..           check(d,p)=e= ifThen(release(d,p)-Threshold < 400,1,0);


* DER - Needs a clear comment: counting the number of periods where flow is at/near the minimum flow.
EQ10_function(f)$(ord(f) eq 1)..  ObjectiveVal(f)=e= sum((d,p),check(d,p));
*EQ10_ introducing Tangent function

EQ12_EnergyGen(d,p)..                         Energy_Gen(d,p)=e= release(d,p)*Duration(p)*0.03715;
* Energy generation formula used in wapa Execl model..


EQ12a_EnergyGen_Max(d,p)..                    Energy_Gen(d,p)=l= 1320*Duration(p);
*Maximum Energy Generation capacity of GCD (MWH).. Source https://www.usbr.gov/uc/rm/crsp/gc/

EQ13_EnergyRevenue(f)$(ord(f) eq 2)..         ObjectiveVal(f)=e= round(sum((d,p),Energy_Gen(d,p)*EnergyRate(p)));
**EQ13_HyrdroPower objective
*EQ13_EnergyRevenue(f)$(ord(f) eq 2)..         ObjectiveVal(f)=e= sum((d,p),(-1/2)*(arctan(((release(d,p)-Threshold)-0.65)/0.001)/(pi/2)+1)+1);

EQ15_CombinedObjectives..                     CombineObjective =e= sum(f,FtoUse(f)*ObjectiveVal(f));


***************************************************
******
***************************************************
*------------------------------------------------------------------------------*
*Initial values just to run simulation (Random Pick)... One might need to pick other numbers if he/she founds that some of the runs are locally infeasbile on their intial values.
release.L(d,p) = 8000;



$ontext
******************************************************
*****Model to disclose the Binding and Shadow Values
******************************************************


PARAMETERS
*For shadow values Only, these parameters are introduced ...


EQ1__ResMassBal_m(d,tot_vol)           Reservoir mass balance (acre-ft)
EQ2__reqpowerstorage_m(d,tot_vol)      The minimum storage equivalent to reservoir level required for hydropower generation (acre-ft)
EQ3__maxstor_m(d,tot_vol)              res storage max (acre-ft)
EQ4__MaxR_m(d,p,tot_vol)               Max Release (cfs)
EQ5__MinR_m(d,p,tot_vol)               Min Release  (cfs)
EQ6_Energyrate_m(d,p,tot_vol)          Defination of Energy rate as per period of day and day of week ($ per MWH)
EQ7_Rampup_rate_m(d,p,tot_vol)         Constraining the daily ramp up rate between the timesteps(cfs) ..(with in same day)
EQ7a_Rampdown_rate_m(d,p,tot_vol)      Constraining the daily ramp down rate between the timesteps(cfs) ..(with in same day)
EQ7b_Rampup_ratenext_m(d,p,tot_vol)    Constraining the daily ramp up rate between the last timestep of current day and next timestep for next day(cfs)
EQ7c_Rampdown_ratenext_m(d,p,tot_vol)  Constraining the daily ramp down rate between the last timestep of current day and next timestep for next day(cfs)
EQ7d_FlowVolume_m(d,p,tot_vol)         volume of water released per time step (acre-ft)
EQ8__Monthtlyrel_m(tot_vol)            Constraining Total monthly volume of water released in "April" as per WAPA information(acre-ft)
EQ9_Threshold_m(tot_vol)               Minimun release value within the hydrograph(cfs)
*EQ9_Avgrelease_m(tot_vol)              Average Monthly release (cfs)
*EQ10_function_m(f,tot_vol)              Fitting Arctangent Function to the release values
*EQ10_Standarddev_m(tot_vol)            Standard Devation over month.
*EQ11_Hydropeakingindex_m(f,tot_vol)    Hydropeaking index value over month.
EQ12_EnergyGen_m(d,p,tot_vol)          Amount of energy generated in each time step (MWH)
EQ12a_EnergyGen_Max_m(d,p,tot_vol)     Maximum Energy Generation Limit of the Glen Caynon Dam(MW)for both Period
EQ13_EnergyRevenue_m(f,tot_vol)        Total monthly Hydropower Revenue generated ($)
*EQ14_ReleaseSim_m(d,p,tot_vol)         Setting release values as predefined for simulation(cfs)
EQ15_CombinedObjectives_m(tot_vol)     Defining all objective in single equation

$offtext

*------------------------------------------------------------------------------*    *------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*    *------------------------------------------------------------------------------*
Parameters
Extreme_Points(f,tot_vol,Ext_points)    Saving Extreme points for All Volume Senarios
Obj_Save(f,tot_vol,All_cases)           Saving Objectives values for all senarios under one parameter

;

***************************************************
******Extreme points Model
****************************************** ********

*MODEL ExtremePt Finding extreme points using the NLP under each of the total Volume searios .


MODEL ExtremePt Find extreme points by using  DNLP/ALL/ ;

loop((tot_vol,f2),
*Ignore all the objectives
   FtoUse(f) = 0;
*  Only consider the current objective
   FtoUse(f2) = 1;
   Display FtoUse;
   TotMonth_volume= Vol_monthlyrelease(tot_vol);
*  DER - Start with a constant release for every period and day
   release.l(d,p) = TotMonth_volume/(factor_foracftperHr*24*30);
*  DER - also initialize the check variable!
   check.l(d,p) = 1;

SOLVE ExtremePt USING dnlp maximize CombineObjective;

   FStore(f2,f,tot_vol)= ObjectiveVal.L(f);
   XStore(f2,d,tot_vol,p) = Energy_Gen.L(d,p);
   RStore(f2,d,tot_vol,p)=release.L(d,p);
   Sstore(f2,d,tot_vol)=storage.L(d);
   ExtModeL_Stat(tot_vol,f2,"SolStat") = ExtremePt.solvestat;
   ExtModeL_Stat(tot_vol,f2,"ModStat") = ExtremePt.modelstat;
   DISPLAY FStore,XStore,RStore,Sstore;
);



$ontext
MODEL ExtremePt1 Find extreme points by using  DNLP/ALL/ ;
*Ignore all the objectives
   FtoUse(f) = 0;
*  Only consider the current objective
   FtoUse(f2) = 1;
   FtoUse("BugIndex") = 1;
   TotMonth_volume= Vol_monthlyrelease("V1");

SOLVE ExtremePt1 USING dnlp MAXIMIZING CombineObjective;

   FStore("BugIndex","BugIndex",tot_vol)= ObjectiveVal.L("BugIndex");
   FStore("BugIndex","Hydro",tot_vol)= ObjectiveVal.L("Hydro");
   FStore("BugIndex",f,tot_vol)= ObjectiveVal.L(f);
   XStore("BugIndex",d,tot_vol,p) = Energy_Gen.L(d,p);
   RStore("BugIndex",d,tot_vol,p)=release.L(d,p);
   Sstore("BugIndex",d,tot_vol)=storage.L(d);
   ExtModeL_Stat(tot_vol,"BugIndex","SolStat") = ExtremePt1.solvestat;
   ExtModeL_Stat(tot_vol,"BugIndex","ModStat") = ExtremePt1.modelstat;


MODEL ExtremePt2 Find extreme points by using  DNLP/ALL/ ;
*Ignore all the objectives
   FtoUse(f) = 0;
*  Only consider the current objective
   FtoUse(f2) = 1;
   FtoUse("Hydro") = 1;
   TotMonth_volume= Vol_monthlyrelease("V1");

SOLVE ExtremePt1 USING dnlp MAXIMIZING CombineObjective;

   FStore("Hydro","BugIndex",tot_vol)= ObjectiveVal.L("BugIndex");
   FStore("Hydro","Hydro",tot_vol)= ObjectiveVal.L("Hydro");
   FStore("Hydro",f,tot_vol)= ObjectiveVal.L(f);
   XStore("Hydro",d,tot_vol,p) = Energy_Gen.L(d,p);
   RStore("Hydro",d,tot_vol,p)=release.L(d,p);
   Sstore("Hydro",d,tot_vol)=storage.L(d);
   ExtModeL_Stat(tot_vol,"Hydro","SolStat") = ExtremePt2.solvestat;
   ExtModeL_Stat(tot_vol,"Hydro","ModStat") = ExtremePt2.modelstat;

$offtext

*Finding values minimum and maximum values
loop((tot_vol,f),
*Saving both objectives extreme values
MinVal(tot_vol,f) = smin(f2,FStore(f2,f,tot_vol));
MaxVal(tot_vol,f) = smax(f2,FStore(f2,f,tot_vol));

*Merging both Extreme point in one Parameter for easier results post processing.
Extreme_Points(f,tot_vol,"Min")= MinVal(tot_vol,f);
Extreme_Points(f,tot_vol,"Max")= MaxVal(tot_vol,f);

Extreme_Points(f,tot_vol,EXT_points) = Extreme_Points(f,tot_vol,EXT_points) + EPS;

*Sorting just the values for Bugindex objective because in this presented model Bugindex objective is taken as constrain. However, one can easily get values for both functions by replacing BugIndex with "f" Or if only values of other objective is required just replace BugIndex with Hydro in Levels equation.
MinVal_a(tot_vol)= MinVal(tot_vol,"BugIndex");
MaxVal_a(tot_vol)= MaxVal(tot_vol,"BugIndex");

Display MinVal,MaxVal,MinVal_a,MaxVal_a,Extreme_points;

*Finding the intermediate levels between Extreme points
Levels("BugIndex",tot_vol,Scen)= MinVal_a(tot_vol)+((MaxVal_a(tot_vol)-MinVal_a(tot_vol))*(ord(scen)/(card(scen)+1)));
);


$ontext
* Just disclosing the Binding and Shadow Values
EQ1__ResMassBal_m(d,tot_vol)= EQ1__ResMassBal.m(d);
EQ2__reqpowerstorage_m(d,tot_vol)= EQ2__reqpowerstorage.m(d);
EQ3__maxstor_m(d,tot_vol)= EQ3__maxstor.m(d);
EQ4__MaxR_m(d,p,tot_vol)= EQ4__MaxR.m(d,p);
EQ5__MinR_m(d,p,tot_vol)= EQ5__MinR.m(d,p);
EQ6_Energyrate_m(d,p,tot_vol)= EQ6_Energyrate.m(d,p);
EQ7_Rampup_rate_m(d,p,tot_vol)= EQ7_Rampup_rate.m(d,p);
EQ7a_Rampdown_rate_m(d,p,tot_vol)= EQ7a_Rampdown_rate.m(d,p);
EQ7b_Rampup_ratenext_m(d,p,tot_vol)= EQ7b_Rampup_ratenext.m(d,p)$(ord(d) lt Numdays);
EQ7c_Rampdown_ratenext_m(d,p,tot_vol)= EQ7c_Rampdown_ratenext.m(d,p)$(ord(d) lt Numdays);
EQ7d_FlowVolume_m(d,p,tot_vol)= EQ7d_FlowVolume.m(d,p);
EQ8__Monthtlyrel_m(tot_vol) = EQ8__Monthtlyrel.m;
EQ9_Threshold_m(tot_vol)=EQ9_Threshold.m;
*EQ9_Avgrelease_m(tot_vol)= EQ9_Avgrelease.m ;
*EQ10_function_m(f,tot_vol)=EQ10_function_m(f)$(ord(f) eq 1);
*EQ10_Standarddev_m(tot_vol) = EQ10_Standarddev.m ;
*EQ11_Hydropeakingindex_m(f,tot_vol)=EQ11_Hydropeakingindex.m(f)$(ord(f) eq 1) ;
EQ12_EnergyGen_m(d,p,tot_vol)= EQ12_EnergyGen.m(d,p);
EQ12a_EnergyGen_Max_m(d,p,tot_vol)= EQ12a_EnergyGen_Max.m(d,p);
EQ13_EnergyRevenue_m(f,tot_vol)= EQ13_EnergyRevenue.m(f)$(ord(f) eq 2);
*EQ14_ReleaseSim_m(d,p,tot_vol)= EQ14_ReleaseSim.m(d,p)$Use_Sim(d,p);
EQ15_CombinedObjectives_m(tot_vol) = EQ15_CombinedObjectives.m ;
);
$offtext




*------------------------------------------------------------------------------*  *------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*  *------------------------------------------------------------------------------*

*This section constrains one objective to a certain defined level
EQUATION
ObjAsCon(f)          Objective function as constraint f(x) = FLevel;

*The objective as constraint is greater or less or equal than the level set for that objective
ObjAsCon(f)$(1 - FtoUse(f))..        ObjectiveVal(f)=e=FLevel(f);

MODEL ObjAsConstraint Single-objective model with other objectives constrained /ALL/;

*constraining bugindex and maximizing hydropower
loop((Scen,tot_vol),
     FtoUse(f) = 0;
     FtoUse("Hydro") =1;
     TotMonth_volume=Vol_monthlyrelease(tot_vol);
*Set a level for the Bugindex objective
     FLevel(f)=Levels(f,tot_vol,Scen);
release.L(d,p) = 8000;

     SOLVE ObjAsConstraint USING DNLP MAXIMIGING CombineObjective;
     Scen_store(f,Scen,tot_vol)= ObjectiveVal.L(f);
     ReleaseSave(tot_vol,Scen,d,p)= release.L(d,p);
     EnergyGen_save(tot_vol,Scen,d,p)= Energy_Gen.L(d,p);
     Storage_Save(tot_vol,Scen,d)=storage.L(d);
     ModelResults(tot_vol,Scen,"SolStat") = ObjAsConstraint.solvestat;
     ModelResults(tot_vol,Scen,"ModStat") = ObjAsConstraint.modelstat;
     DISPLAY Scen_store, ReleaseSave,EnergyGen_save,Storage_Save;

*  Merge All objectives results in one parameter.
     Obj_Save(f,tot_vol,"sc1")= Scen_store(f,"sc1",tot_vol);
     Obj_Save(f,tot_vol,"sc2")= Scen_store(f,"sc2",tot_vol);
     Obj_Save(f,tot_vol,"sc3")= Scen_store(f,"sc3",tot_vol);
     Obj_Save(f,tot_vol,"sc4")= Scen_store(f,"sc4",tot_vol);
     Obj_Save(f,tot_vol,"sc5")= Scen_store(f,"sc5",tot_vol);
     Obj_Save(f,tot_vol,"sc6")= Scen_store(f,"sc6",tot_vol);
     Obj_Save("BugIndex",tot_vol,"Min")= Extreme_Points("BugIndex",tot_vol,"Min");
     Obj_Save("BugIndex",tot_vol,"Max")=Extreme_Points("BugIndex",tot_vol,"Max");
     Obj_Save("Hydro",tot_vol,"Min")= Extreme_Points("Hydro",tot_vol,"Min");
     Obj_Save("Hydro",tot_vol,"Max")= Extreme_Points("Hydro",tot_vol,"Max");
);


*------------------------------------------------------------------------------*
* Dump all input data and results to a GAMS gdx file
Execute_Unload "newmetric_June18.gdx";
* Dump the gdx file to an Excel workbook
Execute "gdx2xls newmetric_June18.gdx"
