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
#include <stdlib.h>

#import "PolyInterpolatorFactory.h"

@implementation PolyInterpolatorFactory

+ create: aZone 
{
   return [super create: aZone];
}



//////////////////////////////////////////
//
// setListOfPolyInputData
//
//////////////////////////////////////////
- setListOfPolyInputData: (id <List>) aList
{
    listOfPolyInputData = aList;
    return self;
}




//////////////////////////////////
//
// setPolyCell
//
//////////////////////////////////
- setPolyCell: (PolyCell *) aPolyCell
{
    polyCell = aPolyCell;
    return self;
}



///////////////////////////////////
//
// createPolyVelocityInterpolator
//
///////////////////////////////////
- createPolyVelocityInterpolator
{
  id <InterpolationTable> velocityInterpolator = nil;

  velocityInterpolator = [polyCell getVelocityInterpolator];

  if(velocityInterpolator != nil)
  {
      fprintf(stderr, "ERROR: PolyInterpolatorFactory >>>> velocityInterpolator already exists for polyCell number %d\n", [polyCell getPolyCellNumber]);
      fflush(0);
      exit(1);
  }

  velocityInterpolator = [InterpolationTable create: [polyCell getPolyCellZone]]; 

  //
  // Add first point 0,0 to ensure velocities do not become negative
  // at low flows.
  //
  [velocityInterpolator addX: 0.0 Y: 0.0];

  [polyCell setVelocityInterpolator: velocityInterpolator];
 
  return self;
}
    


///////////////////////////////////////
//
// createPolyDepthInterpolator
//
//////////////////////////////////////
- createPolyDepthInterpolator
{
  id <InterpolationTable> depthInterpolator = nil;

  depthInterpolator = [polyCell getDepthInterpolator];
  if(depthInterpolator != nil)
  {
      fprintf(stderr, "ERROR: PolyInterpolatorFactory >>>> depthInterpolator already exists for polyCell number %d\n", [polyCell getPolyCellNumber]);
      fflush(0);
      exit(1);
  }

  depthInterpolator = [InterpolationTable create: [polyCell getPolyCellZone]]; 

  //
  // Add first point 0,0 to ensure depths do not become negative
  // at low flows.
  //
  [depthInterpolator addX: 0.0 Y: 0.0];


  [polyCell setDepthInterpolator: depthInterpolator];
 
  return self;
}


///////////////////////////////////////
//
// updatePolyVelocityInterpolator
//
///////////////////////////////////////
- updatePolyVelocityInterpolator
{
   int numberOfNodes = 0;
   int** cornerNodeArray = NULL;
   id <InterpolationTable> velocityInterpolator = nil;
   int i;

   id <ListIndex> ndx = [listOfPolyInputData listBegin: scratchZone];
   PolyInputData* polyInputData = nil;

   

   //fprintf(stdout, "PolyInterpolatorFactory >>>> updatePolyVelocityInterpolator >>>> BEGIN\n");
   //fflush(0);

   if(polyCell == nil)
   {
      fprintf(stdout, "ERROR: PolyInterpolatorFactory >>>> updatePolyVelocityInterpolator >>>> polyCell is nil\n");
      fflush(0);
      exit(1);
   }
      
   numberOfNodes = [polyCell getNumberOfNodes];
   cornerNodeArray = [polyCell getCornerNodeArray];
   velocityInterpolator = [polyCell getVelocityInterpolator];

   while(([ndx getLoc] != End) && ((polyInputData = [ndx next]) != nil))
   {
       double polyFlow = [polyInputData getPolyFlow];
       double** velocityArray = [polyInputData getVelocityArray]; 
       double averageVelocity = 0.0;

       for(i = 0; i <  numberOfNodes; i++)
       {
            averageVelocity += *velocityArray[*cornerNodeArray[i]]; 
       }

       averageVelocity = averageVelocity/numberOfNodes;

       [velocityInterpolator addX: polyFlow Y: averageVelocity];
   }

   [ndx drop];

   //fprintf(stdout, "PolyInterpolatorFactory >>>> updatePolyVelocityInterpolator >>>> END\n");
   //fflush(0);

   return self;
}



/////////////////////////////////////////
//
// updatePolyDepthInterpolator
//
/////////////////////////////////////////
- updatePolyDepthInterpolator
{
   int numberOfNodes = 0;
   int** cornerNodeArray = NULL;
   id <InterpolationTable> depthInterpolator = nil;
   int i;

   id <ListIndex> ndx = [listOfPolyInputData listBegin: scratchZone];
   PolyInputData* polyInputData = nil;

   //fprintf(stdout, "PolyInterpolatorFactory >>>> updatePolyDepthInterpolator >>>> BEGIN\n");
   //fflush(0);

   if(polyCell == nil)
   {
      fprintf(stdout, "ERROR: PolyInterpolatorFactory >>>> updatePolyDepthInterpolator >>>> polyCell is nil\n");
      fflush(0);
      exit(1);
   }
      
   numberOfNodes = [polyCell getNumberOfNodes];
   cornerNodeArray = [polyCell getCornerNodeArray];
   depthInterpolator = [polyCell getDepthInterpolator];

   while(([ndx getLoc] != End) && ((polyInputData = [ndx next]) != nil))
   {
       double polyFlow = [polyInputData getPolyFlow];
       double** depthArray = [polyInputData getDepthArray]; 
       double averageDepth = 0.0;

       for(i = 0; i <  numberOfNodes; i++)
       {
            averageDepth += *depthArray[*cornerNodeArray[i]]; 
       }

       averageDepth = averageDepth/numberOfNodes;

       [depthInterpolator addX: polyFlow Y: averageDepth];
   }

   [ndx drop];

   //fprintf(stdout, "PolyInterpolatorFactory >>>> updatePolyDepthInterpolator >>>> END\n");
   //fflush(0);

   return self;
}

@end
