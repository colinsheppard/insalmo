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



// The TroutBatchSwarm is to run a
// Trout model when the graphical interface is NOT running. The most
// important object is the aTroutModelSwarm

#import <objectbase.h>
#import <analysis.h>
#import <simtools/ObjectLoader.h>
#import <simtools.h>
#import "TroutModelSwarm.h"
#import "globals.h"

@interface TroutBatchSwarm: Swarm
{


  char * modelSetupFile;


  BOOL finished;

  id <Schedule> batchSchedule;

  id <Activity> modelActivity;

  id outputSchedule;

  TroutModelSwarm *troutModelSwarm;	  	// the Swarm we're observing
  id <Zone> obsZone;

  //
  // Included here are variables necessary for the
  // building of the utm cells. These variables are
  // read in by the ObjectLoader in the create method.
  // 
  int    rasterResolutionX;
  int    rasterResolutionY;
  char*  rasterColorVariable;
  char*  takeRasterPictures;

  double shadeColorMax;
  int maxShadeDepth;
  int maxShadeVelocity;

  char* tagFishColor;
  char* tagCellColor;
  char* dryCellColor;

@public
  int modelNumber;

}

// Methods overriden to make the Swarm.
+ create: aZone;

+ createBegin: aZone;
- createEnd;

- (id) getModel;

- objectSetup;
- buildObjects;
- buildActions;

- activateIn: swarmContext;
- checkToStop;
- (BOOL) areYouFinishedYet;
- setModelNumberTo: (int) anInt;
- iAmAlive;
- (void) drop;

- (id <Swarm>) getModelSwarm;
- (id <Zone>) getObsZone;

@end
