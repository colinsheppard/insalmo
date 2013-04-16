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



#import "globals.h"
#import "HabitatSpace.h"
#import "FishCell.h"
#import "TimeManager.h"
#import "TroutModelSwarmP.h"
#import "DEBUGFLAGS.h"
#import "FishParams.h"
#import <random.h>

@interface TroutRedd: SwarmObject
{
  id reddZone;

  id <Symbol> species;
  const char* Species;
  int speciesNdx;
  FishParams* fishParams;

  id <TimeManager> timeManager;
  time_t createTime;

  // generic Redd properties.

  int superimpCount;

  int    numberOfEggs;
  int    initialNumberOfEggs;
  int    numEggsToEmerge;    // Number of eggs to turn into new fish today
  int    emergeDays;         // number of days since fully developed

  double  fracDeveloped;   // range [0-1] - used to determine emergence of new fish
  double  spawnerLength;      // cm
  double  spawnerWeight;
  int     spawnerAge;
  BOOL    iAmGuarded;
  
  int numberOfEggsLostToDewatering;
  int numberOfEggsLostToScouring;
  int numberOfEggsLostToLowTemp;
  int numberOfEggsLostToHiTemp;
  int numberOfEggsLostToSuperimp;

  id <UniformDoubleDist> reddUniformDist;
  id <BinomialDist> reddBinomialDist;

  //
  //Things a Redd needs to know about its Cell
  //
  id myCell;             // Cell
  int cellNumber;
  Color myColor;
  unsigned myRasterX, myRasterY;

  id <TroutModelSwarm> model;

  int createDate;

  id <List> printList;
  id <List> survPrintList;

  char* summaryString;


  // probe modifiable properties

@public

}

- setCell: (FishCell *) aCell;
- setModel;
- setTimeManager: (id <TimeManager>) aTimeManager;
- setReddBinomialDist: (id <BinomialDist>) aBinomialDist;
- setCellNumber: (int) aCellNumber;
- (FishCell *) getCell;

- setRasterX: (unsigned) anX;
- setRasterY: (unsigned) aY;

- createEnd;

- (double) getDepth;
- (double) getVelocity;


- drawSelfOn: (id <Raster>) aRaster;
- setReddColor: (Color) aColor;
- (Color) getReddColor;

- setCreateTimeT: (time_t) aCreateTime;
- (time_t) getCreateTimeT;
- (time_t) getCurrentTimeT;
- setIAmGuarded: (BOOL) aBOOL;
- (BOOL) getIAmGuarded;

- setSpecies: (id <Symbol>) aSymbol;
- (id <Symbol>) getSpecies;
- setSpeciesNdx: (int) aSpeciesNdx;
- (int) getSpeciesNdx;
- setFishParams: (FishParams *) aFishParams;
- (FishParams *) getFishParams;
- setNumberOfEggs: (int) anInt;
- setSpawnerLength: (double) aDouble;
- (double) getSpawnerLength;
- setSpawnerWeight: (double) aWeight;
- (double) getSpawnerWeight;
- setSpawnerAge: (int) anAge;
- (int) getSpawnerAge;
- setPercentDeveloped: (double) aPercent;

//
// BASIC REDD DAILY ROUTINES
//
- survive;
- develop;
- emerge;
- removeWhenEmpty;
- turnMyselfIntoAFish;

// Report Methods
- printReport;
- createPrintString: (int) eggsLostToDewatering
                   : (int) eggsLostToScouring
                   : (int) eggsLostToLowTemp
                   : (int) eggsLostToHiTemp
                   : (int) eggsLostToSuperimp
                   : (time_t) aModelTime_t;

- printReddSurvReport: (FILE *) printRptPtr;
- createSurvPrintStringWithDewaterSF: (double) aDewaterSF
                         withScourSF: (double) aScourSF
                        withLoTempSF: (double) aLoTempSF
                        withHiTempSF: (double) aHiTempSF
                      withSuperimpSF: (double) aSuperimpSF;


- createReddSummaryStr;
- printReddSummary;
- (void) drop;

@end

