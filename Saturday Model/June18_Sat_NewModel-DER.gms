$ontext
Title Optimization model for Glen Canyon Dam releases to favor Bugs population. (June 2018)

###################################
Created By: Moazzam Ali Rind
Email: moazzamalirind@gmail.com

Created : 12/16/2020
Last updated: 12/31/2020

Description: This model was developed to qaunitfy the trade-off between number of steady low flow days and hydropower revenue objectives.
            The model has 2 periods per day (i.e. pHigh and plow) and runs for a month. we have used linear programming to solve the problem.
            All the structural and operational constraints applied here are uptodate.

######################################
$offtext

****Model code

Set
          d                             Types of Days involved in the model/Sunday, Saturday, Weekday/
          FlowPattern                   Types of flow pattern in the model /Steady,Unsteady/
          p                             Periods during a day /pLow "Low flow period",pHigh "High flow period"/
          tot_vol                       Total montly release volume scenarios (acre-ft)/V1*V5/
          modpar                        Saving model status for each of the scenario solution/ ModStat "Model Status", SolStat "Solve Status"/
          Nu_SteadyDays                 Defining constrainted cases for number of low flow steady days /case1*case12/
          Offset                        Scenarios of offset releases between off-peak unsteady day and steady day releases /H1*H4/
;

Alias (d,Days);
Alias (FlowPattern,FlowType);

*======================================
Parameters
*======================================

Initstorage                           Initial reservoir storage (e.g Storage in Powell on 1st June 2018) (acre-ft)/12899134/
* Storage data for lake Powell can be found at: http://lakepowell.water-data.com/index2.php

Inflow                                Average monthly Inflow to reservoir (cfs) /10671/
*Inflow data can be found at: http://lakepowell.water-data.com/index2.php

maxstorage                            Maximumn Reservoir capacity (acre-ft)/25000000/
minstorage                            Minimum reservoir storage to maintain hydropower level(acre-ft)/8950000/
maxRel                                Maximum release in a day d at any timeperiod p(cfs) /32000/
minRel                                Minimum release in a day d at any timeperiod p(cfs)/8000/
evap                                  Evaporation (ac-ft per Month) /45291/
*The evaporation data can be found at: https://www.usbr.gov/rsvrWater/HistoricalApp.html


Duration(p)                           Duration of period (hours)
Vol_monthlyrelease(tot_vol)           Different monthyl release Volumes (acre-ft)/V1 700000,V2 800000,V3 900000,V4 1000000,V5 1100000/
TotMonth_volume                       To represent total monthly volume (acre-ft)

Num_Days(FlowPattern,d)               To represent different number of day types
Energy_Price(d,p)                     Energy price within period p during different day types ($ per MWh)


Saturdays(FlowPattern,d)              To represent the number of saturdays (i.e. steady flow saturdays and unsteady flow saturdays)
Sundays(FlowPattern,d)                To represent the number of Sundays (i.e. steady flow sundays and unsteady flow sundays)
Weekdays(FlowPattern,d)               To represent the number of weekdays (i.e. steady flow weekdays and unsteady flow weekdays)

Weekend_Rel                           Additional release made on weekend off-peak incomparison to weekday off-peak release(cfs).
Diff_Release(Offset)                  Differnce between off-peak weekday release and weekend release(cfs)/H1 0, H2 500, H3 750, H4 1000/


FStore(Offset,tot_vol,Nu_SteadyDays)                          Storing objective function values over different scenarios ($$)

XStore(Offset,tot_vol,Nu_SteadyDays,FlowType,Days)            Store Energy Generated during different types of days over different cases (MWh)
RStore(Offset,tot_vol,Nu_SteadyDays,FlowType,Days,p)          Store Release values during different types of days over different cases (cfs)
Sstore(Offset,tot_vol,Nu_SteadyDays)                          Store Storage Values over different cases(ac-ft)

ModelResults(Offset,tot_vol,Nu_SteadyDays,modpar)             Store solution status of the scenarios i.e. whether the solution found is optimal or not?
*Mar_Ramp(Offset,tot_vol,Nu_SteadyDays,Day_Type,p)             To save margninal values associted with the daily release range.

;

Duration("pLow")= 8;
* low period weightage in a day(08 Hours or 8 by 24 i.e:0.33 of day)

Duration("pHigh")= 16;
*  High period weightage in a day( 16 Hours or 16 by 24 i.e:0.67 of day)

Table Days_Distribution(FlowType,Days,Nu_SteadyDays) "number of saturdays sundays and weekdays in a month"
                         case1   case2   case3   case4   case5   case6  case7   case8   case9   case10   case11   case12
Steady. Sunday            0       2        4       4      4        4      4       4       4       4         4         4
Unsteady. Sunday          4       2        0       0      0        0      0       0       0       0         0         0
Steady. Saturday          0       0        0       2      3        4      4       4       4       4         4         4
Unsteady. Saturday        4       4        4       2      1        0      0       0       0       0         0         0
Steady. Weekday           0       0        0       0      0        0      1       2       7       12        17        22
Unsteady. Weekday         22      22       22      22     22       22     21      20      15      10        5         0     ;

Table Energy_Rate(Days,p)"Price of MegaWatt hour during different days and within period p ($ per MWh)"
              pLow    pHigh
Sunday        37.70   37.70
Saturday      37.70   50.61
Weekday       37.70   63.52;
*===============================================
SCALAR
Convert                        Conversion factor from cfs to ac-ft per hour (0.0014*60)/0.083/
Daily_RelRange                 Allowable daily release range (cfs)/8000/

Totaldays                      Total number of days in the month/30/
Nu_Saturdays                   Number of saturdays in the month/4/
Nu_Sun_Holi                    Number of sundays + holidays in the month /4/
*===============================================
VARIABLES

ObjectiveVal                   Objective functions value ($)
storage                        Reservoir storage at the end of the month (acre-ft)
Released_vol                   Total water released during the month (ac-ft)

Positive Variables
Release(FlowPattern,d,p)       Reservoir release on different day types and flow patterns durinng period p (cfs)
Energy_Gen(FlowPattern,d,p)    Hydropower Generated within each timestep during different day types(MWh)
;
*===============================================

EQUATIONS

*Constraints
EQ1_ResMassBal                                   Reservoir mass balance (acre-ft)
EQ2_reqpowerstorage                              The minimum storage required for hydropower generation(power pool storage) (acre-ft)
EQ3_maxstor                                      Reservoir Max storage (acre-ft)
EQ4_MaxR(FlowPattern,d,p)                        Max Release for any day type during any period p but it will not work when NumDays will be zero(cfs)
EQ5_MinR(FlowPattern,d,p)                        Min Release for any day type with flows during any period p but it will not work when NumDays will be zero (cfs)
EQ6_ZeroDays(FlowPattern,d,p)                    No release for any day type during any period p when Num_Days equal to zero(cfs)
EQ7_Rel_Range(FlowPattern,d)                     Constraining the daily release range but it will not work when NumDays will be zero(cfs per day)
EQ8_Monthtlyrel                                  Constraining total monthly release volume (ac-ft)
EQ9_RelVolume                                    Total volume from different types of day in the month (ac-ft)
EQ10_SteadyFlow_Sundays(FlowPattern,d)           Constraining on-peak and off-peak releases during sunday equal (cfs)
*EQ11_Saturdays_Offpeak(FlowPattern)              Constraining off-peak saturday and sunday off-peak releases equal (cfs)
EQ12a_OffPeakdiff(FlowPattern)                   Offset between the off-peak weekday and sunday (steady day) releases(cfs)
EQ12b_SameOffPeak(FlowPattern,d,p)               When there are zero steady days then no offset between offpeak weekday and weekends (saturday and sunday)(cfs)
EQ12c_Steady_Saturdays(FlowPattern,d,p)          Constraining the steady Saturday flows equal to other steady days flows (cfs)
*EQ12d_Unsteady_Sunday(FlowPattern,d,p)           Constraining off-peak period during unsteady sunday equal to weekday low(cfs)

*EQ12e_Unsteady_OnPeak_Saturday(FlowPattern,d,p)  Constaining On-Peak unsteady Saturday release for trial (cfs)
*EQ12f_Unsteady_OnPeak_Sunday(FlowPattern,d,p)    Constaining On-Peak unsteady Sunday release for trial (cfs)

EQ13_EnergyGen_Max(FlowPattern,d,p)              Maximum Energy Generation Limit of the Glen Caynon Dam(MW)
EQ14_EnergyGen(FlowPattern,d,p)                  Energy generated in each period p during different day types (MWh)

*Objective Functions
EQ15_EnergyRevenue                               Total monthly Hydropower Revenue generated when number of steady low flow day are greater than or equal to sum of saturdays sundays and holidays(e.g. 8 in this case)($)
;

*------------------------------------------------------------------------------*

*Mass Balance Equation
EQ1_ResMassBal..                               storage =e= Initstorage + (Inflow*Convert*sum(p,Duration(p))*Totaldays)- Released_vol - evap;
*                                                                          CFS * conversion factor from cfs to ac-ft/hr and multiplied by 24 (total duration in a day) then multiplied by total day in the month
*Physical Constraints
EQ2_reqpowerstorage..                          storage =g= minstorage;
EQ3_maxstor..                                  storage =l= maxstorage;

EQ4_MaxR(FlowPattern,d,p)$(Num_Days(FlowPattern,d) gt 0)..                     Release(FlowPattern,d,p)=l= maxRel;

EQ5_MinR(FlowPattern,d,p)$(Num_Days(FlowPattern,d) gt 0)..                     Release(FlowPattern,d,p)=g= minRel;

EQ6_ZeroDays(FlowPattern,d,p)$(Num_Days(FlowPattern,d) eq 0)..                 Release(FlowPattern,d,p)=e=0;

EQ7_Rel_Range(FlowPattern,d)$(Num_Days(FlowPattern,d) gt 0)..                  Release(FlowPattern,d,"pHigh")- Release(FlowPattern,d,"pLow")=l=Daily_RelRange;

*EQ8_  constraining the overall monthly released volume..
EQ8_Monthtlyrel..                                                              TotMonth_volume=e= Released_vol;

EQ9_RelVolume..                                                                Released_vol=e=  sum(FlowPattern,sum(d, sum(p, Release(FlowPattern,d,p)*Convert*Duration(p))*Num_Days(FlowPattern,d)));

*Managerial Constraints

EQ10_SteadyFlow_Sundays(FlowPattern,d)$(Num_Days("Steady",d) gt 0)..           Release("Steady",d,"pHigh") =e= Release("Steady",d,"pLow");
*This equation will be creating problem when the low flow days will be zero, therefore, create different equation for Zero days...


*EQ11_Saturdays_Offpeak(FlowPattern)$((Num_Days("Unsteady","Saturday") gt 0) - (Num_Days("Steady","Sunday") eq 0))..            Release("Unsteady","Saturday","pLow")=e= Release("Unsteady","Weekday","pLow");

*DER change: remove set indexing on the equation
EQ12a_OffPeakdiff(FlowPattern)$((Num_days(FlowPattern,"Weekday") gt 0) and (Num_Days("Steady","Sunday") gt 0))..          Release("Steady","Sunday","pLow")=e= Release(FlowPattern,"Weekday","pLow")+ Weekend_Rel;
* EQ12_  finds the minimimum release value from the hydrograph plus additional release we desire on weekends above off-peak weekday release (i.e. Offset).

EQ12b_SameOffPeak(FlowPattern,d,p)$(Num_Days("Steady","Sunday") eq 0)..         Release("Unsteady",d,p)=e= Release("Unsteady","Weekday",p);

EQ12c_Steady_Saturdays(FlowPattern,d,p)$(Num_Days("Steady","Saturday")gt 0)..   Release("Steady","Saturday",p)=e= Release("Steady","Sunday",p);

*EQ12d_Unsteady_Sunday(FlowPattern,d,p)$(Num_Days("Unsteady","Sunday")gt 0)..    Release("Unsteady","Sunday","pLow")=e= Release("Unsteady","Weekday","pLow");

*EQ12e_Unsteady_OnPeak_Saturday(FlowPattern,d,p)$((Num_Days("Unsteady","Saturday") gt 0) - (Num_Days("Steady","Sunday") eq 0))..   Release("Unsteady","Saturday","pHigh")=e= 11000;

*EQ12f_Unsteady_OnPeak_Sunday(FlowPattern,d,p)$(Num_Days("Unsteady","Sunday")eq 2)..  Release("Unsteady","Sunday","pHigh")=e= 10000;

EQ13_EnergyGen_Max(FlowPattern,d,p)..                                          Energy_Gen(FlowPattern,d,p)=l= 1320*Duration(p);
*Maximum Energy Generation capacity of GCD (MWH).. Source https://www.usbr.gov/uc/rm/crsp/gc
EQ14_EnergyGen(FlowPattern,d,p)..                                              Energy_Gen(FlowPattern,d,p)=e= Release(FlowPattern,d,p)*Duration(p)*0.03715;
* Energy generation formula used in WAPA Execl model..

EQ15_EnergyRevenue..                                                           ObjectiveVal=e= sum(FlowPattern,sum(d, sum(p,Energy_Gen(FlowPattern,d,p)*Energy_Price(d,p))*Num_Days(FlowPattern,d)));
*------------------------------------------------------------------------------*



MODEL Model1 Find value of hydropower revenue using LP/ALL/;
*This model is for all cases of steady flow days

Loop((Offset,tot_vol,Nu_SteadyDays),

Weekend_Rel= Diff_Release(Offset);
TotMonth_volume = Vol_monthlyrelease(tot_vol);
Num_Days(FlowType,Days)= Days_Distribution(FlowType,Days,Nu_SteadyDays)+ EPS;
Energy_Price(Days,p)= Energy_Rate(Days,p);

option LP= CPLEX;

******************************
*initialization (Its optional in linear progromming incontrast to non-linear)
*Release.L(FlowPattern,d,p)= 1000;
**********************************

Solve Model1 using LP MAXIMIZE ObjectiveVal;

*----------------------------------------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------------------------
* All the following lines of code are saving values for different parameters

   FStore(Offset,tot_vol,Nu_SteadyDays)= ObjectiveVal.L;

* XStore store the energy generated (Mwh/day) during different types of days
   XStore(Offset,tot_vol,Nu_SteadyDays,FlowType,Days)= sum (p,Energy_Gen.L(FlowType,Days,p))+ EPS;

* RStore store the reservoir releases (cfs) during different types of days and scenarios.
   RStore(Offset,tot_vol,Nu_SteadyDays,FlowType,Days,p)= Release.L(FlowType,Days,p)+ EPS;

*Sstore store the end of month reservoir storage (ac-ft)
   Sstore(Offset,tot_vol,Nu_SteadyDays)= storage.L;


*Saving the model status for different scenarios.
   ModelResults(Offset,tot_vol,Nu_SteadyDays,"SolStat")= Model1.solvestat;
   ModelResults(Offset,tot_vol,Nu_SteadyDays,"ModStat")= Model1.modelstat;

*Marginal values for daily telease range
*Mar_Ramp(Wkn,tot_vol,case,Day_Type,p) = EQ6_Rel_Range.M(Day_Type,p)+ EPS;

   option clear=ObjectiveVal,clear=Release,clear=Energy_Gen;
);

DISPLAY FStore,XStore,RStore,Sstore;

*------------------------------------------------------------------------------*

*Following part of code creates  gdx and excel output file..

* Dump all input data and results to a GAMS gdx file
Execute_Unload "DER_Unconstrained.gdx";
* Dump the gdx file to an Excel workbook
Execute "gdx2xls DER_Unconstrained.gdx"


*Following code can be used to create gdx and excel output files when EQ12e and EQ12f is included in the model. Both EQ12e and EQ12f are introduced to test the behavior of model against contrainted releases.
$ontext
* Dump all input data and results to a GAMS gdx file
Execute_Unload "DER_Trial.gdx";
* Dump the gdx file to an Excel workbook
Execute "gdx2xls DER_Trial.gdx"
$offtext









