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


#include "YearShuffler.h"

@implementation YearShuffler

+      createBegin: aZone 
     withStartTime: (time_t) aStartTime
       withEndTime: (time_t) anEndTime
   withReplacement: (BOOL) aReplaceFlag
   withRandGenSeed: (int) aSeed
   withTimeManager: (id <TimeManager>) aTimeManager
{
   YearShuffler* ys = [super createBegin: aZone];

   ys->ysZone = [Zone create: aZone];
   ys->timeManager = aTimeManager;
   ys->startTime = aStartTime;
   ys->endTime = anEndTime;
   ys->replaceFlag = aReplaceFlag;
   ys->randGenSeed = aSeed;


   if(ys->startTime >= ys->endTime)
   {
       fprintf(stderr, "ERROR: YearShuffler >>>> createBegin... >>>> startTime is greater than or equal to endTime\n");
       fflush(0);
       exit(1);
   }

   return ys;
}



- createEnd
{
   listOfRandomizedYears = [List create: ysZone];
   listOffset = 0;


   if(randGenSeed < 0)
   {
      fprintf(stderr, "ERROR: YearShuffler >>>> createEnd >>>> randGenSeed is less than zero\n");
      fflush(0);
      exit(1);
   }


   randGen = [MT19937gen create: ysZone 
               setStateFromSeed: randGenSeed];

   listRandomizer = [UniformUnsignedDist create: ysZone
                                   setGenerator: randGen
                                 setUnsignedMin: (unsigned) 0 
                                         setMax: (unsigned) 1];

   listShuffler = [ListShuffler      create: ysZone 
                           setUniformRandom: listRandomizer];

   [self calcNumSimYears];
   [self populateYearList];

   return [super createEnd];
}



- calcNumSimYears
{
   int aStartYear =  [timeManager getYearWithTimeT: startTime];
   int aStartMonth =  [timeManager getMonthWithTimeT: startTime];
   int aStartDayOfMonth = [timeManager getDayOfMonthWithTimeT: startTime];

   int anEndYear =  [timeManager getYearWithTimeT: endTime];
   int anEndMonth =  [timeManager getMonthWithTimeT: endTime];
   int anEndDayOfMonth = [timeManager getDayOfMonthWithTimeT: endTime];

   int yearDiff = anEndYear - aStartYear;
   int monthDiff = anEndMonth - aStartMonth;
   int dayDiff = anEndDayOfMonth - aStartDayOfMonth;

   if(monthDiff == 0)
   {
       if(dayDiff >= 0)
       {
           yearDiff++;
       }
   }
   else if(monthDiff > 0)
   {
       yearDiff++; 
   }
    
   numSimYears = yearDiff;
   startDay = aStartDayOfMonth;
   startMonth = aStartMonth;
   startYear = aStartYear;
  
   endYear = anEndYear;

   if(numSimYears <= 1) 
   {
       fprintf(stderr, "ERROR: YearShuffler >>>> calcNumSimYears >>>> Sorry, you cannot use YearShuffler for simulations of one year or less\n");
       fflush(0);
       exit(1);
   }

   fprintf(stdout, "YearShuffler >>>> calcNumSimYears >>>> startYear = %d endYear = %d\n", startYear, endYear);
   fflush(0);
   //exit(0);


   return self;
}


- populateYearList
{
   if(replaceFlag == NO)
   {
       int i;
       for(i = startYear; i < (startYear + numSimYears); i++)
       {
          int* simYear = (int *) [ysZone alloc: sizeof(int)];
          *simYear = i;
          [listOfRandomizedYears addLast: (void *) simYear]; 

          fprintf(stdout, "YearShuffler >>>> populateYearList >>>> replaceFlag == NO >>>> simYear = %d\n", *simYear);
          fflush(0);
       }

       [listShuffler shuffleWholeList: listOfRandomizedYears];

   }
   else  // replaceFlag == Yes
   {
       int i;
       [listRandomizer setUnsignedMin: startYear
                               setMax: (startYear + numSimYears - 1)]; 

       for(i = 0; i < numSimYears; i++)
       {
          unsigned int* simYear = (unsigned int *) [ysZone alloc: sizeof(unsigned int)];
          *simYear = [listRandomizer getUnsignedSample];
          [listOfRandomizedYears addLast: (void *) simYear]; 

          fprintf(stdout, "YearShuffler >>>> populateYearList >>>> replaceFlag == YES >>>> simYear = %d\n", *simYear);
          fflush(0);
       }
           

   }

   return self;
}

- (time_t) checkForNewYearAt: (time_t) aTimeT
{
   int thisDay = [timeManager getDayOfMonthWithTimeT: aTimeT];
   int thisMonth = [timeManager getMonthWithTimeT: aTimeT];
   time_t retVal = aTimeT;
        
   if((thisDay == startDay) && (thisMonth == startMonth)) 
   {
        char* newSimDate = [ysZone alloc: 12 * sizeof(char)];
        int* newSimYear = NULL;

        if(listOffset < numSimYears)
        {
            newSimYear = (int *) [listOfRandomizedYears atOffset: listOffset];
            listOffset++;
        }

// The following 'else if' can be reached in simulations if the
// list of shuffled years contains fewer leap years than in the 
// unshuffled years. This is a possibility only when shuffling
// years with replacement.

        else if(listOffset == numSimYears)
        {
            newSimYear = (int *) [listOfRandomizedYears atOffset: 0];
            listOffset++;
            fprintf(stderr, "WARNING: YearShuffler >>>> checkForNewYearAt >>>> \n       Number of simulation years exceeded by one; repeating first year\n");
        }
 
        if(newSimYear != NULL)
        {
            int anHour = [timeManager getHourWithTimeT: aTimeT];
            int aMinute = [timeManager getMinuteWithTimeT: aTimeT];
            int aSecond = [timeManager getSecondWithTimeT: aTimeT];
            sprintf(newSimDate, "%d/%d/%d", startMonth, startDay, *newSimYear); 
            retVal = [timeManager getTimeTWithDate: newSimDate
                                          withHour: anHour
                                        withMinute: aMinute
                                        withSecond: aSecond];
            currentYear = *newSimYear;
        }
        else
        {
            fprintf(stderr, "ERROR: YearShuffler >>>> checkForNewYearAt >>>> newSimYear is NULL\n");
            fflush(0);
            exit(1);
        }
           
        [ysZone free: newSimDate];
   }
   
   return retVal;
}


- (id <List>) getListOfRandomizedYears
{
  return listOfRandomizedYears;
}
 

- (void) drop
{
   if(listOfRandomizedYears != nil)
   {
       [listOfRandomizedYears deleteAll];
       [listOfRandomizedYears drop];
       listOfRandomizedYears = nil;
   }

   if(randGen != nil)
   {
      [randGen drop];
      randGen = nil;
   }
  
   if(ysZone != nil)
   {
       [ysZone drop];
       ysZone = nil;
   }
   
}
@end

