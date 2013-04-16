/*
inSALMO individual-based salmon model, Version 1.2, October 2011.
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



#import <ctype.h>
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <objectbase/SwarmObject.h>
#import <collections.h>
#import "ZoneAllocMapper.h"
#import "StationObject.h"

@interface HydraulicFileReader : SwarmObject 
{

id <Symbol> FlowArray;
int totalFlowCount;
int prevFlowCount;
int flowCount;

id <Map> hydMap;

id <Array> flowArray;
id <Array> wslArray;
int wslCount;

id <Array> velArray;
int velCount;

BOOL firstFile;
id <List> stationList;

double prevStation;

}

+ createBegin: aZone;
- createEnd;

- checkStationOffsets; 
                       

//- readFile: (char *) inputFile;
- readFile2: (char *) inputFile;

- (id <List>) getStationList;
- (id <Array>) getFlowArray;

@end
