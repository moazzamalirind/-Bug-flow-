
$ontext
Title Optimization model for Glen Canyon Dam releases to favor Bugs population. (Annual scale model)

###################################
Created By: Moazzam Ali Rind
Email: moazzamalirind@gmail.com

Created : 10/19/2020
Last updated: 10/21/2020

Description: Daily High & low flow releases with an aim to minimize the difference between the daily releases (i.e.Miximize number of steady flow days).
             The model quantify trade-off between ecosystem (i.e. number of steady low flow days) and hydropower revenue objectives. The model provides
             hydropraphs for the representative months. The annual volume to be releases is predefined and contributions of each of the representative months in the annual volume are fixed.
             The model runs for annual volumes, weightage to the representative months, and pricing scenarios inorder to estimate the response of system to different conditions.

######################################

$offtext

****Model code:

Set
          Vol_yr                       Total annual release volume in a water year (ac-ft) /V1*V2/
          Month                        Representative months in a year/M1*M6/
*Here, M1 for October and November, M2 for December and January, M3 for Feburary and March, M4 for April and May, M5 for June and September, M6 for July and August

          p                            Period in a day /pLow "Low flow period",pHigh "High flow period"/
          R_Mn                         Representative monthly volumes contribution  /R1*R2/
          modpar                       Saving model parameter for each of the solutions for each of the scenario/ ModStat "Model Statistics", SolStat "Solve Statistics"/
          case                         Defining constrainted cases for number of low flow steady days /case1*case12/
;

*Define a second name for the sets
Alias (Month,Mo);



*======================================
*Parameters
*======================================

PARAMETERS

FStore(Vol_yr,R_Mn,case)               Storing objective function values over different scenarios combinations but annual scale
MStore(Vol_yr,R_Mn,Mo,case)            Storing objective function values over different scenarios combinations but monthly scale


XStore_steady(Vol_yr,Mo,R_Mn,case)     Store Energy Generated during steady flow days  over different scenarios combinations (MWH)
XStore_unsteady(Vol_yr,Mo,R_Mn,case)   Store Energy Generated during unsteady flow days over different scenarios combinations (MWH)

RStore_steady(Vol_yr,Mo,R_Mn,case,p)   Store Release values during steady flow days over different scenarios combinations (cfs)
RStore_unsteady(Vol_yr,Mo,R_Mn,case,p) Store Release values during unsteady flow days over over different scenarios combinations(cfs)

Sstore(Vol_yr,Mo,R_Mn,case)            Store Storage Values over different scenarios combinations(ac-ft)


ModelResults(Vol_yr,Mo,R_Mn,case,modpar)             Model Results for the scenarios


initstorage                           Initial reservoir storage i.e. storage on 30th september (acre-ft)
*Here as we are considering 2018 water year

maxstorage                            Reservoir capacity (acre-ft)
minstorage                            Minimum reservoir storage to maintain hydropower level(acre-ft)
Inflow(Month)                         Inflows during representative months (ac-ft)


maxRel                                Maximum release during any timeperiod p(cfs)
minRel                                Minimum release during any timeperiod p(cfs)

evap(Month)                           Evaporation during the representative month time (ac-ft)
Duration(p)                           Duration of period (hours)
Steady_Days(Month)                    To represent the number of steady low flow days in a representative month

weekdays(Month)                       Number of weekdays days in representative month/M1 44, M2 44, M3 42,M4 44,M5 41,M6 45/
weekends(Month)                       Number of weekdays days in representative month/M1 17, M2 18, M3 17,M4 17,M5 19,M6 17/
Total_Days(Month)                     Total number of day in a representative month  /M1 61, M2 62, M3 59,M4 61,M5 60,M6 62/

Tot_vol(Vol_yr)                       Total annual volume (ac-ft) /V1 8230000,V2 10500000/
*The model can be simulated for any other desired total volume by setting the new values in Tot_vol parameter.

Totyr_volume                          To represent total Annual volume (acre-ft)
Fr(Month)                             Share of the representative month in total annual volume.

Mar_Ramp(Vol_yr,Mo,R_Mn,case,p)       To save margninal values associted with the ramp rate.
;


TABLE WeekRate(Month,p) Energy revenue on weekdays ($ per MWH)
          pLow    pHigh
     M1  37.42    63.42
     M2  38.37    62.11
     M3  37.37    58.95
     M4  27.24    55.81
     M5  31.61    65.58
     M6  33.53    77.72  ;
TABLE weekendRate(Month,p) Energy revenue on weekends ($ per MWH)
          pLow    pHigh
     M1   37.42    37.42
     M2   38.37    38.37
     M3   37.37    37.37
     M4   27.24    27.24
     M5   31.61    31.61
     M6   33.53    33.53  ;

TABLE Num_steady(Month,case) number of steady days in a representative month
*This model consider 2018 water year for simulation, but can work for any other water year with required modifications. Modifiction in number of steady days can be one of them
         case1 case2 case3 case4 case5 case6 case7 case8 case9 case10 case11 case12
     M1   0     8      12   14    16    17    20     24    30   40      50      61
     M2   0     8      12   14    16    18    20     24    30   40      50      62
     M3   0     8      12   14    16    17    20     24    30   40      50      59
     M4   0     8      12   14    16    17    20     24    30   40      50      61
     M5   0     8      12   14    16    19    20     24    30   40      50      60
     M6   0     8      12   14    16    17    20     24    30   40      50      62
 ;


TABLE  Share(R_Mn,Vol_yr,Month) Contribution (%share) of the representative month toward annual volume
*The % share was found using Table 1 in the LTEMP document for the above volumes ( i.e. 8.23 and 10.5 MAF Annual volumes)
             M1      M2    M3    M4    M5    M6
    R1.V1    0.16   0.18  0.17  0.15  0.15  0.19
    R2.V2    0.12   0.17  0.18  0.16  0.16  0.20;


Duration("pLow")= 8;
* low period weightage in a day(08 Hours or 8 by 24 i.e:0.33 of day)

Duration("pHigh")= 16;
*  High period weightage in a day( 16 Hours or 16 by 24 i.e:0.67 of day)


*===================================================
* Read data from Excel
*===================================================
$CALL GDXXRW.EXE input=Input_WY18.xlsx output=Results_WY18.gdx  par=Inflow rng=inflow!A1 Rdim=1  par=initstorage rng=initstorage!A1 Rdim=0  par=maxstorage rng=maxstorage!A1 Rdim=0   par=minstorage rng=minstorage!A1 Rdim=0  par=maxRel rng=maxRel!A1 Rdim=0 par=minRel rng=minRel!A1 Rdim=0  par=evap rng=evap!A1 Rdim=1

*Write the input Data into a GDX file
$GDXIN Results_WY18.gdx


* parameters and input data from the GDX file into the model
$LOAD inflow
$LOAD initstorage
$LOAD maxstorage
$LOAD minstorage
$LOAD maxRel
$LOAD minRel
$LOAD evap


*Close the GDX file
$GDXIN

Display inflow, initstorage, maxstorage, minstorage, maxRel, minRel, evap, p, Duration, Share,Num_steady,weekendRate,WeekRate;
*===============================================

SCALAR
Convert                      conversion factor from cfs to ac-ft per hour (0.0014*60)/0.084/
Daily_Ramprate               Allowable daily ramp rate (cfs)/8000/

VARIABLES
ObjectiveVal                         Objective functions calculation
storage(month)                       reservoir storage at the end of the representative month (acre-ft)

release(Month,p)                     reservoir release on any unsteady day in any period p (cfs)
Energy_Gen(Month,p)                  Hydropower Generated for each timestep during unsteady flow days (MWH)
SteadyEn_Gen(Month,p)                Hydropower Generated for each timestep during steady flow days (MWH)
Steady_Release(Month)                Release on the weekends

steady_Outflow(Month)                Volume of water released in the steady low flow days (acre-ft)
unsteady_Outflow (Month)             Volume of water released in the unsteay low flow days (acre-ft)

;



EQUATIONS
*AND CONSTRAINTS

EQa_SteadyOutflow(Month)            Volume of Water released during the steady days (acre-ft)
EQb_UnSteadyOutflow(Month)          Volume of Water released during the unsteady days (acre-ft)

EQ1__InitMassBal(Month)             Reservoir mass balance at first time step  (acre-ft)
EQ2__ResMassBal(Month)              Reservoir mass balance at any timestep except t1 (acre-ft)
EQ3__reqpowerstorage(Month)         Minimum storage equivalent to reservoir level required for hydropower generation (acre-ft)
EQ4__maxstor(Month)                 Reservoir storage maximum capacity (acre-ft)
EQ5__MaxR(Month,p)                  Max Release during period p (cfs)
EQ6__MinR(Month,p)                  Min Release during period p (cfs)
EQ7_Rampup_rate(Month)              Constraining the daily ramp up rate between the timesteps(cfs)with in same day
EQ8__AnnualRel                      Total annual release  (acre-ft)
EQ9_Steadyflow(Month)               Steady flow value equals the off-peak weekday value (cfs)
EQ10_SteadyEnergy(Month,p)          Energy generated in each time step during steady flow days (MWH)
EQ11_EnergyGen(Month,p)             Energy generated in each time step during unsteady flow days (MWH)
EQ12_EnergyGen_Max(Month,p)         Maximum Energy Generation Limit of the Glen Caynon Dam(MW)
EQ13_EnergyRevenue                  Total monthly Hydropower Revenue generated when number of steady low flow day are greater than number of weekend days($)
EQ14_Revenue                        Total monthly Hydropower Renvenue generated if number of steady flow days are equal or less than weekend days ($)
;

*------------------------------------------------------------------------------*



EQa_SteadyOutflow(Month)..          steady_Outflow(Month) =e= Steady_Release(Month)*sum(p,Duration(p))*Convert*Steady_Days(Month);
EQb_UnSteadyOutflow(Month)..        unsteady_Outflow(Month) =e= sum(p,release(Month,p)*Convert*Duration(p))*(Total_Days(Month)-Steady_Days(Month));

EQ1__InitMassBal(Month)$(ord(Month) eq 1)..        storage(Month) =e= initstorage + Inflow(Month)-evap(Month)- steady_Outflow(Month)- unsteady_Outflow(Month) ;
EQ2__ResMassBal(Month)$(ord(Month) gt 1)..   storage(Month) =e= storage(Month-1) + Inflow(Month)-evap(Month)- steady_Outflow(Month)- unsteady_Outflow(Month) ;
EQ3__reqpowerstorage(Month)..       storage(Month)=g= minstorage;
EQ4__maxstor(Month)..              storage(Month) =l= maxstorage;

EQ5__MaxR(Month,p)..                release(Month,p)=l= maxRel;
EQ6__MinR(Month,p)..                release(Month,p)=g= minRel;
EQ7_Rampup_rate(Month)..                 release(Month,"pHigh")-release(Month,"pLow")=l=Daily_Ramprate;

*EQ7_  constraining the overall monthly released volume..
*EQ8__AnnualRel..                          8230000 =e= Fr("M1")*(steady_Outflow("M1")+unsteady_Outflow("M1"))+ Fr("M2")*(steady_Outflow("M2")+unsteady_Outflow("M2")) + Fr("M3")*(steady_Outflow("M3")+unsteady_Outflow("M3"))+Fr("M4")*(steady_Outflow("M4")+unsteady_Outflow("M4"))+Fr("M5")*(steady_Outflow("M5")+unsteady_Outflow("M5"))+Fr("M6")*(steady_Outflow("M6")+unsteady_Outflow("M6"));
EQ8__AnnualRel..                         Totyr_volume =e= Fr("M1")*(steady_Outflow("M1")+unsteady_Outflow("M1"))+ Fr("M2")*(steady_Outflow("M2")+unsteady_Outflow("M2")) + Fr("M3")*(steady_Outflow("M3")+unsteady_Outflow("M3"))+Fr("M4")*(steady_Outflow("M4")+unsteady_Outflow("M4"))+Fr("M5")*(steady_Outflow("M5")+unsteady_Outflow("M5"))+Fr("M6")*(steady_Outflow("M6")+unsteady_Outflow("M6"));
EQ9_Steadyflow(Month)..                           Steady_Release(Month)=e=release(Month,"pLow");
* EQ8_  finds the minimimum release value from the hydrograph. This equation also takes care of ramprate bewtween unsteady high release and steady release.

EQ10_SteadyEnergy(Month,p)..                      SteadyEn_Gen(Month,p)=e= Steady_Release(Month)*Duration(p)*0.03715;
* Energy generation formula used in wapa Execl model.

EQ11_EnergyGen(Month,p)..                         Energy_Gen(Month,p)=e= release(Month,p)*Duration(p)*0.03715;
* Energy generation formula used in wapa Execl model..

EQ12_EnergyGen_Max(Month,p)..                    Energy_Gen(Month,p)=l= 1320*Duration(p);
*Maximum Energy Generation capacity of GCD (MWH).. Source https://www.usbr.gov/uc/rm/crsp/gc/

**EQ12_HyrdroPower objective                                                                                                   Energy generated from the period of low steady flow multiply by the energy rate and summed over the day (2 periods) in a day and multiply by the number of steady low flow days.
EQ13_EnergyRevenue..                         ObjectiveVal=e= sum(Month,sum(p,SteadyEn_Gen(Month,p)*weekendRate(Month,p))* weekends(Month) + sum(p,SteadyEn_Gen(Month,p)*WeekRate(Month,p))*(Steady_Days(Month)-weekends(Month))+ sum(p,Energy_Gen(Month,p)*WeekRate(Month,p))*(Total_Days(Month)- Steady_Days(Month)));
* *This equation works for number of steady days greater than number of weekend days.

***************************************************
EQ14_Revenue..                             ObjectiveVal=e= sum(Month,sum(p,SteadyEn_Gen(Month,p)*weekendRate(Month,p))* Steady_Days(Month) + sum(p,Energy_Gen(Month,p)*weekendRate(Month,p))*(weekends(Month)- Steady_Days(Month))+ sum(p,Energy_Gen(Month,p)*WeekRate(Month,p))*(Total_Days(Month)-weekends(Month)));
*This equation works for number of steady days either equal or less than weekend days.  This equation price all the weekend days by weekned rate irrespective of whether its steady or hydropeaking day.

*------------------------------------------------------------------------------*

***************************************************
******Linearization Model
****************************************** ********

MODEL Model1 Find value of hydropower revenue using LP/EQa_SteadyOutflow,EQb_UnSteadyOutflow,EQ1__InitMassBal,EQ2__ResMassBal,EQ3__reqpowerstorage,EQ4__maxstor,EQ5__MaxR,EQ6__MinR,EQ7_Rampup_rate,EQ8__AnnualRel,EQ9_Steadyflow,EQ10_SteadyEnergy,EQ11_EnergyGen,EQ12_EnergyGen_Max,EQ13_EnergyRevenue/;
*this Model will work under scenarios when number of steady low bug flow days are greater than number of weekned days.

*Model1.optfile = 1;

Model Model2 Find value of hydropower revenue using LP /EQa_SteadyOutflow,EQb_UnSteadyOutflow,EQ1__InitMassBal,EQ2__ResMassBal,EQ3__reqpowerstorage,EQ4__maxstor,EQ5__MaxR,EQ6__MinR,EQ7_Rampup_rate,EQ8__AnnualRel,EQ9_Steadyflow,EQ10_SteadyEnergy,EQ11_EnergyGen,EQ12_EnergyGen_Max,EQ14_Revenue/;
*this Model will work under scenarios when number of steady low bug flow days are less than or equal to number of weekned days.

*Model2.optfile = 1;

loop((Vol_yr,R_Mn,case),

option reslim=20000;
option Threads=6;
option optcr=0.001;
option LP= CPLEX;
*option LP= Baron;

*initializing the variables
release.L(Month,p) = 10000;
Steady_Release.L (Month)= 8000;


*Constraining the total annual volume
Totyr_volume = Tot_vol(Vol_yr);


loop(Mo,
*constraining the number of steady low flow days in the month
   Steady_Days(Mo) = Num_steady(Mo,case)+ EPS;
* share of each month in the annual volume
   Fr(Mo)= Share(R_Mn,Vol_yr,Mo);

*condition to decide which model to use
if  (Steady_Days(Mo) > weekends(Mo),
     SOLVE Model1 USING LP maximize ObjectiveVal;
else SOLVE Model2 USING LP maximize ObjectiveVal;
);

*Following lines are calculating and saving the objective funcation value at monthly scale
MStore(Vol_yr,R_Mn,Mo,"case1")= sum(p,SteadyEn_Gen.L(Mo,p)*weekendRate(Mo,p))* Steady_Days(Mo) + sum(p,Energy_Gen.L(Mo,p)*weekendRate(Mo,p))*(weekends(Mo)- Steady_Days(Mo))+ sum(p,Energy_Gen.L(Mo,p)*WeekRate(Mo,p))*(Total_Days(Mo)-weekends(Mo));
MStore(Vol_yr,R_Mn,Mo,"case2")= sum(p,SteadyEn_Gen.L(Mo,p)*weekendRate(Mo,p))* Steady_Days(Mo) + sum(p,Energy_Gen.L(Mo,p)*weekendRate(Mo,p))*(weekends(Mo)- Steady_Days(Mo))+ sum(p,Energy_Gen.L(Mo,p)*WeekRate(Mo,p))*(Total_Days(Mo)-weekends(Mo));
MStore(Vol_yr,R_Mn,Mo,"case3")= sum(p,SteadyEn_Gen.L(Mo,p)*weekendRate(Mo,p))* Steady_Days(Mo) + sum(p,Energy_Gen.L(Mo,p)*weekendRate(Mo,p))*(weekends(Mo)- Steady_Days(Mo))+ sum(p,Energy_Gen.L(Mo,p)*WeekRate(Mo,p))*(Total_Days(Mo)-weekends(Mo));
MStore(Vol_yr,R_Mn,Mo,"case4")= sum(p,SteadyEn_Gen.L(Mo,p)*weekendRate(Mo,p))* Steady_Days(Mo) + sum(p,Energy_Gen.L(Mo,p)*weekendRate(Mo,p))*(weekends(Mo)- Steady_Days(Mo))+ sum(p,Energy_Gen.L(Mo,p)*WeekRate(Mo,p))*(Total_Days(Mo)-weekends(Mo));
MStore(Vol_yr,R_Mn,Mo,"case5")= sum(p,SteadyEn_Gen.L(Mo,p)*weekendRate(Mo,p))* Steady_Days(Mo) + sum(p,Energy_Gen.L(Mo,p)*weekendRate(Mo,p))*(weekends(Mo)- Steady_Days(Mo))+ sum(p,Energy_Gen.L(Mo,p)*WeekRate(Mo,p))*(Total_Days(Mo)-weekends(Mo));
MStore(Vol_yr,R_Mn,Mo,"case6")= sum(p,SteadyEn_Gen.L(Mo,p)*weekendRate(Mo,p))* Steady_Days(Mo) + sum(p,Energy_Gen.L(Mo,p)*weekendRate(Mo,p))*(weekends(Mo)- Steady_Days(Mo))+ sum(p,Energy_Gen.L(Mo,p)*WeekRate(Mo,p))*(Total_Days(Mo)-weekends(Mo));
MStore(Vol_yr,R_Mn,Mo,"case7")= sum(p,SteadyEn_Gen.L(Mo,p)*weekendRate(Mo,p))* weekends(Mo) + sum(p,SteadyEn_Gen.L(Mo,p)*WeekRate(Mo,p))*(Steady_Days(Mo)-weekends(Mo))+ sum(p,Energy_Gen.L(Mo,p)*WeekRate(Mo,p))*(Total_Days(Mo)- Steady_Days(Mo));
MStore(Vol_yr,R_Mn,Mo,"case8")= sum(p,SteadyEn_Gen.L(Mo,p)*weekendRate(Mo,p))* weekends(Mo) + sum(p,SteadyEn_Gen.L(Mo,p)*WeekRate(Mo,p))*(Steady_Days(Mo)-weekends(Mo))+ sum(p,Energy_Gen.L(Mo,p)*WeekRate(Mo,p))*(Total_Days(Mo)- Steady_Days(Mo));
MStore(Vol_yr,R_Mn,Mo,"case9")= sum(p,SteadyEn_Gen.L(Mo,p)*weekendRate(Mo,p))* weekends(Mo) + sum(p,SteadyEn_Gen.L(Mo,p)*WeekRate(Mo,p))*(Steady_Days(Mo)-weekends(Mo))+ sum(p,Energy_Gen.L(Mo,p)*WeekRate(Mo,p))*(Total_Days(Mo)- Steady_Days(Mo));
MStore(Vol_yr,R_Mn,Mo,"case10")= sum(p,SteadyEn_Gen.L(Mo,p)*weekendRate(Mo,p))* weekends(Mo) + sum(p,SteadyEn_Gen.L(Mo,p)*WeekRate(Mo,p))*(Steady_Days(Mo)-weekends(Mo))+ sum(p,Energy_Gen.L(Mo,p)*WeekRate(Mo,p))*(Total_Days(Mo)- Steady_Days(Mo));
MStore(Vol_yr,R_Mn,Mo,"case11")= sum(p,SteadyEn_Gen.L(Mo,p)*weekendRate(Mo,p))* weekends(Mo) + sum(p,SteadyEn_Gen.L(Mo,p)*WeekRate(Mo,p))*(Steady_Days(Mo)-weekends(Mo))+ sum(p,Energy_Gen.L(Mo,p)*WeekRate(Mo,p))*(Total_Days(Mo)- Steady_Days(Mo));
MStore(Vol_yr,R_Mn,Mo,"case12")= sum(p,SteadyEn_Gen.L(Mo,p)*weekendRate(Mo,p))* weekends(Mo) + sum(p,SteadyEn_Gen.L(Mo,p)*WeekRate(Mo,p))*(Steady_Days(Mo)-weekends(Mo))+ sum(p,Energy_Gen.L(Mo,p)*WeekRate(Mo,p))*(Total_Days(Mo)- Steady_Days(Mo));


*Storing Energy value on monthly scale
   XStore_steady(Vol_yr,Mo,R_Mn,case)= (Steady_Release.L(Mo)*sum(p,Duration(p))*0.03715)*Num_steady(Mo,case);
   XStore_unsteady(Vol_yr,Mo,R_Mn,case)= sum(p,release.L(Mo,p)*Duration(p)*0.03715)*(Total_Days(Mo)-Num_steady(Mo,case));

*Storing Release value on monthly scale
RStore_steady(Vol_yr,Month,R_Mn,"case1",p)= 0 + EPS;
RStore_steady(Vol_yr,Month,R_Mn,case,p)= Steady_Release.L(Mo);

RStore_unsteady(Vol_yr,Month,R_Mn,case,p)= release.L(Mo,p);
RStore_unsteady(Vol_yr,Month,R_Mn,"case12",p)= 0+ EPS ;

*Storing storage value on monthly scale
 Sstore(Vol_yr,Month,R_Mn,case)=storage.L(Month);

*storaing model status for various combination of the scenarios
   ModelResults(Vol_yr,Mo,R_Mn,"case1","SolStat")= Model2.solvestat;
   ModelResults(Vol_yr,Mo,R_Mn,"case1","ModStat")= Model2.modelstat;
   ModelResults(Vol_yr,Mo,R_Mn,"case2","SolStat")= Model2.solvestat;
   ModelResults(Vol_yr,Mo,R_Mn,"case2","ModStat")= Model2.modelstat;
   ModelResults(Vol_yr,Mo,R_Mn,"case3","SolStat")= Model2.solvestat;
   ModelResults(Vol_yr,Mo,R_Mn,"case3","ModStat")= Model2.modelstat;
   ModelResults(Vol_yr,Mo,R_Mn,"case4","SolStat")= Model2.solvestat;
   ModelResults(Vol_yr,Mo,R_Mn,"case4","ModStat")= Model2.modelstat;
   ModelResults(Vol_yr,Mo,R_Mn,"case5","SolStat")= Model2.solvestat;
   ModelResults(Vol_yr,Mo,R_Mn,"case5","ModStat")= Model2.modelstat;
   ModelResults(Vol_yr,Mo,R_Mn,"case6","SolStat")= Model2.solvestat;
   ModelResults(Vol_yr,Mo,R_Mn,"case6","ModStat")= Model2.modelstat;

   ModelResults(Vol_yr,Mo,R_Mn,case,"SolStat")= Model1.solvestat;
   ModelResults(Vol_yr,Mo,R_Mn,case,"ModStat")= Model1.modelstat;

*Storing the marginal values of the ramp rate constraint for various combination of scenarios
   Mar_Ramp(Vol_yr,Mo,R_Mn,case,p) = EQ7_Rampup_rate.M(Mo)+ EPS;

*clearing the memory before next itteration
   option clear=release,clear=Steady_Release;
);
*Storing objective value for annual scale
   FStore(Vol_yr,R_Mn,case) = ObjectiveVal.L;
);
 DISPLAY FStore,XStore_steady,XStore_unsteady,RStore_steady,RStore_unsteady,Sstore;

*------------------------------------------------------------------------------*
* Dump all input data and results to a GAMS gdx file
Execute_Unload "Results_WY18.gdx";
* Dump the gdx file to an Excel workbook
Execute "gdx2xls Results_WY18.gdx"

