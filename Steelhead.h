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


#import "SpawnerParams.h"
#import "Spawner.h"
@interface Steelhead : Spawner 
{
     time_t arrivalStartTime;
     int arrivalStartMonth;
     int arrivalStartDay;

}
+ createBegin: aZone;

- setSex: (id <Symbol>) aSex;
- setRandGen: aRandGen;
- setRasterResolutionX: (int) aRasterResX
                     Y: (int) aRasterResY;
- setArrivalStartTime: (time_t) anArrivalStartTime;
- (time_t) getArrivalStartTime;

- setArrivalStartMonth: (int) aMonth 
                andDay: (int) aDay;

- (int) getArrivalStartMonth;
- (int) getArrivalStartDay;

- move;
- spawn;
- grow;
- die;

- (int) compare: aSpawner;

- (void) drop;

@end

