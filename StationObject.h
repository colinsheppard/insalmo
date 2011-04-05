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


#import <ctype.h>
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <math.h>

#import <objectbase/SwarmObject.h>
#import <collections.h>

#import "InterpolationTableP.h"

@interface Station : SwarmObject 
{

int cellNo;
int transect;
double station;
double elev;
double bottomElev;

int maxFlowOffset;
int maxVelocityOffset;
int maxWslOffset;
int maxDepthOffset;

id <Array> flowArray;
id <Array> velocityArray;
id <Array> wslArray;
id <Array> depthArray;

id <Zone> stationZone;

id <InterpolationTable> velocityInterpolator;
id <InterpolationTable> wslInterpolator;
id <InterpolationTable> depthInterpolator;

}

+ createBegin: aZone;
- createEnd;

- setCellNo: (int) aCellNo;
- setTransect: (int) aTransect;
- setStation: (double) aStation;
- setElev: (double) anElev;
- setBottomElev: (double) anElev;


- (int) getCellNo;
- (int) getTransect;
- (double) getStation;

- (double) getVelocityAtOffset: (int) anOffset;

- (double) getBottomElev;

- addAFlow: (double) aFlow atTransect: (int) aTransect
                           andStation: (double) aStation;

- addAWsl: (double) aWsl atTransect: (int) aTransect
                         andStation: (double) aStation;

- addAVelocity: (double) aVelocity atTransect: (int) aTransect
                                   andStation: (double) aStation;

- addADepth: (double) aDepth atTransect: (int) aTransect
                             andStation: (double) aStation;

- checkArraySizes;

- printFlowArray;
- printVelocityArray;
- printWslArray;

- checkMaxOffsets;
- printSelf;


- createInterpolationTables;
- (id <InterpolationTable>) getVelocityInterpolator;
- (id <InterpolationTable>) getWslInterpolator;
- (id <InterpolationTable>) getDepthInterpolator;


- (void) drop;

@end


