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



#import "ObjectValueFunc.h"
#import <math.h>

@implementation ObjectValueFunc


+        createBegin: aZone 
   withInputSelector: (SEL) anInputSelector
{
  ObjectValueFunc* anObjectValueFunc = [super createBegin: aZone];

  anObjectValueFunc->messageProbe = nil;

  [anObjectValueFunc setInputMethod: anInputSelector];
  [anObjectValueFunc createInputMethodMessageProbeFor: anInputSelector];

  return anObjectValueFunc;

}


- createEnd
{
    return [super createEnd];
}




- getLogisticFunc
{
   return self;
}



- updateWith: anObj
{

  double objectVal=0.0;
 
   
   if(inputMethod == (SEL) nil)
   {
      [InternalError raiseEvent: "ERROR: ObjectValueFunc >>>> updateWith >>>> anObj >>>> inputMethod = %p\n", inputMethod];
   }
  
   if(anObj == nil)
   {
      [InternalError raiseEvent: "ERROR: ObjectValueFunc >>>> updateWith >>>> anObj is nil\n"];
   }
  
   if(![anObj respondsTo: inputMethod])
   {
      [InternalError raiseEvent: "ERROR: ObjectValueFunc >>>> updateWith >>>> anObj does not respond to inputMethod %s\n", sel_get_name(inputMethod)];
   }

   if(messageProbe == nil)
   {
      [InternalError raiseEvent: "ERROR: ObjectValueFunc >>>> updateWith: >>>> messageProbe is nil\n"];
   } 

   objectVal = [messageProbe doubleDynamicCallOn: anObj];

   if((objectVal < 0.0) || (objectVal > 1.0))
   {
        fprintf(stderr, "ERROR: ObjectValueFunc >>>> updateWith >>>> objectVal = %f is not between 0 and 1 Selector = %s\n", objectVal, sel_get_name(inputMethod));
        fflush(0);
        exit(1);
   }

   //fprintf(stderr, "ObjectValueFunc >>>> updateWith >>>> objectVal = %f \n", objectVal);
   //fflush(0);
   
   // Following statement was missing until Feb 2012. It does not affect inSALMO.
   funcValue = objectVal;


   return self;

}

 

@end

