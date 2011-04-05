/*
inSTREAM Version 4.2, October 2006.
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


#import <objectbase/SwarmObject.h>
//#import <analysis/Averager.h>
#import "EcoAverager.h"
#import <string.h>
#import <stdlib.h>

#ifndef TRUE
   #define TRUE 1
#endif

#ifndef FALSE
   #define FALSE 0
#endif


@interface BreakoutAverager : EcoAverager
{

   char outputLabel[50];
   char averagerType[50];

   SEL averagerSelector;

   id <Symbol> Count;
   id <Symbol> Average;
   id <Symbol> Total;
   id <Symbol> Min;
   id <Symbol> Max;
   id <Symbol> StdDev;
   id <Symbol> Variance;
   
}
+ createBegin: aZone;

- createEnd;

- setOutputLabel: (char *) anOutputLabel;
- setAveragerType: (char *) anAveragerType;

- (char *) getOutputLabel;

- update;
- (double) getAveragerValue;




@end
