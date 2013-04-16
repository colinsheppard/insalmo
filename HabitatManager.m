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



#include "HabitatManager.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


@implementation HabitatManager

+ createBegin: aZone
{
   HabitatManager* habManager;
   habManager = [super createBegin: aZone];

   habManager->siteLatitude = -LARGEINT;

   habManager->habitatSpaceNdx = nil;
   habManager->rasterColorVariable = NULL;
   return habManager;
}



- createEnd
{
   return [super createEnd];
}


- setModel: aModel
{
   model = (id <TroutModelSwarm>) aModel;
   return self;
}


- setTimeManager: (id <TimeManager>) aTimeManager
{
   timeManager = aTimeManager;
   return self;
}


- setModelStartTime: (time_t) aRunStartTime
         andEndTime: (time_t) aRunEndTime
{
   runStartTime = aRunStartTime;
   runEndTime = aRunEndTime;
   return self;
}


- setDataStartTime: (time_t) aDataStartTime
        andEndTime: (time_t) aDataEndTime
{
   dataStartTime = aDataStartTime;
   dataEndTime = aDataEndTime;
   return self;
}


- setSiteLatitude: (double) aLatitude
{
   siteLatitude = aLatitude;
   return self;
}


///////////////////////////////////////
//
////      GET METHODS
//////
///////
///////////////////////////////////////

- (int) getNumberOfHabitatSpaces
{
      return numHabitatSpaces;
}


////////////////////////////////////
//
// getHabitatSpaceList
//
////////////////////////////////////
- getHabitatSpaceList
{
      return habitatSpaceList;
}


////////////////////////////////////
//
// getReachWithName
//
// It is the responsibility of the caller 
// to check for a nil return value.
//
////////////////////////////////////
- getReachWithName: (char *) aReachName
{
  
     id aHabitatSpace = nil;
     int i;

     for(i=0; i < numHabitatSpaces; i++)
     {
        aHabitatSpace = [habitatSpaceList atOffset: i]; 

        if(strcmp(aReachName, [aHabitatSpace getReachName]) == 0)
        {
           break;
        }

        aHabitatSpace = nil;
     }

     //if(aHabitatSpace == nil)
     //{
        //fprintf(stderr, "ERROR: HabitatManager >>>> getReachWithName >>>> There is no reach with name %s \n", aReachName);
        //fflush(0);
        //exit(1);
     //}

     return aHabitatSpace;

}




/////////////////////////////////////////////////////
//
// readReachSetupFile
//
/////////////////////////////////////////////////////
- readReachSetupFile: (char *) aReachSetupFile
{
  FILE * reachFilePtr =  NULL;

  char header[300];

  char reachVarName[50];
  char reachVar[50];

  id habitatSetup = nil;
  int habIndex = -1;

  fprintf(stdout, "HabitatManager >>>> readReachSetupFile >>>> BEGIN\n");
  fflush(0);
  

  if((reachFilePtr = fopen(aReachSetupFile, "r")) == NULL)
  {
      fprintf(stdout, "ERROR: HabitatManager >>>> readReachSetupFile >>>> fileName = %s \n", aReachSetupFile);
      fflush(0);
      exit(1);
  }

  fgets(header, 300, reachFilePtr);
  fgets(header, 300, reachFilePtr);
  fgets(header, 300, reachFilePtr);

      while(fscanf(reachFilePtr,"%s", reachVarName) != EOF)
      {
        if(strcmp(reachVarName, "REACHBEGIN") == 0)
        {
           //fprintf(stdout, "HABITATMANAGER >>>> if reach begin >>>>\n");
           //fflush(0);
           habitatSetup = [HabitatSetup createBegin: habManagerZone]; 
           [habitatSetup setHabitatIndex: ++habIndex];
           habitatSetup = [habitatSetup createEnd];
           [habitatSetupList addLast: habitatSetup];
           xprint(habitatSetup);
           xprint(habitatSetupList);
           continue;
        }

        if(strcmp(reachVarName, "REACHEND") == 0)
        {
           continue;
        }

        if(fscanf(reachFilePtr,"%s", reachVar) == EOF)
        {
            fprintf(stderr, "ERROR: HabitatManager >>>> End of file >>>> Please check the Habitat Manager Setup file\n");
            fflush(0);
            exit(1);
        }
    
        if(strcmp(reachVarName, "reachName") == 0)
        {
           [habitatSetup setReachName: reachVar];
           [habitatSetup setReachSymbol: [model getReachSymbolWithName: reachVar]];
        }
         
        if(strcmp(reachVarName, "habDownstreamJunctionNumber") == 0)
        {
           [habitatSetup setHabDStreamJNumber: atoi(reachVar)];
        }
         
        if(strcmp(reachVarName, "habUpstreamJunctionNumber") == 0)
        {
           [habitatSetup setHabUStreamJNumber: atoi(reachVar)];
        }

        if(strcmp(reachVarName, "habParamFile") == 0)
        {
           [habitatSetup setHabParamFile: reachVar];
        }
         
        if(strcmp(reachVarName, "cellGeomFile") == 0)
        {
           [habitatSetup setCellGeomFile: reachVar];
        }

        if(strcmp(reachVarName, "cellHydraulicFile") == 0)
        {
           [habitatSetup setHydraulicFile: reachVar];
        }
         
        if(strcmp(reachVarName, "flowFile") == 0)
        {
           [habitatSetup setFlowFile: reachVar];
        }
         
        if(strcmp(reachVarName, "temperatureFile") == 0)
        {
           [habitatSetup setTemperatureFile: reachVar];
        }
         
        if(strcmp(reachVarName, "turbidityFile") == 0)
        {
           [habitatSetup setTurbidityFile: reachVar];
        }
         
        if(strcmp(reachVarName, "cellHabVarsFile") == 0)
        {
           [habitatSetup setCellHabVarsFile: reachVar];
        }
         
        if(strcmp(reachVarName, "barrierX") == 0)
        {
               fprintf(stderr, "ERROR: HabitatManager >>>> readReachSetupFile >>>> Reach.Setup\nSorry, no barriers allowed in this version\n");
               fflush(0);
               exit(1);
        }
         
        if(strcmp(reachVarName, "reachFlow") == 0)
        {
               fprintf(stderr, "ERROR: HabitatManager >>>> readReachSetupFile >>>> Reach.Setup\nNo reachFlow input in this version\n");
               fflush(0);
               exit(1);
          /* PolyInputData* polyInputData = [PolyInputData create: habManagerZone];

           double reachFlow = atof(reachVar);

           [polyInputData setPolyFlow: reachFlow];

           //
           // Read another line of input
           // Should be a velocity data file
           //
           fscanf(reachFilePtr,"%s %s", reachVarName, reachVar);
           
           if(strcmp(reachVarName, "reachVelocityFile") != 0)
           {
               fprintf(stderr, "ERROR: HabitatManager >>>> readReachSetupFile >>>> Reach.Setup velocity and depth files out of order\n");
               fflush(0);
               exit(1);  
           }
           [polyInputData  setPolyVelocityDataFile: reachVar];;

           //
           // Read another line of input
           // Should be a flow data file
           //
           fscanf(reachFilePtr,"%s %s", reachVarName, reachVar);
           if(strcmp(reachVarName, "reachDepthFile") != 0)
           {
               fprintf(stderr, "ERROR: HabitatManager >>>> readReachSetupFile >>>> Reach.Setup velocity and depth files out of order\n");
               fflush(0);
               exit(1);
           }
           [polyInputData  setPolyDepthDataFile: reachVar];;

           //
           // Now add this to the list of poly input data objects
           //
           [[habitatSetup getListOfPolyInputData] addLast: polyInputData];
           */
        }
         
        //fprintf(stdout,"reachVarName %s\n", reachVarName);
        //fprintf(stdout,"reachVar %s\n", reachVar);
        //xprint([habitatSetup getReachSymbol]);
        //fflush(0);

      }

  fclose(reachFilePtr);

  numHabitatSpaces = [habitatSetupList getCount];

  fprintf(stdout, "HabitatManager >>>> readReachSetupFile >>>> END\n");
  fflush(0);
 

  return self;
  

}


//////////////////////////////////////////////////
//
// instantiateObjects
//
//////////////////////////////////////////////////
- instantiateObjects
{

   habManagerZone = [Zone create: [self getZone]];
   habitatSetupList = [List create: habManagerZone];
   habitatSpaceList = [List create: habManagerZone];

   return self;

}


////////////////////////////////////////////
//
// setFishParamsMap
//
////////////////////////////////////////////
- setFishParamsMap: (id <Map>) aMap
{
    fishParamsMap = aMap;
    return self;
}



///////////////////////////////////////////////
//
// setNumberOfSpecies
//
////////////////////////////////////////////
- setNumberOfSpecies: (int) aNumberOfSpecies
{
   numberOfSpecies = aNumberOfSpecies;
   return self;
}


//////////////////////////////////////////////////////
//
// setPolyRasterResolution
//
/////////////////////////////////////////////////////
-   setPolyRasterResolutionX: (int) aPolyRasterResolutionX
    setPolyRasterResolutionY: (int) aPolyRasterResolutionY
     setRasterColorVariable:  (char *) aRasterColorVariable
           setShadeColorMax:  (double) aShadeColorMax
{

  //  fprintf(stdout, "HabitatManager >>>>  setPolyRasterResolution >>>> BEGIN\n");
  //  fflush(0);

    polyRasterResolutionX = aPolyRasterResolutionX;
    polyRasterResolutionY = aPolyRasterResolutionY;
    strncpy(polyRasterColorVariable, aRasterColorVariable, 35);
           shadeColorMax = aShadeColorMax; 

  //  fprintf(stdout, "HabitatManager >>>>  setPolyRasterResolution >>>> END\n");
  //  fflush(0);

    return self;
}



///////////////////////////////////
//
// buildObjects
//
///////////////////////////////////
- buildObjects
{
   fprintf(stdout, "HabitatManager >>>> buildObjects >>>> BEGIN\n");
   fflush(0);

   [self finishBuildingTheHabitatSpaces];

   fprintf(stdout, "HabitatManager >>>> buildObjects >>>> END\n");
   fflush(0);
   return self;
}



/////////////////////////////////////////////////
//
// updateHabitatManagerWithTime
//
/////////////////////////////////////////////////
- updateHabitatManagerWithTime: (time_t) aTime
         andWithModelStartFlag: (BOOL) aStartFlag
{
   id habSpace = nil;
   int julianDate;

//   fprintf(stdout, "HabitatManager >>>> updateHabitatManagerWithTime >>>> BEGIN\n");
//   fflush(0);


   modelTime = aTime;
   strncpy(modelDate, [timeManager getDateWithTimeT: modelTime], (size_t) 11);
   julianDate = [timeManager getJulianDayWithTimeT: modelTime]; 

   [solarManager updateDayLengthWithJulianDate: julianDate];

   if(habitatSpaceNdx == nil)
   {
        fprintf(stderr, "ERROR: HabitatManager >>>> updateHabitatManager... >>>> habitatSpaceNdx is nil\n");
        fflush(0);
        exit(1);
   }

   [habitatSpaceNdx setLoc: Start];
   while(([habitatSpaceNdx getLoc] != End) && ((habSpace = [habitatSpaceNdx next]) != nil))
   {
       [habSpace   updateHabitatWithTime: modelTime
                   andWithModelStartFlag: aStartFlag];
   }


   if(aStartFlag == NO)
   {
      #ifdef DEPTH_REPORT_ON
        [self printCellDepthReport];
      #endif 

      #ifdef VELOCITY_REPORT_ON
        [self printCellVelocityReport];
      #endif

      #ifdef HABITAT_REPORT_ON
        [self printHabitatReport];
      #endif

      #ifdef DEPTH_VEL_RPT
        [self printCellAreaDepthVelocityRpt];
      #endif

   }

//   fprintf(stdout, "HabitatManager >>>> updateHabitatManagerWithTime >>>> END\n");
//   fflush(0);

   return self;

}

////////////////////////////////////////////
//
// setShadeColorMax
//
/////////////////////////////////////////////
-  setShadeColorMax: (double) aShadeColorMax
     inHabitatSpace: aHabitatSpace
{
     id <ListIndex> ndx = [habitatSpaceList listBegin: scratchZone];
     HabitatSpace* habitatSpace = nil;

     shadeColorMax = aShadeColorMax;

     while(([ndx getLoc] != End) && ((habitatSpace = [ndx next]) != nil))
     {
         if(habitatSpace == aHabitatSpace)
         {
             [habitatSpace setShadeColorMax: shadeColorMax];  
             break;
         }
     }
     
     [ndx drop];
     return self;
}


////////////////////////////////////////////////////
//
// toggleCellsColorRepIn 
//
//////////////////////////////////////////////////
- toggleCellsColorRepIn: aHabitatSpace 
{
    id <ListIndex> ndx = [habitatSpaceList listBegin: scratchZone];
    HabitatSpace* habitatSpace = nil;
    while(([ndx getLoc] != End) && ((habitatSpace = [ndx next]) != nil))
    {
        if(habitatSpace == aHabitatSpace)
        {
             [habitatSpace toggleCellsColorRep];
             break;
        }
    }
    [ndx drop];
    ndx = nil;
   
    return self;
}

//////////////////////////////////////////
//
// createSolarManager
//
//////////////////////////////////////////
- createSolarManager
{
   if(siteLatitude == -LARGEINT)
   {
      fprintf(stderr, "ERROR: HabitatManager >>>>> siteLatitude hase not been set\n");
      fflush(0);
      exit(1);
   }

   solarManager = [SolarManager create: habManagerZone
                          withLatitude: siteLatitude
                      withHorizonAngle: 0.0
                    withTwilightLength: 6];

   return self;
}


////////////////////////////////////////////
//
// instantiateHabitatSpacesInZone
//
//
// The habitat space(s) must instantiated in the model zone
// so that the experiment swarm can talk to them.
//
////////////////////////////////////////////
- instantiateHabitatSpacesInZone: (id <Zone>) aZone
{
  HabitatSpace* habitatSpace = nil;
  int habitatSpaceCount;

  fprintf(stdout, "HabitatManager >>> instantiateHabitatSpacesInZone >>>> BEGIN\n");
  fflush(0); 
  
  for(habitatSpaceCount = 0; habitatSpaceCount < numHabitatSpaces; habitatSpaceCount++)
  {  

     id habSetup = [habitatSetupList atOffset: habitatSpaceCount];
 
     habitatSpace = [HabitatSpace createBegin: aZone];
     [habitatSpace setModel: model];
     [habitatSpace setNumberOfSpecies: numberOfSpecies];
     [ObjectLoader load: habitatSpace fromFileNamed: [habSetup getHabParamFile]];

     [habitatSpace setReachName: [habSetup getReachName]];
     [habitatSpace setInstanceName: [habSetup getReachName]];
     [habitatSpace setReachSymbol: [habSetup getReachSymbol]];
     [habitatSpace setHabDStreamJNumber: [habSetup getHabDStreamJNumber]];
     [habitatSpace setHabUStreamJNumber: [habSetup getHabUStreamJNumber]];

     [habitatSpace setFishParamsMap: fishParamsMap];
     [habitatSpace setSolarManager: solarManager];

     [habitatSpace buildObjects];

     [habitatSpace setPolyCellGeomFile: [habSetup getCellGeomFile]];
     [habitatSpace setHydraulicFile: [habSetup getHydraulicFile]];
     [habitatSpace setFlowFile: [habSetup getFlowFile]];
     [habitatSpace setTemperatureFile: [habSetup getTemperatureFile]];
     [habitatSpace setTurbidityFile: [habSetup getTurbidityFile]];
     [habitatSpace setCellHabVarsFile: [habSetup getCellHabVarsFile]];
     [habitatSpace setListOfPolyInputData: [habSetup getListOfPolyInputData]];
   
     xprint(habitatSpace);

     [habitatSpaceList addLast: habitatSpace];  

     xprint(habitatSpaceList);
  }

  //
  // This ndx exists for the lifetime of the modelrun 
  // DO NOT EVER DROP IT!
  //
  habitatSpaceNdx = [habitatSpaceList listBegin: habManagerZone];

  fprintf(stdout, "HabitatManager >>> instantiateHabitatSpacesInZone >>>> END\n");
  fflush(0); 

  return self;
}



/////////////////////////////////////////////
//
// finishBuildingTheHabitatSpaces
//
////////////////////////////////////////////
- finishBuildingTheHabitatSpaces
{

  HabitatSpace* habitatSpace = nil;
  int habitatSpaceCount;

  for(habitatSpaceCount = 0; habitatSpaceCount < numHabitatSpaces; habitatSpaceCount++)
  {  
     //id habSetup = [habitatSetupList atOffset: habitatSpaceCount];

     habitatSpace = [habitatSpaceList atOffset: habitatSpaceCount];

     //
     // BEGIN: Code moved from instantiateHabitatSpaces
     //
 
     //[habitatSpace setSpaceDimensions];

     [habitatSpace setTimeManager: timeManager];

     //
     // Poly Cells BEGIN
     //
  
     [habitatSpace setPolyRasterResolutionX: polyRasterResolutionX
                   setPolyRasterResolutionY: polyRasterResolutionY
                     setRasterColorVariable: polyRasterColorVariable
                           setShadeColorMax: shadeColorMax];

     [habitatSpace buildPolyCells];

     [habitatSpace setSizeX: [habitatSpace getSpaceDimX]  Y: [habitatSpace getSpaceDimY] ];
     habitatSpace = [habitatSpace createEnd];


     //
     // END: Code moved from instantiateHabitatSpaces
     //


     [habitatSpace setModelStartTime: runStartTime andEndTime: runEndTime];
     [habitatSpace setDataStartTime: dataStartTime andEndTime: dataEndTime];

     [habitatSpace createTimeSeriesInputManagers]; 

     habitatSpace = [habitatSpace createEnd];

     
     //
     // Poly Cells END
     //

 
     [habitatSpace finishBuildObjects];
  }

  [self buildReachJunctions];
  

  fprintf(stdout, "HabitatManager >>>> finishBuildingTheHabitatSpaces >>>> END\n");
  fflush(0);

  return self;
}


////////////////////////////////////////////////////
//
// buildHabSpaceCellFishInfoReporter
//
///////////////////////////////////////////////////
- buildHabSpaceCellFishInfoReporter
{
  HabitatSpace* habitatSpace = nil;
  int habitatSpaceCount;

  for(habitatSpaceCount = 0; habitatSpaceCount < numHabitatSpaces; habitatSpaceCount++)
  {  
     habitatSpace = [habitatSpaceList atOffset: habitatSpaceCount];
    [habitatSpace buildCellFishInfoReporter];
  }

  return self;
}

////////////////////////////////////////////////////////////
//
// buildReachJunctions
//
////////////////////////////////////////////////////////////
- buildReachJunctions
{

   id <ListIndex> reachNdx = [habitatSpaceList listBegin: scratchZone];
   id <ListIndex> reachJNdx = [habitatSpaceList listBegin: scratchZone];

   id aReach = nil;
   id aJReach = nil;

   fprintf(stdout, "HabitatManager >>>> buildReachJunctions >>>> BEGIN\n");
   fflush(0);


   [reachNdx setLoc: Start];

   while(([reachNdx getLoc] != End) && ((aReach = [reachNdx next]) != nil))
   {
      [reachJNdx setLoc: Start];

      while(([reachJNdx getLoc] != End) && ((aJReach = [reachJNdx next]) != nil))
      {
             if(aJReach == aReach) continue;
           
             if([aJReach getHabDStreamJNumber] == [aReach getHabDStreamJNumber])
             {
                 [aReach setHabDownstreamLinksToDS: aJReach];
             }
             
             if([aJReach getHabUStreamJNumber] == [aReach getHabDStreamJNumber])
             {
                 [aReach setHabDownstreamLinksToUS: aJReach];
             }
             
             if([aJReach getHabDStreamJNumber] == [aReach getHabUStreamJNumber])
             {
                 [aReach setHabUpstreamLinksToDS: aJReach];
             }
             
             if([aJReach getHabUStreamJNumber] == [aReach getHabUStreamJNumber])
             {
                 [aReach setHabUpstreamLinksToUS: aJReach];
             }
             
      }

   }

   //
   // check adjacent reaches in each habitatSpace
   //
   if(0)
   {
       [reachNdx setLoc: Start];
    
       while(([reachNdx getLoc] != End) && ((aReach = [reachNdx next]) != nil))
       {
              fprintf(stdout, "HabitatManager >>>> buildReachJunctions >>>> checkAdjacentReaches >>>> reach = %s\n", [aReach getReachName]);
              fflush(0);
              [aReach checkAdjacentReaches];
              xprint([aReach getUpstreamCells]);
              xprint([aReach getDownstreamCells]);
              fprintf(stdout, "HabitatManager >>>> buildReachJunctions >>>> checkAdjacentReaches >>>> reach = %s\n", [aReach getReachName]);
              fflush(0);
       }
       [reachJNdx drop];
   }

   [reachNdx drop];

   fprintf(stdout, "HabitatManager >>>> buildReachJunctions >>>> END\n");
   fflush(0);

   //exit(0);

   return self;
}






///////////////////////////////////////////////////////////
//
////
//////            FILE OUTPUT
////////
//////////
////////////
///////////////////////////////////////////////////////////


/////////////////////////////////////
//
// outputCellFishInfoReport
//
////////////////////////////////////
- outputCellFishInfoReport
{
   //fprintf(stdout, "HabitatManager >>>> outputCellFishInfoReport >>>> BEGIN\n");
   //fflush(0);

   [habitatSpaceList forEach: M(outputCellFishInfoReport)];

   //fprintf(stdout, "HabitatManager >>>> outputCellFishInfoReport >>>> END\n");
   //fflush(0);
   return self;
}
   



#ifdef DEPTH_REPORT_ON
- printCellDepthReport
{

   [habitatSpaceList forEach: M(printCellDepthReport)]; 

   return self;

}
    
#endif

#ifdef VELOCITY_REPORT_ON
- printCellVelocityReport
{

   [habitatSpaceList forEach: M(printCellVelocityReport)]; 

   return self;
}

#endif


#ifdef HABITAT_REPORT_ON
- printHabitatReport
{

   [habitatSpaceList forEach: M(printHabitatReport)]; 

   return self;
}
#endif

#ifdef DEPTH_VEL_RPT
- printCellAreaDepthVelocityRpt
{

   [habitatSpaceList forEach: M(printCellAreaDepthVelocityRpt)]; 

   return self;
}
#endif


/////////////////////////////////
//
// drop
//
////////////////////////////////
- (void) drop
{
  //  fprintf(stdout, "HabitatManager >>>> drop >>>> BEGIN\n");
  //  fflush(0);

    [habitatSpaceList deleteAll];
    [habitatSpaceList drop];
    habitatSpaceList = nil; 


  //  fprintf(stdout, "HabitatManager >>>> drop >>>> END\n");
  //  fflush(0);
}


@end
