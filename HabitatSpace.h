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



#import <random.h>
#import <space.h>
#import <space/Discrete2d.h>
#import "FishCell.h"
#import "globals.h"
#import "BreakoutReporter.h"
#import "TimeManagerProtocol.h"
#import "TimeSeriesInputManagerP.h"
//#import "Barrier.h"
#import "math.h"
#import "InterpolationTableP.h"
#import "SolarManagerP.h"
#import "TroutModelSwarmP.h"
#import "PolyInputData.h"
//#import "PolyInterpolatorFactory.h"

#import "PolyCell.h"
#import "PolyPoint.h"

@interface HabitatSpace : Discrete2d 
{
  id <TroutModelSwarm> modelSwarm;
  id <Zone> habitatZone;

  char* reachName;
  char* instanceName;
  id <Symbol> reachSymbol;

  id <SolarManager> solarManager;

  int numCells;
  unsigned pixelsX;
  unsigned pixelsY;

  //
  // Added for adjacent reaches
  //
  int habDownstreamJunctionNumber;
  int habUpstreamJunctionNumber;

  id <List> habDownstreamLinksToDS;
  id <List> habDownstreamLinksToUS;

  id <List> habUpstreamLinksToDS;
  id <List> habUpstreamLinksToUS;

      id <List> tempCellList;
     //
     // new...
     //
     id <List> upstreamCells;
     id <List> downstreamCells;
  
  //
  // End adjacent reaches
  //

  //
  //THE FOLLOWING VARIABLES ARE INITIALIZED BY Habitat.Setup
  //
  double habSearchProd;
  double habDriftConc;
  double habDriftRegenDist;
  double habPreyEnergyDensity;
  double habMaxSpawnFlow;
  double habShearParamA;
  double habShearParamB;
  double habShelterSpeedFrac;

//END VARIABLES INITIALIZED BY Habitat.Setup

long int minXCoordinate;
long int minYCoordinate;
long int maxXCoordinate;
long int maxYCoordinate;

@protected

  int numberOfSpecies;

  double reachLength;

  double habWettedArea;



  //
  // These are set from the HabitatManager 
  //
  char* polyCellGeomFile;
  char* hydraulicFile;
  char* flowFile;
  char* temperatureFile;
  char* turbidityFile;
  char* hydraulicsFile;
  char* cellHabVarsFile;

  id <TimeSeriesInputManager> flowInputManager;
  id <TimeSeriesInputManager> temperatureInputManager;
  id <TimeSeriesInputManager> turbidityInputManager;

  double temperature;
  double turbidity;
  
  int spaceDimX, spaceDimY;

  id <Array> flowArray;
  id <InterpolationTable> flowInterpolator;

  // 
  // BARRIERS
  //
  id <List> barrierList;
  int barrierCount;
  double maxCellY;
  double minCellY;

  double dayLength;

  id <LogNormalDist> velDist;

  double yesterdaysRiverFlow;
  double riverFlow;
  double tomorrowsRiverFlow;

  double flowChange;

 
  //
  // TIME
  // 
 
  id <TimeManager> timeManager;
  time_t modelTime_t;
  char* modelDate;
  time_t modelStartTime;
  time_t modelEndTime;

  time_t dataStartTime;
  time_t dataEndTime;

  char* Date;

  int scenario;
  int replicate;

  id <Map> fishParamsMap;

  //
  // REPORT VARIABLES
  //

 BOOL appendFiles;

 BOOL habitatReportFirstWrite;
 BOOL depthReportFirstWrite;
 BOOL velocityReportFirstWrite;
 BOOL depthVelRptFirstTime;     //also used in the cell depth reporting


 char* cellDepthReportFile;
 char* cellVelocityReportFile;
 char* habitatReportFile;
 char* cellAreaDepthVelReportFile;




  //  
  // CELL REPORT VARIABLES
  // 
  BOOL foodReportFirstTime;

  BreakoutReporter* cellFishInfoReporter;
  char cellFishInfoReportFName[50];
  id <List> cellFishList;
  id <List> ageSymbolList;
  id <List> speciesSymbolList;
  id <List> reachSymbolList;

  //
  // The following is used for a work around in the 
  // cellFishInfoReporter (BreakoutReport)
  //
  int    habCellTransectNumber;
  int    habCellNumber;
  double habCellArea;
  double habCellDepth;
  double habCellVelocity;
  double habCellDistToHide;
  double habCellFracShelter;


  //
  // Habitat Report
  //
  FILE* habitatRptFilePtr;
  //
  // HISTOGRAM VARIABLES
  //

  FILE* areaDepthFileStream;
  FILE* areaVelocityFileStream;

  int depthBinWidth;
  int velocityBinWidth;

  double depthHistoMaxDepth;
  double velocityHistoMaxVelocity;

  BOOL firstDepthTime;
  BOOL firstVelocityTime;

  char* areaDepthHistoFmtStr;
  char* areaVelocityHistoFmtStr;

  //
  // Declarations for the cell's using utm coordinates
  //

  int maxPolyCellNumber;
  int maxNode;
//  double** nodeUTMXArray;
//  double** nodeUTMYArray;
  id <ListIndex> polyCellListNdx;

  unsigned int polySpaceSizeX;
  unsigned int polySpaceSizeY;

  unsigned int polyPixelsX;
  unsigned int polyPixelsY;

  int polyRasterResolutionX;
  int polyRasterResolutionY;
  char polyRasterColorVariable[25];
  double shadeColorMax;

  double** velocityArray;

  id <List> listOfPolyInputData;
  //PolyInterpolatorFactory* polyInterpolatorFactory;


   //
   // The new poly cell data 
   //

   id <List> polyCellList;

}

+ createBegin: aZone;
- createEnd;
- checkHabitatParams;

- buildObjects;
- finishBuildObjects;

- setModel: (id <TroutModelSwarm>) aModelSwarm;
- getModel;

- setReachName: (char *) aReachName;
- setInstanceName: (char *) anInstanceName;
- (char *) getReachName;
- (char *) getInstanceName;

- setReachSymbol: (id <Symbol>) aSymbol;
- (id <Symbol>) getReachSymbol;


//
// Adjacent Cells BEGIN
//
- setHabDStreamJNumber: (int) aJunctionNumber;
- setHabUStreamJNumber: (int) aJunctionNumber;
- (int) getHabDStreamJNumber;
- (int) getHabUStreamJNumber;

- setHabDownstreamLinksToDS: aDSLinkToDS;
- setHabDownstreamLinksToUS: aDSLinkToUS;
- setHabUpstreamLinksToDS: anUSLinkToDS;
- setHabUpstreamLinksToUS: anUSLinkToUS;

- (id <List>) getHabDownstreamLinksToDS;
- (id <List>) getHabDownstreamLinksToUS;
- (id <List>) getHabUpstreamLinksToDS;
- (id <List>) getHabUpstreamLinksToUS;

- (id <List>) addDownstreamCellsWithin: (double) aRange 
                                toList: (id <List>) aCellList; // used by getNeighborsWithin
- (id <List>) addUpstreamCellsWithin: (double) aRange 
                              toList: (id <List>) aCellList; // used by getNeighborsWithin

- (double) getReachLength;

     

- setTimeManager: (id <TimeManager>) aTimeManager;
- setFishParamsMap: (id <Map>) aMap;
- setSolarManager: (id <SolarManager>) aSolarManager;
- setNumberOfSpecies: (int) aNumberOfSpecies;

- (id <List>) getNeighborsWithin: (double) aRange 
                              of: refCell 
                        withList: (id <List>) aCellList; // used by fish

- (id <List>) getNeighborsInReachWithin: (double) aRange 
                              of: refCell 
                        withList: (id <List>) aCellList; // used by spawners

- readGeometry;
- calcSpaceVariables;


//
// BEGIN POLY CELLS
//
- setPolyCellGeomFile: (char *) aFile;
- setHydraulicFile: (char *) aFile;
-   setPolyRasterResolutionX: (int) aPolyRasterResolutionX
    setPolyRasterResolutionY: (int) aPolyRasterResolutionY
     setRasterColorVariable: (char *) aRasterColorVariable
          setShadeColorMax: (double) aShadeColorMax;
- setShadeColorMax: (double) aShadeColorMax;

- setListOfPolyInputData: (id <List>) aListOfPolyInputData;
- buildPolyCells;
- checkAdjacentReaches;
- (id <List>) getUpstreamCells;
- (id <List>) getDownstreamCells;
- read2DGeometryFile;
- createPolyInterpolationTables;
- setCellShadeColorMax;
- probePolyCellAtX: (int) probedX Y: (int) probedY; 
- (FishCell *) getFishCellAtX: (int) probedX Y: (int) probedY; 
- probeFishAtX: (int) probedX Y: (int) probedY;
- tagUpstreamLinksToDSCells;
- tagUpstreamLinksToUSCells;
- tagDownstreamLinksToUSCells;
- tagDownstreamLinksToDSCells;
- tagUpstreamCells;
- tagDownstreamCells;
- tagCellNumber: (int) aPolyCellNumber;
- unTagAllPolyCells;
- calcPolyCellCentroids;
- createPolyAdjacentCells;
- readPolyCellDataFile;
- calcPolyCellsDistFromRE;
- checkCellsForCellDepth;
- checkCellsForCellVelocity;
- outputCellCentroidRpt;
- outputCellCorners;
- (id <List>) getPolyCellList;
- (unsigned int) getPolyPixelsX;
- (unsigned int) getPolyPixelsY;
- (FishCell *) getCellWithCellNum: (int) aCellNum;
//
// END POLY CELLS
//


- setFlowFile: (char *) aFile;
- setTemperatureFile: (char *) aFile;
- setTurbidityFile: (char *) aFile;
- setCellHabVarsFile: (char *) aFile;
- createTimeSeriesInputManagers;


- setSpaceDimensions;
- (int) getSpaceDimX;
- (int) getSpaceDimY;

- (time_t) getModelTime;




- setModelStartTime: (time_t) startTime 
         andEndTime: (time_t) endTime;

- setDataStartTime: (time_t) aDataStartTime
        andEndTime: (time_t) aDataEndTime;


// 
// UPDATE
// 
-   updateHabitatWithTime: (time_t) aModelTime_t
    andWithModelStartFlag: (BOOL) aStartFlag;
- updateFishCells;
- switchColorRep;
- toggleCellsColorRep;
- calcWettedArea;
- updateFlowChange;



- (double) getTemperature;

//
// retrieve the total pixels covered by the Cells in X and Y
//
- (unsigned)getPixelsX;
- (unsigned)getPixelsY;

- (double) readTomorrowsFlow: (time_t) aModelTime_t;

- (double) getFlowChange;
- (double) getYesterdaysRiverFlow;
- (double) getRiverFlow;
- (double) getTomorrowsRiverFlow;

- (double) getHabMaxSpawnFlow;

- (double) getDayLength;

- (double) getHabSearchProd;
- (double) getHabDriftConc;
- (double) getHabDriftRegenDist;
- (double) getHabPreyEnergyDensity;
- (double) getHabShelterSpeedFrac;

- buildCellFishInfoReporter;
- outputCellFishInfoReport;

- printCellDepthReport;
- printCellVelocityReport;

- printHabitatReport;
- printCellAreaDepthVelocityRpt;

- (BOOL) getFoodReportFirstTime;
- setFoodReportFirstTime: (BOOL) aBool;
- (BOOL) getDepthVelRptFirstTime;
- setDepthVelRptFirstTime: (BOOL) aBool;

//
// BARRIERS
//
//- buildBarriersFromList: (id <List>) aBarrierXList;


//- setBarrierRasterResolutionX: (int) aResolutionX 
               //andResolutionY: (int) aResolutionY;


//- (id <List>) getBarriers;
//- (int) isThereABarrierTo: aDestCell from: myCell;
//- (BOOL) hasBarrierBetweenDownstreamEndAnd: aCell;
//- (BOOL) hasBarrierBetweenUpstreamEndAnd: aCell;

- (int) isThereABarrierTo: aDestCell from: myCell;



//
// NEW ADJACENT CELL
//
//- _getCellContainingFloatX: (double) probedX floatY: (double) probedY;
- (FishCell *) getFCellWithCellNumber: (int) aCellNumber;

//
// HISTOGRAM
//
- setAreaDepthBinWidth: (int) aWidth;
- setDepthHistoMaxDepth: (double) aDepth;
- setAreaVelocityBinWidth: (int) aWidth;
- setVelocityHistoMaxVelocity: (double) aVelocity;

- setAreaDepthHistoFmtStr: (char *) aFmtStr;
- setAreaVelocityHistoFmtStr: (char *) aFmtStr;

// STRING FUNCTIONS

+ (char *) scrubString: (char *) toScrub withZone: (id) aZone withIgnoredCharacters: (char *) ignoredCharacters;
+ (void) unQuote: (char *) toScrub;

//
// CLEANUP
//
- (void) drop;




@end
