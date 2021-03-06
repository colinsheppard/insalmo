/*
EcoSwarm library for individual-based modeling, last revised April 2013.
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



#import <objectbase/SwarmObject.h>
#import <collections.h>
#import <string.h>
#import "TimeManagerProtocol.h"
#import <math.h>
#import <ctype.h>
#import <stdlib.h>


#define LARGEINT 2147483647

#define HCOMMENTLENGTH 200

#define TRUE 1
#define FALSE 0

enum inputDataType {DAILY = 0, HOURLY = 1, OTHER = 2};


@interface TimeSeriesInputManager : SwarmObject
{

  id <Zone> timeSeriesInputZone;

  enum inputDataType inputDataType;
   
  char* inputFileName;
  id <TimeManager> timeManager;
  time_t startTime;
  time_t endTime;
  
  double** inputRecord;
  unsigned numRecords;

  BOOL log10OfValuesOn;

  BOOL checkData;

}

//CREATING

+     createBegin: (id <Zone>) aZone
     withDataType: (char *) aTypeString
    withInputFile: (char *) aFileName
  withTimeManager: (id <TimeManager>) aTimeManager
    withStartTime: (time_t) aStartTime
      withEndTime: (time_t) anEndTime
    withCheckData: (BOOL) aFlag;

- createEnd;

- checkData;



//SETTING

- setLog10OfValues;



//USING

- (double) getValueForTime: (time_t) aTime;

- (double) getMeanValueWithStartTime: (time_t) aStartTime
                         withEndTime: (time_t) aEndTime;

- (double) getMaxValueWithStartTime: (time_t) aStartTime
                        withEndTime: (time_t) anEndTime;

- (double) getMinValueWithStartTime: (time_t) aStartTime
                        withEndTime: (time_t) anEndTime;


- (double) getMeanAntiLogValueWithStartTime: (time_t) aStartTime
                                withEndTime: (time_t) aEndTime;

- printDataToFileNamed: (char *) aFileName;

- readInputRecords;

+ (void) unQuote: (char *) toScrub;

- (void) drop;

@end
