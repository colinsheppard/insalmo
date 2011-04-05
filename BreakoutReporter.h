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

#import <objectbase/SwarmObject.h>
#import <analysis.h>
#import <time.h>
#import "BreakoutAverager.h"
#import "BreakoutMessageProbe.h"
#import "BreakoutVarProbe.h"

#ifndef TRUE
   #define TRUE 1
#endif

#ifndef FALSE
   #define FALSE 0
#endif

struct OutputLabelStruct {
             char outputLabel[50];
             SEL outputVariableSelector;
             char averagerType[50];
             };

struct DataColumnStruct {
                 BOOL  isVarProbe;
                 char  dataVariable[50];
                 char  dataLabel[50];
                 id    dataObject;
                 SEL   dataSelector;
                 char  dataType[50];
             };

typedef struct OutputLabelStruct OutputWithLabel;
typedef struct DataColumnStruct DataColumnWithLabel;


@interface BreakoutReporter : SwarmObject
{

  id <Zone> reporterZone; 

  id <List> objectList;

  int numberOfBreakoutLevels;

  id <List> level1ListOfKeys;
  id <List> level2ListOfKeys;
  id <List> level3ListOfKeys;
  id <List> level4ListOfKeys;
  id <List> level5ListOfKeys;
 
  id <ListIndex> level1Ndx;
  id <ListIndex> level2Ndx;
  id <ListIndex> level3Ndx;
  id <ListIndex> level4Ndx;
  id <ListIndex> level5Ndx;

  id <Symbol> dummyKeySymbol;

  SEL level0KeySelector;
  SEL level1KeySelector;
  SEL level2KeySelector;
  SEL level3KeySelector;
  SEL level4KeySelector;
  SEL level5KeySelector;

  id <Map> breakoutMap;
  id <List> averagerMapList;

  char fileName[50];
  FILE* filePtr;

  id <List> outputWithLabelsList;
  id <List> dataColumnWithLabelList;
  id <List> dataColumnStructList;


  char* level1HeaderString;
  char* level2HeaderString;
  char* level3HeaderString;
  char* level4HeaderString;
  char* level5HeaderString;

  char headerFormatString[10];
  char floatFormatString[10];
  int columnWidth;
  BOOL useCSV;

  int totalDataColumnWidth;
  char totalDataColumnWidthStr[10];

  id <List> dataColumnList;
  id <List> blankColumnLabelList;

  BOOL suppressColumnLabels;

}

+          createBegin: aZone
               forList: (id <List>) aListOfObj
    withOutputFilename: (char *) aFileName
     withFileOverwrite: (BOOL) aBool
       withColumnWidth: (int) aColumnWidth;

+          createBegin: aZone
               forList: (id <List>) aListOfObj
    withOutputFilename: (char *) aFileName
     withFileOverwrite: (BOOL) aBool;

- createEnd;

- openFileNamed: (char *) aFileName
  withWriteMode: (char *) aWriteMode;

- buildBreakoutMap;

- breakOutUsingSelector: (SEL) aBreakoutVariableSelector
         withListOfKeys: (id <List>) aListOfKeys;


-     createOutputWithLabel: (char *) anOutputLabel
               withSelector: (SEL) anOutputVariableSelector
           withAveragerType: (char *) anAveragerType;

- buildAveragerMaps;

- addColumnWithValueOfVariable: (const char *) aVariable
                    fromObject: (id) aDataObject
                      withType: (char *) aDataType
                     withLabel: (char *) aLabel;

- addColumnWithValueFromSelector: (SEL) aDataSelector
                      fromObject: (id) aDataObject
                        withType: (char *) aDataType
                       withLabel: (char *) aDataLabel;

- buildDataColumns;

- printBreakoutReportHeader;
- suppressColumnLabels: (BOOL) aBool;

- updateByReplacement;
- updateByAccumulation;
- output;

- checkBreakoutSelectorsFor: anObj;

- (void) drop;

@end
