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

//


#import "TimeManager.h"


@implementation TimeManager 


+ create         :   (id <Zone>) aZone
    setController: aController
      setTimeStep: (time_t) aTimeStep 
     setCurrentTime: (time_t) aCurrentTime
{

  TimeManager *time;

  time = [TimeManager createBegin: aZone];

  [time setController: aController];
  [time setTimeStep: aTimeStep];
  [time setCurrentTime: aCurrentTime];

  return time;
}


+ create                : (id <Zone>) aZone
           setController: aController
             setTimeStep: (time_t) aTimeStep 
    setCurrentTimeWithDate: (char *) aFormattedDate
                withHour: (unsigned) anHour
              withMinute: (unsigned) aMinute
              withSecond: (unsigned) aSecond
{

  TimeManager *time;

  time = [TimeManager createBegin: aZone];

  [time setController: aController];
  [time setTimeStep: aTimeStep];
  [time setCurrentTimeWithDate: aFormattedDate
                    withHour: anHour
                  withMinute: aMinute
                  withSecond: aSecond];

  return time;
}



+ create: aZone {
  TimeManager *time;

  time = [super createBegin: aZone];
 
  time->timeStepSize = -LARGEINT;

  time = [time createEnd];

  return time;


}

+ createBegin: aZone {
  TimeManager *time;

  time = [super createBegin: aZone];

  [time initState];
 
  return time;

}

- createEnd
{

   return [super createEnd];

}


///////////////////////////////////////////////
//
// initState
//
///////////////////////////////////////////////
- initState {
  time_t aTime = (time_t) 0;
  struct tm *gmtimeStruct;

  format = "%m/%d/%Y";

  max_size = (size_t) ( 11 * sizeof(char) );

  timeStepSize = -LARGEINT;

  defaultSecond = 0;
  defaultMinute = 0;
  defaultHour = 12;
  defaultDST = 0;

  currentTime = (time_t) 0;

  gmtimeStruct = gmtime(&aTime);

  //
  // Calculate the number of seconds 
  // from the prime meridan
  //
  timeZoneOffset = mktime(gmtimeStruct);

  fprintf(stdout, "TimeManager >>>> initState >>>> timeZoneOffset = %ld\n", (long) timeZoneOffset);
  fflush(0);


  return self;

}

/////////////////////////////////////////////////////////////////////////
//
// getTimeTWithDate
//
// accepts a mm/dd/yyyy formatted date
// and returns a time_t using the default hour,
// minute, second.
//
/////////////////////////////////////////////////////////////////////////
- (time_t) getTimeTWithDate: (char *) aFormattedDate
{
       struct tm timeStruct;
       time_t aTimeT=-1;

       size_t length = strlen(aFormattedDate) + 1;
       char date[length];

       char* dateMonth;
       char* dateDay;
       char* dateYear;

       strncpy(date, aFormattedDate, length);
       
       dateMonth = strtok(date, "/");
       dateDay = strtok(NULL, "/");
       dateYear = strtok(NULL, "");

       memset(&timeStruct, 0, sizeof(timeStruct));

       timeStruct.tm_mon = atoi(dateMonth) - 1; 
       timeStruct.tm_mday = atoi(dateDay);  
       timeStruct.tm_year = atoi(dateYear) - 1900; 

        //strptime(aFormattedDate ,format, &timeStruct);

        //
        // given the arguments to strptime
        // tm_sec, tm_min, and tm_hour
        // have values which may cause mktime to 
        // return -1
        //
        timeStruct.tm_sec = defaultSecond;
        timeStruct.tm_min = defaultMinute;        
        timeStruct.tm_hour = defaultHour;      
        timeStruct.tm_wday = 0;
        timeStruct.tm_yday = 0;
        timeStruct.tm_isdst = defaultDST;       /* no daylight savings */

        //[self printTimeStruct: &timeStruct];

        aTimeT = mktime( &timeStruct );

        aTimeT = aTimeT - timeZoneOffset;

      /*
        printf("aFormattedDate = %s \n", aFormattedDate);
        printf("aTimeT = %d \n", (int) aTimeT);
        printf("aDate = %s \n\n", [self getDateWithTimeT: aTimeT]);
        fflush(stdout);
      */


 if(aTimeT == -1 )  
 {
    fprintf(stderr, "ERROR: TimeManager >>>> getTimeTWithDate: aFormatted Date %s \n", aFormattedDate);
    fprintf(stderr, "ERROR: TimeManager >>>> getTimeTWithDate: check date format \n");
    fflush(0);
    exit(1);
 }

 return aTimeT;
}

/////////////////////////////////////////////////////////////////////////
//
// getTimeTWithDate: withHour: withMinute: withSecond:
//
// returns a time_t
//
/////////////////////////////////////////////////////////////////////////
- (time_t) getTimeTWithDate: (char *) aFormattedDate
                   withHour: (unsigned) anHour
                 withMinute: (unsigned) aMinute
                 withSecond: (unsigned) aSecond 
{

       struct tm timeStruct;
       time_t aTimeT=-1;


       size_t length = strlen(aFormattedDate) + 1;
       char date[length];

       char* dateMonth;
       char* dateDay;
       char* dateYear;

       strncpy(date, aFormattedDate, length);
       
       dateMonth = strtok(date, "/");
       dateDay = strtok(NULL, "/");
       dateYear = strtok(NULL, "");

       memset(&timeStruct, 0, sizeof(timeStruct));

       timeStruct.tm_mon = atoi(dateMonth) - 1; 
       timeStruct.tm_mday = atoi(dateDay);  
       timeStruct.tm_year = atoi(dateYear) - 1900; 

        //strptime(aFormattedDate ,format, &timeStruct);

        //
        // given the arguments to strptime
        // tm_sec, tm_min, and tm_hour
        // have values which may cause mktime to 
        // return -1
        //
        timeStruct.tm_sec = aSecond;         /* seconds */
        timeStruct.tm_min = aMinute;         /* minutes */
        if(anHour == 24)
        {
           timeStruct.tm_hour = 0;        /* hours */
        }
        else
        {
           timeStruct.tm_hour = anHour;        /* hours */
        }
        timeStruct.tm_wday = 0;
        timeStruct.tm_yday = 0;
        timeStruct.tm_isdst = defaultDST;       /* daylight savings */

        //[self printTimeStruct: &timeStruct];

        aTimeT = mktime( &timeStruct );

        aTimeT = aTimeT - timeZoneOffset;

        if(anHour == 24)
        {
           aTimeT = aTimeT + 86400;
        }

        //printf("aFormattedDate = %s \n", aFormattedDate);
        //printf("aTimeT = %d \n", (int) aTimeT);
        //printf("aDate = %s \n\n", [self getDateWithTimeT: aTimeT]);
        //fflush(stdout);



 if(aTimeT == -1)  
 {
    fprintf(stderr, "ERROR: TimeManager >>>> getTimeTWithDate:withHour:withMinute:withSecond: aFormatted Date %s \n", aFormattedDate);
    fprintf(stderr, "ERROR: TimeManager >>>> check date format \n");
    fflush(0);
    exit(1);
 }

 return aTimeT;
}



/////////////////////////////////////////////////////
//
// getYearWithTimeT
//
////////////////////////////////////////////////////
- (int) getYearWithTimeT: (time_t) aTime_t {
   int year=0;


   strftime(formattedDate, max_size, "%Y" , gmtime( &aTime_t )) ;
   year = atoi(formattedDate); 

   /*
   fprintf(stderr, "TIMEMANAGER getYearWithTimeT = %d \n", year);
   fflush(0);
   */

   return year;

}


/////////////////////////////////////////////////////
//
// getMonthWithTimeT
//
////////////////////////////////////////////////////
- (int) getMonthWithTimeT: (time_t) aTime_t {
   int month=0;

   strftime(formattedDate, max_size, "%m" , gmtime( &aTime_t )) ;
   month = atoi(formattedDate); 

   return month;

}


/////////////////////////////////////////////////////
//
// getDayOfMonthWithTimeT
//
////////////////////////////////////////////////////
- (int) getDayOfMonthWithTimeT: (time_t) aTime_t {
   int month=0;

   strftime(formattedDate, max_size, "%d" , gmtime( &aTime_t )) ;
   month = atoi(formattedDate); 

   return month;

}


/////////////////////////////////////////////////////
//
// getHourWithTimeT
//
////////////////////////////////////////////////////
- (int) getHourWithTimeT: (time_t) aTime_t
{
   int theHour=0;

   strftime(formattedDate, max_size, "%H" , gmtime( &aTime_t )) ;
   theHour = atoi(formattedDate); 
   
   //fprintf(stderr, "TIMEWRAPPER getHourWithTimeT = %s \n", [self getDateWithTimeT: aTime_t]);
   //fprintf(stderr, "TIMEWRAPPER getHourWithTimeT = %d \n", theHour);
   //fflush(0);

   return theHour;

}


/////////////////////////////////////////////////////
//
// getMinuteWithTimeT
//
////////////////////////////////////////////////////
- (int) getMinuteWithTimeT: (time_t) aTime_t
{
   int theMinute=0;

   strftime(formattedDate, max_size, "%M" , gmtime( &aTime_t )) ;

   theMinute = atoi(formattedDate); 

   //fprintf(stderr, "TIMEWRAPPER getHourWithTimeT = %s \n", [self getDateWithTimeT: aTime_t]);
   //fprintf(stderr, "TIMEWRAPPER getHourWithTimeT = %d \n", theMinute);
   //fflush(0);

   return theMinute;
}



/////////////////////////////////////////////////////
//
// getSecondWithTimeT
//
////////////////////////////////////////////////////
- (int) getSecondWithTimeT: (time_t) aTime_t
{
   int theSecond=0;

   strftime(formattedDate, max_size, "%S" , gmtime( &aTime_t )) ;

   theSecond = atoi(formattedDate); 
   
   //fprintf(stderr, "TIMEWRAPPER getHourWithTimeT = %s \n", [self getDateWithTimeT: aTime_t]);
   //fprintf(stderr, "TIMEWRAPPER getHourWithTimeT = %d \n", theSecond);
   //fflush(0);
  
   return theSecond;
}



//////////////////////////////////////////////////////
//
// getJulianDayWithTimeT
//
/////////////////////////////////////////////////////
- (int) getJulianDayWithTimeT: (time_t) aTime_t {
  int julDay=0;

  strftime(formattedDate, max_size, "%j" , gmtime( &aTime_t ) );

  julDay = atoi(formattedDate);

  return julDay;

}


//////////////////////////////////////////////////////////
//
// getJulianDayWithDay
//
// The year is not supplied so this method does NOT
// calculate the julian day for 2/29/LeapYear
//
//////////////////////////////////////////////////////////
- (int) getJulianDayWithDay: (char *) aDay {
  int julDay=0;
  size_t length=0;
  int dateMonth;
  int dateDay;

   length = strlen(aDay);


   {
   char datePtr[length];
   size_t spn;
      
      spn = strspn(aDay, "0123456789");

      strncpy(datePtr,aDay, spn);
      datePtr[spn] = '\0';

      dateMonth = atoi(datePtr);

      strncpy(datePtr,aDay + (spn + (size_t) 1), length - spn);
      datePtr[length] = '\0';

      dateDay = atoi(datePtr);

   }

      //fprintf(stderr, "dateMonth = %d \n", dateMonth);
      //fprintf(stderr, "dateDay = %d \n", dateDay);
      //fflush(stderr);
 
      switch(dateMonth) {

          case 1:  julDay = dateDay;
                   break;
          case 2:  julDay = 31 + dateDay;
                   break;
          case 3:  julDay = 59 + dateDay;
                   break;
          case 4:  julDay = 90 + dateDay;
                   break;
          case 5:  julDay = 120 + dateDay;
                   break;
          case 6:  julDay = 151 + dateDay;
                   break;
          case 7:  julDay = 181 + dateDay;
                   break;
          case 8:  julDay = 212 + dateDay;
                   break;
          case 9:  julDay = 243 + dateDay;
                   break;
          case 10: julDay = 273 + dateDay;
                   break;
          case 11: julDay = 304 + dateDay;
                   break;
          case 12: julDay = 334 + dateDay;
                   break;
          default: [InternalError raiseEvent: "ERROR: day format incorrect for getJulDayForDay"];

      }


   //fprintf(stderr, "julDay = %d \n", julDay);
   //fflush(stderr);

  return julDay;

}


//////////////////////////////////////////////////
//
// adjustTimeTToDefaultHMS
//
//////////////////////////////////////////////////
- (time_t) adjustTimeTToDefaultHMS: (time_t) aTime_t {
  time_t aTime;

  //formattedDate = [self getDateWithTimeT: aTime_t];
  
  //aTime =  [self getTimeTWithDate: formattedDate];  
  aTime =  [self getTimeTWithDate: [self getDateWithTimeT: aTime_t]];  

  return aTime;

}



////////////////////////////////////////////////
//
// getDateWithTimeT 
//
// accepts a time_t date
//
// returns a mm/dd/yyyy formatted date
//
////////////////////////////////////////////////
- (char *) getDateWithTimeT: (time_t) aTime_t {

   format = "%m/%d/%Y";

   strftime( formattedDate, max_size, format, gmtime( &aTime_t ) );

   return formattedDate;
}


/////////////////////////////////////////////////////////////
//
// getDateWithTimeT: modifyingMyString: 
//
// accepts a time_t date and aString of proper length
// returns the string pointer you send it
//
// transforms myString into a mm/dd/yyyy formatted date
//
//////////////////////////////////////////////////////////////
- getDateWithTimeT: (time_t) aTime_t modifyingMyString: (char *) myString {

   strftime( myString, max_size, format, gmtime( &aTime_t ) );

   return self;
}



//////////////////////////////////////////
//
// printTimeStruct
//
//////////////////////////////////////////
- printTimeStruct: (struct tm *) tm {

     printf("\ntm_sec = %d \n", tm->tm_sec);
     printf("m_min = %d \n", tm->tm_min);
     printf("m_hour = %d \n",tm->tm_hour);
     printf("m_mday = %d \n", tm->tm_mday);
     printf("m_mon = %d \n", tm->tm_mon);
     printf("m_year = %d \n", tm->tm_year);
     printf("m_wday = %d \n", tm->tm_wday);
     printf("m_yday = %d \n", tm->tm_yday);
     printf("m_isdst = %d \n", tm->tm_isdst);
     fflush(stdout);

  return self;
}




///////////////////////////////////////////////////////////////////
//
// getNumberOfDaysBetween
//
//////////////////////////////////////////////////////////////////
- (int) getNumberOfDaysBetween: (time_t) aTime 
                           and: (time_t) aLaterTime 
{
      double timeDifference=-1;
      int numberOfDays=-1;

      if(aLaterTime >= aTime) 
      {
         timeDifference = difftime(aLaterTime, aTime);

         if(timeDifference == -1) 
         {
             fprintf(stderr, "ERROR: TImeManager >>>> getNumberOfDaysBetween >>>> timeDifference == -1\n"); 
             fflush(0);
             exit(1);
         }

         numberOfDays = ((int) timeDifference)/86400;
      }
      else 
      {
         timeDifference = difftime(aTime, aLaterTime);

         if(timeDifference == -1) 
         {
             fprintf(stderr, "ERROR: TImeManager >>>> getNumberOfDaysBetween >>>> timeDifference == -1\n"); 
             fflush(0);
             exit(1);
         }

         numberOfDays = -1 * ((int) timeDifference)/86400;
      }
 
      return numberOfDays;
}


//////////////////////////////////////////////////////////////////////////
//
// isThisTime
//
// accepts "mm/dd" or "mm/dd/yyyy" formatted date and a time_t value
// useful for 'Is today my birthday 8/18'
// returns YES or NO
//
//////////////////////////////////////////////////////////////////////////
- (BOOL) isThisTime: (time_t) aTime_t onThisDay: (char *) aFormattedDay 
{
   BOOL itIsToday = NO;
   size_t length;
   char *timePtr1;
   char *timePtr2;

   int timeMonth, timeDay;
   int dateMonth=0, dateDay=0;
   
   strcpy(isTodayTime, [self getDateWithTimeT: aTime_t]);

   timePtr1 = [self getDateWithTimeT: aTime_t];

   timePtr2 = strtok(timePtr1, "/");
   timeMonth = atoi(timePtr2);
   timePtr1 = NULL;
   timePtr2 = strtok(timePtr1, "/");
   timeDay = atoi(timePtr2);

   //fprintf(stderr, "TIMEMANAGER >>>> isThisTime >>>> timeMonth = %d \n", timeMonth);
   //fprintf(stderr, "TIMEMANAGER >>>> isThisTime >>>> timeDay = %d \n", timeDay);
   //fflush(stderr);

   length = strlen(aFormattedDay);

   {
      char datePtr[length];
      size_t spn;

      spn = strspn(aFormattedDay, "0123456789");

      strncpy(datePtr,aFormattedDay, spn);
      datePtr[spn] = '\0';

      dateMonth = atoi(datePtr);

      strncpy(datePtr,aFormattedDay + (spn + (size_t) 1), length - spn);
      datePtr[length] = '\0';

      dateDay = atoi(datePtr);

      //fprintf(stderr, "TIMEMANAGER >>>> isThisTime >>>> dateMonth = %d \n", dateMonth);
      //fprintf(stderr, "TIMEMANAGER >>>> isThisTime >>>> dateDay = %d \n", dateDay);
      //fflush(stderr);

   }


   if((dateMonth == timeMonth) && (dateDay == timeDay)) 
   {
      itIsToday = YES;
   }

   return itIsToday;
}


///////////////////////////////////////////////////
//
// isTimeT: betweenMMDD: andMMDD:
//
// uses default hour, minute, second.
//
///////////////////////////////////////////////////
- (BOOL) isTimeT: (time_t) aTime_t
     betweenMMDD: (char *) startMonthDay
         andMMDD: (char *) endMonthDay 
{
  BOOL timeIsBetween=NO;
  char *timePtr1;
  char *timePtr2;
  int timeMonth, timeDay, timeYear;

  size_t startMonthDayLength;
  size_t endMonthDayLength;
  int startDateMonth=0, startDateDay=0;
  int endDateMonth=0, endDateDay=0;
  time_t startTime;
  time_t endTime;
  struct tm startTimeStruct;
  struct tm endTimeStruct;

  strcpy(isTodayTime, [self getDateWithTimeT: aTime_t]);

  timePtr1 = [self getDateWithTimeT: aTime_t];

  timePtr2 = strtok(timePtr1, "/");
  timeMonth = atoi(timePtr2);
  timePtr1 = NULL;
  timePtr2 = strtok(timePtr1, "/");
  timeDay = atoi(timePtr2);
  timePtr2 = strtok(timePtr1, "");
  timeYear = atoi(timePtr2);

  //fprintf(stderr, "TIMEMANAGER >>>> isTimeT:betweenMMDD:andMMDD >>>> timeMonth = %d \n", timeMonth);
  //fprintf(stderr, "TIMEMANAGER >>>> isTimeT:betweenMMDD:andMMDD >>>> timeDay = %d \n", timeDay);
  //fprintf(stderr, "TIMEMANAGER >>>> isTimeT:betweenMMDD:andMMDD >>>> timeYear = %d \n", timeYear);
  //fflush(stderr);

  startMonthDayLength = strlen(startMonthDay);
  endMonthDayLength = strlen(endMonthDay);

  {
     char startDatePtr[startMonthDayLength];
     char endDatePtr[endMonthDayLength];
     size_t startSpn;
     size_t endSpn;

     startSpn = strspn(startMonthDay, "0123456789");
     endSpn = strspn(endMonthDay, "0123456789");

     strncpy(startDatePtr,startMonthDay, startSpn);
     startDatePtr[startSpn] = '\0';
     startDateMonth = atoi(startDatePtr);

     strncpy(startDatePtr, startMonthDay + (startSpn + (size_t) 1), startMonthDayLength - startSpn);
     startDatePtr[startMonthDayLength] = '\0';
     startDateDay = atoi(startDatePtr);

     strncpy(endDatePtr, endMonthDay, endSpn);
     endDatePtr[endSpn] = '\0';
     endDateMonth = atoi(endDatePtr);

     strncpy(endDatePtr,endMonthDay + (endSpn + (size_t) 1), endMonthDayLength - endSpn);
     endDatePtr[endMonthDayLength] = '\0';
     endDateDay = atoi(endDatePtr);

     //fprintf(stderr, "TIMEMANAGER >>>> isTime:betweenMMDD:andMMDD >>>> startDateMonth = %d \n", startDateMonth);
     //fprintf(stderr, "TIMEMANAGER >>>> isTime:betweenMMDD:andMMDD >>>> startDateDay = %d \n", startDateDay);
     //fprintf(stderr, "TIMEMANAGER >>>> isTime:betweenMMDD:andMMDD >>>> endDateMonth = %d \n", endDateMonth);
     //fprintf(stderr, "TIMEMANAGER >>>> isTime:betweenMMDD:andMMDD >>>> endDateDay = %d \n", endDateDay);
     //fflush(stderr);

  }

  //
  // Then we'll use the current year as obtained from aTime_t
  //
  startTimeStruct.tm_sec = defaultSecond;         /* seconds */
  startTimeStruct.tm_min = defaultMinute;         /* minutes */
  startTimeStruct.tm_hour = defaultHour;        /* hours */
  startTimeStruct.tm_mday = startDateDay;
  startTimeStruct.tm_mon = startDateMonth - 1;
  startTimeStruct.tm_year = (timeYear - 1900);
  startTimeStruct.tm_wday = 0;
  startTimeStruct.tm_yday = 0;
  startTimeStruct.tm_isdst = defaultDST;       /* no daylight savings */

  endTimeStruct.tm_sec = defaultSecond;         /* seconds */
  endTimeStruct.tm_min = defaultMinute;         /* minutes */
  endTimeStruct.tm_hour = defaultHour;        /* hours */
  endTimeStruct.tm_mday = endDateDay;
  endTimeStruct.tm_mon = endDateMonth - 1;
  endTimeStruct.tm_year = (timeYear -1900);
  endTimeStruct.tm_wday = 0;
  endTimeStruct.tm_yday = 0;
  endTimeStruct.tm_isdst = defaultDST;       /* no daylight savings */

  startTime = mktime(&startTimeStruct);
  endTime = mktime(&endTimeStruct);


  startTime = startTime - timeZoneOffset;
  endTime = endTime - timeZoneOffset;

  if(endTime  < startTime)
  {
     endTimeStruct.tm_sec = defaultSecond;         /* seconds */
     endTimeStruct.tm_min = defaultMinute;         /* minutes */
     endTimeStruct.tm_hour = defaultHour;        /* hours */
     endTimeStruct.tm_mday = endDateDay;
     endTimeStruct.tm_mon = endDateMonth - 1;
     endTimeStruct.tm_year = ((timeYear + 1) - 1900);
     endTimeStruct.tm_wday = 0;
     endTimeStruct.tm_yday = 0;
     endTimeStruct.tm_isdst = defaultDST;       /* no daylight savings */
 
     endTime = mktime(&endTimeStruct);


     endTime = endTime - timeZoneOffset;

  }

  if((startTime <= aTime_t) && (aTime_t <= endTime))
  {
      timeIsBetween = YES;
  }

  //fprintf(stderr, "TIMEMANAGER >>>> isTime:betweenMMDD:andMMDD >>>> startTime = %ld \n", (long) startTime);
  //fprintf(stderr, "TIMEMANAGER >>>> isTime:betweenMMDD:andMMDD >>>> aTime_t = %ld \n", (long) aTime_t);
  //fprintf(stderr, "TIMEMANAGER >>>> isTime:betweenMMDD:andMMDD >>>> endTime = %ld \n",  (long) endTime);
  //fprintf(stderr, "TIMEMANAGER >>>> isTime:betweenMMDD:andMMDD >>>> timeIsBetween = %d \n", (int) timeIsBetween);
  //fflush(0);

  return timeIsBetween;;

}


////////////////////////////////////////////////////////
//
// getTimeIntervalWithMMDD
//
// Note: This the method s not passed information regarding
//       the year for the begin and end day. It also 
//       assumes the default hour, minute, and second 
//
////////////////////////////////////////////////////////
- (time_t) getTimeIntervalWithMMDD: (char *) aBeginDay
                           andMMDD: (char *) anEndDay
{
   time_t intervalLength;

   [self parseMMDDWith: aBeginDay
               andMMDD: anEndDay];

   intervalLength =    [self getTimeTWithDate: endDate]
                    -  [self getTimeTWithDate: beginDate];



   //fprintf(stderr, "TIMEWRAPPER >>>> intervalLength = %d \n", (int) intervalLength);
   //fflush(0);

   return intervalLength;

}



//////////////////////////////////////////////////////
//
// parseMMDDWith:andMMDD
//
/////////////////////////////////////////////////////
- parseMMDDWith: (char *) aBeginDay
        andMMDD: (char *) anEndDay
{

   char beginDay[6]="#####";
   char endDay[6]="#####";

   int beginMonth=-1;
   int endMonth=-1;

   int beginDayOfTheMonth=0;
   int endDayOfTheMonth=0; 

   char* beginDateYear=NULL;
   char* endDateYear=NULL;


   int beginDayLen=strlen(aBeginDay);
   int endDayLen=strlen(anEndDay);

   int i;


   BOOL ERROR = FALSE;
 

   if(strlen(beginDay) < beginDayLen) 
   {
      ERROR = TRUE;
   }
   
   if((strlen(endDay) < endDayLen) && !ERROR) 
   {
      ERROR = TRUE;
   }

   for(i=0; (i < beginDayLen) && !ERROR; i++) 
   {
       if(!(isdigit(aBeginDay[i]) || (aBeginDay[i] == '/'))) 
       {
            ERROR = TRUE;
            break;
       }

       beginDate[i] = aBeginDay[i];
   }

   for(i=0; (i < endDayLen) && !ERROR ; i++) 
   {
       if(!(isdigit(anEndDay[i]) || (anEndDay[i] == '/'))) 
       {
            ERROR = TRUE;
            break;
       }

       endDate[i] = anEndDay[i];
   }

   if(!ERROR) 
   {
       beginDate[beginDayLen] = '/';
       beginDate[beginDayLen + 1] = '\0';

       endDate[endDayLen] = '/';
       endDate[endDayLen + 1] = '\0';

       strncpy(beginDay, aBeginDay, beginDayLen);
       strncpy(endDay, anEndDay, endDayLen);

       //fprintf(stderr, "TIMEWRAPPER >>>> beginDay = %s \n", beginDay);      
       //fprintf(stderr, "TIMEWRAPPER >>>> endDay = %s \n", endDay);      
       //fflush(0);

       beginMonth = atoi(strtok(beginDay, "/"));
       beginDayOfTheMonth = atoi(strtok(NULL, "#"));


       endMonth = atoi(strtok(endDay, "/"));
       endDayOfTheMonth = atoi(strtok(NULL, "#"));

       //fprintf(stderr, "TIMEWRAPPER >>>> beginDayOfTheMonth = %d \n", beginDayOfTheMonth);
       //fprintf(stderr, "TIMEWRAPPER >>>> endDayOfTheMonth = %d \n", endDayOfTheMonth);      
       //fflush(0);
   }

   if((beginMonth < 1) || (beginMonth > 12)) 
   {
       ERROR = TRUE;
   }

   if((endMonth < 1) || (endMonth > 12)) 
   {
       ERROR = TRUE;
   }

   if(   (beginDayOfTheMonth < 1) || (beginDayOfTheMonth > 31) 
      || (endDayOfTheMonth < 1) || (endDayOfTheMonth > 31)) 
   {
       ERROR = TRUE;
   }
   

   if((endMonth < beginMonth) && !ERROR) 
   {
       beginDateYear = "1973";
       endDateYear = "1974";
   } 
   else if((endMonth > beginMonth) && !ERROR) 
   {
       beginDateYear = "1973";
       endDateYear = "1973";
   }
   else if((endMonth == beginMonth) && !ERROR) 
   {
       if(beginDayOfTheMonth <= endDayOfTheMonth) 
       {
           beginDateYear = "1973";
           endDateYear = "1973";
       }
       else if(beginDayOfTheMonth > endDayOfTheMonth) 
       {
           beginDateYear = "1973";
           endDateYear = "1974";
       }
       else 
       {
           ERROR = TRUE;
       }
   }
   else 
   {
      ERROR = TRUE;
   }

   if(ERROR == TRUE) 
   {
      fprintf(stderr, "ERROR: TimeManager >>>> getTimeIntervalFor... >>>> Ensure inputted date is in MM/DD format\n");
      fflush(0);
      exit(1);
   }

   strncat(beginDate, beginDateYear, strlen(beginDateYear));
   strncat(endDate, endDateYear, strlen(endDateYear));
  
   return self;
}


//////////////////////////////////////////////////////
//
// getTimeTForNextMMDD 
//
// uses default hour, minute, second.
//
/////////////////////////////////////////////////////
- (time_t) getTimeTForNextMMDD: (char *) aDay 
                givenThisTimeT: (time_t) aTime_t 
{
   time_t theTime = (time_t) 0;
   struct tm *timeStruct;
   
   char nextMMDDDay[] = "#####";

   int nextMMDDMonth=0;
   int nextMMDDDayOfTheMonth=0;

   int aDayLen=strlen(aDay);

   int i;

   BOOL ERROR = FALSE;
 

   if( strlen(nextMMDDDay) < aDayLen ) {

            ERROR = TRUE;

    }
   
 
    for(i=0; (i<aDayLen) && !ERROR  ; i++) {

       if( !(isdigit(aDay[i]) || (aDay[i] == '/')) ) {
          
            ERROR = TRUE;
            break;
      
       }

   }

   if(!ERROR) {

       strncpy(nextMMDDDay, aDay, aDayLen);

       nextMMDDMonth = atoi(strtok(nextMMDDDay, "/"));
       nextMMDDDayOfTheMonth = atoi(strtok(NULL, "#"));

       fflush(0);


   }

   if( (nextMMDDMonth < 1) || (nextMMDDMonth > 12) ) {

       ERROR = TRUE;

   }


   if( (nextMMDDDayOfTheMonth < 1) || (nextMMDDDayOfTheMonth > 31) ) {

       ERROR = TRUE;

   }


   if(!ERROR) {

       memset(&timeStruct, 0, sizeof(timeStruct));
       timeStruct = localtime(&aTime_t);  

       //[self printTimeStruct: timeStruct];

       //
       // Now decide what year applies
       // 
       // 
       //
       //
       //

       if( (nextMMDDMonth - 1 ) < timeStruct->tm_mon )  {

           timeStruct->tm_year += 1;

       }
       else if ( (nextMMDDMonth - 1) > timeStruct->tm_mon) {

           // do nothing
       

       }
       else if( (nextMMDDMonth - 1) == timeStruct->tm_mon) {

             if (nextMMDDDayOfTheMonth >= timeStruct->tm_mday) {
 
                 // do nothing 

            }
            else if (nextMMDDDayOfTheMonth < timeStruct->tm_mday) {

                 timeStruct->tm_year += 1;

           }
           else {
              
                ERROR = TRUE;

           }
         
      }
      else {

          ERROR = TRUE;

      }

   }  //if !ERROR


   if(ERROR) 
   {
        fprintf(stderr, "ERROR: TimeManager >>>> getTimeTForNextMMDD... >>>> Ensure inputted date is in MM/DD format\n");
        fflush(0);
        exit(1);
   }

   if(!ERROR) 
   {
 
        //
        // now use the same time struct as aTime_t's,  just change the month
        // and day to (char *) aDay's
        //
        timeStruct->tm_sec = defaultSecond;
        timeStruct->tm_min = defaultMinute;
        timeStruct->tm_hour = defaultHour;
        timeStruct->tm_wday = 0;
        timeStruct->tm_yday = 0;
        timeStruct->tm_isdst = defaultDST;       
        
        timeStruct->tm_mday = nextMMDDDayOfTheMonth;
        timeStruct->tm_mon = nextMMDDMonth - 1;

        //
        // get the time_t for the modified time structure
        //
        theTime = mktime(timeStruct);
         
        
        //
        // Allow for negative time_t's 4/13/06 SKJ
        //
        //if(theTime < 0)
        //{
            //ERROR = TRUE;
        //}
      
      
   }

   //
   // theTime should have the now correct day of the week and etc. 
   //
   //[self printTimeStruct: localtime(&theTime)];
   //fprintf(stderr, "TIMEWRAPPER >>>> getTimeTForNextMMDD theTime = %s \n", [self getDateWithTimeT: theTime]);
   //fflush(0);
   

   return theTime;

}


////////////////////////////////////////////////////
//
// checkDateFormat
//
// Makes sure that a date string is in MM/DD/YYYY format
// and that month and day in realistic range
//
////////////////////////////////////////////////////
- (BOOL) checkDateFormat: (char *) aDate
{
   char checkDate[12] = "###########";
   int aDateLen = 0; 

   int month = 0;
   int day = 0;
   char* year = (char *) nil;


   int i;

   BOOL ERROR = FALSE;
   BOOL isProperDate = NO;


   if(aDate == NULL)
   {
      ERROR = TRUE;
   }
  
   if(!ERROR)
   {
      aDateLen = strlen(aDate);
   }

   if(aDateLen < (size_t) 8 && !ERROR) 
   {
      ERROR = TRUE;
   }


   if((strlen(checkDate) - 1 < aDateLen) && !ERROR) 
   {
      ERROR = TRUE;
   }

    for(i=0; (i<aDateLen) && !ERROR  ; i++) 
    {
       if(!(isdigit(aDate[i]) || (aDate[i] == '/')) ) 
       {
            ERROR = TRUE;
            break;
       }

   }

   if(!ERROR)
   {
       strncpy(checkDate, aDate, strlen(aDate));

       month = atoi(strtok(checkDate, "/"));
       day = atoi(strtok(NULL, "/"));
       year = strtok(NULL, "#");
   } 

   if(year == (char *) nil)
   {
       ERROR = TRUE;
   }

   if(!ERROR && (strlen(year) != 4))
   {
       ERROR = TRUE;
   }
   
   if(((month < 1) || (month > 12)) && !ERROR) 
   {
       ERROR = TRUE;
   }

   if(((day < 1) || (day > 31)) && !ERROR) 
   {
       ERROR = TRUE;
   }

   if(!ERROR) 
   {
      isProperDate = YES;
   }

   return isProperDate;

}  //checkDateFormat
  


/////////////////////////////////////
//
// getSystemTime
//
/////////////////////////////////////
- (time_t) getSystemTime 
{
   return time(NULL);
}



/////////////////////////////////////////////
//
// getSystemDateAndTime
//
////////////////////////////////////////////
- (char *) getSystemDateAndTime 
{
  struct tm *timeStruct;
  time_t aTime;

  aTime = time(NULL);

  timeStruct = localtime(&aTime);

  strftime(sysDateAndTime, 35, "%a %d-%b-%Y %H:%M:%S", timeStruct) ;
  
  return sysDateAndTime;

}


////////////////////////////////////////////////////////
//
// drop
//
////////////////////////////////////////////////////////
- (void) drop 
{
  [super drop];
}



/////////////////////////////////////////
//
// stepTimeWithControllerObject
//
/////////////////////////////////////////
- (time_t) stepTimeWithControllerObject: controllerObject
{
   if(controllerObject != controller)
   {
       fprintf(stderr, "ERROR: TimeManager >>>> stepTimeWithControllerObject >>>> Attempting to step with incorrect controller\n");
       fflush(0);
       exit(1);
   }

   if(timeStepSize <= 0)
   {
       fprintf(stderr, "ERROR: TimeManager >>>> stepTimeWithControllerObject >>>> Time step is less than or equal to 0\n");
       fflush(0);
       exit(1);
   }
       


   currentTime += timeStepSize;

   return currentTime;

}

- setDefaultHour: (int) anHour
  setDefaultMinute: (int) aMinute
    setDefaultSecond: (int) aSecond
{
   defaultSecond = aSecond;
   defaultMinute = aMinute;
   defaultHour   = anHour;

   return self;
}


- setController: aController
{
   controller = aController;
   return self;
}



- setTimeStep: (time_t) aTime
{
   timeStepSize = aTime;
   return self;
}

- setCurrentTime: (time_t) aTime 
{
   currentTime = aTime;
   return self;
}


- setCurrentTimeWithDate: (char *) aFormattedDate
                withHour: (unsigned) anHour
              withMinute: (unsigned) aMinute
              withSecond: (unsigned) aSecond
{
   currentTime = [self getTimeTWithDate: aFormattedDate
                             withHour: anHour
                           withMinute: aMinute
                           withSecond: aSecond];
      
   return self;

}

- (time_t) getTimeDifferenceBetween: (time_t) aTime
                                and: (time_t) aLaterTime
{
    return (aLaterTime - aTime);
}


- (time_t) getCurrentTimeT
{
   return currentTime;
}

/////////////////////////////////////////
//
// getIsDSTWith
//
////////////////////////////////////////
- (BOOL) getIsDSTWith: (time_t) aTime
{
   struct tm *timeStruct = localtime( &aTime);
   BOOL isDST=0;

   if(timeStruct->tm_isdst == 1)
   {
       isDST = YES;
   }
  
   return isDST;
}

@end

