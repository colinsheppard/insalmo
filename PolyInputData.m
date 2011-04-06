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

#import <stdio.h>
#import <stdlib.h>
#import "PolyInputData.h"

@implementation PolyInputData

+ create: aZone 
{
  PolyInputData* polyInputData = [super create: aZone];
 
  polyInputData->inputDataZone = [Zone create: aZone];

  return polyInputData;
}


- setPolyFlow: (double) aFlow
{
     polyFlow = aFlow;
     return self;
}


- setPolyVelocityDataFile: (char *) aVelocityDataFile
{
     strncpy(polyVelocityDataFile, aVelocityDataFile, 50);
     return self;
}

- setPolyDepthDataFile: (char *) aDepthDataFile
{
     strncpy(polyDepthDataFile, aDepthDataFile, 50);
     return self;
}



////////////////////////////////
//
// createVelocityArray
//
////////////////////////////////
- createVelocityArray
{
    FILE* fptr;
    const char* dataFile = polyVelocityDataFile;
    char inputString[100];
    int fcounter = 0;

    int numberOfNodes = 0;
    int numberOfElements = 0;

    double nodeVelocity;
    int i = 0;

    //fprintf(stdout, "PolyInputData >>>> createVelocityArray >>>> BEGIN\n");
    //fflush(0);

    if((fptr = fopen(dataFile, "r")) == NULL)
    {
         fprintf(stdout, "ERROR: PolyInputData >>>> createVelocityArray >>>> Unable to open %s for reading\n", dataFile);
         fflush(0);
         exit(1);
    }

    while(fgets(inputString, 100, fptr) != NULL)
    {
        if(strstr(inputString, "ENDDS") != NULL)
        {  
            break;
        }

        if(strstr(inputString, "DATASET") != NULL)
        {  
            continue;
        }
        if(strstr(inputString, "OBJTYPE") != NULL)
        {  
            continue;
        }
        if(strstr(inputString, "BEGSCL") != NULL)
        {  
            continue;
        }
        if(strstr(inputString, "ND") != NULL)
        {  
            char nd[2];

            sscanf(inputString, "%s %d", nd, &numberOfNodes);

            velocityArray = (double **) [inputDataZone alloc: numberOfNodes * sizeof(double *) + 1];
            
            //
            // Because the node count begins at 1, set *velocityArray[0] to -1
            //
            if(i == 0)
            {
                velocityArray[i] = (double *) [inputDataZone alloc: sizeof(double)];
                *velocityArray[i] = -1;
                i++;
            }
 
            //fprintf(stdout, "PolyInputData >>>> createVelocityArray >>>> numberOfNodes = %d\n", numberOfNodes);
            //fflush(0);

            continue;
        }
        if(strstr(inputString, "NC") != NULL)
        {  
            char nc[2];
            sscanf(inputString, "%s %d", nc, &numberOfElements);
 
            //fprintf(stdout, "PolyInputData >>>> createVelocityArray >>>> numberOfElements = %d\n", numberOfElements);
            //fflush(0);

            continue;
        }

        if(strstr(inputString, "NAME") != NULL)
        {  
            continue;
        }

        if(strstr(inputString, "TS") != NULL)
        {  
            continue;
        }


        if(fcounter == numberOfElements)
        {
            if(i > numberOfNodes)
            {
                fprintf(stderr, "ERROR: PolyInputData >>>> createVelocityArray >>>> numberOfNodes and node count mismatch\n");
                fflush(0);
                exit(1);
            }

            nodeVelocity = atof(inputString);
            velocityArray[i] = (double *) [inputDataZone alloc: sizeof(double)];

            *velocityArray[i] = 100.0*nodeVelocity;

            i++;
        }
        else
        {
            fcounter++;
            continue;
        }
    }

    if(0)
    {
        for(i = 0; i < numberOfNodes; i++)
        {

                fprintf(stdout, "PolyInputData >>>> createVelocityArray >>>> nodeVelocity = %f\n", *velocityArray[i]);
                fflush(0);
        }
    }

    //fprintf(stdout, "PolyInputData >>>> createVelocityArray >>>> END\n");
    //fflush(0);

    return self;
}


//////////////////////////////////////////
//
// createDepthArray
//
/////////////////////////////////////////
- createDepthArray
{
    FILE* fptr;
    const char* dataFile = polyDepthDataFile;
    char inputString[100];
    int fcounter = 0;

    int numberOfNodes = 0;
    int numberOfElements = 0;

    double nodeDepth;
    int i = 0;

    //fprintf(stdout, "PolyInputData >>>> createDepthArray >>>> BEGIN\n");
    //fflush(0);

    if((fptr = fopen(dataFile, "r")) == NULL)
    {
         fprintf(stdout, "ERROR: PolyInputData >>>> createDepthArray >>>> Unable to open %s for reading\n", dataFile);
         fflush(0);
         exit(1);
    }

    while(fgets(inputString, 100, fptr) != NULL)
    {
        if(strstr(inputString, "ENDDS") != NULL)
        {  
            break;
        }

        if(strstr(inputString, "DATASET") != NULL)
        {  
            continue;
        }
        if(strstr(inputString, "OBJTYPE") != NULL)
        {  
            continue;
        }
        if(strstr(inputString, "BEGSCL") != NULL)
        {  
            continue;
        }
        if(strstr(inputString, "ND") != NULL)
        {  
            char nd[2];

            sscanf(inputString, "%s %d", nd, &numberOfNodes);

            depthArray = (double **) [inputDataZone alloc: numberOfNodes * sizeof(double *) + 1];
 
            //
            // Because the node count begins at 1, set *depthArray[0] to -1
            //
            if(i == 0)
            {
                depthArray[i] = (double *) [inputDataZone alloc: sizeof(double)];
                *depthArray[i] = -1;
                i++;
            }
            //fprintf(stdout, "PolyInputData >>>> createDepthArray >>>> numberOfNodes = %d\n", numberOfNodes);
            //fflush(0);

            continue;
        }
        if(strstr(inputString, "NC") != NULL)
        {  
            char nc[2];
            sscanf(inputString, "%s %d", nc, &numberOfElements);
 
            //fprintf(stdout, "PolyInputData >>>> createDepthArray >>>> numberOfElements = %d\n", numberOfElements);
            //fflush(0);

            continue;
        }

        if(strstr(inputString, "NAME") != NULL)
        {  
            continue;
        }

        if(strstr(inputString, "TS") != NULL)
        {  
            continue;
        }


        if(fcounter == numberOfElements)
        {

            if(i > numberOfNodes)
            {
                fprintf(stderr, "ERROR: PolyInputData >>>> createDepthArray >>>> numberOfNodes and node count mismatch\n");
                fflush(0);
                exit(1);
            }

            nodeDepth = atof(inputString);
            depthArray[i] = (double *) [inputDataZone alloc: sizeof(double)];

            *depthArray[i] = 100.0 * nodeDepth;

            i++;
        }
        else
        {
            fcounter++;
            continue;
        }

    }

    if(0)
    {
        for(i = 0; i < numberOfNodes; i++)
        {

                fprintf(stdout, "PolyInputData >>>> createDepthArray >>>> nodeDepth = %f\n", *depthArray[i]);
                fflush(0);
        }
    }

    //fprintf(stdout, "PolyInputData >>>> createDepthArray >>>> END\n");
    //fflush(0);

    return self;
}


- (double) getPolyFlow
{
    return polyFlow;
}


- (char *) getPolyVelocityDataFile
{
    return polyVelocityDataFile;
}

- (char *) getPolyDepthDataFile
{
    return polyDepthDataFile;
}


- (double **) getVelocityArray
{
    return velocityArray;
}

- (double **) getDepthArray
{
    return depthArray;
}


////////////////////////////////////////////
//
// compareFlows
//
////////////////////////////////////////////
- (int) compareFlows: otherInputData
{
   int retVal;

   if(polyFlow < [otherInputData getPolyFlow])
   {
      retVal = -1;
   }
   else if(polyFlow == [otherInputData getPolyFlow])
   {
      retVal = 0;
   }
   else 
   {
      retVal = 1;
   }
      
   return retVal;
}


@end
