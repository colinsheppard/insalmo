/*
inSTREAM Version 4.3, October 2006.
Individual-based stream trout modeling software. Developed and maintained by Steve Railsback (Lang, Railsback & Associates, Arcata, California) and
Steve Jackson (Jackson Scientific Computing, McKinleyville, California).
Development sponsored by EPRI, US EPA, USDA Forest Service, and others.
Copyright (C) 2004 Lang, Railsback & Associates.

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



#import <simtools.h>

#import "TimeManagerProtocol.h"
#import "HabitatSetup.h"
#import "HabitatSpace.h"
#import "TroutModelSwarmP.h"
#import "SolarManagerP.h"
#import "globals.h"
#import "PolyInputData.h"

//#define DEPTH_REPORT_ON
//#define VELOCITY_REPORT_ON

//
// HABITAT_REPORT is the only output on daily flow etc. in each reach
//
//#define HABITAT_REPORT_ON

//#define DEPTH_VEL_RPT


@interface HabitatManager: SwarmObject
{

id <TroutModelSwarm> model;
id <Zone> habManagerZone;
id <SolarManager> solarManager;
double siteLatitude;

int numHabitatSpaces;

int numberOfSpecies;
id <Map> fishParamsMap;

//
// Time variables
//
id <TimeManager> timeManager;
time_t modelTime;
char modelDate[12];
time_t runStartTime;
time_t runEndTime;
time_t dataStartTime;
time_t dataEndTime;



id <List> habitatSetupList;
id <List> habitatSpaceList;
id <ListIndex> habitatSpaceNdx;

char* rasterColorVariable;
int rasterResolution;
int rasterResolutionX;
int rasterResolutionY;


//  
//  Poly CELLS
//  
int polyRasterResolution;
int polyRasterResolutionX;
int polyRasterResolutionY;
char polyRasterColorVariable[35];
double shadeColorMax;

}

+ createBegin: aZone;
- createEnd;

- instantiateObjects;
- setModel: aModel;
- setTimeManager: (id <TimeManager>) aTimeManager;
- setModelStartTime: (time_t) aRunStartTime
         andEndTime: (time_t) aRunEndTime;

- setDataStartTime: (time_t) aDataStartTime
        andEndTime: (time_t) aDataEndTime;

- setSiteLatitude: (double) aLatitude;

- (int) getNumberOfHabitatSpaces;
- getHabitatSpaceList;
- getReachWithName: (char *) aReachName;

- readReachSetupFile: (char *) aReachSetupFile;


- setNumberOfSpecies: (int) aNumberOfSpecies;
- setFishParamsMap: (id <Map>) aMap;


-    setPolyRasterResolution: (int) aPolyRasterResolution
    setPolyRasterResolutionX: (int) aPolyRasterResolutionX
    setPolyRasterResolutionY: (int) aPolyRasterResolutionY
     setRasterColorVariable:  (char *) aRasterColorVariable
           setShadeColorMax:  (double) aShadeColorMax;

- buildObjects;

- updateHabitatManagerWithTime: (time_t) aTime
         andWithModelStartFlag: (BOOL) aStartFlag;

-  setShadeColorMax: (double) aShadeColorMax
     inHabitatSpace: aHabitatSpace;
- toggleCellsColorRepIn: aHabitatSpace;

- instantiateHabitatSpacesInZone: (id <Zone>) aZone;
- finishBuildingTheHabitatSpaces;
- buildHabSpaceCellFishInfoReporter;
- createSolarManager;
- buildReachJunctions;

// 
// FILE OUTPUT
//
- outputCellFishInfoReport;


#ifdef DEPTH_REPORT_ON
- printCellDepthReport;
#endif


#ifdef VELOCITY_REPORT_ON
- printCellVelocityReport;
#endif

#ifdef HABITAT_REPORT_ON
- printHabitatReport;
#endif

#ifdef DEPTH_VEL_RPT
- printCellAreaDepthVelocityRpt;
#endif

- (void) drop;

@end

