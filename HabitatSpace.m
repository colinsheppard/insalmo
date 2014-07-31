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



#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#import <math.h>
#import <random.h>
#import <simtoolsgui.h>

#import "globals.h"
#import "Trout.h"
#import "Redd.h"
#import "HabitatSpace.h"


@implementation HabitatSpace
+ createBegin: aZone 
{
  HabitatSpace* obj;

  obj = [super createBegin: aZone];


  obj->tomorrowsRiverFlow = -LARGEINT;
  obj->yesterdaysRiverFlow = -LARGEINT;

  obj->flowInputManager = nil;

  obj->solarManager = nil;

  obj->habitatRptFilePtr = NULL;

  obj->appendFiles = NO;
  obj->scenario = 0;
  obj->replicate = 0;

  obj->cellFishInfoReporter = nil;
  obj->ageSymbolList = nil;
  obj->speciesSymbolList = nil;

  obj->cellFishList = nil;    

  obj->reachName = NULL;
  obj->instanceName = NULL;

  obj->habitatZone = [Zone create: aZone];

  obj->hydraulicFile = (char *) [obj->habitatZone alloc: 50*sizeof(char)];
  obj->flowFile = (char *) [obj->habitatZone alloc: 50*sizeof(char)];

  obj->temperatureFile = (char *) [obj->habitatZone alloc: 50*sizeof(char)];

  obj->turbidityFile = (char *) [obj->habitatZone alloc: 50*sizeof(char)];

  obj->polyCellGeomFile = (char *) [obj->habitatZone alloc: 50*sizeof(char)];

  obj->cellHabVarsFile = (char *) [obj->habitatZone alloc: 50*sizeof(char)];

  //
  // Initialize the habitat parameters to nonsense values
  //
  obj->habDriftConc          = -1.0;
  obj->habDriftRegenDist     = -1.0;
  obj->habMaxSpawnFlow       = -1.0;
  obj->habPreyEnergyDensity  = -1.0;
  obj->habSearchProd         = -1.0;
  obj->habShearParamA        = -99999999999.0;
  obj->habShearParamB        = -99999999999.0;
  obj->habShelterSpeedFrac   = -1.0;


  //obj->polyCellList = [List create: obj->habitatZone];

  return obj;
}

/////////////////////////////////////////////
//
// createEnd
//
////////////////////////////////////////////
- createEnd {

  fprintf(stdout, "HabitatSpace >>>> createEnd >>>> before [super createEnd]\n");
  fflush(0);

  //[super createEnd];

  temperature = LARGEINT;


  fprintf(stdout, "HabitatSpace >>>> createEnd >>>> before checkHabitatParams\n");
  fflush(0);

  [self checkHabitatParams];

  fprintf(stdout, "HabitatSpace >>>> createEnd >>>> after checkHabitatParams\n");
  fflush(0);

  return self;
}

///////////////////////////////////////////////
//
// checkHabitatParams
//
///////////////////////////////////////////////
- checkHabitatParams
{
   BOOL ERROR = NO;

   if(habDriftConc  < 0.0)
   {
      ERROR = YES;
   }          
   if(habDriftRegenDist < 0.0)
   {
      ERROR = YES;
   }
   if(habMaxSpawnFlow < 0.0)
   {
      ERROR = YES;
   }
   if(habPreyEnergyDensity < 0.0)
   {
      ERROR = YES;
   }
   if(habSearchProd < 0.0)
   {
      ERROR = YES;
   }
   if(habShearParamA == -99999999999.0)
   {
      ERROR = YES;
   }
   if(habShearParamB == -99999999999.0)
   {
      ERROR = YES;
   }
   if((habShelterSpeedFrac < 0) || habShelterSpeedFrac > 1.0)
   {
       ERROR = YES;
   }

   if(ERROR)
   {
       fprintf(stderr, "ERROR: HabitatSpace >>>> checkHabitatParams >>>> reachName %s >>>> please check the inputted parameters for correct or missing values\n", reachName);
       fflush(0);
       exit(1); 
   }

   return self;
}


////////////////////////////////////////////////
//
// buildObjects
//
///////////////////////////////////////////////
- buildObjects 
{
 modelDate = (char *) [habitatZone alloc: 12 * sizeof(char)];

 barrierList = [List create: habitatZone];

 habitatReportFirstWrite = YES;
 depthReportFirstWrite = YES;
 velocityReportFirstWrite = YES;
 depthVelRptFirstTime=YES;

 foodReportFirstTime = YES;

  //
  // BEGIN REPORT FILES
  //
  cellDepthReportFile = (char *) [habitatZone alloc: (strlen(reachName) + strlen("_Cell_Flow_Depth_Test_Out.csv") + 1)];

  strcpy(cellDepthReportFile, reachName);
  strcat(cellDepthReportFile, "_Cell_Flow_Depth_Test_Out.csv"); 

  cellVelocityReportFile = (char *) [habitatZone alloc: (strlen(reachName) + strlen("_Cell_Flow_Velocity_Test_Out.csv") + 1)];

  strcpy(cellVelocityReportFile, reachName);
  strcat(cellVelocityReportFile, "_Cell_Flow_Velocity_Test_Out.csv"); 

  habitatReportFile = (char *) [habitatZone alloc: (strlen(reachName) + strlen("_Habitat_Out.csv") + 1)];

  strcpy(habitatReportFile, reachName);
  strcat(habitatReportFile, "_Habitat_Out.csv"); 

  cellAreaDepthVelReportFile = (char *) [habitatZone alloc: (strlen(reachName) + strlen("_Cell_Depth_Area_Velocity_Out.csv") + 1)];

  strcpy(cellAreaDepthVelReportFile, reachName);
  strcat(cellAreaDepthVelReportFile, "_Cell_Depth_Area_Velocity_Out.csv"); 
  
  // 
  // END REPORT FILES
  //

  Date = (char *) [habitatZone alloc: 12*sizeof(char)];

  habDownstreamLinksToDS = [List create: habitatZone]; 
  habDownstreamLinksToUS = [List create: habitatZone];

  habUpstreamLinksToDS = [List create: habitatZone];
  habUpstreamLinksToUS = [List create: habitatZone];

  tempCellList = [List create: habitatZone];

  upstreamCells = [List create: habitatZone];
  downstreamCells = [List create: habitatZone];

  if(solarManager == nil)
  {
     fprintf(stderr, "ERROR: HabitatSpace >>>> buildObjects >>>> solarManager has not been set\n");
     fflush(0);
     exit(1);
  }

  cellFishList = [List create: habitatZone];

  return self;

} //buildObjects

////////////////////////////////////////////
//
// finishBuildObjects
//
////////////////////////////////////////////
- finishBuildObjects
{

   ageSymbolList = [modelSwarm getAgeSymbolList];
   speciesSymbolList = [modelSwarm getSpeciesSymbolList];

   scenario = [modelSwarm getScenario];
   replicate = [modelSwarm getReplicate];

   appendFiles = [modelSwarm getAppendFiles];

   return self;
}

///////////////////////////////////////////////////////////////
//
// setModel
//
//////////////////////////////////////////////////////////////
- setModel: (id <TroutModelSwarm>) aModelSwarm 
{
  modelSwarm = aModelSwarm;
  return self;
}


////////////////////////////////////////////////
//
// setSolarManager
//
////////////////////////////////////////////////
- setSolarManager: (id <SolarManager>) aSolarManager
{
   solarManager = aSolarManager;
   return self;
}

///////////////////////////////////////
//
// setNumberOfSpecies
//
//////////////////////////////////////
- setNumberOfSpecies: (int) aNumberOfSpecies
{
   numberOfSpecies = aNumberOfSpecies;
   return self;
}
////////////////////////////////////////////////////////////
//
// getModel
//
///////////////////////////////////////////////////////////
- getModel 
{
  return modelSwarm;
}


////////////////////////////////////////
//
// setReachName
//
///////////////////////////////////////
- setReachName: (char *) aReachName
{
   
   size_t strLength = strlen(aReachName); 

   if(reachName == NULL)
   {
       reachName = (char *) [habitatZone alloc: strLength * sizeof(char) + 1];
   }
   else
   {
       fprintf(stderr, "ERROR: HabitatSpace >>>> setReachName >>>> attempting to set reach name more than once\n");
       fflush(0);
       exit(1);
   }

   strncpy(reachName, aReachName, strLength + 1);

   return self;
}


////////////////////////////////////////////////
//
// setInstanceName
//
////////////////////////////////////////////////
- setInstanceName: (char *) anInstanceName
{
   size_t strLength = strlen(anInstanceName); 

   if(instanceName == NULL)
   {
       instanceName = (char *) [habitatZone alloc: strLength * sizeof(char) + 1];
   }
   else
   {
       fprintf(stderr, "ERROR: HabitatSpace >>>> setInstanceName >>>> attempting to set instance name more than once\n");
       fflush(0);
       exit(1);
   }

   strncpy(instanceName, anInstanceName, strLength + 1);

   return self;
}

////////////////////////////////////
//
// getReachName
//
////////////////////////////////////
- (char *) getReachName
{
    return reachName;
}


///////////////////////////////////////
//
// getInstanceName
//
//////////////////////////////////////
- (char *) getInstanceName
{
    if(instanceName == NULL)
    {
         fprintf(stderr, "ERROR: HabitatSpace >>>> getInstanceName >>>> instanceName is NULL\n");
         fflush(0);
         exit(1);
    }
    return instanceName;
}

//////////////////////////////
//
// setReachSymbol
//
/////////////////////////////
- setReachSymbol: (id <Symbol>) aReachSymbol
{
   reachSymbol = aReachSymbol;
   return self;
}

///////////////////////////////
//
// getReachSymbol
//
///////////////////////////////
- (id <Symbol>) getReachSymbol
{
    return reachSymbol;
}



////////////////////////////////////////////
//
////
//////          ADJACENT REACHES
////////
/////////
////////////////////////////////////////////

/////////////////////////////////////////////
//
// JUNCTION NUMBERS 
//
////////////////////////////////////////////

- setHabDStreamJNumber: (int) aJunctionNumber
{
    habDownstreamJunctionNumber = aJunctionNumber;

    return self;
}

- setHabUStreamJNumber: (int) aJunctionNumber
{
    habUpstreamJunctionNumber = aJunctionNumber;
    return self;
}

- (int) getHabDStreamJNumber
{
     return habDownstreamJunctionNumber;
}


- (int) getHabUStreamJNumber
{
     return habUpstreamJunctionNumber;
}




- setHabDownstreamLinksToDS: aDSLinkToDS
{

   [habDownstreamLinksToDS addLast: aDSLinkToDS];

   return self;
}


- setHabDownstreamLinksToUS: aDSLinkToUS
{

   [habDownstreamLinksToUS addLast: aDSLinkToUS];

   return self;
}


- setHabUpstreamLinksToDS: anUSLinkToDS
{

   [habUpstreamLinksToDS addLast: anUSLinkToDS];

   return self;
}


- setHabUpstreamLinksToUS: anUSLinkToUS
{

   [habUpstreamLinksToUS addLast: anUSLinkToUS];

   return self;
}


- (id <List>) getHabDownstreamLinksToDS
{
   return habDownstreamLinksToDS;
}


- (id <List>) getHabDownstreamLinksToUS
{
   return habDownstreamLinksToUS;
}


- (id <List>) getHabUpstreamLinksToDS
{
   return habUpstreamLinksToDS;
}


- (id <List>) getHabUpstreamLinksToUS
{
   return habUpstreamLinksToUS;
}


/////////////////////////////////////////////////////
//
// setTimeManager
//
/////////////////////////////////////////////////////
- setTimeManager: (id <TimeManager>) aTimeManager
{
      timeManager = aTimeManager;
      return self;
}


////////////////////////////////////////////////////
//
// setFishParamsMap
//
////////////////////////////////////////////////////
- setFishParamsMap: (id <Map>) aMap
{
    fishParamsMap = aMap;
    return self;
}



/////////////////////////////////////////
//
// set Input Files
//
////////////////////////////////////////
- setPolyCellGeomFile: (char*) aFile 
{
    strncpy(polyCellGeomFile, aFile, (size_t) 50);

    fprintf(stdout, "HabitatSpace >>>> setPolyCellGeomFile >>>> %s\n", aFile);
    fprintf(stdout, "HabitatSpace >>>> setPolyCellGeomFile >>>> %s\n", polyCellGeomFile);
    fflush(0);

    return self;
}


- setHydraulicFile: (char *) aFile
{
   strncpy(hydraulicFile, aFile, (size_t) 50);

   //fprintf(stdout, "HabitatSpace >>>> hydraulicFile = %s\n", hydraulicFile);
   //fflush(0);
   //exit(0);


   return self;
}
    

- setFlowFile: (char*) aFile 
{
   strncpy(flowFile, aFile, (size_t) 50);

   //fprintf(stdout, "HabitatSpace >>>> flowFile = %s\n", flowFile);
   //fflush(0);
   //exit(0);

   return self;
}

- setTemperatureFile: (char*) aFile 
{
    strncpy(temperatureFile, aFile, (size_t) 50);
    return self;
}


/////////////////////////////////////////////////////////////////
//
// setTurbidityFile
//
//////////////////////////////////////////////////////////////
- setTurbidityFile: (char*) aFile 
{
  strncpy(turbidityFile, aFile, (size_t) 50);
  return self;
}



///////////////////////////////////////////////////
//
// setCellHabVarsFile
//
//////////////////////////////////////////////////
- setCellHabVarsFile: (char *) aFile
{
  strncpy(cellHabVarsFile, aFile, (size_t) 50);
  return self;
}

///////////////////////////////////////////////
//
// createTimeSeriesInputManagers
//
///////////////////////////////////////////////
- createTimeSeriesInputManagers
{
   flowInputManager = [TimeSeriesInputManager  createBegin: habitatZone
                                              withDataType: "DAILY"
                                             withInputFile: flowFile
                                           withTimeManager: timeManager
                                             withStartTime: dataStartTime
                                               withEndTime: dataEndTime
                                             withCheckData: NO];

   flowInputManager = [flowInputManager createEnd];

 
   temperatureInputManager = [TimeSeriesInputManager  createBegin: habitatZone
                                                     withDataType: "DAILY"
                                                    withInputFile: temperatureFile
                                                  withTimeManager: timeManager
                                                    withStartTime: dataStartTime
                                                      withEndTime: dataEndTime
                                                    withCheckData: NO];

   temperatureInputManager = [temperatureInputManager createEnd];

   turbidityInputManager = [TimeSeriesInputManager  createBegin: habitatZone
                                                   withDataType: "DAILY"
                                                  withInputFile: turbidityFile
                                                withTimeManager: timeManager
                                                  withStartTime: dataStartTime
                                                    withEndTime: dataEndTime
                                                  withCheckData: NO];

    turbidityInputManager = [turbidityInputManager createEnd];

    return self;
}



////////////////////////////////////////////////////////////////
//
// setSpaceDimensions
// uses the geometry file to set the space dimensions
//
////////////////////////////////////////////////////////////
- setSpaceDimensions 
{
  return self;
}



////////////////////////////////////////////////////////
//
// getSpaceDimX and getSpaceDimY
//
//////////////////////////////////////////////////////
- (int) getSpaceDimX 
{
   return spaceDimX;
}

- (int) getSpaceDimY 
{
   return spaceDimY;
}


////////////////////////////////////////////////////////////////
//
// readGeometry
//
// Coordinates are converted from input in meters 
// to centimeters in this method
//
///////////////////////////////////////////////////////////////
- readGeometry 
{
 
  return self;
}


/////////////////////////////////////////////////////////////////////////////////
//
// calcSpaceVariables
//
/////////////////////////////////////////////////////////////////////////////////
- calcSpaceVariables 
{
  return self;
}


////////////////////////////////////////////////////
//
////       POLY CODE
//////
////////
//////////
/////////////////////////////////////////////////////


//////////////////////////////////////////////////////
//
// setPolyRasterResolution
//
/////////////////////////////////////////////////////
-   setPolyRasterResolutionX: (int) aPolyRasterResolutionX
    setPolyRasterResolutionY: (int) aPolyRasterResolutionY
      setRasterColorVariable: (char *) aRasterColorVariable
            setShadeColorMax: (double) aShadeColorMax
{
    polyRasterResolutionX = aPolyRasterResolutionX;
    polyRasterResolutionY = aPolyRasterResolutionY;

    if(aRasterColorVariable != NULL)
    {
       strncpy(polyRasterColorVariable, aRasterColorVariable, 25);
    }
   
    shadeColorMax = aShadeColorMax;

    return self;
}

/////////////////////////////////////////
//
// setShadeColorMax
//
//////////////////////////////////////////
- setShadeColorMax: (double) aShadeColorMax
{
  shadeColorMax = aShadeColorMax;
  
  fprintf(stdout, "HabitatSpace >>>> setShadeColorMax >>>> shadeColorMax = %f\n", shadeColorMax);
  fflush(0);

  return self;
}



//////////////////////////////////////////////////////
//
// setListOfPolyVelFiles
//
//////////////////////////////////////////////////////
- setListOfPolyInputData: (id <List>) aListOfPolyInputData
{
    listOfPolyInputData = aListOfPolyInputData;
    return self;
}



//////////////////////////////////////////////
//
// buildPolyCells
//
/////////////////////////////////////////////
- buildPolyCells
{
    // Do not remove this print statement; needed to catch bad input.
    fprintf(stdout, "HabitatSpace %s >>>> buildPolyCells >>>> BEGIN\n",reachName);
    fflush(0);

    polyCellList = [List create: habitatZone];
   
    [self read2DGeometryFile];
    [self createPolyAdjacentCells];
    [self calcPolyCellCentroids];
    [self createPolyInterpolationTables];
    [self setCellShadeColorMax];
    [self readPolyCellDataFile];
    [self calcPolyCellsDistFromRE];


    //[self outputCellCentroidRpt];
    //[self outputCellCorners];

  
    fprintf(stdout, "HabitatSpace >>>> buildPolyCells >>>> END\n");
    fflush(0);

    return self;
}


/////////////////////////////////////////////
//
// checkAdjacentReaches
// 
/////////////////////////////////////////////
- checkAdjacentReaches
{
    fprintf(stdout, "HabitatSpace >>>>reach = %s >>>>  checkAdjacentReaches >>>> BEGIN\n", reachName);
    fflush(0);

    xprint(habDownstreamLinksToDS);
    xprint(habDownstreamLinksToUS);

    xprint(habUpstreamLinksToDS);
    xprint(habUpstreamLinksToUS);

    fprintf(stdout, "HabitatSpace >>>> reach = %s >>>> checkAdjacentReaches >>>> habDownstreamJunctionNumber %d\n", reachName, habDownstreamJunctionNumber);
    fprintf(stdout, "HabitatSpace >>>> reach = %s >>>>  checkAdjacentReaches >>>> habUpstreamJunctionNumber %d\n", reachName, habUpstreamJunctionNumber);
    fflush(0);

    if([habDownstreamLinksToUS getCount] > 0)
    {
         id habDownstreamLinkToUS = [habDownstreamLinksToUS getFirst];
         fprintf(stdout, "HabitatSpace >>>> reach = %s >>>>  checkAdjacentReaches >>>> habDownstreamLinkToUS = %s\n", reachName, [habDownstreamLinkToUS getReachName]);
         fflush(0);
    }
    if([habUpstreamLinksToDS getCount] > 0)
    {
         id habUpstreamLinkToDS = [habUpstreamLinksToDS getFirst];
         fprintf(stdout, "HabitatSpace >>>> reach = %s >>>>  checkAdjacentReaches >>>> habUpstreamLinkToDS = %s\n", reachName, [habUpstreamLinkToDS getReachName]);
         fflush(0);
    }

    fprintf(stdout, "HabitatSpace >>>> reach = %s >>>> checkAdjacentReaches >>>> END\n", reachName);
    fflush(0);

    return self;
}



//////////////////////////////////////////////
//
// read2DGeometryFile
//
//////////////////////////////////////////////
- read2DGeometryFile
{
    //const char* dataFile = "cc3a_polys27sept.dat";
    FILE* dataFPTR = NULL;
    char inputString[300];
    BOOL isNewCell = NO;
    BOOL isDataValid = NO;
    id <ListIndex> polyCellNdx = nil;
    PolyCell* polyCell = (PolyCell *) nil;

    fprintf(stdout, "HabitatSpace >>>> read2DGeometryFile >>>> BEGIN\n");
    fflush(0);

    if((dataFPTR = fopen(polyCellGeomFile, "r")) == NULL)
    {
         fprintf(stderr, "ERROR: HabitatSpace >>>> read2DGeometryFile >>>> unable to open %s for reading\n", polyCellGeomFile);
         fflush(0);
         exit(1);
    }

    isNewCell = YES;
    isDataValid = YES;
    while(!feof(dataFPTR))
    {
          FishCell* newPolyCell = (FishCell *) nil;

          (void) fgets(inputString, 300, dataFPTR);

          if(strchr(inputString, '-') != NULL)
          { 
                 isNewCell = NO;
                 isDataValid = NO;
                 continue;
          }

          if(strncmp(inputString, "END", 3) == 0)
          { 
               isNewCell = YES;
               isDataValid = YES;
               continue;
          }

          if(isNewCell && isDataValid)
          {
              char sCellNumber[8];
              char sCentroidX[25];
              char sCentroidY[25];

              int cellNumber;

          
              newPolyCell = [FishCell create: habitatZone]; 
              [newPolyCell setSpace: self];
              [newPolyCell setReach: self];
              [newPolyCell setModel: modelSwarm];
              [newPolyCell setRandGen: randGen];
              [newPolyCell setNumberOfSpecies: numberOfSpecies];
              [newPolyCell setFishParamsMap: fishParamsMap];
              [newPolyCell setTimeManager: timeManager];
              [newPolyCell setHabShearParamA: habShearParamA
							  habShearParamB: habShearParamB];

              [newPolyCell buildObjects]; //fishCell needs to have objects built
              [polyCellList addLast: newPolyCell];
              isNewCell = NO;

              sscanf(inputString, "%s %s %s", sCellNumber, sCentroidX, sCentroidY);

              cellNumber = atoi(sCellNumber);

              //fprintf(stdout, "%s\n", sCellNumber);
              //fprintf(stdout, "%s\n", sCentroidX);
              //fprintf(stdout, "%s\n", sCentroidY);
              //fflush(0);

              [newPolyCell setPolyCellNumber: cellNumber]; 
         

              continue;
          }

          //
          // Now parse the data string if it is valid data
          //
          if(!isNewCell && isDataValid)
          {
                 newPolyCell = [polyCellList getLast];

                 //
                 // newPolyCell needs to know how much
                 // memeory to allocate for the coordinates
                 //
                 [newPolyCell incrementNumCoordinates: 1];
          }                              

    }

    fclose(dataFPTR);

    [polyCellList forEach: M(createPolyCoordinateArray)];
    
    //
    // reopen the file 
    //
    if((dataFPTR = fopen(polyCellGeomFile, "r")) == NULL)
    {
         fprintf(stderr, "ERROR: HabitatSpace >>>> read2DGeometryFile >>>> unable to open %s for reading\n", polyCellGeomFile);
         fflush(0);
         exit(1);
    }

    isNewCell = YES;
    isDataValid = YES;
    while(!feof(dataFPTR))
    {

          (void) fgets(inputString, 300, dataFPTR);

          if(strchr(inputString, '-') != NULL)
          { 
                 isNewCell = NO;
                 isDataValid = NO;
                 continue;
          }

          if(strncmp(inputString, "END", 3) == 0)
          { 
               isNewCell = YES;
               isDataValid = YES;
               continue;
          }

          if(isNewCell && isDataValid)
          {
              char sCellNumber[8];
              char sCentroidX[25];
              char sCentroidY[25];

              int cellNumber;
          
              if(polyCellNdx == nil)
              {
                   polyCellNdx = [polyCellList listBegin: scratchZone];
              }

              sscanf(inputString, "%s %s %s", sCellNumber, sCentroidX, sCentroidY);

              cellNumber = atoi(sCellNumber);

              [polyCellNdx setLoc: Start];
              while(([polyCellNdx getLoc] != End) && ((polyCell = [polyCellNdx next]) != nil))
              {
                    if([polyCell getPolyCellNumber]  == cellNumber)
                    {
                          id <ListIndex>  chckDupPolyCellNdx = [polyCellList listBegin: scratchZone];
                          FishCell* aFishCell = nil;
 
                          while(([chckDupPolyCellNdx getLoc] != End) && ((aFishCell = [chckDupPolyCellNdx next]) != nil))
                          {
                               if(aFishCell != polyCell)
                               {
                                    if([aFishCell getPolyCellNumber] == cellNumber)
                                    {
                                          fprintf(stderr, "ERROR: HabitatSpace >>>> read2DGeometryFile >>>> duplicate polyCellNumber = %d\n", cellNumber);
                                          fflush(0);
                                          exit(1);
                                    }
                               }        
                          }
                          [chckDupPolyCellNdx drop];
                          chckDupPolyCellNdx  = nil;

                          break;
                    }
              }
              

              isNewCell = NO;
              continue;
          }

          //
          // Now parse the data string if it is valid data
          //
          if(!isNewCell && isDataValid)
          {
                 char sCoordX[25]; 
                 char sCoordY[25]; 

                 double coordX;
                 double coordY;

                 sscanf(inputString, "%s %s", sCoordX, sCoordY);

                 coordX = atof(sCoordX);
                 coordY = atof(sCoordY);

                 [polyCell  setPolyCoordsWith: coordX
                                          and: coordY];

          }                              

    }



    [polyCellNdx drop];

    [polyCellList forEach: M(createPolyPoints)]; 

    if((polyRasterResolutionX <= 0) || (polyRasterResolutionY <= 0))
    {
        fprintf(stdout, "ERROR: HabitatSpace >>>> createPolyCells >>>> a rasterResolution variable is negative\n");
        fflush(0);
        exit(1);
    }
    //
    // We need to find the min x- and y- coordinates also the max
    //
    {
          minXCoordinate = (long int) 1E10;
          minYCoordinate = (long int) 1E10;
          maxXCoordinate = -1;  // The polyPoints should have positive coordinates. 
          maxYCoordinate = -1;

          id <ListIndex> ndx = [polyCellList listBegin: scratchZone];

          while(([ndx getLoc] != End) && ((polyCell = [ndx next]) != nil))
          {
              id <List> polyPointList = nil;

              //
              // set the raster variables
              //
              [polyCell setPolyRasterResolutionX: polyRasterResolutionX];
              [polyCell setPolyRasterResolutionY: polyRasterResolutionY];


              if((polyPointList = [polyCell getPolyPointList]) == nil)
              {
                   fprintf(stderr, "HabitatSpace >>> read2DGeometry >>>> nil polyPointList\n");
                   fflush(0);
                   exit(1);
              }
              else
              { 
                  id <ListIndex> ppNdx = [polyPointList listBegin: scratchZone];
                  PolyPoint* polyPoint = nil;
                  
                  while(([ppNdx getLoc] != End) && ((polyPoint = [ppNdx next]) != nil))
                  {
                      double intXCoord = [polyPoint getIntX];
                      double intYCoord = [polyPoint getIntY];

                      minXCoordinate = (minXCoordinate < intXCoord) ? minXCoordinate : intXCoord;
                      minYCoordinate = (minYCoordinate < intYCoord) ? minYCoordinate : intYCoord;

                      maxXCoordinate = (maxXCoordinate > intXCoord) ? maxXCoordinate : intXCoord;
                      maxYCoordinate = (maxYCoordinate > intYCoord) ? maxYCoordinate : intYCoord;
                  }

                  [ppNdx drop];
                  ppNdx = nil;

              } //else
            
           } // while

           //fprintf(stdout, "HabitatSpace >>> read2DGeometry >>>> polyRasterResolution = %ld\n", polyRasterResolution);
           //fprintf(stdout, "HabitatSpace >>> read2DGeometry >>>> polyRasterResolutionX = %ld\n", polyRasterResolutionX);
           //fprintf(stdout, "HabitatSpace >>> read2DGeometry >>>> polyRasterResolutionY = %ld\n", polyRasterResolutionY);
           //fprintf(stdout, "HabitatSpace >>> read2DGeometry >>>> aMinXCoordinate = %ld\n", minXCoordinate);
           //fprintf(stdout, "HabitatSpace >>> read2DGeometry >>>> aMinYCoordinate = %ld\n", minYCoordinate);
           //fprintf(stdout, "HabitatSpace >>> read2DGeometry >>>> aMaxXCoordinate = %ld\n", maxXCoordinate);
           //fprintf(stdout, "HabitatSpace >>> read2DGeometry >>>> aMaxYCoordinate = %ld\n", maxYCoordinate);
           //fflush(0);

           [ndx setLoc: Start];
           while(([ndx getLoc] != End) && ((polyCell = [ndx next]) != nil))
           {
               id <List> polyPointList = [polyCell getPolyPointList];
               id <ListIndex> ppNdx = [polyPointList listBegin: scratchZone];
               PolyPoint* polyPoint = nil;

               [polyCell setMinXCoordinate: minXCoordinate];
               [polyCell setMaxYCoordinate: maxYCoordinate];

               while(([ppNdx getLoc] != End) && ((polyPoint = [ppNdx next]) != nil))
               {
                   [polyPoint setRasterResolutionX: polyRasterResolutionX];
                   [polyPoint setRasterResolutionY: polyRasterResolutionY];

                   [polyPoint calcDisplayXWithMinX: minXCoordinate];
                   [polyPoint calcDisplayYWithMaxY: maxYCoordinate];
               }
           } 
           [ndx setLoc: Start];
           while(([ndx getLoc] != End) && ((polyCell = [ndx next]) != nil))
           {
                [polyCell setRasterColorVariable: polyRasterColorVariable];   
           }
           [ndx drop];

           polySpaceSizeX = (unsigned int) (maxXCoordinate - minXCoordinate) + 0.5;
           polySpaceSizeY = (unsigned int) (maxYCoordinate - minYCoordinate) + 0.5;
       
           polyPixelsX = polySpaceSizeX;
           polyPixelsY = polySpaceSizeY;

           spaceDimX = polySpaceSizeX;
           spaceDimY = polySpaceSizeY;

           //fprintf(stdout, "HabitatSpace >>> read2DGeometry >>>> aMinXCoordinate = %ld\n", minXCoordinate);
           //fprintf(stdout, "HabitatSpace >>> read2DGeometry >>>> aMinYCoordinate = %ld\n", minYCoordinate);
           //fprintf(stdout, "HabitatSpace >>> read2DGeometry >>>> aMaxXCoordinate = %ld\n", maxXCoordinate);
           //fprintf(stdout, "HabitatSpace >>> read2DGeometry >>>> aMaxYCoordinate = %ld\n", maxYCoordinate);
           //fprintf(stdout, "HabitatSpace >>> read2DGeometry >>>> polySpaceSizeX = %ld\n", (long int) polySpaceSizeX);
           //fprintf(stdout, "HabitatSpace >>> read2DGeometry >>>> polySpaceSizeY = %ld\n", (long int) polySpaceSizeY);
           //fflush(0);
    }


    [polyCellList forEach: M(createPolyCellPixels)];

    //
    // Do not drop the following list index
    //
    polyCellListNdx = [polyCellList listBegin: habitatZone];


    fclose(dataFPTR);
    fprintf(stdout, "HabitatSpace >>>> read2DGeometry >>>> END\n");
    fflush(0);
    //exit(0);

    return self;
}


///////////////////////////////////////////
//
// scrubString
//
// This function returns copy of toScrub allocated to aZone where any characters in ignoredCharacters are 
// removed.
// 
// Example usage:
//  token = [HabitatSpace scrubString: strtok(inputString,delimiters) withZone: scratchZone withIgnoredCharacters: ignoredCharacters];
//
///////////////////////////////////////////
+ (char *) scrubString: (char *) toScrub withZone: (id) aZone withIgnoredCharacters: (char *) ignoredCharacters {
  char * cleanedString = (char *) [(id <Zone>)aZone alloc: sizeof(toScrub)];
  char * foundSubstr;
  char aChar;
  int toScrubNdx=0,cleanedNdx = 0;

  if(toScrub==NULL)return NULL;
  while((aChar=toScrub[toScrubNdx++])!='\0'){
    //fprintf(stdout, "HabitatSpace >>>> scrubString >>>> %c == %s ???\n",aChar,ignoredCharacters);
    //fflush(0);
    foundSubstr = strstr(&(aChar),ignoredCharacters);
    if(foundSubstr==NULL){
      cleanedString[cleanedNdx++] = aChar;
    }
  }
  return cleanedString;
}

///////////////////////////////////////////
//
// unQuote
//
// This function alters the string argument if the string has double quotes at the front and end, 
// the double quotes are removed.
//
///////////////////////////////////////////
+ (void) unQuote: (char *) toScrub {
  int i;

  if(toScrub==NULL)return;
  if(toScrub[0]=='"' && toScrub[strlen(toScrub)-1] == '"'){
    for(i=1;i<=strlen(toScrub)-2;i++){
      toScrub[i-1] = toScrub[i];
    }
    toScrub[i-1] = '\0';
  }
  return;
}

///////////////////////////////////////////
//
// createPolyInterpolationTables;
//
///////////////////////////////////////////
- createPolyInterpolationTables {
  FILE* dataPtr = NULL;
  int strArraySize = 1501;
  char inputString[strArraySize];
  char delimiters[5] = " \t\n,";
  char * token;
  int numFlowsInFile=0,flowDataPos,polyID,flowNdx;
  double * flows;
  double depth,velocity;
  id <InterpolationTable> depthInterpolator = nil,velocityInterpolator = nil;
  FishCell* polyCell = nil;
  
  fprintf(stdout, "HabitatSpace >>>> createPolyInterpolationTables >>>> BEGIN\n");
  fflush(0);
  if((dataPtr = fopen(hydraulicFile, "r")) == NULL){
    fprintf(stderr, "ERROR: HabitatSpace >>>> createPolyInterpolationTables >>>> unable to open %s for reading\n", hydraulicFile);
    fflush(0);
    exit(1);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // First count the number of flows in the hydraulic file
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  (void) fgets(inputString, strArraySize, dataPtr);  // header line 1 skipped
  (void) fgets(inputString, strArraySize, dataPtr);  // header line 2 skipped
  flowDataPos = ftell(dataPtr);			     // save position of flow data for rewind later
  (void) fgets(inputString, strArraySize, dataPtr);  // read line with flow data

  // Throw fit if first token of this line is not one of the following (case insensitive) flows|flow|flows:|flow:
  token =  strtok(inputString,delimiters);
  [HabitatSpace unQuote: token];
  if(!isalpha(token[0]) || 
      !(toupper(token[0])=='F' &&
	toupper(token[1])=='L' &&
	toupper(token[2])=='O' &&
	toupper(token[3])=='W')){
    fprintf(stderr, "ERROR: HabitatSpace >>>> createPolyInterpolationTables >>>> Unrecognized token \"%s\" on line 3 of Hydraulic File: %s \n", token,hydraulicFile);
    fflush(0);
    exit(1);
  }
  token =  strtok(NULL,delimiters);
  [HabitatSpace unQuote: token];
  while(token != NULL){
    numFlowsInFile++;
    token =  strtok(NULL,delimiters);
    [HabitatSpace unQuote: token];
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Now allocate and fill the double array to store the flow values, check along the way to ensure flows are in order of increasing magnitude
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  flows = (double *) [habitatZone alloc: numFlowsInFile*sizeof(double)];
  fseek(dataPtr,flowDataPos,SEEK_SET);		    // rewind to read flow data again
  (void) fgets(inputString, strArraySize, dataPtr); // read line with flow data
  token = strtok(inputString,delimiters);
  token = strtok(NULL,delimiters);
  flowNdx = 0;
  while(token != NULL){
    [HabitatSpace unQuote: token];
    flows[flowNdx++] = atof(token);
    if(flowNdx>1 && flows[flowNdx-1]<flows[flowNdx-2]){
      fprintf(stderr, "ERROR: HabitatSpace >>>> createPolyInterpolationTables >>>> Flows not in order of increasing magnitude, first offending values are: %f, %f \n", flows[flowNdx-2],flows[flowNdx-1]);
      fflush(0);
      exit(1);
    }
    token = strtok(NULL,delimiters);
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Now start reading the hydraulic data, inserting into interpolation tables associated with the appropriate cell
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  (void) fgets(inputString, strArraySize, dataPtr); // skip line with column names 
  while(feof(dataPtr) == 0){
    inputString[0] = '\0';
    (void) fgets(inputString, strArraySize, dataPtr); 
    if((token =  strtok(inputString,delimiters))==NULL) continue;
    [HabitatSpace unQuote: token];
    // Find the poly cell associated with the first token
    polyID = atoi(token);
    if(polyID<=0){ // atoi returns 0 if it cannot parse the string to an integer and non-positive values are also illegal
      fprintf(stderr, "ERROR: HabitatSpace >>>> createPolyInterpolationTables >>>> Illegal poly-id specified: %s \n", token); fflush(0); exit(1);
    }
    //fprintf(stdout, "polyId = %d\n", polyID);
    //fflush(0);
    polyCell = nil;
    polyCell = [self getCellWithCellNum: polyID];
    if(polyCell == nil){
      fprintf(stderr, "ERROR: HabitatSpace >>>> reachName >>>> %s >>>> createPolyInterpolationTables >>>> no cell with polyID %d\n",reachName, polyID);
      fflush(0);
      exit(1);
    }

    // Initialize counters and interpolators
    flowNdx = 0;
    depthInterpolator    = [InterpolationTable create: habitatZone];
    velocityInterpolator = [InterpolationTable create: habitatZone];
    [velocityInterpolator addX: 0.0 Y: 0.0];

    [polyCell setDepthInterpolator: depthInterpolator];
    [polyCell setVelocityInterpolator: velocityInterpolator];

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Read the depth and velocity values, checking to make sure we haven't hit the end of the line and reacting appropriately if a 
    // negative or illegal value is found
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    while(flowNdx<numFlowsInFile){
      token = strtok(NULL,delimiters);
      [HabitatSpace unQuote: token];
      if(token==NULL){
	fprintf(stderr, "ERROR: HabitatSpace >>>> createPolyInterpolationTables >>>> Expected a depth value, found end of line for cell %d in file: %s, this is due to a mismatch between the number of flows and the number of depth/velocity values for this cell in the hydraulic file.\n", polyID,hydraulicFile); fflush(0); exit(1);
      }else if(token[0]=='\0'){
	continue;
      }
      depth = atof(token);
      if(depth<0.0)depth=0.0;

      [depthInterpolator addX: flows[flowNdx]
			 Y: 100.0*depth];
      token = strtok(NULL,delimiters);
      [HabitatSpace unQuote: token];
      if(token==NULL){
	fprintf(stderr, "ERROR: HabitatSpace >>>> createPolyInterpolationTables >>>> Expected a velocity value, found end of line for cell %d in file: %s, this is due to a mismatch between the number of flows and the number of depth/velocity values for this cell in the hydraulic file. \n", polyID, hydraulicFile); fflush(0); exit(1);
      }
      velocity = atof(token);
      if(velocity<0.0){
	fprintf(stderr, "ERROR: HabitatSpace >>>> createPolyInterpolationTables >>>> Illegal velocity value, %f, for cell %d in file: %s \n", velocity,polyID, hydraulicFile); fflush(0); exit(1);
      }	
      [velocityInterpolator addX: flows[flowNdx]
			 Y: 100.0*velocity];
      flowNdx++;
    }
    
    // Check to make sure there aren't any other data on the line
    if((token = strtok(NULL,delimiters))!=NULL){
	fprintf(stderr, "ERROR: HabitatSpace >>>> createPolyInterpolationTables >>>> Expected end of line, found data \"%s\" for cell %d in file: %s, this is due to a mismatch between the number of flows and the number of depth/velocity values for this cell in the hydraulic file.\n",token, polyID, hydraulicFile); fflush(0); exit(1);
    }
  }
    
  [polyCellList forEach: M(checkVelocityInterpolator)];
  [polyCellList forEach: M(checkDepthInterpolator)];

  fprintf(stdout, "HabitatSpace >>>> createPolyInterpolationTables >>>> END\n");
  fflush(0);
  fclose(dataPtr);

  return self;

}

//////////////////////////////////////////////////////////
//
// setCellShadeColorMax
//
/////////////////////////////////////////////////////////
- setCellShadeColorMax
{
     id <ListIndex> ndx = [polyCellList listBegin: scratchZone];
     FishCell* fishCell = nil;
 
     if(fabs(shadeColorMax) <= 0.000000001)
     {
         fprintf(stderr, "ERROR: HabitatSpace >>>> setCellShadeColorMax >>>> shadeColorMax is 0.0\n");
         fflush(0);
         exit(1);
     }

     while(([ndx getLoc] != End) && ((fishCell = [ndx next]) != nil))
     {
             [fishCell setShadeColorMax: shadeColorMax];
     }
 
     [ndx drop];
     ndx = nil;

     return self;
}
//////////////////////////////////////////////////////////
//
// getCellForNewFishWithCellNum
//
///////////////////////////////////////////////////////////
/*   No longer used because it incorrectly assumes cell numbers are sequential starting with zero
- (FishCell *) getCellForNewFishWithCellNum: (int) aCellNum
{
     FishCell* fishCell = nil;
     id <ListIndex> ndx = nil;

     // fprintf(stdout, "HabitatSpace >>>> getCellForNewFishWithCellNum >>>> BEGIN\n");
     // fflush(0);

     ndx = [polyCellList listBegin: scratchZone];

     // fprintf(stdout, "HabitatSpace >>>> getCellForNewFishWithCellNum >>>> aCellNum = %d\n", aCellNum);
     // fflush(0);

     while([ndx getLoc] != End && ((fishCell = [ndx next]) != nil))
     {
              if([fishCell getPolyCellNumber] == aCellNum)
              {
                    break;
              }

              fishCell = nil;

     }

     [ndx drop];

     // fprintf(stdout, "HabitatSpace >>>> getCellForNewFishWithCellNum >>>> END\n");
     // fflush(0);


     return fishCell;
}
*/

///////////////////////////////////////////////////
//
// getCellWithCellNum
//
//////////////////////////////////////////////////
- (FishCell *) getCellWithCellNum: (int) aCellNum{
  FishCell* fishCell = nil;
  id <ListIndex> ndx = nil;

  //fprintf(stdout, "HabitatSpace >>>> getCellWithCellNum >>>> BEGIN\n");
  //fflush(0);

  ndx = [polyCellList listBegin: scratchZone];
  while([ndx getLoc] != End && ((fishCell = [ndx next]) != nil)){
    if([fishCell getPolyCellNumber] == aCellNum)break;
    fishCell = nil;
  }
  [ndx drop];

  //fprintf(stdout, "HabitatSpace >>>> getCellWithCellNum >>>> END\n");
  //fflush(0);

  return fishCell;
}

////////////////////////////////
//
// calcPolyCellCentroids
//
////////////////////////////////
- calcPolyCellCentroids
{
    fprintf(stdout, "HabitatSpace >>>> calcPolyCellCentroids >>>> BEGIN\n");
    fflush(0);

    [polyCellList forEach: M(calcPolyCellCentroid)];

    fprintf(stdout, "HabitatSpace >>>> calcPolyCellCentroids >>>> END\n");
    fflush(0);

    return self;
}


///////////////////////////////////////
//
// createPolyAdjacentCells
//
//////////////////////////////////////
- createPolyAdjacentCells
{
    fprintf(stdout, "HabitatSpace >>>> createPolyAdjacentCells >>>> BEGIN\n");
    fflush(0);

    id <ListIndex> ndx = [polyCellList listBegin: scratchZone];

    [polyCellList forEach: M(createPolyAdjacentCellsFrom:) :ndx];

    fprintf(stdout, "HabitatSpace >>>> createPolyAdjacentCells >>>> END\n");
    fflush(0);

    [ndx drop];

    return self;
}



//////////////////////////////////
//
// readPolyCellDataFile
//
/////////////////////////////////
- readPolyCellDataFile{
    int cellNo = 0;
    double fracShelter = 0.0;
    double distToHide = 0.0;
    double fracSpawn = 0.0;
    char reachEnd = 'K';
    FishCell* aCell = nil;
    char inputString[200];
    BOOL csvFormat = FALSE;

    FILE* polyDataFPTR = NULL;
    fprintf(stdout, "HabitatSpace >>>> readPolyCellDataFile >>>> BEGIN\n");
    fflush(0);

    if((polyDataFPTR = fopen(cellHabVarsFile, "r")) == NULL){
         fprintf(stderr, "ERROR: HabitatSpace >>>> readPolyCellDataFile >>>> unable to open %s for reading\n", cellHabVarsFile);
         fflush(0);
         exit(1);
    }
    
    if(polyCellListNdx == nil){
         fprintf(stderr, "ERROR: HabitatSpace >>>> readPolyCellDataFile >>>> utmCellListNdx is nil\n");
         fflush(0);
         exit(1);
    }

    //
    // Read in the data
    //
    fgets(inputString,200,polyDataFPTR);
    fgets(inputString,200,polyDataFPTR);
    fgets(inputString,200,polyDataFPTR);
    
    // Test for csv format
    fgets(inputString,200,polyDataFPTR);
    if(strchr(inputString,',')!=NULL)csvFormat=TRUE;
    rewind(polyDataFPTR);
    fgets(inputString,200,polyDataFPTR);
    fgets(inputString,200,polyDataFPTR);
    fgets(inputString,200,polyDataFPTR);

    while(fgets(inputString,200,polyDataFPTR) != NULL){
      if(csvFormat){
       sscanf(inputString, "%d,%lf,%lf,%lf,%c", &cellNo,
                                                &fracShelter,
                                                &distToHide,
                                                &fracSpawn,
                                                &reachEnd);
      }else{
       sscanf(inputString, "%d %lf %lf %lf %c", &cellNo,
                                                &fracShelter,
                                                &distToHide,
                                                &fracSpawn,
                                                &reachEnd);
      }


       
       //fprintf(stdout, "HabitatSpace >>>> reachName = %s >>>> readPolyCellDataFile >>>> %d %f %f %f %c\n", reachName,
                                                                                       //cellNo,
                                                                                       //fracShelter,
                                                                                       //distToHide,
                                                                                       //fracSpawn,
                                                                                       //reachEnd);

       



  
       [polyCellListNdx setLoc: Start];

       while(([polyCellListNdx getLoc] != End) && ((aCell = [polyCellListNdx next]) != nil))
       {
            if([aCell getPolyCellNumber] == cellNo)
            {
               [aCell setCellFracShelter: fracShelter];
               [aCell setDistanceToHide: (distToHide * 100)];  // Convert from meters to centimeters
               [aCell setCellFracSpawn: fracSpawn];
               [aCell calcMaxAvailGravelArea];
               //[aCell calcCellAvailableGravelArea];
               [aCell setReachEnd: toupper(reachEnd)];
               [aCell setCellDataSet: YES];

               [aCell calcCellShelterArea];

               if(reachEnd == 'U')
               {
                    [upstreamCells addLast: aCell];
               }
               else if(reachEnd == 'D')
               {
                    [downstreamCells addLast: aCell];
               }

               break;
            }
       }
    }
          
    //
    // When done ...
    //
    
    fclose(polyDataFPTR);

    [polyCellListNdx setLoc: Start];

    while(([polyCellListNdx getLoc] != End) && ((aCell = [polyCellListNdx next]) != nil))
    {
         [aCell checkCellDataSet];
    }

    //
    // Do not drop polyCellListNdx
    //

    fprintf(stdout, "HabitatSpace >>>> readPolyCellDataFile >>>> END\n");
    fflush(0);

    return self;
}


/////////////////////////////////////////////
//
// calcPolyCellsDistFromRE 
//
/////////////////////////////////////////////
- calcPolyCellsDistFromRE 
{

    [polyCellList  forEach: M(calcCellDistToUS)];
    [polyCellList  forEach: M(calcCellDistToDS)];

    return self;
}



///////////////////////////////////////////////
//
// checkCellsForCellDepth
//
// Remove when done.
//
////////////////////////////////////////////
- checkCellsForCellDepth
{
    id <ListIndex> ndx = [polyCellList listBegin: scratchZone];
    id polyCell = nil;
    while(([ndx getLoc] != End) && ((polyCell = [ndx next]) != nil))
    {
           fprintf(stdout, "HabitatSpace >>>> checkCellsForCellDepth >>>> riverFlow = %f >>>> depth = %f \n", riverFlow, [polyCell getPolyCellDepth]);
           fflush(0);
    }

    [ndx drop];
    ndx = nil;
 
    //exit(0);

    return self;
}

///////////////////////////////////////////////
//
// checkCellsForCellVelocity
//
// Remove when done.
//
////////////////////////////////////////////
- checkCellsForCellVelocity
{
    id <ListIndex> ndx = [polyCellList listBegin: scratchZone];
    id polyCell = nil;
    while(([ndx getLoc] != End) && ((polyCell = [ndx next]) != nil))
    {
           fprintf(stdout, "HabitatSpace >>>> checkCellsForCellVelocity >>>> riverFlow = %f >>>>> velocity = %f \n", riverFlow, [polyCell getPolyCellVelocity]);
           fflush(0);
    }

    [ndx drop];
    ndx = nil;
 
    //exit(0);

    return self;
}


/////////////////////////////////////////////
//
// outputCellCentroidRpt
//
/////////////////////////////////////////////
- outputCellCentroidRpt
{
    /*
    if(0)
    {
    FILE* fptr = NULL;
    const char* fileName = "CellCentroids.rpt";
    id <ListIndex> ndx = nil;
    FishCell* fishCell = nil;

    const char* headerFmt = "%-14s%-24s%-24s\n";
    const char* dataFmt = "%-14d%-24f%-24f\n";

    fprintf(stdout, "HabitatSpace >>>> outputCellCentroidRpt >>>> BEGIN\n");
    fflush(0);

    if((fptr = fopen(fileName, "w")) == NULL)
    {
        fprintf(stdout, "ERROR: HabitatSpace >>>> outputCellCentroidRpt >>>> Unable to open file %s for writing\n", fileName);
        fflush(0);
        exit(1);
    } 

    ndx = [utmCellList listBegin: scratchZone];

    fprintf(fptr, "Cell centroid UTM coordinates for reachName: %s System date and time: %s\n\n", reachName, [timeManager getSystemDateAndTime]); 
    fprintf(fptr, headerFmt, "CellNumber", "CentroidX", "CentroidY"); 
    fflush(fptr);

    while(([ndx getLoc] != End) && ((fishCell = [ndx next]) != nil))
    {
        int utmCellNumber = [fishCell getPolyCellNumber];
        double utmCenterX = [fishCell getPolyCenterX]/100.0;
        double utmCenterY = [fishCell getPolyCenterY]/100.0;

        fprintf(fptr, dataFmt, utmCellNumber,
                               utmCenterX,
                               utmCenterY);
        fflush(fptr);
    }

    fclose(fptr);
    [ndx drop];

    }
    */
    fprintf(stdout, "HabitatSpace >>>> outputCellCentroidRpt >>>> END\n");
    fflush(0);
    return self;
}

/////////////////////////////////////////////
//
// outputCellCornersRpt
//
/////////////////////////////////////////////
- outputCellCorners
{
    return self;
}
/*
/////////////////////////////////////////////
//
// outputCellCornersRpt
//
/////////////////////////////////////////////
- outputCellCorners
{
    FILE* fptr = NULL;
    const char* fileName = "CellCorners.rpt";
    id <ListIndex> ndx = nil;
    FishCell* fishCell = nil;

    const char* headerFmt = "%-14s%-24s%-24s%-24s%-24s%-24s%-24s%-24s%-24s\n";
    const char* dataFmt = "%-14d%-24f%-24f%-24f%-24f%-24f%-24f%-24f%-24f\n";

    fprintf(stdout, "HabitatSpace >>>> outputCellCorners >>>> BEGIN\n");
    fflush(0);

    if((fptr = fopen(fileName, "w")) == NULL)
    {
        fprintf(stdout, "ERROR: HabitatSpace >>>> outputCellCorners >>>> Unable to open file %s for writing\n", fileName);
        fflush(0);
        exit(1);
    } 

    ndx = [utmCellList listBegin: scratchZone];

    fprintf(fptr, "Cell corner UTM coordinates for reachName: %s System date and time: %s\n\n", reachName, [timeManager getSystemDateAndTime]); 
    fprintf(fptr, headerFmt, "CellNumber", "Corner1X", "Corner1Y", "Corner2X", "Corner2Y", "Corner3X", "Corner3Y", "Corner4X", "Corner4Y");
    fflush(fptr);

    while(([ndx getLoc] != End) && ((fishCell = [ndx next]) != nil))
    {
        int utmCellNumber = [fishCell getUTMCellNumber];
        double corner1UTMEasting = [fishCell getCorner1UTMEasting]/100.0;
        double corner1UTMNorthing = [fishCell getCorner1UTMNorthing]/100.0;
        double corner2UTMEasting = [fishCell getCorner2UTMEasting]/100.0;
        double corner2UTMNorthing = [fishCell getCorner2UTMNorthing]/100.0;
        double corner3UTMEasting = [fishCell getCorner3UTMEasting]/100.0;
        double corner3UTMNorthing = [fishCell getCorner3UTMNorthing]/100.0;
        double corner4UTMEasting = [fishCell getCorner4UTMEasting]/100.0;
        double corner4UTMNorthing = [fishCell getCorner4UTMNorthing]/100.0;

        fprintf(fptr, dataFmt, utmCellNumber,
                               corner1UTMEasting,
                               corner1UTMNorthing,
                               corner2UTMEasting,
                               corner2UTMNorthing,
                               corner3UTMEasting,
                               corner3UTMNorthing,
                               corner4UTMEasting,
                               corner4UTMNorthing);
        fflush(fptr);
    }

    fclose(fptr);
    [ndx drop];

    fprintf(stdout, "HabitatSpace >>>> outputCellCorners >>>> END\n");
    fflush(0);

    return self;
}
*/





///////////////////////////////////////////////////////////////////////////
//
// probePolyCellAtX:Y
//
//////////////////////////////////////////////////////////////////////////
#import <simtoolsgui.h>
- probePolyCellAtX: (int) probedX Y: (int) probedY 
{
  id <ListIndex> lstNdx = nil;
  id polyCell=nil;

  fprintf(stdout, "HabitatSpace >>>> probePolyCellAtX:Y >>>> BEGIN\n");
  fprintf(stdout, "HabitatSpace >>>> probePolyCellAtX:Y >>>> probedX = %d\n", probedX);
  fprintf(stdout, "HabitatSpace >>>> probePolyCellAtX:Y >>>> probedY = %d\n", probedY);
  fflush(0);


  lstNdx = [polyCellList listBegin: scratchZone];

  while(([lstNdx getLoc] != End) && ((polyCell = [lstNdx next]) != nil))
  {
        if([polyCell containsRasterX: probedX 
                         andRasterY: probedY])
        {
             break;
        }
  }

  [lstNdx drop];

  if(polyCell != nil)
  {
      CREATE_ARCHIVED_PROBE_DISPLAY (polyCell);
  }

  if(polyCell != nil)
  {
      fprintf(stdout, "HabitatSpace >>>> probePolyCellAtX:Y >>>> polyCellNumber = %d\n", [polyCell getPolyCellNumber]);
      fflush(0);
  }
  else
  {
      fprintf(stdout, "HabitatSpace >>>> probePolyCellAtX:Y >>>> polyCell = %p\n", polyCell);
      fflush(0);
  }
  fprintf(stdout, "HabitatSpace >>>> probePolyCellAtX:Y >>>> END\n");
  fflush(0);

  return self;
}


///////////////////////////////////////////////////////////////////////////
//
// getFishCellAtX:Y
//
//////////////////////////////////////////////////////////////////////////
#import <simtoolsgui.h>
- (FishCell *) getFishCellAtX: (int) probedX Y: (int) probedY 
{
  id <ListIndex> lstNdx = nil;
  FishCell* fishCell=nil;

  //fprintf(stdout, "HabitatSpace >>>> getFishCellAtX:Y >>>> BEGIN\n");
  //fflush(0);

  lstNdx = [polyCellList listBegin: scratchZone];

  while(([lstNdx getLoc] != End) && ((fishCell = [lstNdx next]) != nil))
  {
        if([fishCell containsRasterX: probedX 
                          andRasterY: probedY])
        {
             break;
        }
  }

  [lstNdx drop];

  //fprintf(stdout, "HabitatSpace >>>> getFishCellAtX:Y >>>> END\n");
  //fflush(0);

  return fishCell;
}

////////////////////////////////////////////////
//
// probeFishAtX
//
////////////////////////////////////////////////
- probeFishAtX: (int) probedX Y: (int) probedY 
{
  FishCell*  fishCell = nil;
  Trout* fish = nil;
  TroutRedd* redd = nil;
  id <ListIndex> fishNdx = nil;
  id <ListIndex> reddNdx = nil;

   //
   // get the fishCell
   //
   fishCell = [self getFishCellAtX: probedX Y: probedY];

   if(fishCell != nil)
   {
       fishNdx = [[fishCell getFishIContain] listBegin: scratchZone];
       while(([fishNdx getLoc] != End) && ((fish = [fishNdx next]) != nil)) 
       {
         //
         // At this time this will create a a probe display for each fish in the Cell
         //
         CREATE_PROBE_DISPLAY(fish);
      }

      [fishNdx drop];

      reddNdx = [[fishCell getReddsIContain] listBegin: scratchZone];
      while(([reddNdx getLoc] != End) && ((redd = [reddNdx next]) != nil)) 
      {
         //
         // At this time this will create a a probe display for each redd in the Cell
         //
         CREATE_PROBE_DISPLAY(redd);
      }

      [reddNdx drop];
  }

  return self;
}


//////////////////////////////////////////////////
//
// tagUpstreamLinksToDSCells
//
//////////////////////////////////////////////////
- tagUpstreamLinksToDSCells
{
    if([habUpstreamLinksToDS getCount] > 0)
    {
       [habUpstreamLinksToDS forEach: M(tagDownstreamCells)];
    }
    return self;
}
//////////////////////////////////////////////////
//
// tagUpstreamLinksToUSCells
//
//////////////////////////////////////////////////
- tagUpstreamLinksToUSCells
{
    if([habUpstreamLinksToUS getCount] > 0)
    {
       [habUpstreamLinksToUS forEach: M(tagUpstreamCells)];
    }
    return self;
}
//////////////////////////////////////////////////
//
// tagDownstreamLinksToDSCells
//
//////////////////////////////////////////////////
- tagDownstreamLinksToUSCells
{
    if([habDownstreamLinksToUS getCount] > 0)
    {
       [habDownstreamLinksToUS forEach: M(tagUpstreamCells)];
    }
    return self;
}
//////////////////////////////////////////////////
//
// tagDownstreamLinksToDSCells
//
//////////////////////////////////////////////////
- tagDownstreamLinksToDSCells
{
    if([habDownstreamLinksToDS getCount] > 0)
    {
       [habDownstreamLinksToDS forEach: M(tagDownstreamCells)];
    }

    return self;
}


///////////////////////////////////////////////////
//
// tagUpstreamCells
//
//////////////////////////////////////////////////
- tagUpstreamCells
{
     [upstreamCells forEach: M(tagPolyCell)];
     [modelSwarm updateTkEventsFor: self];
     return self;
}

///////////////////////////////////////////////////
//
// tagDownstreamCells
//
//////////////////////////////////////////////////
- tagDownstreamCells
{
     [downstreamCells forEach: M(tagPolyCell)];
     [modelSwarm updateTkEventsFor: self];
     return self;
}




//////////////////////////////////////////////
//
// tagCellNumber
//
//////////////////////////////////////////////
- tagCellNumber: (int) aPolyCellNumber
{
  id <ListIndex> lstNdx = nil;
  id polyCell=nil;

  fprintf(stdout, "HabitatSpace >>>> tagCellNumber >>>> cellNumber = %d >>>> BEGIN\n", aPolyCellNumber);
  fflush(0);
    
  lstNdx = [polyCellList listBegin: scratchZone];

  while(([lstNdx getLoc] != End) && ((polyCell = [lstNdx next]) != nil))
  {
        if([polyCell getPolyCellNumber] == aPolyCellNumber)
        {
             break;
        }
  }

  [lstNdx drop];

  if(polyCell != nil)
  {
      [polyCell tagPolyCell];
  }
 
  [modelSwarm updateTkEventsFor: self];
  fprintf(stdout, "HabitatSpace >>>> tagCellNumber >>>> cellNumber = %d >>>> END\n", aPolyCellNumber);
  fflush(0);

  return self;
}

/////////////////////////////////
//
// unTagAllPolyCells
//
////////////////////////////////
- unTagAllPolyCells
{
    [polyCellList forEach: M(unTagPolyCell)];
    [modelSwarm updateTkEventsFor: self];
    return self;
}

////////////////////////////////////////////////
//
// getPolyCellList
//
///////////////////////////////////////////////
- (id <List>) getPolyCellList
{
     return polyCellList;
}



///////////////////////////////
//
// getPolyPixelsX
// 
///////////////////////////////
- (unsigned int) getPolyPixelsX
{
    return polyPixelsX;
}


////////////////////////////////
//
// getPolyPixelsY
//
///////////////////////////////
- (unsigned int) getPolyPixelsY
{
     return polyPixelsY;
}





////////////////////////////////////////////////
//
// getHabSearchProd
//
////////////////////////////////////////////////
- (double) getHabSearchProd {
  return habSearchProd;
}




/////////////////////////////////////////////////////////
//
// getHabDriftConc
//
/////////////////////////////////////////////////////////
- (double) getHabDriftConc {
  return habDriftConc;
}

///////////////////////////////////////////////////
//
// getHabDriftRegenDist
//
/////////////////////////////////////////////////
- (double) getHabDriftRegenDist {
   return habDriftRegenDist;
}

//////////////////////////////////////////////////////////
//
// getHabPreyEnergyDensity
//
/////////////////////////////////////////////////////////
- (double) getHabPreyEnergyDensity 
{
  return habPreyEnergyDensity;
}


//////////////////////////////////////////////////////////
//
// getHabShelterSpeedFrac
//
/////////////////////////////////////////////////////////
- (double) getHabShelterSpeedFrac 
{
  return habShelterSpeedFrac;
}





////////////////////////////////////////////////
//
// getDayLength
//
////////////////////////////////////////////////
- (double) getDayLength 
{
   return dayLength;
}


///////////////////////////////////////////////////////////////////////
//
// getPixelsX
//
//////////////////////////////////////////////////////////////////////
- (unsigned) getPixelsX 
{
   return pixelsX;
}


//////////////////////////////////////////////////////////////////////
//
// getPixelsY
//
//////////////////////////////////////////////////////////////////////
- (unsigned) getPixelsY 
{
   return pixelsY;
}



////////////////////////////////////////////////////////////////////////
//
// getNeighborsWithin
//
// Comment: List of neighbors does not include self
//
///////////////////////////////////////////////////////////////////////
- (id <List>) getNeighborsWithin: (double) aRange 
                              of: refCell 
                        withList: (id <List>) aCellList
{
  id <ListIndex> cellNdx;
  id tempCell;
  id <List> listOfCellsWithinRange = aCellList;
  id <List> adjacentCells = [refCell getListOfAdjacentCells];
  int adjacentCellCount;

  double polyRefCenterX = [refCell getPolyCenterX];
  double polyRefCenterY = [refCell getPolyCenterY];

  double polyDistance = 0.0;

  cellNdx = [polyCellList listBegin: scratchZone];

  //fprintf(stdout, "HabitatSpace >>>> getNeigborsWithin >>>> BEGIN\n");
  //fflush(0);

  if(listOfCellsWithinRange == nil)
  {
      fprintf(stderr, "ERROR: HabitatSpace >>>> getNeighborsWithin >>>> listOfCellsWithinRange is nil\n");
      fflush(0);
      exit(1);
  }
  if([listOfCellsWithinRange getCount] != 0)
  {
      // 
      // The list from the fish must be empty
      //
      fprintf(stderr, "ERROR: HabitatSpace >>>> getNeighborsWithin >>>> listOfCellsWithinRange is not empty\n");
      fflush(0);
      exit(1);
  }

  if(adjacentCells == nil)
  {
      fprintf(stderr, "ERROR: HabitatSpace >>>> getNeighborsWithin >>>> adjacentCells is nil\n");
      fflush(0);
      exit(1);
  }

  adjacentCellCount = [adjacentCells getCount];

  if(adjacentCellCount == 0)
  {
      // 
      // The list of adjacent cells shouldn't be empty
      //
      fprintf(stderr, "ERROR: HabitatSpace >>>> getNeighborsWithin >>>> adjacentCells is empty\n");
      fflush(0);
      exit(1);
  }

  while(([cellNdx getLoc] != End) && ((tempCell = [cellNdx next]) != nil)) 
  {
     double polyCenterX;
     double polyCenterY;

     double polyCenterDiffSquareX;
     double polyCenterDiffSquareY;

     
     if(refCell == tempCell)
     {
         continue;
     }

     polyCenterX = [tempCell getPolyCenterX];
     polyCenterY = [tempCell getPolyCenterY];

     polyCenterDiffSquareX = (polyCenterX - polyRefCenterX);
     polyCenterDiffSquareY = (polyCenterY - polyRefCenterY);

     polyCenterDiffSquareX = polyCenterDiffSquareX * polyCenterDiffSquareX;
     polyCenterDiffSquareY = polyCenterDiffSquareY * polyCenterDiffSquareY;

     polyDistance = sqrt(polyCenterDiffSquareX + polyCenterDiffSquareY); 
   
     if(polyDistance <= aRange)
     {
        [listOfCellsWithinRange addLast: tempCell];
     }

  }
        
  //
  // Now, ensure listOfCellsWithinRange contains refCell's
  // adjacentCells
  //
  {
     int i;
     for(i = 0; i < adjacentCellCount; i++)
     {
         FishCell* adjacentCell = [adjacentCells atOffset: i]; 
         if([listOfCellsWithinRange contains: adjacentCell] == NO)
         {
            [listOfCellsWithinRange addLast: adjacentCell];
         }
     } 
  }


  //
  // Upstream and Downstream reaches.
  //
  if(1)
  {
      //int habDownstreamJunctionNumber;
      //int habUpstreamJunctionNumber;

      //HabitatSpace* downstreamReach;
      //HabitatSpace* upstreamReach;

           // if there are reaches whose downstream ends are links to the current reach's
           // downstream end habDownstreamLinksToDS is not empty then a message is sent to each reach on
           // habDownstreamLinksToDS to obtain a list of cellswithin a specified distance 
           // of its downstream end. 
           // The cells are added to the end of listOfCellsWithinRange
           // Likewise for habDownstreamLinksToUS (reaches with their upstream end linked to our downstream)

      if(aRange > [refCell getCellDistToDS])
      {
           int i;
           double fishDistToDSEnd = aRange - [refCell getCellDistToDS];

           unsigned int hDLTDSCount = [habDownstreamLinksToDS getCount];
           for(i = 0; i < hDLTDSCount; i++)
                {
                    id anotherReach = [habDownstreamLinksToDS atOffset: i];

                    [anotherReach addDownstreamCellsWithin: fishDistToDSEnd toList: listOfCellsWithinRange]; 
 
                } //for

           unsigned int hDLTUSCount = [habDownstreamLinksToUS getCount];
           for(i = 0; i < hDLTUSCount; i++)
                {
                    id anotherReach = [habDownstreamLinksToUS atOffset: i];

                    [anotherReach addUpstreamCellsWithin: fishDistToDSEnd toList: listOfCellsWithinRange]; 
 
                } //for
              
        }  // if (aRange > [refCell getCellDistToDS])


            // If there area reaches whose downstream ends are linked to the current reach's 
            // upstream end (habUpstreamLinksToDS is not empty), then a message is
            // sent to each reach on habUpstreamLinksToDS to obtain a list of cells
            // within a distance of its upstream end.  These cells are added to the end of
            // listOfCellsWithinRange.
            // Likewise for habUpLinksToUS (reaches with their upstream end linked to our upstream)

      if(aRange > [refCell getCellDistToUS])
      {
           int i;
           double fishDistToUSEnd = aRange - [refCell getCellDistToUS];

           unsigned int hULTDSCount = [habUpstreamLinksToDS getCount];
           for(i = 0; i < hULTDSCount; i++)
                {
                    id anotherReach = [habUpstreamLinksToDS atOffset: i];

                    [anotherReach addDownstreamCellsWithin: fishDistToUSEnd toList: listOfCellsWithinRange]; 
 
                } //for

           unsigned int hULTUSCount = [habUpstreamLinksToUS getCount];
           for(i = 0; i < hULTUSCount; i++)
                {
                    id anotherReach = [habUpstreamLinksToUS atOffset: i];

                    [anotherReach addUpstreamCellsWithin: fishDistToUSEnd toList: listOfCellsWithinRange]; 
 
                } //for

        }  // if (aRange > [refCell getCellDistToUS])

  }



  [cellNdx drop];

  //xprint(listOfCellsWithinRange);

  //fprintf(stdout, "HabitatSpace >>>> getNeigborsWithin >>>> END\n");
  //fflush(0);

  return listOfCellsWithinRange;
}

////////////////////////////////////////////////////////////////////////
//
// getNeighborsInReachWithin
//
// Used by salmon spawners, which cannot move out of their reach
//
///////////////////////////////////////////////////////////////////////
- (id <List>) getNeighborsInReachWithin: (double) aRange 
                              of: refCell 
                        withList: (id <List>) aCellList
{
  id <ListIndex> cellNdx;
  id tempCell;
  id <List> listOfCellsWithinRange = aCellList;
  id <List> adjacentCells = [refCell getListOfAdjacentCells];
  int adjacentCellCount;

  double polyRefCenterX = [refCell getPolyCenterX];
  double polyRefCenterY = [refCell getPolyCenterY];

  double polyDistance = 0.0;

  cellNdx = [polyCellList listBegin: scratchZone];

  //fprintf(stdout, "HabitatSpace >>>> getNeigborsWithin >>>> BEGIN\n");
  //fflush(0);

  if(listOfCellsWithinRange == nil)
  {
      fprintf(stderr, "ERROR: HabitatSpace >>>> getNeighborsWithin >>>> listOfCellsWithinRange is nil\n");
      fflush(0);
      exit(1);
  }
  if([listOfCellsWithinRange getCount] != 0)
  {
      // 
      // The list from the fish must be empty
      //
      fprintf(stderr, "ERROR: HabitatSpace >>>> getNeighborsWithin >>>> listOfCellsWithinRange is not empty\n");
      fflush(0);
      exit(1);
  }

  if(adjacentCells == nil)
  {
      fprintf(stderr, "ERROR: HabitatSpace >>>> getNeighborsWithin >>>> adjacentCells is nil\n");
      fflush(0);
      exit(1);
  }

  adjacentCellCount = [adjacentCells getCount];

  if(adjacentCellCount == 0)
  {
      // 
      // The list of adjacent cells shouldn't be empty
      //
      fprintf(stderr, "ERROR: HabitatSpace >>>> getNeighborsWithin >>>> adjacentCells is empty\n");
      fflush(0);
      exit(1);
  }

  while(([cellNdx getLoc] != End) && ((tempCell = [cellNdx next]) != nil)) 
  {
     double polyCenterX;
     double polyCenterY;

     double polyCenterDiffSquareX;
     double polyCenterDiffSquareY;

     
     if(refCell == tempCell)
     {
         continue;
     }

     polyCenterX = [tempCell getPolyCenterX];
     polyCenterY = [tempCell getPolyCenterY];

     polyCenterDiffSquareX = (polyCenterX - polyRefCenterX);
     polyCenterDiffSquareY = (polyCenterY - polyRefCenterY);

     polyCenterDiffSquareX = polyCenterDiffSquareX * polyCenterDiffSquareX;
     polyCenterDiffSquareY = polyCenterDiffSquareY * polyCenterDiffSquareY;

     polyDistance = sqrt(polyCenterDiffSquareX + polyCenterDiffSquareY); 
   
     if(polyDistance <= aRange)
     {
        [listOfCellsWithinRange addLast: tempCell];
     }

  }
        
  //
  // Now, ensure listOfCellsWithinRange contains refCell's
  // adjacentCells
  //
  {
     int i;
     for(i = 0; i < adjacentCellCount; i++)
     {
         FishCell* adjacentCell = [adjacentCells atOffset: i]; 
         if([listOfCellsWithinRange contains: adjacentCell] == NO)
         {
            [listOfCellsWithinRange addLast: adjacentCell];
         }
     } 
  }


  //
  // Upstream and Downstream reaches are not considered!
  //

  [cellNdx drop];

  //xprint(listOfCellsWithinRange);

  //fprintf(stdout, "HabitatSpace >>>> getNeigborsWithin >>>> END\n");
  //fflush(0);

  return listOfCellsWithinRange;
}



- (id <List>) addDownstreamCellsWithin: (double) aRange 
                                toList: (id <List>) aCellList // used by getNeighborsWithin
{
    id cell = nil;

    [polyCellListNdx setLoc: Start];

    while(([polyCellListNdx getLoc] != End) && ((cell = [polyCellListNdx next]) != nil))
    { 
        if([cell getCellDistToDS] < aRange)
        {
             [aCellList addLast: cell]; 	 
        }
    
    }


    return aCellList;

}


- (id <List>) addUpstreamCellsWithin: (double) aRange 
                              toList: (id <List>) aCellList // used by getNeighborsWithin
{
    id cell = nil;

    [polyCellListNdx setLoc: Start];

    while(([polyCellListNdx getLoc] != End) && ((cell = [polyCellListNdx next]) != nil))
    { 
        if([cell getCellDistToUS] < aRange)
        {
             [aCellList addLast: cell]; 	 
        }
    
    }


    return aCellList;

}





///////////////////////////////////////
//
// getReachLength
//
//////////////////////////////////////
- (double) getReachLength
{
    return reachLength;
}



////////////////////////////////////////
//
// getUpstreamCells
//
////////////////////////////////////////
- (id <List>) getUpstreamCells
{
     return upstreamCells;
}



//////////////////////////////////////
//
// getDownstreamCells
//
//////////////////////////////////////
- (id <List>) getDownstreamCells
{
     return downstreamCells;
}





////////////////////////////////////////////////////
//
// getFCellWithCellNumber
//
////////////////////////////////////////////////////
- (FishCell *) getFCellWithCellNumber: (int) aCellNumber
{
     FishCell* fishCell = nil;
     id <ListIndex> ndx = nil;

     fprintf(stdout, "HabitatSpace >>>> getFCellWithCellNumber >>>> BEGIN\n");
     fflush(0);
     xprint(polyCellList);

     ndx = [polyCellList listBegin: scratchZone];

     fprintf(stdout, "HabitatSpace >>>> getFCellWithCellNumber >>>> aCellNumber = %d\n", aCellNumber);
     fflush(0);

     while([ndx getLoc] != End && ((fishCell = [ndx next]) != nil))
     {
              if([fishCell getPolyCellNumber] == aCellNumber)
              {
                    break;
              }
     }

     if(fishCell == nil)
     {
           fprintf(stdout, "ERROR: HabitatSpace >>>> getFCellWithCellNumber >>>> fishCell is nil\n");
           fflush(0);
           exit(1);
     }

     [ndx drop];

     fprintf(stdout, "HabitatSpace >>>> getFCellWithCellNumber >>>> END\n");
     fflush(0);

     return fishCell;
}

////////////////////////////////////////////////////////
//
// readTomorrowsFlow
//
///////////////////////////////////////////////////////
- (double) readTomorrowsFlow : (time_t) aModelTime_t 
{ 
  double aRiverFlow=-LARGEINT;
  time_t tomorrowsTime;
  tomorrowsTime = aModelTime_t + 86400;
  aRiverFlow = [flowInputManager getValueForTime: tomorrowsTime];
  return aRiverFlow;
}



//////////////////////////////////////// 
//
// getModelTime
//
////////////////////////////////////////
-(time_t) getModelTime 
{
   return modelTime_t;
}


///////////////////////////////////////////////////////////////////////
//
// updateHabitatWithTime
// andWithModelStartFlag
//
//////////////////////////////////////////////////////////////////////
-   updateHabitatWithTime: (time_t) aModelTime_t
    andWithModelStartFlag: (BOOL) aStartFlag
{
  // fprintf(stdout, "HabitatSpace >>>> updateHabitatWithTime >>>> BEGIN\n");
  // fflush(0);
   
  modelTime_t = aModelTime_t;

  sprintf(modelDate, "%s", [timeManager getDateWithTimeT: modelTime_t]);
  strncpy(Date, modelDate, strlen(modelDate) + 1);

  if(aStartFlag == NO)
  { 
      yesterdaysRiverFlow = riverFlow;
      riverFlow = [flowInputManager getValueForTime: modelTime_t];
      tomorrowsRiverFlow = [flowInputManager getValueForTime: (modelTime_t + 86400)];
  }      
  else // aStartFlag == YES
  {
      //
      // On the first day yesterdaysRiverFlow is set to todays riverFlow 
      //
      riverFlow = [flowInputManager getValueForTime: aModelTime_t];
      yesterdaysRiverFlow = riverFlow;
      tomorrowsRiverFlow = [flowInputManager getValueForTime: (modelTime_t + 86400)];
  }
       
  dayLength = [solarManager getDayLength];

  [self updateFishCells];

  [self calcWettedArea];

  temperature = [temperatureInputManager getValueForTime: aModelTime_t];
  turbidity = [turbidityInputManager getValueForTime: aModelTime_t];

  [self updateFlowChange];

  [polyCellList forEach: M(updateHabitatSurvivalProb)];
  [polyCellList forEach: M(updateDSCellHourlyTotal)];
  [polyCellList forEach: M(resetAvailHourlyTotal)];
  [polyCellList forEach: M(resetShelterAreaAvailable)];


  //fprintf(stdout, "HabitatSpace >>>> updateHabitatWithTime >>>> modelTime_t = %ld\n", modelTime_t);
  //fprintf(stdout, "HabitatSpace >>>> updateHabitatWithTime >>>> modelDate = %s\n", modelDate);
  //fprintf(stdout, "HabitatSpace >>>> updateHabitatWithTime >>>> flowInputManager = %p\n", flowInputManager);
  //fprintf(stdout, "HabitatSpace >>>> updateHabitatWithTime >>>> riverFlow = %f\n", riverFlow);
  //fprintf(stdout, "HabitatSpace >>>> updateHabitatWithTime >>>> [flowInputManager getValueForTime: aModelTime_t] = %f\n", [flowInputManager getValueForTime: aModelTime_t]);
  //[flowInputManager  printDataToFileNamed: "FlowInputManager.out"];
  //[temperatureInputManager  printDataToFileNamed: "TemperatureInputManager.out"];
     //[self checkCellsForCellDepth];
     //[self checkCellsForCellVelocity];
  // fprintf(stdout, "HabitatSpace >>>> updateHabitatWithTime >>>> END\n");
  // fflush(0);

  //exit(0);

  return self;
}


//////////////////////////////////////////////////////
//
// updateFishCells
//
//////////////////////////////////////////////////////
- updateFishCells
{
   id <ListIndex> ndx = [polyCellList listBegin: scratchZone];
   FishCell* fishCell = nil;
   id <InterpolationTable> aVelInterpolator = [[polyCellList getFirst] getVelocityInterpolator];
   id <InterpolationTable> aDepthInterpolator = [[polyCellList getFirst] getDepthInterpolator];

   //fprintf(stdout, "HabitatSpace >>>> updateFishCells >>>> BEGIN\n");
   //fflush(0);

   // Get interpolator indices for current flow. This must be done separately
   // for depth and velocity because the d and v interpolators have different
   // numbers of values. (Velocity always starts with zero vel. at zero flow;
   // depth does not.)
   if((aVelInterpolator == nil) || (aDepthInterpolator == nil))
    {
        fprintf(stdout, "ERROR: HabitatSpace >>>> updateFishCell >>>> an Interpolator is nil\n");
        fflush(0);
        exit(1);
    }

  int velInterpolationIndex = [aVelInterpolator getTableIndexFor: riverFlow];
  double velInterpFraction = [aVelInterpolator getInterpFractionFor: riverFlow];
  int depthInterpolationIndex = [aDepthInterpolator getTableIndexFor: riverFlow];
  double depthInterpFraction = [aDepthInterpolator getInterpFractionFor: riverFlow];

   while(([ndx getLoc] != End) && ((fishCell = [ndx next]) != nil))
   {
       [fishCell updateWithDepthTableIndex: depthInterpolationIndex
                       depthInterpFraction: depthInterpFraction
                             velTableIndex: velInterpolationIndex
                         velInterpFraction: velInterpFraction];

//       [fishCell updatePolyCellVelocityWith: riverFlow];
       [fishCell calcCellAvailableGravelArea];
   }

   [ndx drop];

   //fprintf(stdout, "HabitatSpace >>>> updateFishCells >>>> END\n");
   //fflush(0);
   return self;
}


/////////////////////////////////////////////
//
// switchColorRep
//
////////////////////////////////////////////
- switchColorRep
{
    fprintf(stdout, "HabitatSpace >>>> switchColorRep >>>> BEGIN\n");
    fflush(0);

    [modelSwarm switchColorRepFor: self];

    fprintf(stdout, "HabitatSpace >>>> switchColorRep >>>> END\n");
    fflush(0);

    return self;
}

/////////////////////////////////////////////////
//
// toggleCellsColorRep
// 
////////////////////////////////////////////////
-  toggleCellsColorRep
{
    id <ListIndex> lstNdx = [polyCellList listBegin: scratchZone];
    FishCell* fishCell = nil;

    fprintf(stdout, "HabitatSpace >>>> toggleCellsColorRep >>>> BEGIN\n");
    fprintf(stdout, "HabitatSpace >>>> toggleCellsColorRep >>>> shadeColorMax = %d\n", (int) (shadeColorMax + 0.5));
    fflush(0);

    while(([lstNdx getLoc] != End) && ((fishCell = [lstNdx next]) != nil))
    {
        [fishCell toggleColorRep: shadeColorMax];
    }

    [lstNdx drop];

    fprintf(stdout, "HabitatSpace >>>> toggleCellsColorRep >>>> END\n");
    fflush(0);

    return self;
}
////////////////////////////////////////////////
//
// calcWettedArea
//
////////////////////////////////////////////////
- calcWettedArea
{
  FishCell* fishCell = nil;

  habWettedArea = 0.0;

  if(polyCellListNdx == nil)
  {
      fprintf(stderr, "ERROR: HabitatSpace >>>> calcWettedArea >>>> polyCellListNdx is nil\n");
      fflush(0);
      exit(1);
  }

  [polyCellListNdx setLoc: Start];
    
   while(([polyCellListNdx getLoc] != End)
            && ((fishCell = [polyCellListNdx next]) != nil))
  {
      double polyCellDepth = [fishCell getPolyCellDepth];
      if(polyCellDepth > 0.0)
      {
         habWettedArea += [fishCell getPolyCellArea];
      }
  }

  return self;
}


////////////////////////////////////////////////////////////////
//
// getTemperature
//
///////////////////////////////////////////////////////////////
- (double) getTemperature 
{
    return temperature;
}


////////////////////////////////////////////////////////////////
//
// getTurbidity
//
///////////////////////////////////////////////////////////////
- (double) getTurbidity 
{
   return turbidity;
}




/////////////////////////////////////////////////////////////
//
// updateFlowChange
//
// Return the absolute value of the change
// flow from yesterday
//
// NOTE: They are NOT logarithms
//
//////////////////////////////////////////////////////////
- updateFlowChange 
{
  double diff;
  diff = yesterdaysRiverFlow - riverFlow;
  flowChange = sqrt(pow(diff,2));
  return self;
}


///////////////////////////////////////////////////////////
//
// getFlowChange
//
//////////////////////////////////////////////////////////
- (double) getFlowChange
{
  return flowChange;
}


//////////////////////////////////////////////////////////////
//
// getYesterdaysRiverFlow
//
///////////////////////////////////////////////////////////
- (double) getYesterdaysRiverFlow 
{
 return yesterdaysRiverFlow;
}


//////////////////////////////////////////////////////////////
//
// getRiverFlow
//
///////////////////////////////////////////////////////////
- (double) getRiverFlow 
{
 return riverFlow;
}


//////////////////////////////////////////////////////////////
//
// getTomorrowsRiverFlow
//
// pass through from cell
//
//
///////////////////////////////////////////////////////////
- (double) getTomorrowsRiverFlow 
{
 return tomorrowsRiverFlow;
}


//////////////////////////////////////////////////
//
// getHabMaxSpawnFlow
//
//////////////////////////////////////////////////
- (double) getHabMaxSpawnFlow
{
    return habMaxSpawnFlow;
}


/////////////////////////////////////////////
//
// setModelStartTime:andEndTime
//
/////////////////////////////////////////////
- setModelStartTime: (time_t) startTime  
         andEndTime: (time_t) endTime 
{
  modelStartTime = startTime;
  modelEndTime = endTime;
  return self;
}


////////////////////////////////////////
//
// setDataStartTime: andEndTime
//
////////////////////////////////////////
- setDataStartTime: (time_t) aDataStartTime
        andEndTime: (time_t) aDataEndTime
{
   dataStartTime = aDataStartTime;
   dataEndTime = aDataEndTime;
   return self;
}


- printCellDepthReport 
{
  FILE * reportPtr=NULL;

  id <ListIndex> cellNdx;
  id nextCell;
  int cellNumber;
  double myRiverFlow;
  double depth;
  char date[12];
  char strDataFormat[100];
  char * fileMetaData;

  if(depthReportFirstWrite == YES) {
      if((reportPtr = fopen(cellDepthReportFile,"w+")) == NULL) {
           fprintf(stderr, "ERROR: HabitatSpace >>>> printCellDepthReport  >>>> Cannot open file %s",cellDepthReportFile);
           fflush(0);
           exit(1);
      }
      fflush(reportPtr);
  }
  if(depthReportFirstWrite == NO) {
    if((reportPtr = fopen(cellDepthReportFile,"a")) == NULL){
        fprintf(stderr, "ERROR: HabitatSpace >>>> printCellDepthReport  >>>> Cannot open file %s",cellDepthReportFile);
        fflush(0);
        exit(1);
    }
  }
  cellNdx = [polyCellList listBegin: [self getZone]];

  if(depthReportFirstWrite == YES){
    fileMetaData = [BreakoutReporter reportFileMetaData: scratchZone];
    fprintf(reportPtr,"\n%s\n\n",fileMetaData);
    [scratchZone free: fileMetaData];
    fprintf(reportPtr,"%s\n","date,cellNumber,cellFlow,cellDepth");
  }

  while(([cellNdx getLoc] != End) && ( (nextCell = [cellNdx next]) != nil)){
    cellNumber   = [nextCell getPolyCellNumber];
    myRiverFlow = [nextCell getRiverFlow];
    depth    = [nextCell getPolyCellDepth];

    strncpy(date, [timeManager getDateWithTimeT: [[nextCell getSpace] getModelTime]],12);
    strcpy(strDataFormat,"%s,%d,%E,%E\n");
    //Following for pretty print
    //strcpy(strDataFormat,"%s,%d,");
    //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: myRiverFlow]);
    //strcat(strDataFormat,",");
    //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: depth]);
    //strcat(strDataFormat,"\n");

    fprintf(reportPtr,strDataFormat, date,
				     cellNumber,
				     myRiverFlow,
				     depth);
  } //while
  fflush(0);
  [cellNdx drop];
  fclose(reportPtr);
  depthReportFirstWrite = NO;

  return self;
}

- printCellVelocityReport 
{
  FILE * reportPtr=NULL;

  id <ListIndex> cellNdx;
  id nextCell;
  int cellNumber;
  double myRiverFlow;
  double velocity;
  char date[12];
  char strDataFormat[100];
  char * fileMetaData;

  if(velocityReportFirstWrite == YES) {
      if((reportPtr = fopen(cellVelocityReportFile,"w+")) == NULL) {
           fprintf(stderr, "ERROR: HabitatSpace >>>> printCellVelocityReport  >>>> Cannot open file %s",cellVelocityReportFile);
           fflush(0);
           exit(1);
      }
      fflush(reportPtr);
  }
  if(velocityReportFirstWrite == NO) {
    if((reportPtr = fopen(cellVelocityReportFile,"a")) == NULL){
        fprintf(stderr, "ERROR: HabitatSpace >>>> printCellVelocityReport  >>>> Cannot open file %s",cellVelocityReportFile);
        fflush(0);
        exit(1);
    }
  }
  cellNdx = [polyCellList listBegin: [self getZone]];

  if(velocityReportFirstWrite == YES){
    fileMetaData = [BreakoutReporter reportFileMetaData: scratchZone];
    fprintf(reportPtr,"\n%s\n\n",fileMetaData);
    [scratchZone free: fileMetaData];
    fprintf(reportPtr,"%s\n","date,cellNumber,cellFlow,cellVelocity");
  }

  while(([cellNdx getLoc] != End) && ( (nextCell = [cellNdx next]) != nil)){
    cellNumber   = [nextCell getPolyCellNumber];
    myRiverFlow = [nextCell getRiverFlow];
    velocity    = [nextCell getPolyCellVelocity];

    strncpy(date, [timeManager getDateWithTimeT: [[nextCell getSpace] getModelTime]],12);
    strcpy(strDataFormat,"%s,%d,%E,%E\n");
    //or pretty print
    //strcpy(strDataFormat,"%s,%d,");
    //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: myRiverFlow]);
    //strcat(strDataFormat,",");
    //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: velocity]);
    //strcat(strDataFormat,"\n");

    fprintf(reportPtr,strDataFormat, date,
				     cellNumber,
				     myRiverFlow,
				     velocity);
  } //while
  fflush(0);
  [cellNdx drop];
  fclose(reportPtr);
  velocityReportFirstWrite = NO;

  return self;
}

///////////////////////////////////////
//
// buildCellFishInfoReporter
//
//////////////////////////////////////
- buildCellFishInfoReporter
{
  BOOL fileOverWrite = TRUE;
  BOOL suppressBreakoutColumns = NO;


  //fprintf(stdout, "HabitatSpace >>>> buildCellFishInfoReporter >>>> BEGIN\n");
  //fflush(0);
 
  if(speciesSymbolList == nil)
  {
     fprintf(stderr, "ERROR: HabitatSpace >>>> buildCellFishInfoReporter >>>> speciesSymbolList is nil\n");
     fflush(0);
     exit(1);
  }

  if(ageSymbolList == nil)
  {
     fprintf(stderr, "ERROR: HabitatSpace >>>> buildCellFishInfoReporter >>>> ageSymbolList is nil\n");
     fflush(0);
     exit(1);
  }


  if((scenario == 0) || (replicate == 0))
  {
     fprintf(stderr, "ERROR: HabitatSpace >>>> buildCellFishInfoReporter >>>> scenario or replicate is 0\n");
     fflush(0);
     exit(1);
  }

  if(appendFiles == TRUE)
  {
     fileOverWrite = FALSE;
  }

  if((scenario != 1) || (replicate != 1))
  {
      suppressBreakoutColumns = YES;
      fileOverWrite = FALSE;
  }

  sprintf(cellFishInfoReportFName, "%s%s", reachName, "_Cell_Fish_Info_Out.csv");
  fprintf(stdout, "HabitatSpace >>>> buildCellFishInfoReporter >>>> cellFishInfoReportFName = %s \n", cellFishInfoReportFName);
  fflush(0);

  cellFishInfoReporter = [BreakoutReporter   createBeginWithCSV: habitatZone
                                             forList: cellFishList
                                  withOutputFilename: (char *) cellFishInfoReportFName
                                   withFileOverwrite: fileOverWrite];
  //withColumnWidth: 25];



  [cellFishInfoReporter addColumnWithValueOfVariable: "scenario"
                                      fromObject: self
                                        withType: "int"
                                       withLabel: "Scenario"];

  [cellFishInfoReporter addColumnWithValueOfVariable: "replicate"
                                      fromObject: self
                                        withType: "int"
                                       withLabel: "Replicate"];

  [cellFishInfoReporter addColumnWithValueOfVariable: "modelDate"
                                      fromObject: self
                                        withType: "string"
                                       withLabel: "ModelDate"];

  [cellFishInfoReporter addColumnWithValueOfVariable: "habCellNumber"
                                      fromObject: self
                                        withType: "int"
                                       withLabel: "CellNumber"];

  [cellFishInfoReporter addColumnWithValueOfVariable: "habCellArea"
                                      fromObject: self
                                        withType: "double"
                                       withLabel: "CellArea"];

  [cellFishInfoReporter addColumnWithValueOfVariable: "habCellDepth"
                                      fromObject: self
                                        withType: "double"
                                       withLabel: "CellDepth"];

  [cellFishInfoReporter addColumnWithValueOfVariable: "habCellVelocity"
                                      fromObject: self
                                        withType: "double"
                                       withLabel: "CellVelocity"];

  [cellFishInfoReporter addColumnWithValueOfVariable: "habCellDistToHide"
                                      fromObject: self
                                        withType: "double"
                                       withLabel: "CellDistToHide"];

  [cellFishInfoReporter addColumnWithValueOfVariable: "habCellFracShelter"
                                      fromObject: self
                                        withType: "double"
                                       withLabel: "CellFracShelter"];

  [cellFishInfoReporter breakOutUsingSelector: @selector(getSpecies)
                               withListOfKeys: speciesSymbolList];

  [cellFishInfoReporter breakOutUsingSelector: @selector(getAgeSymbol)
                               withListOfKeys: ageSymbolList];

  [cellFishInfoReporter createOutputWithLabel: "Count"
                                 withSelector: @selector(getFishCount)
                             withAveragerType: "Count"];

  [cellFishInfoReporter suppressColumnLabels: suppressBreakoutColumns];

  cellFishInfoReporter = [cellFishInfoReporter createEnd];

  //fprintf(stdout, "HabitatSpace >>>> buildCellFishInfoReporter >>>> END\n");
  //fflush(0);

  return self;
}

/////////////////////////////////////////
//
// outputCellFishInfoReport
//
////////////////////////////////////////
- outputCellFishInfoReport
{
   id <ListIndex> cellNdx = nil;
   FishCell*  aCell = nil;

   //fprintf(stdout, "HabitatSpace >>>> %s >>>> outputCellFishInfoReport >>>> BEGIN\n", [reachSymbol getName]);
   //fflush(0);

   
   if(cellFishInfoReporter == nil)
   {
       fprintf(stderr, "ERROR: HabitatSpace >>>> outputCellFishInfoReport >>>> cellFishInfoReporter is nil\n");
       fflush(0);
       exit(1);
   }


   cellNdx = [polyCellList listBegin: scratchZone];


   while(([cellNdx getLoc] != End) && ((aCell = [cellNdx next]) != nil))
   {
      id <List> fishIContain = [aCell getFishIContain];
      id <ListIndex> fishNdx = [fishIContain listBegin: scratchZone];
      id aFish = nil;

      habCellDepth = [aCell getPolyCellDepth];

      //if(habCellDepth <= 0.0)
      //{
      //    continue;
      //}

      habCellNumber = [aCell getPolyCellNumber];
      habCellArea = [aCell getPolyCellArea];


      habCellVelocity = [aCell getPolyCellVelocity];
      habCellDistToHide = [aCell getDistanceToHide];
      habCellFracShelter = [aCell getCellFracShelter];

      [cellFishList removeAll];

      if([cellFishList getCount] > 0)
      {
          fprintf(stderr, "ERROR: HabitatSpace >>>> outputCellFishInfoReport >>>> cellFishList is non-empty\n");
          fflush(0);
          exit(1);
      }

      while(([fishNdx getLoc] != End) && ((aFish = [fishNdx next]) != nil))
      {
          [cellFishList addLast: aFish];
      }
       
      [fishNdx drop];

      //
      // Now output the breakout reporter
      //
      [cellFishInfoReporter updateByReplacement];
      [cellFishInfoReporter output];
  }

  [cellNdx drop];
  

  //fprintf(stdout, "HabitatSpace >>>> %s >>>> outputCellFishInfoReport >>>> END\n", [reachSymbol getName]);
  //fflush(0);

  return self;
}

///////////////////////////////////
//
// printHabitatReport
//
///////////////////////////////////
- printHabitatReport 
{
  BOOL writeFileHeader;
  char * fileMetaData;
  char strDataFormat[150];

  appendFiles = [modelSwarm getAppendFiles];
  scenario = [modelSwarm getScenario];
  replicate = [modelSwarm getReplicate];

  writeFileHeader =    ((scenario == 1) && (replicate == 1));

  if(habitatRptFilePtr == NULL){
      if(habitatReportFirstWrite == YES){
        if((appendFiles == 0) && (scenario == 1) && (replicate == 1)){
            if((habitatRptFilePtr = fopen(habitatReportFile,"w+")) == NULL){
                fprintf(stderr, "ERROR: HabitatSpace >>>> printHabitatReport >>>> Cannot open file %s", habitatReportFile);
                fflush(0);
                exit(1);
            }
        }else{  // Not appending files or not first scenario and replicate
            if((habitatRptFilePtr = fopen(habitatReportFile,"a")) == NULL){
               fprintf(stderr, "ERROR: HabitatSpace >>>> printHabitatReport >>>> Cannot open file %s",habitatReportFile);
               fflush(0);
               exit(1);
            }
        }

        if(writeFileHeader){
	  fileMetaData = [BreakoutReporter reportFileMetaData: scratchZone];
	  fprintf(habitatRptFilePtr,"\n%s\n\n",fileMetaData);
	  [scratchZone free: fileMetaData];
          fprintf(habitatRptFilePtr,"%s,%s,%s,%s,%s,%s,%s,%s,%s,\n", "Scenario",
                                                                  "Replicate",
                                                                  "Date",
                                                                  "DayLength", 
                                                        "YesterdaysRiverFlow", 
                                                            "TodaysRiverFlow", 
                                                         "TomorrowsRiverFlow", 
                                                                "Temperature", 
                                                                  "Turbidity");
            fflush(habitatRptFilePtr);
        }
      }  // if (habitatReportFirstWrite == YES )

     if(habitatReportFirstWrite == NO){
        if((habitatRptFilePtr = fopen(habitatReportFile,"a")) == NULL){
           fprintf(stderr, "ERROR: HabitatSpace >>>> printHabitatReport >>>> Cannot open file %s",habitatReportFile);
           fflush(0);
           exit(1);
        }
     }

  }

  strcpy(strDataFormat,"%d,%d,%s,%E,%E,%E,%E,%E,%E\n");
  //pretty print
  //strcpy(strDataFormat,"%d,%d,%s,");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: dayLength]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: yesterdaysRiverFlow]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: riverFlow]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: tomorrowsRiverFlow]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: temperature]);
  //strcat(strDataFormat,",");
  //strcat(strDataFormat,[BreakoutReporter formatFloatOrExponential: turbidity]);
  //strcat(strDataFormat,"\n");
  fprintf(habitatRptFilePtr,strDataFormat,scenario,
                                          replicate,
                                          [timeManager getDateWithTimeT: modelTime_t], 
                                          dayLength, 
                                          yesterdaysRiverFlow, 
                                          riverFlow, 
                                          tomorrowsRiverFlow, 
                                          temperature, 
                                          turbidity);
  fflush(habitatRptFilePtr);
  habitatReportFirstWrite = NO;

  return self;
}


- printCellAreaDepthVelocityRpt{

 FILE *depthVelPtr=NULL;
 char openFmt[1];
 char * fileMetaData;

 if(depthVelRptFirstTime == YES){
   openFmt[0] = 'w';
 }else{
   openFmt[0] = 'a';
 }
 if( (depthVelPtr = fopen(cellAreaDepthVelReportFile, openFmt)) == NULL){
     fprintf(stderr, "ERROR: Cell >>>> printCellAreaDepthVelocityRpt >>>> Cannot open %s for writing, open format=%s\n", cellAreaDepthVelReportFile,openFmt);
     fflush(0);
     exit(1);
 }
 if(depthVelRptFirstTime == YES){
    fileMetaData = [BreakoutReporter reportFileMetaData: scratchZone];
    fprintf(depthVelPtr,"\n%s\n\n",fileMetaData);
    [scratchZone free: fileMetaData];
 }

 [polyCellList forEach: M(depthVelReport:) : (id) depthVelPtr];

 fclose(depthVelPtr);
 depthVelRptFirstTime = NO;

 return self;
}



///////////////////////////////////////////////////////////////////
//
////              CELL REPORT METHODS
////// 
////////
///////////////////////////////////////////////////////////////////

- (BOOL) getFoodReportFirstTime {

   return foodReportFirstTime;

}

- setFoodReportFirstTime: (BOOL) aBool {

  foodReportFirstTime = aBool;

  return self;

}

- (BOOL) getDepthVelRptFirstTime {

  return depthVelRptFirstTime;

}


- setDepthVelRptFirstTime: (BOOL) aBool {

   depthVelRptFirstTime = aBool;

   return self;

}





//////////////////////////////////////////////////////////////
//
////
//////  BARRIERS
///////
/////////
//////////////////////////////////////////////////////////////


////////////////////////////////////////////////
//
// buildBarriersFromList
// Not used because this version of model does not allow barriers
//
////////////////////////////////////////////////
/*
- buildBarriersFromList: (id <List>) aBarrierXList
{

  int i;
  int barrierListCount;

  fprintf(stdout, "HabitatSpace >>>> buildBarriersFromList >>>> BEGIN\n");
  fflush(0);

  if(aBarrierXList == nil)
  {
     fprintf(stderr, "ERROR: HabitatSpace >>>> buildBarriersFromList >>>> aBarrierXList is nil\n");
     fflush(0);
  }

  barrierListCount = [aBarrierXList getCount];

  for(i = 0; i < barrierListCount; i++)
  {
     Barrier *barrier=nil;
     double* aBarrierX = (double *) [aBarrierXList atOffset: i];

     barrier = [Barrier create: habitatZone];
     [barrier setBarrierX: *aBarrierX];              //gets multiplied by 100 by the barrier
     [barrier setMinY: minCellY andMaxY: maxCellY];
     [barrierList addLast: barrier];
  }

  barrierCount = [barrierList getCount];

  fprintf(stdout, "HabitatSpace >>>> buildBarriersFromList >>>> END\n");
  fflush(0);

  return self;
}
*/

//////////////////////////////////////////////////////////////////
//
// setBarrierRasterResolutionX
//
/////////////////////////////////////////////////////////////////
- setBarrierRasterResolutionX: (int) aResolutionX 
               andResolutionY: (int) aResolutionY {

  id <ListIndex> barrierNdx;
  id aBarrier=nil;

  if(barrierCount != 0 ) {

      barrierNdx = [barrierList listBegin: scratchZone];

      while( ([barrierNdx getLoc] != End) && 
             ((aBarrier = [barrierNdx next]) != nil) ) {

        [aBarrier setBarrierRasterResolutionX: aResolutionX 
                               andResolutionY: aResolutionY];
    
      }

      [barrierNdx drop];

  }

 
  return self;

}


//////////////////////////////////////////////////////////////////
//
// getBarriers
//
/////////////////////////////////////////////////////////////////
- (id <List>) getBarriers 
{
  return barrierList;
}


//////////////////////////////////////////////////////////////////
//
// isThereABarrierTo
//
// always returns -1 since there are no barriers;
// see old code.
//
/////////////////////////////////////////////////////////////////
- (int) isThereABarrierTo: aDestCell from: myCell 
{
    return -1;
}



/////////////////////////////////////////////////////////////////
//
////            HISTOGRAM OUTPUT
//////
////////     Note: the set and open messages are sent from the
//////////         *Observer* Swarm NOT the model swarm
////////////
/////////////////////////////////////////////////////////////////

- setAreaDepthBinWidth: (int) aWidth {

  depthBinWidth = aWidth;

  return self;

}


//////////////////////////////////////////////////////////
//
// setAreaVelocityBinWidth
//
//////////////////////////////////////////////////////////
- setAreaVelocityBinWidth: (int) aWidth {

  velocityBinWidth = aWidth;

  return self;

}


///////////////////////////////////////////////////////////
//
// setDepthHistoMaxDepth
//
/////////////////////////////////////////////////////////
- setDepthHistoMaxDepth: (double) aDepth {

  depthHistoMaxDepth = aDepth;

  return self;

}

///////////////////////////////////////////////////////
//
// setVelocityHistoMaxVelocity
//
//////////////////////////////////////////////////////
- setVelocityHistoMaxVelocity: (double) aVelocity {
 
  velocityHistoMaxVelocity = aVelocity;

  return self;

}


///////////////////////////////////////////////////////
//
// setAreaDepthHistoFmtStr
//
///////////////////////////////////////////////////////
- setAreaDepthHistoFmtStr: (char *) aFmtStr {

  areaDepthHistoFmtStr = aFmtStr;

  return self;
 
}

///////////////////////////////////////////////////////
//
// setAreaVelocityHistoFmtStr
//
///////////////////////////////////////////////////////
- setAreaVelocityHistoFmtStr: (char *) aFmtStr {

  areaVelocityHistoFmtStr = aFmtStr;

  return self;
 
}

//////////////////////////////////////////////////////////
//
// openAreaDepthFile
//
//////////////////////////////////////////////////////////
- openAreaDepthFile: (char *) aFileName 
{
  int maxBinNumber= (unsigned) floor(depthHistoMaxDepth/depthBinWidth);
  int i;

  if([modelSwarm getAppendFiles] == NO) {
      if( (areaDepthFileStream = fopen(aFileName, "w")) == NULL) {

          [InternalError raiseEvent: "ERROR: Cannot open %s in habitatSpace \n", aFileName];

      }

      fprintf(areaDepthFileStream, "%-14s%-10s%-11s","Date", "Scenario", "Replicate");
      fflush(0);

      for(i=0;i < maxBinNumber; i++) {

        //fprintf(areaDepthFileStream, "%-10d",(i+1)*depthBinWidth);
        fprintf(areaDepthFileStream, areaDepthHistoFmtStr,(i+1)*depthBinWidth);
        fflush(0);

      } //for

        fprintf(areaDepthFileStream, ">");
        fprintf(areaDepthFileStream, areaDepthHistoFmtStr, maxBinNumber*depthBinWidth);
        fprintf(areaDepthFileStream, "\n");
        fflush(0);

  }
  else {

     if( ([modelSwarm getScenario] == 1) && ([modelSwarm getReplicate] == 1) ) {
        if( (areaDepthFileStream = fopen(aFileName, "w")) == NULL) {

            [InternalError raiseEvent: "ERROR: Cannot open %s in habitatSpace \n", aFileName];

        }

        fprintf(areaDepthFileStream, "%-14s%-10s%-11s","Date", "Scenario", "Replicate");
        fflush(0);

        for(i=0;i < maxBinNumber; i++) {

           fprintf(areaDepthFileStream, areaDepthHistoFmtStr,(i+1)*depthBinWidth);
           fflush(0);

        } //for

        fprintf(areaDepthFileStream, ">");
        fprintf(areaDepthFileStream, areaDepthHistoFmtStr, maxBinNumber*depthBinWidth);
        fprintf(areaDepthFileStream, "\n");
        fflush(0);
    }
    else {

        if((areaDepthFileStream = fopen(aFileName, "a")) == NULL) {

           [InternalError raiseEvent: "ERROR: Cannot open %s in habitatSpace \n", aFileName];
        }

    }

   }

  return self;

}



/////////////////////////////////////////////////
//
////       CLEANUP
//////
////////
/////////
////////////////////////////////////////////////
- (void) drop 
{
 //   int i = 0;

   // fprintf(stdout, "HabitatSpace >>>> drop >>>> BEGIN\n");
   // fflush(0);


    //fclose(areaDepthFileStream);
    //fclose(areaVelocityFileStream);

    
    if(cellFishInfoReporter != nil)
    {
        //[cellFishInfoReporter drop];
        //cellFishInfoReporter = nil;
    }
    if(habitatRptFilePtr != NULL) 
    {
        //fclose(habitatRptFilePtr);
    }

    [habitatZone free: hydraulicFile];
    hydraulicFile = NULL;

    [habitatZone free: flowFile];
    flowFile = NULL;

    [habitatZone free: temperatureFile];
    temperatureFile = NULL;

    [habitatZone free: turbidityFile];
    turbidityFile = NULL;

    [habitatZone free: polyCellGeomFile];
    polyCellGeomFile = NULL;

    [habitatZone free: cellHabVarsFile];
    cellHabVarsFile = NULL;

    [barrierList deleteAll];
    [barrierList drop];
    barrierList = nil; 

    [habitatZone free: cellDepthReportFile];
    [habitatZone free: cellVelocityReportFile];
    [habitatZone free: habitatReportFile];
    [habitatZone free: cellAreaDepthVelReportFile];
    [habitatZone free: Date];

    [habDownstreamLinksToDS removeAll];
    [habDownstreamLinksToDS drop];
    habDownstreamLinksToDS = nil;

    [habDownstreamLinksToUS removeAll];
    [habDownstreamLinksToUS drop];
    habDownstreamLinksToUS = nil;

    [habUpstreamLinksToDS removeAll];
    [habUpstreamLinksToDS drop];
    habUpstreamLinksToDS = nil;

    [habUpstreamLinksToUS removeAll];
    [habUpstreamLinksToUS drop];
    habUpstreamLinksToUS = nil;

    [tempCellList removeAll];
    [tempCellList drop];
    tempCellList = nil;

    [upstreamCells removeAll];
    [upstreamCells drop];
    upstreamCells = nil;

    [downstreamCells removeAll];
    [downstreamCells drop];
    downstreamCells = nil;


    [cellFishList removeAll];
    [cellFishList drop];
    cellFishList = nil;

    [habitatZone free: reachName];
    reachName = NULL;

    [habitatZone free: instanceName];
    instanceName = NULL;

    [habitatZone free: modelDate];
    modelDate = NULL;

    [flowInputManager drop];
    flowInputManager = nil;

    [temperatureInputManager drop];
    temperatureInputManager = nil;

    [turbidityInputManager drop];
    turbidityInputManager = nil;

    [polyCellListNdx drop];
    polyCellListNdx = nil;

    [polyCellList deleteAll];
    [polyCellList drop];
    polyCellList = nil;

    [habitatZone drop];
    habitatZone = nil;

   // fprintf(stdout, "HabitatSpace >>>> drop >>>> END\n");
   // fflush(0);
}


@end
