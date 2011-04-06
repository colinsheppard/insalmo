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




#import "globals.h"
#import "Steelhead.h"

@implementation Steelhead

+ createBegin: aZone 
{
   return [super createBegin: aZone];
}

- setSex: (id <Symbol>) aSex
{
    sex = aSex;
    return self;
}

- setRandGen: aRandGen
{
    randGen = aRandGen;
    return self;
}

- setRasterResolutionX: (int) aRasterResX
                     Y: (int) aRasterResY
{
    rasterResolutionX = aRasterResX;
    rasterResolutionY = aRasterResY;
    return self;
}

- setArrivalTime: (time_t) anArrivalTime
{
      arrivalTime = anArrivalTime;
      return self;
}

- (time_t) getArrivalTime
{
      return arrivalTime;
}

- (int) getArrivalMonth
{
     return arrivalMonth;
}


- (int) getArrivalDay
{
     return arrivalDay;
}

- move
{
    return self;
}

- spawn
{
    return self;
}

- grow
{
    return self;
}

- die
{
    return self;
}


///////////////////////////////////////////////////////////////////////////////
//
// compareArrivalTime
// Needed by QSort in TroutModelSwarm method: buildTotalTroutPopList
//
///////////////////////////////////////////////////////////////////////////////
//- (int) compareArrivalTime: aSpawner 
- (int) compare: aSpawner 
{
  double oFishArriveTime = [aSpawner getArrivalTime];

  if(arrivalTime > oFishArriveTime)
  {
     return 1;
  }
  else if(arrivalTime == oFishArriveTime)
  {
     return 0;
  }
  else
  {
     return -1;
  }
}

////////////////////////////////////////////////
//
// drop
//
///////////////////////////////////////////////
- (void) drop
{
     [super drop];
}


@end

