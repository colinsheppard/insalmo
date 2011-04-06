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


#include <stdlib.h>


#import "FishParams.h"

@implementation FishParams

+  createBegin: aZone
{
  FishParams* fishParams=nil;

  Class superClass;   
  id <ProbeLibrary> superProbeLibrary=nil;  
  id <ProbeMap> superProbeMap=nil;  
  id supMapNdx;
  id <VarProbe> supProbe;
  id mapNdx;
  id aProbe;


  fishParams = [super createBegin: aZone];
  
  fishParams->parameterFileName = (char *) nil;

  fishParams->anInitInt = [aZone alloc: sizeof(int)];
  fishParams->anInitFloat = [aZone alloc: sizeof(float)];
  fishParams->anInitDouble = [aZone alloc: sizeof(double)];
  fishParams->anInitId = [aZone alloc: sizeof(id)];

  strncpy(fishParams->anInitString, "nil", 3);
  *(fishParams->anInitInt) = -LARGEINT;
  *(fishParams->anInitFloat) = (double) -LARGEINT;
  *(fishParams->anInitDouble) = (double) -LARGEINT;

  superClass = [[fishParams getClass] getSuperclass];

  fishParams->probeMap = [CompleteVarMap createBegin: aZone];
  [fishParams->probeMap setProbedClass: [fishParams getClass]];
  fishParams->probeMap = [fishParams->probeMap createEnd];

  [fishParams->probeMap dropProbeForVariable: "anInitString"];
  [fishParams->probeMap dropProbeForVariable: "anInitInt"];
  [fishParams->probeMap dropProbeForVariable: "anInitFloat"];
  [fishParams->probeMap dropProbeForVariable: "anInitDouble"];
  [fishParams->probeMap dropProbeForVariable: "anInitId"];
  [fishParams->probeMap dropProbeForVariable: "parameterFileName"];
  [fishParams->probeMap dropProbeForVariable: "probeMap"];
  [fishParams->probeMap dropProbeForVariable: "instanceName"];

  superProbeLibrary = [ProbeLibrary createBegin: aZone];
  superProbeLibrary = [superProbeLibrary createEnd]; 
  superProbeMap = [superProbeLibrary getCompleteVarMapFor: superClass];

  supMapNdx = [superProbeMap begin: aZone];

  while(([supMapNdx getLoc] != End) && ((supProbe = [supMapNdx next]) != nil))
  {
     if([fishParams->probeMap getProbeForVariable: [supProbe getProbedVariable]] != nil)
     {
         [fishParams->probeMap dropProbeForVariable: [supProbe getProbedVariable]];
         continue;
     }
  }
        
  [supMapNdx drop];


  mapNdx = [(id <Map>) fishParams->probeMap begin: aZone];
  while(([mapNdx getLoc] != End) && ((aProbe = [mapNdx next]) != nil) )
  {
        switch ([aProbe getProbedType][0]) 
        {
            case _C_CHARPTR:
                   [aProbe setData: fishParams ToString: (void *) fishParams->anInitString];
                   break;

            case _C_INT:

                  [aProbe setData: fishParams To: (void *) fishParams->anInitInt];
                  break;

            case _C_FLT:
                  [aProbe setData: fishParams To: (void *) fishParams->anInitFloat];
                  break;

            case _C_DBL:
                  [aProbe setData: fishParams To: (void *) fishParams->anInitDouble];
                  break;

            case _C_ID:
                  [aProbe setData: fishParams To: (void *) fishParams->anInitId];
                  break;

            default:
                  fprintf(stdout, "ERROR: FishParams >>>> createBegin >>>> cannot preset variable = %s\n", [aProbe getProbedVariable]);
                  fflush(0);
                  exit(1);
                  break;

            }

  }

 [mapNdx drop];


 return fishParams;

}


//////////////////////////////////////////
//
// createEnd
//
//////////////////////////////////////////
- createEnd
{

  id mapNdx;  
  id <VarProbe> aProbe;
  BOOL ERROR = FALSE;
  char buffer[300];

  fprintf(stderr, "FishParams >>>> createEnd >>>> BEGIN\n");
  fflush(0);


  mapNdx = [(id <Map>) probeMap begin: scratchZone];

  [mapNdx setLoc: Start];

  
  while(([mapNdx getLoc] != End) && ((aProbe = [mapNdx next]) != nil) )
  {

        switch ([aProbe getProbedType][0]) {
         

            case _C_CHARPTR:

                       [aProbe probeAsString: self Buffer: buffer];
 
                       if(strncmp(buffer, "nil", 3) == 0)
                       {
                           ERROR = TRUE;
                           fprintf(stderr, "ERROR: >>>> createEnd >>>> %s has not been initialized\n", [aProbe getProbedVariable]);
                           fflush(0);
                       } 
                       break;


             case _C_INT:

                      if([aProbe probeAsInt: self] == *anInitInt)
                      {
                               ERROR = TRUE;
                               fprintf(stderr, "ERROR: >>>> createEnd >>>> %s has not been initialized\n", [aProbe getProbedVariable]);
                               fflush(0);
                      } 
                      break;

            case _C_FLT:
                      if([aProbe probeAsDouble: self] == *anInitFloat)
                      {
                               ERROR = TRUE;
                               fprintf(stderr, "ERROR: >>>> createEnd >>>> %s has not been initialized\n", [aProbe getProbedVariable]);
                               fflush(0);
                      } 
                      break;

            case _C_DBL:
                      if([aProbe probeAsDouble: self] == *anInitDouble)
                      {
                               ERROR = TRUE;
                               fprintf(stderr, "ERROR: >>>> createEnd >>>> %s has not been initialized\n", [aProbe getProbedVariable]);
                               fflush(0);
                      } 
                      break;

            case _C_ID:
                      if([aProbe probeAsPointer: self] == *(id *) anInitId)
                      {
                               ERROR = TRUE;
                               fprintf(stderr, "ERROR: >>>> createEnd >>>> %s has not been initialized\n", [aProbe getProbedVariable]);
                               fflush(0);
                      } 
                      break;
            default:
                     fprintf(stderr, "FishParams >>>> createEnd >>>> cannot test variable = %s\n", [aProbe getProbedVariable]);
                     fflush(0);
                     exit(1);
                     break;

            }



  }

 [mapNdx drop];


  if(ERROR) 
  {
     fprintf(stderr, "ERROR: FishParams >>>> createEnd >>>> Please check Fish Parameter input file\n");
     fflush(0);
     exit(1);
  }

  fprintf(stderr, "FishParams >>>> createEnd >>>> EXIT\n");
  fflush(0);
 

  return [super createEnd];
}


/////////////////////////////////////////////
//
// setInstanceName
//
////////////////////////////////////////////
- setInstanceName: (char *) anInstanceName
{
    strncpy(instanceName, anInstanceName, 50);
    return self;
}

- (char *) getInstanceName
{
    return instanceName;
}



- setFishSpeciesIndex: (int) aSpeciesIndex
{

   speciesIndex = aSpeciesIndex;

   return self;

}


- setFishSpecies: (id <Symbol>) aFishSpecies
{
    fishSpecies = aFishSpecies;
    return self;
}


- (id <Symbol>) getFishSpecies
{
    return fishSpecies;
}


- printSelf 
{

  id mapNdx;  
  id <VarProbe> aProbe;
  char buffer[300];
  //size_t strLength = (size_t) 25;
  char outputFileName[26];

  FILE* filePtr = NULL;


  fprintf(stderr, "FishParams >>>> printSelf >>>> BEGIN\n");
  fflush(0);
 
  sprintf(outputFileName, "Species%sParamCheck.out", [fishSpecies getName]);

  if((filePtr = fopen(outputFileName, "w")) == NULL)
  {
     fprintf(stderr, "ERROR: FishParams >>>> printSelf >>>> Cannot open %s for writing\n", outputFileName);
     fflush(0);
  }



  mapNdx = [(id <Map>) probeMap begin: scratchZone];

  [mapNdx setLoc: Start];

  
  while(([mapNdx getLoc] != End) && ((aProbe = [mapNdx next]) != nil) )
  {

        switch ([aProbe getProbedType][0])
        {
         
            case _C_CHARPTR:
 
                       fprintf(filePtr, "FishParams >>>> %s = %s \n",
                                              [aProbe getProbedVariable],
                                              [aProbe probeAsString: self Buffer: buffer]);
                       fflush(0);
                       break;


             case _C_INT:

                       fprintf(filePtr, "FishParams >>>> %s = %d \n",
                                              [aProbe getProbedVariable],
                                              [aProbe probeAsInt: self]);
                       fflush(0);
                      
                      break;

            case _C_FLT:
                      fprintf(filePtr, "FishParams >>>> %s = %f \n",
                                                 [aProbe getProbedVariable],
                                                 [aProbe probeAsDouble: self]);
                      fflush(0);
                      break;

            case _C_DBL:
                           fprintf(filePtr, "FishParams >>>> %s = %f \n", [aProbe getProbedVariable],
                                                                             [aProbe probeAsDouble: self]);
                           fflush(0);
                           break;
            case _C_ID:
                           {
                               id obj = [aProbe probeObject: self];
                               if([obj respondsTo: @selector(getName)])
                               {
                                  fprintf(filePtr, "FishParams >>>> %s = %s \n", [aProbe getProbedVariable],
                                                                                    [[aProbe probeObject: self] getName]);
                                  fflush(0);
                                  break;
                               }
                               else
                               {
                                  fprintf(filePtr, "FishParams >>>> %s = %p \n", [aProbe getProbedVariable],
                                                                                    [[aProbe probeObject: self] getName]);
                                  fflush(0);
                                  break;
                               }
                            }

            default:
                     [InternalError raiseEvent: "FishParams >>>> printSelf >>>> cannot test variable = %s\n", [aProbe getProbedVariable]];
                     break;

        }

  }

  [mapNdx drop];


  fprintf(stderr, "FishParams >>>> printSelf >>>> EXIT\n");
  fflush(0);

  return self;

}


/////////////////////////////////////
//
// drop
//
/////////////////////////////////////
- (void) drop
{

  /*

  commented out 12/21/2009 SKJ 
  as in the debugged 4.2.1a code set

  id <MapIndex> mapNdx = [(id <Map>) probeMap begin: scratchZone];
  id aProbe = nil;

  [mapNdx setLoc: Start];
  while(([mapNdx getLoc] != End) && ((aProbe = [mapNdx next]) != nil) )
  {
      [aProbe drop];
      aProbe = nil;
  }

  [mapNdx drop];
  */

   [probeMap drop];
   probeMap = nil;
}

@end
