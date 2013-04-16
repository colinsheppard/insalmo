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



#import "TroutBatchSwarm.h"
#import "TroutModelSwarm.h"
#import <collections.h>
#import <objectbase.h>
//#import <analysis.h>
#import <gui.h>




@implementation TroutBatchSwarm


////////////////////////////////
//
// create
//
///////////////////////////////
+ create: aZone
{
  TroutBatchSwarm* tbs = [super create: aZone];

  fprintf(stdout, "TroutBatchSwarm >>>> create >>>> BEGIN\n");
  fflush(0);

  [ObjectLoader load: tbs fromFileNamed: "Observer.Setup"];


  fprintf(stdout, "TroutBatchSwarm >>>> create >>>> END\n");
  fflush(0);

  return tbs;
    
}



//////////////////////////////////////////////
//
// createBegin
//
//////////////////////////////////////////
+ createBegin: aZone
{
  return [super createBegin: aZone];
}


////////////////////////////////////////////////////////////
//
// createEnd
//
//////////////////////////////////////////////////////
- createEnd
{
  TroutBatchSwarm * obj;

  obj = [super createEnd];

  obj->finished=NO;

  return obj;
}



/////////////////////////////////////////////////////////////////
//
// getModel
//
//////////////////////////////////////////////////////////////
- getModel {

  return troutModelSwarm;

}



//////////////////////////////////////////////////////
//
// objectSetup
//
//////////////////////////////////////////////////////
- objectSetup
{
  //  [super buildObjects];

  obsZone = [Zone create: [self getZone]];
  troutModelSwarm = [TroutModelSwarm create: obsZone];

   [troutModelSwarm setPolyRasterResolutionX:  rasterResolutionX
                   setPolyRasterResolutionY:  rasterResolutionY 
                 setPolyRasterColorVariable:  rasterColorVariable];
  //troutModelSwarm->rasterResolution  = rasterResolution;
  //troutModelSwarm->rasterResolutionX = rasterResolutionX;
  //troutModelSwarm->rasterResolutionY = rasterResolutionY;
  //troutModelSwarm->rasterColorVariable = rasterColorVariable;

  

  fprintf(stderr,"modelSetupFile = %s \n", modelSetupFile);
  fflush(stderr);


  if (modelSetupFile != NULL) {
     [ObjectLoader load: troutModelSwarm fromFileNamed: modelSetupFile];
  }
  else {
     [ObjectLoader load: troutModelSwarm fromFileNamed: "Model.Setup"];
  }

  [troutModelSwarm instantiateObjects];

  return self;
}




- buildObjects {

  [super buildObjects];

  [troutModelSwarm buildObjectsWith: nil
                            andWith: 1.0]; 

  return self;

}  


- buildActions {

  [super buildActions];
  [troutModelSwarm buildActions];

  batchSchedule = [Schedule createBegin: obsZone];
  [batchSchedule setRepeatInterval: 1];
  batchSchedule = [batchSchedule createEnd];
  [batchSchedule at: 0 createActionTo: self message: M(checkToStop)];
  
  return self;

}  

- activateIn:  swarmContext {

  [super activateIn: swarmContext];
  modelActivity = [troutModelSwarm activateIn: self];
  [batchSchedule activateIn: self];
  return [self getActivity];

}


/////////////////////////////////
//
// checkToStop
//
/////////////////////////////////
- checkToStop 
{
  if([troutModelSwarm whenToStop] == YES)
  {
    finished = YES;
   
    modelActivity = nil;

    [[self getActivity] stop];

    fprintf(stdout,"TroutBatchSwarm >>>> checkToStop >>>> Stop date achieved\n");
    fflush(0);
  }


  return self;
}



- (BOOL) areYouFinishedYet {
  return finished;
}

- setModelNumberTo: (int) anInt {
  modelNumber = anInt;
  return self;
}


- iAmAlive 
{
  static int iveBeenCalled=0;
  iveBeenCalled++;

  fprintf(stdout, "BatchSwarm is alive. (%d)\n", iveBeenCalled); 
  fflush(0);

  return self;
}

- (void) drop 
{

 // fprintf(stderr,"TroutBatchSwarm >>>> drop >>>> BEGIN\n");
 // fflush(stderr);

  if(troutModelSwarm != nil) 
  {
      [troutModelSwarm drop];
      troutModelSwarm = nil;
  }

  if(obsZone) 
  {
      [obsZone drop];
      obsZone = nil;
  }


  [super drop];

 // fprintf(stderr,"TroutBatchSwarm >>>> drop >>>> END\n");
 // fflush(stderr);
}


//////////////////////////////////////
//
// getModelSwarm
//
//////////////////////////////////////
- (id <Swarm>) getModelSwarm 
{
     return troutModelSwarm;
}


///////////////////////////////////////
//
// getObsZone
//
//////////////////////////////////////
- (id <Zone>) getObsZone
{
   return obsZone;
}

@end
