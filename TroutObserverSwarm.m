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



#import "TroutObserverSwarm.h"
#import "TroutModelSwarm.h"
#import "ExperSwarm.h"
#import <collections.h>
#import <objectbase.h>
#import <gui.h>




@implementation TroutObserverSwarm

//////////////////////////////////////////////
//
// create
//
//////////////////////////////////////////
+ create: aZone
{
  TroutObserverSwarm* obj=nil;

  obj = [super create: aZone];

  obj->finished=NO;
  obj->probeMap=nil;
  obj->modelNumber = 1;
  obj->rasterOutputFrequency = 1;
  obj->displayFrequency = 1;
  [obj buildProbesIn: aZone];

  return obj;
}


/////////////////////////////////////////////////////////////////
//
// getModel
//
//////////////////////////////////////////////////////////////
- getModel 
{
  return troutModelSwarm;
}



////////////////////////////////////////////////////////////////
//
// buildProbes
//
///////////////////////////////////////////////////////////////
- buildProbesIn: aZone 
{
   //
   // HabitatSpace
   //
   probeMap = [CustomProbeMap create: aZone forClass: [HabitatSpace class]
			      withIdentifiers: "reachName",
                              "Date",
                              "temperature",
                              "riverFlow",
                              "turbidity",
                          //    "dayLength",
                              "habWettedArea",
                              "habDownstreamJunctionNumber",
                              "habUpstreamJunctionNumber",
                          //    "habSearchProd",
                          //    "habDriftConc",
                          //    "habDriftRegenDist",
                          //    "habPreyEnergyDensity",
                          //    "habMaxSpawnFlow",
                          //    "habShearParamA",
                          //    "habShearParamB",
                          //    "habShelterSpeedFrac",
                              ":",
                              "switchColorRep",
                              "tagUpstreamLinksToDSCells",
                              "tagUpstreamLinksToUSCells",
                              "tagDownstreamLinksToUSCells",
                              "tagDownstreamLinksToDSCells",
                              "tagUpstreamCells",
                              "tagDownstreamCells",
                              "tagCellNumber:",
                              "unTagAllPolyCells",
                              NULL];
   [probeLibrary setProbeMap: probeMap For: [HabitatSpace class]];

   //
   // Poly Cells
   //
   probeMap = [CustomProbeMap createBegin: aZone];
   [probeMap setProbedClass: [FishCell class]];
   probeMap = [probeMap createEnd];

[probeMap addProbe: [probeLibrary getProbeForVariable: "polyCellNumber"
                      inClass: [PolyCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForVariable: "polyCellDepth"
                      inClass: [FishCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForVariable: "polyCellVelocity"
                      inClass: [FishCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForVariable: "numberOfFish"
                      inClass: [FishCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForVariable: "numberOfRedds"
                      inClass: [FishCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForVariable: "polyCellArea"
                      inClass: [PolyCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForVariable: "cellFracSpawn"
                      inClass: [FishCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForVariable: "cellDistToHide"
                      inClass: [FishCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForVariable: "cellShelterArea"
                      inClass: [FishCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForVariable: "shelterAreaAvailable"
                      inClass: [FishCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForVariable: "driftHourlyCellTotal"
                      inClass: [FishCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForVariable: "hourlyAvailDriftFood"
                      inClass: [FishCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForVariable: "searchHourlyCellTotal"
                      inClass: [FishCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForVariable: "hourlyAvailSearchFood"
                      inClass: [FishCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForMessage: "tagPolyCell"
                      inClass: [PolyCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForMessage: "unTagPolyCell"
                      inClass: [PolyCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForMessage: "tagAdjacentCells"
                      inClass: [PolyCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForMessage: "unTagAdjacentCells"
                      inClass: [PolyCell class]]];
   [probeMap addProbe: [probeLibrary getProbeForMessage: "tagCellsWithin:"
                      inClass: [FishCell class]]];

   //
   // Finish adding FishCell's super class vars
   // Don't forget to make clean, then make.
   //

   [probeLibrary setProbeMap: probeMap For: [FishCell class]];


  //
  // The fish probes are defined in buildFishProbes
  //


  //
  // Redds
  //
  probeMap = [CustomProbeMap create: aZone forClass: [TroutRedd class]
			     withIdentifiers: "Species",
                             "iAmGuarded",
			     "numberOfEggs",
                             "emergeDays",
                             "fracDeveloped",
                             "spawnerLength",
                             "cellNo",
                             ":",
                             NULL];
  [probeLibrary setProbeMap: probeMap For: [TroutRedd class]];

    return self;
}




////////////////////////////////////////////////////////////////////
//
// buildFishProbes
//
///////////////////////////////////////////////////////////////////
- buildFishProbes 
{
  id <ListIndex> listNdx;
  id speciesClass;

  probeMap = [CustomProbeMap create: [self getZone] forClass: [Trout class]
			   withIdentifiers: "age",
					    "isSpawner",
					    "fishLength",
					    "fishWeight",
					    "fishCondition",
					    //"prevLength",
					    //"prevWeight",
					    //"prevCondition",
					    //"netEnergyForBestCell",
					    //"dailyDriftFoodIntake",
					    //"dailyDriftNetEnergy",
					    //"dailySearchFoodIntake",
					    //"dailySearchNetEnergy",
					    //"feedTime",
					    //"potentialHourlyDriftIntake",
					    //"potentialHourlySearchIntake",
					    //"cMax",
					    //"standardResp",
					    //"activeResp",
					    "feedStrategy",
					    "inShelter",
					    "deadOrAlive",
					    "deathCausedBy",
					    "captureSuccess",
					    "captureArea",
					    "nonStarvSurvival",
                                            "nRep",
                                            "superindividualWeight",
					    ":",
					    "tagFish",
					    "tagCellsICouldMoveTo",
					    "makeMeImmortal",
                                            "killFish",
					     NULL];

   listNdx = [[troutModelSwarm getSpeciesClassList] listBegin: scratchZone];
   while (([listNdx getLoc] != End) && ((speciesClass = [listNdx next]) != nil)) 
   {
       [probeLibrary setProbeMap: probeMap For: speciesClass];
   }
   [listNdx drop];
[probeDisplayManager setDropImmediatelyFlag: NO];
   return self;
}






- _velocityHistoDeath_ : caller
{
  velocityHisto = nil;
  return self;
}

- _depthHistoDeath_ : caller
{
  depthHisto = nil;
  return self;
}

- _populationHistoDeath_ : caller
{
  //[populationHisto drop];
  populationHisto = nil;
  return self;
}

- _juveLengthHistoDeath_ : caller
{
  //[juveLengthHisto drop];
  juveLengthHisto = nil;
  return self;
}

- _mortalityGraphDeath : caller
{
  //[mortalityGraph drop];
  mortalityGraph = nil;
  return self;
}

- _outmigrantGraphDeath : caller
{
  //[mortalityGraph drop];
  outmigrantGraph = nil;
  return self;
}



//////////////////////////////////////////////////
//
// objectSetup
//
/////////////////////////////////////////////////
- objectSetup 
{

  obsZone = [Zone create: [self getZone]];

  troutModelSwarm = [TroutModelSwarm create: self];
  [troutModelSwarm setObserverSwarm: self];

  [ObjectLoader load: troutModelSwarm fromFileNamed: "Model.Setup"];

   [troutModelSwarm setPolyRasterResolutionX:  rasterResolutionX
                   setPolyRasterResolutionY:  rasterResolutionY 
                 setPolyRasterColorVariable:  rasterColorVariable];
  //troutModelSwarm->rasterResolution = rasterResolution;
  //troutModelSwarm->rasterResolutionX = rasterResolutionX;
  //troutModelSwarm->rasterResolutionY = rasterResolutionY;
  //troutModelSwarm->rasterColorVariable = rasterColorVariable;

  //
  // Instantiate the objects first;
  // this allows the experiment swarm to operate on 
  // model objects BEFORE their final creation 
  //
  [troutModelSwarm instantiateObjects];



  return self;
}



////////////////////////////////////////////////////////
//
// buildObjects
//
///////////////////////////////////////////////////////
- buildObjects
{
  int ndx;

  fprintf(stdout, "TroutObserverSwarm >>>> buildObjects >>>> BEGIN\n");
  fflush(0);


  if((rasterResolutionX <= 0) || (rasterResolutionY <= 0))
  {
     fprintf(stderr, "TroutObserverSwarm >>>> buildObjects >>>> one of the rasterResolution parameters is <= zero\n");
     fflush(0);
     exit(1);
  }

  polyColorMaps = [Map create: obsZone];
  Depth = [Symbol create: obsZone
                 setName: "Depth"];
  depthColormap = [Colormap create: obsZone];

  Velocity = [Symbol create: obsZone
                 setName: "Velocity"];

  velocityColormap = [Colormap create: obsZone];

  [polyColorMaps at: Depth
         insert: depthColormap];

  [polyColorMaps at: Velocity
         insert: velocityColormap];

  habitatRasterMap  = [Map create: obsZone];
  habColormapMap  = [Map create: obsZone];
  habCellDisplayMap = [Map create: obsZone];

  {
       if(maxShadeVelocity <= 0)
       {
           fprintf(stderr, "ERROR: TroutObserverSwarm >>>> maxShadeVelocity is <= 0 >>>> check Observer.Setup\n");
           fflush(0);
           exit(1);
       }
       else shadeColorMax = (double) maxShadeVelocity;
 
       for(ndx = 0; ndx < CELL_COLOR_MAX; ndx++)
       {
             double aRedFrac = 1.0;
             double aGreenFrac = (double) (CELL_COLOR_MAX - 1.0 - ndx)/((double) CELL_COLOR_MAX - 1.0);
             double aBlueFrac = 0.0;

             [velocityColormap setColor: ndx 
                             ToRed: aRedFrac
                             Green: aGreenFrac
                              Blue: aBlueFrac];
  
       }
  }
  {
       if(maxShadeDepth <= 0)
       {
           fprintf(stderr, "ERROR: TroutObserverSwarm >>>> maxShadeDepth is <= 0 >>>> check Observer.Setup\n");
           fflush(0);
           exit(1);
       }
       else shadeColorMax = (double) maxShadeDepth;
 
       for(ndx = 0; ndx < CELL_COLOR_MAX; ndx++)
       {
             double aRedFrac = 0.0;
             double aGreenFrac = (double) (CELL_COLOR_MAX - 1.0 - ndx)/((double) CELL_COLOR_MAX - 1.0);
             double aBlueFrac =  1.0;

             [depthColormap setColor: ndx 
                             ToRed: aRedFrac
                             Green: aGreenFrac
                              Blue: aBlueFrac];

       }
  }



  [depthColormap setColor: POLYBOUNDARYCOLOR ToName: "black"];
  [depthColormap setColor: POLYINTERIORCOLOR ToName: "blue"];
  [depthColormap setColor: TAG_CELL_COLOR ToName: tagCellColor];
  [depthColormap setColor: DRY_CELL_COLOR ToName: dryCellColor];
  [depthColormap setColor: TAG_FISH_COLOR ToName: tagFishColor];

  [velocityColormap setColor: POLYBOUNDARYCOLOR ToName: "black"];
  [velocityColormap setColor: POLYINTERIORCOLOR ToName: "yellow"];
  [velocityColormap setColor: TAG_CELL_COLOR ToName: tagCellColor];
  [velocityColormap setColor: DRY_CELL_COLOR ToName: dryCellColor];
  [velocityColormap setColor: TAG_FISH_COLOR ToName: tagFishColor];
  

   //build model Objects and set the fish color in the ModelSwarm
   //
   [troutModelSwarm setPolyRasterResolutionX:  rasterResolutionX
                   setPolyRasterResolutionY:  rasterResolutionY 
                 setPolyRasterColorVariable:  rasterColorVariable];

   [troutModelSwarm buildObjectsWith: polyColorMaps
                             andWith: shadeColorMax];


  [self buildFishProbes];


  //
  // Build the rasters, display objects, etc from the 
  // HabitatManager 
  // 
  {
       int numberOfSpaces = -1;
       int spaceCount;
       id habitatManager = nil;
       id <List> habSpaceList;

       habitatManager = [troutModelSwarm getHabitatManager];    
       numberOfSpaces = [habitatManager getNumberOfHabitatSpaces];
       habSpaceList = [habitatManager getHabitatSpaceList];
       
       habitatRasterList = [List create: obsZone];
       habCellDisplayList = [List create: obsZone];

       fprintf(stdout, "TroutObserverSwarm >>>> buildObjects >>>> building space display objects >>>> BEGIN\n");
       fflush(0);

       for(spaceCount = 0; spaceCount < numberOfSpaces; spaceCount++)
       {
            id <Raster> polyWorldRaster = nil;
            id habitatSpace = [habSpaceList atOffset: spaceCount];
             
            polyWorldRaster = [Raster createBegin: obsZone];
            [polyWorldRaster setWindowGeometryRecordName: [habitatSpace getReachName]];
            polyWorldRaster = [polyWorldRaster createEnd];
            [polyWorldRaster enableDestroyNotification: self
	                 notificationMethod: @selector (polyRasterDeath:)];

              [habitatRasterMap at: habitatSpace
                            insert: polyWorldRaster];
              [habitatRasterList addLast: polyWorldRaster];

             if(strncmp(rasterColorVariable, "velocity", 8) == 0)
             {
                strncpy(toggleColorVariable, "velocity", 9);
                [polyWorldRaster setColormap: velocityColormap];

                [habColormapMap   at: polyWorldRaster
                              insert:velocityColormap];
                currentRepresentation = Velocity;
             }
             else if(strncmp(rasterColorVariable, "depth", 5) == 0)
             {
                strncpy(toggleColorVariable, "depth", 6);
                [polyWorldRaster setColormap: depthColormap];

                [habColormapMap   at: polyWorldRaster
                              insert: depthColormap];

                currentRepresentation = Depth;
             }
             else
             {
                 fprintf(stderr, "ERROR: TroutObserverSwarm >>>> buildObjects >>>> rasterColorVariable = %s\n", rasterColorVariable);
                 fflush(0);
                 exit(1);
             }


            polyRasterX = [habitatSpace getPolyPixelsX];
            polyRasterY = [habitatSpace getPolyPixelsY];

            //fprintf(stdout, "TroutObserverSwarm >>>> buildObjects >>>> polyRasterX = %d\n", polyRasterX);
            //fprintf(stdout, "TroutObserverSwarm >>>> buildObjects >>>> polyRasterY = %d\n", polyRasterY);
            //fflush(0);

            [polyWorldRaster setWidth: polyRasterX/rasterResolutionX Height: polyRasterY/rasterResolutionY];

            [polyWorldRaster setWindowTitle: [habitatSpace getReachName]];

            [polyWorldRaster pack];				  // draw the window.

            polyCellDisplay = [Object2dDisplay createBegin: obsZone];
            [polyCellDisplay setDisplayWidget: polyWorldRaster];
            [polyCellDisplay setDiscrete2dToDisplay: habitatSpace];
            [polyCellDisplay setObjectCollection: 
		            [habitatSpace getPolyCellList]];
            [polyCellDisplay setDisplayMessage: M(drawSelfOn:)];   // draw method
            polyCellDisplay = [polyCellDisplay createEnd];

            [polyWorldRaster setButton: ButtonLeft
		               Client: habitatSpace 
		              Message: M(probePolyCellAtX:Y:)];

            [polyWorldRaster setButton: ButtonRight
	                       Client: habitatSpace 
	                      Message: M(probeFishAtX:Y:)];

            [habCellDisplayMap at: habitatSpace
                           insert: polyCellDisplay];

         } //for

         fprintf(stdout, "TroutObserverSwarm >>>> buildObjects >>>> building space display objects >>>> END\n");
         fflush(0);

   } // Build Display Objects


  velocityHisto = [EZBin createBegin: obsZone];
  SET_WINDOW_GEOMETRY_RECORD_NAME (velocityHisto);
  [velocityHisto setTitle: "Redd Velocity Histogram"];
  [velocityHisto setAxisLabelsX: "Velocity (cm/s)" Y: "Number of redds"];
  [velocityHisto setBinCount: 10];
  [velocityHisto setLowerBound: 0];
  [velocityHisto setUpperBound: 200];
  [velocityHisto setCollection: [troutModelSwarm getReddList]];
  [velocityHisto setProbedSelector: M(getVelocity)];
  [velocityHisto setFileOutput: YES];
  [velocityHisto setFileName: "ReddVelocityHisto.out"];
  velocityHisto = [velocityHisto createEnd];
  [velocityHisto enableDestroyNotification: self
                notificationMethod: @selector (_velocityHistoDeath_:)];


  depthHisto = [EZBin createBegin: obsZone];
  SET_WINDOW_GEOMETRY_RECORD_NAME (depthHisto);
  [depthHisto setTitle: "Redd Depth Histogram"];
  [depthHisto setAxisLabelsX: "Depth (cm)" Y: "Number of redds"];
  [depthHisto setBinCount: 10];
  [depthHisto setLowerBound: 0];
  [depthHisto setUpperBound: 200];
  [depthHisto setCollection: [troutModelSwarm getReddList]];
  [depthHisto setProbedSelector: M(getDepth)];
  [depthHisto setFileOutput: YES];
  [depthHisto setFileName: "ReddDepthHisto.out"];
  depthHisto = [depthHisto createEnd];
  [depthHisto enableDestroyNotification: self
                notificationMethod: @selector (_depthHistoDeath_:)];


  populationHisto = [EZBin createBegin: obsZone];
  SET_WINDOW_GEOMETRY_RECORD_NAME (populationHisto);
  [populationHisto setTitle: "Population By Age"];
  [populationHisto setAxisLabelsX: "Age (years)" Y: "Number of fish"];
  [populationHisto setBinCount: 7];
  [populationHisto setLowerBound: 0];
  [populationHisto setUpperBound: 7];
  [populationHisto setCollection: [troutModelSwarm getLiveFishList]];
  [populationHisto setProbedSelector: M(getAge)];
  populationHisto = [populationHisto createEnd];
  [populationHisto enableDestroyNotification: self
                notificationMethod: @selector (_populationHistoDeath_:)];

  juveLengthHisto = [EZBin createBegin: obsZone];
  SET_WINDOW_GEOMETRY_RECORD_NAME (juveLengthHisto); 
  [juveLengthHisto setTitle: "Fish Lengths"];
  [juveLengthHisto setAxisLabelsX: "Length (cm)" Y: "Number of live fish"];
  [juveLengthHisto setBinCount: 10];
  [juveLengthHisto setLowerBound: 0];
  [juveLengthHisto setUpperBound: 10];
  [juveLengthHisto setCollection: [troutModelSwarm getLiveFishList]];
  [juveLengthHisto setProbedSelector: M(getFishLength)];
  juveLengthHisto = [juveLengthHisto createEnd];
 
  [juveLengthHisto enableDestroyNotification: self
                notificationMethod: @selector (_juveLengthHistoDeath_:)];


  mortalityGraph = [EZGraph createBegin: self];
  SET_WINDOW_GEOMETRY_RECORD_NAME (mortalityGraph); 
  [mortalityGraph setTitle: "Mortality"];
  [mortalityGraph setAxisLabelsX: "Time" Y: "Number dead"];
  mortalityGraph = [mortalityGraph createEnd];

  //
  // Now create the graph sequences
  //
  {
      id <List> listOfMortalityCounts = [troutModelSwarm getListOfMortalityCounts];
      id <ListIndex> lstNdx = nil;
      id mortalityCount = nil;

      if(listOfMortalityCounts == nil) 
      {
          fprintf(stderr, "ERROR: TroutObserverSwarm >>>> buildObjects >>>> listOfMortalityCounts is nil\n");
          fflush(0);
          exit(1);
      }
  
      lstNdx = [listOfMortalityCounts listBegin: scratchZone];

      [lstNdx setLoc: Start];

      while(([lstNdx getLoc] != End) && ((mortalityCount = [lstNdx next]) != nil)) 
      {
            [mortalityGraph createSequence: [[mortalityCount getMortality] getName]
                              withFeedFrom: mortalityCount
                               andSelector: M(getNumDead)];
      }

      [lstNdx drop];
  }

  [mortalityGraph enableDestroyNotification: self
               notificationMethod: @selector (_mortalityGraphDeath:)];

//
//   New graph of outmigration count
//
  outmigrantGraph = [EZGraph createBegin: self];
  SET_WINDOW_GEOMETRY_RECORD_NAME (outmigrantGraph); 
  [outmigrantGraph setTitle: "Daily Outmigration"];
  [outmigrantGraph setAxisLabelsX: "Time" Y: "Number outmigrants"];
  outmigrantGraph = [outmigrantGraph createEnd];
     [outmigrantGraph createSequence: "All outmigrants"
                        withFeedFrom: troutModelSwarm
                         andSelector: M(getNumOutmigrants)];

  [outmigrantGraph enableDestroyNotification: self
               notificationMethod: @selector (_outmigrantGraphDeath:)];


  //
  // One for each habitat space
  //
  if(troutModelSwarm)
  {
      id <List> aHabitatSpaceList = [[troutModelSwarm getHabitatManager] getHabitatSpaceList]; 
      int habitatSpaceCount = [aHabitatSpaceList getCount];
      int i;

      for(i = 0; i < habitatSpaceCount; i++)
      {
          CREATE_ARCHIVED_PROBE_DISPLAY([aHabitatSpaceList atOffset: i]);
      }
  }

  //fprintf(stdout, "TroutObeserverSwarm >>>> buildObjects >>>> shadeColorMax = %f\n", shadeColorMax);
  //fprintf(stdout, "TroutObeserverSwarm >>>> buildObjects >>>> maxShadeVelocity = %f\n", (double) maxShadeVelocity);
  //fprintf(stdout, "TroutObeserverSwarm >>>> buildObjects >>>> maxShadeDepth = %f\n", (double) maxShadeDepth);
  //fprintf(stdout, "TroutObeserverSwarm >>>> buildObjects >>>> END\n");
  fflush(0);
  return self;
}  

///////////////////////////////
//
// _polyRasterDeath_
//
///////////////////////////////
- polyRasterDeath : caller
{
  //[utmWorldRaster drop];
  return self;
}
 
//////////////////////////////////////////////////
//
// _update_
//
//////////////////////////////////////////////////
- _update_ 
{
//  fprintf(stdout, "TroutObserverSwarm >>>> update >>>> BEGIN\n");
//  fflush(0);

  if (depthHisto) 
  {
    [depthHisto reset];
    [depthHisto update];
    [depthHisto output];
  }  
  if(velocityHisto) 
  {
    [velocityHisto reset];
    [velocityHisto update];
    [velocityHisto output];
  }  
  if(populationHisto)
  {
    [populationHisto reset];
    [populationHisto update];
    [populationHisto output];
  }  
  if(juveLengthHisto)
  {
    [juveLengthHisto reset];
    [juveLengthHisto update];
    [juveLengthHisto output];
  }  
  if(mortalityGraph) 
  {
     [mortalityGraph step];
     [mortalityGraph update];
     [mortalityGraph outputGraph];
  }
  if(outmigrantGraph) 
  {
     [outmigrantGraph step];
     [outmigrantGraph update];
     [outmigrantGraph outputGraph];
  }


   if(habitatRasterMap)
   {
        id habitatManager = [troutModelSwarm getHabitatManager];    
        id habSpaceList = [habitatManager getHabitatSpaceList];
        id habitatSpace = nil;
        id <ListIndex> listNdx = [habSpaceList listBegin: scratchZone];

        while(([listNdx getLoc] != End) && ((habitatSpace = [listNdx next]) != nil))
        {
             [[habitatRasterMap at: habitatSpace] erase];
             [[habCellDisplayMap at: habitatSpace] display];
             [[habitatRasterMap at: habitatSpace] drawSelf];
        }

        [listNdx drop];

    } //if habitatRasterMap
       
//  fprintf(stdout, "TroutObserverSwarm >>>> update >>>> END\n");
//  fflush(0);

  return self;
}

///////////////////////////////////
//
// switchColorRep
//
///////////////////////////////////
- switchColorRepFor: aHabitatSpace
{
  id <Raster> habitatRaster = nil;
  id <Colormap> habitatColormap;

  fprintf(stdout, "TroutObserverSwarm >>>> switchColorRep >>>> BEGIN\n");
  fflush(0);

       habitatRaster = [habitatRasterMap at: aHabitatSpace];
       habitatColormap = [habColormapMap  at: habitatRaster];

      if(habitatColormap == depthColormap)
      {
            [habitatRaster setColormap: velocityColormap];
            [habColormapMap at: habitatRaster replace: velocityColormap];
            if(maxShadeVelocity <= 0)
            {
                fprintf(stderr, "ERROR: TroutObserverSwarm >>>> maxShadeVelocity is <= 0 >>>> check Observer.Setup\n");
                fflush(0);
                exit(1);
            }
            else shadeColorMax = (double) maxShadeVelocity;
      }
      else if(habitatColormap == velocityColormap)
      {
            [habitatRaster setColormap: depthColormap];
            [habColormapMap at: habitatRaster replace: depthColormap];

            if(maxShadeDepth <= 0)
            {
                fprintf(stderr, "ERROR: TroutObserverSwarm >>>> maxShadeVelocity is <= 0 >>>> check Observer.Setup\n");
                fflush(0);
                exit(1);
            }
            else shadeColorMax = (double) maxShadeDepth;
      }
      
      [troutModelSwarm setShadeColorMax: shadeColorMax
                         inHabitatSpace: aHabitatSpace]; 
      [troutModelSwarm toggleCellsColorRepIn: aHabitatSpace];
      [self redrawRasterFor: aHabitatSpace];
    
  fprintf(stdout, "TroutObserverSwarm >>>> switchColorRep END\n");
  fflush(0);

  return self;
}


////////////////////////////////////
//
// redrawRaster
//
//////////////////////////////////
- redrawRasterFor: aHabitatSpace
{
   fprintf(stdout, "TroutObserverSwarm >>>> redrawRaster >>>> BEGIN\n");
   fflush(0);

       [[habitatRasterMap at: aHabitatSpace] erase];
       [[habCellDisplayMap at: aHabitatSpace] display];
       [[habitatRasterMap at: aHabitatSpace] drawSelf];

    fprintf(stdout, "TroutObserverSwarm >>>> redrawRaster >>>> END\n");
    fflush(0);

    return self;
}


//////////////////////////////////////////////////
//
// buildActions
//
//////////////////////////////////////////////////
- buildActions
{
  [super buildActions];
  [troutModelSwarm buildActions];

  displayActions = [ActionGroup create: obsZone];
  [displayActions createActionTo: self message: M(_update_)];
  [displayActions createActionTo: probeDisplayManager message: M(update)];


  displaySchedule = [Schedule createBegin: obsZone];
  [displaySchedule setRepeatInterval: displayFrequency]; // note frequency!
  displaySchedule = [displaySchedule createEnd];
  [displaySchedule at: 0 createAction: displayActions];
  [displaySchedule at: 0 createActionTo: self message: M(checkToStop)];
  
  if (rasterOutputFrequency > 0) {
    outputSchedule = [Schedule createBegin: obsZone];
    [outputSchedule setRepeatInterval: rasterOutputFrequency];
    outputSchedule = [outputSchedule createEnd];
    if ((strcmp(takeRasterPictures, "YES") == 0) ||
	(strcmp(takeRasterPictures, "yes") == 0) ||
	(strcmp(takeRasterPictures, "Yes") == 0) ||
	(strcmp(takeRasterPictures, "Y") == 0) ||
	(strcmp(takeRasterPictures, "y") == 0))
      [outputSchedule at: 0 createActionTo: self message: M(writeFrame)];
  }

  return self;
}  


/////////////////////////////////////////
//
// setExperSwarm
//
/////////////////////////////////////////
- setExperSwarm: anExperSwarm
{
    experSwarm = anExperSwarm;
    return self;
}

//////////////////////////////////////////////////////////
//
// updateTkEvents
//
// called from the model swarm when tagFish is invoked.
//
/////////////////////////////////////////////////////////
- updateTkEventsFor: aHabitatSpace
{
    id <Raster> habitatRaster = nil;

   //fprintf(stdout, "TroutObserverSwarm >>>> updateTkEvents >>>> BEGIN\n");
   //fflush(0); 


   if(experSwarm == nil)
   {
       fprintf(stderr, "ERROR: TroutObserverSwarm >>>> updateTkEvents >>>> experSwarm is nil\n");
       fflush(0);
       exit(1);
   }


   habitatRaster = [habitatRasterMap at: aHabitatSpace] ;
   [habitatRaster erase];
   [[habCellDisplayMap at: aHabitatSpace] display];
   [habitatRaster drawSelf];

   [experSwarm updateTkEvents];

   //fprintf(stdout, "TroutObserverSwarm >>>> updateTkEvents >>>> END\n");
   //fflush(0); 

   return self;
}



/////////////////////////////////////////////
//
// activateIn
//
////////////////////////////////////////////
- activateIn:  swarmContext
{

  fprintf(stderr, "OBSERVER SWARM >>>> activateIn begin\n");
  fprintf(stderr, "OBSERVER SWARM >>>> activateIn begin super = %s\n", [super getName]);
  fprintf(stderr, "OBSERVER SWARM >>>> activateIn begin swarmContext = %p\n", swarmContext);
  //fprintf(stderr, "OBSERVER SWARM >>>> activateIn begin actionCache = %p\n", actionCache);
  fflush(0);

  [super activateIn: swarmContext];
  modelActivity = [troutModelSwarm activateIn: self];
  fprintf(stderr, "OBSERVER SWARM >>>> activateIn modelActivity = %p\n", modelActivity);
  fflush(0);
  [displaySchedule activateIn: self];
  fprintf(stderr, "OBSERVER SWARM >>>> activateIn displaySchedule = %p\n", displaySchedule);
  fflush(0);
  if (rasterOutputFrequency > 0)
  {
    [outputSchedule activateIn: self];
  }

  myActivity = [self getActivity];

  fprintf(stderr, "OBSERVER SWARM >>>> activateIn returning myActivity = %p\n", myActivity);
  fflush(0);

  return [self getActivity];
}



////////////////////////////////
//
// checkToStop
//
////////////////////////////////
- checkToStop
{

  if([troutModelSwarm whenToStop] == YES) 
  {
    finished = YES;
    modelActivity = nil;
    [[self getActivity] stop];
 
    fprintf(stdout,"TroutObserverSwarm >>>> Stop date achieved\n");
    fflush(0);

  }


  return self;
}



/////////////////////////////////////////////
//
// getTagCellColor
//
////////////////////////////////////////////
- (char *) getTagCellColor
{
  return tagCellColor;
}

/////////////////////////////////////////////
//
// getDryCellColor
//
////////////////////////////////////////////
- (char *) getDryCellColor
{
  return dryCellColor;
}

/////////////////////////////////////////////
//
// getTagFishColor
//
////////////////////////////////////////////
- (char *) getTagFishColor
{
   return tagFishColor;
}



- (BOOL) areYouFinishedYet 
{
  return finished;
}

- setModelNumberTo: (int) anInt 
{
  modelNumber = anInt;
  return self;
}

-(void) writeFrame 
{
  char filename[256];
  id pixID;
  id raster = nil;

  fprintf(stdout, "TroutObserverSwarm >>>> writeFrame >>>> BEGIN\n");
  fflush(0);

  if([habitatRasterList getCount] > 0)
  {
      raster = [habitatRasterList getFirst];
 
      if(raster == nil)
      {
         fprintf(stderr, "ERROR: TroutModelSwarm >>>> writeFrame >>>> raster is nil\n");
         fflush(0);
         exit(1);
      }

      sprintf(filename, "Model%03d_Frame%03ld.png", modelNumber, getCurrentTime());

      pixID =  [Pixmap createBegin: [self getZone]];
      [pixID  setWidget: raster];
      pixID = [pixID createEnd];
      [pixID save: filename];
      [pixID drop];
  }

  fprintf(stdout, "TroutObserverSwarm >>>> writeFrame >>>> END\n");
  fflush(0);

}


- iAmAlive 
{
  static int iveBeenCalled=0;
  iveBeenCalled++;
  (void) fprintf(stdout, "TroutObserverSwarm is alive. (%d)\n", iveBeenCalled); 
  fflush(0);
  return self;
}

- (void) drop 
{
  fprintf(stdout,"TroutObserverswarm >>>> drop >>>> BEGIN\n");
  fflush(0);

  [probeDisplayManager setDropImmediatelyFlag: NO];

  if(habitatRasterList)
  {
      [habitatRasterList deleteAll];
      [habitatRasterList drop];
      habitatRasterList = nil;
  }
  if(habCellDisplayList)
  {
      [habCellDisplayList deleteAll];
      [habCellDisplayList drop];
      habCellDisplayList = nil;
  }
            
  if(polyCellDisplay)
  {
      [polyCellDisplay drop];
      polyCellDisplay = nil;
  }


  if(velocityHisto)
  {
      [velocityHisto drop];
      velocityHisto = nil;
  }

  if(depthHisto) 
  {
     [depthHisto drop];
     depthHisto = nil;
  }

  if(populationHisto)
  {
     [populationHisto drop];
     populationHisto = nil;
  }

  if(juveLengthHisto)
  {
     [juveLengthHisto drop];
     juveLengthHisto = nil;
  }

  if(mortalityGraph)
  {
      [mortalityGraph drop];
      mortalityGraph = nil;
  }

  if(outmigrantGraph)
  {
      [outmigrantGraph drop];
      outmigrantGraph = nil;
  }


  if(displayActions)
  {
     [displayActions drop];
     displayActions = nil;
  }

  if(displaySchedule)
  {
      [displaySchedule drop];
      displaySchedule = nil;
  }

  //[[troutModelSwarm getActivity] drop];

  if(troutModelSwarm)
  {
      fprintf(stdout, "OBSERVER SWARM >>>> drop >>>> dropping troutModelSwarm\n");
      fflush(0);

      [troutModelSwarm drop];
      troutModelSwarm = nil;
  }

  if(probeMap)
  {
      [probeMap drop];
      probeMap = nil;
  }

  if(obsZone)
  {
      [obsZone drop];
      obsZone = nil;
  }

  
  [super drop];

  fprintf(stdout,"TroutObserverSwarm >>>> drop >>>> END\n");
  fflush(0);
  

} //drop


- (id <Swarm>) getModelSwarm 
{
     return troutModelSwarm;
}

@end
