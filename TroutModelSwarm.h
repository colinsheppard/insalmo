/*
inSALMO individual-based salmon model, Version 1.2, April 2013.
Developed and maintained by Steve Railsback, Lang, Railsback & Associates, 
Steve@LangRailsback.com; Colin Sheppard, critter@stanfordalumni.org; and
Steve Jackson, Jackson Scientific Computing, McKinleyville, California.
Development sponsored by US Bureau of Reclamation under the 
Central Valley Project Improvement Act, EPRI, USEPA, USFWS,
USDA Forest Service, and others.
Copyright (C) 2011 Lang, Railsback & Associates.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program (see file LICENSE); if not, write to the
Free Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA.
*/



#import <stdlib.h>
#import <objectbase/Swarm.h>
#import <random.h>

#import "EcoAverager.h"

#import "TroutModelSwarmP.h"

#import "globals.h"
#import "Trout.h"
#import "FallChinook.h"
#import "Redd.h"
#import "HabitatSpace.h"
#import "FishParams.h"
#import "TimeManagerProtocol.h"
#import "HabitatManager.h"
#import "BreakoutReporter.h"
#import "TroutMortalityCount.h"
#import "InterpolationTableP.h"
#import "LogisticFunc.h"
#import "YearShufflerP.h"

#import "DEBUGFLAGS.h"

//#define REDD_SURV_REPORT
//#define PRINT_CELL_FISH_REPORT
//#define REDD_MORTALITY_REPORT  // This used to be a standard output

struct FishSetupStruct
       {
           int speciesNdx;
           id <Symbol> mySpecies;
           int  year;
           char reach[35];
           int number;
           double fracFemale;
           char arrivalStartDate[12];
           char arrivalEndDate[12];
           double ratio;
           double meanLength;
           double stdDevLength;

           time_t arrivalStartTime; 
           time_t arrivalEndTime; 
           int arrivalStartMonth;
           int arrivalStartDay;


           time_t initTime;

           int age;

        };

typedef struct FishSetupStruct SpawnerInitializationRecord; 

@interface TroutModelSwarm: Swarm <TroutModelSwarm>
{

  id observerSwarm;

  id <List> speciesClassList;

  int flowSpaceXSize, flowSpaceYSize;

  int scenario;
  int replicate;

@public
  //
  // POLY Cell Display
  //
  int    polyRasterResolutionX;
  int    polyRasterResolutionY;
  char   polyRasterColorVariable[35];
  double shadeColorMax;


@protected
  id <Zone> modelZone;

  id initAction;
  id oneAction;
  id myAction[15];
  id initFishAction;
  id dropInitFishAction;
  id updateActions;
  id modelActions;
  id fishActions;
  id reddActions;
  id printCellFishAction;
  id overheadActions;
  id modelSchedule;
  id printSchedule;
  id coinFlip;

  id <Activity> modelActivity;

  // 
  // FILE OUTPUT
  //

  //id <List> fishSummaryOutList;
  //id <List> fishMortalityOutList;

  FILE * reddRptFilePtr;
  FILE * reddSummaryFilePtr;
  FILE * lftOutputFilePtr;

  //
  // Changes for LJCMultReachv4.0
  //
  id <List> fishMortSymbolList;
  id <List> reddMortSymbolList;

  id <List> listOfMortalityCounts;
  id <ListIndex> mortalityCountLstNdx;


//THE FOLLOWING VARIABLES ARE INITIALIZED BY Model.Setup
//THE FOLLOWING VARIABLES ARE INITIALIZED BY Model.Setup
//THE FOLLOWING VARIABLES ARE INITIALIZED BY Model.Setup

int          randGenSeed;
int          numberOfSpecies;

int          runStartYear;
int          runStartDay;
char * runStartDate;
char * runEndDate;
const char*  fishOutputFile;
const char*  fishMortalityFile;
// const char*  reddMortalityFile;   This is now an optional output
const char*  reddOutputFile;
const char*  outmigrantOutputFile;
//char* popInitDate;  NOT USED FOR SALMON
int          fileOutputFrequency;
char*        movementRule;

// New for superindividuals
int juvenileSuperindividualRatio;  // Number of juveniles / object

//END VARIABLES INITIALIZED BY Model.Setup
//END VARIABLES INITIALIZED BY Model.Setup
//END VARIABLES INITIALIZED BY Model.Setup

// NEW VARIABLES CONTROLLED BY OR USED BY LIMITING FACTOR TOOL
double numSpawnerAdjuster;  // TO VARY SPAWNER ABUNDANCE
int lftNumTotalOutmigrants; // Cumulative total of all live outmigrants
int lftNumBigOutmigrants;   // Cumulative total of big live outmigrants
double lftBigOutmigrantsSizeThreshold; // Size defining "big" outmigrants

  time_t popInitTime;


  id fishColorMap;

  id <List> speciesSymbolList;  // List of symbols corresp to species studied

  id <List> spawners;
  id <List> liveFish;
  id <List> killedFish;
  id <List> newOutmigrants;
  id <List> outmigrantList;
  id <List> deadFish;
   
  id <List> reddList;
  id <List> reddRemovedList;
  id <List> emptyReddList;

  //id <List> troutDominanceList;

  HabitatManager* habitatManager;
  double siteLatitude;

  int numberOfReaches;
  id <List> reachList;

  /*
   * model parameters -- we don't necessarily need get or set methods
   * for these because we're handling setup from a file.
   */

  //  id randGen; // use the same generator for all random draws in the model

  int numFish;   // number of live trout at any given time
  int numOutmigrants; // Number of fish that outmigrate on current day

  id <List> spawnerInitializationRecords;


  char **speciesPopFile;
  double ***speciesPopTable;
  char **speciesParameter;

  int populationInitYear;   // starting year
  int modelMonth;
  int modelDay;

  BOOL initialDay;
  BOOL updateFish;

  int whenToStart;

  id <TimeManager> timeManager;
  id <Map> fishParamsMap; //One for each species
  id <Map> cmaxInterpolatorMap; //One for each species
  id <Map> spawnDepthInterpolatorMap; //One for each species
  id <Map> spawnVelocityInterpolatorMap; //One for each species
  id <Map> captureLogisticMap; //One for each species
  id <Map> juveOutMigLogisticMap; //One for each species


  time_t modelTime;  // time_t as measured at noon
  char *modelDate;     // mm/dd/yyyy format
  time_t runStartTime;
  time_t runEndTime;

  BOOL shuffleYears;
  BOOL shuffleYearReplace;
  int shuffleYearSeed;
  time_t dataStartTime;
  time_t dataEndTime;
  char dataEndDate[12];
  int startDay;
  int startMonth;
  int startYear;
  int endDay;
  int endMonth;
  int endYear;
  int numSimDays;
  int simCounter;
  int fishCounter;

  BOOL firstTime;

  BOOL appendFiles;


  //
  // Breakout reporters
  //
  BreakoutReporter* fishMortalityReporter;
  BreakoutReporter* liveFishReporter;
  BreakoutReporter* outmigrantReporter;

  id <List> ageSymbolList;
  id <Symbol> Age0;
  id <Symbol> Age1;
  id <Symbol> Age2;
  id <Symbol> Age3;
  id <Symbol> Age4;
  id <Symbol> Age5;
  id <Symbol> Age6Plus;
 
  id <List> lifestageSymbolList;
  id <Symbol> Juvenile;
  id <Symbol> Adult;

  id <List> sizeSymbolList;
  id <Symbol> Size0to5;
  id <Symbol> Size5to8;
  id <Symbol> Size8Plus;

  id <Symbol> outmigrationSymbol;
 

  id <List> reachSymbolList;

  //
  // YearShuffler
  //
  id <YearShuffler> yearShuffler;

  //
  // Binomial Distribution
  //
  id <BinomialDist> reddBinomialDist;

  //
  // Print the fish parameters
  //
  BOOL printFishParams;



}

+ create: aZone;

- instantiateObjects;
- setObserverSwarm: anObserverSwarm;



- buildObjectsWith: theColormaps
           andWith: (double) aShadeColorMax;

-    setPolyRasterResolutionX:  (int) aRasterResolutionX
    setPolyRasterResolutionY:  (int) aRasterResolutionY
  setPolyRasterColorVariable:  (char *) aRasterColorVariable;

- activateIn: swarmContext;

- createCMaxInterpolators;
- createSpawnDepthInterpolators;
- createSpawnVelocityInterpolators;
- createCaptureLogistics;
- createJuveOutMigLogistics;

- createSpawners;
- readFishInitializationFiles;

- createFishParameters;
- buildFishClass;
- buildActions;
- updateTkEventsFor: aReach;


- updateKilledFishList;
- updateNewOutmigrantsList;
- removeKilledFishFromLiveFishList;
- removeOutmigrantsFromLiveFishList;
- sortLiveFish;
//
// GET METHODS
//

- getRandGen;

- (int) getJuvenileSuperindividualRatio;

- (id <List>) getReddList;
- (id <List>) getReddRemovedList;
- processEmptyReddList;

- (HabitatManager *) getHabitatManager;
- addAFish: (Trout *) aTrout;

- addToNewOutmigrants: aJuve;


- (id <List>) getLiveFishList;
- addToKilledList: (Trout *) aFish;
- addToEmptyReddList: aRedd;
- processEmptyReddList;
- (id <List>) getDeadTroutList;
- (id <List>) getOutmigrantList;
- (int) getNumOutmigrants;


- (BOOL) getAppendFiles;
- (int) getScenario;
- (int) getReplicate;

- (id <List>) getSpeciesSymbolList;
- (id <List>) getAgeSymbolList;
- (id <List>) getSizeSymbolList;
- (id <List>) getLifestageSymbolList;
- (id <Symbol>) getAdultLifestageSymbol;
- (id <Symbol>) getJuvenileLifestageSymbol;


#if (DEBUG_LEVEL > 0)
- iAmAlive: (const char *) string;
#endif


//
// DATE HANDLING/RELATED  AND other UPDATE METHODS
//

- (time_t) getModelTime;
- updateModelTime;

- updateHabitatManager;
- updateFish;

- (BOOL) whenToStop;
- initialDayAction;

- switchColorRepFor: aHabitatSpace;
- setShadeColorMax: (double) aShadeColorMax
          inHabitatSpace: aHabitatSpace;
//- setShadeColorMax: (double) aShadeColorMax;
- toggleCellsColorRepIn: aHabitatSpace;



//
//
//

- createNewFishWithSpeciesIndex: (int) speciesNdx  
                           Species: (id <Symbol>) species
                            Length: (double) fishLength
                            Sex: (id <Symbol>) sex;

- setFishColormap: theColormaps;
- readSpeciesSetup;

- (id <List>) getSpeciesClassList;
- (int) getNumberOfSpecies;

- (id <Symbol>) getSpeciesSymbolWithName: (char *) aName;

- writeLFTOutput;  // WRITE OUTPUT FILE FOR LIMITING FACTORS TOOL

//
// REDD OUTPUT
//


#ifdef REDD_REPORT
- printReddReport;
#endif

#ifdef REDD_SURV_REPORT
- printReddSurvReport;
#endif

- openReddSummaryFilePtr;
- (FILE *) getReddSummaryFilePtr;

#ifdef REDD_MORTALITY_REPORT
- openReddReportFilePtr;
#endif
- (FILE *) getReddReportFilePtr;  // This method always must be compiled

- outputInfoToTerminal;


- (id <Zone>) getModelZone;

//
// Added for LJCMultReach version 4.0
//
- (id <Symbol>) getFishMortalitySymbolWithName: (char *) aName;
- (id <Symbol>) getReddMortalitySymbolWithName: (char *) aName;
- (id <Symbol>) getAgeSymbolForAge: (int) anAge;
- (id <Symbol>) getSizeSymbolForLength: (double) aLength;
- (id <Symbol>) getReachSymbolWithName: (char *) aName;
- (id <BinomialDist>) getReddBinomialDist;

- (id <Symbol>) getOutmigrationSymbol;

- createBreakoutReporters;
- outputBreakoutReports;

- createYearShuffler;


- updateMortalityCountWith: aDeadFish;
- (id <List>) getListOfMortalityCounts;





- (void) drop;
- outputModelZone: (id <Zone>) anArbitraryZone;

@end

