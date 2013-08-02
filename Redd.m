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



#include <math.h>
#import "Redd.h"
#import  "Trout.h"
#import  "TroutModelSwarm.h"

id <Symbol> Female, Male, CoinFlip;  // sex of fish

@implementation TroutRedd

- setCell: (FishCell *) aCell 
{
  myCell = aCell;
  return self;
}


- setModel 
{
  model =  (id <TroutModelSwarm>) [[myCell getSpace] getModel] ;
  return self;
}


- setTimeManager: (id <TimeManager>) aTimeManager
{
    timeManager = aTimeManager;
    return self;
}


- setReddBinomialDist: (id <BinomialDist>) aBinomialDist
{
   reddBinomialDist = aBinomialDist;
   return self;
}


- setCellNumber: (int) aCellNumber 
{
  cellNumber   = aCellNumber;
  return self;
}
  
- (FishCell *) getCell 
{
    return myCell;
}

- setIAmGuarded: (BOOL) aBOOL
{
  iAmGuarded = aBOOL;
  return self;
}

- (BOOL) getIAmGuarded
{
  return iAmGuarded;
}

- createEnd 
{
  [super createEnd];
  reddZone = [Zone create: [self getZone]];
  numEggsToEmerge = 0;
  emergeDays = 0;
  fracDeveloped = 0.0;
  numberOfEggsLostToDewatering = 0;
  numberOfEggsLostToScouring = 0;
  numberOfEggsLostToLowTemp = 0;
  numberOfEggsLostToHiTemp = 0;
  numberOfEggsLostToSuperimp = 0;

  #ifdef REDD_MORTALITY_REPORT
  printList     = [List create: reddZone];
  #endif
  #ifdef REDD_SURV_REPORT
  survPrintList = [List create: reddZone];
  #endif

  
  reddUniformDist = [UniformDoubleDist create: reddZone 
                         setGenerator: randGen
                              setDoubleMin: fishParams->reddNewLengthMin
                            setMax: fishParams->reddNewLengthMax];



    #ifdef DEBUG_REDD

        fprintf(stderr,"\n");
        fprintf(stderr,"<<<<<<< DEBUG REDD ----> speciesNdx = %d >>>>> \n", speciesNdx);
        fprintf(stderr,"METHOD: createEnd \n");
        fprintf(stderr,"reddNewLengthMean %f \n",fishParams->reddNewLengthMean);
        fprintf(stderr,"reddNewLengthStdDev = %f \n",fishParams->reddNewLengthVar);

        fflush(0);

    #endif


  return self;
}

- setCreateTimeT: (time_t) aCreateTime 
{
  createTime = aCreateTime;
  return self;
}

- (time_t) getCreateTimeT 
{
  return createTime;
}

- (time_t) getCurrentTimeT 
{
  return [model getModelTime];
}


- setReddColor: (Color) aColor 
{
  myColor = aColor;
  return self;
}

- (Color) getReddColor 
{
  return myColor;
}
/////////////////////////////////////////////////////////////
//
// drawSelfOn
//
/////////////////////////////////////////////////////////////
- drawSelfOn: (id <Raster>) aRaster 
{
  if (myRasterX >= 0)  // myRasterX is -1 if there are no pixels in cell
  {
  [aRaster ellipseX0: myRasterX - 3 
                  Y0: myRasterY - 2 
                  X1: myRasterX + 3 
                  Y1: myRasterY + 2 
               Width: 1 
               Color: myColor];  
  }

  return self;
}

- setRasterX: (unsigned) anX
{
    myRasterX = anX;

    //    fprintf(stderr,"Setting rasterX to %d \n",myRasterX);
    //    fflush(0);

    return self;
}

- setRasterY: (unsigned) aY
{
    myRasterY = aY;
    return self;
}


- setSpecies: (id <Symbol>) aSymbol 
{
    species = aSymbol;

    Species = (const char *) [species getName];

    return self;
}

- (id <Symbol>) getSpecies 
{
    return species;
}

- setSpeciesNdx: (int) aSpeciesNdx 
{
  speciesNdx = aSpeciesNdx;
  return self;
}

- (int) getSpeciesNdx 
{
  return speciesNdx;
}



- setFishParams: (FishParams *) aFishParams
{
   fishParams = aFishParams;
   return self;
}

- (FishParams *) getFishParams
{
   return fishParams;
}



////////////////////////////////////
//
// Some info about the spawner
//
////////////////////////////////////
- setSpawnerLength: (double) aDouble 
{
    spawnerLength = aDouble;
    return self;
}

- (double) getSpawnerLength 
{
    return spawnerLength;
}


- setSpawnerWeight: (double) aDouble 
{
    spawnerWeight = aDouble;
    return self;
}

- (double) getSpawnerWeight 
{
    return spawnerWeight;
}

- setSpawnerAge: (int)anAge
{
   spawnerAge = anAge;
   return self;
}


- (int) getSpawnerAge
{
   return spawnerAge;
}


- setNumberOfEggs: (int) anInt 
{
    numberOfEggs = anInt;
    initialNumberOfEggs = numberOfEggs;
    return self;
}

- setPercentDeveloped: (double) aFloat 
{
  fracDeveloped = aFloat;
  return self;
}


// Redd Daily Routine Methods: survive, develop, emerge
 

  // Redd mortality risk computation

//////////////////////////////////////////////////////////////
//
// survive
//
//////////////////////////////////////////////////////////////
- survive 
{
  int eggsLostToDewatering=0;
  int eggsLostToScouring=0;
  int eggsLostToLowTemp=0;
  int eggsLostToHiTemp=0;
  int eggsLostToSuperimp=0;

  int totalEggsLost = 0;

  //
  // Survival Manager Code
  //
  {

    //
    // Begin code for the survival manager 
    //
    {
       id <List> listOfSurvProbs;
       id <ListIndex> lstNdx;
       id <SurvProb> aProb;

       double dewater = (double) -LARGEINT;
       double scour = (double) -LARGEINT;
       double loTemp = (double) -LARGEINT;
       double hiTemp = (double) -LARGEINT;
       double superimp = (double) -LARGEINT;
 
       [myCell updateReddSurvivalProbFor: self];

       listOfSurvProbs = [myCell getReddListOfSurvProbsFor: self];

       lstNdx = [listOfSurvProbs listBegin: scratchZone];
       while(([lstNdx getLoc] != End) && ((aProb = [lstNdx next]) != nil))
       {
         
           //
           // Caution: the order of these MUST match the survival probs in the
           // cell.
           //

           if(dewater == (double) -LARGEINT) dewater = [aProb getSurvivalProb];
           else if (scour == (double) -LARGEINT) scour = [aProb getSurvivalProb];
           else if (loTemp == (double) -LARGEINT) loTemp = [aProb getSurvivalProb];
           else if (hiTemp == (double) -LARGEINT) hiTemp = [aProb getSurvivalProb];
           else if (superimp == (double) -LARGEINT) superimp = [aProb getSurvivalProb];
    
       }

       [lstNdx drop];  

       if(    (dewater == (double) -LARGEINT) 
           || (scour == (double) -LARGEINT) 
           || (loTemp == (double) -LARGEINT)
           || (hiTemp == (double) -LARGEINT)
           || (superimp == (double) -LARGEINT))
        {
             fprintf(stderr, "ERROR: Redd >>>> survive probability values not properly set\n");
             fflush(0);
             exit(1);
        }

        if(numberOfEggs > 0)
        {
            eggsLostToDewatering = [reddBinomialDist getUnsignedSampleWithNumTrials: (unsigned) numberOfEggs
                                                                    withProbability: (1.0 - dewater)];
            numberOfEggs -= eggsLostToDewatering; 
        }


        if(numberOfEggs > 0)
        {
            eggsLostToScouring = [reddBinomialDist getUnsignedSampleWithNumTrials: (unsigned) numberOfEggs
                                                              withProbability: (1.0 - scour)];
            numberOfEggs -= eggsLostToScouring; 
        }
           

        if(numberOfEggs > 0)
        {
            eggsLostToLowTemp = [reddBinomialDist getUnsignedSampleWithNumTrials: (unsigned) numberOfEggs
                                                             withProbability: (1.0 - loTemp)];
            numberOfEggs -= eggsLostToLowTemp; 
        }

        
        if(numberOfEggs > 0)
        {
            eggsLostToHiTemp = [reddBinomialDist getUnsignedSampleWithNumTrials: (unsigned) numberOfEggs
                                                            withProbability: (1.0 - hiTemp)];
            numberOfEggs -= eggsLostToHiTemp; 
        }

        if(numberOfEggs > 0)
        {
            eggsLostToSuperimp = [reddBinomialDist getUnsignedSampleWithNumTrials: (unsigned) numberOfEggs
                                                              withProbability: (1.0 - superimp)];
            numberOfEggs -= eggsLostToSuperimp; 
        }

        if(numberOfEggs < 0)
        {
            fprintf(stderr, "ERROR: Redd >>>> survive >>>> numberOfEggs is less than 0\n");
            fflush(0);
            exit(1);
        }


        numberOfEggsLostToDewatering += (int)eggsLostToDewatering;
        numberOfEggsLostToScouring += (int)eggsLostToScouring;
        numberOfEggsLostToLowTemp += (int)eggsLostToLowTemp;
        numberOfEggsLostToHiTemp += (int)eggsLostToHiTemp;
        numberOfEggsLostToSuperimp += (int)eggsLostToSuperimp;

        totalEggsLost =  numberOfEggsLostToDewatering 
                         + numberOfEggsLostToScouring 
                         + numberOfEggsLostToLowTemp 
                         + numberOfEggsLostToHiTemp 
                         + numberOfEggsLostToSuperimp;

       if(totalEggsLost > initialNumberOfEggs)
       {
           fprintf(stderr, "ERROR: Redd >>>> survive >>>> totalEggsLost is greater than the initialNumberOfEggs\n");
           fprintf(stderr, "ERROR: Redd >>>> survive >>>> totalEggsLost %d\n", totalEggsLost);
           fprintf(stderr, "ERROR: Redd >>>> survive >>>> initialNumberOfEggs %d\n", initialNumberOfEggs);
           fflush(0);
           exit(1);
       }

      #ifdef REDD_MORTALITY_REPORT
       [self createPrintString: eggsLostToDewatering
                              : eggsLostToScouring
                              : eggsLostToLowTemp
                              : eggsLostToHiTemp
                              : eggsLostToSuperimp
                              : [model getModelTime] ];
       #endif

       #ifdef REDD_SURV_REPORT
       [self createSurvPrintStringWithDewaterSF: dewater
                                    withScourSF: scour
                                   withLoTempSF: loTemp
                                   withHiTempSF: hiTemp
                                 withSuperimpSF: superimp];
       #endif
     

      }
  }

  if(numberOfEggs < 0)
  {
     fprintf(stderr, "ERROR: Redd >>>> survive >>>> numberOfEggs is less than zero\n");
     fflush(0);
     exit(1);
  }


  if(numberOfEggs == 0 ) 
  {
      #ifdef REDD_MORTALITY_REPORT
     [self printReport];
      #endif
     //[self createReddSummaryStr];
     //[self printReddSummary];  

     [self removeWhenEmpty];
  }
  


  return self;
}




//////////////////////////////////////////////////////////////
//
// develop
// Revised for salmon model SFR 1/13/2011
//
//////////////////////////////////////////////////////////////
- develop 
{
    if((numberOfEggs > 0) && (fracDeveloped < 1.0) )
    {
       double rDPA, rDPB, rDPC;
       double temperature=-1;  //what is a good value here?
       double  reddDailyDevelop;

       rDPA = fishParams->reddDevelParamA; 
       rDPB = fishParams->reddDevelParamB; 
       rDPC = fishParams->reddDevelParamC; 

       if(myCell != nil) 
       {
           temperature = [myCell getTemperature];
       }
       else  
       {
           fprintf(stderr, "WARNING: Redd %p has no myCell\n", self);
           fflush(0);
       }

//       reddDailyDevelop = rDPA + (rDPB * temperature) + ( rDPC * pow(temperature,2) );
       reddDailyDevelop = 1 / (rDPA * pow((temperature - rDPC),rDPB));
       fracDeveloped += reddDailyDevelop;

   }

    #ifdef DEBUG_REDD

        fprintf(stderr,"\n");
        fprintf(stderr,"<<<<<<< DEBUG REDD ----> speciesNdx = %d >>>>> \n", speciesNdx);
        fprintf(stderr,"METHOD: develop \n");
        fprintf(stderr,"reddDevelParamA = %f \n",fishParams->reddDevelParamA);
        fprintf(stderr,"reddDevelParamB = %f \n",fishParams->reddDevelParamB);
        fprintf(stderr,"reddDevelParamC = %f \n",fishParams->reddDevelParamC);

        fflush(0);

    #endif

   return self;
}


////////////////////////////////////
//
// emerge
//
////////////////////////////////////
- emerge 
{
  int numFishToEmerge;
  int numObjectsToCreate;
  int superindividualRatio = [model getJuvenileSuperindividualRatio];

  if((fracDeveloped >= 1.0) && (numberOfEggs > 0))
  {
     emergeDays++;

     // We assume that the percent of eggs emerging on each day 
     // (starting when percentDeveloped reaches 100%) is 10% the first day,
     // 20% the second day, etc. until all eggs have emerged.

     numFishToEmerge = (int) (emergeDays * 0.10 * numberOfEggs); 


     // create new fish 

     if(numFishToEmerge >= numberOfEggs) 
     {
         numFishToEmerge = numberOfEggs;
     }

     // Make sure there is at least one superindividual to create 

     if(numFishToEmerge < superindividualRatio) 
     {
         numFishToEmerge = superindividualRatio;
     }

     // Reduce number left in redd
     numberOfEggs -= numFishToEmerge;

     // Adjust number for superindividuals: Divide and round
     numObjectsToCreate = (int) ((numFishToEmerge / superindividualRatio) + 0.5);

     if(numObjectsToCreate > 0) 
     {
         int   count;

         for (count = 1; count <= numObjectsToCreate; count++) 
         {
	   // For each egg emerging from the redd, the model creates a
	   // new fish object.  The fish inherits its species and
	   // location from the redd.  

           [self turnMyselfIntoAFish];
	   // numberOfEggs--;
         }
     }

     // determine if Redd empty - if so, remove redd
     if (numberOfEggs <= 0)
     {
      #ifdef REDD_MORTALITY_REPORT
        [self printReport]; // Added 2/28/04 skj
      #endif
        [self removeWhenEmpty];
     }
  }

  return self;
}

//////////////////////////////////////////////////////////////
//
// removeWhenEmpty
//
/////////////////////////////////////////////////////////////
- removeWhenEmpty 
{  
  [self createReddSummaryStr];
  [self printReddSummary];  

  [model addToEmptyReddList: self];

  //
  // remove Redd from Cell it is in
  //
  [myCell removeRedd: self]; 
  myCell = nil;

  return self;
}


/////////////////////////////////////////////////////////////////
//
// turnMySelfIntoAFish
//
////////////////////////////////////////////////////////////////
- turnMyselfIntoAFish 
{
  id newFish=nil;
  // double length = (double) LARGEINT;   

  //fprintf(stdout, "Redd >>>> turnMySelfIntoAFish >>>> BEGIN\n");
  //fflush(0);

  // Revised for salmon to use uniform distribution


  newFish = [model createNewFishWithSpeciesIndex: speciesNdx  
                                         Species: species
                                          Length: [reddUniformDist getDoubleSample]
					     Sex: CoinFlip];

  [newFish setFishColor: myColor];

  //
  // sets myCell pointer and x,y coords for newFish
  //
  //[[self getCell] addFish: newFish]; 
  [myCell addFish: newFish]; 

  [model addAFish: newFish];

  //
  // Set ivars in newFish
  //
  [newFish setAge: 0];           //Temporary fix to give spawners an age
  [newFish setAgeSymbol: [model getAgeSymbolForAge: 0]];
  [newFish setLifestageSymbol: [model getJuvenileLifestageSymbol]];  // New for salmon
  [newFish setNatalReachSymbol: [[myCell getReach] getReachSymbol]];
  [newFish setNRep: [model getJuvenileSuperindividualRatio]];

  [newFish moveToBestDest: myCell];

  //fprintf(stdout, "Redd >>>> turnMySelfIntoAFish >>>> END\n");
  //fflush(0);

  return self;

}




//////////////////////////////////////////////////////////
//
//printReport
//
/////////////////////////////////////////////////////
- printReport 
{
  id <ListIndex> printNdx;
  id nextString;
  FILE* printRptPtr = [model getReddReportFilePtr];

  if(printRptPtr == NULL)
  {
     return self;   // pointer will be NULL if this optional file is not on
     // fprintf(stderr, "ERROR: Redd >>>> printReport >>>> printRptPtr = %p\n", printRptPtr);
     // fflush(0);
     // exit(1);
  }

  fprintf(printRptPtr,"\n%s %p\n","BEGIN REPORT for Redd", self);
  fprintf(printRptPtr,"Redd: %p Scenario = %d Replicate = %d\n", self, [model getScenario],
                                                                       [model getReplicate]);

  fprintf(printRptPtr,"Redd: %p Species: %s  CellNumber: %d\n", self,
                                                                [species getName],
                                                                cellNumber);

  fprintf(printRptPtr,"Redd: %p INITIAL NUMBER OF EGGS: %d\n", self, initialNumberOfEggs);

  fprintf(printRptPtr,"\n%-12s%-12s%-12s%-10s%-10s%-10s%-10s\n", "Redd",
                                                                 "Date",
                                                                 "Dewatering", 
                                                                 "Scouring",
                                                                 "LowTemp",
                                                                 "HiTemp",
                                                                 "Superimposition");

  printNdx = [printList listBegin: [self getZone]];

  while(([printNdx getLoc] != End) && ((nextString = [printNdx next]) != nil)) 
  {
    fprintf(printRptPtr,"%s",(char *) nextString);
    [[self getZone] free: nextString];
  }


  fprintf(printRptPtr,"%-12p%-12s%-12d%-10d%-10d%-10d%-10d\n", self, 
                                                              "TOTALS:",
                                                              numberOfEggsLostToDewatering,
                                                              numberOfEggsLostToScouring,
                                                              numberOfEggsLostToLowTemp,
                                                              numberOfEggsLostToHiTemp,
                                                              numberOfEggsLostToSuperimp);

  fprintf(printRptPtr,"\n\n%s %p\n","END REPORT for Redd", self);

  [printNdx drop];
  [printList drop];

  return self;
}



////////////////////////////////////////////////////////////////
//
//createPrintString
//
////////////////////////////////////////////////////////////////
- createPrintString: (int) eggsLostToDewatering
                   : (int) eggsLostToScouring
                   : (int) eggsLostToLowTemp
                   : (int) eggsLostToHiTemp
                   : (int) eggsLostToSuperimp
                   : (time_t) aModelTime_t 
{

  id printString;
  const char* formatString;

  printString  = [[self getZone] alloc: 300*sizeof(char)];

  formatString = "%-12p%-12s%-12d%-10d%-10d%-10d%-10d\n";
 
  sprintf((char *)printString,formatString, self,
                                            [timeManager getDateWithTimeT: aModelTime_t],
                                            eggsLostToDewatering,
                                            eggsLostToScouring,
                                            eggsLostToLowTemp,
                                            eggsLostToHiTemp,
                                            eggsLostToSuperimp);


  [printList addLast: printString];

  return self;
}




//////////////////////////////////////////////////////////
//
//printReddSurvReport
//
/////////////////////////////////////////////////////
- printReddSurvReport: (FILE *) printRptPtr {
  id <ListIndex> printNdx;
  id nextString;
  const char *formatString;

  fprintf(printRptPtr,"\n\n%s %p\n","BEGIN SURVIVAL REPORT for Redd", self);

  fprintf(printRptPtr,"Redd: %p Species: %s  CellNumber: %d\n", self,
                                                                [species getName],
                                                                cellNumber);

  fprintf(printRptPtr,"Redd: %p INITIAL NUMBER OF EGGS: %d\n", self, initialNumberOfEggs);
  formatString = "\n%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n";

  fprintf(printRptPtr,formatString, "Redd",
                                    "Species",
                                    "Temperature",
                                    "Flow",
                                    "Depth",
                                    "Dewatering", 
                                    "Scouring",
                                    "LowTemp",
                                    "HiTemp",
                                    "Superimposition");

  printNdx = [survPrintList listBegin: [self getZone]];

  while( ([printNdx getLoc] != End) && ( (nextString = [printNdx next]) != nil) ) {
    fprintf(printRptPtr,"%s",(char *) nextString);
    [[self getZone] free: (void *) nextString];
  }

  fprintf(printRptPtr,"\n\n%s %p\n","END SURVIVAL REPORT for Redd", self);

[printNdx drop];
[survPrintList deleteAll];
[survPrintList drop];

return self;
}

////////////////////////////////////////////////////////////////
//
//createSurvPrintString
//
////////////////////////////////////////////////////////////////
- createSurvPrintStringWithDewaterSF: (double) aDewaterSF
                         withScourSF: (double) aScourSF
                        withLoTempSF: (double) aLoTempSF
                        withHiTempSF: (double) aHiTempSF
                      withSuperimpSF: (double) aSuperimpSF
 {

  id printString;
  char formatString[150];
  
  printString  = [[self getZone] alloc: 300*sizeof(char)];

  strcpy(formatString,"%p,%s,%E,%E,%E,%E,%E,%E,%E,%E\n");
  //pretty print
  //strcpy(formatString,"%p,%s,");
  //strcat(formatString,[BreakoutReporter formatFloatOrExponential: temp]);
  //strcat(formatString,",");
  //strcat(formatString,[BreakoutReporter formatFloatOrExponential: flow]);
  //strcat(formatString,",");
  //strcat(formatString,[BreakoutReporter formatFloatOrExponential: depth]);
  //strcat(formatString,",");
  //strcat(formatString,[BreakoutReporter formatFloatOrExponential: aDewaterSF]);
  //strcat(formatString,",");
  //strcat(formatString,[BreakoutReporter formatFloatOrExponential: aScourSF]);
  //strcat(formatString,",");
  //strcat(formatString,[BreakoutReporter formatFloatOrExponential: aLoTempSF]);
  //strcat(formatString,",");
  //strcat(formatString,[BreakoutReporter formatFloatOrExponential: aHiTempSF]);
  //strcat(formatString,",");
  //strcat(formatString,[BreakoutReporter formatFloatOrExponential: aSuperimpSF]);
  //strcat(formatString,"\n");

  sprintf((char *)printString,formatString,self,
					    [species getName],
                                            [myCell getTemperature],
                                            [myCell getRiverFlow],
                                            [myCell getPolyCellDepth],
                                            aDewaterSF,
                                            aScourSF,
                                            aLoTempSF,
                                            aHiTempSF,
                                            aSuperimpSF);
  [survPrintList addLast: printString];
  return self;
}


////////////////////////////////////////////////////////
//
// createReddSummaryStr
//
///////////////////////////////////////////////////////
- createReddSummaryStr 
{
  char strDataFormat[150];

  char reddCreateDate[12];
  char emptyDate[12];

  id reach = [myCell getReach];
  char reachName[25];

  int fryEmerged = initialNumberOfEggs - (   numberOfEggsLostToDewatering
                                           + numberOfEggsLostToScouring
                                           + numberOfEggsLostToLowTemp
                                           + numberOfEggsLostToHiTemp
                                           + numberOfEggsLostToSuperimp);

  if(summaryString == NULL){
      summaryString = (char *) [[self getZone] alloc: 300*sizeof(char)];
  }

  strncpy(reddCreateDate, [timeManager getDateWithTimeT: createTime], 11);  
  strncpy(emptyDate, [timeManager getDateWithTimeT: [model getModelTime]], 11);
  
  strncpy(reachName, [reach getReachName], (size_t) 25);

  strcpy(strDataFormat,"%d,%d,%p,");
  strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: spawnerLength]);
  strcat(strDataFormat,",");
  strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: spawnerWeight]);
  strcat(strDataFormat,",%d,%s,%s,%d,%s,%d,%s,%d,%d,%d,%d,%d,%d\n");

  sprintf(summaryString, strDataFormat, [model getScenario],  
                                       [model getReplicate],
                                       self,
                                       spawnerLength,
                                       spawnerWeight,
                                       spawnerAge,
                                       [species getName],
                                       reachName,
                                       cellNumber,
                                       reddCreateDate,
                                       initialNumberOfEggs,
                                       emptyDate,
                                       numberOfEggsLostToDewatering,
                                       numberOfEggsLostToScouring,
                                       numberOfEggsLostToLowTemp,
                                       numberOfEggsLostToHiTemp,
                                       numberOfEggsLostToSuperimp,
                                       fryEmerged);
  return self;

}

////////////////////////////////////////////////////////////
//
// printReddSummary
//
////////////////////////////////////////////////////////////
- printReddSummary {
  FILE* fptr = [model getReddSummaryFilePtr];

  if(fptr == NULL) {
      fprintf(stderr, "ERROR: Redd >>>> printReddSummary >>>> The FILE pointer is %p\n", fptr);
      fflush(0);
      exit(1);
  }

  fprintf(fptr,"%s",summaryString);
  fflush(0);

  if(summaryString != NULL){
      [[self getZone] free: summaryString];
  }
 
  return self;
}





//////////////////////////////////////
//
// drop
//
/////////////////////////////////////
- (void) drop
{
    [reddUniformDist drop];
    reddUniformDist = nil;
 
    [reddZone drop];
    reddZone = nil;

    [super drop];
    self = nil;

}

//////////////////////////////////////
//
// getDepth  added 1/14/SFR
//
/////////////////////////////////////
- (double) getDepth
{

   return [myCell getPolyCellDepth];

}

//////////////////////////////////////
//
// getVelocity  added 1/14/SFR
//
/////////////////////////////////////
- (double) getVelocity
{

   return [myCell getPolyCellVelocity];

}




@end

