/*
inSALMO individual-based salmon model, Version 1.2, April 2013.
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



#import "ReddSuperimpFunc.h"
#import "FishCell.h"
#import "Redd.h"
#import "globals.h"

@implementation ReddSuperimpFunc

+    createBegin: aZone
  setInputMethod: (SEL) anInputMethod
{

   ReddSuperimpFunc* superimpFunc = [super createBegin: aZone];

   superimpFunc->uniformDist = nil;
 

   [superimpFunc setInputMethod: anInputMethod];
   [superimpFunc createInputMethodMessageProbeFor: anInputMethod];

   return superimpFunc;

}


- createEnd
{

   return [super createEnd];

}


- updateWith: anObj
{

   //int otherReddSpNdx;
   FishParams* otherReddFishParams;
   float superimpSF=1.0;
   id nextRedd;
   id <List> reddList=nil;
   id <ListIndex> reddListNdx=nil;
   double reddSuperimpRisk=-1.0;
   double areaSpawnedToday = 0.0;
   //double cellArea;
   //double cellGravelFrac;
   double otherReddSize;
   double areaAvailableToday;

   id aRedd = anObj;
   id cell = nil;

   if(inputMethod == (SEL) nil)
   {
      fprintf(stderr, "ERROR: ReddSuperimpFunc >>>> updateWith >>>> anObj >>>> inputMethod = %p\n", inputMethod);
      fflush(0);
      exit(1);
   }
  
   if(![anObj respondsTo: inputMethod])
   {
      fprintf(stderr, "ERROR: ReddSuperimpFunc >>>> updateWith >>>> anObj does not respond to inputMethod\n");
      fflush(0);
      exit(1);
   }

   if(messageProbe == nil)
   {
      fprintf(stderr, "ERROR: ReddSuperimpFunc >>>> updateWith: >>>> messageProbe is nil\n");
      fflush(0);
      exit(1);
   } 

   // First, if the redd is guarded then there is no superimposition
   if([aRedd getIAmGuarded] == YES)
   {
     funcValue = 1.0;
     return self;
   }

   // If there is no gravel, then there can be no superimposition
   if ([[aRedd getCell] getCellFracSpawn] < 0.0000001)
   {
     funcValue = 1.0;
     return self;
   }
  

   // Otherwise, do all the other stuff
   cell = [aRedd getCell];
   areaAvailableToday = [cell getCellAvailableGravelArea]; // unguarded gravel area after spawning is done

   if(uniformDist == nil)
   {
    id aRandGen = [cell getRandGen];

    //
    // Ensure that aRandGen conformsTo the correct protocol
    //

        if(aRandGen == nil)
        {
           fprintf(stderr, "ERROR: ReddSuperimpFunc >>>> the random generator is nil\n");
           fflush(0);
           exit(1);
        }
     

    //Create Uniform Dist
     uniformDist = [UniformDoubleDist create: [self getZone]
                                setGenerator: aRandGen
                                setDoubleMin: 0.0
                                      setMax: 1.0];
 
   }


   // Add up how much area was disturbed by redd-building today
   // assuming redds created on same day do not overlap
   // And calculate the unguarded spawning area *before* spawning started
   if( (reddList = [cell getReddsIContain]) != nil) 
   {
     // fprintf(stderr, "SuperimpFunc >> Redds in cell: %d \n", [reddList getCount]);

     reddListNdx = [reddList listBegin: scratchZone];

      while (([reddListNdx getLoc] != End) && ((nextRedd = [reddListNdx next]) != nil)) 
      {
            if(nextRedd == aRedd) break;

            if([nextRedd getCreateTimeT] == [aRedd getCurrentTimeT])
            {
               //   fprintf(stderr, "SuperimpFunc >> another redd created here today \n");
                  otherReddFishParams = [nextRedd getFishParams];

                  otherReddSize = otherReddFishParams->reddSize;
                  areaSpawnedToday += otherReddSize;
                  areaAvailableToday -= otherReddFishParams->fishSpawnDefenseArea;
                  // fprintf(stderr, "SuperimpFunc >> Area disturbed today: %f \n", areaSpawnedToday);
            }
      }  // while
                 

      if(areaAvailableToday < areaSpawnedToday)  // All available area was disturbed
      {
         reddSuperimpRisk = 1.0;
      }
      else
      {
         reddSuperimpRisk = areaSpawnedToday/areaAvailableToday;
      }
      // fprintf(stderr, "SuperimpFunc >> areaSpawnedToday: %f areaAvailableToday: %f Risk: %f \n", 
      // areaSpawnedToday, areaAvailableToday, reddSuperimpRisk);

      uniformRanNum = [uniformDist getDoubleSample];

      if(uniformRanNum < reddSuperimpRisk) 
      {
        superimpSF *= [uniformDist getDoubleSample];  // Multiply 1.0 x rand
      }
    }  // if (( reddList


     [reddListNdx drop];


   funcValue = superimpSF;
   
   if((funcValue < 0.0) || (funcValue > 1.0))
   {
      fprintf(stderr, "ERROR: funcValue is not between 0 an 1\n");
      fflush(0);
      exit(1);
   }

   return self;
}






@end

