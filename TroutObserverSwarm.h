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



// The TroutObserverSwarm is a swarm of objects set up to observe a
// Trouts model when the graphical interface is running. The most
// important object is the aTroutModelSwarm, but we also have
// graphical windows and data analysis and stuff.

/*
#import <analysis.h> // EZGraph
#import <simtools/ObjectLoader.h>
#import <simtoolsgui.h>
#import <simtoolsgui/GUISwarm.h>
#import "TroutModelSwarm.h"
#import "globals.h"
*/

#import <analysis.h> // EZGraph
#import <simtools/ObjectLoader.h>
#import <simtools.h>
#import <objectbase/Swarm.h>
#import "TroutModelSwarm.h"
#import "globals.h"



//@interface TroutObserverSwarm: GUISwarm
@interface TroutObserverSwarm: Swarm
{
  id <ProbeMap> probeMap;
  BOOL finished;

  id experSwarm;


//THE FOLLOWING VARIABLES ARE INITIALIZED BY Observer.Setup

  int rasterOutputFrequency;
 id <ProbeMap> habitatProbeMap;

 id <Activity> myActivity;
 id <Activity> modelActivity;

@protected  // the default scope level
  char*  rasterColorVariable;
  int    displayFrequency;				// one parameter: update freq

@public
  char*  takeRasterPictures;



@protected 

//END VARIABLES INITIALIZED BY Observer.Setup


  id displayActions;				// schedule data structs
  id displaySchedule;
  id outputSchedule;


  TroutModelSwarm *troutModelSwarm;	  	// the Swarm we're observing
  char * modelSetupFile;                        // the default is Model.Setup
                                                // this variable can be set 
                                                // from the ExperSwarm
  id <Zone> obsZone;
  id <ProbeMap> obsProbeMap;

  /*
   * displaying the cells and fish -- The HabitatSpace consists of 
   * cells, which are irregular and contain fish (and other things).
   * the raster we allocate here will be the result of a double 
   * indirect display via the Cells.
   */
  char toggleColorVariable[35];

  id <Colormap> polyColormap;			// allocate colours
  id <Colormap> depthColormap;
  id <Colormap> velocityColormap;
  id <Symbol> Depth;
  id <Symbol> Velocity;
  id <Symbol> currentRepresentation;
  id <Map> polyColorMaps;

  id <Object2dDisplay> cellDisplay;	        // display the trout

  id <List> habitatRasterList;	       // 2d display widgets
  id <List> habCellDisplayList;       // display the trout

  
  id <Map> habitatRasterMap;
  id <Map> habColormapMap;
  id <Map> habCellDisplayMap;


  id <EZBin> populationHisto;
  id <EZBin> velocityHisto;
  id <EZBin> depthHisto;
  
  id <EZBin> juveLengthHisto;
  id <EZGraph> mortAgeClassGraph;
  id <EZBin> mortAgeClassHist;
  id <EZGraph> mortalityGraph;
  id <EZGraph> outmigrantGraph;



  //
  // POLY Cell Display
  //
  int    rasterResolutionX;
  int    rasterResolutionY;

  int polyRasterX;
  int polyRasterY;

  id <Object2dDisplay> polyCellDisplay;	        // display the trout

  char* tagFishColor;
  char* tagCellColor;
  char* dryCellColor;

  double shadeColorMax;
  int maxShadeDepth;
  int maxShadeVelocity;

@public
  int modelNumber;
}

// Methods overriden to make the Swarm.

+ create: aZone;
//+ createBegin: aZone;
//- createEnd;

- (id) getModel;

- buildProbesIn: aZone;
- buildFishProbes;

- objectSetup;
- buildObjects;
- polyRasterDeath : caller;
- switchColorRepFor: aHabitatSpace;
- redrawRasterFor: aHabitatSpace;

//- useActionCache: (id <ActionCache>) anActionCache;
- buildActions;


//
// Sends a message to ExperSwarm to
// updateTkEvents
//
- setExperSwarm: anExperSwarm;

- updateTkEventsFor: aHabitatSpace;

//- (int) getMySpeciesPop;
- activateIn: swarmContext;
- checkToStop;
- (BOOL) areYouFinishedYet;
- setModelNumberTo: (int) anInt;
- (void) writeFrame;
- iAmAlive;
- (void) drop;

- (id <Swarm>) getModelSwarm;

//- (id <Raster>) getWorldRaster;

- (char *) getTagFishColor;
- (char *) getDryCellColor;
- (char *) getTagCellColor;



- polyRasterDeath: caller;

@end
