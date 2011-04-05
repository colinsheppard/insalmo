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
#import <stdlib.h>
#import <ctype.h>
#import <string.h>
#import <simtools.h>
#import <objectbase/SwarmObject.h>
#import "TimeManagerProtocol.h"

#ifndef TRUE
 
  #define TRUE 1

#endif

#ifndef FALSE

  #define FALSE 0

#endif

#ifdef LARGEINT
   #undef LARGEINT
#endif

#define LARGEINT 2147483647



@interface TimeManager : SwarmObject <TimeManager, CREATABLE>
{

size_t max_size;

char *format;

char formattedDate[11];

char isTodayTime[11];


//
// used in getTimeIntervalWithMMDD:andMMDD
//
char beginDate[11];  //="mm/dd/yyyy";
char endDate[11];  //="mm/dd/yyyy";


char sysDateAndTime[35];


time_t timeStepSize;
time_t currentTime;

int defaultSecond;
int defaultMinute;
int defaultHour;
int defaultDST;

id controller;

//
// Calculate the number of seconds 
// from the prime meridan
//
time_t timeZoneOffset;

}

//CREATING

- initState; // unpublished


+ create         :   (id <Zone>) aZone
    setController: aController
      setTimeStep: (time_t) aTimeStep 
     setCurrentTime: (time_t) aCurrentTime;

+ create                : (id <Zone>) aZone
           setController: aController
             setTimeStep: (time_t) aTime_t 
    setCurrentTimeWithDate: (char *) aFormattedDate
                withHour: (unsigned) anHour
              withMinute: (unsigned) aMinute
              withSecond: (unsigned) aSecond;

+ create: aZone;
+ createBegin: aZone;
- createEnd;



//
// SETTING
//


- setController: aController;

- setTimeStep: (time_t) aTime; 

- setCurrentTime: (time_t) aTime;

- setCurrentTimeWithDate: (char *) aFormattedDate
              withHour: (unsigned) anHour
            withMinute: (unsigned) aMinute
            withSecond: (unsigned) aSecond;

-    setDefaultHour: (int) anHour
   setDefaultMinute: (int) aMinute
   setDefaultSecond: (int) aSecond;


//
// USING
//

- (time_t) stepTimeWithControllerObject: controllerObject;

- (time_t) getCurrentTimeT;

- (time_t) getTimeDifferenceBetween: (time_t) aTime
                                and: (time_t) aLaterTime;

- (time_t) getTimeTWithDate: (char *) aFormattedDate;

- (time_t) getTimeTWithDate: (char *) aFormattedDate
                   withHour: (unsigned) anHour
                 withMinute: (unsigned) aMinute
                 withSecond: (unsigned) aSecond;
            
- (char *) getDateWithTimeT: (time_t) aTime_t;
- getDateWithTimeT: (time_t) aTime_t modifyingMyString: (char *) myString;

//- (time_t) getTimeTWithDate: (char *) aFormattedDate
                   //withHour: (unsigned) aHour
                 //withMinute: (unsigned) aMinute
                 //withSecond: (unsigned) aSecond
          //withBuffer: (char *) buf;

- (int) getYearWithTimeT: (time_t) aTime_t;
- (int) getMonthWithTimeT: (time_t) aTime_t;
- (int) getDayOfMonthWithTimeT: (time_t) aTime_t;
- (int) getHourWithTimeT: (time_t) aTime_t;
- (int) getMinuteWithTimeT: (time_t) aTime_t;
- (int) getSecondWithTimeT: (time_t) aTime_t;


- (time_t) adjustTimeTToDefaultHMS: (time_t) aTime_t;

- (int) getJulianDayWithTimeT: (time_t) aTime_t;
- (int) getJulianDayWithDay: (char *) aDay;  // Month and Day only--No Year

- (int) getNumberOfDaysBetween: (time_t) aTime and: (time_t) aLaterTime;

- printTimeStruct: (struct tm *) tm;
- (BOOL) isThisTime: (time_t) aTime_t onThisDay: (char *) aFormattedDay; 


- (BOOL) isTimeT: (time_t) aTime_t 
     betweenMMDD: (char *) startMonthDay
         andMMDD: (char *) endMonthDay;

//
// unpublished
//
- parseMMDDWith: (char *) aBeginDay
        andMMDD: (char *) anEndDay;

- (time_t) getTimeIntervalWithMMDD: (char *) aBeginDay
                           andMMDD: (char *) anEndDay;


- (time_t) getTimeTForNextMMDD: (char *) aDay 
                givenThisTimeT: (time_t) aTime_t;


//
// Ensures the date is in the mm/dd/yyyy format
//
- (BOOL) checkDateFormat: (char *) aDate;


//
// Can be used for stamping files with the current system time
//
- (time_t) getSystemTime;
- (char *) getSystemDateAndTime;


- (BOOL) getIsDSTWith: (time_t) aTime;

- (void) drop;


- (time_t) getTimeTWithDate: (char *) aFormattedDate
                   withHour: (unsigned) anHour
                 withMinute: (unsigned) aMinute
                 withSecond: (unsigned) aSecond;
            


@end

