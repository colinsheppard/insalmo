/*
inSTREAM Version 4.3, September 2006
Individual-based stream trout modeling software. Developed and maintained by Steve Railsback (Lang, Railsback & Associates, Arcata, California) and
Steve Jackson (Jackson Scientific Computing, McKinleyville, California).
Development sponsored by EPRI, US EPA, USDA Forest Service, and others.
Copyright (C) 2006 Lang, Railsback & Associates.

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





#import <objectbase/SwarmObject.h>
#import <gui.h>
#import <random.h>

#import <math.h>
#import <stdlib.h>

#import "globals.h"
#import "TimeManagerProtocol.h"
#import "TroutModelSwarmP.h"
#import "SurvMGRProtocol.h"
#import "InterpolationTableP.h"

#import "PolyCell.h"

//#define FOOD_AVAIL_REPORT


@interface FishCell : PolyCell
{
  id space;  // space of which Im a member
  id reach;  // The reach in which I belong; actually the space
  id <TroutModelSwarm> model;

  id <TimeManager> timeManager;

  id myRandGen;

  int numberOfSpecies;
  int numberOfFish;
  int numberOfRedds;
  double cellDistToHide;
  id <List> fishIContain;
  id <List> reddsIContain;

  id <Map> fishParamsMap;
  id <Map> survMgrMap;
  id <Map> survMgrReddMap;
  id <Symbol> ANIMAL;
  id <Symbol> HABITAT;

  double cellFracSpawn;
  double cellAvailableGravelArea;
  double maxAvailableGravelArea;
  id <List> spawnersIContain;
  double cellFracShelter;
  double cellShelterArea;
  double shelterAreaAvailable;
  BOOL   isShelterAvailable;

  double driftHourlyCellTotal;
  double searchCellTotal;
  double searchHourlyCellTotal;
  double hourlyAvailDriftFood;
  double hourlyAvailSearchFood;

  double habShearParamA;
  double habShearParamB;
  double habShelterSpeedFrac;

  //
  // For exception handling
  //
  BOOL cellDataSet;

  
  BOOL foodReportFirstTime;
  BOOL depthVelRptFirstTime;


  double shadeColorMax;

  char reachEnd;
  double cellDistToUS;
  double cellDistToDS;
}
+ create: aZone;
- buildObjects;


- setSpace: aSpace;
- getSpace;

- setReach: aReach;
- getReach;

- setReachEnd: (char) aReachEnd;
- (char) getReachEnd;

- calcCellDistToUS;
- calcCellDistToDS;

- (double) getCellDistToUS;
- (double) getCellDistToDS;


- setTimeManager: (id <TimeManager>) aTimeManager;
- setModel: (id <TroutModelSwarm>) aModel;
- setRandGen: aRandGen;
- getRandGen;


- setFishParamsMap: (id <Map>) aMap;

- setFishParamsMap: (id <Map>) aMap;
- setNumberOfSpecies: (int) aNumberOfSpecies;

- setHabShearParamA: (double) aShearParamA
     habShearParamB: (double) aShearParamB;

- (double) getHabShearParamA;
- (double) getHabShearParamB;

- setHabShelterSpeedFrac: (double) aShelterSpeedFrac;
- (double) getHabShelterSpeedFrac;

- tagDestCells;

- getNeighborsWithin: (double) aRange
            withList: (id <List>) aCellList;

- getNeighborsInReachWithin: (double) aRange
            withList: (id <List>) aCellList;

- (int) getNumberOfFish;
- (id <List>) getFishIContain;
- (int)getNumberOfRedds;
- (id <List>) getReddsIContain;

- (double) getFlowChange;

//- (double) getSpawnQualityForFish: aFish;

//SHELTER AREA
- (void) setCellFracShelter: (double) aDouble;
- (void) calcCellShelterArea;
- (double) getShelterAreaAvailable;
- (void) resetShelterAreaAvailable;
- (BOOL) getIsShelterAvailable;

- setCellFracSpawn: (double) aFracSpawn;
- (double) getCellFracSpawn;

- calcMaxAvailGravelArea;
- calcCellAvailableGravelArea;
- (double) getCellAvailableGravelArea;


- (double) getCellFracShelter;

- eatHere: aFish;
- addFish: aFish;
- removeFish: aFish;
- addRedd: aRedd;
- removeRedd: aRedd;


- (double) getTemperature;
- (double) getTurbidity;
- (double) getDayLength;


- (double) getHabPreyEnergyDensity;

- setDistanceToHide: (double) aDistance;
- (double) getDistanceToHide;


// FOOD METHODS
-  calcDriftHourlyTotal;
- (double) getHourlyAvailDriftFood;
- calcSearchHourlyTotal;
- (double) getHourlyAvailSearchFood;

- (double) getPolyCellDepth;
- (BOOL) isDepthGreaterThan0;


// mortality risk mods

//SURVIVAL PROBABILITIES
- initializeSurvProb;
- updateHabitatSurvivalProb;
- updateFishSurvivalProbFor: aFish;
- updateReddSurvivalProbFor: aRedd;
- updatePolyCellVelocityWith: (double) aFlow;

- (id <List>) getListOfSurvProbsFor: aFish;
- (id <List>) getReddListOfSurvProbsFor: aRedd;
- (double) getTotalKnownNonStarvSurvivalProbFor: aFish;
- (double) getStarvSurvivalFor: aFish;


- (double) getYesterdaysRiverFlow;
- (double) getRiverFlow;            // These two get methods are
- (double) getTomorrowsRiverFlow;   // pass throughs to the habitatSpace

- (void) updateDSCellHourlyTotal;
- (void) resetAvailHourlyTotal;

#ifdef FOOD_AVAIL_REPORT
- foodAvailAndConInCell: aFish;
#endif

- depthVelReport: (FILE *) depthVelPtr;


//
// Barrier pass through to habitat space 
//
- (int) isThereABarrierTo: aCell;

- (double) getHabDriftConc;
- (double) getHabSearchProd;



- (double) getCellVelocity;

- setShadeColorMax: (double) aShadeColorMax;
- toggleColorRep: (double) aShadeColorMax;
- tagPolyCell;
- unTagPolyCell;
- tagAdjacentCells;
- unTagAdjacentCells;
- tagCellsWithin: (double) aRange;
- drawSelfOn: (id <Raster>) aRaster;


- setCellDataSet: (BOOL) aBool;
- checkCellDataSet;


- checkVelocityInterpolator;
- checkDepthInterpolator;

- (void) drop;

@end






