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
#import "globals.h"
#import "Redd.h"
#import "Trout.h"



@implementation Trout

///////////////////////////////////////////////////////////////
//
// createBegin
//
/////////////////////////////////////////////////////////////
+ createBegin: aZone 
{
  Trout * newTrout;

  newTrout = [super createBegin: aZone];

  newTrout->troutZone = [Zone create: aZone];
  newTrout->causeOfDeath = nil;
  newTrout->captureLogistic = nil;
  newTrout->juveOutMigLogistic = nil;
  newTrout->imImmortal = NO;
  newTrout->toggledFishForHabSurvUpdate = nil;
  newTrout->fishParams = nil;
  newTrout->isSpawner = NO;
  newTrout->isFemale = NO;
  newTrout->deathCausedBy = NULL;

  return newTrout;
}

///////////////////////////////////////////////////////////////////////
//
// setCell
//
/////////////////////////////////////////////////////////////////////
- setCell: (FishCell *) aCell 
{

  //fprintf(stdout, "Trout >>>> setCell >>>> BEGIN\n");
  //fflush(0);

  myCell = aCell;

  //fprintf(stdout, "Trout >>>> setCell >>>> END\n");
  //fflush(0);
  //exit(0);

  return self;
}



///////////////////////////////////////////////
//
// setReach
//
// set the fish's reach and its reach symbol
//
/////////////////////////////////////////////// 
- setReach: aReach
{
   reach = aReach;
   reachSymbol = [reach getReachSymbol];

   return self;
}



///////////////////////////////////////////////
//
// setMyRedd
//
// set the fish's redd if it has one
//
/////////////////////////////////////////////// 
- setMyRedd: (id) aRedd
{
   myRedd = aRedd;

   return self;
}




///////////////////////////////////////////////
//
// setNRep
//
// set the fish's superindividual ratio
//
/////////////////////////////////////////////// 
- setNRep: (int) aRatio;
{
   nRep = aRatio;

   return self;
}




///////////////////////////////////////////////
//
// getNRep
//
// get the fish's superindividual ratio
//
/////////////////////////////////////////////// 
- (int) getNRep;
{
   return nRep;
}




///////////////////////////////////////////////
//
// setNatalReachSymbol
//
// set the reach symbol for where fish emerged (for salmon)
//
/////////////////////////////////////////////// 
- setNatalReachSymbol: (id <Symbol>) aSymbol
{
   natalReachSymbol = aSymbol;

   return self;
}



- (FishCell *) getCell 
{
  return myCell;
}


- getReach
{
   return reach;
}



///////////////////////////////////
//
// getReachSymbol
//
// reachSymbol is set in setReach
//
//////////////////////////////////
- (id <Symbol>) getReachSymbol
{
   return reachSymbol;
}



///////////////////////////////////
//
// getNatalReachSymbol
//
// New for salmon
//
//////////////////////////////////
- (id <Symbol>) getNatalReachSymbol
{
   return natalReachSymbol;
}



//////////////////////////////////////////////////////////////////
//
// createEnd
//
//////////////////////////////////////////////////////////////////
- createEnd 
{

  [super createEnd];

  if(randGen == nil)
  {
     fprintf(stderr, "ERROR: Trout >>>> createEnd >>>> fish %p doesn't have a randGen.", self);
     fflush(0);
     exit(1);
  } 
  else 
  {
     spawnDist = [UniformDoubleDist create: troutZone
                              setGenerator: randGen
                              setDoubleMin: 0.0
                                    setMax: 1.0];

     dieDist = [UniformDoubleDist create: troutZone
                            setGenerator: randGen
                            setDoubleMin: 0.0
                                  setMax: 1.0];

     oReachCellChoiceDist = [UniformUnsignedDist create: troutZone
                                           setGenerator: randGen];
  }

  hourlyDriftConRate = 0.0;
  hourlySearchConRate = 0.0;
  deadOrAlive = "ALIVE";
 
  spawnedThisSeason = NO;

  destCellList = [List create: troutZone];

  return self;
}


////////////////////////////////////////////
//
// setTimeManager
//
///////////////////////////////////////////
- setTimeManager: (id <TimeManager>) aTimeManager
{
     timeManager = aTimeManager;
     return self;
}


///////////////////////////////////////////
//
// setModel
//
//////////////////////////////////////////
- setModel: (id <TroutModelSwarm>) aModel
{
    model = aModel;
    return self;
}

///////////////////////////////////////
//
// setRandGen
//
//////////////////////////////////////
- setRandGen: aRandGen
{
     randGen = aRandGen;
     return self;
}


///////////////////////////////////////////////////////////////
//
// setCMaxInterpolator
//
///////////////////////////////////////////////////////////////
- setCMaxInterpolator: (id <InterpolationTable>) anInterpolator
{
   cmaxInterpolator = anInterpolator;
   return self;
}



///////////////////////////////////////////
//
// setSpawnDepthInterpolator
//
//////////////////////////////////////////
- setSpawnDepthInterpolator: (id <InterpolationTable>) anInterpolator
{
   spawnDepthInterpolator = anInterpolator;
   return self;
}



////////////////////////////////////////////
//
// setSpawnVelocityInterpolator
//
///////////////////////////////////////////
- setSpawnVelocityInterpolator: (id <InterpolationTable>) anInterpolator
{
    spawnVelocityInterpolator = anInterpolator;
    return self;
}


////////////////////////////////////////////////////
//
// setCaptureLogistic
//
////////////////////////////////////////////////////
- setCaptureLogistic: (LogisticFunc *) aLogisticFunc
{
   captureLogistic = aLogisticFunc;
   return self;
}


////////////////////////////////////////////////////
//
// setJuveOutMigLogistic
//
////////////////////////////////////////////////////
- setJuveOutMigLogistic: (LogisticFunc *) aLogisticFunc
{
   juveOutMigLogistic = aLogisticFunc;
   return self;
}



/*
//////////////////////////////////////////////////
//
// setMovementRule
//
//////////////////////////////////////////////////
- setMovementRule: (char *) aRule  {
  movementRule = aRule;
  return self;
}

*/


////////////////////////////////////////////
//
// setIsFemale
//
////////////////////////////////////////////
- setIsFemale: (BOOL) isAFemale;
{
     isFemale = isAFemale;
     return self;
}


/////////////////////////////////////////
//
// getIsFemale
//
/////////////////////////////////////////
- (BOOL) getIsFemale
{
    return isFemale;
}





/////////////////////////////////////////////////////////
//
// setSpeciesIndex
//
////////////////////////////////////////////////////////
- setSpeciesNdx: (int) anIndex {
  speciesNdx = anIndex;

  return self;
}



/////////////////////////////////////////////////////////
//
// getSpeciesIndex
//
////////////////////////////////////////////////////////
- (int) getSpeciesNdx {
  return speciesNdx;

}




/////////////////////////////////////////////////////////////////////////////
//
// setFishColor
//
////////////////////////////////////////////////////////////////////////////
- setFishColor: (Color) aColor 
{
  myColor = aColor;
  return self;
}

/////////////////////////////////////////////////////////////
//
// drawSelfOn
//
/////////////////////////////////////////////////////////////
- drawSelfOn: (id <Raster>) aRaster atX: (int) anX Y: (int) aY 
{
  //fprintf(stdout, "Trout >>>> drawSelfOn >>>> BEGIN\n");
  //fprintf(stdout, "Trout >>>> drawSelfOn >>>> myColor = %ld\n", (long) myColor);
  //fflush(0);

  if (isSpawner == YES)
  {
  [aRaster fillRectangleX0: anX - 4 
                  Y0: aY - 2 
                  X1: anX + 4 
                  Y1: aY + 2 
           //    Width: 3 
               Color: myColor];  
  }
  else
  {
  [aRaster drawPointX: anX 
                  Y: aY 
              Color: myColor];  
  }

  //fprintf(stdout, "Trout >>>> drawSelfOn >>>> END\n");
  //fflush(0);

  return self;
}



/////////////////////////////////////////////////////////////////////
//
// tagFish
//
/////////////////////////////////////////////////////////////////////
- tagFish 
{
  fprintf(stdout, "Trout >>>> tagFish >>>> BEGIN\n");
  fprintf(stdout, "Trout >>>> tagFish >>>> trout = %p\n", self);
  fflush(0);

  if(reach == nil)
  {
      fprintf(stdout, "ERROR: Trout >>>> tagFish >>>> reach is nil\n");
      fflush(0);
      exit(1);
  }

  [self setFishColor: (Color) TAG_FISH_COLOR];
  [model updateTkEventsFor: reach];

  //fprintf(stdout, "Trout >>>> tagFish >>>> color = %s\n", [model getTagFishColor]);
  fprintf(stdout, "Trout >>>> tagFish >>>> trout = %p\n", self);
  //fprintf(stdout, "Trout >>>> tagFish >>>> END\n");
  //fflush(0);
  return self;
}



//////////////////////////////////////////
//
// setFishParams
//
//////////////////////////////////////////
- setFishParams: (FishParams *) aFishParams
{
    fishParams = aFishParams;
    return self;
}


///////////////////////////////////////////
//
// getFishParams
// 
///////////////////////////////////////////
- (FishParams *) getFishParams
{
    return fishParams;
}
 
/////////////////////////////////////////////////////////////////////////////
//
// setSpecies
//
////////////////////////////////////////////////////////////////////////////
- setSpecies: (id <Symbol>) aSymbol 
{
   species = aSymbol;
   return self;
}


/////////////////////////////////////////////////////////////////////////////
//
// getSpecies
//
////////////////////////////////////////////////////////////////////////////
- (id <Symbol>) getSpecies
{
   return species;
}


////////////////////////////////////
//
// setSex
//
/////////////////////////////////////
- setSex: (id <Symbol>) aSex
{
   sex = aSex;
   return self;
}


//////////////////////////////////////
//
// getSex
//
///////////////////////////////////////
- (id <Symbol>) getSex
{
   return sex;
}



/////////////////////////////////////////////////////////////////////////////
//
// setAge
//
////////////////////////////////////////////////////////////////////////////
- setAge: (int) anInt 
{
   age = anInt;
   return self;
}

///////////////////////////////////////////////////////////
//
// getAge
//
//////////////////////////////////////////////////////////
- (int) getAge 
{
   return age;
}


////////////////////////////////////////////////////////
//
// updateFish
//
// We assume that all fish increment their age
// on Jan 1.
//
////////////////////////////////////////////////////////
- updateFishWith: (time_t) aModelTime
{
   if([timeManager isThisTime: aModelTime onThisDay: "01/1"] == YES)
   {
       [self incrementAge];  
   }
  
   //
   // reset spawnedThisSeason at the start of each spawning season
   //
   //if([timeManager isThisTime: aModelTime 
                    //onThisDay: (char *) fishParams->fishSpawnStartDate] == YES) 
   //{
      //spawnedThisSeason = NO;
   //}

   toggledFishForHabSurvUpdate = nil;
 
   return self;
}

///////////////////////////////////////////////////////////
//
// incrementAge
//
///////////////////////////////////////////////////////////
- incrementAge 
{
  ++age;
  [self setAgeSymbol: [model getAgeSymbolForAge: age]];
  return self;
}


//////////////////////////////////////
//
// setAgeSymbol
//
//////////////////////////////////////
- setAgeSymbol: (id <Symbol>) anAgeSymbol
{
   ageSymbol = anAgeSymbol;
   return self;
}


//////////////////////////////////////
//
// setSizeSymbol
//
//////////////////////////////////////
- setSizeSymbol: (id <Symbol>) aSizeSymbol
{
   sizeSymbol = aSizeSymbol;
   return self;
}


//////////////////////////////////////
//
// setLifestageSymbol
//
//////////////////////////////////////
- setLifestageSymbol: (id <Symbol>) aLifestageSymbol
{
   lifestageSymbol = aLifestageSymbol;
   return self;
}


////////////////////////////////////
//
// getAgeSymbol
//
////////////////////////////////////
- (id <Symbol>) getAgeSymbol
{
   return ageSymbol;
}



////////////////////////////////////
//
// getSizeSymbol
//
////////////////////////////////////
- (id <Symbol>) getSizeSymbol
{
   return sizeSymbol;
}



////////////////////////////////////
//
// getLifestageSymbol
//
////////////////////////////////////
- (id <Symbol>) getLifestageSymbol
{
   return lifestageSymbol;
}



////////////////////////////////////////////
//
// setIsSpawner
//
///////////////////////////////////////////
- setIsSpawner: (BOOL) anIsSpawner
{
    isSpawner = anIsSpawner;
    return self;
}


/////////////////////////////////////////////
//
// getIsSpawner
//
//////////////////////////////////////////////
- (BOOL) getIsSpawner
{
    return isSpawner;
}


////////////////////////////////////////////////////
//
// setFishCondition
//
/////////////////////////////////////////////////
- setFishCondition: (double) aCondition 
{
  fishCondition = aCondition;
  return self;
}


/////////////////////////////////////////////////////////////////////
//
// setFishWeightFromLength: andCondtion:
// 
////////////////////////////////////////////////////////////////////
- setFishWeightFromLength: (double) aLength andCondition: (double) aCondition 
{

  fishWeight =   aCondition 
               * fishParams->fishWeightParamA 
               * pow(aLength,fishParams->fishWeightParamB);


   #ifdef DEBUG_TROUT_FISHPARAMS
     #ifdef DEBUG_GROW
   
       fprintf(stderr,"\n");
       fprintf(stderr,"<<<<< METHOD: setFishWeightFromLength speciesNdx = %d >>>>>\n", speciesNdx);
       xprint(self);
       fprintf(stderr,"fishWeightParamA = %f fishWeightParamB = %f \n", fishParams->fishWeightParamA,  fishParams->fishWeightParamB);
       fprintf(stderr,"\n"); 
    
     #endif
   #endif



  return self;
}

/////////////////////////////////////////////////////////////////
//
// getWeightWithIntake
//
//////////////////////////////////////////////////////////////////
- (double) getWeightWithIntake: (double) anEnergyIntake {
  double deltaWeight;
  double weight;


   #ifdef DEBUG_TROUT_FISHPARAMS
     #ifdef DEBUG_GROW
   
       fprintf(stderr,"\n");
       fprintf(stderr,"<<<<< METHOD: getWeightWithIntake speciesNdx = %d >>>>>\n", speciesNdx);
       xprint(self);
       fprintf(stderr,"fishEnergyDensity = %f \n", fishParams->fishEnergyDensity);
       fprintf(stderr,"\n"); 
    
     #endif
   #endif



  deltaWeight = anEnergyIntake/(fishParams->fishEnergyDensity);
  weight = fishWeight + deltaWeight;

  if(weight > 0.0) 
  {
    return weight;
  }
  else 
  {
    return 0.0;
  }
}


/////////////////////////////////////////////////////////////////////
//
// getFishWeight
//
////////////////////////////////////////////////////////////////////
- (double) getFishWeight 
{
  return fishWeight;
}

/////////////////////////////////////////////////////////////////////
//
// getSuperindividualWeight
//
////////////////////////////////////////////////////////////////////
- (double) getSuperindividualWeight 
{
  return superindividualWeight;
}

/////////////////////////////////////////////////////////////////////////////
//
// setFishLength
//
////////////////////////////////////////////////////////////////////////////
- setFishLength: (double) aLength 
{
  fishLength = aLength;
  return self;
}


/////////////////////////////////////////////////////////////////////////////
//
// setFishID
//
////////////////////////////////////////////////////////////////////////////
- setFishID: (int) anIDNum 
{
  fishID = anIDNum;

  return self;
}




///////////////////////////////////////////////////
//
// setArrivalTime
//
///////////////////////////////////////////////////
- setArrivalTime: (time_t) anArrivalTime
{
      arrivalTime = anArrivalTime;
      return self;
}



////////////////////////////////////
//
// getArrivalTime
//
////////////////////////////////////
- (time_t) getArrivalTime
{
      return arrivalTime;
}



////////////////////////////////////////////////////////////////////
//
// getLengthForNewWeight
//
//////////////////////////////////////////////////////////////////
- (double) getLengthForNewWeight: (double) aWeight 
{
  double fishWannabeLength;


   #ifdef DEBUG_TROUT_FISHPARAMS
     #ifdef DEBUG_GROW
   
      
       fprintf(stderr,"\n");
       fprintf(stderr,"<<<<< METHOD: getLengthForNewWeight speciesNdx = %d >>>>>\n", speciesNdx);
       xprint(self);
       fprintf(stderr,"fishWeightParamA = %f fishWeightParamB = %f\n", fishParams->fishWeightParamA, fishParams->fishWeightParamB);
       fprintf(stderr,"\n"); 
        
 
     #endif
   #endif


  fishWannabeLength = pow((aWeight/fishParams->fishWeightParamA),1/fishParams->fishWeightParamB);

  if(fishLength <  fishWannabeLength) 
  {
     return fishWannabeLength;
  }
  else 
  {
     return fishLength;
  }
}


/////////////////////////////////////////////////////////////////////////////
//
//  getFishLength
//
////////////////////////////////////////////////////////////////////////////
- (double) getFishLength 
{
  return fishLength;
}



//////////////////////////////////
//
// getFishCount
//
// Modified to show superindividual count
//
/////////////////////////////////
- (int) getFishCount
{
   return nRep;
}

///////////////////////////////////////////////////////////////
//
// getConditionForWeight: andLength:
//
//////////////////////////////////////////////////////////////
- (double) getConditionForWeight: (double) aWeight andLength: (double) aLength 
{
  double condition=LARGEINT;

   #ifdef DEBUG_TROUT_FISHPARAMS
     #ifdef DEBUG_GROW
    /*
   
       fprintf(stderr,"\n");
       fprintf(stderr,"<<<<<METHOD:  getConditionForWeight speciesNdx = %d >>>>>\n", speciesNdx);
       xprint(self);
       fprintf(stderr,"fishWeightParamA = %f fishWeightParamB = %f\n", fishParams->fishWeightParamA, fishParams->fishWeightParamB);
       fprintf(stderr,"\n"); 
    */
     #endif
   #endif



   condition = aWeight/
        (fishParams->fishWeightParamA*pow(aLength,fishParams->fishWeightParamB)); 

   return condition;
}

- (double) getFishCondition 
{
  return fishCondition;
}

/////////////////////////////////////////////////////////////////
//
// getFracMatureForLength
// 
// Modified for salmon!!
//
//////////////////////////////////////////////////////////////
- (double) getFracMatureForLength: (double) aLength 
{
   double fmature;

   #ifdef DEBUG_TROUT_FISHPARAMS
     #ifdef DEBUG_GROW
   
       fprintf(stderr,"\n");
       fprintf(stderr,"<<<<< METHOD: getFracMatureForLength speciesNdx = %d >>>>>\n", speciesNdx);
       xprint(self);
    
     #endif
   #endif


  fmature =  aLength/fishParams->fishOutmigrateSuccessL9;

  if(fmature < 1.0) 
  {
     return fmature;
  }
  else 
  {
    return 1.0;
  }
}


/////////////////////////////////////////////////////////////////////////////
//
// getFishShelterArea
//
////////////////////////////////////////////////////////////////////////////
- (double) getFishShelterArea 
{
  return fishLength*fishLength;
}



///////////////////////////////////
//
// getPolyCellDepth
//
//////////////////////////////////
- (double) getPolyCellDepth
{
    return [myCell getPolyCellDepth];
}


//////////////////////////////////
//
// getPolyCellVelocity
//
/////////////////////////////////
- (double) getPolyCellVelocity
{
   return [myCell getPolyCellVelocity];
}



////////////////////////////////////////////////////////
//
// TIME_T METHODS
//
////////////////////////////////////////////////////////

- setTimeTLastSpawned: (time_t) aTime_t 
{
  timeLastSpawned = aTime_t;
  return self;
}


- (time_t) getCurrentTimeT 
{
  return [model getModelTime];
}


/////////////////////////////////////////////////
//
// getSwimSpeedMaxSwimSpeedRatio
//
////////////////////////////////////////////////
- (double) getSwimSpeedMaxSwimSpeedRatio
{
   double aSwimSpeedMaxSwimSpeedRatio;

   //
   // maxSwimSpeedForCell is set in the 
   // following methods: moveToBestDest
   //                    expectedMaturityAt
   //
   // cellSwimSpeedForCell is set in: calcNetEnergyForCell
   //
   if(maxSwimSpeedForCell <= 0.0)
   {
       fprintf(stdout, "ERROR: Trout >>>> getSwimSpeedMaxSwimSpeedRatio >>>> maxSwimSpeedForCell is less than or equal to zero\n");  
       fflush(0);
       exit(1);
   }

   aSwimSpeedMaxSwimSpeedRatio = cellSwimSpeedForCell/maxSwimSpeedForCell;


   //
   // FIX ME
   //


   return aSwimSpeedMaxSwimSpeedRatio ;
}


////////////////////////////////////////////////
//
// calcDepthLengthRatioAt
//
///////////////////////////////////////////////// 
- (double) calcDepthLengthRatioAt: (FishCell *) aCell
{
   double depthLengthRatio = [aCell getPolyCellDepth]/fishLength;
   return depthLengthRatio;
}



/////////////////////////////////////////////////////////
//
// getDepthLengthRatioForCell
//
// depthLengthRatioForCell is set in expectedMaturityAt
//
/////////////////////////////////////////////////////////
- (double) getDepthLengthRatioForCell
{
   return depthLengthRatioForCell;
}


/*
- (BOOL) getFishSpawnedThisTime
{
  BOOL didISpawn = NO;
  if(timeLastSpawned == [model getModelTime])
  {
     didISpawn = YES;
  }
  return didISpawn;
}  
*/



/////////////////////////////////////////////
//
// setSpawnedThisSeason
//
////////////////////////////////////////////
- setSpawnedThisSeason: (BOOL) aBool
{
   spawnedThisSeason = aBool;
   return self;
}


/////////////////////////////////////////////
//
// getSpawnedThisSeason
//
///////////////////////////////////////////
- (BOOL) getSpawnedThisSeason
{
   return spawnedThisSeason;
}


/////////////////////////////////////////////////
//
// getFeedTmeForCell
//
// feedTimeForCell is set in: moveToBestDest
//                            expectedMaturityAt  
//
//////////////////////////////////////////////////
- (double) getFeedTimeForCell
{
    return feedTimeForCell;
} 
    

////////////////////////////////////////////////////////////////////
//
//
// Scheduled actions for trout 
//
// There are four scheduled actions: spawn, move, grow, and die 
//
// spawn is the first action taken by fish in their daily routine 
// spawn may result in the fish moving to another cell 
//
////////////////////////////////////////////////////////////////////


/////////////////////////////////////
//
// spawn
//
/////////////////////////////////////
- spawn 
{
  //fprintf(stdout, "Trout >>>> spawn >>>> BEGIN\n");
  //fflush(0);

  if(isSpawner == YES)
  {
      // spawn is executed only by females
      // determine if ready to spawn 
      //    spawning criteria
      //       a) date window
      //       b) not spawned this year
      // identify Redd location
      //       a) within moving distance
      //       b) pick cell with highest spawnQuality, where
      //           spawnQuality = spawnDepthSuit * spawnVelocitySuit * spawnGravelArea
      // move to spawning cell
      // make Redd
      //       calculate numberOfEggs
      //       set spawnerLength
      // update lastSpawnDate to today
      // select a male that also spawns

      // HOWEVER: for inSALMO all spawners, male or female, spawn by the last
      // date of the date window.

      id spawnCell=nil;
      id <List> fishList;
      id <ListIndex> fishLstNdx;
      id anotherTrout = nil;


      //
      // If we're dead or male we can't spawn we can't spawn
      //
      // But if we're male and it's the last day of spawning, then
      // we have to do it by ourselves.
      //
      if(sex == Male) 
      {
        if([timeManager isThisTime: [self getCurrentTimeT] 
             onThisDay: fishParams->fishSpawnEndDate] == YES) 
         { 
           [self updateMaleSpawner];
           return self;
         }
        else
         {
           return self;
         }
      }

      if(causeOfDeath) 
      {
         return self;
      }
    

      if(reach == nil) 
      {
          fprintf(stderr, "ERROR: Trout >>>> spawn >>>> reach is nil\n");
          fflush(0);
          exit(1);
      }

      if([self isFemaleReadyToSpawn] == NO)
      {
          #ifdef READY_TO_SPAWN_RPT
              [self printReadyToSpawnRpt: NO];
          #endif

          return self;
      }

      #ifdef READY_TO_SPAWN_RPT
          [self printReadyToSpawnRpt: YES];
      #endif

      if((spawnCell = [self findCellForNewRedd]) == nil) 
      {
         fprintf(stderr, "WARNING: Trout >>>> spawn >>>> No spawning habitat found, making Redd without moving");
         fflush(0);
         spawnCell = myCell;
      }

         spawnedThisSeason = YES;
         fishFeedingStrategy = GUARDING;

         [spawnCell addFish: self]; 
         [spawnCell calcCellAvailableGravelArea]; 
         [self _createAReddInCell_: spawnCell];
    
      //
      // reduce weight of spawners 
      // and update condition
      //
      fishWeight = fishWeight * (1.0 - fishParams->fishSpawnWtLossFraction);

      fishCondition = [self getConditionForWeight: fishWeight andLength: fishLength];

      timeLastSpawned = [self getCurrentTimeT];


      //
      // Now, find male spawner.
      //
      fishList = [model getLiveFishList]; 

      if(fishList == nil)
      {
         fprintf(stderr, "ERROR: Trout >>>> spawn >>>> fishList is nil\n");
         fflush(0);
         exit(1);
      }

      //
      // Search for first (= largest) eligible
      // male, if there is one.
      // 
      //
      fishLstNdx = [fishList listBegin: scratchZone];
      while(([fishLstNdx getLoc] != End) && ((anotherTrout = [fishLstNdx next]) != nil))
      {
           if([self shouldISpawnWith: anotherTrout])
           {
               [anotherTrout updateMaleSpawner];
               break;
           }
      }
      [fishLstNdx drop];

    }

    //fprintf(stdout, "Trout >>>> spawn >>>> END\n");
    //fflush(0);

    return self;
}


///////////////////////////////////////////////////////////
//
// isFemaleReadyToSpawn
//
///////////////////////////////////////////////////////////
- (BOOL) isFemaleReadyToSpawn 
{
  time_t currentTime;
  double currentTemp = -LARGEINT;

  /* ready?
   *    a) age minimum (fish) <branch>
   *    b) size minimum (fish) <branch>
   *    c) spawned already this year  (fish) <branch>
   *    d) date window (cell) <branch> <msg>
   *    e) flow threshhold (cell) <branch> <msg>
   *    f) temperature (cell) <branch> <msg>
   *    g) steady flows (cell) <branch> <msg>
   *    h) condition threshhold (fish) <calc>

	Criteria are re-ordered for salmon.

   */


   #ifdef DEBUG_TROUT_FISHPARAMS
     #ifdef DEBUG_SPAWN
   
       fprintf(stderr,"\n");
       fprintf(stderr,"<<<<< METHOD: readyToSpawn speciesNdx = %d >>>>>\n", speciesNdx);
       xprint(self);
       fprintf(stderr,"fishSpawnMinTemp = %f \n", fishParams->fishSpawnMinTemp);
       fprintf(stderr,"fishSpawnMaxFlow = %f \n", fishParams->fishSpawnMaxFlow);
       fprintf(stderr,"fishSpawnMaxFlowChange = %f \n", fishParams->fishSpawnMaxFlowChange);
       fprintf(stderr,"fishSpawnMinCond = %f \n", fishParams->fishSpawnMinCond);
       fprintf(stderr,"fishSpawnProb = %f \n", fishParams->fishSpawnProb);
       fprintf(stderr,"\n"); 
    
     #endif
   #endif

  //
  // SPAWNED THIS SEASON?
  //
  if(spawnedThisSeason == YES) 
  {
      return NO;
  }

  currentTime =  [self getCurrentTimeT];

  //
  // IN THE WINDOW FOR THIS YEAR?
  //
  if([timeManager isTimeT: currentTime
              betweenMMDD: (char *) fishParams->fishSpawnStartDate 
                  andMMDD: (char *) fishParams->fishSpawnEndDate] == NO) 
  { 
      return NO;
  }

  //
  //  IS IT THE LAST DAY OF THE SPAWN WINDOW?
  //  Removed as criterion starting with v. 1.5
  /*
  if([timeManager isThisTime: currentTime onThisDay: fishParams->fishSpawnEndDate] == YES) 
  { 
      return YES;
  }
  */


  currentTemp = [reach getTemperature];

  if(currentTemp == -LARGEINT)
  {
      fprintf(stderr, "ERROR: Trout >>>> readyToSpawn >>>> currentTemp = %f\n", currentTemp);
      fflush(0);
      exit(1);
  }
  if((currentTemp < fishParams->fishSpawnMinTemp) ||
	   (fishParams->fishSpawnMaxTemp < currentTemp))
  {
      return NO;
  }

  //
  // FLOW THRESHHOLD
  //
      //fprintf(stdout, "ERROR: Trout >>>> readyToSpawn >>>> getRiverFlow = %f getHabMaxSpawnFlow = %f \n", [reach getRiverFlow], [reach getHabMaxSpawnFlow]);
      //fflush(0);
  if([reach getRiverFlow] > [reach getHabMaxSpawnFlow])
  {
      return NO;
      //fprintf(stdout, "ERROR: Trout >>>> readyToSpawn >>>> returning NO due to MaxFlow constraint\n");
      //fflush(0);
      //exit(0);
  }

  //
  // STEADY FLOWS
  //
  if(([reach getFlowChange]/[reach getRiverFlow]) > fishParams->fishSpawnMaxFlowChange)
  {
      return NO;
  }


  //
  // CONDITION THRESHHOLD - Turned off for salmon
  //
  //if(fishCondition <= fishParams->fishSpawnMinCond)
  //{
      //return NO;
  //}


  //
  // FINALLY TEST AGAINST RANDOM DRAW
  //
  if([spawnDist getDoubleSample] > fishParams->fishSpawnProb)
  {
      return NO;
  }

  //
  // IF WE FALL THROUGH ALL THE ABOVE, then YES
  // I'M READY TO SPAWN.
  //
  return YES;
   
} // readyToSpawn



/////////////////////////////////////////////
//
// shouldISpawnWith
//
/////////////////////////////////////////////
- (BOOL) shouldISpawnWith: aTrout
{
   if([aTrout getSex] != Male)
   {
       return NO;
   }
   if([aTrout getIsSpawner] != YES)
   {
       return NO;
   }
   if([aTrout getSpecies] != species)
   {
       return NO;
   }
   if([aTrout getReach] != reach)
   {
       return NO;
   }
   // The following criteria are not used for salmon
   //if([aTrout getFishLength] < fishParams->fishSpawnMinLength)
   //{
       //return NO;
   //}
   //if([aTrout getAge] < fishParams->fishSpawnMinAge)
   //{
       //return NO;
   //}
   //if([aTrout getFishCondition] > fishParams->fishSpawnMinCond) 
   //{
       //return NO;
   //}
   if([aTrout getSpawnedThisSeason] == YES) 
   {
       return NO;
   }

   return YES;
}


////////////////////////////////////
//
// updateMaleSpawner
//
///////////////////////////////////       
- updateMaleSpawner 
{
  if(sex != Male)
  {
     fprintf(stderr, "ERROR: Trout >>>> updateMaleSpawner >>>> fish is not male\n");
     fflush(0);
     exit(1);
  }

  spawnedThisSeason = YES;
  fishFeedingStrategy = SPENTMALE;

  fishWeight = fishWeight * (1.0 - fishParams->fishSpawnWtLossFraction);

  //
  // and update condition - because it is otherwise set only in
  // "grow", which spawners do not execute
  //
 
  fishCondition = [self getConditionForWeight: fishWeight andLength: fishLength];

  return self;
}  
       


/////////////////////////////////////////////
//
// findCellForNewRedd
//
////////////////////////////////////////////
- (FishCell *) findCellForNewRedd
{
  id <ListIndex> cellNdx;
  id bestCell=nil;
  id nextCell=nil;
  double bestSpawnQuality=0.0;
  double spawnQuality=-LARGEINT;

//  fprintf(stdout, "Trout >>>> findCellForNewRedd >>>> BEGIN\n");
//  fflush(0);

  if(potentialReddCells == nil)
  {
     potentialReddCells = [List create: troutZone];
  }

  [myCell getNeighborsInReachWithin: maxMoveDistance
                    withList: potentialReddCells]; 

  [potentialReddCells addFirst: myCell];

  #ifdef SPAWN_CELL_RPT
     [self printSpawnCellRpt: potentialReddCells];
  #endif

  cellNdx = [potentialReddCells listBegin: scratchZone];
  while(([cellNdx getLoc] != End) && ((nextCell = [cellNdx next]) != nil)) 
  {
    spawnQuality = [self getSpawnQuality: nextCell];

    if(spawnQuality > bestSpawnQuality) 
    {
      bestSpawnQuality = spawnQuality;
      bestCell = nextCell;
    }
  }

  if(bestCell == nil)
  {
      [cellNdx setLoc: Start];
      while (([cellNdx getLoc] != End) && ((nextCell = [cellNdx next]) != nil)) 
      {
        spawnQuality = [self getNonGravelSpawnQuality: nextCell];

        if(spawnQuality > bestSpawnQuality) 
        {
          bestSpawnQuality = spawnQuality;
          bestCell = nextCell;
        }
      }
  }

  [cellNdx drop];

  [potentialReddCells removeAll];
  [potentialReddCells drop];
  potentialReddCells = nil;

  //
  // we test for nil in the calling method
  //
  //fprintf(stdout, "Trout >>>> findCellForNewRedd >>>> best depth: %f\n",[bestCell getPolyCellDepth]);

  //fprintf(stdout, "Trout >>>> findCellForNewRedd >>>> END\n");
  //fflush(0);

  return bestCell;
}



///////////////////////////////////////
//
// _createAReddInCell_
//
//////////////////////////////////////
- _createAReddInCell_: (FishCell *) aCell 
{
  id  newRedd;

   #ifdef DEBUG_TROUT_FISHPARAMS
     #ifdef DEBUG_SPAWN
   
       fprintf(stderr,"\n");

       fprintf(stderr,"<<<<< _createAReddInCell speciesNdx = %d >>>>>\n", speciesNdx);

       fprintf(stderr,"<<<<< _createAReddInCell redd = %p >>>>>\n", self);
       fprintf(stderr,"<<<<< _createAReddInCell myCell = %p >>>>>\n", aCell);
       fprintf(stderr,"fishFecundParamA = %f fishFecundParamB = %f\n", fishParams->fishFecundParamA, fishParams->fishFecundParamB);
       fprintf(stderr,"\n"); 
    
     #endif
   #endif

  newRedd = [TroutRedd createBegin: [model getModelZone]];
  [newRedd setCell: aCell];
  [newRedd setModel];
  [newRedd setFishParams: fishParams];
  [newRedd setTimeManager: timeManager];
  [newRedd setCellNumber: [aCell getPolyCellNumber]];
  [newRedd setReddColor: myColor];
  [newRedd setSpecies: [self getSpecies]];
  [newRedd setSpeciesNdx: [self getSpeciesNdx]];
  [newRedd setNumberOfEggs: fishParams->fishFecundParamA
         * pow(fishLength, fishParams->fishFecundParamB)
         * fishParams->fishSpawnEggViability];
  [newRedd setSpawnerLength: fishLength];
  [newRedd setSpawnerWeight: fishWeight];
  [newRedd setSpawnerAge: age];
  [newRedd setCreateTimeT: [self getCurrentTimeT]];
  [newRedd setReddBinomialDist: [model getReddBinomialDist]];  
  [newRedd setIAmGuarded: YES];

  newRedd = [newRedd createEnd];

  [aCell addRedd: newRedd];

  [[model getReddList] addLast: newRedd];

  myRedd = newRedd;

  return self;
}



//////////////////////////////////////////////////
//
// getSpawnerDefenseArea
//
//////////////////////////////////////////////////
- (double) getSpawnerDefenseArea
{
     return fishParams->fishSpawnDefenseArea; 
}



////////////////////////////////////////////////////////////////////
//
// getSpawnQuality
//
////////////////////////////////////////////////////////////////////
- (double) getSpawnQuality: aCell 
{
  double spawnQuality;

  spawnQuality = [self getSpawnDepthSuitFor: [aCell getPolyCellDepth] ]
               * [self getSpawnVelSuitFor: [aCell getPolyCellVelocity] ]
               * [aCell getCellAvailableGravelArea];

  /*
  spawnQuality = [self getSpawnDepthSuitFor: [aCell getPolyCellDepth] ]
               * [self getSpawnVelSuitFor: [aCell getPolyCellVelocity] ]
               * [aCell getPolyCellArea]
               * [aCell getCellFracSpawn]; 

  */
  return spawnQuality;
}


////////////////////////////////////////////////////
//
// getNonGravelSpawnQuality
//
///////////////////////////////////////////////////
- (double) getNonGravelSpawnQuality: aCell
{
    double spawnQuality;
    spawnQuality =   [self getSpawnDepthSuitFor: [aCell getPolyCellDepth]]
                   * [self getSpawnVelSuitFor: [aCell getPolyCellVelocity]];

    return spawnQuality;
}



//////////////////////////////////////////////////////////////////////
//
// getSpawnDepthSuitFor
//
/////////////////////////////////////////////////////////////////////
- (double) getSpawnDepthSuitFor: (double) aDepth 
{
    double sds=LARGEINT;
   
    if(spawnDepthInterpolator == nil)
    {
       fprintf(stderr, "ERROR: Trout >>>> getSpawnDepthSuitFor >>>> spawnDepthInterpolator is nil\n");
       fflush(0);
       exit(1);
    }

    sds = [spawnDepthInterpolator getValueFor: aDepth];

    if(sds < 0.0)
    {
       sds = 0.0;
    }

    return sds;

} 




/////////////////////////////////////////////////////////////////////
//
// getSpawnVelSuitFor 
//
/////////////////////////////////////////////////////////////////////
- (double) getSpawnVelSuitFor: (double) aVel 
{
    double svs=LARGEINT;

    if(spawnVelocityInterpolator == nil)
    {
       fprintf(stderr, "ERROR: Trout >>>> spawnVelocityInterpolator is nil\n");
       fflush(0);
       exit(1);
    }

    svs = [spawnVelocityInterpolator getValueFor: aVel];

    if(svs < 0.0)
    {
        svs = 0.0;
    }

    return svs;
}


//////////////////////////////////////////////////////////////////////
//
// Move 
//
// move is the second action taken by fish in their daily routine 
//
//////////////////////////////////////////////////////////////////////
- move 
{
       //fprintf(stdout, "Trout >>>> move >>>> BEGIN\n");
       //fflush(0);
   //
   // calcMaxMoveDistance sets the ivar
   // maxMoveDistance.
   //
   [self calcMaxMoveDistance];

   if(isSpawner == YES)
   {

     if(spawnedThisSeason == YES)
     {
       //
       // Spawners do not move once they have spawned, to guard their redd.
       // The non-moving spawners still do grow and die, so they need all the
       // variables set in moving to a cell
       //

       [self moveToBestDest: myCell];

       //fprintf(stdout, "Trout >>>> move >>>> depthLengthRatioForCell = %f\n",depthLengthRatioForCell);
     } // if spawned this seasons

     else
     {
       //
       // Spawners who have not yet spawned move, but to minimize risk and cannot
       // move out of their reach. Methods to calculate drift and search intake
       // return zero if "isSpawner" is YES.
       //
       [self moveInReachToMaximizeSurvival];
     } // else - spawner who did not spawn yet
   }   // if isSpawner

   else  // isSpawner != YES
   {

     if(spawnedThisSeason == NO)
     {
         [self moveToMaximizeExpectedMaturity];
     }

     else
     {
      fprintf(stderr, "ERROR: Trout >>>> Move >>>> isSpawner = NO and spawnedThisSeason != NO\n");
      fflush(0);
      exit(1);
     }
    }  // else isSpawner != YES

   return self;

}

///////////////////////////////////////////////////////////////////////
//
// moveToMaximizeExpectedMaturity
//
///////////////////////////////////////////////////////////////////////
- moveToMaximizeExpectedMaturity 
{
  id <ListIndex> destNdx;
  FishCell *destCell=nil;
  FishCell *bestDest=nil;
  double bestExpectedMaturity=0.0;
  double expectedMaturityHere=0.0;
  double expectedMaturityAtDest=0.0;

  double outMigFuncValue = [juveOutMigLogistic evaluateFor: fishLength];

  //fprintf(stdout, "Trout >>>> moveToMaximizeExpectedMaturity >>>> BEGIN >>>> fish = %p\n", self);
  //fprintf(stdout, "Trout >>>> moveToMaximizeExpectedMaturity >>>> outMigFuncValue = %f\n", outMigFuncValue);
  //fflush(0);
  //exit(0);

  if(myCell == nil) 
  {
    fprintf(stderr, "WARNING: Trout >>>> moveToMaximizeExpectedMaturity >>>> Fish 0x%p has no Cell context.\n", self);
    fflush(0);
    return self;
  }

  //
  // Calculate the variables that depend only on the reach that a fish is in.
  //  (can't do this because cells may be in multiple reaches, with different 
  //  temperature and turbidity. Moved to expectedMaturityAt:
  // temporaryTemperature = [myCell getTemperature];
  // standardResp    = [self calcStandardRespirationAt: myCell];
  // cMax            = [self calcCmax: temporaryTemperature];
  // detectDistance  = [self calcDetectDistanceAt: myCell]; 

  //
  // calculate our expected maturity here
  //
  expectedMaturityHere = [self expectedMaturityAt: myCell];
 
  if(destCellList == nil)
  {
      fprintf(stderr, "ERROR: Trout >>>> moveToMaximizeExpectedMaturity >>>> destCellList is nil\n");
      fflush(0);
      exit(1);
  }

  //
  // destCellList must be empty
  // before it is populated.
  //
  [destCellList removeAll];
  
  //
  // Now, let the habitat space populate
  // the destCellList with myCells adjacent cells
  // and any other cells that are within
  // maxMoveDistance.
  //
  //fprintf(stdout, "Trout >>>> moveToMaximizeExpectedMaturity >>>> maxMoveDistance = %f\n", maxMoveDistance);
   //fflush(0);
  //xprint(myCell);


  [myCell getNeighborsWithin: maxMoveDistance
                    withList: destCellList];

  destNdx = [destCellList listBegin: scratchZone];
  while (([destNdx getLoc] != End) && ((destCell = [destNdx next]) != nil))
  {
      //
      // SHUNT FOR DEPTH ... it's assumed fish won't jump onto shore
      //
      if([destCell getPolyCellDepth] <= 0.0)
      {
         continue;
      }

      expectedMaturityAtDest = [self expectedMaturityAt: destCell];

      if (expectedMaturityAtDest >= bestExpectedMaturity) 
      {
	  bestExpectedMaturity = expectedMaturityAtDest;
	  bestDest = destCell;
      }

   }  //while destNdx

   if(expectedMaturityHere >= bestExpectedMaturity) 
   {
      //
      // Stay here 
      //
      bestDest = myCell;
      bestExpectedMaturity = expectedMaturityHere;
   }

   if(bestDest == nil) 
   { 
      fprintf(stderr, "ERROR: Trout >>>> moveToMaximizeExpectedMaturity >>>> bestDest is nil\n");
      fflush(0);
      exit(1);
   }

   // 
   //  Now, move -- or move out if outmigration is best
   //

   if(bestExpectedMaturity > outMigFuncValue)
   {
       [self moveToBestDest: bestDest];
   }
   else
   {
       //
       // Find a cell in the downstreamLinksToUS 
       //
       
       //fprintf(stdout, "Trout >>>> moveToMaximizeExpectedMaturity >>>> moving to downstream reach >>>> BEGIN\n");
       //fflush(0);

       id <List> habDownstreamLinksToUS =  [reach getHabDownstreamLinksToUS];
       if([habDownstreamLinksToUS getCount] > 0)
       {
           id aReach = nil;
           id <ListIndex> reachNdx = [habDownstreamLinksToUS listBegin: scratchZone];
           id <List> oReachPotentialCells = [List create: scratchZone];
           int numOKCells = 0;
           while(([reachNdx getLoc] != End) && ((aReach = [reachNdx next]) != nil))
           {
   // Starting in V. 1.5, select among all DS cells that are not dry and have
   // velocity less than fish max swim speed.

                  id <List> cellList = [aReach getPolyCellList]; 
 
                  if([cellList getCount] > 0)
                  { 
                      id <ListIndex> clNdx = [cellList listBegin: scratchZone];
                      FishCell* fishCell = nil;
                 
                      while(([clNdx getLoc] != End) && ((fishCell = [clNdx next]) != nil))
                      {
    // Starting in V. 1.5, fish move down only into non-dry cells with vel < maxSwimSpeed
    // Note that maxSwimSpeed is not updated for different temperature in new reach
                          if([fishCell getPolyCellDepth] > 0.0 && [fishCell getPolyCellVelocity] < maxSwimSpeedForCell)
                          {
                              numOKCells++;
                              [oReachPotentialCells addLast: fishCell];
                          }
                       }
                       [clNdx drop];
                       clNdx = nil;
                  }
            }
            [reachNdx drop];

            if(numOKCells == 0)
            {
                 [self moveToBestDest: bestDest];
                  fprintf(stderr, "WARNING: Trout >>>> moveToMaximizeExpectedMaturity >>>>  habDownstreamLinksToUS none have good depth & vel >>>> juvenile staying in reach %s\n", [reach getReachName]);
                  fflush(0);
            }
            else if(numOKCells == 1)
            {
                 bestDest = [oReachPotentialCells getFirst];
            }
            else
            {
                   //
                   // randomly select one the cells meeting criteria
                   //
                   unsigned oReachCellChoice = [oReachCellChoiceDist getUnsignedWithMin: 0
                                                                                withMax: (unsigned) (numOKCells - 1)]; 
    

                   bestDest = [oReachPotentialCells atOffset: oReachCellChoice];

            }
               // 
               // Now move to the downstream reach and repeat the move
               //
                  [self moveToBestDest: bestDest];
              //    [self moveToMaximizeExpectedMaturity];
   // Starting in V. 1.5, use method that allows only move one reach/day
                  [self moveToMaximizeEMInReach];
        
            [oReachPotentialCells removeAll];
            [oReachPotentialCells drop];
            oReachPotentialCells = nil;

//         fprintf(stdout, "Trout >>>> moveToMaximizeExpectedMaturity >>>> moving to downstream reach >>>> reach = %s\n", [reach getReachName]);
//         fprintf(stdout, "Trout >>>> moveToMaximizeExpectedMaturity >>>> moving to downstream [[myCell getReach] getReachName] %s\n", [[myCell getReach] getReachName]);
//         fprintf(stdout, "Trout >>>> moveToMaximizeExpectedMaturity >>>> moving to downstream [[bestDest getReach] getReachName] %s\n", [[bestDest getReach] getReachName]);
//         fprintf(stdout, "Trout >>>> moveToMaximizeExpectedMaturity >>>> moving to downstream reach >>>> END\n");
//         fflush(0);

         }

         else   // No downstream reach to move into, so migrate out
         {
               //
               // remove self from model
               // bestDest is needed in outmigrateFrom
               // so we can write output on movement from there.
               //
               [self outmigrateFrom: bestDest];
               //[bestDest removeFish: self]; 
         }

   } // Migration downstream / out


   //
   // RESOURCE CLEANUP
   // 
   if(destNdx != nil) 
   {
     [destNdx drop];
   }

   #ifdef DEBUG_TROUT_FISHPARAMS
     #ifdef DEBUG_MOVE
   
       fprintf(stderr,"\n");
       fprintf(stderr,"<<<<<METHOD: moveToMaximizeExpectedMaturity speciesNdx = %d >>>>>\n", speciesNdx);
       xprint(self);
       fprintf(stderr,"fishEMForUnknownCells = %f\n", fishParams->fishEMForUnknownCells);
       fprintf(stderr,"\n"); 
    
     #endif
   #endif

  //fprintf(stderr, "Trout >>>> moveToMaximizeExpectedMaturity >>>> END >>>> expectedMaturityAtDest = %f\n", expectedMaturityAtDest);
  //fprintf(stderr, "Trout >>>> moveToMaximizeExpectedMaturity >>>> END >>>> fish = %p\n", self);
  //fflush(0);

  return self;

} // moveToMaximizeExpectedMaturity 


///////////////////////////////////////////////////////////////////////
//
// moveToMaximizeEMInReach         SFR 3/28/2013
// Same as moveToMaximizeExpectedMaturity except
// does not include outmigration
///////////////////////////////////////////////////////////////////////
- moveToMaximizeEMInReach 
{
  id <ListIndex> destNdx;
  FishCell *destCell=nil;
  FishCell *bestDest=nil;
  double bestExpectedMaturity=0.0;
  double expectedMaturityHere=0.0;
  double expectedMaturityAtDest=0.0;

  // double outMigFuncValue = [juveOutMigLogistic evaluateFor: fishLength];

  //fprintf(stdout, "Trout >>>> moveToMaximizeExpectedMaturity >>>> BEGIN >>>> fish = %p\n", self);
  //fprintf(stdout, "Trout >>>> moveToMaximizeExpectedMaturity >>>> outMigFuncValue = %f\n", outMigFuncValue);
  //fflush(0);
  //exit(0);

  if(myCell == nil) 
  {
    fprintf(stderr, "WARNING: Trout >>>> moveToMaximizeExpectedMaturity >>>> Fish 0x%p has no Cell context.\n", self);
    fflush(0);
    return self;
  }

  //
  // The following vars. are now set in expectedMaturityAt:
  
  // temporaryTemperature = [myCell getTemperature];
  // temporaryTurbidity =  [myCell getTurbidity];
  // standardResp    = [self calcStandardRespirationAt: myCell];
  // cMax            = [self calcCmax: temporaryTemperature];
  // detectDistance  = [self calcDetectDistanceAt: myCell]; 

  //
  // calculate our expected maturity here
  //
  expectedMaturityHere = [self expectedMaturityAt: myCell];
 
  if(destCellList == nil)
  {
      fprintf(stderr, "ERROR: Trout >>>> moveToMaximizeExpectedMaturity >>>> destCellList is nil\n");
      fflush(0);
      exit(1);
  }

  //
  // destCellList must be empty
  // before it is populated.
  //
  [destCellList removeAll];
  
  //
  // Now, let the habitat space populate
  // the destCellList with myCells adjacent cells
  // and any other cells that are within
  // maxMoveDistance.
  //
  //fprintf(stdout, "Trout >>>> moveToMaximizeExpectedMaturity >>>> maxMoveDistance = %f\n", maxMoveDistance);
   //fflush(0);
  //xprint(myCell);


  [myCell getNeighborsWithin: maxMoveDistance
                    withList: destCellList];

  destNdx = [destCellList listBegin: scratchZone];
  while (([destNdx getLoc] != End) && ((destCell = [destNdx next]) != nil))
  {
      //
      // SHUNT FOR DEPTH ... it's assumed fish won't jump onto shore
      //
      if([destCell getPolyCellDepth] <= 0.0)
      {
         continue;
      }

      expectedMaturityAtDest = [self expectedMaturityAt: destCell];

      if (expectedMaturityAtDest >= bestExpectedMaturity) 
      {
	  bestExpectedMaturity = expectedMaturityAtDest;
	  bestDest = destCell;
      }

   }  //while destNdx

   if(expectedMaturityHere >= bestExpectedMaturity) 
   {
      //
      // Stay here 
      //
      bestDest = myCell;
      bestExpectedMaturity = expectedMaturityHere;
   }

   if(bestDest == nil) 
   { 
      fprintf(stderr, "ERROR: Trout >>>> moveToMaximizeExpectedMaturity >>>> bestDest is nil\n");
      fflush(0);
      exit(1);
   }

   // 
   //  Now, move 
   //

   [self moveToBestDest: bestDest];

	/*  Outmigration stuff deleted here */

   //
   // RESOURCE CLEANUP
   // 
   if(destNdx != nil) 
   {
     [destNdx drop];
   }

   #ifdef DEBUG_TROUT_FISHPARAMS
     #ifdef DEBUG_MOVE
   
       fprintf(stderr,"\n");
       fprintf(stderr,"<<<<<METHOD: moveToMaximizeExpectedMaturity speciesNdx = %d >>>>>\n", speciesNdx);
       xprint(self);
       fprintf(stderr,"fishEMForUnknownCells = %f\n", fishParams->fishEMForUnknownCells);
       fprintf(stderr,"\n"); 
    
     #endif
   #endif

  //fprintf(stderr, "Trout >>>> moveToMaximizeExpectedMaturity >>>> END >>>> expectedMaturityAtDest = %f\n", expectedMaturityAtDest);
  //fprintf(stderr, "Trout >>>> moveToMaximizeExpectedMaturity >>>> END >>>> fish = %p\n", self);
  //fflush(0);

  return self;

} // moveToMaximizeEMInReach 


///////////////////////////////////////////////////////////////////////
//
// moveInReachToMaximizeSurvival 
//
// Used by spawners who have not yet spawned.
// They find cells with good EM; food intake is zero; cannot move out of reach
//
///////////////////////////////////////////////////////////////////////
- moveInReachToMaximizeSurvival 
{
  id <ListIndex> destNdx;
  FishCell *destCell=nil;
  FishCell *bestDest=nil;
  double bestExpectedMaturity=0.0;
  double expectedMaturityHere=0.0;
  double expectedMaturityAtDest=0.0;

  double temporaryTemperature;

  //fprintf(stdout, "Trout >>>> moveInReachToMaximizeSurvival >>>> BEGIN >>>> fish = %p\n", self);
  //fprintf(stdout, "Trout >>>> moveInReachToMaximizeSurvival >>>> outMigFuncValue = %f\n", outMigFuncValue);
  //fflush(0);
  //exit(0);

  if(myCell == nil) 
  {
    fprintf(stderr, "WARNING: Trout >>>> moveInReachToMaximizeSurvival >>>> Fish %p has no Cell context.\n", self);
    fflush(0);
    return self;
  }

  //
  // Calculate the variables that depend only on the reach that a fish is in.
  //
  temporaryTemperature = [myCell getTemperature];
  standardResp    = [self calcStandardRespirationAt: myCell];
  cMax            = [self calcCmax: temporaryTemperature];
  detectDistance  = [self calcDetectDistanceAt: myCell]; 

  //
  // calculate our expected maturity here
  //
  expectedMaturityHere = [self expectedMaturityAt: myCell];
 
  if(destCellList == nil)
  {
      fprintf(stderr, "ERROR: Trout >>>> moveInReachToMaximizeSurvival >>>> destCellList is nil\n");
      fflush(0);
      exit(1);
  }

  //
  // destCellList must be empty
  // before it is populated.
  //
  [destCellList removeAll];
  
  //
  // Now, let the habitat space populate
  // the destCellList with myCells adjacent cells
  // and any other cells that are within
  // maxMoveDistance.
  //
  //fprintf(stdout, "Trout >>>> moveInReachToMaximizeSurvival >>>> maxMoveDistance = %f\n", maxMoveDistance);
   //fflush(0);
  //xprint(myCell);

  // Potential destinations are only in the same reach

  [myCell getNeighborsInReachWithin: maxMoveDistance
                    withList: destCellList];

  destNdx = [destCellList listBegin: scratchZone];
  while (([destNdx getLoc] != End) && ((destCell = [destNdx next]) != nil))
  {
      //
      // SHUNT FOR DEPTH ... it's assumed fish won't jump onto shore
      //
      if([destCell getPolyCellDepth] <= 0.0)
      {
         continue;
      }

      expectedMaturityAtDest = [self expectedMaturityAt: destCell];

      if (expectedMaturityAtDest >= bestExpectedMaturity) 
      {
	  bestExpectedMaturity = expectedMaturityAtDest;
	  bestDest = destCell;
      }

   }  //while destNdx

   if(expectedMaturityHere >= bestExpectedMaturity) 
   {
      //
      // Stay here 
      //
      bestDest = myCell;
      bestExpectedMaturity = expectedMaturityHere;
   }

   if(bestDest == nil) 
   { 
      fprintf(stderr, "ERROR: Trout >>>> moveInReachToMaximizeSurvival >>>> bestDest is nil\n");
      fflush(0);
      exit(1);
   }

   // 
   //  Now, move -- No outmigration allowed
   //

   [self moveToBestDest: bestDest];


   //
   // RESOURCE CLEANUP
   // 
   if(destNdx != nil) 
   {
     [destNdx drop];
   }

   #ifdef DEBUG_TROUT_FISHPARAMS
     #ifdef DEBUG_MOVE
   
       fprintf(stderr,"\n");
       fprintf(stderr,"<<<<<METHOD: moveInReachToMaximizeSurvival speciesNdx = %d >>>>>\n", speciesNdx);
       xprint(self);
       fprintf(stderr,"fishEMForUnknownCells = %f\n", fishParams->fishEMForUnknownCells);
       fprintf(stderr,"\n"); 
    
     #endif
   #endif

  //fprintf(stderr, "Trout >>>> moveInReachToMaximizeSurvival >>>> END >>>> expectedMaturityAtDest = %f\n", expectedMaturityAtDest);
  //fprintf(stderr, "Trout >>>> moveInReachToMaximizeSurvival >>>> END >>>> fish = %p\n", self);
  //fflush(0);

  return self;

} // moveInReachToMaximizeSurvival 


///////////////////////////////////////
//
// movetToBestDest
//
///////////////////////////////////////
- moveToBestDest: bestDest 
{

   //fprintf(stdout, "Trout >>>> moveToBestDest >>>> BEGIN\n");
   //fflush(0);

/*
	The following instance variables are set mainly for testing movement calculations
	by probing the fish. HOWEVER (1) netEnergyForBestCell must be set here because it is used in
	-grow, (2) the feeding strategy, hourly food consumption rates, and velocity shelter use 
	must be set here so the destination cell's food and velocity shelter availability can
	be updated accurately when the fish moves (cell method "eatHere"). 

	These variables show the state of the fish when it made its movement decision
	and will not necessarily be equal to the results of the same methods executed at the
	end of a model time step because there will be different numbers of fish in cells etc.
	after -move is completed for all fish.

	These variables must be set BEFORE the fish actually moves to the new cell, so the
	fish is not included in the destination cell's list of contained fish (so the fish 
	does not compete with itself for food).

	It seems inefficient to re-calculate these variables after finding the best destination
	cell, but it is much cleaner and safer this way! 
*/

  feedTimeForCell = [self calcFeedTimeAt: bestDest];
  standardResp = [self calcStandardRespirationAt: bestDest];
  maxSwimSpeedForCell = [self calcMaxSwimSpeedAt: bestDest];
  detectDistance = [self calcDetectDistanceAt: bestDest];
  captureSuccess = [self calcCaptureSuccess: bestDest];
  captureArea = [self calcCaptureArea: bestDest];
  cMax = [self calcCmax: [bestDest getTemperature] ];
  potentialHourlyDriftIntake = [self calcDriftIntake: bestDest];
  potentialHourlySearchIntake = [self calcSearchIntake: bestDest];
  dailyDriftFoodIntake = [self calcDailyDriftFoodIntake: bestDest];
  dailyDriftNetEnergy = [self calcDailyDriftNetEnergy: bestDest];
  dailySearchFoodIntake = [self calcDailySearchFoodIntake: bestDest];
  dailySearchNetEnergy = [self calcDailySearchNetEnergy: bestDest];
  netEnergyForBestCell = [self calcNetEnergyForCell: bestDest];
  expectedMaturity = [self expectedMaturityAt: bestDest];

  nonStarvSurvival = [bestDest getTotalKnownNonStarvSurvivalProbFor: self];

  // Set fishFeedingStrategy considering that it is set for spawners already in - spawn
  if ((fishFeedingStrategy != GUARDING) && (fishFeedingStrategy != SPENTMALE) && (fishFeedingStrategy != SPAWNER))
   {
     fishFeedingStrategy = cellFeedingStrategy; //cellFeedingStrategy is set in -calcNetEnergyForCell
   }
  fishSwimSpeed = cellSwimSpeedForCell;       // cellSwimSpeedForCell is set in -calcNetEnergyForCell

  activeResp = [self calcActivityRespirationAt: bestDest 
                                 withSwimSpeed: [self getSwimSpeedAt: bestDest forStrategy: fishFeedingStrategy] ];

   switch(fishFeedingStrategy) 
   {
     case DRIFT: if(feedTimeForCell != 0.0) 
                 {
                     hourlyDriftConRate = dailyDriftFoodIntake/feedTimeForCell;
                 }
                 else 
                 {
                     hourlyDriftConRate = 0.0;
                 }
                 hourlySearchConRate = 0.0;
                 feedStrategy = "DRIFT";
         
                 velocityShelter = [bestDest getIsShelterAvailable];

                 if(velocityShelter == YES) 
                 {
                     inShelter = "YES";   //Probe Variable
                 }
                 else 
                 {
                    inShelter = "NO";
                 }
                 break;
     
     case SEARCH: if(feedTimeForCell != 0.0) 
                  {
                     hourlySearchConRate = dailySearchFoodIntake/feedTimeForCell;
                  }
                  else 
                  {
                     hourlySearchConRate = 0.0;
                  } 
                  hourlyDriftConRate  = 0.0;
                  velocityShelter = NO; 
                  inShelter = "NO"; //Probe Variable
                  feedStrategy = "SEARCH";  //Probe Variable
                  break;

     case SPAWNER:  
                  hourlySearchConRate = 0.0;
                  hourlyDriftConRate  = 0.0;
                  velocityShelter = NO; 
                  inShelter = "NO"; //Probe Variable
                  feedStrategy = "SPAWNER";  //Probe Variable
                  break;

     case SPENTMALE:  
                  hourlySearchConRate = 0.0;
                  hourlyDriftConRate  = 0.0;
                  velocityShelter = NO; 
                  inShelter = "NO"; //Probe Variable
                  feedStrategy = "SPENTMALE";  //Probe Variable
                  break;

     case GUARDING:  
                  hourlySearchConRate = 0.0;
                  hourlyDriftConRate  = 0.0;
                  velocityShelter = NO; 
                  inShelter = "NO"; //Probe Variable
                  feedStrategy = "GUARDING";  //Probe Variable
                  break;

     default: fprintf(stderr, "ERROR: Trout >>>> moveToBestDest >>>> Fish has no feeding strategy\n");
              fflush(0);
              exit(1);
              break;

   }

   // Update previous location
   prevCell = myCell;
   prevReach = reach;

   //PRINT THE MOVE REPORT
   #ifdef MOVE_REPORT_ON
   [self moveReport: bestDest];
   #endif



   //
   // Now, we move...
   // eatHere indirectly sets the fish's cell and the fish's reach
   //
   [bestDest eatHere: self]; 


   //[self checkVars];

   //fprintf(stdout, "Trout >>>> moveToBestDest >>>> END\n");
   //fflush(0);

   return self;
}

- checkVars
{
  fprintf(stdout, "Trout >>>> checkVars >>>> BEGIN\n");
  fflush(0);

  fprintf(stdout, "Trout >>>> checkVars >>>> feedTimeForCell = %f\n", feedTimeForCell);
  fprintf(stdout, "Trout >>>> checkVars >>>> standardResp = %f\n", standardResp);
  fprintf(stdout, "Trout >>>> checkVars >>>> maxSwimSpeedForCell = %f\n", maxSwimSpeedForCell);
  fprintf(stdout, "Trout >>>> checkVars >>>> detectDistance = %f\n", detectDistance);
  fprintf(stdout, "Trout >>>> checkVars >>>> captureSuccess = %f\n", captureSuccess);
  fprintf(stdout, "Trout >>>> checkVars >>>> cMax = %f\n", cMax);
  fprintf(stdout, "Trout >>>> checkVars >>>> potentialHourlyDriftIntake = %f\n", potentialHourlyDriftIntake);
  fprintf(stdout, "Trout >>>> checkVars >>>> potentialHourlySearchIntake = %f\n", potentialHourlySearchIntake);
  fprintf(stdout, "Trout >>>> checkVars >>>> dailyDriftFoodIntake = %f\n", dailyDriftFoodIntake);
  fprintf(stdout, "Trout >>>> checkVars >>>> dailyDriftNetEnergy = %f\n", dailyDriftNetEnergy);
  fprintf(stdout, "Trout >>>> checkVars >>>> dailySearchFoodIntake = %f\n", dailySearchFoodIntake);
  fprintf(stdout, "Trout >>>> checkVars >>>> dailySearchNetEnergy = %f\n", dailySearchNetEnergy);
  fprintf(stdout, "Trout >>>> checkVars >>>> netEnergyForBestCell = %f\n", netEnergyForBestCell);
  fprintf(stdout, "Trout >>>> checkVars >>>> expectedMaturity = %f\n", expectedMaturity);
  fprintf(stdout, "Trout >>>> checkVars >>>> nonStarvSurvival = %f\n", nonStarvSurvival);
  fprintf(stdout, "Trout >>>> checkVars >>>> fishFeedingStrategy = %d\n", (int) fishFeedingStrategy);
  fprintf(stdout, "Trout >>>> checkVars >>>> fishSwimSpeed = %f\n", fishSwimSpeed);
  fprintf(stdout, "Trout >>>> checkVars >>>> activeResp = %f\n", activeResp);
  fprintf(stdout, "Trout >>>> checkVars >>>> utmCellNumber = %d\n", [myCell getPolyCellNumber]);
  fprintf(stdout, "Trout >>>> checkVars >>>> fishLength = %f\n", fishLength);
  fprintf(stdout, "Trout >>>> checkVars >>>> fishWeight = %f\n", fishWeight);
  fprintf(stdout, "Trout >>>> checkVars >>>> fishCondition = %f\n", fishCondition);

  fprintf(stdout, "Trout >>>> checkVars >>>> END\n");
  fflush(0);

  return self;
}




///////////////////////////////////////////////////////////////////////////
//
// End of Move
//
//////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////
//
// expectedMaturityAt
//
////////////////////////////////////////////////
- (double) expectedMaturityAt: (FishCell *) aCell 
{ 
  double weightAtTForCell;
  double lengthAtTForCell; 
  double conditionAtTForCell; 
  double fracMatureAtTForCell; 
  double T;                    //fishFitnessHorizon
  double Kt, KT, a, b;
  double starvSurvival;
  double expectedMaturityAtACell = 0.0;
  double totalNonStarvSurv = 0.0;

  T = fishParams->fishFitnessHorizon;

  if(aCell == nil)
  {
     fprintf(stderr, "ERROR: Trout >>>> expectedMaturityAt >>>> aCell = nil\n");
     fflush(0);
     exit(1);
  }

  netEnergyForCell = [self calcNetEnergyForCell: aCell];
  weightAtTForCell = [self getWeightWithIntake: (T * netEnergyForCell) ]; 
  lengthAtTForCell = [self getLengthForNewWeight: weightAtTForCell];
  conditionAtTForCell = [self getConditionForWeight: weightAtTForCell andLength: lengthAtTForCell];

  fracMatureAtTForCell = [self getFracMatureForLength: lengthAtTForCell];

  //
  // The following variables: maxSwimSpeedForCell, feedTimeForCell, 
  // depthLengthRatioForCell are set here because they depend on
  // both cell and fish. They are then used by the
  // survivalManager via fish get methods.
  //
  maxSwimSpeedForCell = [self calcMaxSwimSpeedAt: aCell];
  feedTimeForCell = [self calcFeedTimeAt: aCell];
  depthLengthRatioForCell = [self calcDepthLengthRatioAt: aCell];
  
  // and these trout instance variables depend on reach and fish
  standardResp = [self calcStandardRespirationAt: aCell];
  cMax = [self calcCmax: [aCell getTemperature]];
  detectDistance = [self calcDetectDistanceAt: aCell]; 


  //
  // Now update the survival manager...
  //

  if(aCell == nil)
  {
      fprintf(stderr, "Trout >>>> expectedMaturityAt >>>> aCell is nil\n");
      fprintf(stderr, "Trout >>>> expectedMaturityAt >>>> isSpawner = %d\n", (int) isSpawner);
      fflush(0);
      exit(1);
  }

  [aCell updateFishSurvivalProbFor: self];

  if(fabs(fishCondition - conditionAtTForCell) < 0.001) 
  {
      starvSurvival = [aCell getStarvSurvivalFor: self];
  }
  else 
  {
     a = starvPa; 
     b = starvPb; 
     Kt = fishCondition;  //current fish condition
     KT = conditionAtTForCell;
     starvSurvival =  (1/a)*(log((1+exp(a*KT+b))/(1+exp(a*Kt+b))))/(KT-Kt); 
  }  

  if(isnan(starvSurvival) || isinf(starvSurvival))
  {
     fprintf(stderr, "ERROR: Trout >>>> expectedMaturityAt >>>> starvSurvival = %f\n", starvSurvival);
     fflush(0);
     exit(1);
  }

  totalNonStarvSurv = [aCell getTotalKnownNonStarvSurvivalProbFor: self];

  if(isnan(totalNonStarvSurv) || isinf(totalNonStarvSurv))
  {
     fprintf(stderr, "ERROR: Trout >>>> expectedMaturityAt >>>> totalNonStarvSurv = %f\n", totalNonStarvSurv);
     fflush(0);
  }

  expectedMaturityAtACell = fracMatureAtTForCell * pow((starvSurvival * totalNonStarvSurv), T);
  if(isnan(expectedMaturityAtACell) || isinf(expectedMaturityAtACell))
  {
     fprintf(stderr, "ERROR: Trout >>>> expectedMaturityAt >>>> expectedMaturityAtACell = %f\n", expectedMaturityAtACell);
     fflush(0);
     exit(1);
  }

  if(expectedMaturityAtACell < 0.0)
  {
     fprintf(stderr, "ERROR: Trout >>>> expectedMaturityAt >>>> expectedMaturityAtACell = %f is less than ZERO\n", expectedMaturityAtACell);
     fflush(0);
     exit(1);
  }

  return expectedMaturityAtACell;
}

//////////////////////////////////////////////////
//
// calcStarvPaAndPb
//
/////////////////////////////////////////////////
- calcStarvPaAndPb
{

  double x1 = fishParams->mortFishConditionK1;
  double x2 = fishParams->mortFishConditionK9;

  double y1 = 0.1;
  double y2 = 0.9;

  double u, v;

  if(x1 == x2)
  {
      fprintf(stderr, "Trout >>>> calcStarvPaAndPb... >>>> the independent variables mortFishConditionK1 and mortFishConditionK9 are equal\n");
      fflush(0);
      exit(1);
  }
  if((y1 >= 1.0) || (y1 <= 0.0) || (y2 <= 0.0) || (y2 >= 1.0) || (y1 == y2))
  {
      fprintf(stderr, "ERROR: Trout >>>> calcStarvPaAndPb... >>>> the dependent variables UPPER_LOGISTIC_DEPENDENT or LOWER_LOGISTIC_DEPENDENT incorrect\n");
      fflush(0);
      exit(1);
  }


  u = log(y1/(1.0-y1));
  v = log(y2/(1.0-y2));

  starvPa = (u - v)/(x1-x2);
  starvPb = u - starvPa*x1;

  //fprintf(stdout, "Trout >>>> calcStarvPaAndPb >>>> starvPa = %f starvPb = %f\n", starvPa, starvPb);
  //fflush(0);

  return self;

}


//////////////////////////////////////////////////////////////////
//
// grow  
//
// Grow is the third action taken by fish in their daily routine 
//
/////////////////////////////////////////////////////////////////
- grow 
{
    //
    // if we are already dead -- or outmigrated --
    // just return. Important to keep outmigrated fish from growing into
    // the next (wrong) size class.

    if(causeOfDeath != nil) return self;

  prevWeight = fishWeight;
  prevLength = fishLength;
  prevCondition = fishCondition;

  fishWeight = [self getWeightWithIntake: netEnergyForBestCell];
  fishLength = [self getLengthForNewWeight: fishWeight];
  fishCondition = [self getConditionForWeight: fishWeight andLength: fishLength];
  fishFracMature = [self getFracMatureForLength: fishLength];
  superindividualWeight = fishWeight * nRep; // Superindividual weight
  return self;
}


/////////////////////////////////////////////////////////////////////////////////////////
//
// die
// Comment: Die is the fourth action taken by fish in their daily routine 
//
////////////////////////////////////////////////////////////////////////////////////////
- die 
{

    if(imImmortal == YES)
    {
        return self;
    }

    //
    // if we are already dead -- or outmigrated --
    // just return
    //
    if(causeOfDeath != nil) return self;

    //
    // Survival Manager code
    //
    {
       id <List> listOfSurvProbs;
       id <ListIndex> lstNdx;
       id <SurvProb> aProb;
       
       if(myCell == nil)
       {
           fprintf(stderr, "Trout >>>> die >>>> myCell is nil\n");
           fprintf(stderr, "Trout >>>> die >>>> isSpawner = %d\n", (int) isSpawner);
           fflush(0);
           exit(1);
       }

       [myCell updateFishSurvivalProbFor: self];
       
       listOfSurvProbs = [myCell getListOfSurvProbsFor: self]; 

       lstNdx = [listOfSurvProbs listBegin: scratchZone];
     
       while(([lstNdx getLoc] != End) && ((aProb = [lstNdx next]) != nil))
       {
            if([dieDist getDoubleSample] > [aProb getSurvivalProb]) 
            {
                 char* deathName = (char *) [aProb getName];
                 size_t strLen = strlen(deathName) + 1;
                 causeOfDeath = [aProb getProbSymbol];
                 deathCausedBy = (char *) [troutZone alloc: strLen*sizeof(char)];
                 strncpy(deathCausedBy, deathName, strLen);
                 deadOrAlive = "DEAD";
                 timeOfDeath = [self getCurrentTimeT]; 
                 [model addToKilledList: self ];
                 [myCell removeFish: self];

                 // Tell a spawner's redd that it's not guarded any more
                 if(myRedd != nil)
                   {
                     [myRedd setIAmGuarded: NO];
                   }
                 
                 //
                 // I don't think we want to kill a fish
                 // more than once so ...
                 //
                 break;
            }
      }
      [lstNdx drop];
  }

  return self;
}

////////////////////////////////////////////////////////
//
// killFish AKA
// deathByDemonicIntrusion
//
////////////////////////////////////////////////////////
- killFish
{
    size_t strLen = strlen("DemonicIntrusion") + 1;
    causeOfDeath = [model getFishMortalitySymbolWithName: "DemonicIntrusion"];
    deathCausedBy = (char *) [troutZone alloc: strLen*sizeof(char)];
    strncpy(deathCausedBy, "DemonicIntrusion", strLen);
    deadOrAlive = "DEAD";
    timeOfDeath = [self getCurrentTimeT];
    [model addToKilledList: self ];
    [myCell removeFish: self];

    return self;
}



///////////////////////////////////////////////
//
// getCauseOfDeath
//
//////////////////////////////////////////
- (id <Symbol>) getCauseOfDeath 
{
   return causeOfDeath;
}

//////////////////////////////////////////////////
//
// getTimeOfDeath
//
/////////////////////////////////////////////////
- (time_t) getTimeOfDeath 
{
  return timeOfDeath;
}


///////////////////////////////////////////////////////////////////////////////
//
// compare
// Needed by QSort in TroutModelSwarm method: buildTotalTroutPopList
//
///////////////////////////////////////////////////////////////////////////////
- (int) compare: (Trout *) aFish 
{
  double otherFishLength = [aFish getFishLength];

  if(fishLength > otherFishLength)
  {
    return 1;
  }
  else if (fishLength == otherFishLength)
  {
    return 0;
  }
  else
  {
    return -1;
  }
}


////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
//
//FISH FEEDING AND ENERGETICS
//
///////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////

// ACTIVITY BUDGET

/////////////////////////////////////////
//
// calcFeedTimeAt
//
/////////////////////////////////////////
- (double) calcFeedTimeAt: (FishCell *) aCell 
{
   double aFeedTime;

   aFeedTime = [aCell getDayLength] + 2.0;

   //
   // Commented out 10/13/06 SKJ
   //
   //if([aCell getTemperature] < fishParams->fishMinFeedTemp)
   //{
      //aFeedTime = 0.0;
   //}

   return aFeedTime;
}



////////////////////////////////////////////////
//
//
// FOOD INTAKE: DRIFT FEEDING STRATEGY
//
//
////////////////////////////////////////////////

//////////////////////////////////////////////////////////////
//
// calcDetectDistanceAt
//
// We do this for each cell because a fish may be looking 
// at cell that is in a reach different than the one a fish
// is currently in
//
// Modified 12/24/04 SFR to make detectDist a linear
// function of fish length
// fishDetectDistParamA is the constant;
// fishDetectDistParamB is the slope
//
//////////////////////////////////////////////////////////////
- (double)  calcDetectDistanceAt: (FishCell *) aCell
{
   double habTurbidity;
   double turbidityFunction = 1.0;
   double aDetectDistance;
   double expFunction = -LARGEINT;
   double fishTurbidThreshold = fishParams->fishTurbidThreshold;

   if(aCell == nil)
   {
      fprintf(stderr, "ERROR: Trout >>>> calcDetectDistance >>>> aCell is nil\n");
      fflush(0);
      exit(1);
   }

   //
   // getTurbidity is a pass through to the habitatSpace 
   //
   habTurbidity = [aCell getTurbidity];

   //
   // The following if block modified 4/13/06 SKJ
   //
   if(habTurbidity > fishTurbidThreshold)
   {
      expFunction = exp(fishParams->fishTurbidExp * (habTurbidity - fishTurbidThreshold));
      
      turbidityFunction = (expFunction >= fishParams->fishTurbidMin) ? expFunction 
                                                                     : fishParams->fishTurbidMin;
   }

   aDetectDistance =   (fishParams->fishDetectDistParamA 
                     + (fishLength * fishParams->fishDetectDistParamB))
                     * turbidityFunction;
 
   return aDetectDistance;
}


///////////////////////////////////////////
//
// calcCaptureArea
//
//////////////////////////////////////////
- (double) calcCaptureArea: (FishCell *) aCell 
{
   double aCaptureArea;
   double depth;
   double minValue=0.0;
   //double aDetectDistance = [self calcDetectDistanceAt: aCell];

   depth = [aCell getPolyCellDepth];
   minValue = (detectDistance < depth) ? detectDistance : depth;
   aCaptureArea = 2.0*detectDistance*minValue;

   return aCaptureArea;
}


///////////////////////////////////////////////
//
// calcCaptureSuccess
//
//////////////////////////////////////////////
- (double) calcCaptureSuccess: (FishCell *) aCell
{
   double aCaptureSuccess;
   double velocity = 0.0;
   double aMaxSwimSpeed = [self calcMaxSwimSpeedAt: aCell];
   
   if(captureLogistic == nil)
   {
      fprintf(stderr, "ERROR: Trout >>>> calcCaptureSuccess >>>> captureLogistic is nil\n");
      fflush(0);
      exit(1);
   }

   if(aCell == nil)
   {
      fprintf(stderr, "ERROR: Trout >>>> calcCaptureSuccess >>>> aCell is nil\n");
      fflush(0);
      exit(1);
   }

   velocity = [aCell getPolyCellVelocity];

   aCaptureSuccess = [captureLogistic evaluateFor: (velocity/aMaxSwimSpeed)];

   return aCaptureSuccess;
}
 

/////////////////////////////////
//
// calcDriftIntake
// Comment: Intake = hourly rate 
//
/////////////////////////////////
- (double) calcDriftIntake: (FishCell *) aCell 
{
  double aDriftIntake;
  double aCaptureArea;
  double aCaptureSuccess;

  if (isSpawner == YES)
  {
     return 0.0;
  }

  else
 {
  aCaptureArea = [self calcCaptureArea: aCell];
  aCaptureSuccess = [self calcCaptureSuccess: aCell];


  aDriftIntake =   [aCell getHabDriftConc] 
                 * [aCell getPolyCellVelocity]
                 * aCaptureArea 
                 * aCaptureSuccess
                 * 3600.0;

  return aDriftIntake;
 }
}



///////////////////////////////////////////
//
//
//FOOD INTAKE: ACTIVE SEARCHING STRATEGY
//
//
///////////////////////////////////////////

////////////////////////////////////////////////
//
// calcMaxSwimSpeedAt
//
// This is done for each cell since fish may be
// considering cells that are different reaches.
//
////////////////////////////////////////////////
- (double) calcMaxSwimSpeedAt: (FishCell *) aCell 
{
  double fMSPA = fishParams->fishMaxSwimParamA;
  double fMSPB = fishParams->fishMaxSwimParamB;
  double fMSPC = fishParams->fishMaxSwimParamC;
  double fMSPD = fishParams->fishMaxSwimParamD;
  double fMSPE = fishParams->fishMaxSwimParamE;
  double T = [aCell getTemperature];
  double aMaxSwimSpeed;

  //fprintf(stdout, "Trout >>>> calcMaxSwimSpeedAt >>>> temperature = %f \n", T);
  //fflush(0);
 


  aMaxSwimSpeed =   (fMSPA*fishLength + fMSPB)
                 * (fMSPC*T*T + fMSPD*T + fMSPE);

  if(aMaxSwimSpeed <= 0.0)
  {
      fprintf(stderr, "ERROR: Trout >>>> calcMaxSwimSpeed >>>> aMaxSwimSpeed is less than or equal to 0\n");
      fflush(0); 
      exit(1); 
  }

  return aMaxSwimSpeed;
} 



///////////////////////////////////////////
//
//calcSearchIntake
//
///////////////////////////////////////////
- (double) calcSearchIntake: (FishCell *) aCell 
{
  double aSearchIntake;
  double fSA;
  double velocity=0.0;
  double habSearchProd=0.0;
  double aMaxSwimSpeed;
  
  if (isSpawner == YES)
  {
     return 0.0;
  }

  if ([aCell getPolyCellDepth] <= 0.0)
  {
     return 0.0;
  }

  else
 {
  aMaxSwimSpeed = [self calcMaxSwimSpeedAt: aCell];
  fSA = fishParams->fishSearchArea;

  velocity = [aCell getPolyCellVelocity];
  habSearchProd = [aCell getHabSearchProd];
 
  if(velocity > aMaxSwimSpeed) 
  {
     aSearchIntake = 0.0;
  }
  else 
  {
     aSearchIntake = habSearchProd * fSA * (aMaxSwimSpeed - velocity)/aMaxSwimSpeed;
  }

  return aSearchIntake;
 }
}



///////////////////////////////////////
//
//
//FOOD INTAKE: MAXIMUM CONSUMPTION
//
//
///////////////////////////////////////

////////////////////////////////////////////
//
//calcCmax
//
////////////////////////////////////////////
- (double) calcCmax: (double) aTemperature 
{
  double aCmax;
  double fCPA,fCPB;
  double cmaxTempFunction;

  fCPA = fishParams->fishCmaxParamA;
  fCPB = fishParams->fishCmaxParamB;

  cmaxTempFunction = [cmaxInterpolator getValueFor: aTemperature];

  aCmax = fCPA * pow(fishWeight,(1+fCPB)) * cmaxTempFunction;

   #ifdef DEBUG_TROUT_FISHPARAMS
     #ifdef DEBUG_FEEDING
   
       fprintf(stderr,"\n");
       fprintf(stderr,"<<<<<METHOD: calcCMax speciesNdx = %d >>>>>\n", speciesNdx);
       xprint(self);
       fprintf(stderr,"fishCmaxParamA = %f\n", fishParams->fishCmaxParamA);
       fprintf(stderr,"fishCmaxParamB = %f\n", fishParams->fishCmaxParamB);
       fprintf(stderr,"\n"); 
    
     #endif
   #endif

  if(aCmax < 0.0)
  {
      fprintf(stderr, "ERROR: Trout >>>> calcCmax >>>> Negative cMax calculated\n");
      fflush(0);
      exit(1);
  }


  return aCmax;
}

///////////////////////////////////////////////
//
// FOOD INTAKE: FOOD AVAILABILITY
//
///////////////////////////////////////////////


//
// RESPIRATION COSTS
//
///////////////////////////////////////////////////
//
// calcStandardRespirationAt
//
///////////////////////////////////////////////////
- (double) calcStandardRespirationAt: (FishCell *) aCell
{
  double temperature;
  double aStandardResp;

  if(aCell == nil)
  {
     fprintf(stderr, "ERROR: Trout >>>> calcStandardRespirationAt >>>> aCell is nil\n");
     fflush(0);
     exit(1);
  }

  temperature = [aCell getTemperature];

  aStandardResp =   fishParams->fishRespParamA
                  * pow(fishWeight, fishParams->fishRespParamB) 
                  * exp(fishParams->fishRespParamC * temperature);

  return aStandardResp;
}

  

//////////////////////////////////////////////////////////////////////////////////
//
//calcActivityRespiration
//
///////////////////////////////////////////////////////////////////////////////////
- (double) calcActivityRespirationAt: (FishCell *) aCell withSwimSpeed: (double) aSpeed 
{
  double aRespActivity;
  double aFeedTime;

  //fprintf(stdout, "Trout >>>> calcActivityRespirationAt >>>> BEGIN\n");
  //fflush(0); 

  aFeedTime = [self calcFeedTimeAt: aCell];  

  if(aSpeed > 0.0) 
  {
     aRespActivity = (aFeedTime/24) * (exp(fishParams->fishRespParamD*aSpeed) - 1.0) * standardResp;
  }
  else 
  {
     aRespActivity = 0.0; 
  }

  //fprintf(stdout, "Trout >>>> calcActivityRespirationAt >>>> aFeedTime = %f\n", aFeedTime);
  //fprintf(stdout, "Trout >>>> calcActivityRespirationAt >>>> aRespActivity = %f\n", aRespActivity);
  //fflush(0); 

  //fprintf(stdout, "Trout >>>> calcActivityRespirationAt >>>> END\n");
  //fflush(0); 

  return aRespActivity;

}



//////////////////////////////////////////////////////////////////////////////
//
// calcTotalRespirationAt
//
//////////////////////////////////////////////////////////////////////////////
- (double) calcTotalRespirationAt: (FishCell *) aCell withSwimSpeed: (double) aSpeed 
{
  return [self calcActivityRespirationAt: aCell withSwimSpeed: aSpeed] + standardResp;
}


///////////////////////////////////////////////////////////////
//
//
// FEEDING STRATEGY SELECTION, NET ENERGY BENEFITS, AND GROWTH
//
////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////
//
//calcDailyDriftFoodIntake
//
/////////////////////////////////////////////////////
- (double) calcDailyDriftFoodIntake: (FishCell *) aCell 
{
   double aDailyPotentialDriftFood;
   double aDailyDriftFoodIntake = 0.0;
   double aDailyAvailableFood;

   //fprintf(stdout, "Trout >>>> calcDailyDriftFoodIntake >>>> BEGIN\n");
   //fflush(0);


   aDailyPotentialDriftFood = [self calcDriftIntake: aCell] * [self calcFeedTimeAt: aCell];
   aDailyAvailableFood = [aCell getHourlyAvailDriftFood] * [self calcFeedTimeAt: aCell]; 
 

   //
   //aDailyDriftFoodIntake is the minimum of aDailyPotentialFood, aDailyAvailbleFood, and cMax
   //
   // Now adjusted for superindividuals
   //

   aDailyDriftFoodIntake = aDailyPotentialDriftFood;
 
   if(aDailyAvailableFood < (aDailyDriftFoodIntake * nRep))
   {
       aDailyDriftFoodIntake = (aDailyAvailableFood / nRep);
   }

   if(cMax < aDailyDriftFoodIntake)
   {
      aDailyDriftFoodIntake = cMax;
   }

   /*
   fprintf(stdout, "Trout >>>> calcDailyDriftFoodIntake >>>> aDailyPotentialDriftFood = %f\n", aDailyPotentialDriftFood);
   fprintf(stdout, "Trout >>>> calcDailyDriftFoodIntake >>>> aDailyAvailableFood = %f\n", aDailyPotentialDriftFood);
   fprintf(stdout, "Trout >>>> calcDailyDriftFoodIntake >>>> aDailyDriftFoodIntake = %f\n", aDailyDriftFoodIntake);
   fprintf(stdout, "Trout >>>> calcDailyDriftFoodIntake >>>> cMax = %f\n", cMax);
   fflush(0);
   */

   //fprintf(stdout, "Trout >>>> calcDailyDriftFoodIntake >>>> END\n");
   //fflush(0);

   return aDailyDriftFoodIntake; 
}


////////////////////////////////////////////////////
//
//calcDailyDriftNetEnergy
//
////////////////////////////////////////////////////
- (double) calcDailyDriftNetEnergy: (FishCell *) aCell 
{
  double aDailyDriftNetEnergy;   
 
  aDailyDriftNetEnergy = ( [self calcDailyDriftFoodIntake: aCell] * [aCell getHabPreyEnergyDensity] )
                         - [self calcTotalRespirationAt: aCell withSwimSpeed:
                           [self getSwimSpeedAt: aCell forStrategy: DRIFT] ];

  return aDailyDriftNetEnergy;
}

/////////////////////////////////////////
//
//getSwimSpeedAt
//
///////////////////////////////////////
- (double) getSwimSpeedAt: (FishCell *) aCell forStrategy: (int) aFeedStrategy 
{
 
  if(([aCell getIsShelterAvailable] == YES) && (aFeedStrategy == DRIFT)) 
  {
      return ([aCell getPolyCellVelocity] * [aCell getHabShelterSpeedFrac]); 
  }
  else 
  {
     return [aCell getPolyCellVelocity];
  }

}


/////////////////////////////
//
// getAmIInAShelter
// 
/////////////////////////////
- (BOOL) getAmIInAShelter 
{
   return velocityShelter;
}



/////////////////////////////////////////////////////
//
//calcDailySearchFoodIntake
//
/////////////////////////////////////////////////////
- (double) calcDailySearchFoodIntake: (FishCell *) aCell 
{
   double aDailyPotentialSearchFood;
   double aDailySearchFoodIntake = 0.0;
   double aDailyAvailableSearchFood;
   //double aCmax;

   //aCmax = [self calcCmax: [aCell getTemperature]];

   aDailyPotentialSearchFood = [self calcSearchIntake: aCell] * [self calcFeedTimeAt: aCell];
   aDailyAvailableSearchFood = [aCell getHourlyAvailSearchFood] * [self calcFeedTimeAt: aCell];
 
   //
   // aDailySearchFoodIntake is the minimum 
   // of aDailyPotentialSearchFood, aDailyAvailableSearchFood, cMax
   //
   // Now adjusted for superindividuals
   //
   aDailySearchFoodIntake = aDailyPotentialSearchFood;
 
   if(aDailyAvailableSearchFood < (aDailySearchFoodIntake * nRep)) 
   {
      aDailySearchFoodIntake = (aDailyAvailableSearchFood / nRep);
   }
   if(cMax < aDailySearchFoodIntake) 
   {
      aDailySearchFoodIntake = cMax;
   }

   return aDailySearchFoodIntake;
}




//////////////////////////////////////////////////
//
//calcDailySearchNetEnergy
//
//////////////////////////////////////////////////
- (double) calcDailySearchNetEnergy: (FishCell *) aCell 
{
   double aDailySearchNetEnergy;   

   aDailySearchNetEnergy = ([self calcDailySearchFoodIntake: aCell] * [aCell getHabPreyEnergyDensity] )
                          - [self calcTotalRespirationAt: aCell withSwimSpeed: [self getSwimSpeedAt: aCell forStrategy: SEARCH]];

   return aDailySearchNetEnergy;
}


/////////////////////////////////////////////////
//
//calcNetEnergyForCell
//
////////////////////////////////////////////////
- (double) calcNetEnergyForCell: (FishCell *) aCell 
{
   double aNetEnergy=0.0;
   double aDailySearchNetEnergy, aDailyDriftNetEnergy;

   aDailyDriftNetEnergy = [self calcDailyDriftNetEnergy: aCell];
   aDailySearchNetEnergy = [self calcDailySearchNetEnergy: aCell];
   
 //
 // Select the most profitable feeding strategy
 //
   if(aDailyDriftNetEnergy >= aDailySearchNetEnergy) 
   {
      aNetEnergy = aDailyDriftNetEnergy;
      cellFeedingStrategy = DRIFT;
   }
   else 
   {
      aNetEnergy = aDailySearchNetEnergy;
      cellFeedingStrategy = SEARCH;
   }   

   //
   // cellSwimSpeedForCell is used by hi velocity survival
   //
   cellSwimSpeedForCell = [self getSwimSpeedAt: aCell forStrategy: cellFeedingStrategy];   
  
   return aNetEnergy;
}




   
- (int) getFishFeedingStrategy 
{
  return fishFeedingStrategy;
}

- setFishFeedingStrategy: (int) aFeedingStrategy
{
  fishFeedingStrategy = aFeedingStrategy;
  return self;
}

- (double) getHourlyDriftConRate 
{
   return hourlyDriftConRate;
}

- (double) getHourlySearchConRate 
{
   return  hourlySearchConRate;
}




///////////////////////////////////////////////////
//
// calcMaxMoveDistance
//
///////////////////////////////////////////////////
- calcMaxMoveDistance 
{

  maxMoveDistance =   fishParams->fishMoveDistParamA
                    * pow(fishLength, fishParams->fishMoveDistParamB);


   #ifdef DEBUG_TROUT_FISHPARAMS
     #ifdef DEBUG_MOVE
   
       fprintf(stderr,"\n");
       fprintf(stderr,"<<<<<METHOD: calcMaxMoveDistance speciesNdx = %d >>>>>\n", speciesNdx);
       xprint(self);
       fprintf(stderr,"fishMoveDistParamA = %f\n", fishParams->fishMoveDistParamA);
       fprintf(stderr,"fishMoveDistParamB = %f\n", fishParams->fishMoveDistParamB);
       fprintf(stderr,"\n"); 
    
     #endif
   #endif

  return self;
}


///////////////////////////////////////////////
//
// tagFishDestCells
//
///////////////////////////////////////////////
- tagCellsICouldMoveTo
{
   id <ListIndex> cellNdx;
   id nextCell=nil;

   if(tagDestCellList == nil)
    {
        tagDestCellList = [List create: troutZone];
    }

    [tagDestCellList removeAll];

    [myCell getNeighborsWithin: maxMoveDistance
                      withList: tagDestCellList];

    cellNdx = [tagDestCellList listBegin: scratchZone];

    while(([cellNdx getLoc] != End) && ((nextCell = [cellNdx next]) != nil)) 
    {
         [nextCell tagPolyCell];
    } 

    [model updateTkEventsFor:reach];

    [cellNdx drop];

    return self;
}

///////////////////////////////
//
// makeMeImmortal
//
//////////////////////////////
- makeMeImmortal
{
   if(imImmortal == NO)
   {
       imImmortal = YES;
   }

   return self;
}


#ifdef MOVE_REPORT_ON

///////////////////////////////////////////////////////////////
//
// moveReport
//
//////////////////////////////////////////////////////////////
- moveReport: (FishCell *) aCell {
  FILE *mvRptPtr=NULL;
  const char *mvRptFName = "Move_Test_Out.csv";
  static BOOL moveRptFirstTime=YES;     
  double velocity, depth, temp, turbidity, availableDrift, availableSearch;
  double distToHide;
  char *mySpecies;
  char *fileMetaData;
  char strDataFormat[150];
  double outMigFuncValue = [juveOutMigLogistic evaluateFor: fishLength];

  velocity = [aCell getPolyCellVelocity];
  depth    = [aCell getPolyCellDepth];
  temp    = [aCell getTemperature];
  turbidity = [aCell getTurbidity];
  availableDrift = [aCell getHourlyAvailDriftFood];
  availableSearch = [aCell getHourlyAvailSearchFood];

  distToHide = [aCell getDistanceToHide];

  mySpecies = (char *)[[self getSpecies] getName];

  if(moveRptFirstTime == YES){
     if((mvRptPtr = fopen(mvRptFName,"w+")) != NULL){
       fileMetaData = [BreakoutReporter reportFileMetaData: scratchZone];
       fprintf(mvRptPtr,"\n%s\n\n",fileMetaData);
       [scratchZone free: fileMetaData];
       fprintf(mvRptPtr,"%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n",
                                                           "DATE",
                                                           "FISH-ID",
							   "SPECIES",
							   "AGE",
                                                           "PrevREACH",
                                                           "REACH",
                                                           "PrevCELL",
                                                           "CELL",
                                                          "VELOCITY",
                                                          "DEPTH",
                                                          "TEMP",
                                                           "TURBIDITY",
                                                          "DIST_HIDE",
                                                          "AVAIL_DRIFT",
                                                          "AVAIL_SEARCH",
                                                          "fishLength",
                                                          "fishWeight",
                                                          "feedTime",
                                                          "captureSuccess",
                                                          "potHDIntake",
                                                          "potHSIntake",
                                                          "cMax",
                                                          "standardResp",
                                                          "activeResp",
                                                          "inShelter",
                                                          "dailyDrftNetEn",
                                                          "dailySchNetEn",
                                                          "feedStrategy",
                                                          "nonStarvSurv",
                                                          "ntEnrgyFrBstCll",
                                                          "outmigrantFunc",
                                                          "ERMForBestCell");
         fflush(mvRptPtr);
         moveRptFirstTime = NO;
         fclose(mvRptPtr);
     }else{
         fprintf(stderr, "ERROR: Trout >>>> moveReport >>>> Cannot open %s for writing\n", mvRptFName);
         fflush(0);
         exit(1);
     }
  }
  if((mvRptPtr = fopen(mvRptFName,"a")) == NULL){
      fprintf(stderr, "ERROR: Trout >>>> moveReport >>>> Cannot open %s for appending\n", mvRptFName);
      fflush(0);
      exit(1);
  }

  strcpy(strDataFormat,"%s,%d,%s,%d,%s,%s,%d,%d,%E,%E,%E,%E,%E,%E,%E,%E,%E,%E,%E,%E,%E,%E,%E,%E,%s,%E,%E,%s,%E,%E,%E,%E\n");
  //pretty print
  //strcpy(strDataFormat,"%s,%d,");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: velocity]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: depth]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: temp]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: turbidity]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: distToHide]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: availableDrift]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: availableSearch]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: fishLength]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: fishWeight]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: feedTimeForCell]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: captureSuccess]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: potentialHourlyDriftIntake]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: potentialHourlySearchIntake]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: cMax]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: standardResp]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: activeResp]);
  //strcat(strDataFormat,",%s,"); // string format for inShelter
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: dailyDriftNetEnergy]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: dailySearchNetEnergy]);
  //strcat(strDataFormat,",%s,"); // string format for feedStrategy
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: nonStarvSurvival]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: netEnergyForBestCell]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: expectedMaturity]);
  //strcat(strDataFormat,"\n");

  fprintf(mvRptPtr, strDataFormat,[timeManager getDateWithTimeT: [self getCurrentTimeT]],
                                  fishID,
                                  mySpecies,
				  age,
                                  [prevReach getReachName],
                                  [[aCell getReach] getReachName],
                                  [prevCell getPolyCellNumber],
                                  [aCell getPolyCellNumber],
				  velocity,
				  depth,
				  temp,
				  turbidity,
				  distToHide,
				  availableDrift,
				  availableSearch,
				  fishLength,
				  fishWeight,
				  feedTimeForCell,
				  captureSuccess,
				  potentialHourlyDriftIntake,
				  potentialHourlySearchIntake,
				  cMax,
				  standardResp,
				  activeResp,
				  inShelter,
				  dailyDriftNetEnergy,
				  dailySearchNetEnergy,
				  feedStrategy,
				  nonStarvSurvival,
				  netEnergyForBestCell,
                                  outMigFuncValue,
				  expectedMaturity);


  fflush(mvRptPtr);
  fclose(mvRptPtr);
  return self;
}

#endif



#ifdef READY_TO_SPAWN_RPT
///////////////////////////////////////////////////////////
//
// printReadyToSpawnRpt
//
///////////////////////////////////////////////////////////
- printReadyToSpawnRpt: (BOOL) readyToSpawn 
{
  FILE * spawnReportPtr=NULL; 
  const char* readyToSpawnFile = "Ready_To_Spawn_Out.csv"; 
  static BOOL firstRTSTime=YES;
  char* readyTSString = "NO";
  time_t currentTime = (time_t) 0;
  double currentTemp;
  double currentFlow;
  double currentFlowChange;
  char *lastSpawnDate = (char *) NULL;  
  char strDataFormat[150];
  char *fileMetaData;

  if(readyToSpawn == YES) readyTSString = "YES";

   if(firstRTSTime == YES){
     if( (spawnReportPtr = fopen(readyToSpawnFile,"w+")) == NULL){
          fprintf(stderr, "ERROR: Trout >>>> printReadyToSpawnRpt >>>> Cannot open %s for writing",readyToSpawnFile);
          fflush(0);
          exit(1);
     }
       fileMetaData = [BreakoutReporter reportFileMetaData: scratchZone];
       fprintf(spawnReportPtr,"\n%s\n\n",fileMetaData);
       [scratchZone free: fileMetaData];
      fprintf(spawnReportPtr,"%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n","Date",
                                                                            "Species",
                                                                            "Age",
                                                                            "Sex",
                                                                            "Reach",
                                                                            "Temperature",
                                                                            "Flow",
                                                                            "FlowChange",
                                                                            "FishLength",
                                                                            "Condition",
                                                                            "LastSpawnDate",
                                                                            "FishSpawnStartDate",
                                                                            "FishSpawnEndDate",
                                                                            "ReadyToSpawn");
  }else if(firstRTSTime == NO){
     if( (spawnReportPtr = fopen(readyToSpawnFile,"a")) == NULL){
          fprintf(stderr, "ERROR: Trout >>>> printReadyToSpawnRpt >>>> Cannot open %s for writing",readyToSpawnFile);
          fflush(0);
          exit(1);
      }
  }
  lastSpawnDate = [[self getZone] alloc: 12*sizeof(char)];
  currentTemp = [myCell getTemperature];
  currentTime = [self getCurrentTimeT];
  currentFlow = [myCell getRiverFlow];
  currentFlowChange = [myCell getFlowChange];

  if(timeLastSpawned > (time_t) 0 ){
    strncpy(lastSpawnDate, [timeManager getDateWithTimeT: timeLastSpawned], 12);
  }else{
     strncpy(lastSpawnDate, "00/00/0000", (size_t) 12);
  }
  strcpy(strDataFormat,"%s,%s,%d,%s,%s,%E,%E,%E,%E,%E,%s,%s,%s,%s\n");
  //pretty print
  //strcpy(strDataFormat,"%s,%s,%d,%s,%s,");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: currentTemp]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: currentFlow]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: currentFlowChange]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: fishLength]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: fishCondition]);
  //strcat(strDataFormat,",%s,%s,%s,%s\n");

  fprintf(spawnReportPtr,strDataFormat,[timeManager getDateWithTimeT: currentTime],
                                       [species getName],
                                       age,
                                       [sex getName],
                                       [reach getReachName],
                                       currentTemp,
                                       currentFlow,
                                       currentFlowChange,
                                       fishLength,
                                       fishCondition,
                                       lastSpawnDate,
                                       fishParams->fishSpawnStartDate,
                                       fishParams->fishSpawnEndDate,
                                       readyTSString);


   firstRTSTime = NO;
   fclose(spawnReportPtr);
   return self;
} 
#endif


#ifdef SPAWN_CELL_RPT
/////////////////////////////////////////////////
//
// printSpawnCellRpt
//
/////////////////////////////////////////////////
- printSpawnCellRpt: (id <List>) spawnCellList 
{
  FILE * spawnCellRptPtr=NULL;
  const char * spawnCellFile = "Spawn_Cell_Out.csv";
  static BOOL spawnCellFirstTime = YES;
  char strDataFormat[150];
  double cellDepth,cellVelocity,cellArea,fracSpawn,depthSuit,velSuit,spawnQuality;
  char * fileMetaData;

  id <ListIndex> cellListNdx=nil;
  id  aCell=nil;

  if(spawnCellFirstTime == YES){
      if((spawnCellRptPtr = fopen(spawnCellFile,"w+")) == NULL){
          fprintf(stderr, "ERROR: Trout >>>> printSpawnCellRpt >>>> Cannot open report file %s for writing", spawnCellFile);
          fflush(0);
          exit(1);
      }
       fileMetaData = [BreakoutReporter reportFileMetaData: scratchZone];
       fprintf(spawnCellRptPtr,"\n%s\n\n",fileMetaData);
       [scratchZone free: fileMetaData];
      fprintf(spawnCellRptPtr,"%s,%s,%s,%s,%s,%s,%s,%s,\n","FishID",
                                                           "Depth",
                                                           "Velocity",
                                                           "Area",
                                                           "fracSpawn",
                                                           "DepthSuit",
                                                           "VelSuit",
                                                           "spawnQuality");
  }
  if(spawnCellFirstTime == NO){
	if((spawnCellRptPtr = fopen(spawnCellFile,"a")) == NULL) 
	{
	    fprintf(stderr, "ERROR: Trout >>>> printSpawnCellRpt >>>> Cannot open report file %s for writing\n", spawnCellFile);
	    fflush(0);
	    exit(1);
	}
  }

  cellListNdx = [spawnCellList listBegin: [self getZone]];

  while(([cellListNdx getLoc] != End) && ((aCell = [cellListNdx next]) != nil)){
    cellDepth	  = [aCell getPolyCellDepth];
    cellVelocity  = [aCell getPolyCellVelocity];
    cellArea	  = [aCell getPolyCellArea];
    fracSpawn	  = [aCell getCellFracSpawn];
    depthSuit	  = [self getSpawnDepthSuitFor: [aCell getPolyCellDepth] ];
    velSuit	  = [self getSpawnVelSuitFor: [aCell getPolyCellVelocity]];
    spawnQuality  = [self getSpawnQuality: aCell];
    strcpy(strDataFormat,"%p,%E,%E,%E,%E,%E,%E,%E\n");
    //pretty print
    //strcpy(strDataFormat,"%p,");
    //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: cellDepth]);
    //strcat(strDataFormat,",");
    //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: cellVelocity]);
    //strcat(strDataFormat,",");
    //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: cellArea]);
    //strcat(strDataFormat,",");
    //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: fracSpawn]);
    //strcat(strDataFormat,",");
    //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: depthSuit]);
    //strcat(strDataFormat,",");
    //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: velSuit]);
    //strcat(strDataFormat,",");
    //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: spawnQuality]);
    //strcat(strDataFormat,"\n");
    fprintf(spawnCellRptPtr,strDataFormat,self,
					  cellDepth, 
					  cellVelocity, 
					  cellArea, 
					  fracSpawn, 
					  depthSuit, 
					  velSuit, 
					  spawnQuality); 
  }  
  [cellListNdx drop];

  if(spawnCellRptPtr != NULL){
    fclose(spawnCellRptPtr);
  }
  spawnCellFirstTime = NO;
  return self;
}
#endif


////////////////////////////////////////////////////////
//
// outmigrateFrom:
// Added SFR 1/14/2011
//
////////////////////////////////////////////////////////
- outmigrateFrom: (FishCell *) bestDest {
    size_t strLen = strlen("Outmigration") + 1;

    [model addToNewOutmigrants: self ];
    prevCell = myCell;
    prevReach = [myCell getReach];
    [myCell removeFish: self];
    [self setSizeSymbol: [model getSizeSymbolForLength: fishLength]];

    // feign death to keep from executing "die" on the same day as outmigration
    causeOfDeath = [model getOutmigrationSymbol];
 // deathCausedBy = "Outmigration";  // This makes 'drop' fail.
    deathCausedBy = (char *) [troutZone alloc: strLen*sizeof(char)];
    strncpy(deathCausedBy, "Outmigration", strLen);

    //PRINT THE MOVE REPORT AFTER GETTING VARIABLES FOR BEST CELL
    #ifdef MOVE_REPORT_ON
    feedStrategy = "OUTMIG";
    feedTimeForCell = [self calcFeedTimeAt: bestDest];
    standardResp = [self calcStandardRespirationAt: bestDest];
    activeResp = -1.0; // Cannot be determined easily for outmigrants
    inShelter = "UNK"; // Cannot be determined easily for outmigrants
    captureSuccess = [self calcCaptureSuccess: bestDest];
    potentialHourlyDriftIntake = [self calcDriftIntake: bestDest];
    potentialHourlySearchIntake = [self calcSearchIntake: bestDest];
    dailyDriftNetEnergy = [self calcDailyDriftNetEnergy: bestDest];
    dailySearchNetEnergy = [self calcDailySearchNetEnergy: bestDest];
    netEnergyForBestCell = [self calcNetEnergyForCell: bestDest];
    expectedMaturity = [self expectedMaturityAt: bestDest];
    nonStarvSurvival = [bestDest getTotalKnownNonStarvSurvivalProbFor: self];

    [self moveReport: bestDest];
    #endif

    return self;
}



- (void) drop {
     [spawnDist drop]; 
     [dieDist drop];

     [destCellList drop];
     destCellList = nil; 

     if(deathCausedBy != NULL){
         [troutZone free: deathCausedBy];
         deathCausedBy = NULL;
     }

     [troutZone drop];
     troutZone = nil;

     [super drop];
     self = nil;
}


@end



