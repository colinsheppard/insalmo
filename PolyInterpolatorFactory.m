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


@end
