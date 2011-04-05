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


#import <time.h>
#import <objectbase/SwarmObject.h>
#import <random.h>
#import "TimeManagerProtocol.h"
#import "YearShufflerP.h"
@interface YearShuffler: SwarmObject <YearShuffler>
{
  id <Zone> ysZone;
  id <TimeManager> timeManager;
  id randGen;
  id <UniformUnsignedDist> listRandomizer;
  id <ListShuffler> listShuffler;
  id <List> listOfRandomizedYears;
  int listOffset;
  time_t startTime;
  time_t endTime;
  int startDay;
  int startMonth;
  int startYear;
  int endYear;
  int currentYear;
  int numSimYears;
  BOOL replaceFlag;
  unsigned randGenSeed;
}

+      createBegin: aZone 
     withStartTime: (time_t) aStartTime
       withEndTime: (time_t) anEndTime
   withReplacement: (BOOL) aReplaceFlag
   withRandGenSeed: (int) aSeed
   withTimeManager: (id <TimeManager>) aTimeManager;

- createEnd;
- calcNumSimYears;
- populateYearList;
- (time_t) checkForNewYearAt: (time_t) aTimeT;
- (id <List>) getListOfRandomizedYears; 

- (void) drop;

@end
