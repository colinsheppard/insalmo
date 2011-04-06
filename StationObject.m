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




#import "StationObject.h"

@implementation Station 

+ createBegin: aZone 
{
  Station* newStation;
  id <Array> tempArray;
  id tempZone;

  newStation = [super createBegin: aZone]; 

  tempArray = [Array createBegin: aZone];
  [tempArray setCount: 0];
  [tempArray setDefaultMember: nil];
  tempArray = [tempArray createEnd];
 
  newStation->flowArray = tempArray; 
  

  tempArray = [Array createBegin: aZone];
  [tempArray setCount: 0];
  [tempArray setDefaultMember: nil];
  tempArray = [tempArray createEnd];
 
  newStation->velocityArray = tempArray; 
  
  tempArray = [Array createBegin: aZone];
  [tempArray setCount: 0];
  [tempArray setDefaultMember: nil];
  tempArray = [tempArray createEnd];
 
  newStation->wslArray = tempArray; 

  tempArray = [Array createBegin: aZone];
  [tempArray setCount: 0];
  [tempArray setDefaultMember: nil];
  tempArray = [tempArray createEnd];
 
  newStation->depthArray = tempArray; 
  
  tempZone = [Zone create: aZone];

  newStation->stationZone = tempZone;

  newStation->maxFlowOffset = 0;
  newStation->maxVelocityOffset = 0;
  newStation->maxWslOffset = 0;

  //
  // Interpolation Tables
  //
  newStation->velocityInterpolator = [InterpolationTable create: newStation->stationZone];
  newStation->wslInterpolator = [InterpolationTable create: newStation->stationZone];
  newStation->depthInterpolator = [InterpolationTable create: newStation->stationZone];

  return newStation;

}


- createEnd 
{
  [self createInterpolationTables];
  return [super createEnd];
}

- setCellNo: (int) aCellNo 
{
  cellNo = aCellNo;
  return self;
}


- setTransect: (int) aTransect 
{
   transect = aTransect;
   return self;
}


- setStation: (double) aStation 
{
   station = aStation;
   return self;
}

- setElev: (double) anElev 
{
  elev = anElev;
  return self;
}

- setBottomElev: (double) anElev 
{
   bottomElev = 100.0*anElev;
   return self;
}


- (int) getCellNo 
{
   return cellNo;
}





- (int) getTransect 
{
  return transect;
}

- (double) getStation 
{
   return station;
}


///////////////////////////////////////////////////////
//
// getVelocityAtOffset
//
//////////////////////////////////////////////////////
- (double) getVelocityAtOffset: (int) anOffset 
{
  double velocity;

  if((anOffset > maxVelocityOffset) || (anOffset < 0))
  {
     fprintf(stderr, "ERROR: StationObject >>>> getVelocityAtOfset >>>> In *station* offset is out of bounds\n");
     fflush(0);
     exit(1);
  } 

  velocity = *((double *) [velocityArray atOffset: anOffset]);  
 
  return velocity;

}


////////////////////////////////////////
//
// getBottomElev
//
///////////////////////////////////////
- (double) getBottomElev
{
   return bottomElev;
}


/////////////////////////////////////////////////////////
//
// addAFlow
//
/////////////////////////////////////////////////////////
- addAFlow: (double) aFlow atTransect: (int) aTransect
                          andStation: (double) aStation 
{
  double* stationFlow = (double *) [stationZone alloc: sizeof(double)];

  int offset = [flowArray getCount];
  
  if( (aTransect != transect) || (abs(aStation - station) > 0.0001))
  {
    fprintf(stderr, "ERROR: StationObject >>>> addAFlow >>>> transect and/or station incorrect in Station\n");
    fprintf(stderr, "ERROR: StationObject >>>> addAFlow >>>> aTransect = %d \n", aTransect);
    fprintf(stderr, "ERROR: StationObject >>>> addAFlow >>>> transect = %d \n", transect);
    fprintf(stderr, "ERROR: StationObject >>>> addAFlow >>>> aStation = %f \n", aStation);
    fprintf(stderr, "ERROR: StationObject >>>> addAFlow >>>> station = %f \n", station);
    fflush(0);
    exit(1);
  }

  *stationFlow = aFlow;

  [flowArray setCount: offset + 1];
  [flowArray atOffset: offset put: (void *) stationFlow];
  
  maxFlowOffset++;

  return self;

}



//////////////////////////////////////////////////////////
//
// addAWsl
//
/////////////////////////////////////////////////////////
- addAWsl: (double) aWsl 
 atTransect: (int) aTransect
 andStation: (double) aStation 
{

  double *stationWsl = (double *) [stationZone alloc: sizeof(double)];
  int offset = [wslArray getCount];

  if((aTransect != transect) || (abs(aStation - station) > 0.0001))
  {
     fprintf(stderr, "ERROR: StationObject >>>> addAWSL >>>> transect and/or station incorrect in Station\n");
     fflush(0);
     exit(1);
  }

   *stationWsl = 100.0*aWsl;

   [wslArray setCount: offset + 1];
   [wslArray atOffset: offset put: (void *) stationWsl];
  
   maxWslOffset++;

   return self;

}




/////////////////////////////////////////////////////////////////
//
// addAVelocity
//
/////////////////////////////////////////////////////////////////
- addAVelocity: (double) aVelocity 
    atTransect: (int) aTransect 
    andStation: (double) aStation 
{

  double* stationVelocity = (double *)[stationZone alloc: sizeof(double)];

  int offset = [velocityArray getCount];

  // 
  // set the average velocity for all the stations within a transect
  //

  if((aTransect != transect) || (abs(aStation - station) > 0.0001))
  {
      fprintf(stderr, "ERROR: StationObject >>>> addAVelocity >>>> transect and/or station incorrect in Station\n");
      fflush(0);
      exit(1);
  }

  *stationVelocity = 100.0*aVelocity;

   offset = [velocityArray getCount];

   [velocityArray setCount: offset + 1];
   [velocityArray atOffset: offset put: (void *) stationVelocity];
  
   maxVelocityOffset++;

   return self;

}

/////////////////////////////////////////////////////////////////
//
// addADepth:atTransect:andStation
//
/////////////////////////////////////////////////////////////////
-    addADepth: (double) aDepth 
    atTransect: (int) aTransect 
    andStation: (double) aStation 
{

  double* stationDepth = (double *)[stationZone alloc: sizeof(double)];

  int offset = [depthArray getCount];

  if((aTransect != transect) || (abs(aStation - station) > 0.0001))
  {
      fprintf(stderr, "ERROR: StationObject >>>> addADepth >>>> transect and/or station incorrect in Station\n");
      fflush(0);
      exit(1);
  }

  *stationDepth = 100.0*aDepth;

   offset = [depthArray getCount];

   [depthArray setCount: offset + 1];
   [depthArray atOffset: offset put: (void *) stationDepth];
  
   maxDepthOffset++;

   return self;
}



- checkMaxOffsets 
{
   if(   (maxFlowOffset != maxVelocityOffset) 
      || (maxFlowOffset != maxWslOffset) 
      || (maxWslOffset != maxVelocityOffset) 
      || (maxFlowOffset != maxFlowOffset)) 
   {
        fprintf(stderr, "ERROR: checkMaxOffsets >>>> max Offsets are different in station object\n");
        fflush(0);
        exit(1);
   }

  return self;
}


- checkArraySizes 
{
  return self;
}


- printFlowArray 
{
  int i;
  fprintf(stdout,"\n");
  for(i = 0; i < maxFlowOffset; i++) 
  {
     fprintf(stdout,"STATIONOBJECT>>>>> flowArray[%d] = %f \n", i, *((double *) [flowArray atOffset: i]));
     fflush(0);
  }

  return self;

}

- printVelocityArray 
{
  int i;
  fprintf(stdout,"\n");
  for(i = 0; i < maxVelocityOffset; i++) 
  {
     fprintf(stdout,"STATIONOBJECT>>>>> transect = %d station = %f velocityArray[%d] = %f \n",transect, station, i, *((double *) [velocityArray atOffset: i]));
     fflush(0);
  }

  return self;
}


- printWslArray 
{
  int i;
  fprintf(stdout,"\n");
  for(i = 0; i < maxWslOffset; i++) 
  {
     fprintf(stdout,"STATIONOBJECT>>>>> transect = %d station = %f wslArray[%d] = %f \n",transect, station, i, *((double *) [wslArray atOffset: i]));
     fflush(0);
  }

  return self;

}



- printSelf 
{
  fprintf(stdout,"\n");
  fprintf(stdout,"TRANSECT = %d \n", transect);
  fprintf(stdout,"STATION  ELEV \n");
  fprintf(stdout,"%f       %f      ", station, elev);
  fprintf(stdout,"\n");
  fflush(0);

  return self;

}


////////////////////////////////////////////////
//
// createinterpolationTables
//
////////////////////////////////////////////////
- createInterpolationTables
{
   int i;

   //fprintf(stdout, "StationObject >>>> createInterpolationtable >>>> BEGIN\n");
   //fflush(0);

   if(wslInterpolator == nil)
   {
       fprintf(stderr, "ERROR: StationObject >>>> createInterpolationTables >>>> wslInterpolator is nil\n");
       fflush(0);
       exit(1);
   }


   for(i = 0; i < maxFlowOffset; i++)
   {
       double flow = *((double *)[flowArray atOffset: i]);
       double velocity = *((double *)[velocityArray atOffset: i]);
       double wsl = *((double *)[wslArray atOffset: i]);
       double depth = *((double *)[depthArray atOffset: i]);

       if(velocity <= 0.0)
       {
            velocity = 0.0;
       }
       if(depth <= 0.0)
       {
            depth = 0.0;
       }

       [velocityInterpolator addX: flow
                                Y: velocity];

       [wslInterpolator addX: flow
                           Y: wsl];

       [depthInterpolator addX: flow
                             Y: depth];

   }


   //[velocityInterpolator printSelf];
   //[wslInterpolator printSelf];
   //[depthInterpolator printSelf];

   //fprintf(stdout, "StationObject >>>> createInterpolationtable >>>> END\n");
   //fflush(0);
   return self;
}


//////////////////////////////////////////////////
//
// getVelocityInterpolator
//
///////////////////////////////////////////////////
- (id <InterpolationTable>) getVelocityInterpolator
{
    return velocityInterpolator;
}


////////////////////////////////////////////////
//
// getWslInterpolator
//
////////////////////////////////////////////////
- (id <InterpolationTable>) getWslInterpolator
{
   return wslInterpolator;
}

////////////////////////////////////////////////
//
// getDepthInterpolator
//
////////////////////////////////////////////////
- (id <InterpolationTable>) getDepthInterpolator
{
   return depthInterpolator;
}


//////////////////////////////////////////
//
// drop
//
////////////////////////////////////////
- (void) drop
{
    [flowArray deleteAll];
    [flowArray drop];
    flowArray = nil;
 
    [wslArray deleteAll];
    [wslArray drop];
     wslArray = nil;

    [velocityArray deleteAll];
    [velocityArray drop];
    velocityArray = nil;

   [depthArray deleteAll];
   [depthArray drop];
   depthArray = nil;
}

@end
