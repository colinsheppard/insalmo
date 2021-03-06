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

#import <objc/objc-api.h>
#import <simtoolsgui/GUISwarm.h>
#import <objectbase/SwarmObject.h>
#import <objectbase.h>
#import <analysis.h>
#import <analysis/EZGraph.h>

#import "TroutObserverSwarm.h"

// First, the interface for the ParameterManager

id <Symbol> NONE;

@interface ParameterManager: SwarmObject {

  id modelIterator;

  id <Zone> parameterZone;
  id <ProbeMap> paramProbeMap;

  id <List> managedClasses;
  id <List> instanceNames;
}

- initializeParameters;
- initializeModelFor: (id ) subSwarm
      andSwarmObject: (id ) aSwarmObject
    withInstanceName: (id <Symbol>) anInstanceName;
- (BOOL) canWeGoAgain;
//- printParameters: anOutFile;
- (id <List>) getManagedClasses;
- (id <List>) getInstanceNames;

@end




@interface ExperSwarm: GUISwarm
{
  int numExperimentsRun;

  id dynRunGroup;
  id testRunGroup;

  id experSchedule;
  id testSchedule;

  TroutObserverSwarm* subSwarm;
  id <ActivityControl> subSwarmControl;

  id * modelSwarm;
  id <List> experClassList;
  id <ListIndex> experClassNdx;

  id <List> experInstanceNames;
  id <ListIndex> experInstanceNameNdx;

  ParameterManager *parameterManager;

  id <Activity> subswarmActivity;

  id <ProbeMap> modelProbeMap;

}

+ createBegin: aZone;
- createEnd;
- setupModel;
- buildModel;
- runModel;
- dropModel;
- checkToStop;

- buildObjects;
- buildActions;
- activateIn: swarmContext;
- updateTkEvents;

- (void) exitNow;


@end

@interface TestInput : SwarmObject
{
   //no vars

}

+ create: aZone;

- testInputWithDataType: (char *) varType
           andWithValue: (char *) varValue
       andWithParamName: (char *) varName;
        

@end



