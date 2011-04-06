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

#import <stdlib.h>

#import "BreakoutAverager.h"

@implementation BreakoutAverager

+ createBegin: aZone
{
   BreakoutAverager* anAverager = [super createBegin: aZone];
   return anAverager;
}


- createEnd
{
  SEL aProbedSelector = sel_get_any_typed_uid (sel_get_name (probedSelector));
  
  if (!aProbedSelector)
    {
      fprintf(stderr, "ERROR: BreakoutAverager >>>> Typed selector %s does not exist\n", sel_get_name(probedSelector));
      fprintf(stderr, "Check BreakoutReporter creation\n");
      fflush(0);
      exit(1);
    }

  if (!sel_get_type (aProbedSelector))
    {
      fprintf(stderr, "ERROR: BreakoutAverager >>>> Type for selector %s does not exist\n", sel_get_name(probedSelector));
      fprintf(stderr, "Check BreakoutReporter creation\n");
      fflush(0);
      exit(1);
    }

  return [super createEnd];

}


- setOutputLabel: (char *) anOutputLabel
{
    if(strlen(anOutputLabel) > 50)
    {
        [InternalError raiseEvent: "ERROR: BreakoutAverager >>>> setOutputLabel more than 50 characters\n"];
    }

    strncpy(outputLabel, anOutputLabel, strlen(anOutputLabel));
    return self;

}


- setAveragerType: (char *) anAveragerType
{
   Count = (id <Symbol>) nil;
   Average = (id <Symbol>) nil;
   Total = (id <Symbol>) nil;
   Min = (id <Symbol>) nil;
   Max = (id <Symbol>) nil;
   StdDev = (id <Symbol>) nil;
   Variance = (id <Symbol>) nil;
   

   if(strncmp(anAveragerType, "Count", (size_t) 5) == 0)
   {
         Count = [Symbol create: [self getZone]
                        setName: "Count"]; 
   }
   else if(strncmp(anAveragerType, "Average", (size_t) 7) == 0)
   {
         Average = [Symbol create: [self getZone]
                          setName: "Average"]; 
   }
   else if(strncmp(anAveragerType, "Total", (size_t) 5) == 0)
   {
         Total = [Symbol create: [self getZone]
                          setName: "Total"]; 
   }
   else if(strncmp(anAveragerType, "Min", (size_t) 3) == 0)
   {
         Min = [Symbol create: [self getZone]
                          setName: "Min"]; 
   }
   else if(strncmp(anAveragerType, "Max", (size_t) 3) == 0)
   {
         Max = [Symbol create: [self getZone]
                          setName: "Max"]; 
   }
   else if(strncmp(anAveragerType, "StdDev", (size_t) 6) == 0)
   {
         StdDev = [Symbol create: [self getZone]
                          setName: "StdDev"]; 
   }
   else if(strncmp(anAveragerType, "Variance", (size_t) 8) == 0)
   {
         Variance = [Symbol create: [self getZone]
                          setName: "Variance"]; 
   }
   else
   {
        fprintf(stderr, "ERROR: BreakoutAverager >>>> setAveragerType >>>> incorrect Averager Type\n");
        fflush(0);
        exit(1);
   }


    return self;
}
  
   
- (char *) getOutputLabel
{
     return outputLabel;
}


- update
{

   /*
    if([collection getCount] > 0)
    {
         id probedObj = [collection getFirst];

         if([probedObj respondsTo: probedSelector] == FALSE)
         {
              fprintf(stderr, "ERROR: BreakoutAverager >>>> %s does not respond to Selector %s\n", [probedObj getName], sel_get_name(probedSelector));
              fprintf(stderr, "Check BreakoutReporter creation\n");
              fflush(0);
              exit(1);
         }
    }

   */

   [super update];

   return self;

}

- (double) getAveragerValue
{

    if(Count != (id <Symbol>) nil)
    {
        return [super getCount];
    }
    if(Average != (id <Symbol>) nil)
    {
        return [super getAverage];
    }
    if(Total != (id <Symbol>) nil)
    {
        return [super getTotal];
    }
    if(Min != (id <Symbol>) nil)
    {
        return [super getMin];
    }
    if(Max != (id <Symbol>) nil)
    {
        return [super getMax];
    }
    if(StdDev != (id <Symbol>) nil)
    {
        return [super getStdDev];
    }
    if(Variance != (id <Symbol>) nil)
    {
        return [super getVariance];
    }


    [InternalError raiseEvent: "ERROR: BreakoutAverager >>>> getAveragerValue >>>> Averager Type has not been set\n"];

    return -1.0;
}




@end
