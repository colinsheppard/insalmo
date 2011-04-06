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



#import "ReddScourFunc.h"
#import "FishCell.h"
#import "Redd.h"
#import "globals.h"

@implementation ReddScourFunc

+    createBegin: aZone
  setInputMethod: (SEL) anInputMethod
{

   ReddScourFunc* scourFunc = [super createBegin: aZone];

   [scourFunc setInputMethod: anInputMethod];
   [scourFunc createInputMethodMessageProbeFor: anInputMethod];

   scourFunc->habShearParamA = (double) LARGEINT;
   scourFunc->habShearParamB = (double) LARGEINT;

   scourFunc->uniformDoubleDist = nil; 

   return scourFunc;

}


- createEnd
{
   return [super createEnd];
}


- updateWith: anObj
{
   int speciesNdx;

   double scourParam=0.0;
   double shearStress=0.0;
   double scourSurvival=0.0;

   double mortReddScourDepth=0.0;

   double yesterdaysRiverFlow;
   double todaysRiverFlow;
   double tomorrowsRiverFlow;

   id aRedd = anObj;
   FishParams* fishParams;
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


   funcValue = 1.0;


   cell = [aRedd getCell];

   if(cell == nil)
   {
       fprintf(stderr, "ReddScourFunc >>>> updateWith >>>> cell id nil\n");
       fflush(0);
       exit(1);
   }

   if(uniformDoubleDist == nil)
   {
      id aRandGen = [cell getRandGen];

      if(aRandGen == nil)
      {
         fprintf(stderr, "ERROR: ReddScourFunc >>>> updateWith >>>> the random generator is nil\n");
         fflush(0);
         exit(1);
      }
     
      //
      //Create the uniform distribution
      //
      uniformDoubleDist = [UniformDoubleDist create: [self getZone]
                                 setGenerator: aRandGen
                                 setDoubleMin: 0.0
                                       setMax: 1.0];
   }

 
   //
   // Get the following parameters once.
   // Assumption: They don't change within a reach during a model run
   //
   if(habShearParamA >= (double) LARGEINT)
   {
       habShearParamA = [cell getHabShearParamA];
   }
   if(habShearParamB >= (double) LARGEINT)
   {
       habShearParamB = [cell getHabShearParamB];
   }
  
   fishParams = [aRedd getFishParams];
   speciesNdx = [aRedd getSpeciesNdx];

   yesterdaysRiverFlow = [cell getYesterdaysRiverFlow];
   todaysRiverFlow = [cell getRiverFlow];
   tomorrowsRiverFlow = [cell getTomorrowsRiverFlow];
  

   if( (yesterdaysRiverFlow < todaysRiverFlow) && (todaysRiverFlow > tomorrowsRiverFlow)) 
   {
       mortReddScourDepth = fishParams->mortReddScourDepth;

       shearStress = habShearParamA*pow(todaysRiverFlow, habShearParamB);

       scourParam = 3.33*exp(-1.52*shearStress/0.045);

       if(isnan(scourParam) || isinf(scourParam))
       {
            fprintf(stderr, "ERROR: ReddScourFunc >>>> scourParam >>>> updateWith >>>> scourParam is nan or inf\n");
            fprintf(stderr, "ERROR: ReddScourFunc >>>> scourParam >>>> updateWith >>>> shearStress = %f\n", shearStress);
            fprintf(stderr, "ERROR: ReddScourFunc >>>> scourParam >>>> updateWith >>>> todaysRiverFlow = %f\n", todaysRiverFlow);
            fprintf(stderr, "ERROR: ReddScourFunc >>>> scourParam >>>> updateWith >>>> habShearParamA = %f\n", habShearParamA);
            fprintf(stderr, "ERROR: ReddScourFunc >>>> scourParam >>>> updateWith >>>> habShearParamB = %f\n", habShearParamB);
            fflush(0);
            exit(1);
       }

       if((scourParam * mortReddScourDepth) > 100.0)
       {
           funcValue = 1.0;
       }
       else
       {
           scourSurvival = 1.0 - exp(-scourParam * mortReddScourDepth);

           if(isnan(scourSurvival) || isinf(scourSurvival))
           {
                fprintf(stderr, "ERROR: ReddScourFunc >>>> scourParam >>>> updateWith >>>> scourSurvival is nan or inf\n");
                fflush(0);
                exit(1);
           }
            
           if([uniformDoubleDist getDoubleSample] > scourSurvival)
           {
              funcValue = 0.0;
           }
       }

   } // if (flow peaked)

   if((funcValue < 0.0) || (funcValue > 1.0))
   {
      fprintf(stderr,"ERROR: ReddScourFunc >>>> funcValue is not between 0 an 1\n");
      fflush(0);
      exit(1);
   }

   return self;

}

@end

