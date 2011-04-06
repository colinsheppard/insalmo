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




#import "SurvProb.h"

@implementation SurvProb 


+ createBegin: aZone
{

  SurvProb* aProb = [super createBegin: aZone];

  aProb->probZone = [Zone create: aZone];

  aProb->isStarvProb = 3;

  aProb->anAgentKnows = 3;

  aProb->funcList = [List create: aProb->probZone];
  aProb->funcListNdx = nil;


  return aProb;

}


- createEnd
{

   if(isStarvProb == 3)
   {
      [InternalError raiseEvent: "ERROR: SurvProb >>>> isStarvProb has not been set\n"];
   }

   if(anAgentKnows == 3)
   {
      [InternalError raiseEvent: "ERROR: SurvProb >>>> anAgentKnows has not been set\n"];
   }

   if(funcListNdx == nil)
   {
       funcListNdx = [funcList listBegin: [self getZone]];
   }


   return [super createEnd];

}


- setProbSymbol: (id <Symbol>) aNameSymbol
{

  probSymbol = aNameSymbol;

  probName = (char *) [probSymbol getName];

  return self;

}


- setIsStarvProb: (unsigned) aBool
{

  isStarvProb = aBool;

  return self;

}


- setAnAgentKnows: (unsigned) aBool
{

 anAgentKnows = aBool;

 return self;

}



- setSurvMgr: aSurvMgr
{

  survMgr = aSurvMgr;

  return self;

}




- (const char *) getName
{
   return probName;
}



- (id <Symbol>) getProbSymbol
{
  return probSymbol;
}


- (BOOL) getIsStarvProb
{
   return (BOOL) isStarvProb;
}


- (BOOL) getAnAgentKnows
{
   return (BOOL) anAgentKnows;
}



- (double) getSurvivalProb
{

  [self subclassResponsibility: M(getSurvivalProb)];

  return -1.0;

}




- createLogisticFuncWithInputMethod: (SEL) inputMethod
                withInputObjectType: (id <Symbol>) anObjType
                         andXValue1: (double) xValue1
                         andYValue1: (double) yValue1
                         andXValue2: (double) xValue2
                         andYValue2: (double) yValue2
{

      id aFunc;

      if(inputMethod == (SEL) nil)
      {
          [InternalError raiseEvent: "ERROR: SurvProb >>>> createLogisticFuncWithInputMethod inputMethod was not set\n"];
      }


      aFunc =  [LogisticFunc createBegin: probZone 
                         withInputMethod: inputMethod
		              usingIndep: xValue1
		                     dep: yValue1
                                   indep: xValue2
                                     dep: yValue2];

      aFunc = [aFunc createEnd];
      [funcList addLast: aFunc];

      return aFunc;

}



- createConstantFuncWithValue: (double) aValue
{

  id aFunc;

  aFunc = [ConstantFunc create: probZone
                     withValue: aValue];

  [funcList addLast: aFunc];

  return aFunc;

}





- createBoolSwitchFuncWithInputMethod: (SEL) anInputMethod
                         withYesValue: (double) aYesValue
                          withNoValue: (double) aNoValue
{

  id aFunc;

  if(anInputMethod == (SEL) nil)
  {
     [InternalError raiseEvent: "ERROR: SurvProb >>>> createBooleanSwitchFuncWithInputMethod inputMethod was not set\n"];
  }

  aFunc = [BooleanSwitchFunc   create: probZone
                      withInputMethod: anInputMethod 
                         withYesValue: aYesValue
                          withNoValue: aNoValue];


  [funcList addLast: aFunc];

  return aFunc;

}

- createCustomFuncWithClassName: (char *) className
              withInputSelector: (SEL) anInputSelector
            withInputObjectType: (id <Symbol>) objType
{
   //
   // SurvProb knows nothing about the custom function
   // at compile time. This gets resolved at runtime...
   //
   Class CustomFunc = Nil;
   id aFunc = nil;

   CustomFunc = [objc_get_class(className) class];

   //fprintf(stdout, "SurvProb >>>> createCustomFuncWithClassName >>>> className = %s\n", className);
   //fprintf(stdout, "SurvProb >>>> createCustomFuncWithClassName >>>> class = %p\n", CustomFunc);
   //fflush(0);

   
   aFunc = [CustomFunc createBegin: [self getZone]
                    setInputMethod: anInputSelector];


   //fprintf(stdout, "SurvProb >>>> createCustomFuncWithClassName >>>> aFunc = %p\n", aFunc);
   //fflush(0);
  
   [funcList addLast: aFunc];

   return aFunc;

}


- createObjectValueFuncWithInputSelector: (SEL) anObjSelector
                     withInputObjectType: (id) objType
{

    id aFunc = nil;

    //fprintf(stdout, "SurvProb >>>> createObjectValueFuncWithInputSelector >>>> BEGIN\n");
    //fflush(0);

    aFunc = [ObjectValueFunc createBegin: [self getZone]
                         withInputSelector: anObjSelector];


    [funcList addLast: aFunc];

    //fprintf(stdout, "SurvProb >>>> createObjectValueFuncWithInputSelector >>>> aFunc = %p END\n", aFunc);
    //fflush(0);
  
    return aFunc;

}




@end
