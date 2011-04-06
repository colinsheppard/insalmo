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



#import "HydraulicFileReader.h"

@implementation HydraulicFileReader

+ createBegin: aZone 
{ 
  HydraulicFileReader * fileReader;
  id <Map> tempMap;
  id <Array> tempArray;
  id <Symbol> tempSymbol;
  id <List> tempList;

  fileReader = [super createBegin: aZone];

  tempMap = [Map create: aZone];
  
  fileReader->hydMap = tempMap;

  tempArray = [Array createBegin: aZone];
  [tempArray setDefaultMember: nil]; 
  [tempArray setCount: 0];
  tempArray = [tempArray createEnd];

  fileReader->velArray = tempArray;


  tempArray = [Array createBegin: aZone];
  [tempArray setDefaultMember: nil]; 
  [tempArray setCount: 0];
  tempArray = [tempArray createEnd];
  fileReader->flowArray = tempArray;

  fileReader->flowCount = 0;
  fileReader->totalFlowCount = 0;
  fileReader->prevFlowCount = 0;

  tempArray = [Array createBegin: aZone];
  [tempArray setDefaultMember: nil]; 
  [tempArray setCount: 0];
  tempArray = [tempArray createEnd];
  fileReader->wslArray = tempArray;

  tempSymbol = [Symbol create: aZone setName: "FlowArray"];
  fileReader->FlowArray = tempSymbol;

  [fileReader->hydMap at: fileReader->FlowArray insert: fileReader->flowArray];

  tempList = [List create: aZone];
  fileReader->stationList = tempList;

  fileReader->firstFile = YES;

  return fileReader;

}


///////////////////////////////////////
//
// createEnd
//
///////////////////////////////////////
- createEnd
{

   //fprintf(stdout, "HydraulicFileReader >>>> createEnd >>> END\n");
   //fflush(0);

   return [super createEnd];
}

///////////////////////////////////////
// 
// getStationList
//
//////////////////////////////////////
- (id <List>) getStationList 
{
  return stationList;
}


/////////////////////////////////////////
//
// getFlowArray
//
///////////////////////////////////////
- (id <Array>) getFlowArray 
{
  return flowArray;
}

//////////////////////////////////////////
//
// checkStationOffsets
//
//////////////////////////////////////////
- checkStationOffsets 
{
  [stationList forEach: M(checkMaxOffsets)]; 
  //[stationList forEach: M(printFlowArray)]; 
  //[stationList forEach: M(printVelocityArray)]; 
  //[stationList forEach: M(printSelf)]; 

  return self;
}
  


/*
////////////////////////////////////////////////
//
// readFile
//
///////////////////////////////////////////////
- readFile: (char *) inputFile 
{
 return self;
}
*/





////////////////////////////////////////////////
//
// readFile2
//
// This is the one I'm modifying for
// the InterpolationTables
//
///////////////////////////////////////////////
- readFile2: (char *) inputFile 
{
  FILE * filePtr;
  char * aLine;
  char * aWord;
  char * aSubStr;
  char * TOKEN;
  char * DELIMITERS = " 	";   // a space and at tab
  int transect;
  double aWsl[100];
  double aVelocity;

  BOOL newFile = NO;

  aLine = (char *) [[self getZone] alloc: 300*sizeof(char)];
  aWord = (char *) [[self getZone] alloc: 300*sizeof(char)];
  TOKEN = (char *) [[self getZone] alloc: 300*sizeof(char)];

  if((filePtr = fopen(inputFile, "r" )) == NULL)  
  {
     fprintf(stderr, "ERROR: HydraulicFileReader >>>> readFile2 >>>> Cannot open %s \n", inputFile);
     fflush(stderr);
     exit(1);
  }
 
  newFile = YES;

  while(fgets(aLine, 300, filePtr) != NULL)  
  {
     if(strcmp(aLine, "\n") == 0) continue;

     if(sscanf(aLine,"%s", TOKEN)) 
     {
          if(strcmp(TOKEN, "VELOCITY") == 0) 
          {
                aSubStr = strpbrk(aLine, "0123456789");
                sscanf(aSubStr,"%d", &transect);
          }

          if((strcmp(TOKEN, "FLOW:") == 0) && (newFile == YES)) 
          {
              char * str;
              flowCount = 0;

              newFile = NO;
 
              totalFlowCount = prevFlowCount;

              aSubStr = strpbrk(aLine, ".0123456789");

              while((str = strtok(aSubStr, DELIMITERS)) ,*str != '\n') 
              {
                  double *thisFlow; 
                  aSubStr = (char *) NULL;

                  thisFlow = (double *) [ZoneAllocMapper allocBlockIn: [self getZone] ofSize: sizeof(double)];

                 *thisFlow = atof(str);

                  [flowArray setCount: totalFlowCount+1];
                  [flowArray atOffset: totalFlowCount put: (void *) thisFlow];
                  flowCount++;
                  totalFlowCount = prevFlowCount + flowCount;
              }
          }
          if(strcmp(TOKEN, "WSL:") == 0) 
          {
              char * str;
              wslCount = 0;

               aSubStr = strpbrk(aLine, ".0123456789");

               while((str = strtok(aSubStr, DELIMITERS)) ,*str != '\n') 
               {
                   aSubStr = (char *) NULL;

                   aWsl[wslCount] = atof(str);
                   wslCount++;
               }
          }
          if(strcmp(TOKEN, "Wet") == 0)
          {
             //
             // Before the station data is read reset prevStation to -1
             // This will be used t check for errors in the station data
             //
             prevStation = -1;
             continue;
          }
          if(strcmp(TOKEN, "STATION") == 0) 
          {
               char * strArray;
               char doubleArray[13];
               int length;
               int strpos;
               int i;
               int j;
               int k;
               double currStation;
               double currElev;
               int stationListOffset;
               int currDepthCount;
          
               id station=nil;
               int cellNo=1;

                  while(fgets(aLine, 300, filePtr))  
                  {  
                    sscanf(aLine,"%s", TOKEN);
                    if(strcmp(TOKEN, "Average") == 0) 
                    {
                         break;
                    }
 
                    aSubStr = aLine;
                    strArray = aLine;

                    length = strlen(strArray);

                     // Now we're in the station, elev, depth portion of the file
                     // so first get the station
                     // 
                     for(j = 0, strpos = 0, i = strpos; i < strpos + 10; j++, i++) 
                     {
                        if(strArray[i] == '\n') 
                        {
                            doubleArray[j] = '\0';
                            break;
                        }
                        doubleArray[j] = strArray[i]; 
                        doubleArray[j+1] = '\0';
                     }
                  
                    //
                    // set the station objects value of station
                    //
                    currStation = atof(doubleArray);

                    //
                    // now get the elev
                    //
                    for(j = 0, strpos = 10, i = strpos; i < strpos + 10; j++, i++) 
                    {
                       if(strArray[i] == '\n') 
                       {
                            doubleArray[j] = '\0';
                            break;
                       }
                       doubleArray[j] = strArray[i]; 
                       doubleArray[j+1] = '\0';
                    }
    
                    //
                    // and set the elev in station object
                    //
                    currElev = atof(doubleArray);

                    //
                    //  create the station objects if this is the 
                    //  first time we're reading a hydraulic file
                    //
                    if(firstFile == YES) 
                    {
                        //
                        // Check stations to ensure duplicate stations are not created
                        //
                        id <ListIndex> stationNdx = [stationList listBegin: [self getZone]];
                        id checkStation = nil;

                        while(([stationNdx getLoc] != End) && ((checkStation = [stationNdx next]) != nil))                    
                        {
                             if(([checkStation getTransect] == transect) && ([checkStation getStation] >= currStation))
                             {
                                 fprintf(stderr, "ERROR: HydraulicFileReader >>>> readFile2 >>>> attempting to create a duplicate station\n");
                                 fflush(0);
                                 exit(1);
                             }
                        }

                        [stationNdx drop];
                 
                        station = [Station createBegin: [self getZone]];
                        //station = [station createEnd];
                        [stationList addLast: station];

                        [station setCellNo: cellNo];
                        cellNo++;

                        [station setTransect: transect];

                        [station setStation: currStation];
                        [station setElev: currElev];
                        [station setBottomElev: currElev];

                     } 
                     else 
                     {
                       int s;

                       if(prevStation >= currStation)
                       {
                             fprintf(stderr, "ERROR: HydraulicFileReader >>>> readFile2 >>>> duplicate station; Check Hydraulic data\n");
                             fflush(0);
                             exit(1);
                       }

                       prevStation = currStation;
                       stationListOffset = [stationList getCount];
                   
                      for(s = 0; s < stationListOffset; s++) 
                      {
                          station = [stationList atOffset: s];
                          if(    ([station getTransect] == transect) 
                              && (fabs([station getStation] - currStation) < 0.00001) ) 
                          {
                                   break;
                          }
                      }           

                    }

                //
                // finally get all the depths and set them in the
                // station object
                //

                strpos = 21;
                currDepthCount = 0;

                while(strpos < length - 1) 
                {
                    for(j = 0, i = strpos; i < strpos + 9; i++) 
                    {
                        if(strArray[i] == '\n') 
                        {
                              doubleArray[j] = '\n';
                              break;
                        }
                        doubleArray[j] = strArray[i]; 
                        doubleArray[j+1] = '\0';
          
                        j++;
                     }

                    if(doubleArray[j] == '\n') break;

                    doubleArray[j+1]='\0';
                    aVelocity = atof(doubleArray);

                    [station addAVelocity: aVelocity atTransect: transect andStation: currStation]; 

                    [station addAWsl: aWsl[currDepthCount] atTransect: transect andStation: currStation]; 
                   
                    strpos += 8;
                    currDepthCount++;

                }

                if((currDepthCount != flowCount) && (currDepthCount != wslCount)) 
                {
                   xprint(self);
                   fprintf(stderr, "ERROR: HydraulicFileReader >>>> readFile2 >>>> array counts are different in hydraulic file\n See HydraulicFileReader.m and Hydraulic files"); 
                   fflush(0);
                   exit(1);
                }
                //
                // set the flows in the station object;
                // the station object's offset is automatically 
                // incremented
                //

                for(k = prevFlowCount; k < totalFlowCount; k++) 
                {
                    [station addAFlow: *((double *) [flowArray atOffset: k])
                           atTransect: transect
                           andStation: currStation]; 
                }
             }
          } //if STATION

      } //if TOKEN

   } //while fgets


  //
  // free up resources
  //
  [[self getZone] free: aLine];
  [[self getZone] free: aWord];
  [[self getZone] free: TOKEN];

  fclose(filePtr);

  
  //
  // Used for reading multiple files
  //
  firstFile = NO; 
  prevFlowCount += flowCount;

  return self;

} //readFile2 




@end
