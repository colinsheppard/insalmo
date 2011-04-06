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



#import "LogisticFunc.h"
#import <math.h>

@implementation LogisticFunc


+      createBegin: aZone 
   withInputMethod: (SEL) anInputMethod
        usingIndep: (double) xValue1
               dep: (double) yValue1
             indep: (double) xValue2
               dep: (double) yValue2
{
  LogisticFunc* aLogisticFunc = [super createBegin: aZone];
  aLogisticFunc->pA=LARGEINT;
  aLogisticFunc->pB=LARGEINT;
  aLogisticFunc->prevInputVal=-LARGEINT;

  if(xValue1 == xValue2)
  {
      [InternalError raiseEvent: "LogisticFunc >>>> createBegin... >>>> the independent variables x1 and x2 are equal\n"];
  }
  if((yValue1 <= 0.0) || (yValue1 >= 1.0))
  {
      [InternalError raiseEvent: "LogisticFunc >>>> createBegin... >>>> y value parameter %f out of 0.0 - 1.0 range during creation of LogisticFunc\n", yValue1];
  }
  if((yValue2 <= 0.0) || (yValue2 >= 1.0))
  {
      [InternalError raiseEvent: "LogisticFunc >>>> createBegin... >>>> y value parameter %f out of 0.0 - 1.0 range during creation of LogisticFunc\n", yValue2];
  }


  aLogisticFunc->messageProbe = nil;

  aLogisticFunc->logisticLimiter = 84.0;
 
  [aLogisticFunc setInputMethod: anInputMethod];
  [aLogisticFunc createInputMethodMessageProbeFor: anInputMethod];
  [aLogisticFunc initializeWithIndep: xValue1 
                        dep: yValue1
	              indep: xValue2 
                        dep: yValue2]; 

  return aLogisticFunc;

}


- createEnd
{
    if ((pA == LARGEINT)||(pB == LARGEINT))
       [InternalError raiseEvent: "ERROR: >>>> LogisticFunc >>>> createEnd >>>> Couldn't finish creating because "
                                  "the function was not initialized properly.\n"];
		  
    return [super createEnd];
}



- setLogisticFuncLimiterTo: (double) aLimiter
{
   logisticLimiter = aLimiter;
   return self;
}


- getLogisticFunc
{
   return self;
}



- updateWith: anObj
{

  double inputVal=0.0;
 
   
   if(inputMethod == (SEL) nil)
   {
      [InternalError raiseEvent: "ERROR: LogisticFunc >>>> updateWith >>>> anObj >>>> inputMethod = %p\n", inputMethod];
   }
  
   if(anObj == nil)
   {
      [InternalError raiseEvent: "ERROR: LogisticFunc >>>> updateWith >>>> anObj is nil\n"];
   }
  
   if(![anObj respondsTo: inputMethod])
   {
      [InternalError raiseEvent: "ERROR: LogisticFunc >>>> updateWith >>>> anObj does not respond to inputMethod\n"];
   }

   if(messageProbe == nil)
   {
      [InternalError raiseEvent: "ERROR: LogisticFunc >>>> updateWith: >>>> messageProbe is nil\n"];
   } 

   inputVal = [messageProbe doubleDynamicCallOn: anObj];

   if(prevInputVal == inputVal)
   {
       funcValue =  prevFuncVal;
   }
   else
   { 
      funcValue = [self evaluateFor: inputVal];
   }

   prevInputVal = inputVal;
   prevFuncVal =  funcValue;

   return self;

}

- (double) evaluateFor: (double) x
{
  double temp;
  double arg;
  double retArg;
   
  //
  // Return a value of 1.0 if arg > 20, or a value of 0.0 if arg < -20.
  // This avoids floating point overflow and underflow errors 
  // and speeds execution by avoiding unnecessary calls to exp().
  // The maximum error due to this shortcut is 1/500 millionth.
  //
  // The exp(arg) statement should be bypassed if arg > 20 or < -20
  // to avoid overflow/underflow errors on a Pentium computer.
  //

  arg = pA*x+pB;   
 
  //fprintf(stdout, "LogisticFunc >>>> evaluateFor: %f\n", x);
  //fprintf(stdout, "LogisticFunc >>>> evaluateFor: logisticLimiter = %f \n", logisticLimiter);
  //fflush(0);



  if(arg > logisticLimiter)
  { 
     return 1.0;
  }
  else if(arg < -logisticLimiter)
  { 
     return 0.0;
  }

  temp = exp(arg);
  //return (temp/(1.0+temp));
  retArg = (temp/(1.0+temp));

  //fprintf(stdout, "LogisticFunc >>>> evaluateFor >>>> retArg: %f\n", retArg);
  //fflush(0);

  return retArg;

}


/* It calculates the parameters (a,b) to the following logistic function:
 * y = exp(a+bx)/(1+exp(a+bx))
 */
- initializeWithIndep: (double) x1 dep: (double) y1
	       indep: (double) x2 dep: (double) y2 
{

 double u, v;

  u = log(y1/(1.0-y1));
  v = log(y2/(1.0-y2));

  pA = (u - v)/(x1-x2);
  pB = u - pA*x1;
  return self;
}

- (double) getpA
{
    return pA;
}


- (double) getpB
{
    return pB;
}

- (void) drop
{
     fprintf(stdout, "LogisticFunc >>>> drop >>>> BEGIN\n");
     fflush(0);

     [super drop];

     fprintf(stdout, "LogisticFunc >>>> drop >>>> END\n");
     fflush(0);
}
 

@end

