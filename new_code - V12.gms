
$ontext
Title Optimization model for Glen Canyon Dam releases to favor Bugs population




###################################
Created By: Moazzam Ali Rind
Email: moazzamalirind@gmail.com

Created : 4/24/2019
Last updated: 6/21/2019

Description: Daily High flow & low flow release concept with an aim to minimize the difference between two daily flows.
             Whereas, the overall objective of the model is to get the daily flow release outer bound which is not only favourable for bugs
             but also accounts the hydropower objective to its best. Conversely, the total monthly release amount is maintained same as per colorado river compact .

######################################

$offtext

****Model code:

Set

          d             days in May
          p             time period during a day /pHigh "High flow period",pLow "Low flow period"/
          f             objective functions/BugIndex "Bug Flow objective", Hydro "Hydropower Objective"/
          Scen          objective function senario values /sc1 * sc12/

;
*Define a second name for the set f -- f2.
Alias (f,f2);

*======================================
*Parameters
*======================================

PARAMETERS

FtoUse(f)                    Objective functions to use (1=yes 0=no)
FLevel(f)                    Right hand side of constraint when the objective is constrained
FStore(f2,f)                 Storing objective function values over different scenarios of f
XStore(f2,d)                 Store decision variable values over different scenarios of f
FStore2(f2,f)                Storing objective function values over different scenarios of f
XStore2(f2,d)                Store decision variable values over different scenarios of f

Scen_store(f2,Scen)          Store objective function values under different senario values
Scen_store2(f2,Scen)          Store objective function values under different senario values

initstorage                  Initial reservoir storage on apr 30th 2018 (acre-ft)
maxstorage                   Reservoir capacity (acre-ft)
minstorage                   Minimum reservoir storage to maintain hydropower level(acre-ft)
Inflow(d)                    Inflow to reservoir (cfs)
maxRel                       Maximum release in a day d at any timeperiod p(cfs)
minRel                       Minimum release in a day d at any timeperiod p(cfs)
evap                         evaporation (ac-ft per day Considered constant throughout the month
EnergyRate(p)                Energy revenue ($ per MWH) /pHigh 60, pLow 25/
Final_Release(d,p)           Final release output values (cfs)
Duration(p)                  Duration of period (hours)
Use_Sim(d,p)                 Binary parameter which will specify simulation flow for day and period (1=yes 0=no)

Levels(f,Scen)               Selected objective function levels(i.e. BugIndex)/BugIndex .sc1  0, BugIndex .sc2  0.05, BugIndex .sc3  0.07,BugIndex .sc4 0.1,BugIndex .sc5 0.15,BugIndex .sc6 0.2,BugIndex .sc7 0.25,BugIndex .sc8 0.3,BugIndex .sc9 0.4,BugIndex .sc10 0.5,BugIndex .sc11 0.6,BugIndex .sc12 0.659/

;

Duration("pHigh")= 13;
*phigh_weightage/duration              High period weightage in a day(13 by 24 hrs. i.e:0.542 of day)
Duration("pLow")= 11;
*plow_weightage/duration               low period weightage in a day(11 by 24 hrs. i.e:0.458 of day)



*===================================================
* Read data from Excel
*===================================================
$CALL GDXXRW.EXE input=Input.xlsx output= Bugflow_releases.gdx set=d rng=day!A1 Rdim=1  par=Inflow rng=inflow!A1 Rdim=1  par=initstorage rng=initstorage!A1 Rdim=0  par=maxstorage rng=maxstorage!A1 Rdim=0   par=minstorage rng=minstorage!A1 Rdim=0  par=maxRel rng=maxRel!A1 Rdim=0 par=minRel rng=minRel!A1 Rdim=0  par=evap rng=evap!A1 Rdim=0

*Write the input Data into a GDX file
$GDXIN Bugflow_releases.gdx

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

Display d,inflow, initstorage, maxstorage, minstorage, maxRel, minRel, evap,p,Duration, Levels,Scen;
*===============================================
SCALAR
conver                        conversion factor from cfs to ac-ft per day /1.98348/
factor_foracftperHr           conversion factor from cfs to ac-ft per hour /0.08/
*factor_HptoKWH                conversion factor from Horse Power to KWH (0.746 by 550)/0.00098/
*KWHtoMWH_factor               conversion factor from KWH to MWH /0.001/
*Unitweight_Water              Specific weight of Water(Lb per Ft3)/62.43/
factor_powerMW                Factor required to get results in MW with English Units /11810/
Numdays                       Number of days in month/31/
Elev_Head                     Elevation Head at Glen Canyon Dam /432.54/
Efficiency                    Efficieny of power turbines at GCD /0.9/
Num_of_timesteps              Total Number of timesteps used /62/
Vol_monthlyrelease            Total volume of water to be released in the month i.e. may 2018 in presented case (acre-ft)/900000/

VARIABLES

ObjectiveVal(f)               Objective functions calculation
CombineObjective              Combine objective functions for each senario

Positive Variables
storage(d)                    reservoir storage on any day d (acre-ft)
release(d,p)                  reservoir release on any day d in any period p (cfs)
Avgrelease                    Average release value for the whole month (cfs)
standarddev                   Standard deviation of releases over the month
Energyrate_vari(d,p)          Rate of hydropower with respect to day and period of day ($ per MWH)
Energy_Gen(d,p)               Hydropower Generated at a each time step (MWH)
FlowVol(d,p)                  volume of water released per time step(acre-ft)
Rel_vals(d,p)                 Defined release value for simulation with respect to day and period of day (cfs)
;





*Initialize
Use_Sim(d,p) = 0;
Rel_vals.L(d,p)= 0;
*Set weekend days to 1
Use_Sim(d,p) $((ord(d)>= 5  and ord(d)<= 6)
                    OR(ord(d)>= 12 and ord(d)<= 13)
                   OR (ord(d)>=19 and ord(d)<=20)
                  OR (ord(d)>=26 and ord(d)<=28)) = 1;
*Set weekend flows to 9000 cfs + 28 may which is also a holiday because of memorial day.
Rel_vals.L(d,p)$Use_Sim(d,p) = 9000;

EQUATIONS
*AND CONSTRAINTS

EQ1__ResMassBal(d)           Reservoir mass balance (acre-ft)
EQ2__reqpowerstorage(d)      The minimum storage equivalent to reservoir level required for hydropower generation (acre-ft)
EQ3__maxstor(d)              res storage max (acre-ft)
EQ4__MaxR(d,p)               Max Release (cfs)
EQ5__MinR(d,p)               Min Release  (cfs)
EQ6_Energyrate(d,p)          Defination of Energy rate as per period of day and day of week ($ per MWH)
EQ7_FlowVolume(d,p)          volume of water released per time step (acre-ft)
EQ8__Mayrel                  Constraining Total monthly volume of water released in "May" as per WAPA information(acre-ft)
EQ9_Avgrelease               Average Monthly release (cfs)
EQ10_Standarddev             Standard Devation over month.
EQ11_Hydropeakingindex(f)    Hydropeaking index value over month.
EQ12_EnergyGen(d,p)          Amount of energy generated in each time step (MWH)
EQ13_EnergyRevenue(f)        Total monthly Hydropower Revenue generated ($)
*EQ14_Simvalues(d,p)          Release values for simulation model with respect to day and periods of day(cfs)
EQ14_ReleaseSim(d,p)         Setting release values as predefined for simulation(cfs)
*EQ15__flowLow(d,p)          Low flow release condition or defination(cfs)
EQ16_CombinedObjectives     Defining all objective in single equation
;


*------------------------------------------------------------------------------*

EQ1__ResMassBal(d)..         storage(d) =e= initstorage$(ord(d)eq 1)+ storage(d-1)$(ord(d)gt 1)+ (inflow(d)*conver)- sum(p,FlowVol(d,p))-evap;
EQ2__reqpowerstorage(d)..    storage(d) =g= minstorage;
EQ3__maxstor(d)..            storage(d)=l= maxstorage;
EQ4__MaxR(d,p)..             release(d,p)=l= maxRel ;
EQ5__MinR(d,p)..             release(d,p)=g= minRel;
EQ6_Energyrate(d,p)..        Energyrate_vari(d,p)=e= EnergyRate(p);
*Equation 6 is just making the energy rate same for all days. However in future we can change it as per different rates for different days.

EQ7_FlowVolume(d,p)..        FlowVol(d,p) =e= release(d,p)*factor_foracftperHr*Duration(p);
EQ8__Mayrel..                sum(d,sum(p,FlowVol(d,p)))=e=Vol_monthlyrelease;
*EQ8b_  constraining the overall monthly released volume..
EQ9_Avgrelease..             Avgrelease=e= sum(d,sum(p,release(d,p))/2)/Numdays;
* Equation 9 is calculating the monlthy average release from the reservior. (Mathematical details of RHS: First summing daily two values and dividing by 2-for average- and then summing values for all days and dividing by total number of days i.e: 31 in May.
EQ10_Standarddev..           standarddev=e= sqrt[sum(d,sum{p,power(release(d,p)- Avgrelease,2)})/Num_of_timesteps];
* Equation 10 is calculating the monlthy average standard devation. (Mathematical details of RHS:   as per formula of standard dev i.e: sqrt((summation (value - average)^2)/number of values).. So same is applied here with the help of power function for squaring.

EQ11_Hydropeakingindex(f)$(ord(f) eq 1)..     ObjectiveVal(f)=e= -1*(standarddev/Avgrelease);
*EQ 11 is calculating hydropeaking index value for the whole month. Whereas, the -1 is added to switch the direction of objective (i.e. inorder to minimize the Bug objective rather miximizing it).

*EQ12_EnergyGen(d,p)..                         Energy_Gen(d,p)=e= (release(d,p)*Unitweight_Water*Elev_Head *Efficiency*factor_HptoKWH*KWHtoMWH_factor)*Duration(p);
*https://www.quora.com/What-is-formula-of-hydroelectric-power-generation

EQ12_EnergyGen(d,p)..                         Energy_Gen(d,p)=e= ((release(d,p)*Elev_Head *Efficiency)/factor_powerMW)*Duration(p);
*formula Source http://rivers.bee.oregonstate.edu/book/export/html/6


EQ13_EnergyRevenue(f)$(ord(f) eq 2)..         ObjectiveVal(f)=e= sum((d,p),Energy_Gen(d,p)*EnergyRate(p));
**EQ13_HyrdroPower objective

*EQ15__flowLow(d,p)..          release(d,p)$(ord(p) eq 2)=L= 10000;
* EQEQ15__flowLow is  introducing an addtional constraint for low flow amount (incase the high and low values are coming near to each other)

EQ16_CombinedObjectives..                     CombineObjective=e= sum(f,FtoUse(f)*ObjectiveVal(f));



***************************************************
******Simulation Model
****************************************** ********
*------------------------------------------------------------------------------*
*Eqauation 14 is introducing the steady bug flow on weekneds only. while allowing the model to calculate release for other days as per formulation.
*Assuming the month of may 2018 (i.e. starting day will be tuesday and month ends on thursday).
EQ14_ReleaseSim(d,p)$Use_Sim(d,p)..                 release(d,p)=e=Rel_vals(d,p);


*EQ14_ReleaseSim(d,p)$((ord(d)>= 5  and ord(d)<= 6)
*                   OR(ord(d)>= 12 and ord(d)<= 13)
*                   OR (ord(d)>=19 and ord(d)<=20)
*                 OR (ord(d)>=26 and ord(d)<=27))..               release(d,p)=e=Rel_vals(d,p);


Model HI includes all the equations including Simuatlion part as well /ALL/;
release.L(d,p) = 10;
Avgrelease.L = 10;

*MODEL Simulation Find release values for Maximizing CombineObjective/All/
FtoUse(f)=1;

MODEL Simulation Find release values for Maximizing CombineObjective including all equations /All/;

SOLVE Simulation USING NLP MAXIMIGING CombineObjective;

DISPLAY release.L,storage.L,ObjectiveVal.L,FlowVol.L,Energy_Gen.L,CombineObjective.L;


*MODEL ExtremePt Finding extreme points using the NLP

MODEL ExtremePt Find extreme points by using  NLP /ALL/;

MODEL ExtremePt_minus_simulation Find extreme points by using  NLP without simulation part /EQ1__ResMassBal,EQ2__reqpowerstorage,EQ3__maxstor,EQ4__MaxR,EQ5__MinR,EQ6_Energyrate,EQ7_FlowVolume,EQ8__Mayrel,EQ9_Avgrelease,EQ10_Standarddev, EQ11_Hydropeakingindex, EQ12_EnergyGen,EQ13_EnergyRevenue,EQ16_CombinedObjectives/;

*This section constrains one objective to be greater than a level
EQUATION
ObjAsCon(f)          Objective function as constraint f(x) = FLevel;

*The objective as constraint is greater or less or equal than the level set for that objective
ObjAsCon(f)$(1 - FtoUse(f))..        ObjectiveVal(f)=e=FLevel(f);

MODEL ObjAsConstraint Single-objective model with other objectives constrained /ALL/;

MODEL ObjAsConstraint__minus_simulation Single-objective model with other objectives constrained /EQ1__ResMassBal,EQ2__reqpowerstorage,EQ3__maxstor,EQ4__MaxR,EQ5__MinR,EQ6_Energyrate,EQ7_FlowVolume,EQ8__Mayrel,EQ9_Avgrelease,EQ10_Standarddev, EQ11_Hydropeakingindex, EQ12_EnergyGen,EQ13_EnergyRevenue,EQ16_CombinedObjectives/;

*6. Solve the models.
*First, solve the single objective formulation(minimize BugFlow_objective)
*FtoUse(f)=1;

*Solve as a single-objective nonlinear programming formulation
*SOLVE ExtremePt USING NLP MAXIMIGING CombineObjective;


* Solve for the extrement points in sequence
* Step A. First find the extreme points associated with objective #1. Ignore all other objectives
*   i.e., Max fi(X) s.t. aX <= b;
* Then move to objective #2

Loop(f2,
*  Ignore all the objectives
   FtoUse(f) = 0;
*  Only consider the current objective
   FtoUse(f2) = 1;

   Display FtoUse;

*  Solve the model
   SOLVE ExtremePt USING NLP MAXIMIGING CombineObjective;

   DISPLAY release.L,storage.L,ObjectiveVal.L,FlowVol.L,Energy_Gen.L, CombineObjective.L;
*Also save the results for later use
   FStore(f2,f)= ObjectiveVal.L(f);

   XStore(f2,d) =sum(p,FlowVol.L(d,p));
);

DISPLAY FStore, XStore;

Loop(f2,
*  Ignore all the objectives
   FtoUse(f) = 0;
*  Only consider the current objective
   FtoUse(f2) = 1;

   Display FtoUse;

*  Solve the model
   SOLVE ExtremePt_minus_simulation USING NLP MAXIMIGING CombineObjective;

   DISPLAY release.L,storage.L,ObjectiveVal.L,FlowVol.L,Energy_Gen.L, CombineObjective.L;
*Also save the results for later use
   FStore2(f2,f)= ObjectiveVal.L(f);

   XStore2(f2,d) =sum(p,FlowVol.L(d,p));
);

DISPLAY FStore2, XStore2;


* Step B. Constrain one objective function value and maximize the other objective

**Minimize the bugindex objective, constrain the hydropower objective
*FToUse(f) = 0;
*FtoUse("BugIndex") = 1;
*Constrain the irrigation objective
*Choose a value between the extreme points for the irrigation objective identified above
*FLevel("Hydro") =7877694.725;

*Alternatively
*Maximum the hydropower objective, constraint the  Bug objective

loop(Scen,
     FtoUse(f) = 0;
     FtoUse("Hydro") =1;
*Set a level for the Hydropower objective

     FLevel(f)=Levels(f,Scen);

     SOLVE ObjAsConstraint USING NLP MAXIMIGING CombineObjective;
     DISPLAY release.L,storage.L,ObjectiveVal.L,FlowVol.L,Energy_Gen.L, CombineObjective.L;
     Scen_store(f2,Scen)= ObjectiveVal.L(f2);
);
DISPLAY Scen_store;

loop(Scen,
     FtoUse(f) = 0;
     FtoUse("Hydro") =1;
*Set a level for the Hydropower objective

     FLevel(f)=Levels(f,Scen);

     SOLVE ObjAsConstraint__minus_simulation USING NLP MAXIMIGING CombineObjective;
     DISPLAY release.L,storage.L,ObjectiveVal.L,FlowVol.L,Energy_Gen.L, CombineObjective.L;
     Scen_store2(f2,Scen)= ObjectiveVal.L(f2);
);
DISPLAY Scen_store2;

*MODEL Simulation Find release values for Maximizing CombineObjective /All/;

*SOLVE Simulation USING NLP MAXIMIGING CombineObjective;

*DISPLAY release.L,storage.L,ObjectiveVal.L,FlowVol.L,Energy_Gen.L,CombineObjective.L;


Final_Release(d,p)= release.L(d,p);

SOLVE HI USING NLP MAXIMIGING CombineObjective;

DISPLAY release.L,storage.L,ObjectiveVal.L,FlowVol.L,Energy_Gen.L, CombineObjective.L;

* Dump all input data and results to a GAMS gdx file
Execute_Unload "Bug_simulation_Senariovalues.gdx";
* Dump the gdx file to an Excel workbook
Execute "gdx2xls Bug_simulation_Senariovalues.gdx"



