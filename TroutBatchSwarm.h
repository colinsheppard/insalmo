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



// The TroutObserverSwarm is a swarm of objects set up to observe a
// Trouts model when the graphical interface is running. The most
// important object is the aTroutModelSwarm, but we also have
// graphical windows and data analysis and stuff.

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
