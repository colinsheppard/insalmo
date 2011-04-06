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
#import "ScenarioIterator.h"

struct experVar {

         void * experVariableValue;
         int scenarioCount;
         int replicateCount;

}; 


struct updateVar {

           Class updateClass;
           id <VarProbe> varProbe;
};


@implementation ScenarioIterator 

+ createBegin: aZone 
{
  ScenarioIterator * newSelf;
  id <Map> tempMap;
  id <List> tempList;
  char * tempString;


  newSelf = [super createBegin: aZone];

  newSelf->scenarioIterZone = [Zone create: aZone];


  tempMap = [Map create: aZone];
  newSelf->iterMap = tempMap;


  tempList = [List create: aZone];
  newSelf->updateScenarioClassList = tempList;
  
  tempList = [List create: aZone];
  newSelf->updateReplicateClassList = tempList;
  

  tempString = (char *) [aZone alloc: 101*sizeof(char)];
  newSelf->oldParameter = tempString;

  newSelf->scenarioCount = 1;
  newSelf->replicateCount = 1;
  newSelf->classCount = 0;
  newSelf->numScenarios = 1;
  newSelf->numReplicates = 1;

  newSelf->aProbe=nil;

  newSelf->classList = [List create: aZone];
  //newSelf->instanceNameList = [List create: aZone];
  newSelf->paramClassInstanceNameMap = [Map create: aZone];

  return newSelf;

}



//////////////////////////////////////////////
//
// setNumScenarios
//
//////////////////////////////////////////////
- setNumScenarios: (int) aNumScenarios
{
  numScenarios = aNumScenarios;

  return self;

}



/////////////////////////////////////////////
//
// setNumReplicates
//
/////////////////////////////////////////////
- setNumReplicates: (int) aNumReplicates {

  numReplicates = aNumReplicates;

  return self; 
 
}




/////////////////////////////////////////////////
//
// appendToIterSetParam
//
/////////////////////////////////////////////////
-  appendToIterSetParam: (const char *) newParam
          withParamType: (char) aParamType
                ofClass: (Class) paramClass
       withInstanceName: (id <Symbol>) anInstanceName
             paramValue: (void *) paramValue
{

 static int scenarioCounter = 1;
 struct experVar *myVar;
 id <Map> aNewProbeMap = nil;
 id <Map> instanceNameMap = nil;
 const char * needANewParam = "need a new param";
 char probeType;
 BOOL TYPEERROR = YES;
 
  myVar = (struct experVar *) [scenarioIterZone  alloc: sizeof(struct experVar)];

  if(![classList contains: paramClass]) 
  {
    instanceNameMap = [Map create: scenarioIterZone];
    aNewProbeMap = [Map create: scenarioIterZone];
    instanceNameList = [List create: scenarioIterZone];

    [instanceNameMap at: anInstanceName insert: aNewProbeMap];

    [iterMap at: paramClass insert: instanceNameMap];

    parameterClass = paramClass;

    classCount++;

    strncpy(oldParameter, needANewParam, 1 + strlen(needANewParam));

    [classList addLast: paramClass];
    [instanceNameList addLast: anInstanceName];
    [paramClassInstanceNameMap at: paramClass insert: instanceNameList]; 


  }
  else if([classList contains: paramClass] && ![[paramClassInstanceNameMap at: paramClass] contains: anInstanceName])
  {
     aNewProbeMap = [Map create: scenarioIterZone];
    [[iterMap at: paramClass] at: anInstanceName insert: aNewProbeMap];
    [[paramClassInstanceNameMap at: paramClass] addLast: anInstanceName];
  }

  /*
  aProbe = [probeLibrary getProbeForVariable: newParam inClass: paramClass];

  if(aProbe == nil)
  {
       fprintf(stderr, "ERROR: ScenarioIterator >>>> appendToIterSetParam >>>> nil Probe\n");
       fprintf(stderr, "       Check the experiment setup file for parameter: %s\n", newParam);
       fflush(0);
       exit(1);
  }
  */

  if([probeLibrary getProbeForVariable: newParam inClass: paramClass] != nil)
  {
      aProbe = [probeLibrary getProbeForVariable: newParam inClass: paramClass];
  }
  else
  {
       fprintf(stderr, "ERROR: ScenarioIterator >>>> appendToIterSetParam >>>> nil Probe\n");
       fprintf(stderr, "       Check the experiment setup file for parameter: %s\n", newParam);
       fflush(0);
       exit(1);
  }
  if(strcmp(oldParameter, newParam) != 0) 
  {
    id <Array> tempArray;

    tempArray = [Array createBegin: scenarioIterZone];
    [tempArray setDefaultMember: nil];
    [tempArray setCount: 0];
    tempArray = [tempArray createEnd];

    [[[iterMap at: paramClass] at: anInstanceName] at: aProbe insert: tempArray];

    strncpy( oldParameter, newParam, 1 + strlen(newParam) );
  }

  if([[[iterMap at: paramClass] at: anInstanceName] at: aProbe] == nil)
  {
    id <Array> tempArray;

    tempArray = [Array createBegin: scenarioIterZone];
    [tempArray setDefaultMember: nil];
    [tempArray setCount: 0];
    tempArray = [tempArray createEnd];

    [[[iterMap at: paramClass] at: anInstanceName] at: aProbe insert: tempArray];
  }

  probeType = [aProbe getProbedType][0];

  if((probeType == _C_CHARPTR) && (aParamType == _C_CHARPTR))
  {
        TYPEERROR = NO;
  } 
  else if((probeType == _C_INT) && (aParamType == _C_INT))
  {
        TYPEERROR = NO;
  } 
  else if((probeType == _C_UCHR) && (aParamType == _C_UCHR))
  {
        TYPEERROR = NO;
  } 
  else if((probeType == _C_FLT) && (aParamType == _C_FLT))
  {
        TYPEERROR = NO;
  } 
  else if((probeType == _C_DBL) && (aParamType == _C_DBL))
  {
        TYPEERROR = NO;
  } 
  
   
  if(TYPEERROR == YES)
  {
     fprintf(stderr, "ERROR: ScenarioIterator >>>> appendToIterSet: >>>> data type mismatch\n");
     fprintf(stderr, "       Check the experiment set up file for parameter: %s\n", newParam);
     fflush(0);
     exit(1);
  }


    switch (([aProbe getProbedType])[0]) {

        case _C_CHARPTR:   {

                 char *aNewString;
                     
                  aNewString = (char *)[[self getZone] alloc: (size_t) 1 + strlen(paramValue)*sizeof(char)];
                  strcpy(aNewString, paramValue);

                  myVar->experVariableValue = (void *) aNewString;


                          }
          break;

         case _C_INT:     {
                 int *aNewInt;
                 aNewInt = (int *) [[self getZone] alloc: sizeof(int)];
                 *aNewInt = *((int *) paramValue);

                 myVar->experVariableValue = (void *) aNewInt;

                         }
          break;

         case _C_UCHR:     {

                 unsigned char *aNewUChar;
                 aNewUChar = (unsigned char *) [[self getZone] alloc: sizeof(unsigned char)];
                 *aNewUChar = *((unsigned char *) paramValue);

                 myVar->experVariableValue = (void *) aNewUChar;

                         }
          break;

         case _C_FLT:    {
                 
                 float *aNewFlt;
                 aNewFlt = (float *) [[self getZone] alloc: sizeof(float)];
                 *aNewFlt = *((float *) paramValue);

                 myVar->experVariableValue = (void *) aNewFlt;

                         }

          break;

         case _C_DBL:   {
                 
                 double *aNewDbl;
                 aNewDbl = (double *) [[self getZone] alloc: sizeof(double)];
                 *aNewDbl = *((double *) paramValue);

                 myVar->experVariableValue = (void *) aNewDbl;

                 }
          break;

         default:
             fprintf(stderr, "ERROR: ScenarioIterator: Didn't recognize probedType\n");
             fflush(0);
             exit(1);
          break;


     } //switch

     myVar->scenarioCount = scenarioCounter;
     myVar->replicateCount = numReplicates; 

     [[[[iterMap at: paramClass] at: anInstanceName] at: aProbe] setCount: scenarioCounter + 1];
     [[[[iterMap at: paramClass] at: anInstanceName] at: aProbe] atOffset: scenarioCounter put: (void *) myVar];

    scenarioCounter++;

  if(scenarioCounter > numScenarios) scenarioCounter = 1;

  return self;

}



- checkParameters {

  return self;

}


- createEnd 
{
  [super createEnd];

  if((numScenarios == 0) || (numReplicates == 0)) 
  {  
     fprintf(stderr, "ERROR: numScenarios or numReplicates is 0\n");
     fflush(0);
     exit(1);
  }

  scenarioNdx = [updateScenarioClassList listBegin: scenarioIterZone];
  replicateNdx = [updateReplicateClassList listBegin: scenarioIterZone];

  return self;
}


- nextFileSetOnObject: (id) theObject 
{
  return self;
}




//////////////////////////////////////////
//
// getIteration
//
/////////////////////////////////////////
- (int) getIteration 
{
    return scenarioCount;
}




////////////////////////////////////////////////////
//
// canWeGoAgain
//
////////////////////////////////////////////////////
- (BOOL) canWeGoAgain
{
   replicateCount++;

   if(replicateCount > numReplicates) 
   {
      scenarioCount++;
      replicateCount = 1;
   }

   if(scenarioCount > numScenarios)
   {
      fprintf(stdout, "ScenarioIterator >>>> canWeGoAgain >>>> We're done >>>> EXITING\n");
      fflush(0);

     return NO;
   }

   return YES;
}
 



//////////////////////////////////////////////////////////
//
// nextControlSetOnObject
//
///////////////////////////////////////////////////////////
- nextControlSetOnObject: (id) theObject 
        withInstanceName: (id <Symbol>) anInstanceName
{

   id <VarProbe> ctrlSetProbe=nil;
   id ctrlSetObject;

   id <Map> myProbeMap = nil;

   id <MapIndex> probeMapNdx;

   char * newFile;

   unsigned char newUCharVal;
   int newIntVal;
   float newFloatVal;
   double newDoubleVal;

   struct experVar *myVar;

   fprintf(stdout, "ScenarioIterator >>>> nextControlSetOnObject >>>> BEGIN\n");
   fflush(0);
   xprint(theObject);
   xprint(anInstanceName);

   [self updateClassScenarioCounts: theObject];
   [self updateClassReplicateCounts: theObject];

   fprintf(stdout, "ScenarioIterator >>>> nextControlSetOnObject >>>> after update*Counts\n");
   fflush(0);

   if([iterMap at: getClass(theObject)] != nil)
   {
       if([[iterMap at: getClass(theObject)] at: anInstanceName] != nil);
       {
           myProbeMap = [[iterMap at: getClass(theObject)] at: anInstanceName];
      
           fprintf(stderr, "SCENARIO ITERATOR >>>> iterMap = %p\n", iterMap);
           fprintf(stderr, "SCENARIO ITERATOR >>>> iterMap getCount = %d\n", [iterMap getCount]);
           fprintf(stderr, "SCENARIO ITERATOR >>>> theObject = %p\n", theObject);
           xprint(theObject);
           fprintf(stderr, "SCENARIO ITERATOR >>>> myProbeMap = %p\n", myProbeMap);
           fprintf(stderr, "SCENARIO ITERATOR >>>> anInstanceName = %p\n", anInstanceName);
           xprint(anInstanceName);
           fflush(0);
       }
   }
      
   if(myProbeMap != nil) 
   {
       probeMapNdx = [myProbeMap mapBegin: [self getZone]];

        while( ([probeMapNdx getLoc] != End) && ([probeMapNdx next], (ctrlSetProbe = [probeMapNdx getKey]) != nil) )
        {

             myVar = (struct experVar *) [[myProbeMap at: ctrlSetProbe] atOffset: scenarioCount];

        if(scenarioCount != myVar->scenarioCount) continue;

        ctrlSetObject = theObject;

        switch (([ctrlSetProbe getProbedType])[0]) 
        {

            case _C_CHARPTR:

                  newFile = strdup((char *) myVar->experVariableValue);
                  [ctrlSetProbe setData: ctrlSetObject ToString: newFile];

                  break;

             case _C_UCHR:     

                  newUCharVal = *((unsigned char *) myVar->experVariableValue);
                  [ctrlSetProbe setData: ctrlSetObject To: &newUCharVal];

                  break;

             case _C_INT:

              newIntVal = *((int *) myVar->experVariableValue);
              [ctrlSetProbe setData: ctrlSetObject To: &newIntVal];

              break;

            case _C_FLT:
              newFloatVal = *((float *) myVar->experVariableValue);
              [ctrlSetProbe setData: ctrlSetObject To: &newFloatVal];
              break;

            case _C_DBL:
              newDoubleVal = *((double *) myVar->experVariableValue);
              [ctrlSetProbe setData: ctrlSetObject To: &newDoubleVal];

              break;

            default:
              fprintf(stderr, "ERROR: ScenarioIterate: Didn't recognize probedType\n");
              fflush(0);
              exit(1);
              break;
               
         } //switch

      } //while  


       [probeMapNdx drop];


  } //if probeMap 
  else
  {
      [WarningMessage raiseEvent: "WARNING: SCENARIO ITERATOR >>>> nextControlSetOnObject\n"
                                  "         theObject = %s does not belong to iterMap\n", [theObject getName]];

  }

  fprintf(stdout, "ScenarioIterator >>>> nextControlSetOnObject >>>> END\n");
  fflush(0);

  return self;

}

/////////////////////////////////////////////////////////////////////
//
// sendScenarioCountToParam
//
/////////////////////////////////////////////////////////////////////
- sendScenarioCountToParam: (const char *) newParam
                   inClass: (Class) paramClass {
   struct updateVar *aScenarioCounter;

   fprintf(stdout, "ScenarioIterator >>>> sendScenarioCountToParam >>>> BEGIN\n");
   fflush(0);

   aScenarioCounter = (struct updateVar *) [scenarioIterZone alloc: sizeof(struct updateVar)];

   aScenarioCounter->updateClass = paramClass;
   aScenarioCounter->varProbe = [probeLibrary getProbeForVariable: newParam inClass: paramClass];
 

   [updateScenarioClassList addLast: (void *) aScenarioCounter];

   xprint(aScenarioCounter->varProbe); 
   
   fprintf(stdout, "ScenarioIterator >>>> sendScenarioCountToParam >>>> END\n");
   fflush(0);

   return self;
}

/////////////////////////////////////////////////////////////////////
//
// sendReplicateCountToParam
//
/////////////////////////////////////////////////////////////////////
- sendReplicateCountToParam: (const char *) newParam
                    inClass: (Class) paramClass {
 
   struct updateVar *aReplicateCounter;

   fprintf(stdout, "ScenarioIterator >>>> sendReplicateCountToParam >>>> BEGIN\n");
   fflush(0);

   aReplicateCounter = (struct updateVar *) [scenarioIterZone alloc: sizeof(struct updateVar)];

   aReplicateCounter->updateClass = paramClass;
   aReplicateCounter->varProbe = [probeLibrary getProbeForVariable: newParam inClass: paramClass];

   [updateReplicateClassList addLast: (void *) aReplicateCounter];

   xprint(aReplicateCounter->varProbe);

   fprintf(stdout, "ScenarioIterator >>>> sendReplicateCountToParam >>>> END\n");
   fflush(0);

   return self;
}

////////////////////////////////////////////
//
// updateClassScenarioCounts
// 
////////////////////////////////////////////
- updateClassScenarioCounts: (id) inObject 
{
  struct updateVar *anSCounter;

  fprintf(stdout, "ScenarioIterator >>>> updateClassScenarioCounts >>>> BEGIN\n");
  fflush(0);

  xprint(updateScenarioClassList);
  xprint(scenarioNdx);

  [scenarioNdx setLoc: Start];

  while(([scenarioNdx getLoc] != End) && ((anSCounter = (struct updateVar *) [scenarioNdx next]) != (struct updateVar *) nil))
  {
         fprintf(stdout, "ScenarioIterator >>>> updateClassScenarioCounts >>>> while >>>> varProbe = %p\n", anSCounter->varProbe);
         fflush(0);
         fprintf(stdout, "ScenarioIterator >>>> updateClassScenarioCounts >>>> while >>>> varProbe getProbedVar = %s\n", [anSCounter->varProbe getProbedVariable]);
         fflush(0);
         xprint(anSCounter->varProbe);

          if(getClass(inObject) != anSCounter->updateClass) 
          {
             continue;            
          }


          [anSCounter->varProbe setData: inObject To: &scenarioCount];
  }

  fprintf(stdout, "ScenarioIterator >>>> updateClassScenarioCounts >>>> END\n");
  fflush(0);

  return self;
}


///////////////////////////////////////////////
//
// updateClassreplicateCounts
//
///////////////////////////////////////////////
- updateClassReplicateCounts: (id) inObject 
{
  struct updateVar *anRCounter;

  fprintf(stdout, "ScenarioIterator >>>> updateClassReplicateCounts >>>> BEGIN\n");
  fflush(0);


  [replicateNdx setLoc: Start];

  while(([replicateNdx getLoc] != End) && ( (anRCounter = (struct updateVar *) [replicateNdx next]) != (struct updateVar *) nil))
  {
          if(getClass(inObject) != anRCounter->updateClass) continue;            

          [anRCounter->varProbe setData: inObject To: &replicateCount];
  }

  fprintf(stdout, "ScenarioIterator >>>> updateClassReplicateCounts >>>> END\n");
  fflush(0);

  return self;
}

- calcStep {

    return self;

}

@end

