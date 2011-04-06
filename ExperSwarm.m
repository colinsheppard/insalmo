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


#import <simtoolsgui.h>
#import "ScenarioIterator.h"
#import "ExperSwarm.h"
#import "globals.h"

@protocol Model

- (id <Zone>) getModelZone;

@end

@protocol Object

- (id <Zone>) getObjectZone;

@end

@implementation ParameterManager


- initializeParameters {

  FILE * filePtr;
  const char* file = "Experiment.Setup";
  char* header;
  
  int numberOfScenarios=0;
  int numberOfReplicates=0;

  char* record;
  char* varValue;

  char* className=(char *) NULL;
  id <Symbol> instanceName=nil;
  char* paramName=(char *) NULL;
  char* valueType=(char *) NULL;
  char* value=(char *) NULL;

  char* inputString = (char *) NULL;

  char paramType = '\0';

  TestInput* testInput = nil;

  //
  // These local variables are used for 
  // error checking.
  //
  int varValueCount = 0;
  int instanceNameCount = 0;
  int classNameCount = 0;
  int paramNameCount = 0;
  int valueTypeCount = 0;
  BOOL firstClassName = YES;
  BOOL ERROR = NO;
  BOOL NOVARS = YES;


  // create a subzone to hold all the parameter objects
  parameterZone = [Zone create: [self getZone]];

  managedClasses = [List create: parameterZone];
  instanceNames = [List create: parameterZone];

  testInput = [TestInput create: parameterZone];

  if( (filePtr = fopen(file, "r")) == NULL ) 
  {
     fprintf(stderr, "ERROR: ParameterManager >>>> ExperSwarm.m >>>> initializeParameters >>>> Cannot open %s for reading\n", file);
     fflush(0);
     exit(1);
  }

  header = [parameterZone alloc: HCOMMENTLENGTH*sizeof(char)];
  record = [parameterZone alloc: 85*sizeof(char)];
  varValue = [parameterZone alloc: 85*sizeof(char)];
  className = [parameterZone alloc: 85*sizeof(char)];
  paramName = [parameterZone alloc: 85*sizeof(char)];
  valueType = [parameterZone alloc: 85*sizeof(char)];
  value = [parameterZone alloc: 85*sizeof(char)];

  inputString = [parameterZone alloc: 300*sizeof(char)];

  NONE = [Symbol create: parameterZone setName: "NONE"];

  modelIterator = [ScenarioIterator createBegin: parameterZone];

  fgets(header,HCOMMENTLENGTH,filePtr); 
  fgets(header,HCOMMENTLENGTH,filePtr); 
  fgets(header,HCOMMENTLENGTH,filePtr); 


  strcpy(className, "FOO" );
  strcpy(paramName, "FOO" );
  strcpy(valueType, "FOO" );
  strcpy(value, "FOO" );


  while(EOF != fscanf(filePtr,"%s %s", record, varValue)) 
  {

       if(record[0] == '#' ) continue;

       if(strcmp(record, "numberOfScenarios") == 0 ) 
       {
           numberOfScenarios = atoi(varValue);
           [modelIterator setNumScenarios: numberOfScenarios]; 
           continue;
       }
       else if(strcmp(record, "numberOfReplicates") == 0 ) 
       {
           numberOfReplicates = atoi(varValue);
           [modelIterator setNumReplicates: numberOfReplicates];
           continue;
       }
       if((numberOfScenarios == 0) || (numberOfReplicates == 0))
       {
          fprintf(stderr, "ERROR: ParameterManager >>>> initializeParameters >>>> numberOfScenarios or numberOfReplicates equals 0\n");
          fflush(0);
          exit(1);
       }

 
       if(strcmp(record, "sendScenarioCountToParam:") == 0) 
       {
          char * aScenarioCounter;

          aScenarioCounter = (char *) [parameterZone alloc: (1 + strlen(varValue))*sizeof(char)];

          strncpy(aScenarioCounter, varValue, 1 + strlen(varValue) );

          //fprintf(stdout,"aScenarioCounter = %s \n", aScenarioCounter);
          //fflush(0);
         
          fscanf(filePtr,"%s %s", record, varValue);

          if(strcmp(record, "inClass:") != 0) 
          {
             fprintf(stderr,"ERROR: ParameterManager >>>> initializeParameters >>>> Check sendScenarioCountToParam in %s\n", file);
             fflush(0);
             exit(1);
           } 

          [modelIterator sendScenarioCountToParam: (const char *) aScenarioCounter
                                          inClass: objc_get_class(varValue)];
          strncpy(record, "FOO", strlen("FOO"));
          strncpy(varValue, "FOO", strlen("FOO"));
          continue;

       }
     
  
       if(strcmp(record, "sendReplicateCountToParam:") == 0) 
       {
          char * aReplicateCounter;

          aReplicateCounter = (char *) [parameterZone alloc: (1 + strlen(varValue))*sizeof(char)];

          strncpy(aReplicateCounter , varValue, 1 + strlen(varValue) );

          //fprintf(stdout,"aReplicateCounter = %s \n", aReplicateCounter);
          //fflush(0);
         
          fscanf(filePtr,"%s %s", record, varValue);


          if(strcmp(record, "inClass:") != 0) 
          {
              fprintf(stderr,"ERROR: ParameterManager >>>> initializeParameters >>>> Check sendReplicateCountToParam in %s\n", file);
              fflush(0);
              exit(1);
          } 

          [modelIterator sendReplicateCountToParam: (const char *) aReplicateCounter
                                           inClass: objc_get_class(varValue)];
          

           strncpy(record, "FOO", strlen("FOO"));
           strncpy(varValue, "FOO", strlen("FOO"));
           continue;

       }

       if(!ERROR)
       {
           NOVARS = NO;
           if(strcmp(record,"ClassName") == 0) 
           {
              strcpy(className,varValue);
    
              if((varValueCount != numberOfScenarios) && !firstClassName)
              {
                 ERROR = YES;
              }
              if(classNameCount > 0)
              {
                 ERROR = YES;
              }

       
              firstClassName = NO;
              ++classNameCount;
              instanceNameCount = 0;
              continue;
          
           }
           if((strcmp(record,"InstanceName") == 0) && (classNameCount == 1)) 
           {
              fprintf(stdout, "ParameterManager >>>> instanceName = %s >>>> BEGIN\n", varValue);
              fflush(0);
              if(strncmp(varValue, "NONE", strlen("NONE")) != 0)
              {
                  id <Symbol> anInstanceName = nil;
                  BOOL instanceNameFound = NO;
                  if([instanceNames getCount] == 0)
                  {
                     anInstanceName = [Symbol create: parameterZone setName: varValue];
                     [instanceNames addLast: anInstanceName];
                     instanceName = anInstanceName;
                  }
                  else
                  { 
                       id <ListIndex> ndx = [instanceNames listBegin: scratchZone];
                       char* aName = (char *) NULL;
                       while(([ndx getLoc] != End) && ((anInstanceName = [ndx next]) != nil))
                       {
                           aName = (char *)[anInstanceName getName];
                           if(strncmp(aName, varValue, strlen(varValue)) == 0)
                           { 
                              instanceName = anInstanceName;
                              instanceNameFound = YES;
                              break;
                           }
                       }
                       [ndx drop];
                       
                       if(!instanceNameFound)
                       {
                         anInstanceName = [Symbol create: parameterZone setName: varValue];
                         [instanceNames addLast: anInstanceName];
                         instanceName = anInstanceName;
                       }           

                  }
              }
              else
              { 
                 instanceName = NONE;
              }

              if(instanceNameCount > 0)
              {
                 ERROR = YES;
              }

              ++instanceNameCount;
              paramNameCount = 0;

              continue;
           }
           if((strcmp(record,"ParamName") == 0) && (classNameCount == 1)) 
           {
              strcpy(paramName,varValue);
              varValueCount = 0;
              if(paramNameCount > 0)
              {
                 ERROR = YES;
              }

              ++paramNameCount;
              valueTypeCount = 0;
              continue;
           }
           if((strcmp(record,"ValueType") == 0) && (paramNameCount == 1)) 
           {
              strcpy(valueType,varValue);
              if(valueTypeCount > 0)
              {
                  ERROR = YES;
              }

              ++valueTypeCount;
              continue;
           }
           if((strcmp(record,"Value") == 0) && (varValueCount <= numberOfScenarios) && (valueTypeCount == 1)) 
           {
              strcpy(value,varValue);
              strcpy(varValue, "");
                
              ++varValueCount;
              classNameCount = 0;
           }
           else 
           {
               ERROR = YES;
           }

       } //if !ERROR


       if((varValueCount <= numberOfScenarios) && !ERROR)
       {

           if(    (strcmp(className,"FOO") != 0)
              &&  (strcmp(paramName,"FOO") != 0)
              &&  (strcmp(valueType,"FOO") != 0) 
              &&  (strcmp(value,"FOO") != 0)) 
              {
                   void * aValue=(void *) NULL;

                   [testInput  testInputWithDataType: valueType
                                        andWithValue: value
                                    andWithParamName: paramName];

                   //
                   // Memory allocation takes place in the scenario iterator.
                   //
                   if(strcmp(valueType, "filename") == 0) 
                   {
                       aValue = (void *) value;   
                       paramType = _C_CHARPTR;
                   }
                   else if(strcmp(valueType, "day") == 0) 
                   {
                       aValue = (void *) value;   
                       paramType = _C_CHARPTR;
                   }
                   else if(strcmp(valueType, "date") == 0) 
                   {
                       aValue = (void *) value;   
                       paramType = _C_CHARPTR;
                   }
                   else if(strcmp(valueType, "int") == 0) 
                   {
                       int i;
                       i = atoi(value);
                       aValue = (void *) &i;   
                       paramType = _C_INT;
                   }
                   else if(strcmp(valueType, "BOOL") == 0) 
                   {
                       int i;
                       if(strcmp(value, "NO") == 0) i = (BOOL) 0;
                       if(strcmp(value, "YES")  == 0) i = (BOOL) 1;
                       aValue = (void *) &i;   
                       paramType = _C_UCHR;
                    }
                    else if(strcmp(valueType, "float") == 0) 
                    {
                       float f;
                       f = atof(value);
                       aValue = (void *) &f;   
                       paramType = _C_FLT;
                    }
                    else if(strcmp(valueType, "double") == 0) 
                    {
                       double d;
                       d = atof(value);
                       aValue = (void *) &d;   
                       paramType = _C_DBL;
                    }
                    else 
                    {
                        fprintf(stderr, "ERROR: ParameterManager >>>> initializeParameters >>>> incorrect data type\n");
                        fprintf(stderr, "       check experiment set up file for parameter: %s\n", paramName);
                        fflush(0);
                        exit(1);
                    }
    

                    if(objc_lookup_class(className) == Nil)
                    {
                        fprintf(stderr, "ERROR: ParameterManager >>>> initializeParameters >>>> cannot find class %s\n", className);
                        fprintf(stderr, "       Check the experiment setup file\n");
                        fflush(0);
                        exit(1);
                    }
              
                    [modelIterator appendToIterSetParam: (const char *) paramName
                                          withParamType: paramType
		                                ofClass: objc_get_class(className)
                                       withInstanceName: instanceName
                                             paramValue: (void *) aValue];

                    strcpy(value,"FOO");

                    if([managedClasses contains: objc_get_class(className)] == NO) 
                    {
                        [managedClasses addLast: objc_get_class(className)];
                    } 
              }
       } //if varValueCount
       else
       {
           ERROR = YES;
       }

 } //while


 if(NOVARS == NO)
 {
     //
     // For the last block of data in the experiment input file
     // 
     if(varValueCount != numberOfScenarios)
     {
        ERROR = YES;
     }

     if(ERROR == YES)
     {
        fprintf(stderr, "ERROR: ParameterManager >>>> initializeParameters >>>> data input error check %s\n", file);
        fflush(0);
        exit(1);
     }
 }
     modelIterator = [modelIterator createEnd];
    
     fprintf(stderr, "ParameterManager >>>> initializeParameters >>>> END\n");
     fflush(0);

  return self;
}



////////////////////////////////////////////////////////////
//
// initializeModelFor
//
///////////////////////////////////////////////////////////
- initializeModelFor: (id) subSwarm
      andSwarmObject: (id) aSwarmObject
    withInstanceName: (id <Symbol>) anInstanceName
{


  // so the subSwarm knows which run it is for file output
  [subSwarm setModelNumberTo: [modelIterator getIteration]];

  [modelIterator nextControlSetOnObject: aSwarmObject
                       withInstanceName: anInstanceName];

  return self;
}



///////////////////////////////////////////////////////////////////////
//
// canWeGoAgain 
//
///////////////////////////////////////////////////////////////////////
- (BOOL) canWeGoAgain {

  if ([modelIterator canWeGoAgain] == NO) { 

           return NO;

  }
 
   return YES;
}


/**********************************************

- printParameters: (id <OutFile>)anOutFile {

  [anOutFile putNewLine];
  [ObjectSaver save: self to: anOutFile withTemplate: paramProbeMap];
  [anOutFile putNewLine];

  return self;

}

************************************************/

- (id <List>) getManagedClasses {

   return managedClasses;

}

- (id <List>) getInstanceNames {

   return instanceNames;

}

@end


@implementation ExperSwarm

+ createBegin: aZone
{
  ExperSwarm *obj;
  id <ProbeMap> theProbeMap;

  obj = [super createBegin: aZone];

  obj->numExperimentsRun = 0;

  theProbeMap = [EmptyProbeMap createBegin: aZone];
  [theProbeMap setProbedClass: [self class]];
  theProbeMap = [theProbeMap createEnd];

  [theProbeMap addProbe: [probeLibrary getProbeForVariable: "numExperimentsRun"
                                   inClass: [self class]]];

  [probeLibrary setProbeMap: theProbeMap For: [self class]];

  return obj;		// We return the newly created ExperSwarm
}


- createEnd
{
  return [super createEnd];
}



- buildObjects
{

  [super buildObjects];

  fprintf(stderr, "EXPERSWARM >>>> buildObjects actionCache = %p\n", actionCache);

  // Build the parameter manager

  parameterManager = [ParameterManager create: self];

  [parameterManager initializeParameters];

  [controlPanel setStateStopped];

  //
  // creates the controller for the subSwarm
  //
  subSwarmControl = [ActivityControl createBegin: [self getZone]];
  [subSwarmControl setDisplayName: "Model Run Controller"];
  subSwarmControl = [subSwarmControl createEnd];


  //
  // Get the classes of the objects that will be probed and altered at run time
  //
  experClassList = [parameterManager getManagedClasses];

  //
  // Create the list indices that will last the lifetime of the experiment
  //
  experClassNdx = [experClassList listBegin: [self getZone]];

  //
  // Get the labels (user defined names) of the objects that will be
  // altered at run time.
  //
  experInstanceNames = [parameterManager getInstanceNames];

  return self;
}



//////////////////////////////////
//
// buildActions
//
/////////////////////////////////
- buildActions
{
  [super buildActions];

  dynRunGroup = [[ActionGroup createBegin: self] createEnd];
  testRunGroup = [[ActionGroup createBegin: self] createEnd];

  experSchedule = [Schedule createBegin: self];
  [experSchedule setRepeatInterval: 1];
  experSchedule = [experSchedule createEnd];

  testSchedule = [Schedule createBegin: self];
  [testSchedule setRepeatInterval: 1];
  testSchedule = [testSchedule createEnd];

  [experSchedule at: 0 createActionTo: self	message: M(setupModel)];
  [experSchedule at: 0 createActionTo: self	message: M(buildModel)];
  [experSchedule at: 0 createActionTo: self	message: M(runModel)];
  [experSchedule at: 0 createAction: dynRunGroup];
  [experSchedule at: 0 createActionTo: self     message: M(checkToStop)];
  [experSchedule at: 0 createActionTo: self	message: M(dropModel)];
  //[experSchedule at: 0 createActionTo: self	message: M(exitNow)];

  [experSchedule at: 0 createActionTo: probeDisplayManager message: M(update)];
  [experSchedule at: 0 createActionTo: actionCache message: M(doTkEvents)];

  return self;
}  

- activateIn: swarmContext
{
  [super activateIn: swarmContext];
  [experSchedule activateIn: self];
  return [self getActivity];
}

- (void) exitNow
{
   exit(4);
}


//////////////////////////////////////////////
//
// updateTkEvents
//
//////////////////////////////////////////////
- updateTkEvents
{
    //fprintf(stdout, "ExperSwarm >>>> updateTkEvents >>>> BEGIN\n");
    //fflush(0);

    [actionCache doTkEvents];

    //fprintf(stdout, "ExperSwarm >>>> updateTkEvents >>>> END\n");
    //fflush(0);

    return self;
}


///////////////////////////////////////////////////
//
// setupModel
//
///////////////////////////////////////////////////
- setupModel
{
  id <Zone> modelZone=nil;
  id <List> zoneList=nil;
  id <List> instanceNamesUsed = [List create: scratchZone];

  fprintf(stdout, "ExperSwarm >>>> setupModel >>>> BEGIN\n");
  fflush(0);


  subSwarm = [TroutObserverSwarm create: self];

  [ObjectLoader load: subSwarm fromFileNamed: "Observer.Setup"];

  [parameterManager initializeModelFor: subSwarm
                        andSwarmObject: subSwarm
                      withInstanceName: NONE];


  [subSwarm objectSetup];

  //
  //first get the modelSwarm and its zone;
  //
  [parameterManager initializeModelFor: subSwarm
                        andSwarmObject: [subSwarm getModelSwarm]
                      withInstanceName: NONE];

  modelZone = [ (id <Model>) [subSwarm getModelSwarm] getModelZone];

  xprint(modelZone);

  //
  // Then for every object that is of the specified classes
  // probe and initialize
  //

  if(modelZone != nil) 
  {
   Class  aClass=Nil;
  
   zoneList = [modelZone getPopulation];

   [experClassNdx setLoc: Start];

   while(([experClassNdx getLoc] != End) && ((aClass = (Class) [experClassNdx next]) != Nil)) 
   {
       id anObj = nil;
       id <ListIndex> lstNdx;

       lstNdx = [zoneList listBegin: [self getZone]];

       while(([lstNdx getLoc] != End) && ((anObj = [lstNdx next]) != nil)) 
       {
           id <Symbol> instanceName = nil;
           BOOL anObjModified = NO;

           if(getClass(anObj) == aClass) 
           {
                   if([experInstanceNames getCount] > 0)
                   {
                      //
                      // instanceName 'NONE' is not on this list.
                      //
                      id <ListIndex> instanceNameNdx = [experInstanceNames listBegin: scratchZone];
                      while(([instanceNameNdx getLoc] != End) && ((instanceName = [instanceNameNdx next]) != nil))
                      {
                           if([anObj respondsTo: @selector(getInstanceName)])
                           {
                               if(strcmp([instanceName getName], [anObj getInstanceName]) == 0)
                               {
                                     //
                                     // Alter the objects parameter value
                                     // 
                                    [parameterManager initializeModelFor: subSwarm
                                                          andSwarmObject: anObj
                                                        withInstanceName: instanceName];
                                     anObjModified = YES;
                                     [instanceNamesUsed addLast: instanceName];
                                     break;
                                }
                            }
                      }
                      [instanceNameNdx drop];
                   }

                   if(!anObjModified)
                   {
                         [parameterManager initializeModelFor: subSwarm
                                               andSwarmObject: anObj
                                             withInstanceName: NONE];

                   }
           }
       }

       [lstNdx drop];

    } //while Class

    if([instanceNamesUsed getCount] != [experInstanceNames getCount])
    {
        id <ListIndex> ndx = [experInstanceNames listBegin: scratchZone];
        id <Symbol> instanceName = nil;
        while(([ndx getLoc] != End) && ((instanceName = [ndx next]) != nil)) 
        {
            if([instanceNamesUsed contains: instanceName])
            {
                continue;
            }
            else
            {
                fprintf(stderr, "ERROR: ExperSwarm >>>> setupModel >>>> instanceName = %s not used but defined in Experiment.Setup\n", [instanceName getName]);
                fflush(0);
            }
        }
        [ndx drop];
        exit(1);
    }

    [instanceNamesUsed removeAll];
    [instanceNamesUsed drop];
    instanceNamesUsed = nil;

  }

  // Let the subSwarm build its objects and actions and activate
  // it in "nil", giving us a new activity. We don't start it here...
  // we will start models from the ExperSwarm schedule.
  
  [controlPanel setStateStopped];

  fprintf(stdout, "ExperSwarm >>>> setupModel >>>> END\n");
  fflush(0);

  return self;

}


////////////////////////////////////////////////
//
// buildModel
//
///////////////////////////////////////////////
- buildModel {


  [subSwarm buildObjects];

  //[subSwarm useActionCache: actionCache];

  [subSwarm buildActions];

  //subSwarm = [subSwarm createEnd];   // skj 10/30/2000

  [subSwarm activateIn: nil];

  [subSwarm setExperSwarm: self];

  // this if is an artefact of bad design for the ActivityControl class
  if (![probeLibrary isProbeMapDefinedFor: [ActivityControl class]]) {
    // now that the subSwarm is activated, attach the controller to it
    [subSwarmControl attachToActivity: [subSwarm getActivity]];
    CREATE_ARCHIVED_PROBE_DISPLAY (subSwarmControl);
  }
  else
    [subSwarmControl attachToActivity: [subSwarm getActivity]];

  return self;
}  




////////////////////////////////////////////////////////////
//
// runModel
//
////////////////////////////////////////////////////////////
- runModel
{
  static id <Symbol> activityState;
  BOOL doneRunning=NO;


  // We have built the model and activated it - here is where we run it.
  // When it has terminated, control will return here.

  while(((activityState = [[subSwarm getActivity] run]) != Terminated) &&
	 (activityState != Stopped))
  {
                   ;  // just loop
  }

  fprintf(stdout, "ExperSwarm >>>> runModel >>>> activityState = %s\n", [activityState getName]);
  fflush(0);

  if((doneRunning = [subSwarm areYouFinishedYet]) == YES) 
  {
    fprintf(stdout,"ExperSwarm >>>> doneRunning = %d\n", doneRunning);
    fflush(0);
 
    numExperimentsRun++;               // increment count of models

  }
  else if(doneRunning == NO) 
  {
    // then insert another runModel onto a dynamic schedule between
    // runModel and doStats
    //[dynRunGroup createActionTo: self message: M(runModel)];

    // and stop the sim so the user can fiddle with things
  
    [controlPanel setStateStopped];

  }

  return self;
}



////////////////////////////////////
//
// dropModel
//
////////////////////////////////////
- dropModel
{

  // The model has finished and we've extracted the data we need from
  // it. We drop the subSwarm's activity, and then drop the subSwarm
  // itself which drops all of the objects built by subSwarm

  fprintf(stdout, "ExperSwarm >>>> dropModel >>>> BEGIN\n");
  fprintf(stdout, "ExperSwarm >>>> dropModel >>>> subSwarm activity = %p\n", [subSwarm getActivity]);
  fflush(0);
  xprint([subSwarm getActivity]);

  [[subSwarm getActivity] drop];
  [subSwarm drop];
  subSwarm = nil;  

  fprintf(stdout, "ExperSwarm >>>> dropModel >>>> END\n");
  fflush(0);

  return self;

}


- checkToStop
{
  //
  // If all the models have run, time to quit!
  //
  if ([parameterManager canWeGoAgain] == NO)
  {
      
      [probeDisplayManager update];
      [actionCache doTkEvents];
      
      fprintf(stdout, "ExperSwarm >>>> checkToStop >>>> All the models have run!\n");
      fflush(0);
      
      [controlPanel setStateQuit];
  }
  
  return self;
}

@end


@implementation TestInput

+ create: aZone
{
   return [super create: aZone];
}


- testInputWithDataType: (char *) varType
           andWithValue: (char *) varValue
       andWithParamName: (char *) varName
{
   int i;
   int strLength = 0;
   BOOL ERROR = NO;        

   strLength = strlen(varValue);

   if(strncmp("filename", varType, strlen("filename")) == 0)
   {
   }
   if(strncmp("day", varType, strlen("day")) == 0)
   {
       int slashCount = 0;
       BOOL month = YES;
       int monthCount = 0;
       BOOL day = NO;
       int dayCount = 0;

       for(i = 0; i < strLength; i++)
       {

            switch(varValue[i])
            {
            case '/': 
                      ++slashCount;
                      if((slashCount == 1) && (month == YES))
                      { 
                          month = NO;
                          day = YES;
                      } 
                      break;
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9': 
                      if(month == YES)
                      {
                         ++monthCount;
                      }
                      if(day == YES)
                      {
                          ++dayCount;
                      }
                      break;


            default: fprintf(stderr, "ERROR: TestInput >>>> input error check parameter: %s varValue: %s in experiment setup file\n", varName, varValue);
                     fflush(0);
                     exit(1);
                     break;
            }

       }

       if((monthCount == 0) || (monthCount > 2))
       {
            ERROR = YES;
       }
       if((dayCount == 0) || (dayCount > 2))
       {
            ERROR = YES;
       }
       if(slashCount > 1)
       {
            ERROR = YES;
       }
   }
   if(strncmp("date", varType, strlen("date")) == 0)
   {
       int slashCount = 0;
       BOOL month = YES;
       int monthCount = 0;
       BOOL day = NO;
       int dayCount = 0;
       BOOL year = NO;
       int yearCount = 0;


       for(i = 0; i < strLength; i++)
       {

            switch(varValue[i])
            {
            case '/': 
                      ++slashCount;
                      if((slashCount == 1) && (month == YES))
                      { 
                          month = NO;
                          day = YES;
                      } 
                      if((slashCount == 2) && (day == YES))
                      {
                           day = NO;
                           year = YES;
                      }

                      break;
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9': 
                      if(month == YES)
                      {
                         ++monthCount;
                      }
                      if(day == YES)
                      {
                          ++dayCount;
                      }
                      if(year == YES)
                      {
                          ++yearCount;
                      }
                      break;


            default: fprintf(stderr, "ERROR: TestInput >>>> input error check parameter: %s varValue: %s in experiment setup file\n", varName, varValue);
                     fflush(0);
                     exit(1);
                     break;
            }

       }

       if((monthCount == 0) || (monthCount > 2))
       {
            ERROR = YES;
       }
       if((dayCount == 0) || (dayCount > 2))
       {
            ERROR = YES;
       }
       if(yearCount != 4)
       {
            ERROR = YES;
       }

   }
   if(strncmp("int", varType, strlen("int")) == 0)
   {

       int digitCount = 0;

       for(i = 0; i < strLength; i++)
       {
            switch(varValue[i])
            {
               case '.':
                         ERROR = YES;
                         break;
               case '-': 
                         if(digitCount != 0)
                         {
                            ERROR = YES;
                         }
                         break;

               case '0':
               case '1':
               case '2':
               case '3':
               case '4':
               case '5':
               case '6':
               case '7':
               case '8':
               case '9': 
                          ++digitCount;
                          break;

               default: ERROR = YES;
                        break;

            }
       }

   }
   if(strncmp("BOOL", varType, strlen("BOOL")) == 0)
   {

        ERROR = YES;
   
        if((strncmp(varValue, "YES", strlen("YES")) == 0) || (strncmp(varValue, "NO", strlen("NO")) == 0))
        {
            ERROR = NO;
        }

     
   }
   if((strncmp("float", varType, strlen("float")) == 0) || (strncmp("double", varType, strlen("double")) == 0))
   {
       BOOL e = NO;
       BOOL E = NO;
       BOOL decimal = NO;
       BOOL sign = NO;
       BOOL expSign = NO;


       int digitCount = 0;
       int mantissaCount = 0;

       for(i = 0; i < strLength; i++)
       {


            switch(varValue[i])
            {
               case '.':
                         if(decimal == YES)
                         {
                            ERROR = YES;
                         }
                         decimal = YES;
                         break;
               case '-':
                         if(((e == YES) || (E == YES)) && (expSign == NO))
                         {
                            expSign = YES;
                            sign = NO;
                         }
                         if((mantissaCount != 0) && (expSign == YES))
                         {
                             ERROR = YES;
                         }
                         if(sign == YES)
                         {
                            ERROR = YES;
                         }
                         if((digitCount != 0) && (expSign == NO))
                         {
                            ERROR = YES;
                         } 
                         sign = YES;
                         break;

               case 'e': 
                         if((digitCount == 0) || (e == YES) || (E == YES))
                         {
                            ERROR = YES;
                         }

                         e = YES;
                         break;
               case 'E':
                         if((digitCount == 0) || (E == YES) || (e == YES))
                         {
                            ERROR = YES;
                         }

                         E = YES;
                         break;
               case '0':
               case '1':
               case '2':
               case '3':
               case '4':
               case '5':
               case '6':
               case '7':
               case '8':
               case '9':
                         ++digitCount;

                         if((E == YES) || (e == YES))
                         {
                            ++mantissaCount; 
                         }
                         break;

               default: 
                        ERROR = YES;
                        break;
            }

       }




   }

   if(ERROR == YES)
   {
       fprintf(stderr, "ERROR: TestInput >>>> input error check parameter: %s varValue: %s in experiment setup file\n", varName, varValue);
       fflush(0);
       exit(1);
   } 

   return self;


}




@end

