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



#import "Barrier.h"

@implementation Barrier

//////////////////////////////////////////////////////////
//
// setBarrierX
//
//////////////////////////////////////////////////////////
- setBarrierX: (double) anX {

  barrierX = 100 * anX;

  return self;

}


//////////////////////////////////////////////////////////
//
// setMinY
//
//////////////////////////////////////////////////////////
- setMinY: (double) Y0 andMaxY: (double) Y1 {

  aMinY = Y0;

  aMaxY = Y1;

  return self;

}



//////////////////////////////////////////////////////////
//
// setBarrierRasterResolutionX
//
//////////////////////////////////////////////////////////
- setBarrierRasterResolutionX: (int) aResolutionX 
               andResolutionY: (int) aResolutionY {


  rasterResolutionX = aResolutionX;
  rasterResolutionY = aResolutionY;


  return self;

}



///////////////////////////////////////////////////////////
//
// getBarrierX
//
//////////////////////////////////////////////////////////
- (double) getBarrierX {

   return barrierX;

}



///////////////////////////////////////////////////////////
//
// drawSelfOn
//
//////////////////////////////////////////////////////////
- drawSelfOn: (id <Raster>) aRaster {

   if(aRaster == nil) {

     fprintf(stdout,"WARNING: worldRaster is nil in Barriers \n");
     fflush(0);
 
     return self;

   }

   if( (rasterResolutionX == 0) || (rasterResolutionY == 0) ) {

     return self;

   }

  
  //xprint(aRaster);
  //fprintf(stdout,"rasterResolutionX = %d \n", rasterResolutionX);
  //fflush(0);

   [aRaster  lineX0: (int) ((barrierX/rasterResolutionX) + 0.5)
                 Y0: (int) ((aMinY/rasterResolutionY) + 0.5)
                 X1: (int) ((barrierX/rasterResolutionX) + 0.5)
                 Y1: (int) ((aMaxY/rasterResolutionY) + 0.5)
              Width: 3
             Color: BARRIER_COLOR];


  return self;

}

 
/////////////////////////////////////////////////
//
// drop
//
//////////////////////////////////////////////////
- (void) drop
{
     [super drop];
     self = nil;
}



@end
