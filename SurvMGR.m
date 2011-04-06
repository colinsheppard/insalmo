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

#include <stdlib.h>
#include <time.h>

#import "SurvMGR.h"



@implementation SurvMGR


+         createBegin: aZone
   withHabitatObject: anObj
{

  SurvMGR* aSurvMgr;
  
  static unsigned anNdx = 0;

  aSurvMgr = [super createBegin: aZone];

  aSurvMgr->managerNdx = anNdx++;

  aSurvMgr->mgrZone = [Zone create: aZone];
  aSurvMgr->ANIMAL = [Symbol create: aSurvMgr->mgrZone setName: "ANIMAL"];
  aSurvMgr->HABITAT = [Symbol create: aSurvMgr->mgrZone setName: "HABITAT"];


  aSurvMgr->starvSurvivalProb = nil;
  aSurvMgr->listOfSurvProbs = nil;
  aSurvMgr->listOfKnownNonStarvSurvProbs = nil;
  aSurvMgr->listOfHabitatUpdateFuncs = nil;
  aSurvMgr->listOfAnimalUpdateFuncs = nil;

  aSurvMgr->myCurrentAnimal = nil;
  aSurvMgr->myHabitatObject = anObj;

  aSurvMgr->testOutput = NO;
  aSurvMgr->testOutputFilePtr = NULL;
  aSurvMgr->formatString = NULL;

  aSurvMgr->survProbLstNdx = nil;
  aSurvMgr->knownNonStarvSurvProbLstNdx = nil;

  aSurvMgr->listOfSurvProbs = [List create: aSurvMgr->mgrZone];
  aSurvMgr->listOfKnownNonStarvSurvProbs = [List create: aSurvMgr->mgrZone];
  aSurvMgr->listOfHabitatUpdateFuncs = [List create: aSurvMgr->mgrZone];
  aSurvMgr->listOfAnimalUpdateFuncs = [List create: aSurvMgr->mgrZone];


  return aSurvMgr;

}



- createEnd
{

  id aProb = nil;


  //
  //
  //
  [listOfSurvProbs forEach: M(createEnd)];

  numberOfProbs = [listOfSurvProbs getCount];

  //
  // This index is used throughout the model run DO NOT DROP IT!!!
  //
  if(survProbLstNdx != nil)
  {
     [survProbLstNdx drop]; 
  }

  survProbLstNdx = [listOfSurvProbs listBegin: mgrZone];

  if( [listOfKnownNonStarvSurvProbs getCount] > 0)
  {
      [listOfKnownNonStarvSurvProbs removeAll];
  }
 

  [survProbLstNdx setLoc: Start];

  while (([survProbLstNdx getLoc] != End) && ((aProb = [survProbLstNdx next]) != nil))
  {

     BOOL isStarvSurvProb = [aProb getIsStarvProb];
     BOOL anAgentKnows = [aProb getAnAgentKnows];

     if(!isStarvSurvProb && anAgentKnows)
     {
        [listOfKnownNonStarvSurvProbs addLast: aProb];
     }
       
  }
   
  //
  // This index is used throughout the model run DO NOT DROP IT!!!
  //
  knownNonStarvSurvProbLstNdx  = [listOfKnownNonStarvSurvProbs listBegin: mgrZone];


  return [super createEnd];

}


- setMyHabitatObject: anObj
{

   myHabitatObject = anObj;

   return self;

}



- setTestOutputOnWithFileName: (char *) aFileName;
{

    static FILE* outFilePtr = NULL;

    struct tm *timeStruct;
    time_t aTime;
    char sysDateAndTime[35];

    testOutput = TRUE;

    if(outFilePtr == NULL)
    {
        if((outFilePtr = fopen(aFileName, "w")) == NULL)
        {
           [InternalError raiseEvent: "ERROR: SurvMGR >>>> Cannot open %s for writing\n", aFileName];
        }

        testOutputFilePtr = outFilePtr;

        aTime = time(NULL);
        timeStruct = localtime(&aTime);
        strftime(sysDateAndTime, 35, "%a %d-%b-%Y %H:%M:%S", timeStruct) ;

        fprintf(testOutputFilePtr, "\n");
        fprintf(testOutputFilePtr, "Model Run System Date and Time: %s\n", sysDateAndTime); 
        fprintf(testOutputFilePtr, "\n");
        fflush(0);

    }

    testOutputFilePtr = outFilePtr;

    [self createHeaderAndFormatStrings];

    return self;

}


- (id <Symbol>) getANIMALSYMBOL
{

   if(ANIMAL == nil)
   {
      fprintf(stderr,"ERROR: SurvMgr >>>> ANIMAL Symbol is nil\n");
      fflush(0);
      exit(1);
   }

   return ANIMAL;
}

- (id <Symbol>) getHABITATSYMBOL
{

   if(HABITAT == nil)
   {
      fprintf(stderr,"ERROR: SurvMgr >>>> HABITAT Symbol is nil\n");
      fflush(0);
      exit(1);
   }


   return HABITAT;
}


- (int) getNumberOfProbs
{
  return numberOfProbs;
}


- getHabitatObject
{
  return myHabitatObject;
}


- getCurrentAnimal
{
  return myCurrentAnimal;
}




- addPROBWithSymbol: (id <Symbol>) aProbSymbol
          withType: (char *) aProbType
    withAgentKnows: (BOOL) anAgentKnows
   withIsStarvProb: (BOOL) isAStarvProb
{

  id aProb = nil;
  int i;
   
  for(i = 0; i < [listOfSurvProbs getCount]; i++)
  {
      id aProb = [listOfSurvProbs atOffset: i];
    
      if([aProb getProbSymbol] == aProbSymbol)
      {
           fprintf(stderr, "ERROR: addPROBWithSymbol:withType:withAgentKnows:withIsStarvProb >>>> Probability object %s already exists\n", [aProb getName]);
           fflush(0);
           exit(1);
      }
  }



  if(strncmp("SingleFunctionProb", aProbType, strlen("SingleFunctionProb")) == 0)
  {

     aProb = [SingleFuncProb createBegin: mgrZone];

  }
  else if(strncmp("LimitingFunctionProb", aProbType, strlen("LimitingFunctionProb")) == 0)
  {

     aProb = [LimitingFunctionProb createBegin: mgrZone];
  }

  else if(strncmp("CustomProb", aProbType, strlen("CustomProb")) == 0)
  {
     //
     // SurvMGR knows nothing about the custom probablity
     // at compile time. This gets resolved at runtime...
     //
     Class aCustomProbClass;

     aCustomProbClass = [objc_get_class([aProbSymbol getName]) class];
     
     aProb = [aCustomProbClass createBegin: mgrZone];

  }
  else
  {
     [InternalError raiseEvent: "ERROR: SurvMGR >>>> Cannot create Probability type %s \n", aProbType];
  }  


   [aProb setProbSymbol: aProbSymbol];
   [aProb setIsStarvProb: isAStarvProb];
   [aProb setAnAgentKnows: anAgentKnows];
   [aProb setSurvMgr: self];

   [listOfSurvProbs addLast: aProb];


   if(isAStarvProb)
   {
     if(starvSurvivalProb != nil)
     {
         [InternalError raiseEvent: "ERROR: SurvMGR >>>> addPROBWithSymbol:andType:andAgentKnows:andIsStarvProb >>>> attempting to create more than one starvation survival probability function\n"];
     }
     starvSurvivalProb = aProb;
   }

  return self;

}


- addBoolSwitchFuncToProbWithSymbol: (id <Symbol>) aProbSymbol
          withInputObjectType: (id <Symbol>) objType
               withInputSelector: (SEL) aSelector
                  withYesValue: (double) aYesValue
                   withNoValue: (double) aNoValue
{

  id <ListIndex> ndx;
  id aProb = nil;
  id aFunc = nil;

  BOOL ERROR=TRUE;

  ndx = [listOfSurvProbs listBegin: mgrZone];
  while (([ndx getLoc] != End) && ((aProb = [ndx next]) != nil))
  {
     if(aProbSymbol == [aProb getProbSymbol])
     {

          aFunc = [aProb createBoolSwitchFuncWithInputMethod: aSelector
                                        withYesValue: aYesValue
                                         withNoValue: aNoValue];



         if(objType == HABITAT)
         {
             [listOfHabitatUpdateFuncs addLast: aFunc];
         }
         else if(objType == ANIMAL)
         {
             [listOfAnimalUpdateFuncs addLast: aFunc];
         }
         else
         {
            break;  //an error occurred 
         }

         ERROR = FALSE;
         break;
     }

  }


  [ndx drop];

  if(ERROR) 
  {
     [InternalError raiseEvent: "ERROR: SurvMGR >>>> addBoolSwitchFuncToProbWihSymbol >>>> Either aProbSymbol = %s was not found or inputObject is invalid\n", [aProbSymbol getName]];
  }


  return self;

}



- addLogisticFuncToProbWithSymbol: (id <Symbol>) aProbSymbol
         withInputObjectType: (id <Symbol>) objType
              withInputSelector: (SEL) aSelector
                  withXValue1: (double) xValue1
                  withYValue1: (double) yValue1
                  withXValue2: (double) xValue2
                  withYValue2: (double) yValue2
{

  id <ListIndex> ndx;
  id aProb = nil;
  id aFunc = nil;

  BOOL ERROR=TRUE;


  ndx = [listOfSurvProbs listBegin: mgrZone];
  while (([ndx getLoc] != End) && ((aProb = [ndx next]) != nil))
  {
     if(aProbSymbol == [aProb getProbSymbol])
     {

        aFunc = [aProb createLogisticFuncWithInputMethod: aSelector
                              withInputObjectType: objType
                                       andXValue1: xValue1
                                       andYValue1: yValue1
                                       andXValue2: xValue2
                                       andYValue2: yValue2];


         if(objType == HABITAT)
         {
             [listOfHabitatUpdateFuncs addLast:  aFunc];
         }
         else if(objType == ANIMAL)
         {
             [listOfAnimalUpdateFuncs addLast: aFunc];
         }
         else
         {
            break;  //an error occurred 
         }

         ERROR = FALSE;
         break;
     }

  }


  [ndx drop];

  if(ERROR) 
  {
     [InternalError raiseEvent: "ERROR: SurvMGR >>>> addLogisticFuncToProbWithSymbol >>>> Either aProbSymbol = %s was not found or inputObjectType is invalid\n", [aProbSymbol getName]];
  }


  return self;

}


- setLogisticFuncLimiterTo: (double) aLimiter
{

   id aFunc = nil;

   id <ListIndex> habitatUpdateFuncsNdx = [listOfHabitatUpdateFuncs listBegin: mgrZone];
   id <ListIndex> animalUpdateFuncsNdx = [listOfAnimalUpdateFuncs listBegin: mgrZone];

   [habitatUpdateFuncsNdx setLoc: Start];
   
   while(([habitatUpdateFuncsNdx getLoc] != End) && ((aFunc = [habitatUpdateFuncsNdx next]) != nil))
   {
        if([aFunc respondsTo: @selector(setLogisticFuncLimiterTo:)])
        {
            [aFunc setLogisticFuncLimiterTo: aLimiter];
        }
   }

   [habitatUpdateFuncsNdx drop];
  
   [animalUpdateFuncsNdx setLoc: Start];
  
   while(([animalUpdateFuncsNdx getLoc] != End) && ((aFunc = [animalUpdateFuncsNdx next]) != nil))
   {
        if([aFunc respondsTo: @selector(setLogisticFuncLimiterTo:)])
        {
            [aFunc setLogisticFuncLimiterTo: aLimiter];
        }
   }
 
   [animalUpdateFuncsNdx drop];



   return self;
}


- addConstantFuncToProbWithSymbol: (id <Symbol>) aProbSymbol
                   withValue: (double) aValue
{


  id <ListIndex> ndx;
  id aProb;

  BOOL ERROR=TRUE;


  ndx = [listOfSurvProbs listBegin: mgrZone];
  while (([ndx getLoc] != End) && ((aProb = [ndx next]) != nil))
  {
     if(aProbSymbol == [aProb getProbSymbol])
     {
           [aProb createConstantFuncWithValue: aValue];

           ERROR = FALSE;
           break;
     }

   }

  if(ERROR) 
  {
     [InternalError raiseEvent: "ERROR: SurvMGR >>>> addConstantFuncToProbWithSymbol >>>> Either aProbSymbol = %s was not found or inputObjectType is invalid\n", [aProbSymbol getName]];
  }

  return self;
}


- addCustomFuncToProbWithSymbol: (id <Symbol>) aProbSymbol
                  withClassName: (char *) className
            withInputObjectType: (id <Symbol>) objType
              withInputSelector: (SEL) anInputSelector
{

  id <ListIndex> ndx;
  id aProb;

  BOOL ERROR=TRUE;

  ndx = [listOfSurvProbs listBegin: mgrZone];
  while (([ndx getLoc] != End) && ((aProb = [ndx next]) != nil))
  {
     if(aProbSymbol == [aProb getProbSymbol])
     {
         id aFunc = nil;

         aFunc = [aProb createCustomFuncWithClassName: className
                                       withInputSelector: anInputSelector
                                     withInputObjectType: objType];

         if(objType == HABITAT)
         {
             [listOfHabitatUpdateFuncs addLast: aFunc];
         }
         else if(objType == ANIMAL)
         {
             [listOfAnimalUpdateFuncs addLast: aFunc];
         }
         else
         {
            break;  //an error occurred 
         }

         ERROR = FALSE;
         break;
     }

   }

  [ndx drop];

  if(ERROR) 
  {
     [InternalError raiseEvent: "ERROR: SurvMGR >>>> addCustomFuncToProbWithSymbol >>>> aProbSymbol = %s was not found or inputObjectType was not found\n", [aProbSymbol getName]];

  }


  return self;


}





- addObjectValueFuncToProbWithSymbol: (id <Symbol>) aProbSymbol
                 withInputObjectType: (id <Symbol>) objType
                   withInputSelector: (SEL) anObjSelector
{

  id <ListIndex> ndx;
  id aProb = nil;
  id aFunc = nil;

  BOOL ERROR=TRUE;

  ndx = [listOfSurvProbs listBegin: mgrZone];
  while (([ndx getLoc] != End) && ((aProb = [ndx next]) != nil))
  {
     if(aProbSymbol == [aProb getProbSymbol])
     {

        aFunc = [aProb createObjectValueFuncWithInputSelector: anObjSelector
                                        withInputObjectType: objType];


         if(objType == HABITAT)
         {
             [listOfHabitatUpdateFuncs addLast:  aFunc];
         }
         else if(objType == ANIMAL)
         {
             [listOfAnimalUpdateFuncs addLast: aFunc];
         }
         else
         {
            break;  //an error occurred 
         }

         ERROR = FALSE;
         break;
     }

  }


  [ndx drop];

  if(ERROR) 
  {
     [InternalError raiseEvent: "ERROR: SurvMGR >>>> addObjectValueuncToProbWithSymbol >>>> Either aProbSymbol = %s was not found or inputObjectType is invalid\n", [aProbSymbol getName]];
  }


  return self;
}
        




//
// USING
//


///////////////////////////////////
//
// updateForHabitat
//
///////////////////////////////////
- updateForHabitat
{
   //fprintf(stdout, "SURVMGR >>>> updateForHabitat BEGIN\n");
   //fflush(0);
   
   if(myHabitatObject == nil)
   {
      [InternalError raiseEvent: "ERROR: SurvMGR >>>> myHabitatObject is nil\n"];
   }


   [listOfHabitatUpdateFuncs forEach: M(updateWith:) :myHabitatObject];

   //fprintf(stdout, "SURVMGR >>>> updateForHabitat EXIT\n");
   //fflush(0);

   return self;

}


///////////////////////////////////
//
// updateForAnimal
//
///////////////////////////////////
- updateForAnimal: anAnimal
{

   //
   // set the SurvMGR's instance var. myCurrentAnimal
   // will change from agent to agent.
   //
   myCurrentAnimal = anAnimal;

   [listOfAnimalUpdateFuncs forEach: M(updateWith:) :myCurrentAnimal];

   if(testOutput == YES)
   {
      [self writeSurvOutputWithAnimal: anAnimal];
   }

   return self;

}


//////////////////////////////////////////////////
//
// getListOfSurvProbsFor
//
//////////////////////////////////////////////////
- (id <List>) getListOfSurvProbsFor: anAnimal
{

  if(myCurrentAnimal != anAnimal)
  {
     [InternalError raiseEvent: "ERROR: SurvMGR >>>> Attempt to use getListOfSurvProbStructsFor for an animal the survival manager has not been updated for\n"];
  }

  return listOfSurvProbs;

}



///////////////////////////////////////////////
//
// getTotalSurvivalProbFor
//
///////////////////////////////////////////////
- (double) getTotalSurvivalProbFor: anAnimal
{

  id aProb = nil;

  double totalSurvivalProb=1.0;


  if(myCurrentAnimal != anAnimal)
  {
     [InternalError raiseEvent: "ERROR: SurvMGR >>>> Attempt to use  getTotalSurvivalProbFor for an animal the survival manager has not been updated for\n"];
  }

  if(survProbLstNdx == nil)
  {
     [InternalError raiseEvent: "ERROR: >>>> getTotalSurvivalProbFor >>>> survProbLstNdx is nil >>>> ensure createEnd was invoked\n"];
  }

  [survProbLstNdx setLoc: Start];

  while (([survProbLstNdx getLoc] != End) && ((aProb = [survProbLstNdx next]) != nil))
  {
      double aSurvProb = [aProb getSurvivalProb];
      if(isnan(aSurvProb) || isinf(aSurvProb))
      {
         fprintf(stderr, "ERROR: Trout >>>> SurvMGR >>>> aSurvProb = %f\n", aSurvProb);
         fprintf(stderr, "ERROR: Trout >>>> SurvMGR >>>> SurvivalProb = %s\n", [aProb getName]);
         fflush(0);
         exit(1);
      }
      totalSurvivalProb *= aSurvProb;
      if(isnan(totalSurvivalProb) || isinf(totalSurvivalProb))
      {
         fprintf(stderr, "ERROR: Trout >>>> SurvMGR >>>> totalSurvivalProb = %f\n", totalSurvivalProb);
         fprintf(stderr, "ERROR: Trout >>>> SurvMGR >>>> SurvivalProb = %s\n", [aProb getName]);
         fflush(0);
         exit(1);
      }
      //totalSurvivalProb *= [aProb getSurvivalProb];
  } 

  return totalSurvivalProb;

}



///////////////////////////////////////////////
//
// getTotalKnownNonStarvSurvivalProb
//
//////////////////////////////////////////////
- (double) getTotalKnownNonStarvSurvivalProbFor: anAnimal
{
  id aProb=nil;

  double totalKnownNonStarvSurvivalProb = 1.0;

  if(myCurrentAnimal != anAnimal)
  {
      [InternalError raiseEvent: "ERROR: SurvMGR >>>> Attempt to use getTotalKnownNonStarvSurvivalProbFor for an animal the survival manager has not been updated for\n"];
  }

  [knownNonStarvSurvProbLstNdx setLoc: Start];

  while (([knownNonStarvSurvProbLstNdx getLoc] != End) && ((aProb = [knownNonStarvSurvProbLstNdx next]) != nil))
  {
      double aSurvProb = [aProb getSurvivalProb];
      if(isnan(aSurvProb) || isinf(aSurvProb))
      {
         fprintf(stderr, "ERROR: Trout >>>> SurvMGR >>>> getTotalKnownNonStarvSurvivalProbFor >>>> aSurvProb = %f\n", aSurvProb);
         fprintf(stderr, "ERROR: Trout >>>> SurvMGR >>>> getTotalKnownNonStarvSurvivalProbFor >>>> SurvivalProb = %s\n", [aProb getName]);
         fflush(0);
         exit(1);
      }
      totalKnownNonStarvSurvivalProb *=  aSurvProb;
      if(isnan(totalKnownNonStarvSurvivalProb) || isinf(totalKnownNonStarvSurvivalProb))
      {
         fprintf(stderr, "ERROR: Trout >>>> SurvMGR >>>> getTotalKnownNonStarvSurvivalProbFor >>>> totalKnownNonStarvSurvivalProb = %f\n", totalKnownNonStarvSurvivalProb);
         fprintf(stderr, "ERROR: Trout >>>> SurvMGR >>>> SurvivalProb = %s\n", [aProb getName]);
         fflush(0);
         exit(1);
      }
         //totalKnownNonStarvSurvivalProb *=  [aProb getSurvivalProb];
  }


  return totalKnownNonStarvSurvivalProb; 

}


- (double) getStarvSurvivalFor: anAnimal
{

   if(myCurrentAnimal != anAnimal)
   {
      [InternalError raiseEvent: "ERROR: SurvMGR >>>> Attempt to use getStarvSurvivalFor for an animal the survival manager has not been updated for\n"];
   }

   return [starvSurvivalProb getSurvivalProb];

}







- (void) drop
{
     [listOfSurvProbs deleteAll];
     [mgrZone drop];
     [super drop];
 
}




///////////////////////////////////////////
//
// createHeaderAndFormatStrings
//
///////////////////////////////////////////
- createHeaderAndFormatStrings
{
   static char* anOutputString = NULL;
 
   int habitatFuncCount = [listOfHabitatUpdateFuncs getCount]; 
   int animalFuncCount = [listOfAnimalUpdateFuncs getCount];
   int survProbCount = [listOfSurvProbs getCount];
   int maxFuncCount;
   static char** aFormatString = NULL;
   int i;
   
   maxFuncCount = habitatFuncCount + animalFuncCount + survProbCount;


   if(!testOutput) return self;
   
   //fprintf(stdout, "SurvMgr >>>> createHeaderAndFormatStrings >>>> BEGIN\n");
   //fflush(0);

   
   if(aFormatString == NULL)
   {
      aFormatString = (char **) [mgrZone alloc: (size_t) 10 * maxFuncCount * sizeof(char)] ;

      for(i=0;i < maxFuncCount ; i++)
      {

         aFormatString[i] = (char *) [mgrZone alloc: (size_t) 10 * sizeof(char)];
      }

   }
  
  
   formatString = aFormatString;
   

   if(anOutputString == NULL)
   {

      id <ListIndex> habitatLstNdx;
      id <ListIndex> animalLstNdx;
      id <ListIndex> probLstNdx;
      id aFunc = nil;
      id aProb = nil;

      habitatLstNdx = [listOfHabitatUpdateFuncs listBegin: scratchZone];
      animalLstNdx = [listOfAnimalUpdateFuncs listBegin: scratchZone];
      probLstNdx = [listOfSurvProbs listBegin: scratchZone];



      anOutputString = [mgrZone alloc: (size_t) maxFuncCount * 50 * sizeof(char)];
    
      //fprintf(stdout, "SurvMGR >>>> createHeaderAndFormatStrings >>>> maxFuncCount = %d\n", maxFuncCount);
      //fflush(0);


      [habitatLstNdx setLoc: Start];
      [animalLstNdx setLoc: Start];
      [probLstNdx setLoc: Start];
    
      sprintf(anOutputString,"%s", "");

      /*
      for(i=0;i < maxFuncCount; i++)
      {
         sprintf(aFormatString[i],"%s", "");
      } 
      */

      i = 0;

      while(([habitatLstNdx getLoc] != End) && ((aFunc = [habitatLstNdx next]) != nil)) 
      {
          char* aMethodName = (char *) [aFunc getProbedMessage];
          size_t methodNameLength;
          size_t minLength = 23;
          char aFormat[10];
          

          //fprintf(stderr, "HABITAT WHILE aFunc = %p\n", aFunc);
          //fflush(0);

          methodNameLength = strlen(aMethodName);
          if(methodNameLength <= minLength)
          {
               char methodName[minLength]; 
               methodNameLength = minLength;
               sprintf(aFormat, "%c%c%d%c",  '%', '-', (int) methodNameLength + 1, 's');
               sprintf(methodName, aFormat, aMethodName);
               strncat(anOutputString, methodName, methodNameLength);
          }
          else 
          {
               char methodName[methodNameLength]; 
               sprintf(aFormat, "%c%c%d%c",  '%', '-', (int) methodNameLength + 1, 's');
               sprintf(methodName, aFormat, aMethodName);
               strncat(anOutputString, methodName, methodNameLength);
          }


          //strncat(anOutputString, aMethodName, methodNameLength);
          strncat(anOutputString, " ", strlen(" "));


          if(i > habitatFuncCount)
          {
             [InternalError raiseEvent: "ERROR: createHeaderAndFormatStrings >>>> index exceeds funcCount\n"];
          } 

          //fprintf(stderr, "HABITAT WHILE i = %d\n", i);
          //fflush(0);

          if(![aFunc isResultId])
          {
              sprintf(aFormatString[i], "%c%c%d%c%d%c",  '%', '-', (int) methodNameLength + 1, '.', 3, 'E');
          }
          else
          {
              sprintf(aFormatString[i], "%c%c%d%c",  '%', '-', (int) methodNameLength + 1, 'p');
          }

          i++;


          //strncat(aFormatString, aFormat, strlen(aFormat));


      }
 
      [habitatLstNdx drop];

      
      i = maxFuncCount - (animalFuncCount + survProbCount);

      while(([animalLstNdx getLoc] != End) && ((aFunc = [animalLstNdx next]) != nil)) 
      {
          char* aMethodName = (char *) [aFunc getProbedMessage];
          size_t methodNameLength;
          size_t minLength = 17;
          char aFormat[10];
          

          //fprintf(stderr, "ANIMAL WHILE aFunc = %p\n", aFunc);
          //fflush(0);

          methodNameLength = strlen(aMethodName);
          if(methodNameLength <= minLength)
          {
               char methodName[minLength]; 
               methodNameLength = minLength;
               sprintf(aFormat, "%c%c%d%c",  '%', '-', (int) methodNameLength + 1, 's');
               sprintf(methodName, aFormat, aMethodName);
               strncat(anOutputString, methodName, methodNameLength);
          }
          else 
          {
               char methodName[methodNameLength]; 
               sprintf(aFormat, "%c%c%d%c",  '%', '-', (int) methodNameLength + 1, 's');
               sprintf(methodName, aFormat, aMethodName);
               strncat(anOutputString, methodName, methodNameLength);
          }


          //strncat(anOutputString, aMethodName, methodNameLength);
          strncat(anOutputString, " ", strlen(" "));

          //fprintf(stderr, "ANIMAL WHILE methodNameLength = %d\n", (int) methodNameLength);
          //fflush(0);

          if((maxFuncCount - i) > (animalFuncCount + survProbCount))
          {
             [InternalError raiseEvent: "ERROR: createHeaderAndFormatStrings >>>> index exceeds funcCount\n"];
          } 

          //fprintf(stderr, "ANIMAL WHILE i = %d\n", i);
          //fflush(0);

          if(![aFunc isResultId])
          {
              sprintf(aFormatString[i], "%c%c%d%c%d%c",  '%', '-', (int) methodNameLength + 1, '.', 3, 'E');
          }
          else
          {
              sprintf(aFormatString[i], "%c%c%d%c",  '%', '-', (int) methodNameLength + 1, 'p');
          }
 
          i++;

      }

      [animalLstNdx drop];

      
      i = maxFuncCount - survProbCount;

      while(([probLstNdx getLoc] != End) && ((aProb = [probLstNdx next]) != nil)) 
      {
          char* aProbName = (char *) [aProb getName];
          size_t probNameLength;
          size_t minLength = 17;
          char aFormat[10];
          

          //fprintf(stderr, "PROB WHILE aProb = %p\n", aProb);
          //fflush(0);

          probNameLength = strlen(aProbName);
          if(probNameLength <= minLength)
          {
               char probName[minLength]; 

               probNameLength = minLength;
               sprintf(aFormat, "%c%c%d%c",  '%', '-', (int) probNameLength + 1, 's');
               sprintf(probName, aFormat, aProbName);
               strncat(anOutputString, probName, probNameLength);
          }
          else 
          {
               char probName[probNameLength]; 

               sprintf(aFormat, "%c%c%d%c",  '%', '-', (int) probNameLength + 1, 's');
               sprintf(probName, aFormat, aProbName);
               strncat(anOutputString, probName, probNameLength);
          }


          //strncat(anOutputString, aProbName, probNameLength);
          strncat(anOutputString, " ", strlen(" "));

          //fprintf(stderr, "PROB WHILE probNameLength = %d\n", (int) probNameLength);
          //fflush(0);

          if((maxFuncCount - i) > survProbCount)
          {
             [InternalError raiseEvent: "ERROR: createHeaderAndFormatStrings >>>> index exceeds survProbCount\n"];
          } 

          //fprintf(stderr, "SURV PROB WHILE i = %d\n", i);
          //fflush(0);

          sprintf(aFormatString[i], "%c%c%d%c",  '%', '-', (int) probNameLength + 1, 'f');
 
          i++;

      }

      [probLstNdx drop];

      

      strncat(anOutputString, "\n", strlen("\n"));

      if(testOutputFilePtr != NULL)
      {
         fprintf(testOutputFilePtr, "%-s", anOutputString);
         fflush(testOutputFilePtr);

         for(i=0;i < maxFuncCount; i++)
         {
           //fprintf(testOutputFilePtr, "%s", formatString[i]);
           //fflush(testOutputFilePtr);
         }

         //fprintf(testOutputFilePtr, "\n");
         //fflush(testOutputFilePtr);

      }
   }

   //fprintf(stdout, "SurvMgr >>>> createHeaderAndFormatStrings >>>> END\n");
   //fflush(0);

   return self;

}


- writeSurvOutputWithAnimal: anAnimal
{

   if(testOutput == YES)
   {
       int habitatFuncCount = [listOfHabitatUpdateFuncs getCount];
       int animalFuncCount = [listOfAnimalUpdateFuncs getCount];
       int survProbCount = [listOfSurvProbs getCount];

       int maxFuncCount = habitatFuncCount + animalFuncCount + survProbCount;
    
       int i = 0;


       if(myCurrentAnimal != anAnimal)
       {
          [InternalError raiseEvent: "ERROR: SurvMGR >>>> Attempt to use writeSurvOutputWithAnimal for an animal the survival manager has not been updated for\n"];
       }

       if(myHabitatObject != nil)
       {

          id <ListIndex> lstNdx;
          id aFunc = nil;
          val_t val;

          lstNdx = [listOfHabitatUpdateFuncs listBegin: scratchZone];

          [lstNdx setLoc: Start];

           i = 0;
           while(([lstNdx getLoc] != End) && ((aFunc = [lstNdx next]) != nil)) 
           {
                if(i > habitatFuncCount)
                {
                    fprintf(stderr, "ERROR: SurvMGR writeSurvOutputWithHabitatObj:withAnimalObj: funcIndex count incorrect\n");
                    fflush(0);
                    exit(1);
                }

                val = [aFunc getProbedMessageValWithAnObj: myHabitatObject];

                //fprintf(stderr, "SURVMGR TYPE %c\n", val.type);
                //fflush(0);

                if((val.type == _C_ID) || (val.type == _C_SEL))
                {
                   //fprintf(stderr, "SURVMGR TYPE %p\n", [aFunc getProbedMessageIDRetValWithAnObj: myHabitatObject]);
                   fprintf(testOutputFilePtr, formatString[i], [aFunc getProbedMessageIDRetValWithAnObj: myHabitatObject]);
                   fflush(testOutputFilePtr);
                }
                else
                {   
                   //fprintf(stderr, "SURVMGR TYPE %f\n", [aFunc getProbedMessageRetValWithAnObj: myHabitatObject]);
                   fprintf(testOutputFilePtr, formatString[i], [aFunc getProbedMessageRetValWithAnObj: myHabitatObject]);
                   fflush(testOutputFilePtr);
                }
    
               //fprintf(testOutputFilePtr, formatString[i], [aFunc getFuncValue]);
               //fflush(testOutputFilePtr);
    
                i++;
           }

         [lstNdx drop];

       }

   

       if(anAnimal != nil)
       {

          id <ListIndex> lstNdx;
          id aFunc = nil;
          val_t val;
    
          lstNdx = [listOfAnimalUpdateFuncs listBegin: scratchZone];
    
          [lstNdx setLoc: Start];
    
          while(([lstNdx getLoc] != End) && ((aFunc = [lstNdx next]) != nil)) 
          {
               if(i > maxFuncCount)
               {
                   fprintf(stderr,  "ERROR: SurvMGR writeSurvOutputWithHabitatObj:withAnimalObj: funcIndex count incorrect\n");
                   fflush(0);
                   exit(1);
    
               }
    
               val = [aFunc getProbedMessageValWithAnObj: anAnimal];
    
               //fprintf(stderr, "SURVMGR TYPE %c\n", val.type);
    
               if((val.type == _C_ID) || (val.type == _C_SEL))
               {
                   //fprintf(stderr, "SURVMGR TYPE %p\n", [aFunc getProbedMessageIDRetValWithAnObj: anAnimal]);
                   fprintf(testOutputFilePtr, formatString[i], [aFunc getProbedMessageIDRetValWithAnObj: anAnimal]);
                   fflush(testOutputFilePtr);
               }
               else
               {
                   //fprintf(stderr, "SURVMGR TYPE %f\n", [aFunc getProbedMessageRetValWithAnObj: anAnimal]);
                   fprintf(testOutputFilePtr, formatString[i], [aFunc getProbedMessageRetValWithAnObj: anAnimal]);
                   fflush(testOutputFilePtr);
               }   
    
    
               //fprintf(testOutputFilePtr, formatString[i], [aFunc getFuncValue]);
               //fflush(testOutputFilePtr);
       
               i++;
          }

         [lstNdx drop];
    
       }
       if(anAnimal != nil)
       {

          id <ListIndex> lstNdx;
          id aProb = nil;

          lstNdx = [listOfSurvProbs listBegin: scratchZone];

          [lstNdx setLoc: Start];

          while(([lstNdx getLoc] != End) && ((aProb = [lstNdx next]) != nil)) 
          {
               if(i > maxFuncCount)
               {
                   fprintf(stderr,"ERROR: SurvMGR writeSurvOutputWithHabitatObj:withAnimalObj: funcIndex count incorrect\n");

               }

               fprintf(testOutputFilePtr, formatString[i], [aProb getSurvivalProb]);
               fflush(testOutputFilePtr);
       
               i++;
          }

         [lstNdx drop];

       }

       fprintf(testOutputFilePtr, "\n");
       fflush(testOutputFilePtr);

   }



   return self;

}


@end


