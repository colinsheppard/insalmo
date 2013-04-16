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



#import <objc/objc-api.h>
#import <objectbase.h>
#import <string.h>
#import <stdlib.h>

#import "SearchElement.h"

@interface ScenarioIterator : SearchElement 
{

  id <Zone> scenarioIterZone;

  char *oldParameter;
  Class parameterClass;

  id <Index> experParamNdx;

  int numScenarios;
  int numReplicates;

  int scenarioCount;
  int replicateCount;

  int classCount;

  int numProbes;

  id <Map> iterMap;

  id <List> updateScenarioClassList;
  id <ListIndex> scenarioNdx;
  id <List> updateReplicateClassList;
  id <ListIndex> replicateNdx;

  id <VarProbe> aProbe;

  id <List> classList;
  id <List> instanceNameList;
  id <Map> paramClassInstanceNameMap;

}

+ createBegin: aZone;

- createEnd;

- nextFileSetOnObject: (id) theObject;

- (BOOL) canWeGoAgain;
 
- nextControlSetOnObject: (id) theObject
        withInstanceName: (id <Symbol>) anInstanceName;

-  appendToIterSetParam: (const char *) newParam
          withParamType: (char) aParamType 
                ofClass: (Class) paramClass
       withInstanceName: (id <Symbol>) anInstanceName
             paramValue: (void *) paramValue;



- setNumScenarios: (int) aNumScenarios;
- setNumReplicates: (int) aNumReplicates;

- checkParameters;
- (int) getIteration;


- sendScenarioCountToParam: (const char *) newParam
                   inClass: (Class) paramClass;

- sendReplicateCountToParam: (const char *) newParam
                    inClass: (Class) paramClass;

- updateClassScenarioCounts: (id) inObject;
- updateClassReplicateCounts: (id) inObject;

- calcStep;
@end
