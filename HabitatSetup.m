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
#include <string.h>


#import "HabitatSetup.h"

@implementation HabitatSetup

+ createBegin: aZone
{

   HabitatSetup* habitatSetup = [super createBegin: aZone];

   habitatSetup->habIndex = -1;
  
   strcpy(habitatSetup->reachName,"NONAME");
   habitatSetup->reachSymbol = nil;
   strcpy(habitatSetup->habParamFile,"NONAME");
   strcpy(habitatSetup->cellGeomFile,"NONAME");
   strcpy(habitatSetup->hydraulicFile,"NONAME");
   strcpy(habitatSetup->flowFile,"NONAME");
   strcpy(habitatSetup->temperatureFile,"NONAME");
   strcpy(habitatSetup->turbidityFile,"NONAME");
   strcpy(habitatSetup->cellHabVarsFile,"NONAME");

   habitatSetup->barrierXList = nil;

   //
   // aZone should be the habManagerZone from HabitatManager
   //
   
   habitatSetup->listOfPolyInputData = [List create: aZone];

   return habitatSetup;

}


- createEnd
{
   if(habIndex < 0)
   {
       fprintf(stderr, "HabitatSetup >>>> createEnd >>>> improper habIndex\n");
       fflush(0);
       exit(1);
   }

   return [super createEnd];

}


- setHabitatIndex: (int) anIndex
{
    habIndex = anIndex;
    return self;
}



- setHabDStreamJNumber: (int) aJunctionNum
{
     habDownStreamJunctionNumber = aJunctionNum;
     return self;
}

- setHabUStreamJNumber: (int) aJunctionNum
{
     habUpStreamJunctionNumber = aJunctionNum;
     return self;
}

- setReachName: (char *) aReachName
{
   strcpy(reachName, aReachName);

   fprintf(stdout,"HabitatSetup >>>> ReachName = %s \n", reachName);
   fflush(0);

   return self;
}


- setReachSymbol: (id <Symbol>) aReachSymbol
{
    reachSymbol = aReachSymbol;
    return self;
}


- setHabParamFile: (char *) aHabParamFile
{

  strcpy(habParamFile, aHabParamFile);

  fprintf(stdout,"HabitatSetup >>>> HabParamFile = %s \n", habParamFile);
  fflush(0);


  return self;

}



- setCellGeomFile: (char *) aCellGeomFile
{

   strcpy(cellGeomFile, aCellGeomFile);

   fprintf(stdout,"HabitatSetup >>>> setCellGeomFile = %s \n", cellGeomFile);
   fflush(0);


   return self;

}

- setHydraulicFile: (char *) aHydraulicFile
{

   strcpy(hydraulicFile, aHydraulicFile);

   fprintf(stdout,"HabitatSetup >>>> sethydraulicFile = %s \n", hydraulicFile);
   fflush(0);


   return self;

}


- setFlowFile: (char *) aFlowFile
{
   strcpy(flowFile, aFlowFile);
   fprintf(stdout,"HabitatSetup >>>> FlowFile = %s \n", flowFile);
   return self;
}


- setTemperatureFile: (char *) aTemperatureFile
{
   strcpy(temperatureFile, aTemperatureFile);
   fprintf(stdout,"HabitatSetup >>>> TemperatureFile = %s \n", temperatureFile);
   fflush(0);
   return self;
}



- setTurbidityFile: (char *) aTurbidityFile
{
   strcpy(turbidityFile, aTurbidityFile);
   fprintf(stdout,"HabitatSetup >>>> TurbidityFile = %s \n", turbidityFile);
   fflush(0);
   return self;
}


- setCellHabVarsFile: (char *) aCellDataFile
{
   strcpy(cellHabVarsFile, aCellDataFile);
   fprintf(stdout,"HabitatSetup >>>> cellHabVarsFile = %s \n", cellHabVarsFile);
   fflush(0);
   return self;
}


- setBarrierXWith: (char *) aBarrierX
{
   double* barrierX = (double *) [[self getZone] alloc: sizeof(double)];

   if(barrierXList == nil)
   {
      barrierXList = [List create: [self getZone]];
   }

   *barrierX = atof(aBarrierX);
   [barrierXList addLast: (void *) barrierX];

   return self;
}


- (int) getHabitatIndex
{
   return habIndex;

}

- (char *) getReachName
{
   return reachName;
}


- (id <Symbol>) getReachSymbol
{
   return reachSymbol;
}

- (int) getHabDStreamJNumber
{
    return habDownStreamJunctionNumber;
}

- (int) getHabUStreamJNumber
{
    return habUpStreamJunctionNumber;
}


- (char *) getHabParamFile
{
   return habParamFile;
}


- (char *) getCellGeomFile
{
   return cellGeomFile;
}

- (char *) getHydraulicFile
{
     return hydraulicFile;
}

- (char *) getFlowFile
{
   return flowFile;
}


- (char *) getTemperatureFile
{
   return temperatureFile;
}

- (char *) getTurbidityFile
{
   return turbidityFile;

}

- (char *) getCellHabVarsFile
{
   return cellHabVarsFile;

}


- (id <List>) getBarrierXList
{
   return barrierXList;
}


/////////////////////////////////////////
//
////       Poly DATA
//////
////////
/////////////////////////////////////////
- (id <List>) getListOfPolyInputData
{
    return listOfPolyInputData;
}



/////////////////////////////////////
//
// drop
//
///////////////////////////////////
- (void) drop
{

    [barrierXList deleteAll];
    [barrierXList drop];
    barrierXList = nil;

}

@end
