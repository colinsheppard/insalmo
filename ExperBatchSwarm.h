/*
inSTREAM Version 4.2, October 2006.
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


#import <stdlib.h>
#import <objc/objc-api.h>
#import <objectbase.h>
#import <simtools.h>
#import <analysis.h>
#import <activity.h>
#import <collections.h>
#import "TroutBatchSwarm.h"

// First, the interface for the ParameterManager

id <Symbol> NONE;

@interface ParameterBatchManager: Swarm {

  id modelIterator;
  id <Zone> parameterZone;
  id <List> managedClasses;
  id <List> instanceNames;
}

- initializeParameters;
- initializeModelFor: (id ) subSwarm
      andSwarmObject: (id ) aSwarmObject
    withInstanceName: (id <Symbol>) anInstanceName;
- (BOOL) canWeGoAgain;
- (id <List>) getManagedClasses;
- (id <List>) getInstanceNames;


@end


@interface ExperBatchSwarm: Swarm
{
  int numExperimentsRun;

  id experSchedule;
  id testSchedule;

  TroutBatchSwarm * subSwarm;

  id * modelSwarm;
  id <List> experClassList;
  id <ListIndex> experClassNdx;

  id <List> experInstanceNames;
  id <ListIndex> experInstanceNameNdx;

  ParameterBatchManager *parameterManager;

  id <Activity> subswarmActivity;

  id <Zone> experZone;

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

- go;


@end



@interface BatchTestInput : SwarmObject
{
   //no vars
}

+ create: aZone;

- testInputWithDataType: (char *) varType
           andWithValue: (char *) varValue
       andWithParamName: (char *) varName;
        

- (void) drop;

@end



