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
#include <string.h>
#include <math.h>
#include <time.h>

#import "BreakoutReporter.h"

@implementation BreakoutReporter

+          createBeginWithFixedColumns: aZone
               forList: (id <List>) aListOfObj
    withOutputFilename: (char *) aFileName
     withFileOverwrite: (BOOL) aBool
       withColumnWidth: (int) aColumnWidth
{

   BreakoutReporter* reporter = [super createBegin: aZone];
   size_t fileNameLen = strlen(aFileName) + 1;
   id <Zone> myZone = [Zone create: aZone];

   if(aListOfObj == nil){
       fprintf(stderr, "ERROR: BreakoutReporter >>>> createBegin: >>>> objectList is nil\n");
       fflush(0);
       exit(1);
   }

   reporter->objectList = aListOfObj; 

   if(fileNameLen > 50){
        fprintf(stderr, "ERROR: BreakoutReporter >>>> createBegin >>>> fileName length is too long\n");
        fflush(0);
        exit(1);
   }
   strncpy(reporter->fileName, aFileName, fileNameLen);

   reporter->numberOfBreakoutLevels = 0;
   reporter->dummyKeySymbol = [Symbol create: myZone
                                        setName: "dummyKeySymbol"];

   reporter->level1ListOfKeys = [List create: myZone];
   [reporter->level1ListOfKeys addLast: reporter->dummyKeySymbol];  
   reporter->level2ListOfKeys = [List create: myZone];
   [reporter->level2ListOfKeys addLast: reporter->dummyKeySymbol];  
   reporter->level3ListOfKeys = [List create: myZone];
   [reporter->level3ListOfKeys addLast: reporter->dummyKeySymbol];  
   reporter->level4ListOfKeys = [List create: myZone];
   [reporter->level4ListOfKeys addLast: reporter->dummyKeySymbol];  
   reporter->level5ListOfKeys = [List create: myZone];
   [reporter->level5ListOfKeys addLast: reporter->dummyKeySymbol];  

   reporter->level1KeySelector = (SEL) nil;
   reporter->level2KeySelector = (SEL) nil;
   reporter->level3KeySelector = (SEL) nil;
   reporter->level4KeySelector = (SEL) nil;
   reporter->level5KeySelector = (SEL) nil;

   reporter->breakoutMap = [Map create: myZone];
   reporter->averagerMapList = [List create: myZone];
   reporter->useCSV = FALSE;
   reporter->columnWidth = aColumnWidth;
   sprintf(reporter->headerFormatString, "%s%d%s", "%-",aColumnWidth,"s");
   sprintf(reporter->floatFormatString, "%s%d%s", "%-",aColumnWidth,"f");
   sprintf(reporter->intFormatString, "%s%d%s", "%-",aColumnWidth,"d");
   sprintf(reporter->expFormatString, "%s%d%s", "%-",aColumnWidth,"E");
   fprintf(stdout, "BreakoutReport >>>>   createBegin: aZone >>>> useCSV = %d \n", (int) reporter->useCSV);
   fprintf(stdout, "BreakoutReport >>>>   headerFormatString = %s\n", reporter->headerFormatString);
   fprintf(stdout, "BreakoutReport >>>>   floatFormatString = %s\n", reporter->floatFormatString);
   fprintf(stdout, "BreakoutReport >>>>   intFormatString = %s\n", reporter->intFormatString);
   fprintf(stdout, "BreakoutReport >>>>   expFormatString = %s\n", reporter->expFormatString);

   if(aBool == TRUE){
      [reporter openFileNamed: reporter->fileName
                withWriteMode: "w"];
   }else{
      [reporter openFileNamed: reporter->fileName
                withWriteMode: "a"];
   }

   reporter->outputWithLabelsList = [List create: myZone];
   reporter->dataColumnStructList = [List create: myZone];
   reporter->dataColumnList = [List create: myZone];
   reporter->blankColumnLabelList = [List create: myZone];
   reporter->reporterZone = myZone;
   reporter->suppressColumnLabels = NO;

   return reporter;
}


+          createBeginWithCSV: aZone
               forList: (id <List>) aListOfObj
    withOutputFilename: (char *) aFileName
     withFileOverwrite: (BOOL) aBool
{
   BreakoutReporter* reporter = [super createBegin: aZone];
   size_t fileNameLen = strlen(aFileName) + 1;
   id <Zone> myZone = [Zone create: aZone];

   if(aListOfObj == nil){
       fprintf(stderr, "ERROR: BreakoutReporter >>>> createBegin: >>>> objectList is nil\n");
       fflush(0);
       exit(1);
   }

   reporter->objectList = aListOfObj; 

   if(fileNameLen > 50){
        fprintf(stderr, "ERROR: BreakoutReporter >>>> createBegin >>>> fileName length is too long\n");
        fflush(0);
        exit(1);
   }
   strncpy(reporter->fileName, aFileName, fileNameLen);

   reporter->numberOfBreakoutLevels = 0;
   reporter->dummyKeySymbol = [Symbol create: myZone
                                        setName: "dummyKeySymbol"];
   reporter->level1ListOfKeys = [List create: myZone];
   [reporter->level1ListOfKeys addLast: reporter->dummyKeySymbol];  
   reporter->level2ListOfKeys = [List create: myZone];
   [reporter->level2ListOfKeys addLast: reporter->dummyKeySymbol];  
   reporter->level3ListOfKeys = [List create: myZone];
   [reporter->level3ListOfKeys addLast: reporter->dummyKeySymbol];  
   reporter->level4ListOfKeys = [List create: myZone];
   [reporter->level4ListOfKeys addLast: reporter->dummyKeySymbol];  
   reporter->level5ListOfKeys = [List create: myZone];
   [reporter->level5ListOfKeys addLast: reporter->dummyKeySymbol];  

   reporter->level1KeySelector = (SEL) nil;
   reporter->level2KeySelector = (SEL) nil;
   reporter->level3KeySelector = (SEL) nil;
   reporter->level4KeySelector = (SEL) nil;
   reporter->level5KeySelector = (SEL) nil;
   reporter->breakoutMap = [Map create: myZone];
   reporter->averagerMapList = [List create: myZone];

   reporter->useCSV = TRUE;
   reporter->columnWidth = 25;
   sprintf(reporter->headerFormatString, "%s%s%s", "%", "s", ",");
   sprintf(reporter->floatFormatString, "%s%d%s%s", "%",reporter->columnWidth,"f", ",");

   //fprintf(stdout, "BreakoutReport >>>>   createBegin: aZone >>>> useCSV = %d \n", (int) reporter->useCSV);
   //fprintf(stdout, "BreakoutReport >>>>   headerFormatString = %s\n", reporter->headerFormatString);
   //fprintf(stdout, "BreakoutReport >>>>   floatFormatString = %s\n", reporter->floatFormatString);
   //fprintf(stdout, "BreakoutReport >>>>   test >>>>\n");
   //fprintf(stdout, reporter->headerFormatString, "testString");
   //fprintf(stdout, reporter->floatFormatString, -0.0012345678901234567890123456789012345678901234567890);
   //fprintf(stdout, reporter->floatFormatString, log10(0.00012345678901234567890123456789012345678901234567890));
   //fflush(0);
   //exit(0);
   
   if(aBool == TRUE){
      [reporter openFileNamed: reporter->fileName
                withWriteMode: "w"];
   }else{
      [reporter openFileNamed: reporter->fileName
                withWriteMode: "a"];
   }
   reporter->outputWithLabelsList = [List create: myZone];
   reporter->dataColumnStructList = [List create: myZone];
   reporter->dataColumnList = [List create: myZone];
   reporter->blankColumnLabelList = [List create: myZone];
   reporter->reporterZone = myZone;
   reporter->suppressColumnLabels = NO;
   return reporter;
}

- suppressColumnLabels: (BOOL) aBool{
   suppressColumnLabels = aBool;
   return self;
}

- createEnd
{
    level1Ndx = [level1ListOfKeys listBegin: reporterZone];
    level2Ndx = [level2ListOfKeys listBegin: reporterZone];
    level3Ndx = [level3ListOfKeys listBegin: reporterZone];
    level4Ndx = [level4ListOfKeys listBegin: reporterZone];
    level5Ndx = [level5ListOfKeys listBegin: reporterZone];

    [self buildBreakoutMap];
    [self buildAveragerMaps];
    [self buildDataColumns];
 
    if(suppressColumnLabels == NO)
    {
       [self printBreakoutReportHeader];
    }

    return [super createEnd];
}
 

- buildBreakoutMap
{

      id level1Key = nil;
      id level2Key = nil;
      id level3Key = nil;
      id level4Key = nil;
      id level5Key = nil;

      [level1Ndx setLoc: Start];
      while(([level1Ndx getLoc] != End) && ((level1Key = [level1Ndx next]) != nil))
      {
         id <Map> level2Map = [Map create: reporterZone];

         [breakoutMap at: level1Key insert: level2Map];

         [level2Ndx setLoc: Start];

         while(([level2Ndx getLoc] != End) && ((level2Key = [level2Ndx next]) != nil))
         {
              id <Map> level3Map = [Map create: reporterZone];

              [level2Map at: level2Key insert: level3Map];

              [level3Ndx setLoc: Start];

            while(([level3Ndx getLoc] != End) && ((level3Key = [level3Ndx next]) != nil))
            {
	       id <Map> level4Map = [Map create: reporterZone];

               [level3Map at: level3Key insert: level4Map];

               [level4Ndx setLoc: Start];

               while(([level4Ndx getLoc] != End) && ((level4Key = [level4Ndx next]) != nil))
               {
                  id <Map> level5Map = [Map create: reporterZone];

                  [level4Map at: level4Key insert: level5Map];

                  [level5Ndx setLoc: Start];
                  while(([level5Ndx getLoc] != End) && ((level5Key = [level5Ndx next]) != nil))
                  {
                      id <List> anObjList = [List create: reporterZone];
                     
                      [level5Map at: level5Key insert: anObjList];

                       //xprint(breakoutMap);
                       //xprint([breakoutMap at: level1Key]);

                       //xprint([[breakoutMap at: level1Key] 
                                          //at: level2Key]);

                       //xprint([[[breakoutMap at: level1Key] 
                                          //at: level2Key] 
                                          //at: level3Key]);

                       //xprint([[[[breakoutMap at: level1Key] 
                                          //at: level2Key] 
                                          //at: level3Key] 
                                          //at: level4Key]);

                       //xprint([[[[[breakoutMap at: level1Key] 
                                          //at: level2Key] 
                                          //at: level3Key] 
                                          //at: level4Key] 
                                          //at: level5Key]);


                  }
               }
            }
         }
      }


   return self;

}



- breakOutUsingSelector: (SEL) aBreakoutVariableSelector
         withListOfKeys: (id <List>) aListOfKeys
{
     id <ListIndex> ndx = [aListOfKeys listBegin: scratchZone];
     id aKey = nil; 

     numberOfBreakoutLevels++;

     switch (numberOfBreakoutLevels)
     {
        case 1:  [level1ListOfKeys removeAll];
                 while(([ndx getLoc] != End) && ((aKey = [ndx next]) != nil))
                 {
                    [level1ListOfKeys addLast: aKey];
                 }
                 level1KeySelector = aBreakoutVariableSelector;
                 break;
      
        case 2:  [level2ListOfKeys removeAll];
                 while(([ndx getLoc] != End) && ((aKey = [ndx next]) != nil))
                 {
                    [level2ListOfKeys addLast: aKey];
                 }
                 level2KeySelector = aBreakoutVariableSelector;
                 break;
      
        case 3:  [level3ListOfKeys removeAll];
                 while(([ndx getLoc] != End) && ((aKey = [ndx next]) != nil))
                 {
                    [level3ListOfKeys addLast: aKey];
                 }
                 level3KeySelector = aBreakoutVariableSelector;
                 break;
      
        case 4:  [level4ListOfKeys removeAll];
                 while(([ndx getLoc] != End) && ((aKey = [ndx next]) != nil))
                 {
                    [level4ListOfKeys addLast: aKey];
                 }
                 level4KeySelector = aBreakoutVariableSelector;
                 break;
      
        case 5:  [level5ListOfKeys removeAll];
                 while(([ndx getLoc] != End) && ((aKey = [ndx next]) != nil))
                 {
                    [level5ListOfKeys addLast: aKey];
                 }
                 level5KeySelector = aBreakoutVariableSelector;
                 break;
      
        default: fprintf(stderr, "ERROR: BreakoutReporter >>>> breakOutUsingSelector:withListOfKeys >>>> called more than 5 times\n");
                 fflush(0);
                 exit(1);
                 break;
    }

    [ndx drop];

    return self;

}

-     createOutputWithLabel: (char *) anOutputLabel
               withSelector: (SEL) anOutputVariableSelector
           withAveragerType: (char *) anAveragerType
{

      OutputWithLabel* outputLabel = (OutputWithLabel *) [reporterZone alloc: sizeof(OutputWithLabel)];

      
      strncpy(outputLabel->outputLabel, anOutputLabel, 50);
      outputLabel->outputVariableSelector = anOutputVariableSelector;
      strncpy(outputLabel->averagerType, anAveragerType, 50);

      [outputWithLabelsList addLast: (void *) outputLabel];
    
      return self;
}

- buildAveragerMaps
{

      id level1Key = nil;
      id level2Key = nil;
      id level3Key = nil;
      id level4Key = nil;
      id level5Key = nil;

      int i;


      for(i = 0; i < [outputWithLabelsList getCount]; i++)
      {
        
      OutputWithLabel* outputLabel = (OutputWithLabel *) [outputWithLabelsList atOffset: i];
      char * anOutputLabel = outputLabel->outputLabel; 
      SEL anOutputVariableSelector = outputLabel->outputVariableSelector;
      char * anAveragerType = outputLabel->averagerType;

      id <Map> averagerMapLevel1 = [Map create: reporterZone];
      [averagerMapList addLast: averagerMapLevel1];

      [level1Ndx setLoc: Start];

      while(([level1Ndx getLoc] != End) && ((level1Key = [level1Ndx next]) != nil))
      {
         id <Map> averagerMapLevel2 = [Map create: reporterZone];
         [averagerMapLevel1 at: level1Key insert: averagerMapLevel2];

         [level2Ndx setLoc: Start];

         while(([level2Ndx getLoc] != End) && ((level2Key = [level2Ndx next]) != nil))
         {
              id <Map> averagerMapLevel3 = [Map create: reporterZone];
              [averagerMapLevel2 at: level2Key insert: averagerMapLevel3];

              [level3Ndx setLoc: Start];

            while(([level3Ndx getLoc] != End) && ((level3Key = [level3Ndx next]) != nil))
            {
                 id <Map> averagerMapLevel4 = [Map create: reporterZone];
                 [averagerMapLevel3 at: level3Key insert: averagerMapLevel4];
                 [level4Ndx setLoc: Start];

               while(([level4Ndx getLoc] != End) && ((level4Key = [level4Ndx next]) != nil))
               {
                    id <Map> averagerMapLevel5 = [Map create: reporterZone];
                    [averagerMapLevel4 at: level4Key insert: averagerMapLevel5];
                    [level5Ndx setLoc: Start];

                  while(([level5Ndx getLoc] != End) && ((level5Key = [level5Ndx next]) != nil))
                  {
                       BreakoutAverager* anAverager = [BreakoutAverager createBegin: reporterZone];
                       [anAverager setCollection: [[[[[breakoutMap at: level1Key] 
                                                                   at: level2Key] 
                                                                   at: level3Key] 
                                                                   at: level4Key] 
                                                                   at: level5Key]];

                       [anAverager setProbedSelector: anOutputVariableSelector];
                       
                       [anAverager setOutputLabel: anOutputLabel];
                       [anAverager setAveragerType: anAveragerType];
                       anAverager = [anAverager createEnd];
                      
                       [averagerMapLevel5 at: level5Key insert: anAverager]; 

                  }
               }
            }
         }
      }

      }

      return self;
}




- addColumnWithValueOfVariable: (const char *) aDataVariable
                    fromObject: (id) aDataObject
                      withType: (char *) aDataType
                     withLabel: (char *) aDataLabel
{

   DataColumnWithLabel* dataColumnWithLabel = (DataColumnWithLabel *) [reporterZone alloc: sizeof(DataColumnWithLabel)];

   dataColumnWithLabel->isVarProbe = TRUE;
   strncpy(dataColumnWithLabel->dataVariable, aDataVariable, 50);
   dataColumnWithLabel->dataObject = aDataObject; 
   strncpy(dataColumnWithLabel->dataLabel, aDataLabel, 50);
   strncpy(dataColumnWithLabel->dataType, aDataType, 50);

   [dataColumnStructList addLast: (void *) dataColumnWithLabel];




   

   return self;
}

- addColumnWithValueFromSelector: (SEL) aDataSelector
                      fromObject: (id) aDataObject
                        withType: (char *) aDataType
                       withLabel: (char *) aDataLabel;
{
   
   DataColumnWithLabel* dataColumnWithLabel = (DataColumnWithLabel *) [reporterZone alloc: sizeof(DataColumnWithLabel)];


   dataColumnWithLabel->isVarProbe = FALSE;
   strncpy(dataColumnWithLabel->dataLabel, aDataLabel, 50);
   dataColumnWithLabel->dataObject = aDataObject; 
   dataColumnWithLabel->dataSelector = aDataSelector;
   strncpy(dataColumnWithLabel->dataType, aDataType, 50);

   [dataColumnStructList addLast: (void *) dataColumnWithLabel];

   return self;
}


- buildDataColumns
{
   int i;

   for(i = 0; i < [dataColumnStructList getCount]; i++)
   {

       char* blankLabel = (char *) [reporterZone alloc: (size_t) 4];

       DataColumnWithLabel* dataColumnStruct = (DataColumnWithLabel *) [dataColumnStructList atOffset: i];

       if(dataColumnStruct->isVarProbe == TRUE)
       {
           BreakoutVarProbe* dataColumn;

           char* aDataVariable = dataColumnStruct->dataVariable;
           char* aDataLabel = dataColumnStruct->dataLabel;
           id aDataObject = dataColumnStruct->dataObject;
           char* aDataType = dataColumnStruct->dataType;

           strncpy(blankLabel, "***", (size_t) 4);
           [blankColumnLabelList addLast: (void *) blankLabel];


           dataColumn =  [BreakoutVarProbe createBegin: reporterZone];
           [dataColumn setProbedClass: [aDataObject class]];
           [dataColumn setProbedVariable: aDataVariable];
           [dataColumn setNonInteractive];

           [dataColumn setIsVarProbe: dataColumnStruct->isVarProbe];
           [dataColumn setColumnLabel: aDataLabel];
           [dataColumn setDataObject: aDataObject];

           [dataColumn setDataColumnWidth: columnWidth];
           [dataColumn setUseCSV: useCSV];
           [dataColumn setDataType: aDataType];
    
           dataColumn = [dataColumn createEnd];
    
           [dataColumnList addLast: dataColumn];
    
           totalDataColumnWidth += columnWidth;

           sprintf(totalDataColumnWidthStr, "%s%d%s", "%-", totalDataColumnWidth, "s");

       }
       else if(dataColumnStruct->isVarProbe == FALSE)
       {
           BreakoutMessageProbe* dataColumn;
           char* aDataLabel = dataColumnStruct->dataLabel;
           id aDataObject = dataColumnStruct->dataObject;
           SEL aDataSelector = dataColumnStruct->dataSelector;
           char* aDataType = dataColumnStruct->dataType;

           strncpy(blankLabel, "***", (size_t) 4);
           [blankColumnLabelList addLast: (void *) blankLabel];

           dataColumn = [BreakoutMessageProbe create: reporterZone
                                   setProbedSelector: aDataSelector
                                       setDataObject: aDataObject];
    
   
           [dataColumn setIsVarProbe: dataColumnStruct->isVarProbe];
           [dataColumn setColumnLabel: aDataLabel];

           [dataColumn setDataColumnWidth: columnWidth];
           [dataColumn setUseCSV: useCSV];
           [dataColumn setDataType: aDataType];
    
           dataColumn = [dataColumn createEnd];
    
           [dataColumnList addLast: dataColumn];
    
           totalDataColumnWidth += columnWidth;

           sprintf(totalDataColumnWidthStr, "%s%d%s", "%-", totalDataColumnWidth, "s");
       }
   }

   return self;
}

- updateByReplacement
{

      id level1Key = nil;
      id level2Key = nil;
      id level3Key = nil;
      id level4Key = nil;
      id level5Key = nil;

      [level1Ndx setLoc: Start];
      while(([level1Ndx getLoc] != End) && ((level1Key = [level1Ndx next]) != nil))
      {
         [level2Ndx setLoc: Start];
         while(([level2Ndx getLoc] != End) && ((level2Key = [level2Ndx next]) != nil))
         {
              [level3Ndx setLoc: Start];
            while(([level3Ndx getLoc] != End) && ((level3Key = [level3Ndx next]) != nil))
            {
               [level4Ndx setLoc: Start];
               while(([level4Ndx getLoc] != End) && ((level4Key = [level4Ndx next]) != nil))
               {
                  [level5Ndx setLoc: Start];
                  while(([level5Ndx getLoc] != End) && ((level5Key = [level5Ndx next]) != nil))
                  {
                      [[[[[[breakoutMap    at: level1Key]
                                           at: level2Key]
                                           at: level3Key]
                                           at: level4Key]
                                           at: level5Key] 
                                               removeAll];
                  }
               }
            }
         }
      }


  [self updateByAccumulation];

  return self;


}

- updateByAccumulation
{
   
      id <ListIndex> ndx = [objectList listBegin: scratchZone];
      id obj = nil;

      id level1Key = dummyKeySymbol;
      id level2Key = dummyKeySymbol;
      id level3Key = dummyKeySymbol;
      id level4Key = dummyKeySymbol;
      id level5Key = dummyKeySymbol;


      if([objectList getCount] > 0)
      {
           [self checkBreakoutSelectorsFor: [objectList getFirst]];
      }

      
      switch (numberOfBreakoutLevels)
      {
        
         case 0:  while(([ndx getLoc] != End) && ((obj = [ndx next]) != nil))
                  {
                        [[[[[[breakoutMap at: level1Key] 
                                          at: level2Key] 
                                          at: level3Key] 
                                          at: level4Key] 
                                          at: level5Key] 
                                     addLast: obj];
                  }
                  break;
         case 1:  while(([ndx getLoc] != End) && ((obj = [ndx next]) != nil))
                  {
                       level1Key = [obj perform: level1KeySelector];
                       [[[[[[breakoutMap at: level1Key] 
                                         at: level2Key] 
                                         at: level3Key] 
                                         at: level4Key] 
                                         at: level5Key] 
                                    addLast: obj];
                  }
                  break;
         case 2:  while(([ndx getLoc] != End) && ((obj = [ndx next]) != nil))
                  {
                       level1Key = [obj perform: level1KeySelector];
                       level2Key = [obj perform: level2KeySelector];
                       [[[[[[breakoutMap at: level1Key] 
                                         at: level2Key] 
                                         at: level3Key] 
                                         at: level4Key] 
                                         at: level5Key] 
                                    addLast: obj];
                  }
                  break;
         case 3:  while(([ndx getLoc] != End) && ((obj = [ndx next]) != nil))
                  {
                       level1Key = [obj perform: level1KeySelector];
                       level2Key = [obj perform: level2KeySelector];
                       level3Key = [obj perform: level3KeySelector];
                       [[[[[[breakoutMap at: level1Key] 
                                         at: level2Key] 
                                         at: level3Key] 
                                         at: level4Key] 
                                         at: level5Key]
                                    addLast: obj];


                  }
                  break;
         case 4:  while(([ndx getLoc] != End) && ((obj = [ndx next]) != nil))
                  {
                       level1Key = [obj perform: level1KeySelector];
                       level2Key = [obj perform: level2KeySelector];
                       level3Key = [obj perform: level3KeySelector];
                       level4Key = [obj perform: level4KeySelector];
                       [[[[[[breakoutMap at: level1Key] 
                                         at: level2Key] 
                                         at: level3Key] 
                                         at: level4Key] 
                                         at: level5Key] 
                                    addLast: obj];
                   }
                  break;
         case 5:  while(([ndx getLoc] != End) && ((obj = [ndx next]) != nil))
                  {
                       level1Key = [obj perform: level1KeySelector];
                       level2Key = [obj perform: level2KeySelector];
                       level3Key = [obj perform: level3KeySelector];
                       level4Key = [obj perform: level4KeySelector];
                       level5Key = [obj perform: level5KeySelector];
                       [[[[[[breakoutMap at: level1Key] 
                                         at: level2Key] 
                                         at: level3Key] 
                                         at: level4Key] 
                                         at: level5Key] 
                                    addLast: obj];
                  }
                  break;
           default:
                  fprintf(stderr, "ERROR: BreakoutReporter >>>> update >>>> numberOfBreakoutLevels exceeded\n");
                  fflush(0);
                  exit(1);
                  break;

       }

       [ndx drop];

  return self;
}


-   openFileNamed: (char *) aFileName
    withWriteMode: (char *) aWriteMode
{
    if((filePtr = fopen(fileName, aWriteMode)) == NULL)
    { 
         fprintf(stderr, "ERROR: BreakoutReporter >>>> openFileNamed:withWriteMode: >>>> Cannot open file named %s\n", fileName);
         fflush(0);
         exit(1);
    }

    return self;
}


- printBreakoutReportHeader
{

      id level1Key = nil;
      id level2Key = nil;
      id level3Key = nil;
      id level4Key = nil;
      id level5Key = nil;
      BOOL printLn = FALSE;
      int i;

      char sysDateAndTime[35];
      struct tm *timeStruct;
      time_t aTime;

      aTime = time(NULL);
      timeStruct = localtime(&aTime);
      strftime(sysDateAndTime, 35, "%a %d-%b-%Y %H:%M:%S", timeStruct) ;

      fprintf(filePtr, "\n");
      fprintf(filePtr, "Model Run System Date and Time: %s\n", sysDateAndTime); 
      fprintf(filePtr, "\n");
      fflush(0);
  
      for(i = 0; i < [dataColumnList getCount]; i++)
      {
          fprintf(filePtr, headerFormatString, [[dataColumnList atOffset: i] getColumnLabel]);
          fflush(filePtr);
      }

      for(i = 0; i < [averagerMapList getCount]; i++)
      {
      [level1Ndx setLoc: Start];
      while(([level1Ndx getLoc] != End) && ((level1Key = [level1Ndx next]) != nil))
      {
         [level2Ndx setLoc: Start];
         while(([level2Ndx getLoc] != End) && ((level2Key = [level2Ndx next]) != nil))
         {
            [level3Ndx setLoc: Start];
            while(([level3Ndx getLoc] != End) && ((level3Key = [level3Ndx next]) != nil))
            {
               [level4Ndx setLoc: Start];
               while(([level4Ndx getLoc] != End) && ((level4Key = [level4Ndx next]) != nil))
               {
                  [level5Ndx setLoc: Start];
                  while(([level5Ndx getLoc] != End) && ((level5Key = [level5Ndx next]) != nil))
                  {
                        const char* level1KeyName = [level1Key getName];
                        if((id) level1Key != (id) dummyKeySymbol)
                        {
                           fprintf(filePtr, headerFormatString, level1KeyName);
                           fflush(filePtr);
                           printLn = TRUE;
                        }
                  }
               }
            }
         }
      }
      }
  
      if(printLn == TRUE)
      {
          if(useCSV == TRUE)
          {
             //
             // go back one character and overwrite trailing ',' with a \n
             //
             long filePos = 0;
             if((filePos = ftell(filePtr)) != (long) -1)
             {
                 filePos = filePos - 1;
                 if(fseek(filePtr, filePos, 0) != 0)
                 {
                     fprintf(stderr, "BreakoutReporter >>>>  printBreakoutReportHeader >>>> ERROR: cannot reset output file position\n");
                     fflush(0);
                     exit(1);
                 }

              }
              else
              {
                    fprintf(stderr, "BreakoutReporter >>>> printBreakoutReportHeader >>>> ERROR: cannot get output file position\n");
                    fflush(0);
                    exit(1);
              }
          } //if useCSV

          fprintf(filePtr, "\n"); 
          for(i = 0; i < [blankColumnLabelList getCount]; i++)
          {
              fprintf(filePtr, headerFormatString, (char *) [blankColumnLabelList atOffset: i]);
              fflush(filePtr);
          }
      } 

      printLn = FALSE;
     
      for(i = 0; i < [averagerMapList getCount]; i++)
      {
      [level1Ndx setLoc: Start];
      while(([level1Ndx getLoc] != End) && ((level1Key = [level1Ndx next]) != nil))
      {
         [level2Ndx setLoc: Start];
         while(([level2Ndx getLoc] != End) && ((level2Key = [level2Ndx next]) != nil))
         {
            [level3Ndx setLoc: Start];
            while(([level3Ndx getLoc] != End) && ((level3Key = [level3Ndx next]) != nil))
            {
               [level4Ndx setLoc: Start];
               while(([level4Ndx getLoc] != End) && ((level4Key = [level4Ndx next]) != nil))
               {
                  [level5Ndx setLoc: Start];
                  while(([level5Ndx getLoc] != End) && ((level5Key = [level5Ndx next]) != nil))
                  {
                        const char* level2KeyName = [level2Key getName];
                        if((id) level2Key != (id) dummyKeySymbol)
                        {
                            fprintf(filePtr, headerFormatString, level2KeyName);
                            fflush(filePtr);
                            printLn = TRUE;
                        }
                  }
               }
            }
         }
      }
      }
  
      if(printLn == TRUE)
      {
          if(useCSV == TRUE)
          {
             //
             // go back one character and in order to 
             // overwrite trailing ',' with a \n
             //
             long filePos = 0;
             if((filePos = ftell(filePtr)) != (long) -1)
             {
                 filePos = filePos - 1;
                 if(fseek(filePtr, filePos, 0) != 0)
                 {
                     fprintf(stderr, "BreakoutReporter >>>>  printBreakoutReportHeader >>>> ERROR: cannot reset output file position\n");
                     fflush(0);
                     exit(1);
                 }

              }
              else
              {
                    fprintf(stderr, "BreakoutReporter >>>> printBreakoutReportHeader >>>> ERROR: cannot get output file position\n");
                    fflush(0);
                    exit(1);
              }
          } //if useCSV

          fprintf(filePtr, "\n"); 
          for(i = 0; i < [blankColumnLabelList getCount]; i++)
          {
              fprintf(filePtr, headerFormatString, (char *) [blankColumnLabelList atOffset: i]);
              fflush(filePtr);
          }
          //fprintf(filePtr, totalDataColumnWidthStr, "*");
          //fflush(filePtr);      
      } 
 
      printLn = FALSE;
      
      for(i = 0; i < [averagerMapList getCount]; i++)
      {
      [level1Ndx setLoc: Start];
      while(([level1Ndx getLoc] != End) && ((level1Key = [level1Ndx next]) != nil))
      {
         [level2Ndx setLoc: Start];
         while(([level2Ndx getLoc] != End) && ((level2Key = [level2Ndx next]) != nil))
         {
            [level3Ndx setLoc: Start];
            while(([level3Ndx getLoc] != End) && ((level3Key = [level3Ndx next]) != nil))
            {
               [level4Ndx setLoc: Start];
               while(([level4Ndx getLoc] != End) && ((level4Key = [level4Ndx next]) != nil))
               {
                  [level5Ndx setLoc: Start];
                  while(([level5Ndx getLoc] != End) && ((level5Key = [level5Ndx next]) != nil))
                  {
                        const char* level3KeyName = [level3Key getName];
                        if((id) level3Key != (id) dummyKeySymbol)
                        {
                            fprintf(filePtr, headerFormatString, level3KeyName);
                            fflush(filePtr);
                            printLn = TRUE;
                        }
                  }
               }
            }
         }
      }
      }

  
      if(printLn == TRUE)
      {
          if(useCSV == TRUE)
          {
             //
             // go back one character and in order to 
             // overwrite trailing ',' with a \n
             //
             long filePos = 0;
             if((filePos = ftell(filePtr)) != (long) -1)
             {
                 filePos = filePos - 1;
                 if(fseek(filePtr, filePos, 0) != 0)
                 {
                     fprintf(stderr, "BreakoutReporter >>>>  printBreakoutReportHeader >>>> ERROR: cannot reset output file position\n");
                     fflush(0);
                     exit(1);
                 }

              }
              else
              {
                    fprintf(stderr, "BreakoutReporter >>>> printBreakoutReportHeader >>>> ERROR: cannot get output file position\n");
                    fflush(0);
                    exit(1);
              }
          } //if useCSV
          fprintf(filePtr, "\n"); 
          for(i = 0; i < [blankColumnLabelList getCount]; i++)
          {
              fprintf(filePtr, headerFormatString, (char *) [blankColumnLabelList atOffset: i]);
              fflush(filePtr);
          }
      } 
 
      printLn = FALSE;

      for(i = 0; i < [averagerMapList getCount]; i++)
      {
      [level1Ndx setLoc: Start];
      while(([level1Ndx getLoc] != End) && ((level1Key = [level1Ndx next]) != nil))
      {
         [level2Ndx setLoc: Start];
         while(([level2Ndx getLoc] != End) && ((level2Key = [level2Ndx next]) != nil))
         {
            [level3Ndx setLoc: Start];
            while(([level3Ndx getLoc] != End) && ((level3Key = [level3Ndx next]) != nil))
            {
               [level4Ndx setLoc: Start];
               while(([level4Ndx getLoc] != End) && ((level4Key = [level4Ndx next]) != nil))
               {
                  [level5Ndx setLoc: Start];
                  while(([level5Ndx getLoc] != End) && ((level5Key = [level5Ndx next]) != nil))
                  {
                        const char* level4KeyName = [level4Key getName];
                        if((id) level4Key != (id) dummyKeySymbol)
                        {
                            fprintf(filePtr, headerFormatString, level4KeyName);
                            fflush(filePtr);
                            printLn = TRUE;
                        }
                  }
               }
            }
         }
      }
      }

  
      if(printLn == TRUE)
      {
          if(useCSV == TRUE)
          {
             //
             // go back one character and in order to 
             // overwrite trailing ',' with a \n
             //
             long filePos = 0;
             if((filePos = ftell(filePtr)) != (long) -1)
             {
                 filePos = filePos - 1;
                 if(fseek(filePtr, filePos, 0) != 0)
                 {
                     fprintf(stderr, "BreakoutReporter >>>>  printBreakoutReportHeader >>>> ERROR: cannot reset output file position\n");
                     fflush(0);
                     exit(1);
                 }

              }
              else
              {
                    fprintf(stderr, "BreakoutReporter >>>> printBreakoutReportHeader >>>> ERROR: cannot get output file position\n");
                    fflush(0);
                    exit(1);
              }
          } //if useCSV
          fprintf(filePtr, "\n"); 
          for(i = 0; i < [blankColumnLabelList getCount]; i++)
          {
              fprintf(filePtr, headerFormatString, (char *) [blankColumnLabelList atOffset: i]);
              fflush(filePtr);
          }
      } 

      printLn = FALSE; 

      for(i = 0; i < [averagerMapList getCount]; i++)
      {
      [level1Ndx setLoc: Start];
      while(([level1Ndx getLoc] != End) && ((level1Key = [level1Ndx next]) != nil))
      {
         [level2Ndx setLoc: Start];
         while(([level2Ndx getLoc] != End) && ((level2Key = [level2Ndx next]) != nil))
         {
            [level3Ndx setLoc: Start];
            while(([level3Ndx getLoc] != End) && ((level3Key = [level3Ndx next]) != nil))
            {
               [level4Ndx setLoc: Start];
               while(([level4Ndx getLoc] != End) && ((level4Key = [level4Ndx next]) != nil))
               {
                  [level5Ndx setLoc: Start];
                  while(([level5Ndx getLoc] != End) && ((level5Key = [level5Ndx next]) != nil))
                  {
                        const char* level5KeyName = [level5Key getName];
                        if((id) level5Key != (id) dummyKeySymbol)
                        {
                            fprintf(filePtr, headerFormatString, level5KeyName);
                            fflush(filePtr);
                            printLn = TRUE;
                        }
                  }
               }
            }
         }
      }
      }

      if(printLn == TRUE)
      {
          if(useCSV == TRUE)
          {
             //
             // go back one character and in order to 
             // overwrite trailing ',' with a \n
             //
             long filePos = 0;
             if((filePos = ftell(filePtr)) != (long) -1)
             {
                 filePos = filePos - 1;
                 if(fseek(filePtr, filePos, 0) != 0)
                 {
                     fprintf(stderr, "BreakoutReporter >>>>  printBreakoutReportHeader >>>> ERROR: cannot reset output file position\n");
                     fflush(0);
                     exit(1);
                 }

              }
              else
              {
                    fprintf(stderr, "BreakoutReporter >>>> printBreakoutReportHeader >>>> ERROR: cannot get output file position\n");
                    fflush(0);
                    exit(1);
              }
          } //if useCSV
          fprintf(filePtr, "\n"); 
          for(i = 0; i < [blankColumnLabelList getCount]; i++)
          {
              fprintf(filePtr, headerFormatString, (char *) [blankColumnLabelList atOffset: i]);
              fflush(filePtr);
          }
      } 

      printLn = FALSE;

      for(i = 0; i < [averagerMapList getCount]; i++)
      {
      id <Map> anAveragerMap = [averagerMapList atOffset: i];
      [level1Ndx setLoc: Start];
      while(([level1Ndx getLoc] != End) && ((level1Key = [level1Ndx next]) != nil))
      {
         [level2Ndx setLoc: Start];
         while(([level2Ndx getLoc] != End) && ((level2Key = [level2Ndx next]) != nil))
         {
            [level3Ndx setLoc: Start];
            while(([level3Ndx getLoc] != End) && ((level3Key = [level3Ndx next]) != nil))
            {
               [level4Ndx setLoc: Start];
               while(([level4Ndx getLoc] != End) && ((level4Key = [level4Ndx next]) != nil))
               {
                  [level5Ndx setLoc: Start];
                  while(([level5Ndx getLoc] != End) && ((level5Key = [level5Ndx next]) != nil))
                  {
                        BreakoutAverager* anAverager = [[[[[anAveragerMap at: level1Key]
                                                                          at: level2Key]
                                                                          at: level3Key]
                                                                          at: level4Key]
                                                                          at: level5Key];

                        fprintf(filePtr, headerFormatString, [anAverager getOutputLabel]);
                        fflush(filePtr);
                  }
               }
            }
         }
      }
      }

          if(useCSV == TRUE)
          {
             //
             // go back one character and in order to 
             // overwrite trailing ',' with a \n
             //
             long filePos = 0;
             if((filePos = ftell(filePtr)) != (long) -1)
             {
                 filePos = filePos - 1;
                 if(fseek(filePtr, filePos, 0) != 0)
                 {
                     fprintf(stderr, "BreakoutReporter >>>>  printBreakoutReportHeader >>>> ERROR: cannot reset output file position\n");
                     fflush(0);
                     exit(1);
                 }

              }
              else
              {
                    fprintf(stderr, "BreakoutReporter >>>> printBreakoutReportHeader >>>> ERROR: cannot get output file position\n");
                    fflush(0);
                    exit(1);
              }
          } //if useCSV
      fprintf(filePtr, "\n");  
 
      return self;

}




- checkBreakoutMap
{
   id level1Key = nil;
   id level2Key = nil;
   id level3Key = nil;
   id level4Key = nil;
   id level5Key = nil;

   [level1Ndx setLoc: Start];
   while(([level1Ndx getLoc] != End) && ((level1Key = [level1Ndx next]) != nil))
          {

             [level2Ndx setLoc: Start];
             while(([level2Ndx getLoc] != End) && ((level2Key = [level2Ndx next]) != nil))
             {
                [level3Ndx setLoc: Start];
                while(([level3Ndx getLoc] != End) && ((level3Key = [level3Ndx next]) != nil))
                {
                   [level4Ndx setLoc: Start];
                   while(([level4Ndx getLoc] != End) && ((level4Key = [level4Ndx next]) != nil))
                   {
                      [level5Ndx setLoc: Start];
                      while(([level5Ndx getLoc] != End) && ((level5Key = [level5Ndx next]) != nil))
                      {
                          xprint(breakoutMap);
                          xprint([breakoutMap at: level1Key]);
                          xprint([[breakoutMap at: level1Key]
                                               at: level2Key]);
                          xprint([[[breakoutMap at: level1Key]
                                               at: level2Key]
                                               at: level3Key]);
                          xprint([[[[breakoutMap at: level1Key]
                                                 at: level2Key]
                                                 at: level3Key]
                                                 at: level4Key]);
                          xprint([[[[[breakoutMap at: level1Key]
                                                  at: level2Key]
                                                  at: level3Key]
                                                  at: level4Key]
                                                  at: level5Key]);
                      }                           
                   }
                }
             }
          }


   return self;

}


- output
{
      id <ListIndex> ndx = [averagerMapList listBegin: scratchZone];
      id <Map> anAveragerMap = nil;

      id level1Key = nil;
      id level2Key = nil;
      id level3Key = nil;
      id level4Key = nil;
      id level5Key = nil;

      int i;
      double aVal;

      for(i = 0; i < [dataColumnList getCount]; i++)
      {
         id dataColumn =  [dataColumnList atOffset: i];

         if([dataColumn getIsVarProbe] == TRUE)
         {
             if(strcmp([dataColumn getDataType],"id") == 0)
             {
                char* aFormatString = [dataColumn getFormatString];
                fprintf(filePtr, aFormatString, [dataColumn probeObject: [dataColumn getDataObject]]);
             }
             if(strcmp([dataColumn getDataType],"double") == 0)
             {
                char* aFormatString = [dataColumn getFormatString];
                fprintf(filePtr, aFormatString, [dataColumn probeAsDouble: [dataColumn getDataObject]]);
             }
             if(strcmp([dataColumn getDataType],"int") == 0)
             {
                char* aFormatString = [dataColumn getFormatString];
                fprintf(filePtr, aFormatString, [dataColumn probeAsInt: [dataColumn getDataObject]]);
             }
             if(strcmp([dataColumn getDataType],"string") == 0)
             {
                char* aFormatString = [dataColumn getFormatString];
                fprintf(filePtr, aFormatString, [dataColumn probeAsString]);
             }
         }
         else if([dataColumn getIsVarProbe] == FALSE)
         {
             if(strcmp([dataColumn getDataType],"id") == 0)
             {
                char* aFormatString = [dataColumn getFormatString];
                fprintf(filePtr, aFormatString, [dataColumn objectDynamicCallOn: [dataColumn getDataObject]]);
             }
             if(strcmp([dataColumn getDataType],"double") == 0)
             {
                char* aFormatString = [dataColumn getFormatString];
                fprintf(filePtr, aFormatString, [dataColumn doubleDynamicCallOn: [dataColumn getDataObject]]);
             }
             if(strcmp([dataColumn getDataType],"long") == 0)
             {
                char* aFormatString = [dataColumn getFormatString];
                fprintf(filePtr, aFormatString, [dataColumn longDynamicCallOn: [dataColumn getDataObject]]);
             }
             if(strcmp([dataColumn getDataType],"string") == 0)
             {
                char* aFormatString = [dataColumn getFormatString];
                fprintf(filePtr, aFormatString, [dataColumn stringDynamicCallOn: [dataColumn getDataObject]]);
             }
           }
      }

      while(([ndx getLoc] != End) && ((anAveragerMap = [ndx next]) != nil))
      {

          [level1Ndx setLoc: Start];
          while(([level1Ndx getLoc] != End) && ((level1Key = [level1Ndx next]) != nil))
          {

             [level2Ndx setLoc: Start];
             while(([level2Ndx getLoc] != End) && ((level2Key = [level2Ndx next]) != nil))
             {
                [level3Ndx setLoc: Start];
                while(([level3Ndx getLoc] != End) && ((level3Key = [level3Ndx next]) != nil))
                {
                   [level4Ndx setLoc: Start];
                   while(([level4Ndx getLoc] != End) && ((level4Key = [level4Ndx next]) != nil))
                   {
                      [level5Ndx setLoc: Start];
                      while(([level5Ndx getLoc] != End) && ((level5Key = [level5Ndx next]) != nil))
                      {
                           BreakoutAverager* anAverager;
                           
                           anAverager = [[[[[anAveragerMap at: level1Key]
                                                           at: level2Key]
                                                           at: level3Key]
                                                           at: level4Key]
                                                           at: level5Key];
                           [anAverager update];

			  aVal = [anAverager getAveragerValue];
			  if(aVal==(double)(int)aVal){
			    if(useCSV == TRUE){
			      fprintf(filePtr, "%d,",(int)aVal);
			    }else{
			      fprintf(filePtr, intFormatString,(int)aVal);
			    }
			  }else{
			    if(aVal == 0.0){
				   fprintf(filePtr, floatFormatString,aVal);
			    }else if(aVal < 0.0){
				    if(log10(-aVal) < -3.0){
				      if(useCSV == TRUE){
					   fprintf(filePtr,"%E,",aVal);
				      }else{
				        fprintf(filePtr,expFormatString,aVal);
				      }
				    }else{
				      fprintf(filePtr, floatFormatString,aVal);
				    }
			    }else if(log10(aVal) < -3.0){
			      if(useCSV == TRUE){
				   fprintf(filePtr,"%E,",aVal);
			      }else{
				fprintf(filePtr,expFormatString,aVal);
			      }
			    }else{
				   fprintf(filePtr, floatFormatString,aVal);
			    }
			  }
                           fflush(filePtr);
                      }                           
                   }
                }
             }
          }

      } //while ndx

      if(useCSV == TRUE)
      {
          //
          // go back one character and in order to 
          // overwrite trailing ',' with a \n
          //
          long filePos = 0;
          if((filePos = ftell(filePtr)) != (long) -1)
          {
              filePos = filePos - 1;
              if(fseek(filePtr, filePos, 0) != 0)
              {
                  fprintf(stderr, "BreakoutReporter >>>>  printBreakoutReportHeader >>>> ERROR: cannot reset output file position\n");
                  fflush(0);
                  exit(1);
              }

          }
          else
          {
                fprintf(stderr, "BreakoutReporter >>>> printBreakoutReportHeader >>>> ERROR: cannot get output file position\n");
                fflush(0);
                exit(1);
          }
      } //if useCSV

      fprintf(filePtr, "\n");
      fflush(filePtr);

      [ndx drop];

      return self;
}


- checkBreakoutSelectorsFor: anObj
{

  SEL badSelector = (SEL) nil;

  switch (numberOfBreakoutLevels)
  {

     case 0: break;

     case 1: if([anObj respondsTo: level1KeySelector] == FALSE)
             {
                badSelector = level1KeySelector;
                break;
             }

             break;

     case 2: if([anObj respondsTo: level1KeySelector] == FALSE)
             {
                badSelector = level1KeySelector;
                break;
             }
             else if([anObj respondsTo: level2KeySelector] == FALSE)
             {
                badSelector = level2KeySelector;
                break;
             }

             break;

     case 3: if([anObj respondsTo: level1KeySelector] == FALSE)
             {
                badSelector = level1KeySelector;
                break;
             }
             else if([anObj respondsTo: level2KeySelector] == FALSE)
             {
                badSelector = level2KeySelector;
                break;
             }
             else if([anObj respondsTo: level3KeySelector] == FALSE)
             {
                badSelector = level3KeySelector;
                break;
             }

             break;

     case 4: if([anObj respondsTo: level1KeySelector] == FALSE)
             {
                badSelector = level1KeySelector;
                break;
             }
             else if([anObj respondsTo: level2KeySelector] == FALSE)
             {
                badSelector = level2KeySelector;
                break;
             }
             else if([anObj respondsTo: level3KeySelector] == FALSE)
             {
                badSelector = level3KeySelector;
                break;
             }
             else if([anObj respondsTo: level4KeySelector] == FALSE)
             {
                badSelector = level4KeySelector;
                break;
             }
             
             break;

     case 5: if([anObj respondsTo: level1KeySelector] == FALSE)
             {
                badSelector = level1KeySelector;
                break;
             }
             else if([anObj respondsTo: level2KeySelector] == FALSE)
             {
                badSelector = level2KeySelector;
                break;
             }
             else if([anObj respondsTo: level3KeySelector] == FALSE)
             {
                badSelector = level3KeySelector;
                break;
             }
             else if([anObj respondsTo: level4KeySelector] == FALSE)
             {
                badSelector = level4KeySelector;
                break;
             }
             else if([anObj respondsTo: level5KeySelector] == FALSE)
             {
                badSelector = level5KeySelector;
                break;
             }

             break;

       default:  fprintf(stderr, "ERROR: BreakoutReporter >>>> checkBreakoutSelectorsFor >>>> numberOfBreakoutLevels exceeded\n");
                 fflush(0);
                 exit(1);
                 break;

  }

 if(badSelector != (SEL) nil)
 {
    fprintf(stderr, "ERROR: BreakoutReporter >>>> %s does not respond to Selector %s\n", [anObj getName], sel_get_name (badSelector));
    fflush(0);
    exit(1);
 }

 return self;

}

+ (char *) reportFileMetaData: (id) aZone {
  char* sysDateAndTime = (char *) [(id <Zone>)aZone alloc: (size_t) 55];
  struct tm *timeStruct;
  time_t aTime;
  aTime = time(NULL);
  timeStruct = localtime(&aTime);
  strftime(sysDateAndTime, 55, "Model Run System Date and Time: %a %d-%b-%Y %H:%M:%S", timeStruct);
  return sysDateAndTime;
}
    
+ (char *) formatFloatOrExponential: (double) aVal{
	int sigFigsKept = 4;

	if(aVal == 0.0){
	   return "%f";
	}else if(aVal < 0.0){
	    if(log10(-aVal) < -(sigFigsKept-1)){
		   return "%E";
	    }else{
		   return "%f";
	    }
	}else if(log10(aVal) < -(sigFigsKept-1)){
	   return "%E";
	}else{
	   return "%f";
	}
}
    

- (void) drop
{

   // fprintf(stdout, "BreakoutReporter drop >>>> BEGIN\n");
   // fflush(0);

    if(outputWithLabelsList)
    {
       id <ListIndex> lstNdx = [outputWithLabelsList listBegin: scratchZone];
       OutputWithLabel* outputLabel = (OutputWithLabel *) nil;
       
       while(([lstNdx getLoc] != nil) && ((outputLabel = (OutputWithLabel *) [lstNdx next]) != (OutputWithLabel *) nil))
       {
              [reporterZone free: outputLabel];
       }
    
       [lstNdx drop];
       [outputWithLabelsList drop];
    }

    if(dataColumnStructList)
    {   
       id <ListIndex> lstNdx = [dataColumnStructList listBegin: scratchZone];
       DataColumnWithLabel* dataColumnWithLabel = (DataColumnWithLabel *) nil;

       while(([lstNdx getLoc] != nil) && ((dataColumnWithLabel = (DataColumnWithLabel *) [lstNdx next]) != (DataColumnWithLabel *) nil))
       {
              [reporterZone free: dataColumnWithLabel];
       }

       [lstNdx drop];
       [dataColumnStructList drop];

    }

    if(filePtr != NULL) 
    {
        fclose(filePtr);
    }

    if(level1Ndx)
        [level1Ndx drop];
    if(level2Ndx)
        [level2Ndx drop];
    if(level3Ndx)
        [level3Ndx drop];
    if(level4Ndx)
        [level4Ndx drop];
    if(level5Ndx)
        [level5Ndx drop];


    if(averagerMapList)
    {
       id <ListIndex> ndx = [averagerMapList listBegin: scratchZone];
       id <Map> averagerMap = nil;

       while(([ndx getLoc] != End) && ((averagerMap = [ndx next]) !=  nil))
       {
           [averagerMap deleteAll];
       }
       [ndx drop];

       [averagerMapList deleteAll];
       [averagerMapList drop];
       averagerMapList = nil;
  
    }

    [breakoutMap deleteAll];
    [breakoutMap drop];
    breakoutMap = nil;




    [reporterZone drop];

    [super drop];

   // fprintf(stdout, "BreakoutReporter drop >>>> END\n");
   // fflush(0);

}

@end



