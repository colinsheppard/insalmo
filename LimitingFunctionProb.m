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




#import "LimitingFunctionProb.h"

@implementation LimitingFunctionProb 


+ createBegin: aZone
{

  LimitingFunctionProb* aProb;

  aProb = [super createBegin: aZone];

  return aProb;

}


- createEnd
{
   if([funcList getCount] < 2)
   {
      [InternalError raiseEvent: "ERROR: LimitingFunctionProb >>>> probName = %s getSurvivalProb funcList has less than 2 members\n", probName];
   }

   minProbFunc = [funcList getFirst];

   return [super createEnd];
}


- setMinSurvProb: (double) aMinSurvProb
{

    minSurvProb = aMinSurvProb;
 
    return self;

}



- (id <List>) getMultiFunctionList
{
   return funcList;
}



- (double) getSurvivalProb
{

   double survProb=1.0;
   double survIncreaseFactor=-LARGEINT;
   double maxP = -LARGEINT;

   id probFunc = nil;

   //xprint(minProbFunc);

   minSurvProb = [minProbFunc getFuncValue];

   if((minSurvProb < 0.0) || (minSurvProb > 1.0))
   {
       [InternalError raiseEvent: "ERROR: LimitingFunctionProb >>>> minSurvProb in %s is not between zero and one. Value is: %f\n", probName, minSurvProb];
   }

   //xprint(funcListNdx);

   if(funcListNdx == nil)
   {
       [InternalError raiseEvent: "ERROR: LimitingFunctionProb >>>> funcListNdx is nil\n"];
   }
      
   [funcListNdx setLoc: Start];

   while(([funcListNdx getLoc] != End) && ((probFunc = [funcListNdx next]) != nil))
   {

     if(minProbFunc == probFunc) continue;

     survIncreaseFactor = [probFunc getFuncValue];
 
     if((survIncreaseFactor < 0.0) || (survIncreaseFactor > 1.0))
     {
         [InternalError raiseEvent: "ERROR: LimitingFunctionProb >>>> survIncreaseFactor is not between zero and one. Value is: %f\n", survIncreaseFactor];
     }
   
     if(survIncreaseFactor > maxP)
     {
          maxP = survIncreaseFactor;
     }

   }

   survProb = minSurvProb +
              ((1.0 - minSurvProb) * maxP);

   //if((survProb < 0.0) || (survProb > 1.0))
   //{
      //[InternalError raiseEvent: "ERROR: LimitingFunctionProb >>>> probName = %s >>>> survProb = %f\n", probName, survProb];
   //}

   return survProb;

}


@end
