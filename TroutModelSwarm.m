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



#import <math.h>
#import <simtools.h>
#import <objectbase/SwarmObject.h>
#import <random.h>
#import "FishParams.h"
#import "TroutModelSwarm.h"

/*
@protocol Observer 
- (id <Raster>) getWorldRaster;
@end
*/


id <Symbol> *mySpecies;
id <Symbol> Female, Male, CoinFlip;  // sex of fish
Class *MyTroutClass; 
char **speciesName;
char **speciesColor;

@implementation TroutModelSwarm

+ create: aZone 
{
  TroutModelSwarm* troutModelSwarm;

  troutModelSwarm = [super create: aZone];

  //troutModelSwarm->popInitDate = (char *) nil;
  troutModelSwarm->observerSwarm = nil;
  troutModelSwarm->initialDay=YES;
  troutModelSwarm->updateFish=NO;
  troutModelSwarm->numberOfSpecies=0;
  troutModelSwarm->timeManager = nil;
  troutModelSwarm->fishColorMap = nil;

  troutModelSwarm->printFishParams = NO;


  return troutModelSwarm;

}



//////////////////////////////////////////////////////////////
//
// instantiateObjects
//
/////////////////////////////////////////////////////////////
- instantiateObjects 
{
   int numspecies;

   modelZone = [Zone create: globalZone];

  #ifdef DEBUG_TROUT_FISHPARAMS

     fprintf(stdout,"TroutModelSwarm instantiateObjects \n");
     fflush(0);

  #endif

  if(numberOfSpecies == 0)
  {
     fprintf(stderr, "ERROR: TroutModelSwarm >>>> instantiateObjects >>>> numberOfSpecies is zero\n"); 
     fflush(0);
     exit(1);
  }

  [self readSpeciesSetup];

  //
  // Create list of species symbols
  //
  mySpecies = (id *) [modelZone alloc: numberOfSpecies*sizeof(Symbol)];
  for(numspecies = 0; numspecies < numberOfSpecies; numspecies++ )
  {
     mySpecies[numspecies] = [Symbol create: modelZone setName: speciesName[numspecies] ];
  }

  speciesSymbolList = [List create: modelZone];
  for(numspecies = 0; numspecies < numberOfSpecies; numspecies++ )
  {
    [speciesSymbolList addLast: mySpecies[numspecies] ];
  }

  //
  // The mortality symbol lists
  // 
  listOfMortalityCounts = [List create: modelZone];

  fishMortSymbolList = [List create: modelZone];
  reddMortSymbolList = [List create: modelZone];

  [self getFishMortalitySymbolWithName: "DemonicIntrusion"];
  outmigrationSymbol = [Symbol create: modelZone setName: "Outmigration"];

  fishParamsMap = [Map create: modelZone];

  [self createFishParameters];

  //
  // To create additional age classes, add more symbols to this list.
  // Then modify the code in getAgeSymbolForAge 
  // that assigns symbols to fish.
  // 
  ageSymbolList = [List create: modelZone];

  Age0     = [Symbol create: modelZone setName: "Age0"];
  [ageSymbolList addLast: Age0];
  Age1     = [Symbol create: modelZone setName: "Age1"];
  [ageSymbolList addLast: Age1];
  Age2     = [Symbol create: modelZone setName: "Age2"];
  [ageSymbolList addLast: Age2];
  Age3     = [Symbol create: modelZone setName: "Age3"];
  [ageSymbolList addLast: Age3];
  Age4     = [Symbol create: modelZone setName: "Age4"];
  [ageSymbolList addLast: Age4];
  Age5     = [Symbol create: modelZone setName: "Age5"];
  [ageSymbolList addLast: Age5];
  Age6Plus = [Symbol create: modelZone setName: "Age6Plus"];
  [ageSymbolList addLast: Age6Plus];

  //
  // Size classes for salmon outmigrants.
  // 
  sizeSymbolList = [List create: modelZone];

  Size0to5     = [Symbol create: modelZone setName: "Size0to5"];
  [sizeSymbolList addLast: Size0to5];
  Size5to8     = [Symbol create: modelZone setName: "Size5to8"];
  [sizeSymbolList addLast: Size5to8];
  Size8Plus     = [Symbol create: modelZone setName: "Size8Plus"];
  [sizeSymbolList addLast: Size8Plus];

  //
  // Life stages for salmon.
  // 
  lifestageSymbolList = [List create: modelZone];

  Juvenile     = [Symbol create: modelZone setName: "Juvenile"];
  [lifestageSymbolList addLast: Juvenile];
  Adult     = [Symbol create: modelZone setName: "Adult"];
  [lifestageSymbolList addLast: Adult];

  reachSymbolList = [List create: modelZone];

  fishCounter = 0;
  lftNumTotalOutmigrants = 0; // Cumulative total of all live outmigrants
  lftNumBigOutmigrants = 0;   // Cumulative total of big live outmigrants
  lftBigOutmigrantsSizeThreshold = 5.0;  // "Big" outmigrants have length > this 


  fprintf(stdout, "TroutModelSwarm >>>> buildObjects >>> instantiateObjects >>>> BEFORE HabitatManager\n");
  fflush(0);

  habitatManager = [HabitatManager createBegin: modelZone];
  [habitatManager instantiateObjects];

  //
  // Moved to buildObjects
  //
  //[habitatManager  setPolyRasterResolution:  polyRasterResolution
                  //setPolyRasterResolutionX:  polyRasterResolutionX
                  //setPolyRasterResolutionY:  polyRasterResolutionY
                   //setRasterColorVariable:   polyRasterColorVariable
                          //setShadeColorMax:  shadeColorMax];

  [habitatManager setSiteLatitude: siteLatitude];
  [habitatManager createSolarManager];
  [habitatManager setModel: self];
  [habitatManager readReachSetupFile: "Reach.Setup"];
  [habitatManager setNumberOfSpecies: numberOfSpecies];
  [habitatManager setFishParamsMap: fishParamsMap];
  [habitatManager instantiateHabitatSpacesInZone: modelZone];

  fprintf(stdout, "TroutModelSwarm >>>> instantiateObjects >>>> AFTER HabitatManager\n");
  fflush(0);

  // New Sept. 2011 for Limiting Factors Tool
  if (numSpawnerAdjuster == 0.0) { numSpawnerAdjuster = 1.0; }

  return self;

}

/////////////////////////////////////////////////////////////
//
// setPolyRasterResolution
//
/////////////////////////////////////////////////////////////
-   setPolyRasterResolutionX:  (int) aRasterResolutionX
    setPolyRasterResolutionY:  (int) aRasterResolutionY
  setPolyRasterColorVariable:  (char *) aRasterColorVariable
{
     polyRasterResolutionX = aRasterResolutionX;
     polyRasterResolutionY = aRasterResolutionY;
     strncpy(polyRasterColorVariable, aRasterColorVariable, 35);


     return self;
}

/////////////////////////////////////
//
// setObserverSwarm
//
////////////////////////////////////
- setObserverSwarm: anObserverSwarm
{
    observerSwarm = anObserverSwarm;
    return self;
}

//////////////////////////////////////////////////////////////////
//
// buildObjects
//
/////////////////////////////////////////////////////////////////
- buildObjectsWith: theColormaps
          andWith: (double) aShadeColorMax
{
  int genSeed;
  time_t newYearTime = (time_t) 0;

  fprintf(stdout, "TroutModelSwarm >>>> buildObjects >>>> BEGIN\n");
  fflush(0);

  shadeColorMax = aShadeColorMax;

  firstTime = YES;

  //
  // if we're a sub-swarm, then run our super's buildObjects first
  //
  [super buildObjects];

  timeManager = [TimeManager create: modelZone
                      setController: self
                        setTimeStep: (time_t) 86400
             setCurrentTimeWithDate: runStartDate
                           withHour: 12
                         withMinute: 0
                         withSecond: 0];

 [timeManager setDefaultHour: 12
            setDefaultMinute: 0
            setDefaultSecond: 0];


 timeManager = [timeManager createEnd];

 runStartTime = [timeManager getTimeTWithDate: runStartDate];







 runEndTime = [timeManager getTimeTWithDate: runEndDate];

  modelDate = (char *) [modelZone alloc: 15*sizeof(char)];

  modelTime = runStartTime; 

  if(runStartTime > runEndTime)
  {
     fprintf(stderr, "ERROR: TroutModelSwarm >>>> buildObjects >>>> Check runStartDate and runEndDate in Model.Setup\n");
     fflush(0);
     exit(1);
  }

  //
  // set up the random number generator to be used throughout the model
  //
  if(replicate != 0) 
  {
      genSeed = randGenSeed * replicate;
  }
  else
  {
      genSeed = randGenSeed;
  }

  randGen = [MT19937gen create: modelZone 
              setStateFromSeed: genSeed];

  //
  // coinFlip used to decide the sex of a new fish
  //
  coinFlip = [RandomBitDist create: modelZone
                      setGenerator: randGen];

  //
  // Create the Classes that instantiate the fish
  //
  [self buildFishClass];

  numSimDays = [timeManager getNumberOfDaysBetween: runStartTime and: runEndTime] + 1;
  simCounter = 1;

  if(shuffleYears == YES)
  {
     //
     // Create the year shuffler and the data start and end times.
     //
     [self createYearShuffler];
      newYearTime = [yearShuffler checkForNewYearAt: modelTime];

      if (newYearTime != modelTime)
      {
         [timeManager setCurrentTime: newYearTime];
         modelTime = newYearTime;
      }
  }
  else
  {
      modelTime = runStartTime;
      dataStartTime = runStartTime;
      dataEndTime = runEndTime + 86400;
  }

  fprintf(stdout, "TroutModelSwarm >>>> buildObjects >>>> scenario = %d\n", scenario);
  fprintf(stdout, "TroutModelSwarm >>>> buildObjects >>>> replicate = %d\n", replicate);
  fflush(0);


  //
  // Create the space in which the fish will live
  //
  [habitatManager setTimeManager: timeManager];

  [habitatManager setModelStartTime: (time_t) runStartTime
                         andEndTime: (time_t) runEndTime];

  [habitatManager setDataStartTime: (time_t) dataStartTime
                        andEndTime: (time_t) dataEndTime];

  //
  // Moved from instantiateObjects 
  //
  [habitatManager setPolyRasterResolutionX:  polyRasterResolutionX
                  setPolyRasterResolutionY:  polyRasterResolutionY
                    setRasterColorVariable:   polyRasterColorVariable
                          setShadeColorMax:  shadeColorMax];

  [habitatManager buildObjects];

  #ifdef PRINT_CELL_FISH_REPORT
      [habitatManager buildHabSpaceCellFishInfoReporter];
  #endif

  [habitatManager updateHabitatManagerWithTime: modelTime
                         andWithModelStartFlag: initialDay];

  numberOfReaches = [habitatManager getNumberOfHabitatSpaces];
  reachList = [habitatManager getHabitatSpaceList];

  //
  // set up fish lists
  //
  liveFish = [List create: modelZone];
  spawners = [List create: modelZone];
  killedFish = [List create: modelZone];
  deadFish = [List create: modelZone];
  newOutmigrants = [List create: modelZone];
  outmigrantList = [List create: modelZone];

  Male = [Symbol create: modelZone setName: "Male"];
  Female = [Symbol create: modelZone setName: "Female"];

  if(numberOfSpecies == 0)
  {
     fprintf(stderr, "ERROR: TroutModelSwarm >>>> buildObjects numberOfSpecies is ZERO!\n"); 
     fflush(0);
     exit(1);
  }

  reddList = [List create: modelZone];
  reddRemovedList = [List create: modelZone];
  emptyReddList = [List create: modelZone];

  if(theColormaps != nil) 
  {
      [self setFishColormap: theColormaps];
  }


  //
  // This can only be done once the fish parameter objects have been created
  // and initialized
  //
  cmaxInterpolatorMap = [Map create: modelZone];
  spawnDepthInterpolatorMap = [Map create: modelZone];
  spawnVelocityInterpolatorMap = [Map create: modelZone];
  captureLogisticMap = [Map create: modelZone];
  juveOutMigLogisticMap = [Map create: modelZone];
  [self createCMaxInterpolators];
  [self createSpawnDepthInterpolators];
  [self createSpawnVelocityInterpolators];
  [self createCaptureLogistics];
  [self createJuveOutMigLogistics];

  spawnerInitializationRecords = [List create: modelZone];

  [self createSpawners];
  [self sortLiveFish];

  reddBinomialDist = [BinomialDist create: modelZone setGenerator: randGen];

  [self openReddSummaryFilePtr];

#ifdef REDD_MORTALITY_REPORT
  [self openReddReportFilePtr];
#endif
  [self createBreakoutReporters];


  fprintf(stdout, "TroutModelSwarm >>> buildObjects >>>> runStartTime = %ld\n", (long) runStartTime);
  fprintf(stdout, "TroutModelSwarm >>> buildObjects >>>> runStartDate = %s\n", [timeManager getDateWithTimeT: runStartTime]);
  fprintf(stdout, "TroutModelSwarm >>> buildObjects >>>> modelTime = %ld\n", (long) modelTime);
  fprintf(stdout, "TroutModelSwarm >>> buildObjects >>>> modelTime = %s\n", [timeManager getDateWithTimeT: modelTime]);
  fflush(0);

  if(printFishParams)
  {
     int speciesNdx;
     for(speciesNdx = 0; speciesNdx < numberOfSpecies; speciesNdx++) 
     {
        [[fishParamsMap at: mySpecies[speciesNdx]] printSelf]; 
     }
  }


  fprintf(stdout, "TroutModelSwarm >>>> buildObjects >>>> END\n");
  fflush(0);

  return self;

}  // buildObjects  


//////////////////////////////////////////////////////
//
// createFishParameters
//
// Create parameter objects for the fish
// parameters
//
/////////////////////////////////////////////////////
- createFishParameters
{
   int speciesNdx;

   fprintf(stdout, "TroutMOdelSwarm >>>> createFishParameters >>>> BEGIN\n");
   fflush(0);


   for(speciesNdx = 0; speciesNdx < numberOfSpecies; speciesNdx++) 
   {
      FishParams* fishParams = [FishParams createBegin:  modelZone];
      [ObjectLoader load: fishParams fromFileNamed: speciesParameter[speciesNdx]];
 
      [fishParams setFishSpeciesIndex: speciesNdx]; 
      [fishParams setFishSpecies: mySpecies[speciesNdx]]; 

      [fishParams setInstanceName: (char *) [mySpecies[speciesNdx] getName]];

      fishParams = [fishParams createEnd];

      #ifdef DEBUG_TROUT_FISHPARAMS
         [fishParams printSelf];
      #endif

      [fishParamsMap at: [fishParams getFishSpecies] insert: fishParams]; 
   }


   fprintf(stdout, "TroutMOdelSwarm >>>> createFishParameters >>>> END\n");
   fflush(0);
   return self;

}  // createFishParameters



/////////////////////////////////////////////////////////
//
// setFishColormap
//
//////////////////////////////////////////////
- setFishColormap: theColormaps 
{
  id <ListIndex> speciesNdx;
  int speciesIDX=0;
  id nextSpecies= nil;
  int FISH_COLOR= (int) FISHCOLORSTART;
  id <MapIndex> clrMapNdx = [theColormaps mapBegin: scratchZone];
  id <Colormap> aColorMap = nil;

  //fprintf(stdout, "TroutModelSwarm >>>> setFishColormap >>>> BEGIN\n");
  //fprintf(stdout, "TroutModelSwarm >>>> setFishColormap >>>> tagFishColor = %s \n", theTagFishColor);
  //xprint(theColormaps);
  //fflush(0);

  while(([clrMapNdx getLoc] != End) && ((aColorMap = [clrMapNdx next]) != nil))
  {
     [aColorMap setColor: FISH_COLOR 
                  ToName: "white"];
  }

  fishColorMap = [Map create: modelZone];

  FISH_COLOR++;

  //fprintf(stdout, "TroutModelSwarm >>>> setFishColormap >>>> FISH_COLOR = %d\n", FISH_COLOR);
  //fflush(0);


  speciesNdx = [speciesSymbolList listBegin: scratchZone];
  while(([speciesNdx getLoc] != End) && ((nextSpecies = [speciesNdx next]) != nil)) 
  {
      long* thisFishColor = [modelZone alloc: sizeof(long)];
      *thisFishColor = FISH_COLOR++;
  //fprintf(stdout, "TroutModelSwarm >>>> setFishColormap >>>> in while >>>> FISH_COLOR = %d\n", FISH_COLOR);
  //fflush(0);

      [clrMapNdx setLoc: Start];
     
      while(([clrMapNdx getLoc] != End) && ((aColorMap = [clrMapNdx next]) != nil))
      {
          //  xprint(aColorMap);
            [aColorMap setColor: FISH_COLOR 
                         ToName: speciesColor[speciesIDX]];
      }

      *thisFishColor = FISH_COLOR;

      FISH_COLOR++;

      [fishColorMap at: nextSpecies insert: (void *) thisFishColor];

      speciesIDX++;
  }

  [speciesNdx drop];
  [clrMapNdx drop];

  //fprintf(stdout, "TroutModelSwarm >>>> setFishColormap >>>> END\n");
  //fflush(0);


  //exit(0);

  return self;
}


/////////////////////////////////////////
//
// createCMaxInterpolators
//
/////////////////////////////////////////
- createCMaxInterpolators
{
  id <MapIndex> mapNdx;
  FishParams* fishParams;

  mapNdx = [fishParamsMap mapBegin: scratchZone];
 
  while(([mapNdx getLoc] != End) && ((fishParams = (FishParams *) [mapNdx next]) != nil))
  {
     id <InterpolationTable> cmaxInterpolationTable = [InterpolationTable create: modelZone];

     [cmaxInterpolationTable addX: fishParams->fishCmaxTempT1 Y: fishParams->fishCmaxTempF1];
     [cmaxInterpolationTable addX: fishParams->fishCmaxTempT2 Y: fishParams->fishCmaxTempF2];
     [cmaxInterpolationTable addX: fishParams->fishCmaxTempT3 Y: fishParams->fishCmaxTempF3];
     [cmaxInterpolationTable addX: fishParams->fishCmaxTempT4 Y: fishParams->fishCmaxTempF4];
     [cmaxInterpolationTable addX: fishParams->fishCmaxTempT5 Y: fishParams->fishCmaxTempF5];
     [cmaxInterpolationTable addX: fishParams->fishCmaxTempT6 Y: fishParams->fishCmaxTempF6];
     [cmaxInterpolationTable addX: fishParams->fishCmaxTempT7 Y: fishParams->fishCmaxTempF7];

     [cmaxInterpolatorMap at: [fishParams getFishSpecies] insert: cmaxInterpolationTable]; 
  }

  return self;
}

////////////////////////////////////////////////
//
// createSpawnDepthInterpolators
//
////////////////////////////////////////////////
- createSpawnDepthInterpolators
{
  id <Index> mapNdx;
  FishParams* fishParams;

  mapNdx = [fishParamsMap mapBegin: scratchZone];
 
  while(([mapNdx getLoc] != End) && ((fishParams = (FishParams *) [mapNdx next]) != nil))
  {
     id <InterpolationTable> spawnDepthInterpolationTable = [InterpolationTable create: modelZone];

     [spawnDepthInterpolationTable addX: fishParams->fishSpawnDSuitD1 Y: fishParams->fishSpawnDSuitS1];
     [spawnDepthInterpolationTable addX: fishParams->fishSpawnDSuitD2 Y: fishParams->fishSpawnDSuitS2];
     [spawnDepthInterpolationTable addX: fishParams->fishSpawnDSuitD3 Y: fishParams->fishSpawnDSuitS3];
     [spawnDepthInterpolationTable addX: fishParams->fishSpawnDSuitD4 Y: fishParams->fishSpawnDSuitS4];
     [spawnDepthInterpolationTable addX: fishParams->fishSpawnDSuitD5 Y: fishParams->fishSpawnDSuitS5];

     [spawnDepthInterpolatorMap at: [fishParams getFishSpecies] insert: spawnDepthInterpolationTable]; 
  }

  return self;
}


////////////////////////////////////////////
//
// createSpawnVelocityInterpolators
//
///////////////////////////////////////////
- createSpawnVelocityInterpolators
{
  id <Index> mapNdx;
  FishParams* fishParams;

  mapNdx = [fishParamsMap mapBegin: scratchZone];
 
  while(([mapNdx getLoc] != End) && ((fishParams = (FishParams *) [mapNdx next]) != nil))
  {
     id <InterpolationTable> spawnVelocityInterpolationTable = [InterpolationTable create: modelZone];

     [spawnVelocityInterpolationTable addX: fishParams->fishSpawnVSuitV1 Y: fishParams->fishSpawnVSuitS1];
     [spawnVelocityInterpolationTable addX: fishParams->fishSpawnVSuitV2 Y: fishParams->fishSpawnVSuitS2];
     [spawnVelocityInterpolationTable addX: fishParams->fishSpawnVSuitV3 Y: fishParams->fishSpawnVSuitS3];
     [spawnVelocityInterpolationTable addX: fishParams->fishSpawnVSuitV4 Y: fishParams->fishSpawnVSuitS4];
     [spawnVelocityInterpolationTable addX: fishParams->fishSpawnVSuitV5 Y: fishParams->fishSpawnVSuitS5];
     [spawnVelocityInterpolationTable addX: fishParams->fishSpawnVSuitV6 Y: fishParams->fishSpawnVSuitS6];

     [spawnVelocityInterpolatorMap at: [fishParams getFishSpecies] insert: spawnVelocityInterpolationTable]; 
  }

  return self;
}


/////////////////////////////////////////////////
//
// createCaptureLogistics
//
/////////////////////////////////////////////////
- createCaptureLogistics
{
  id <Index> mapNdx;
  FishParams* fishParams;

  mapNdx = [fishParamsMap mapBegin: scratchZone];
 
  while(([mapNdx getLoc] != End) && ((fishParams = (FishParams *) [mapNdx next]) != nil))
  {
      //
      // getCellVelocity is not actually used;
      // it is there because the logistic
      // needs an input method. The fish
      // evaluates for velocity/aMaxSwimSpeed
      //
      LogisticFunc* aCaptureLogistic = [LogisticFunc createBegin: modelZone 
                                                 withInputMethod: M(getPolyCellVelocity) 
                                                      usingIndep: fishParams->fishCaptureParam1
                                                             dep: 0.1
                                                           indep: fishParams->fishCaptureParam9
                                                             dep: 0.9];

     [captureLogisticMap at: [fishParams getFishSpecies] insert: aCaptureLogistic]; 
  }

  return self;
}


//////////////////////////////////////////////////////////
//
// createJuveOutMigLogistics
//
///////////////////////////////////////////////////////////
- createJuveOutMigLogistics
{

  id <Index> mapNdx;
  FishParams* fishParams;

  mapNdx = [fishParamsMap mapBegin: scratchZone];
 
  while(([mapNdx getLoc] != End) && ((fishParams = (FishParams *) [mapNdx next]) != nil))
  {
      LogisticFunc* anJuveOutMigLogistic = [LogisticFunc createBegin: modelZone 
                                                     withInputMethod: M(getFishLength) 
                                                          usingIndep: fishParams->fishOutmigrateSuccessL1
                                                                 dep: 0.1
                                                               indep: fishParams->fishOutmigrateSuccessL9
                                                                 dep: 0.9];
  
     [juveOutMigLogisticMap at: [fishParams getFishSpecies] insert: anJuveOutMigLogistic]; 
  }


     return self;
}


//////////////////////////////////////////
//
// createSpawners
//
// Create the initial list of spawners
//
//////////////////////////////////////////
- createSpawners
{
   id <Symbol> species = nil;
   id <ListIndex> fishInitNdx = nil;
   SpawnerInitializationRecord* fishInitRecord = (SpawnerInitializationRecord *) nil;

   id aHabitatSpace;

   int numFishThisYear = 0;
   int numFemalesThisYear = 0;
   int fishNdx = 0;


   fprintf(stdout,"TroutModelSwarm >>>> createSpawners >>>> BEGIN\n");
   fflush(0);

   //
   // Read the population files for each species
   // and create the fish initialization records
   //
   [self readFishInitializationFiles];

   xprint(spawnerInitializationRecords);

   fishInitNdx = [spawnerInitializationRecords listBegin: scratchZone];

   numFish = 0;

   //
   // Now, read the fish initialization records and create the fish.
   //
   while(([fishInitNdx getLoc] != End) && ((fishInitRecord = (SpawnerInitializationRecord *) [fishInitNdx next]) != (SpawnerInitializationRecord *) nil)){
       if(fishInitRecord->mySpecies != (species = [speciesSymbolList atOffset: fishInitRecord->speciesNdx])){
            fprintf(stderr, "ERROR: TroutModelSwarm >>>> createSpawners >>>> incorrect speciesNdx\n");
            fflush(0);
            exit(1);
       }
       //fprintf(stdout,"TroutModelSwarm >>>> createSpawners >>>> fishInitRecord->arrivalStartTime = %d , runStartTime,runEndTime = %d, %d\n",
       //fishInitRecord->arrivalStartTime,runStartTime,runEndTime);
       //fflush(0);
       if((fishInitRecord->arrivalStartTime > runEndTime) || (fishInitRecord->arrivalEndTime < runStartTime)){
          // Initialization record is not for this year so skip it
          continue;
       }
       aHabitatSpace = [habitatManager getReachWithName: fishInitRecord->reach];


       if(aHabitatSpace == nil){
            //
            // Then skip it and move on
            //
            fprintf(stderr, "WARNING: TroutModelSwarm >>>> createSpawners >>>> spawner init file includes non-existant reach %s\n", fishInitRecord->reach);
            fflush(0);
            continue;
       }
       if(fishInitRecord->number != 0){
          //
          // This distribution will only be used in this routine
          // and then goes out of scope.
          //
          id doubleNormDist1 = nil; 
          id arrivalTimeDist = nil; 

          //double spawnerMeanArrivalTime = (fishInitRecord->arrivalStartTime + fishInitRecord->arrivalEndTime)/2.0;
          double spawnerMeanArrivalTime = ((fishInitRecord->arrivalStartTime/2.0) + (fishInitRecord->arrivalEndTime/2.0));
          double spawnerStdDevArrivalTime = (fishInitRecord->arrivalEndTime - fishInitRecord->arrivalStartTime)/(2.0*sqrt(-2.0*log(fishInitRecord->ratio))); 
           
          doubleNormDist1 = [NormalDist create: modelZone setGenerator: randGen
                                       setMean: fishInitRecord->meanLength
                                     setStdDev: fishInitRecord->stdDevLength];

          arrivalTimeDist = [NormalDist create: modelZone setGenerator: randGen
                                            setMean: spawnerMeanArrivalTime
                                          setStdDev: spawnerStdDevArrivalTime];

          // numFishThisYear = fishInitRecord->number; Let LFT control # spawners
	  numFishThisYear = (int) floor( ((double) fishInitRecord->number) * numSpawnerAdjuster + 0.5);
	  numFemalesThisYear = (int) floor( ((double) numFishThisYear) * fishInitRecord->fracFemale + 0.5);
	  fprintf(stdout, "TroutModelSwarm >>>> createSpawners >>>> numFishThisYear = %d  fracFemale = %f  numFemalesThisYear = %d \n", numFishThisYear, fishInitRecord->fracFemale, numFemalesThisYear);
	  fflush(0);
 
          //
          //  build the population list for this species in this reach
          //
          for(fishNdx=0; fishNdx<numFishThisYear; fishNdx++){
             id newSpawner;
	     double length = 0.0;
             time_t arrivalTime = 0;
	     id<Symbol> sex = (fishNdx >= numFemalesThisYear) ? Male : Female;
  
	    //if(sex == Female){
	      //fprintf(stdout, "TroutModelSwarm >>>> createSpawners >>>> Female created\n");
	      //fflush(0);
	    //}else if (sex == Male){
	      //fprintf(stdout, "TroutModelSwarm >>>> createSpawners >>>> Male created\n");
	      //fflush(0);
	    //}else{
	      //fprintf(stdout, "TroutModelSwarm >>>> createSpawners >>>> Error, sex not recognized\n");
	      //fflush(0);
	    //}

             //
	     // set properties of the new Trout
             //
	     while((length = [doubleNormDist1 getDoubleSample]) <= (0.5)*[doubleNormDist1 getMean]){
                 ;  // do nothing, just waiting for condition to fail
             }

	     newSpawner = [self createNewFishWithSpeciesIndex: fishInitRecord->speciesNdx  
                                                         Species: fishInitRecord->mySpecies 
                                                          Length: length
							     Sex: sex
							  ];

             [newSpawner setIsSpawner: YES];
             [newSpawner setAge: 5];           //Temporary fix to give spawners an age
             [newSpawner setAgeSymbol: [self getAgeSymbolForAge: 5]];
             [newSpawner setLifestageSymbol: Adult];
             [newSpawner calcMaxMoveDistance];
             [newSpawner setFishFeedingStrategy: SPAWNER];
             [newSpawner setNRep: 1]; // Spawners are not superindividuals

	     [spawners addLast: newSpawner];
             [newSpawner setReach: aHabitatSpace];

             arrivalTime = -1;
	     BOOL arrivalTimeOK = FALSE;
	     while(!arrivalTimeOK){
		   arrivalTime = (time_t) [arrivalTimeDist getDoubleSample];  
		   arrivalTimeOK = (fishInitRecord->arrivalStartTime <= arrivalTime) && (arrivalTime <= fishInitRecord->arrivalEndTime);
		   //fprintf(stdout, "TroutModelSwarm >>>> createSpawners >>>> arrivalTimeOK = %d\n", (int) arrivalTimeOK);
		   //fprintf(stdout, "TroutModelSwarm >>>> createSpawners >>>> arrivalDate = %s\n", [timeManager getDateWithTimeT: arrivalTime]);
		   //fflush(0);
	      }
             
             [newSpawner setArrivalTime: arrivalTime];

         } // end numFish/Age loop

	  // cleanup
	  [doubleNormDist1 drop];

      }  //if fishInitRecord->number != 0

  } //while fishInitRecord

  [fishInitNdx drop];

  fprintf(stdout,"TroutModelSwarm >>>> createInitialFish >>>> [liveFish getCount] = %d\n", [liveFish getCount]);
  fprintf(stdout,"TroutModelSwarm >>>> createInitialFish >>>> [spawners getCount] = %d\n", [spawners getCount]);
  fprintf(stdout,"TroutModelSwarm >>>> createInitialFish >>>> END\n");
  fflush(0);

  [QSort sortObjectsIn: spawners using: M(compareArrivalTime:)];

/*
   id <ListIndex> ndx = [spawners listBegin: scratchZone];
   id aSpawner = nil;
   while(([ndx getLoc] != End) && ((aSpawner = [ndx next]) != nil))
   {
	 time_t arrivalTime = [aSpawner getArrivalTime];
	 fprintf(stdout, "TroutModelSwarm >>>> createSpawners >>>> arrivalDate = %s\n", [timeManager getDateWithTimeT: arrivalTime]);
	 fflush(0);

   }
   [ndx drop];
*/
   fprintf(stdout,"TroutModelSwarm >>>> createSpawners >>>> END\n");
   fflush(0);

   return self;
}

///////////////////////////////////////
//
// readFishInitializationFiles
//
//////////////////////////////////////
- readFishInitializationFiles
{
  FILE* initFilePtr=NULL;
  int numSpeciesNdx;
  char * header1=(char *) NULL;

  char* inputFormat;
  char inputString[300];

  char year[5];
  char reach[35];
  char number[10];
  char fracFemale[10];
  char arrivalStartDate[12];
  char arrivalEndDate[12];
  char ratio[10];
  char meanLength[10];
  char stdDevLength[10];

  fprintf(stdout,"TroutModelSwarm >>>> readFishInitializationFiles >>>> BEGIN\n");
  fflush(0);

  inputFormat =  "%[0-9] %*1[,] \
                   %[a-zA-Z_-0-9] %*1[,] \
                   %[0-9] %*1[,] \
                   %[0-9.] %*1[,] \
                   %[0-9/] %*1[,] \
                   %[0-9/] %*1[,] \
                   %[0-9.] %*1[,] \
                   %[0-9.] %*1[,] \
                   %[0-9.] %*1[,]";

  for(numSpeciesNdx=0; numSpeciesNdx<numberOfSpecies; numSpeciesNdx++){
      if((initFilePtr = fopen(speciesPopFile[numSpeciesNdx], "r")) == NULL){
          fprintf(stderr, "ERROR: TroutModelSwarm >>>> readFishInitializationFiles >>>> Error opening %s \n", speciesPopFile[numSpeciesNdx]);
          fflush(0);
          exit(1);
      }

      header1 = (char *)[scratchZone alloc: HCOMMENTLENGTH*sizeof(char)];

      fgets(header1,HCOMMENTLENGTH,initFilePtr);
      fgets(header1,HCOMMENTLENGTH,initFilePtr);
      fgets(header1,HCOMMENTLENGTH,initFilePtr);

      while(EOF != fscanf(initFilePtr, "%s", inputString)){
           SpawnerInitializationRecord*  fishRecord;

           fishRecord = (SpawnerInitializationRecord *) [modelZone alloc: sizeof(SpawnerInitializationRecord)];

           sscanf(inputString, inputFormat, year,
                                            reach,
                                            number,
					    fracFemale,
                                            arrivalStartDate,
                                            arrivalEndDate,
                                            ratio,
                                            meanLength,
                                            stdDevLength);

           fprintf(stdout, "%s %s %s %s %s %s %s %s %s\n", year,
                                                        reach,
                                                        number,
							fracFemale,
                                                        arrivalStartDate,
                                                        arrivalEndDate,
                                                        ratio,
                                                        meanLength,
                                                        stdDevLength);
           fflush(0);


           fishRecord->speciesNdx = numSpeciesNdx;
           fishRecord->mySpecies = mySpecies[numSpeciesNdx];
           fishRecord->year = atoi(year);
           strncpy(fishRecord->reach, reach, 35);
           fishRecord->number = atoi(number);
           fishRecord->fracFemale = atof(fracFemale);
           fishRecord->arrivalStartTime = [timeManager getTimeTWithDate: arrivalStartDate];
           fishRecord->arrivalEndTime = [timeManager getTimeTWithDate: arrivalEndDate];
           fishRecord->ratio = atof(ratio);
           fishRecord->meanLength = atof(meanLength);
           fishRecord->stdDevLength = atof(stdDevLength);

	   //fprintf(stdout, "TroutModelSwarm >>>> checking fish records >>>>>\n");
	   //fprintf(stdout, "speciesNdx = %d speciesName = %s year = %d reach = %s number = %d arrivalStartTime = %ld arrivalEndTime = %ld ratio = %f meanLength = %f stdDevLength = %f\n",
                                           //fishRecord->speciesNdx,
                                           //[fishRecord->mySpecies getName],
                                           //fishRecord->year,
                                           //fishRecord->reach,
                                           //fishRecord->number,
                                           //(long) fishRecord->arrivalStartTime,
                                           //(long) fishRecord->arrivalEndTime,
                                           //fishRecord->ratio,
                                           //fishRecord->meanLength,
                                           //fishRecord->stdDevLength);
           //fflush(0);
           [spawnerInitializationRecords addLast: (void *) fishRecord];
     } //while !EOF
     fclose(initFilePtr);
  } //for numberOfSpecies

  [scratchZone free: header1];

  xprint(spawnerInitializationRecords);

  fprintf(stdout,"TroutModelSwarm >>>> readFishInitializationFiles >>>> END\n");
  fflush(0);

  //exit(0);

  return self;
} 

//////////////////////////////////////////////////////////////////////
//
// buildActions
//
///////////////////////////////////////////////////////////////////////
- buildActions 
{
 
  [super buildActions];

  fprintf(stderr,"TroutModelSwarm >>>> buildActions >>>> BEGIN\n");
  fflush(0);

  // create the action group with sequential ordering --the only ordering
  // available now, anyway

  updateActions = [ActionGroup createBegin: modelZone];
  updateActions = [updateActions createEnd];

  initAction = [ActionGroup createBegin: modelZone];
  initAction = [initAction createEnd];

  fishActions = [ActionGroup createBegin: modelZone];
  fishActions = [fishActions createEnd];

  reddActions = [ActionGroup createBegin: modelZone];
  reddActions = [reddActions createEnd];

  #ifdef PRINT_CELL_FISH_REPORT
      printCellFishAction = [ActionGroup createBegin: modelZone];
      printCellFishAction = [printCellFishAction createEnd];
  #endif
  modelActions = [ActionGroup createBegin: modelZone];
  modelActions = [modelActions createEnd];

  // create the action group that performs maintenance overhead for the model
  overheadActions = [ActionGroup createBegin: modelZone];
  overheadActions = [overheadActions createEnd];

  // UPDATE ACTIONS
  //
  // Now, put the actions executed each time step
  // into the action groups
  //
  [updateActions createActionTo: self message: M(updateModelTime)];
  [updateActions createActionTo: self message: M(updateFish)];
  [updateActions createActionTo: self message: M(moveSpawnersToLiveFish)];
  [updateActions createActionTo: self message: M(updateHabitatManager)]; 


  // INITACTION
  [initAction createActionTo: self message: M(initialDayAction)];


  //
  // MODEL ACTIONS
  //
  // Fish Actions
  //

  
  [fishActions createActionForEach: liveFish message: M(spawn)];
  [fishActions createActionForEach: liveFish message: M(move)];
  [fishActions createActionForEach: liveFish message: M(grow)];
  [fishActions createActionForEach: liveFish message: M(die)];

  //
  // Redd Actions
  //
  [reddActions createActionForEach: [self getReddList]
	       message: M(survive)];

  [reddActions createActionForEach: [self getReddList]
	       message: M(develop)];

  [reddActions createActionForEach: [self getReddList]
               message: M(emerge)];


  #ifdef PRINT_CELL_FISH_REPORT
      [printCellFishAction createActionTo: habitatManager message: M(outputCellFishInfoReport)];
  #endif

  [modelActions createAction: fishActions];
  [modelActions createAction: reddActions];

  //#ifdef PRINT_CELL_FISH_REPORT
     //[modelActions createAction: printCellFishAction];
  //#endif

  // designate the OVERHEAD ACTIONS
  [overheadActions createActionTo: self message: M(processEmptyReddList)];
  [overheadActions createActionTo: self message: M(removeKilledFishFromLiveFishList)];
  [overheadActions createActionTo: self message: M(removeOutmigrantsFromLiveFishList)];
  [overheadActions createActionTo: self message: M(sortLiveFish)];
  [overheadActions createActionTo: self message: M(updateKilledFishList)];
  [overheadActions createActionTo: self message: M(updateNewOutmigrantsList)];
  [overheadActions createActionTo: self message: M(outputInfoToTerminal)];

  //
  // This is the main model schedule
  //

  // create the SCHEDULE that will be iterated over for the entire
  // model

  modelSchedule = [Schedule createBegin: modelZone];
  [modelSchedule setRepeatInterval: 1];
  modelSchedule = [modelSchedule createEnd];

  printSchedule = [Schedule createBegin: modelZone];
  [printSchedule setRepeatInterval: fileOutputFrequency];
  printSchedule = [printSchedule createEnd];
  [printSchedule createActionTo: self message: M(outputBreakoutReports)];
  #ifdef PRINT_CELL_FISH_REPORT
     [printSchedule createAction: printCellFishAction];
  #endif

  //
  // Put the Actions in the schedule
  //
              [modelSchedule at: 0 createAction: updateActions];
 oneAction =  [modelSchedule at: 0 createAction: initAction];
              [modelSchedule at: 0 createAction: modelActions];
              [modelSchedule at: 0 createAction: overheadActions];



  fprintf(stderr,"TroutModelSwarm >>>> buildActions >>>> END\n");
  fflush(0);

  return self;

}  // buildActions




/*
///////////////////////////////////////
//
// readFishInitializationFiles
//
//////////////////////////////////////
- readFishInitializationFiles
{
  FILE * speciesPopFP=NULL;
  int numSpeciesNdx;
  char * header1=(char *) NULL;
  int prevAge = -1;
  char date[11];
  char prevDate[11];
  int age;
  int number;
  double meanLength;
  double stdDevLength;
  char reach[35];
  char prevReach[35];

  int numRecords;
  int recordNdx;

  BOOL POPINITDATEOK = NO;

  fprintf(stderr,"TroutModelSwarm >>>> readFishInitializationFiles >>>> BEGIN\n");
  fflush(0);

  for(numSpeciesNdx=0; numSpeciesNdx<numberOfSpecies; numSpeciesNdx++)
  {
      if((speciesPopFP = fopen(speciesPopFile[numSpeciesNdx], "r")) == NULL) 
      {
          fprintf(stderr, "ERROR: TroutModelSwarm >>>> readFishInitializationFiles >>>> Error opening %s \n", speciesPopFile[numSpeciesNdx]);
          fflush(0);
          exit(1);
      }

      header1 = (char *)[scratchZone alloc: HCOMMENTLENGTH*sizeof(char)];

      fgets(header1,HCOMMENTLENGTH,speciesPopFP);
      fgets(header1,HCOMMENTLENGTH,speciesPopFP);
      fgets(header1,HCOMMENTLENGTH,speciesPopFP);

      strcpy(prevDate,"00/00/0000");
      strcpy(prevReach,"NOREACH");

      while(fscanf(speciesPopFP,"%11s %d %d %lf %lf %35s", date, &age, &number, &meanLength, &stdDevLength, reach) != EOF)
      {
           TroutInitializationRecord*  fishRecord;

           fishRecord = (TroutInitializationRecord *) [modelZone alloc: sizeof(TroutInitializationRecord)];

           if(strcmp(prevDate, "00/00/0000") == 0)
           {
              strcpy(prevDate, date);
           }
           if(strcmp(prevReach, "NOREACH") == 0)
           {
              strcpy(prevReach, reach);
           }


           fishRecord->speciesNdx = numSpeciesNdx;
           fishRecord->mySpecies = mySpecies[numSpeciesNdx];
           strncpy(fishRecord->date, date, 11);
           fishRecord->initTime = [timeManager getTimeTWithDate: date];
           if(fishRecord->initTime == popInitTime)
           {
               POPINITDATEOK = YES;
           }
           fishRecord->age = age;
           fishRecord->number = number;
           fishRecord->meanLength = meanLength;
           fishRecord->stdDevLength = stdDevLength;
           strcpy(fishRecord->reach, reach);
           
           fprintf(stdout, "TroutModelSwarm >>>> checking fish records >>>>>\n");
           fprintf(stdout, "speciesNdx = %d speciesName = %s date = %s initTime = %ld age = %d number = %d meanLength = %f stdDevLength = %f reach = %s\n",
                                           fishRecord->speciesNdx,
                                           [fishRecord->mySpecies getName],
                                           fishRecord->date,
                                           (long) fishRecord->initTime,
                                           fishRecord->age,
                                           fishRecord->number,
                                           fishRecord->meanLength,
                                           fishRecord->stdDevLength,
                                           fishRecord->reach);
           fflush(0);


          if(strcmp(prevReach, reach) == 0)
          {
              if(strcmp(prevDate, date) == 0)
              {
                  if(prevAge >= age) 
                  {
                     fprintf(stderr, "ERROR: TroutModelSwarm >>>> readFishInitializationFiles >>>> Check %s and ensure that fish ages are in increasing order\n",speciesPopFile[numSpeciesNdx]);
                     fflush(0);
                     exit(1);
                  }
 
                  prevAge = age;
              }
              else
              {
                 strcpy(prevDate, date);
                 prevAge = age;
              }
          }
          else
          {
               strcpy(prevReach, reach);
               prevAge = -1;
          }

          [fishInitializationRecords addLast: (void *) fishRecord];

      }

      if(POPINITDATEOK == NO)
      {
           fprintf(stderr, "ERROR: TroutModelSwarm >>>> readFishInitializationFiles >>>> popInitDate not found\n");
           fflush(0);
           exit(1);
      }

     prevAge = -1;

     fclose(speciesPopFP);
  } //for numberOfSpecies

  [scratchZone free: header1];

  numRecords = [fishInitializationRecords getCount];

  for(recordNdx = 0; recordNdx < numRecords; recordNdx++)
  {
       int chkRecordNdx; 

       TroutInitializationRecord* fishRecord = (TroutInitializationRecord *) [fishInitializationRecords atOffset: recordNdx]; 

       for(chkRecordNdx = 0; chkRecordNdx < numRecords; chkRecordNdx++)
       {
       
           TroutInitializationRecord* chkFishRecord = (TroutInitializationRecord *) [fishInitializationRecords atOffset: chkRecordNdx]; 

                   if(fishRecord == chkFishRecord)
                   {
                       continue;
                   }
                   else if(    (fishRecord->mySpecies == chkFishRecord->mySpecies)
                            && (strcmp(fishRecord->date, chkFishRecord->date) == 0) 
                            && (fishRecord->age == chkFishRecord->age)
                            && (strcmp(fishRecord->reach, chkFishRecord->reach) == 0))
                   {
                         fprintf(stderr, "\n\n");
                         fprintf(stderr, "ERROR: TroutModelSwarm >>>> readFishInitializationFiles\n");
                         fprintf(stderr, "ERROR: TroutModelSwarm >>>> readFishInitializationFiles >>>> Multiple records for the following record\n");
                         fprintf(stderr, "speciesName = %s date = %s age = %d number = %d  reach = %s\n",
                                       [fishRecord->mySpecies getName],
                                       fishRecord->date,
                                       fishRecord->age,
                                       fishRecord->number,
                                       fishRecord->reach);
                         fprintf(stderr, "ERROR: TroutModelSwarm >>>> readFishInitializationFiles\n");
                         fflush(0);
                         exit(1);
                   }

       }

       fprintf(stdout, "speciesNdx = %d speciesName = %s date = %s initTime = %ld age = %d number = %d meanLength = %f stdDevLength = %f reach = %s\n",
                                       fishRecord->speciesNdx,
                                       [fishRecord->mySpecies getName],
                                       fishRecord->date,
                                       (long) fishRecord->initTime,
                                       fishRecord->age,
                                       fishRecord->number,
                                       fishRecord->meanLength,
                                       fishRecord->stdDevLength,
                                       fishRecord->reach);
       fflush(0);

   }
           

  fprintf(stderr,"TroutModelSwarm >>>> readFishInitializationFiles >>>> END\n");
  fflush(0);

  return self;
} 
*/




///////////////////////////////////
//
// updateTkEvents
//
///////////////////////////////////
- updateTkEventsFor: aReach
{
    //
    // Passes message to the observer
    // which in turn passes the message
    // to the experSwarm.
    //
    [observerSwarm updateTkEventsFor: aReach];
    return self;
}

//////////////////////////////////////////////////////
//
// activateIn
//
/////////////////////////////////////////////////////
- activateIn: swarmContext 
{

  [super activateIn: swarmContext];
  [modelSchedule activateIn: self];
  [printSchedule activateIn: self];

  fprintf(stderr, "TROUT MODEL SWARM >>>> activateIn\n");
  fflush(0);

  return [self getActivity];
}

/////////////////////////////////////////////////////////
//
// addAFish
//
////////////////////////////////////////////////////////////
- addAFish: (Trout *) aTrout 
{
  numFish++;
  [liveFish addLast: aTrout];
  return self;
}



/////////////////////////////////////////////
//
//
// addToNewOutmigrants
//
//////////////////////////////////////////////
- addToNewOutmigrants: aJuve
{
   [outmigrantList addLast: aJuve];
   [newOutmigrants addLast: aJuve];
   return self;
}

///////////////////////////////
//
// getRandGen
//
//////////////////////////////
- getRandGen 
{
   return randGen;
}


///////////////////////////////
//
// getJuvenileSuperindividualRatio
//
//////////////////////////////
- (int) getJuvenileSuperindividualRatio 
{
   return juvenileSuperindividualRatio;
}


//////////////////////////////////
//
// getReddList
//
//////////////////////////////////
- (id <List>) getReddList 
{
  return reddList;
}


////////////////////////////////////
//
// getReddremovedList
//
///////////////////////////////////
- (id <List>) getReddRemovedList 
{
  return reddRemovedList;
}



///////////////////////////////////////
//
// addToKilledList
//
///////////////////////////////////////
- addToKilledList: (Trout *) aFish 
{
  [deadFish addLast: aFish];
  [killedFish addLast: aFish];

  [self updateMortalityCountWith: aFish];

  return self;
}


/////////////////////////////////
//
// addToEmptyReddList
//
////////////////////////////////
- addToEmptyReddList: aRedd 
{
  [emptyReddList addLast: aRedd];
  return self;
}


//////////////////////////////////////////////
//
// getHabitatManager
//
//////////////////////////////////////////////
- (HabitatManager *) getHabitatManager
{
    return habitatManager;
}



//////////////////////////////////////////////////////////
//
// whenToStop
//
// This is where any methods called at the end of 
// the model run are performed
//
// Called from the observer swarm 
//
////////////////////////////////////////////////////////
- (BOOL) whenToStop 
{ 
   BOOL STOP = NO;

   if(simCounter >= numSimDays)
   {
       STOP = YES;

       #ifdef REDD_SURV_REPORT
          [self printReddSurvReport];
       #endif

       fprintf(stdout,"TroutModelSwarm >>>> whenToStop >>>> STOPPING\n");
       fflush(0);

       [self writeLFTOutput];   // WRITE OUTPUT FOR LIMITING FACTORS TOOL

   }
   else 
   {
       STOP = NO;
       simCounter++;
   }

   return STOP;
}



///////////////////////////////////////////////////////
//
// updateFish
//
//////////////////////////////////////////////////////
- updateFish 
{
    if(updateFish == YES)
    {
        id <ListIndex> ndx;
        id fish=nil;
        ndx = [liveFish listBegin: scratchZone];
        while(([ndx getLoc] != End) && ((fish = [ndx next]) != nil))
        {
            [fish updateFishWith: modelTime];
        }
        [ndx drop];
    }

    updateFish = YES;

    return self;
}




///////////////////////////////////////////////////
//
// moveSpawnersToLiveFish
//
//////////////////////////////////////////////////
- moveSpawnersToLiveFish
{
    id <ListIndex> ndx = [spawners listBegin: scratchZone];
    id aSpawner = nil;
    id <List> activeSpawners = [List create: scratchZone];
    time_t arrivalTime = -1;
    id randCellDist = nil;
	int aRandInt;
	int maxCellTrials = 10000;
   
    // fprintf(stdout, "TroutModelSwarm >>>> moveSpawnersToLiveFish >>>> BEGIN\n");
    // fflush(0);
    // xprint(spawners);

    randCellDist = [UniformIntegerDist create: modelZone
                                    setGenerator: randGen];

    while(([ndx getLoc] != End) && ((aSpawner = [ndx next]) != nil)){
         arrivalTime = [aSpawner getArrivalTime];
	 if([timeManager getNumberOfDaysBetween: modelTime and: arrivalTime] == 0){
	     id reach = nil;
	     FishCell*  fishCell = (FishCell *) nil;

	     //fprintf(stdout, "TroutModelSwarm >>>> moveSpawnersToLiveFish >>>> modelDate = %s\n", [timeManager getDateWithTimeT: modelTime]);
	     //fprintf(stdout, "TroutModelSwarm >>>> moveSpawnersToLiveFish >>>> arrivalDate = %s\n", [timeManager getDateWithTimeT: arrivalTime]);
	     //fprintf(stdout, "TroutModelSwarm >>>> moveSpawnersToLiveFish >>>> modelDate = %d\n", modelTime);
	     //fprintf(stdout, "TroutModelSwarm >>>> moveSpawnersToLiveFish >>>> arrivalDate = %d\n", arrivalTime);
	     //fflush(0);

	     [liveFish addLast: aSpawner];
	     [activeSpawners addLast: aSpawner];

	     reach = [aSpawner getReach];
	     [randCellDist setIntegerMin: 0  setMax: [[reach getPolyCellList] getCount] - 1];

		 while(fishCell == nil){
			  maxCellTrials--;
			  if(maxCellTrials <= 0) {
				fprintf(stderr, "ERROR: TroutModelSwarm >>>> moveSpawnersToLiveFish >>>> no sufficiently deep cell found\n");
				fprintf(stderr, "Fish length: %f Reach: %s\n",[aSpawner getFishLength],[reach getReachName]);
				fflush(0);
				exit(1);
				}
			aRandInt = [randCellDist getIntegerSample]; 
			fishCell = [[reach getPolyCellList] atOffset: aRandInt];

			if(fishCell == nil) {
				fprintf(stderr, "ERROR: TroutModelSwarm >>>> moveSpawnersToLiveFish >>>> fishCell is nil\n");
				fflush(0);
				}

		   
	     // fprintf(stdout, "TroutModelSwarm >>>> moveSpawnersToLiveFish >>>> fish length: %f cell depth: %f\n",[aSpawner getFishLength], [fishCell getPolyCellDepth]);
	     // fflush(0);

		 if([fishCell getPolyCellDepth] <= ([aSpawner getFishLength] / 10.0)){
			 fishCell = (FishCell *) nil;
			// fprintf(stdout, "TroutModelSwarm >>>> moveSpawnersToLiveFish >>>> Rejected cell\n");
			// fflush(0);
		   }
         }

	     
	      //xprint(liveFish);
	      //xprint(fishCell);
	      [aSpawner setCell: fishCell];
	      [fishCell addFish: aSpawner];
		}
    }
    [ndx drop];

    ndx = [activeSpawners listBegin: scratchZone];
    while(([ndx getLoc] != End) && ((aSpawner = [ndx next]) != nil))
    {
         [spawners remove: aSpawner];
    }
    [ndx drop];
    [activeSpawners removeAll];
    [activeSpawners drop];

    [randCellDist drop];
 
    // fprintf(stdout, "TroutModelSwarm >>>> moveSpawnersToLiveFish >>>> END\n");
    // fflush(0);

    return self;
}



///////////////////////////////////
//
// initialDayAction
//
// This is done only on the first day
//
////////////////////////////////////

- initialDayAction 
{
  initialDay = 0;
  [modelSchedule remove: oneAction];
  return self;
}



/////////////////////////////////////////////////////////
//
// updateHabitatManager
//
//////////////////////////////////////////////////////////
- updateHabitatManager 
{
  [habitatManager updateHabitatManagerWithTime: modelTime
                         andWithModelStartFlag: initialDay];
  return self;
}


/////////////////////////////////////////////////
//
// setShadeColorMax
//
/////////////////////////////////////////////////
- setShadeColorMax: (double) aShadeColorMax
          inHabitatSpace: aHabitatSpace
{
    shadeColorMax = aShadeColorMax;
    [habitatManager setShadeColorMax: shadeColorMax
                      inHabitatSpace: aHabitatSpace];
    return self;
}


///////////////////////////////////////////////////////
//
// switchColorRepFor 
//
///////////////////////////////////////////////////////
- switchColorRepFor: aHabitatSpace
{
    fprintf(stdout, "TroutModelSwarm >>>> switchColorRepFor >>>> BEGIN\n");
    fflush(0);

    if(observerSwarm == nil)
    {
       fprintf(stderr, "WARNING: TroutModelSwarm >>>> switchColorRepFor >>>> observerSwarm is nil >>>> Cannot handle your request\n");
       fflush(0);
    }

    [observerSwarm switchColorRepFor: aHabitatSpace];  


    fprintf(stdout, "TroutModelSwarm >>>> switchColorRepFor >>>> END\n");
    fflush(0);

    return self;
}


/////////////////////////////////////////////////////////
//
// toggleCellsColorRepIn
//
//////////////////////////////////////////////////////////
- toggleCellsColorRepIn: aHabitatSpace
{
      [habitatManager setShadeColorMax: shadeColorMax
                       inHabitatSpace:  aHabitatSpace];
      [habitatManager toggleCellsColorRepIn: aHabitatSpace];
      return self;
}


////////////////////////////////////////////////////////////////
//
// getLiveFishList
//
////////////////////////////////////////////////////////////////
- (id <List>) getLiveFishList 
{
  return liveFish;
}


////////////////////////////////////////////////////////////
//
// getDeadTroutList
//
////////////////////////////////////////////////////////////
- (id <List>) getDeadTroutList 
{
    return deadFish;
}

////////////////////////////////////////////////////////////
//
// getOutmigrantList
//
////////////////////////////////////////////////////////////
- (id <List>) getOutmigrantList 
{
    return outmigrantList;
}


////////////////////////////////////////////////////////////
//
// getNumOutmigrants  -- Number of fish migrating out on current day
//
////////////////////////////////////////////////////////////
- (int) getNumOutmigrants
{
    return numOutmigrants;
}


///////////////////////////////////
//
// removeKilledFishFromLiveFishList
//
//////////////////////////////////
- removeKilledFishFromLiveFishList
{

   id <ListIndex> ndx = [killedFish listBegin: scratchZone];
   id aFish = nil;

   [ndx setLoc: Start];

   while(([ndx getLoc] != End) && ((aFish = [ndx next]) != nil))
   {
      [liveFish remove: aFish];
   }

   [ndx drop];

   return self;

}



///////////////////////////////////
//
// removeOutmigrantsFromLiveFishList
// New for salmon
//
//////////////////////////////////
- removeOutmigrantsFromLiveFishList
{

   id <ListIndex> ndx = [newOutmigrants listBegin: scratchZone];
   id aFish = nil;

   [ndx setLoc: Start];

   while(([ndx getLoc] != End) && ((aFish = [ndx next]) != nil))
   {
      [liveFish remove: aFish];
   }

   [ndx drop];

   return self;

}






///////////////////////////////////
//
// updateKilledFishList
//
//////////////////////////////////
- updateKilledFishList
{
   [killedFish removeAll];
   return self;
}


///////////////////////////////////
//
// updateNewOutmigrantsList
//
// This updates output for graphics and for the Limiting Factors Tool output file
//
//////////////////////////////////
- updateNewOutmigrantsList
{
   id <ListIndex> migrantNdx;
   id nextOutmigrant = nil;

   numOutmigrants = [newOutmigrants getCount];
   lftNumTotalOutmigrants += numOutmigrants;

   migrantNdx = [newOutmigrants listBegin: scratchZone];

   while (([migrantNdx getLoc] != End) && ((nextOutmigrant = [migrantNdx next]) != nil)) 
    {
       if([nextOutmigrant getFishLength] > lftBigOutmigrantsSizeThreshold)
       {
          lftNumBigOutmigrants++;
       }
    }

   [migrantNdx drop];

   [newOutmigrants removeAll];
   return self;
}




////////////////////////////////////////
//
// sortLiveFish
//
///////////////////////////////////////
- sortLiveFish
{
  [QSort sortObjectsIn:  liveFish using: M(compare:)];
  [QSort reverseOrderOf: liveFish];

  return self;
}


//////////////////////////////////////////
//
// processEmptyReddList
//
///////////////////////////////////////////
- processEmptyReddList 
{
    id <ListIndex> emptyReddNdx;
    id nextRedd = nil;

    emptyReddNdx = [emptyReddList listBegin: scratchZone];

    while (([emptyReddNdx getLoc] != End) && ((nextRedd = [emptyReddNdx next]) != nil)) 
    {
       if([reddList contains: nextRedd] == YES)
       {
          [reddList remove: nextRedd];
       }
       else
       {
           fprintf(stderr, "ERROR: TroutModelSwarm >>>> processEmptyReddList >>>> attempting to remove a nonexistant redd from redd list\n");
           fflush(0);
           exit(1);
       }       

       [reddRemovedList addLast: nextRedd];
    }

    [emptyReddNdx drop];
    [emptyReddList removeAll];

    return self;
}




//////////////////////////////////////////////////////
//
// createNewFishWithSpeciesIndex
//   used for juveniles as well as spawners!
//
/////////////////////////////////////////////////////
- createNewFishWithSpeciesIndex: (int) speciesNdx  
                           Species: (id <Symbol>) species
                            Length: (double) fishLength 
			       Sex: (id <Symbol>) sex
{

  id newSpawner;
  //id <Symbol> sex = nil;
  id <InterpolationTable> aCMaxInterpolator = nil;
  id <InterpolationTable> aSpawnDepthInterpolator = nil;
  id <InterpolationTable> aSpawnVelocityInterpolator = nil;
  LogisticFunc* aCaptureLogistic = nil;
  LogisticFunc* anOutMigLogistic = nil;

  //
  // The newSpawner color is currently being set in the observer swarm
  //

  //fprintf(stdout, "TroutModelSwarm >>>> createNewFishWithSpeciesIndex >>>> BEGIN\n");
  //fflush(0);

  newSpawner = [MyTroutClass[speciesNdx] createBegin: modelZone];

  //xprint(newSpawner);

  [newSpawner setFishParams: [fishParamsMap at: species]];

  //
  // set properties of the new Trout
  //

  if(sex == CoinFlip){
    sex = [coinFlip getCoinToss] == YES ?  Female : Male;
  }
  [newSpawner setSex: sex];


  if(sex == Female){
    [newSpawner setIsFemale: YES];
    //fprintf(stdout, "TroutModelSwarm >>>> createNewFishWithSpeciesIndex >>>> sex is female\n");
    //fflush(0);
  }else{
    //fprintf(stdout, "TroutModelSwarm >>>> createNewFishWithSpeciesIndex >>>> sex is male\n");
    //fflush(0);
  }

  [newSpawner setMyRedd: nil];

  //
  // isSpawner is defualt NO in Trout.[hm]
  //

  [newSpawner setRandGen: randGen];

  [newSpawner setSpecies: species];
  [newSpawner setSpeciesNdx: speciesNdx];

  [newSpawner setFishLength: fishLength];
  [newSpawner setFishCondition: 1.0];
  [newSpawner setFishWeightFromLength: fishLength andCondition: 1.0]; 
  [newSpawner setTimeTLastSpawned: 0];

  [newSpawner calcStarvPaAndPb];

  if(fishColorMap != nil)
  {
     [newSpawner setFishColor: (Color) *((long *) [fishColorMap at: [newSpawner getSpecies]])];
  }

  [newSpawner setTimeManager: timeManager];
  [newSpawner setModel: (id <TroutModelSwarm>) self];

  aCMaxInterpolator = [cmaxInterpolatorMap at: species];
  aSpawnDepthInterpolator = [spawnDepthInterpolatorMap at: species];
  aSpawnVelocityInterpolator = [spawnVelocityInterpolatorMap at: species];
  aCaptureLogistic = [captureLogisticMap at: species];
  anOutMigLogistic = [juveOutMigLogisticMap at: species];
  
  [newSpawner setCMaxInterpolator: aCMaxInterpolator];
  [newSpawner setSpawnDepthInterpolator: aSpawnDepthInterpolator];
  [newSpawner setSpawnVelocityInterpolator: aSpawnVelocityInterpolator];
  [newSpawner setCaptureLogistic: aCaptureLogistic];
  [newSpawner setJuveOutMigLogistic: anOutMigLogistic];

  fishCounter++;  // Give each fish a serial number ID
  [newSpawner setFishID: fishCounter];

  newSpawner = [newSpawner createEnd];

  //fprintf(stdout, "TroutModelSwarm >>>> createNewFishWithSpeciesIndex >>>> END\n");
  //fflush(0);
        
  return newSpawner;
}



///////////////////////////////////////////////////////////////////////////////
//
// readSpeciesSetup
//
// Copied from inSTREAM SFR 8/1/2013
////////////////////////////////////////////////////////////////////////////////
- readSpeciesSetup {
  FILE* speciesFP=NULL;
  const char* speciesFile="Species.Setup";
  int speciesIDX, speciesBlockCount = 0;
  char* headerLine;

  headerLine = (char *) [modelZone alloc: HCOMMENTLENGTH*sizeof(char)];

  if((speciesFP = fopen( speciesFile, "r")) == NULL){
      fprintf(stderr, "ERROR: TroutModelSwarm >>>> readSpeciesSetup >>>> Cannot open speciesFile %s",speciesFile);
      fflush(0);
      exit(1);
  }
  // Count the number of species and increment numberOfSpecies accordingly
  // first skip the 3 header lines and the following blank line
  numberOfSpecies = 0;
  fgets(headerLine,HCOMMENTLENGTH,speciesFP);  
  fgets(headerLine,HCOMMENTLENGTH,speciesFP);  
  fgets(headerLine,HCOMMENTLENGTH,speciesFP);  
  fgets(headerLine,HCOMMENTLENGTH,speciesFP);  
  while(fgets(headerLine,HCOMMENTLENGTH,speciesFP)!=NULL){
    speciesBlockCount++;
    if(speciesBlockCount==4){
      speciesBlockCount = 0;
      numberOfSpecies++;
      // skip the next blank line
      fgets(headerLine,HCOMMENTLENGTH,speciesFP);
    }
  }
  fclose(speciesFP);

  if(numberOfSpecies == 0){
     fprintf(stderr, "ERROR: TroutModelSwarm >>>> readSpeciesSetup >>>> numberOfSpecies is zero\n"); 
     fflush(0);
     exit(1);
  }else if(numberOfSpecies > 10){
      fprintf(stderr, "ERROR: TroutModelSwarm >>>> readSpeciesSetup >>>> numberOfSpecies greater than 10");
      fflush(0);
      exit(1);
  }
  speciesName  = (char **) [modelZone alloc: numberOfSpecies*sizeof(char *)];
  speciesParameter  = (char **) [modelZone alloc: numberOfSpecies*sizeof(char *)];
  speciesPopFile = (char **) [modelZone alloc: numberOfSpecies*sizeof(char *)];
  speciesColor = (char **) [modelZone alloc: numberOfSpecies*sizeof(char *)];


  if((speciesFP = fopen( speciesFile, "r")) == NULL){
      fprintf(stderr, "ERROR: TroutModelSwarm >>>> readSpeciesSetup >>>> Cannot open speciesFile %s",speciesFile);
      fflush(0);
      exit(1);
  }
  fgets(headerLine,HCOMMENTLENGTH,speciesFP);  
  fgets(headerLine,HCOMMENTLENGTH,speciesFP);  
  fgets(headerLine,HCOMMENTLENGTH,speciesFP);  

  for(speciesIDX=0;speciesIDX<numberOfSpecies;speciesIDX++) {
      speciesName[speciesIDX] = (char *) [modelZone alloc: 200*sizeof(char)];
      speciesParameter[speciesIDX] = (char *) [modelZone alloc: 200*sizeof(char)];
      speciesPopFile[speciesIDX] = (char *) [modelZone alloc: 200*sizeof(char)];
      speciesColor[speciesIDX] = (char *) [modelZone alloc: 200*sizeof(char)];

      if(fscanf(speciesFP,"%s%s%s%s",speciesName[speciesIDX],
                              speciesParameter[speciesIDX],
                              speciesPopFile[speciesIDX],
                              speciesColor[speciesIDX]) != EOF){
          fprintf(stdout, "TroutModelSwarm >>>> readSpeciesSetup >>>> Myfiles are: %s %s %s \n", speciesName[speciesIDX],speciesParameter[speciesIDX], speciesPopFile[speciesIDX]);
          fflush(0);
      }
   }
   fclose(speciesFP);
   [modelZone free: headerLine];
   return self;
} 


//////////////////////////////////////////////////////
//
// buildFishClass
//
/////////////////////////////////////////////////////
- buildFishClass 
{
   int i;

   MyTroutClass = (Class *) [modelZone alloc: numberOfSpecies*sizeof(Class)];

   speciesClassList = [List create: modelZone]; 

   for(i=0;i<numberOfSpecies;i++) 
   {
        if(objc_lookup_class(speciesName[i]) == Nil)
        {
            fprintf(stderr, "ERROR: TroutModelSwarm >>>> buildFishClass >>>> can't find class for %s\n", speciesName[i]);
            fflush(0);
            exit(1);
        }  

       MyTroutClass[i] = [objc_get_class(speciesName[i]) class];
       [speciesClassList addLast: MyTroutClass[i]];
   }

   return self;
}


- (id <List>) getSpeciesClassList 
{
  return speciesClassList;
}

- (int) getNumberOfSpecies 
{
  return numberOfSpecies;
}


////////////////////////////////////////////
//
// getSpeciesSymbolWithName
//
////////////////////////////////////////////
- (id <Symbol>) getSpeciesSymbolWithName: (char *) aName
{
   id <Symbol> speciesSymbol = nil;
   id <ListIndex> ndx = nil;
   BOOL speciesNameFound = NO;
   char* speciesName = NULL;

   if(speciesSymbolList != nil)
   {
       ndx = [speciesSymbolList listBegin: scratchZone];
   }
   else
   {
      fprintf(stderr, "TroutModelSwarm >>>> getSpeciesSymbolWithName >>>> method invoked before instantiateObjects\n");
      fflush(0);
      exit(1);
   }

   while(([ndx getLoc] != End) && ((speciesSymbol = [ndx next]) != nil))  
   {
        speciesName = (char *)[speciesSymbol getName];
        if(strncmp(aName, speciesName, strlen(speciesName)) == 0)
        {
            speciesNameFound = YES;
            [scratchZone free: speciesName];
            speciesName = NULL; 
            break;
        }

        if(speciesName != NULL)
        { 
            [scratchZone free: speciesName];
            speciesName = NULL;
        }
   } 

   if(!speciesNameFound)
   {
       fprintf(stderr, "TroutModelSwarm >>>> getSpeciesSymbolWithName >>>> no species symbol for name %s\n", aName);
       fflush(0);
       exit(1);
   } 

   return speciesSymbol;
}

#ifdef REDD_MORTALITY_REPORT

/////////////////////////////////////////////////
//
// openReddReportFilePtr
//
//////////////////////////////////////////////////
- openReddReportFilePtr 
{

  const char * reddMortalityFile = "Redd_Mortality.rpt";

  if(reddRptFilePtr == NULL) 
  {

     if ((appendFiles == NO) && (scenario == 1) && (replicate == 1))
     {
        if((reddRptFilePtr = fopen(reddMortalityFile,"w")) == NULL ) 
        {
            fprintf(stderr, "ERROR: TroutModelSwarm >>>> openReddReportFilePtr >>>> Cannot open %s for writing\n",reddMortalityFile);
            fflush(0);
            exit(1);
        }
        fprintf(reddRptFilePtr,"\n\n");
        fprintf(reddRptFilePtr,"SYSTEM TIME:  %s\n", [timeManager getSystemDateAndTime]);
     }
     else if((scenario == 1) && (replicate == 1) && (appendFiles == YES))
     {
        if((reddRptFilePtr = fopen(reddMortalityFile,"a")) == NULL)
        {
            fprintf(stderr, "ERROR: TroutModelSwarm >>>> openReddReportFilePtr >>>> Cannot open %s for writing\n",reddMortalityFile);
            fflush(0);
            exit(1);
        }
        fprintf(reddRptFilePtr,"\n\n");
        fprintf(reddRptFilePtr,"SYSTEM TIME:  %s\n", [timeManager getSystemDateAndTime]);
     }
     else // Not the first replicate or scenario, so no header 
     {
         if((reddRptFilePtr = fopen(reddMortalityFile,"a")) == NULL) 
         {
            fprintf(stderr, "ERROR: TroutModelSwarm >>>> openReddReportFilePtr >>>> Cannot open %s for appending\n",reddMortalityFile);
            fflush(0);
            exit(1);
         }
     }

  }

   if(reddRptFilePtr == NULL)
   {
       fprintf(stderr, "ERROR: TroutModelSwarm >>>> openReddReportFilePtr >>>> File %s is not open\n",reddMortalityFile);
       fflush(0);
       exit(1);
   }


  return self;

}

#endif



/////////////////////////////////////////////////
//
// getReddReportFilePtr
//
//////////////////////////////////////////////////
- (FILE *) getReddReportFilePtr
{

  // if(reddRptFilePtr == NULL)
  // {
  //     fprintf(stderr, "ERROR: TroutModelSwarm >>>> getReddReportFilePtr >>>> File %s is not open\n", reddMortalityFile);
  //      fflush(0);
  //     exit(1);
  // }

   return reddRptFilePtr;
}



#ifdef REDD_SURV_REPORT

//////////////////////////////////////////////////////////
//
// printReddSurvReport
//
/////////////////////////////////////////////////////////
- printReddSurvReport { 
    FILE *printRptPtr=NULL;
    const char * reddSurvFile = "Redd_Survival_Test_Out.csv";
    id <ListIndex> reddListNdx;
    id redd;

    if((printRptPtr = fopen(reddSurvFile,"w+")) != NULL){
        if([[self getReddRemovedList] getCount] != 0){
            reddListNdx = [reddRemovedList listBegin: modelZone];

            while(([reddListNdx getLoc] != End) && ((redd = [reddListNdx next]) != nil)){
               [redd printReddSurvReport: printRptPtr];
            }
            [reddListNdx drop];
        }
   }else{
       fprintf(stderr, "ERROR: TroutModelSwarm >>>> printReddSurvReport >>>> Couldn't open %s\n", reddSurvFile);
       fflush(0);
       exit(1);
   }
   fclose(printRptPtr);
   return self;
}

#endif



///////////////////////////////////////////////////
//
// openReddSummaryFilePtr
//
//////////////////////////////////////////////////
- openReddSummaryFilePtr {
  char * formatString = "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n";
  char * fileMetaData;


  if(reddSummaryFilePtr == NULL) {

    if ((appendFiles == NO) && (scenario == 1) && (replicate == 1)){
      if((reddSummaryFilePtr = fopen(reddOutputFile,"w")) == NULL ){
            fprintf(stderr, "ERROR: TroutModelSwarm >>>> openReddSummaryFilePtr >>>> Cannot open %s for writing\n",reddOutputFile);
            fflush(0);
            exit(1);
       }
       fileMetaData = [BreakoutReporter reportFileMetaData: scratchZone];
       fprintf(reddSummaryFilePtr,"\n%s\n\n",fileMetaData);
       [scratchZone free: fileMetaData];

	fprintf(reddSummaryFilePtr,formatString, "Scenario",
						 "Replicate",
						 "ReddID",
						 "SpawnerLength",
						 "SpawnerWeight",
						 "SpawnerAge",
						 "Species",
						 "Reach",
						 "CellNo",
						 "CreateDate",
						 "InitialViableEggs",
						 "EmptyDate",
						 "Dewatering",
						 "Scouring",
						 "LowTemp",
						 "HiTemp",
						 "Superimp",
						 "FryEmerged"); 
    }else if ((scenario == 1) && (replicate == 1) && (appendFiles == YES)){
      if( (reddSummaryFilePtr = fopen(reddOutputFile,"a")) == NULL ) {
	fprintf(stderr, "ERROR: TroutModelSwarm >>>> openReddSummaryFilePtr >>>> Cannot open %s for writing\n",reddOutputFile);
	fflush(0);
	exit(1);
      }
      fileMetaData = [BreakoutReporter reportFileMetaData: scratchZone];
      fprintf(reddSummaryFilePtr,"\n%s\n\n",fileMetaData);
      [scratchZone free: fileMetaData];

      fprintf(reddSummaryFilePtr,formatString, "Scenario",
					   "Replicate",
					   "ReddID",
					   "SpawnerLength",
					   "SpawnerWeight",
					   "SpawnerAge",
					   "Species",
					   "Reach",
					   "CellNo",
					   "CreateDate",
					   "InitialViableEggs",
					   "EmptyDate",
					   "Dewatering",
					   "Scouring",
					   "LowTemp",
					   "HiTemp",
					   "Superimp",
					   "FryEmerged"); 
    }else{ // Not the first replicate or scenario, so no header
	   if((reddSummaryFilePtr = fopen(reddOutputFile,"a")) == NULL ){
	       fprintf(stderr, "ERROR: TroutModelSwarm >>>> openReddSummaryFilePtr >>>> Cannot open %s for appending\n",reddOutputFile);
	       fflush(0);
	       exit(1);
	   }
    }
  }
  if(reddSummaryFilePtr == NULL){
     fprintf(stderr, "ERROR: TroutModelSwarm >>>> openReddSummaryFilePtr >>>> Cannot open %s for writing\n",reddOutputFile);
     fflush(0);
     exit(1);
  }
  return self;

}

///////////////////////////////////
//
// getReddSummaryFilePtr 
//
/////////////////////////////////// 
- (FILE *) getReddSummaryFilePtr {
   if(reddSummaryFilePtr == NULL){
       fprintf(stderr, "ERROR: TroutModelSwarm >>>> openReddSummaryFilePtr >>>>  file %s is not open\n",reddOutputFile);
       fflush(0);
       exit(1);
   }
   return reddSummaryFilePtr;
}

//////////////////////////////////////////////////////////
//
////
//////           MODEL TIME_T METHODS
////////
//////////
////////////
/////////////////////////////////////////////////////////

- updateModelTime 
{
  time_t newYearTime = (time_t) 0;

  if(shuffleYears == NO)
  {
      if(initialDay == YES)
      {
          initialDay = NO;
      }
      else 
      {
         modelTime = [timeManager stepTimeWithControllerObject: self];
      }

  }
  else
  {
      if(initialDay == YES)
      {
          initialDay = NO;
      }
      else
      {
          modelTime = [timeManager stepTimeWithControllerObject: self];

          newYearTime = [yearShuffler checkForNewYearAt: modelTime];

          if(newYearTime != modelTime)
          {
              [timeManager setCurrentTime: newYearTime];
              modelTime = newYearTime;
          }
      } // else initial day = NO
  } 

  strcpy(modelDate, [timeManager getDateWithTimeT: modelTime]);

  return self;
}



/////////////////////////////////////////////////////////
//
// getModelTime
//
/////////////////////////////////////////////////////////
- (time_t) getModelTime 
{
   return modelTime;
}


- (id <Zone>) getModelZone 
{
    return modelZone;
}

- (BOOL) getAppendFiles 
{
  return appendFiles;
}

- (int) getScenario 
{
  return scenario;
}


- (int) getReplicate 
{
  return replicate;
}


////////////////////////////////////
//
// getSpeciesSymbolList
//
////////////////////////////////////
- (id <List>) getSpeciesSymbolList
{
   return speciesSymbolList;
}


///////////////////////////////////
//
// getAgeSymbolList
//
///////////////////////////////////
- (id <List>) getAgeSymbolList
{
   return ageSymbolList;
}



///////////////////////////////////
//
// getSizeSymbolList
//
///////////////////////////////////
- (id <List>) getSizeSymbolList
{
   return sizeSymbolList;
}



///////////////////////////////////
//
// getLifestageSymbolList
//
///////////////////////////////////
- (id <List>) getLifestageSymbolList
{
   return lifestageSymbolList;
}



///////////////////////////////////
//
// getAdultLifestageSymbol
//
///////////////////////////////////
- (id <Symbol>) getAdultLifestageSymbol
{
   return Adult;
}



///////////////////////////////////
//
// getJuvenileLifestageSymbol
//
///////////////////////////////////
- (id <Symbol>) getJuvenileLifestageSymbol
{
   return Juvenile;
}



///////////////////////////////////////
//
// outputInfoToTerminal
//
///////////////////////////////////////
- outputInfoToTerminal
{
  fprintf(stdout, "%s Scenario %d Replicate %d Number of live fish = %d\n", 
                             [timeManager getDateWithTimeT: modelTime], 
                             scenario, 
                             replicate, 
                             [liveFish getCount]);
  fflush(0);

  return self;
}


//////////////////////////////////////////////////////////
//
// getFishMortalitySymbolWithName
//
//////////////////////////////////////////////////////////
- (id <Symbol>) getFishMortalitySymbolWithName: (char *) aName
{

    id <ListIndex> lstNdx;
    id aSymbol = nil;
    id mortSymbol = nil;
    TroutMortalityCount* mortalityCount = nil;
    char* mortName = NULL;

    lstNdx = [fishMortSymbolList listBegin: scratchZone]; 

    while(([lstNdx getLoc] != End) && ((aSymbol = [lstNdx next]) != nil))
    {
       mortName = (char *) [aSymbol getName];  
        if(strncmp(aName, mortName, strlen(aName)) == 0) 
        {
           mortSymbol = aSymbol;
           [scratchZone free: mortName];
           mortName = NULL;
           break;
        }

        if(mortName != NULL)
        {
            [scratchZone free: mortName];
            mortName = NULL;
        }
    }
  
    [lstNdx drop];

    if(mortSymbol == nil)
    {
        mortSymbol = [Symbol create: modelZone setName: aName];
        [fishMortSymbolList addLast: mortSymbol];

        mortalityCount = [TroutMortalityCount createBegin: modelZone
                                       withMortality: mortSymbol];

        [listOfMortalityCounts addLast: mortalityCount];

        if(mortalityCountLstNdx != nil)
        {
            [mortalityCountLstNdx drop];
        }
    
        mortalityCountLstNdx = [listOfMortalityCounts listBegin: modelZone];
  
    }

    return mortSymbol;
}


//////////////////////////////////////////////////////////
//
// getReddMortalitySymbolWithName
//
//////////////////////////////////////////////////////////
- (id <Symbol>) getReddMortalitySymbolWithName: (char *) aName

{

    id <ListIndex> lstNdx;
    id aSymbol = nil;
    id mortSymbol = nil;
    char* mortName = NULL;

    lstNdx = [reddMortSymbolList listBegin: scratchZone]; 

    while(([lstNdx getLoc] != End) && ((aSymbol = [lstNdx next]) != nil))
    {
        mortName = (char *) [aSymbol getName];
        if(strncmp(aName, mortName, strlen(aName)) == 0) 
        {
           mortSymbol = aSymbol;
           [scratchZone free: mortName];
           mortName = NULL;
           break;
        }

        if(mortName != NULL)
        {
            [scratchZone free: mortName];
            mortName = NULL;
        }
    }
  
    [lstNdx drop];

    if(mortSymbol == nil)
    {
        mortSymbol = [Symbol create: modelZone setName: aName];
        [reddMortSymbolList addLast: mortSymbol];
    }

    return mortSymbol;
}


/////////////////////////////////////////
//
// getAgeSymbolForAge
//
/////////////////////////////////////////
- (id <Symbol>) getAgeSymbolForAge: (int) anAge
{
   int fishAge = anAge;

   if(fishAge >= 6)
   { 
      fishAge = 6;
   }

   return [ageSymbolList atOffset: fishAge];
}


/////////////////////////////////////////
//
// getSizeSymbolForLength
//
/////////////////////////////////////////
- (id <Symbol>) getSizeSymbolForLength: (double) aLength
{
   int offset = 0;

   if(aLength > 5.0)
   { 
      offset = 1;
   }
   if(aLength > 8.0)
   { 
      offset = 2;
   }

   return [sizeSymbolList atOffset: offset];
}


////////////////////////////////////////////
//
// getReachSymbolWithName
//
////////////////////////////////////////////
- (id <Symbol>) getReachSymbolWithName: (char *) aName
{
    id <ListIndex> lstNdx;
    id aSymbol = nil;
    id reachSymbol = nil;
    char* reachName = NULL;

    //fprintf(stdout, "TroutModelSwarm >>>> getReachSymbolWithName >>>> BEGIN\n");
    //fflush(0);

    lstNdx = [reachSymbolList listBegin: scratchZone]; 

    while(([lstNdx getLoc] != End) && ((aSymbol = [lstNdx next]) != nil))
    {
        reachName = (char *) [aSymbol getName];
        if(strncmp(aName, reachName, strlen(aName)) == 0) 
        {
           reachSymbol = aSymbol;
           [scratchZone free: reachName];
           reachName = NULL;
           break;
        }

        if(reachName != NULL) 
        {
           [scratchZone free: reachName];
           reachName = NULL;
        }
    }
  
    [lstNdx drop];

    if(reachSymbol == nil)
    {
        reachSymbol = [Symbol create: modelZone setName: aName];
        [reachSymbolList addLast: reachSymbol];
    }


    //fprintf(stdout, "TroutModelSwarm >>>> getReachSymbolWithName >>>> END\n");
    //fflush(0);


    return reachSymbol;

}

/////////////////////////////////////////////
//
// getReddBinomialDist
//
////////////////////////////////////////////
- (id <BinomialDist>) getReddBinomialDist
{
   return reddBinomialDist;
}



/////////////////////////////////////////////
//
// getOutmigrationSymbol
//
////////////////////////////////////////////
- (id <Symbol>) getOutmigrationSymbol
{
   return outmigrationSymbol;
}

//////////////////////////////////////////////////////
//
// createBreakoutReporters
//
/////////////////////////////////////////////////////
- createBreakoutReporters
{

  BOOL fileOverWrite = TRUE;
  BOOL suppressBreakoutColumns = NO;

  if(appendFiles == TRUE)
  {
     fileOverWrite = FALSE;
  }

  if((scenario != 1) || (replicate != 1))
  {
      suppressBreakoutColumns = YES;
      fileOverWrite = FALSE;
  }
      
  //
  // Fish mortality reporter
  //
  fishMortalityReporter = [BreakoutReporter   createBeginWithCSV: modelZone
                                                  forList: deadFish
                                       withOutputFilename: (char *) fishMortalityFile
                                        withFileOverwrite: fileOverWrite];

  [fishMortalityReporter addColumnWithValueOfVariable: "scenario"
                                        fromObject: self
                                          withType: "int"
                                         withLabel: "Scenario"];

  [fishMortalityReporter addColumnWithValueOfVariable: "replicate"
                                        fromObject: self
                                          withType: "int"
                                         withLabel: "Replicate"];

  [fishMortalityReporter addColumnWithValueOfVariable: "modelDate"
                                        fromObject: self
                                          withType: "string"
                                         withLabel: "ModelDate"];

  [fishMortalityReporter breakOutUsingSelector: @selector(getReachSymbol)
                                withListOfKeys: reachSymbolList];

  [fishMortalityReporter breakOutUsingSelector: @selector(getSpecies)
                                withListOfKeys: speciesSymbolList];

  [fishMortalityReporter breakOutUsingSelector: @selector(getLifestageSymbol)
                                withListOfKeys: lifestageSymbolList];

  [fishMortalityReporter breakOutUsingSelector: @selector(getCauseOfDeath)
                                withListOfKeys: fishMortSymbolList];

  [fishMortalityReporter createOutputWithLabel: "Count"
                                  withSelector: @selector(getFishCount)
                              withAveragerType: "Total"];

  [fishMortalityReporter suppressColumnLabels: suppressBreakoutColumns];

  fishMortalityReporter = [fishMortalityReporter createEnd];


  //
  // Live fish reporter
  //
  liveFishReporter = [BreakoutReporter   createBeginWithCSV: modelZone
                                             forList: liveFish
                                  //withOutputFilename: "LiveFish.rpt"
                                  withOutputFilename: (char *) fishOutputFile
                                   withFileOverwrite: fileOverWrite];
  //withColumnWidth: 25];


  [liveFishReporter addColumnWithValueOfVariable: "scenario"
                                      fromObject: self
                                        withType: "int"
                                       withLabel: "Scenario"];

  [liveFishReporter addColumnWithValueOfVariable: "replicate"
                                      fromObject: self
                                        withType: "int"
                                       withLabel: "Replicate"];

  [liveFishReporter addColumnWithValueOfVariable: "modelDate"
                                      fromObject: self
                                        withType: "string"
                                       withLabel: "ModelDate"];

  [liveFishReporter breakOutUsingSelector: @selector(getReachSymbol)
                           withListOfKeys: reachSymbolList];

  [liveFishReporter breakOutUsingSelector: @selector(getSpecies)
                           withListOfKeys: speciesSymbolList];

  [liveFishReporter breakOutUsingSelector: @selector(getLifestageSymbol)
                           withListOfKeys: lifestageSymbolList];

  [liveFishReporter createOutputWithLabel: "Count"
                             withSelector: @selector(getFishCount)
                         withAveragerType: "Total"];

  [liveFishReporter createOutputWithLabel: "MeanLength"
                             withSelector: @selector(getFishLength)
                         withAveragerType: "Average"];

  [liveFishReporter createOutputWithLabel: "TotalWeight"
                             withSelector: @selector(getSuperindividualWeight)
                         withAveragerType: "Total"];

  [liveFishReporter createOutputWithLabel: "MeanWeight"
                             withSelector: @selector(getFishWeight)
                         withAveragerType: "Average"];

  [liveFishReporter suppressColumnLabels: suppressBreakoutColumns];

  liveFishReporter = [liveFishReporter createEnd];

  //
  // Outmigrant reporter
  //
  outmigrantReporter = [BreakoutReporter   createBeginWithCSV: modelZone
                                             forList: outmigrantList
                                  withOutputFilename: (char *) outmigrantOutputFile
                                   withFileOverwrite: fileOverWrite];
  //withColumnWidth: 25];


  [outmigrantReporter addColumnWithValueOfVariable: "scenario"
                                      fromObject: self
                                        withType: "int"
                                       withLabel: "Scenario"];

  [outmigrantReporter addColumnWithValueOfVariable: "replicate"
                                      fromObject: self
                                        withType: "int"
                                       withLabel: "Replicate"];

  [outmigrantReporter addColumnWithValueOfVariable: "modelDate"
                                      fromObject: self
                                        withType: "string"
                                       withLabel: "ModelDate"];

  [outmigrantReporter breakOutUsingSelector: @selector(getSpecies)
                           withListOfKeys: speciesSymbolList];

  [outmigrantReporter breakOutUsingSelector: @selector(getNatalReachSymbol)
                           withListOfKeys: reachSymbolList];

  [outmigrantReporter breakOutUsingSelector: @selector(getSizeSymbol)
                           withListOfKeys: sizeSymbolList];

  [outmigrantReporter createOutputWithLabel: "Count"
                             withSelector: @selector(getFishCount)
                         withAveragerType: "Total"];

  [outmigrantReporter createOutputWithLabel: "MeanLength"
                             withSelector: @selector(getFishLength)
                         withAveragerType: "Average"];

  [outmigrantReporter suppressColumnLabels: suppressBreakoutColumns];

  outmigrantReporter = [outmigrantReporter createEnd];

  return self;
}





//////////////////////////////////////////////////
//
// outputBreakoutReports
//
/////////////////////////////////////////////////
- outputBreakoutReports
{

  //  fprintf(stderr, "TroutModelSwarm >>>> outputBreakoutReports >>> BEGIN\n");
  //  fflush(0);

   [fishMortalityReporter updateByReplacement];
   [fishMortalityReporter output];

   [liveFishReporter updateByReplacement];
   [liveFishReporter output];

   [outmigrantReporter updateByReplacement];
   [outmigrantReporter output];

   [deadFish deleteAll]; 

   [outmigrantList deleteAll];

  //  fprintf(stderr, "TroutModelSwarm >>>> outputBreakoutReports >>> END\n");
  //  fflush(0);

   return self;
}


///////////////////////////////////////////////
//
// createYearShuffler
//
///////////////////////////////////////////////
- createYearShuffler
{
   startDay = [timeManager getDayOfMonthWithTimeT: runStartTime];
   startMonth = [timeManager getMonthWithTimeT: runStartTime];
   startYear = [timeManager getYearWithTimeT: runStartTime];

   endDay = [timeManager getDayOfMonthWithTimeT: runEndTime];
   endMonth = [timeManager getMonthWithTimeT: runEndTime];
   endYear = [timeManager getYearWithTimeT: runEndTime];

   if(shuffleYearSeed < 0.0)
   {
      fprintf(stderr, "ERROR: TroutModelSwarm >>>> createYearShuffler >>> shuffleYearSeed less than 0\n");
      fflush(0);
      exit(1);
   }

   yearShuffler = [YearShuffler   createBegin: modelZone 
                                withStartTime: runStartTime
                                  withEndTime: runEndTime
                              withReplacement: shuffleYearReplace
                              withRandGenSeed: shuffleYearSeed
                              withTimeManager: timeManager];

   yearShuffler = [yearShuffler createEnd];

   if([[yearShuffler getListOfRandomizedYears] getCount] <= 1)
   {
       fprintf(stderr, "ERROR: TroutModelSwarm >>>> createYearShuffler >>>> Cannot use year shuffler for simulations of one year or less\n");
       fflush(0);
       exit(1);
   }

   //
   // Now calculate dataStartTime and dataEndTime
   //
   {
       int numSimYears = [[yearShuffler getListOfRandomizedYears] getCount];
       int dataEndYear = [timeManager getYearWithTimeT: runStartTime] + numSimYears;
       int dataEndMonth = startMonth;
       int dataEndDay = startDay;

       sprintf(dataEndDate, "%d/%d/%d", dataEndMonth, dataEndDay, dataEndYear);
       dataStartTime = runStartTime;
       dataEndTime = [timeManager getTimeTWithDate: dataEndDate
                                          withHour: 12
                                        withMinute: 0
                                        withSecond: 0];

       dataEndTime = dataEndTime + 86400;

       fprintf(stdout, "TroutModelSwarm >>>> createYearShuffler >>>> numSimYears %d\n", numSimYears);
       fprintf(stdout, "TroutModelSwarm >>>> createYearShuffler >>>> startYear %d endYear %d\n", startYear, endYear);
       fflush(0);
   }

   return self;
}


///////////////////////////////////////////////
//
// updateMortalityCountWith
//
///////////////////////////////////////////////
- updateMortalityCountWith: aDeadFish
{
   TroutMortalityCount* mortalityCount = nil;
   id <Symbol> causeOfDeath = [aDeadFish getCauseOfDeath];
   BOOL ERROR = YES;


   [mortalityCountLstNdx setLoc: Start];
    while(([mortalityCountLstNdx getLoc] != End) && ((mortalityCount = [mortalityCountLstNdx next]) != nil))
    {
         if(causeOfDeath == [mortalityCount getMortality])
         {
             [mortalityCount incrementNumDead];
             ERROR = NO;
             break;
         }
    }

    if(ERROR)
    {
        fprintf(stderr, "TroutModelSwarm >>>> updateMortalityCountWith >>>> mortality source not found in object TroutMortalityCount\n");
        fflush(0);
        exit(1);
    }

   return self;
}


- (id <List>) getListOfMortalityCounts
{
   return listOfMortalityCounts;
}


///////////////////////////////////////////////
//
// writeLFTOutput
//
///////////////////////////////////////////////

- writeLFTOutput
{

  const char * lftOutputFile = "LFT_Output.rpt";

  if(lftOutputFilePtr == NULL) 
  {

     if ((scenario == 1) && (replicate == 1))
     {
        if((lftOutputFilePtr = fopen(lftOutputFile,"w")) == NULL ) 
        {
            fprintf(stderr, "ERROR: TroutModelSwarm >>>> writeLFTOutput >>>> Cannot open %s for writing\n",lftOutputFile);
            fflush(0);
            exit(1);
        }
        fprintf(lftOutputFilePtr,"Limiting factors tool output file\n");
        fprintf(lftOutputFilePtr,"SYSTEM TIME:  %s\n", [timeManager getSystemDateAndTime]);
        fprintf(lftOutputFilePtr,"Scenario, Replicate, Total number of outmigrants, Total number of big outmigrants\n");
     }
     else // Not the first replicate or scenario, so no header 
     {
         if((lftOutputFilePtr = fopen(lftOutputFile,"a")) == NULL) 
         {
            fprintf(stderr, "ERROR: TroutModelSwarm >>>> writeLFTOutput >>>> Cannot open %s for appending\n",lftOutputFile);
            fflush(0);
            exit(1);
         }
     }

  }

   if(lftOutputFilePtr == NULL)
   {
       fprintf(stderr, "ERROR: TroutModelSwarm >>>> writeLFTOutput >>>> File %s is not open\n",lftOutputFile);
       fflush(0);
       exit(1);
   }


   fprintf(lftOutputFilePtr,"%d\t%d\t%d\t%d\n", 
      scenario, 
        replicate, 
          (lftNumTotalOutmigrants * juvenileSuperindividualRatio), 
             (lftNumBigOutmigrants * juvenileSuperindividualRatio));



   return self;
}


//////////////////////////////////////////////////////////
//
// drop
//
//////////////////////////////////////////////////////////
- (void) drop 
{
  //fprintf(stderr, "TroutModelSwarm >>>> drop >>>> BEGIN\n");
  //fflush(0);

  if(reddSummaryFilePtr != NULL){
      fclose(reddSummaryFilePtr);
  }
  if(reddRptFilePtr != NULL){
      fclose(reddRptFilePtr);
  }
  if(lftOutputFilePtr != NULL){
      fclose(lftOutputFilePtr);
  }
  if(timeManager){
    //  fprintf(stderr, "TroutModelSwarm >>>> drop >>>> dropping timeManager\n");
    //  fflush(0);

      [timeManager drop];
      timeManager = nil;
  }
  if(coinFlip){
   [coinFlip drop];
   coinFlip = nil;
  }

  if(fishColorMap){
       id <MapIndex> mapNdx = [fishColorMap mapBegin: scratchZone];
       long* aFishColor = (long *) nil;
 
       while(([mapNdx getLoc] != End) && ((aFishColor = (long *) [mapNdx next]) != (long *) nil)){
            [modelZone free: aFishColor];
       }

       [mapNdx drop];
       [fishColorMap drop];
    
       [speciesSymbolList deleteAll];
       [speciesSymbolList drop];
       speciesSymbolList = nil;
  }
  if(randGen){
      [randGen drop]; 
      randGen = nil;
  }
  if(modelZone != nil){
      int speciesIDX = 0;
      //fprintf(stderr, "TroutModelSwarm >>>> drop >>>> dropping objects in  modelZone >>>> BEGIN\n");
      //fflush(0);
 
      [modelZone free: mySpecies];
      [modelZone free: modelDate];

      for(speciesIDX=0;speciesIDX<numberOfSpecies;speciesIDX++) {
          [modelZone free: speciesName[speciesIDX]];
          [modelZone free: speciesParameter[speciesIDX]];
          [modelZone free: speciesPopFile[speciesIDX]];
          [modelZone free: speciesColor[speciesIDX]];
      }
      [modelZone free: speciesName];
      [modelZone free: speciesParameter];
      [modelZone free: speciesPopFile];
      [modelZone free: speciesColor];

      [modelZone free: MyTroutClass];

      //fprintf(stdout, "Before drop interpolationTables\n");
      //fflush(0);
      //
      // drop interpolation tables
      //
    [spawnVelocityInterpolatorMap deleteAll];
    [spawnVelocityInterpolatorMap drop];
    spawnVelocityInterpolatorMap = nil;
    [spawnDepthInterpolatorMap deleteAll];
    [spawnDepthInterpolatorMap drop];
    spawnDepthInterpolatorMap = nil;
    [cmaxInterpolatorMap deleteAll];
    [cmaxInterpolatorMap drop];
    cmaxInterpolatorMap = nil;
     //
     // End drop interpolation tables
     //
     //fprintf(stdout, "After drop interpolationTables\n");
     //fflush(0);

     // fprintf(stdout, "Before drop capture logistic\n");
     // fflush(0);
     //
     // drop capture logistics
     //
    [captureLogisticMap deleteAll];
    [captureLogisticMap drop];
    captureLogisticMap = nil;
     //
     // drop capture logistics
     //
     // fprintf(stdout, "After drop capture logistic\n");
     // fflush(0);

     // fprintf(stdout, "Before drop juveOutMigLogisticMap\n");
     // fflush(0);
    [juveOutMigLogisticMap deleteAll];
    [juveOutMigLogisticMap drop];
    juveOutMigLogisticMap = nil;
     // fprintf(stdout, "After drop juveOutMigLogisticMap\n");
     // fflush(0);

     [mortalityCountLstNdx drop];
     mortalityCountLstNdx = nil;
  
     [listOfMortalityCounts deleteAll];
     [listOfMortalityCounts drop];
      listOfMortalityCounts = nil; 

     [liveFish deleteAll];
     [liveFish drop];
     liveFish = nil;

     [updateActions drop];
     updateActions = nil;
     [initAction drop];
     initAction = nil;
     [fishActions drop];
     fishActions = nil;
     [reddActions drop];
     reddActions = nil;
     [modelActions drop];
     modelActions = nil;
     [overheadActions drop];
     overheadActions = nil;
  #ifdef PRINT_CELL_FISH_REPORT
     [printCellFishAction drop];
     printCellFishAction = nil;
  #endif

     [modelSchedule drop];
     modelSchedule = nil;
     [printSchedule drop];
     printSchedule = nil;
      
     // The following produces error: FallChinook does not recognize drop
     //[speciesClassList deleteAll];
     //[speciesClassList drop];
     //speciesClassList = nil;
        
     // The following segfaults, but should be fixed
     //[spawnerInitializationRecords deleteAll];
     [spawnerInitializationRecords drop];
     spawnerInitializationRecords = nil;

     [reddBinomialDist drop];
     reddBinomialDist = nil;
        
    [spawners deleteAll];
    [spawners drop];
    spawners = nil;

     [deadFish deleteAll];
     [deadFish drop];
     deadFish = nil;

     [killedFish deleteAll];
     [killedFish drop];
     killedFish = nil;

     [newOutmigrants deleteAll];
     [newOutmigrants drop];
     newOutmigrants = nil;

     [outmigrantList deleteAll];
     [outmigrantList drop];
     outmigrantList = nil;
    
     [reddRemovedList deleteAll];
     [reddRemovedList drop];
     reddRemovedList = nil;
   
     [emptyReddList deleteAll];
     [emptyReddList drop];
     emptyReddList = nil;

     [reddList deleteAll];
     [reddList drop];
     reddList = nil;

     //[Male drop];
     Male = nil;
     //[Female drop];
     Female = nil;

     if(yearShuffler != nil){
          [yearShuffler drop];
          yearShuffler = nil;
     }

     [fishMortalityReporter drop];
     fishMortalityReporter = nil;

     [liveFishReporter drop];
     liveFishReporter = nil;

     [outmigrantReporter drop];
     outmigrantReporter = nil;

     //
     // Drop the fishParams
     //
    //fprintf(stdout, "TroutModelSwarm >>>> drop >>>> dropping fishParams >>>> BEGIN\n");
    //fflush(0);

    [fishParamsMap deleteAll];
    [fishParamsMap drop];
    fishParamsMap = nil;

    //fprintf(stdout, "TroutModelSwarm >>>> drop >>>> dropping fishParams >>>> END\n");
    //fflush(0);

     [fishMortSymbolList deleteAll];
     [fishMortSymbolList drop];
     fishMortSymbolList = nil;

    //id <ListIndex> lstNdx;
    //id aSymbol = nil;
    //lstNdx = [reddMortSymbolList listBegin: scratchZone]; 
    //while(([lstNdx getLoc] != End) && ((aSymbol = [lstNdx next]) != nil)){
      //[modelZone free: aSymbol];
    //}
    //[lstNdx drop];
    [reddMortSymbolList deleteAll];
    [reddMortSymbolList drop];
    reddMortSymbolList = nil;

    //[outmigrationSymbol drop];
    outmigrationSymbol = nil;

     [ageSymbolList deleteAll];
     [ageSymbolList drop];
     ageSymbolList = nil;

     [reachSymbolList deleteAll];
     [reachSymbolList drop];
     reachSymbolList = nil;

     [lifestageSymbolList deleteAll];
     [lifestageSymbolList drop];
     lifestageSymbolList = nil;

     [sizeSymbolList deleteAll];
     [sizeSymbolList drop];
     sizeSymbolList = nil;

      if(habitatManager){
          [habitatManager drop];
          habitatManager = nil;
      }

 //    [self outputModelZone: modelZone];

     [modelZone drop];
     modelZone = nil;

     //fprintf(stdout, "TroutModelSwarm >>>> drop >>>> dropping modelZone >>>> END\n");
     //fflush(0);
  }
  
  [super drop];

  //fprintf(stdout, "TroutModelSwarm >>>> drop >>>> END\n");
  //fflush(0);

  //exit(0);

} //drop




//////////////////////////////////
//
// outputModelZone
//
/////////////////////////////////////
- outputModelZone: (id <Zone>) anArbitraryZone
{
   id <ListIndex> ndx = nil;
   id obj = nil;
   //int liveFishCount = 0;
   //int deadFishCount = 0;

   int numberOfRT = 0;
   int numberOfBT = 0;
   int totalZoneFishCount = 0;
   //int objCount = 0;

   FILE* zout = NULL;

   fprintf(stdout, "\n\n\nTroutModelSwarm >>>> outputModelZone >>>> BEGIN\n");
   fflush(0);
    

   if((zout = fopen("ZoneOutputFile.txt", "a")) == NULL) 
   {
       fprintf(stderr, "ERROR: TroutModelSwarm >>>> outputModelZone >>>> Error opening %s \n", "ZoneOutputFile.txt");
       fflush(0);
       exit(1);
   }
   
   fprintf(zout, "\n\n\nTroutModelSwarm >>>> outputModelZone >>>> BEGIN\n");
   fflush(0);
  
/*
 
   ndx = [[anArbitraryZone getPopulation] listBegin: scratchZone];
   //ndx = [[modelZone getPopulation] listBegin: scratchZone];
   //ndx = [[globalZone getPopulation] listBegin: scratchZone];
   while(([ndx getLoc] != End) && ((obj = [ndx next]) != nil))
   {
          Class aClass = Nil;
          Class ZoneClass = objc_get_class("ZoneAllocMapper");
          char aClassName[20];
          char ZoneClassName[20];

          aClass = object_get_class(obj);

          strncpy(aClassName, class_get_class_name(aClass), 20);   
          strncpy(ZoneClassName, class_get_class_name(ZoneClass), 20);   

          //if(strncmp(aClassName, ZoneClassName, 20) == 0)
          {
              objCount++;
              fprintf(zout, "Class name = %s\n", class_get_class_name (aClass));
              //fprintf(zout, "Class name = %s\n", class_get_class_name (ZoneClass));
              fprintf(zout, "objCount = %d\n", objCount);
              fflush(0);
          } 

    }
    [ndx drop];
*/
   
   ndx = [[anArbitraryZone getPopulation] listBegin: scratchZone];
   while(([ndx getLoc] != End) && ((obj = [ndx next]) != nil))
   {
          Class aClass = Nil;
          Class ZoneClass = objc_get_class("Cutthroat");
          char aClassName[20];
          char ZoneClassName[20];

          aClass = object_get_class(obj);

          strncpy(aClassName, class_get_class_name(aClass), 20);   
          strncpy(ZoneClassName, class_get_class_name(ZoneClass), 20);   


          //if(strncmp(aClassName, ZoneClassName, 20) == 0)
          {
              fprintf(zout, "Class name = %s\n", class_get_class_name (aClass));
              //fprintf(zout, "Class name = %s\n", class_get_class_name (ZoneClass));
              fflush(0);
              if([obj respondsTo: @selector(drop)])
              {
                  fprintf(zout, "Object responds to drop\n");
                  fflush(zout);
              }
              numberOfBT++;
          } 
    }
    [ndx drop];

    totalZoneFishCount = numberOfRT + numberOfBT;

    {
         //char* zBuf[300];
         id <OutputStream> catC = [OutputStream create: anArbitraryZone
                                         setFileStream: zout];
         fprintf(zout, "TroutModelSwarm >>>> outputModelZone >>>> testMemZone describe >>>> BEGIN\n");
         fflush(0);
         [anArbitraryZone describe: catC];
         //fprintf(zout," zBuf = %s\n", zBuf);
         //fflush(zout);

         fprintf(zout, "TroutModelSwarm >>>> outputModelZone >>>> testMemZone describe >>>> END\n");
         fflush(0);
         [catC drop];
    }

    fprintf(zout, "TroutModelSwarm >>>> outputModelZone >>>> END\n\n\n");
    fflush(0);
    fclose(zout);



    fprintf(stdout, "TroutModelSwarm >>>> outputModelZone >>>> END\n\n\n");
    fflush(0);


   return self;
}

@end


