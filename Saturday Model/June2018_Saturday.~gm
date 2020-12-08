
$ontext
Title Optimization model for Glen Canyon Dam releases to favor Bugs population. (June 2018)

###################################
Created By: Moazzam Ali Rind
Email: moazzamalirind@gmail.com

Created : 11/30/2020
Last updated: 12/05/2020

Description: This model was developed to qaunitfy the trade-off between number of steady low flow days and hydropower revenue objectives.
            The model has 2 periods per day (i.e. pHigh and plow) and runs for a month. we have used linear programming to solve the problem.
            All the structural and operational constraints applied here are uptodate.

######################################
$offtext

****Model code

Set

          d                             days in June
          p                             time period during a day /pLow "Low flow period",pHigh "High flow period"/
          tot_vol                       Total montly release volume (acre-ft)/V1*V5/
          modpar                        Saving model status for each of the scenario solution/ ModStat "Model Status", SolStat "Solve Status"/
          case                          Defining constrainted cases for number of low flow steady days /case1*case12/
          Wkn                           Scenarios to decide the change between off-peak release on weekday and weekend steady flows /S1*S4/
          d_type                       Types of Days involved in the model/Steady "Low steady flow days", Saturday "Saturday with unique flows", Unsteady "unsteady flow days"/

;

Alias (d_type,Day_Type);
*======================================
*Parameters
*======================================

PARAMETERS

FStore(Wkn,tot_vol,case)                          Storing objective function values over different scenarios

XStore(Wkn,tot_vol,case,Day_Type)                 Store Energy Generated during different types of days over different cases (MWh)
RStore(Wkn,tot_vol,case,Day_Type,p)               StoreRelease values during different types of days over different cases (cfs)
Sstore(Wkn,tot_vol,case)                          Store Storage Values over different cases(ac-ft)

ModelResults(Wkn,tot_vol,case,modpar)             Store solution status of the scenarios i.e. whether the solution found is optimal or not?
Mar_Ramp(Wkn,tot_vol,case,Day_Type,p)             To save margninal values associted with the daily release range.

initstorage                           Initial reservoir storage 1st June 2018 (acre-ft)
maxstorage                            Reservoir capacity (acre-ft)
minstorage                            Minimum reservoir storage to maintain hydropower level(acre-ft)
Inflow(d)                             Inflow to reservoir (cfs)
maxRel                                Maximum release in a day d at any timeperiod p(cfs)
minRel                                Minimum release in a day d at any timeperiod p(cfs)
evap                                  evaporation (ac-ft per day Considered constant throughout the month
WeekdayRate(p)                        Energy prices on weekdays ($ per MWH) /pLow 37.70, pHigh 63.52/
SaturdayRate(p)                       Energy prices on Saturdays ($ per MWH) /pLow 37.70, pHigh 50.61/
SundayRate                            Energy prices on Sundays and Holidays ($ per MWH) /37.70/
Duration(p)                           Duration of period (hours)
Vol_monthlyrelease(tot_vol)           Different Total volumes of water to be released in the month i.e. June2018 in presented case (acre-ft)/V1 700000,V2 800000,V3 900000,V4 1000000,V5 1100000/
TotMonth_volume                       To represent total monthly volume (acre-ft)
Saturdays                             To reperesent the number of saturdays in a month
Steady_Days                           To represent the number of steady low flow days
Num_steady(case)                      Number of steady low flow days/case1 0, case2 4,case3 6, case4 7, case5 8, case6 9,case7 10,case8 12,case9 15,case10 20,case11 25,case12 30/
Weekend_Rel                           Additional release made on weekend incomparison to weekday off-peak release(cfs).
Diff_Release(Wkn)                     Differnce between off-peak weekday release and weekend release(cfs)/S1 0, S2 500, S3 750, S4 1000/
;


Duration("pLow")= 8;
* low period weightage in a day(08 Hours or 8 by 24 i.e:0.33 of day)

Duration("pHigh")= 16;
*  High period weightage in a day( 16 Hours or 16 by 24 i.e:0.67 of day)

*===================================================
* Read data from Excel
*===================================================
$CALL GDXXRW.EXE input=June2018.xls output=Results_SatAuto.gdx set=d rng=day!A1 Rdim=1  par=Inflow rng=inflow!A1 Rdim=1  par=initstorage rng=initstorage!A1 Rdim=0  par=maxstorage rng=maxstorage!A1 Rdim=0   par=minstorage rng=minstorage!A1 Rdim=0  par=maxRel rng=maxRel!A1 Rdim=0 par=minRel rng=minRel!A1 Rdim=0  par=evap rng=evap!A1 Rdim=0

*Write the input Data into a GDX file
*$GDXIN Results_Saturday.gdx
$GDXIN Results_SatAuto.gdx

* loading parameters and input data from the GDX file into the model
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

Display d,inflow, initstorage, maxstorage, minstorage, maxRel, minRel, evap, p, Duration;
*===============================================
SCALAR
Convert                       conversion factor from cfs to ac-ft per hour (0.0014*60)/0.083/
Totaldays                     Total number of days in the month/30/
weekdays                      Number of days in month/22/
Nu_Saturdays                  Number of saturdays in the month/4/
Nu_Sun_Holi                   Number of sundays + holidays in the month /4/
Num_of_timesteps              Total Number of timesteps used /60/
Daily_RelRange                Allowable daily release range (cfs)/8000/


VARIABLES

ObjectiveVal                   Objective functions calculation
storage                        Reservoir storage at the end of the month (acre-ft)
Avail_Water                    Total Water available in the system during the month (June)
Sat_outflow                    Volume of water released during saturdays (ac-ft)
steady_Outflow                 Volume of water released during steady low flow days but volume of water released during saturdays are calculated seperately (acre-ft)
unsteady_Outflow               Volume of water released in the unsteay low flow days (acre-ft)

Positive Variables
Release(d_type,p)              Reservoir release on different day types durinng period p (cfs)
Energy_Gen(d_type,p)           Hydropower Generated within each timestep during different day types(MWh)
;


EQUATIONS
*AND CONSTRAINTS

*Calculating different flow volumes involved in the system
EQa_Inflow                   Total volume of water available in the system during the month (acre-ft)
EQb_SatOutflow               Volume of water release during the sturdays(ac-ft)
EQc_SteadyOutflow            Volume of Water released during the steady days but saturdays are not counted here (acre-ft)
EQd_UnSteadyOutflow          Volume of Water released during the unsteady days (acre-ft)

EQ1_ResMassBal              Reservoir mass balance (acre-ft)
EQ2_reqpowerstorage         The minimum storage required for hydropower generation(power pool level) (acre-ft)
EQ3_maxstor                 res storage max (acre-ft)
EQ4_MaxR(d_type,p)          Max Release for any day type during any period p (cfs)
EQ5_MinR(d_type,p)          Min Release for any day type during any period p (cfs)
EQ6_Rel_Range(d_type,p)     Constraining the daily release range (cfs per day)
EQ7_Monthtlyrel             Constraining Total monthly volume of water released in "June" as per WAPA information(acre-ft)
EQ8_Steadydays(d_type,p)    Constraining on-peak and off-peak releases during steady day equal (cfs)
EQ9_Saturdays(d_type,p)     Constraining off-peak saturday release equal to release on steady day (cfs)
EQ10_OffPeakdiff(d_type,p)  Differentiating the off-peak release of steady day from unsteady off-peak release(cfs)
EQ11_SatCondition(d_type,p) Constraining the on-peak saturday release equal to steady release in scenarios when steady days is greater than number of saturdays sundays and holidays
EQ12_EnergyGen_Max(d_type,p) Maximum Energy Generation Limit of the Glen Caynon Dam(MW)
EQ13_EnergyGen(d_type,p)    Energy generated in each time step during unsteady flow days (MWh)
EQ14_EnergyRevenue           Total monthly Hydropower Revenue generated when number of steady low flow day are greater than number of weekend days($)
EQ15_Revenue                 Total monthly Hydropower Renvenue generated if number of steady flow days are equal or less than weekend days ($)
;

*------------------------------------------------------------------------------*

EQa_Inflow..                 Avail_Water =e= initstorage + sum(d,inflow(d)*Convert*sum(p,Duration(p)));
EQb_SatOutflow..             Sat_outflow =e= sum(p,Release("Saturday",p)*Duration(p)*Convert)*Saturdays;
EQc_SteadyOutflow ..         steady_Outflow =e=sum(p,Release("Steady",p)*Duration(p)*Convert)*(Steady_Days-Saturdays);
EQd_UnSteadyOutflow..        unsteady_Outflow =e= sum(p,Release("Unsteady",p)*Convert*Duration(p))*(Totaldays-Steady_Days-Saturdays);

EQ1_ResMassBal..           storage =e= Avail_Water-Sat_outflow-steady_Outflow-unsteady_Outflow-(evap*Totaldays);

*Physical Constraints
EQ2_reqpowerstorage..      storage =g= minstorage;
EQ3_maxstor..              storage =l= maxstorage;
EQ4_MaxR(d_type,p)..       Release(d_type,p)=l= maxRel;
EQ5_MinR(d_type,p)..       Release(d_type,p)=g= minRel;
EQ6_Rel_Range(d_type,p)..  Release(d_type,"pHigh")- Release(d_type,"pLow")=l=Daily_RelRange;

*EQ7_  constraining the overall monthly released volume..
EQ7_Monthtlyrel..         TotMonth_volume=e= Sat_outflow + steady_Outflow + unsteady_Outflow;

EQ8_Steadydays(d_type,p)..                               Release("Steady","pHigh")=e= Release("Steady","pLow");
EQ9_Saturdays(d_type,p)..                                Release("Saturday","pLow")=e= Release("Steady","pLow");
EQ10_OffPeakdiff(d_type,p)..                             Release("Steady",p)=e= Release("Unsteady","pLow")+ Weekend_Rel;
* EQ10_  finds the minimimum release value from the hydrograph plus additional release we desire on weekends above off-peak weekday release.

EQ11_SatCondition(d_type,p)..                            Release("Saturday","pHigh") =e= Release("Steady","pHigh");
*This equation is only applicable when te number of steady days is equal to or greater than sum of number of saturdays, sundays and holidays.

EQ12_EnergyGen_Max(d_type,p)..                   Energy_Gen(d_type,p)=l= 1320*Duration(p);
*Maximum Energy Generation capacity of GCD (MWH).. Source https://www.usbr.gov/uc/rm/crsp/gc
EQ13_EnergyGen(d_type,p)..                        Energy_Gen(d_type,p)=e= Release(d_type,p)*Duration(p)*0.03715;
* Energy generation formula used in wapa Execl model..

EQ14_EnergyRevenue..                        ObjectiveVal=e= sum(p,Energy_Gen("Steady",p)*SundayRate)*Nu_Sun_Holi + sum(p,Energy_Gen("Steady",p)*SaturdayRate(p))*Nu_Saturdays+ sum(p,Energy_Gen("Steady",p)*WeekdayRate(p))*(Steady_Days-(Nu_Sun_Holi + Nu_Saturdays))+ sum(p,Energy_Gen("Unsteady",p)*WeekdayRate(p))*(Totaldays-Steady_Days);
* *This equation works for number of steady days equal to or greater than sum of number of Holidays, Sundays and Saturdays.

EQ15_Revenue..                             ObjectiveVal=e= sum(p,Energy_Gen("Steady",p)*SundayRate)*(Steady_Days - Saturdays) + sum(p,Energy_Gen("Saturday",p)*SaturdayRate(p))* Saturdays + sum(p,Energy_Gen("Unsteady",p)*WeekdayRate(p))*(Totaldays-(Nu_Sun_Holi + Nu_Saturdays))+ sum(p,Energy_Gen("Unsteady",p)*SaturdayRate(p))*(Nu_Saturdays-Saturdays)+ sum(p,Energy_Gen("Unsteady",p)*SundayRate)*(Nu_Sun_Holi - Steady_Days + Saturdays);
*This equation works for number of steady days less than sum of number of Holidays, Sundays and Saturdays.  This equation price all the weekend days by weekned rates ( i.e. saturday and sunday rates) irrespective of whether its steady or hydropeaking day.

*Note: Both Eq 14 and Eq 15 can work for scenario when number of steady days is equal to sum of number of holidays, sundays and saturdays. In this model, we are using Eq 14 for equality scenario.
*------------------------------------------------------------------------------*

***************************************************
******Linearization Model
****************************************** ********

MODEL Model1 Find value of hydropower revenue using LP/EQa_Inflow,EQb_SatOutflow,EQc_SteadyOutflow,EQd_UnSteadyOutflow,EQ1_ResMassBal,EQ2_reqpowerstorage,EQ3_maxstor,EQ4_MaxR,EQ5_MinR,EQ6_Rel_Range,EQ7_Monthtlyrel,EQ8_Steadydays,EQ9_Saturdays,EQ10_OffPeakdiff,EQ11_SatCondition,EQ12_EnergyGen_Max,EQ13_EnergyGen,EQ14_EnergyRevenue/;
*this Model will work under scenarios when number of steady low bug flow days are greater than or equal to sum of number of Holidays, Sundays and Saturdays

*This line provides additional information in the .lst file. If you not aware of option file please comment it out or remove before running the model
Model1.optfile = 1;


Model Model2 Find value of hydropower revenue using LP /EQa_Inflow,EQb_SatOutflow,EQc_SteadyOutflow,EQd_UnSteadyOutflow,EQ1_ResMassBal,EQ2_reqpowerstorage,EQ3_maxstor,EQ4_MaxR,EQ5_MinR,EQ6_Rel_Range,EQ7_Monthtlyrel,EQ8_Steadydays,EQ9_Saturdays,EQ10_OffPeakdiff,EQ12_EnergyGen_Max,EQ13_EnergyGen,EQ15_Revenue/;
*this Model will work under scenarios when number of steady low bug flow days are less than number of weekned days (sum of number of saturadys, sundays and holidays).

*This line provides additional information in the .lst file. If you not aware of option file please comment it out or remove before running the model
Model2.optfile = 1;

*Looping over different additional weekend, total volume, and number of steay days scenarios
loop((Wkn,tot_vol,case,Day_Type),

*option optcr=0.001;
option LP= CPLEX;

******************************
*initialization (It optional in linear progromming incontrast to non-linear)
Release.L(d_type,p)= 10000;
**********************************

   Weekend_Rel= Diff_Release(Wkn);
   TotMonth_volume = Vol_monthlyrelease(tot_vol);
   Steady_Days = Num_steady(case)+ EPS;

*Following lines of code are identifying the number of saturdays (saturday releases) involved in the simulation.
if (Steady_Days <=Nu_Sun_Holi, Saturdays=0;
else if(Steady_Days =Nu_Sun_Holi+1, Saturdays=1;
else if(Steady_Days = Nu_Sun_Holi+2, Saturdays=2;
else if(Steady_Days = Nu_Sun_Holi+3, Saturdays=3;
else if(Steady_Days >= Nu_Sun_Holi+4, Saturdays=4;
); ); ); ); );


if  (Steady_Days >= (Nu_Saturdays + Nu_Sun_Holi),
     SOLVE Model1 USING LP maximize ObjectiveVal;
else SOLVE Model2 USING LP maximize ObjectiveVal;
);


* All the following lines of code are saving values for different parameters
   FStore(Wkn,tot_vol,case)= ObjectiveVal.L;

* XStore store the energy generated during different types of days
   XStore(Wkn,tot_vol,case,"Steady")= sum (p,Release.L("Steady",p)*Duration(p)*0.03715)*(Num_steady(case)-Saturdays);
   XStore(Wkn,tot_vol,case,"Saturday")= sum (p,Release.L("Saturday",p)*Duration(p)*0.03715)* Saturdays;
   XStore(Wkn,tot_vol,case,"Unsteady")= sum (p,Release.L("Unsteady",p)*Duration(p)*0.03715)* (Totaldays-Num_steady(case));


*************************************************
* RStore store the reservoir releases during different types of days and scenarios.
   RStore(Wkn,tot_vol,"case1","Steady",p)= 0 + EPS;
   RStore(Wkn,tot_vol,case,"Steady",p)=Release.L("Steady",p);

   RStore(Wkn,tot_vol,case,"Saturday",p)=Release.L("Saturday",p);
   RStore(Wkn,tot_vol,"case1","Saturday",p)= 0 + EPS;
   RStore(Wkn,tot_vol,"case12","Saturday",p)= 0 + EPS;

$ontext
   RStore(Wkn,tot_vol,"case1","Saturday",p)= 0 + EPS;
   RStore(Wkn,tot_vol,"case2","Saturday",p)= 0 + EPS;
   RStore(Wkn,tot_vol,"case3","Saturday","pLow")= Release.L("Saturday","pLow");
   RStore(Wkn,tot_vol,"case3","Saturday","pHigh")= Release.L("Saturday","pHigh");
   RStore(Wkn,tot_vol,"case4","Saturday","pLow")= Release.L("Saturday","pLow");
   RStore(Wkn,tot_vol,"case4","Saturday","pHigh")= Release.L("Saturday","pHigh");
   RStore(Wkn,tot_vol,"case5","Saturday",p)= 0 + EPS;
   RStore(Wkn,tot_vol,"case6","Saturday",p)= 0 + EPS;
   RStore(Wkn,tot_vol,"case7","Saturday",p)= 0 + EPS;
   RStore(Wkn,tot_vol,"case8","Saturday",p)= 0 + EPS;
   RStore(Wkn,tot_vol,"case9","Saturday",p)= 0 + EPS;
   RStore(Wkn,tot_vol,"case10","Saturday",p)= 0 + EPS;
   RStore(Wkn,tot_vol,"case11","Saturday",p)= 0 + EPS;
   RStore(Wkn,tot_vol,"case12","Saturday",p)= 0 + EPS;
$offtext

   RStore(Wkn,tot_vol,case,"Unsteady",p)=Release.L("Unsteady",p);
   RStore(Wkn,tot_vol,"case12","Unsteady",p)= 0 + EPS;
*********************************************************************
*Sstore store the end of month reservoir storage (ac-ft)
    Sstore(Wkn,tot_vol,case)=storage.L;

*Saving the model status for different scenarios.
   ModelResults(Wkn,tot_vol,"case1","SolStat")= Model2.solvestat;
   ModelResults(Wkn,tot_vol,"case1","ModStat")= Model2.modelstat;
   ModelResults(Wkn,tot_vol,"case2","SolStat")= Model2.solvestat;
   ModelResults(Wkn,tot_vol,"case2","ModStat")= Model2.modelstat;
   ModelResults(Wkn,tot_vol,"case3","SolStat")= Model2.solvestat;
   ModelResults(Wkn,tot_vol,"case3","ModStat")= Model2.modelstat;
   ModelResults(Wkn,tot_vol,"case4","SolStat")= Model2.solvestat;
   ModelResults(Wkn,tot_vol,"case4","ModStat")= Model2.modelstat;

   ModelResults(Wkn,tot_vol,case,"SolStat")= Model1.solvestat;
   ModelResults(Wkn,tot_vol,case,"ModStat")= Model1.modelstat;

*Marginal values for daily telease range
   Mar_Ramp(Wkn,tot_vol,case,Day_Type,p) = EQ6_Rel_Range.M(Day_Type,p)+ EPS;

   option clear=ObjectiveVal,clear=Release,clear=Energy_Gen;
);

DISPLAY FStore,XStore,RStore,Sstore;

*------------------------------------------------------------------------------*

* Dump all input data and results to a GAMS gdx file
Execute_Unload "Results_SatAuto.gdx";
* Dump the gdx file to an Excel workbook
Execute "gdx2xls Results_SatAuto.gdx"
