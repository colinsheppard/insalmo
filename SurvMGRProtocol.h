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
@protocol SurvMGR  <CREATABLE>


// CREATING


+         createBegin: aZone
   withHabitatObject: anObj;
    

- createEnd;
- setMyHabitatObject: anObj;

- setTestOutputOnWithFileName: (char *) aFileName;

- (id <Symbol>) getANIMALSYMBOL;
- (id <Symbol>) getHABITATSYMBOL;
- (int) getNumberOfProbs;
- getHabitatObject;
- getCurrentAnimal;



- addPROBWithSymbol: (id <Symbol>) aProbSymbol
          withType: (char *) aProbType
    withAgentKnows: (BOOL) anAgentKnows
   withIsStarvProb: (BOOL) isAStarvProb;

- addBoolSwitchFuncToProbWithSymbol: (id <Symbol>) aProbSymbol
          withInputObjectType: (id <Symbol>) objType
               withInputSelector: (SEL) aSelector
                  withYesValue: (double) aYesValue   //FIX
                   withNoValue: (double) aNoValue;


- addLogisticFuncToProbWithSymbol: (id <Symbol>) aProbSymbol
         withInputObjectType: (id <Symbol>) objType
              withInputSelector: (SEL) aSelector
                  withXValue1: (double) xValue1
                  withYValue1: (double) yValue1
                  withXValue2: (double) xValue2
                  withYValue2: (double) yValue2;

- setLogisticFuncLimiterTo: (double) aLimiter;

- addConstantFuncToProbWithSymbol: (id <Symbol>) aProbSymbol
                   withValue: (double) aValue;


- addCustomFuncToProbWithSymbol: (id <Symbol>) aProbSymbol
                  withClassName: (char *) className
            withInputObjectType: (id <Symbol>) objType
              withInputSelector: (SEL) aObjSelector;

- addObjectValueFuncToProbWithSymbol: (id <Symbol>) aProbSymbol
                 withInputObjectType: (id <Symbol>) objType
                   withInputSelector: (SEL) aObjSelector;
                  

- updateForHabitat;
- updateForAnimal: anAnimal;

- (id <List>) getListOfSurvProbsFor: anAnimal;

- (double) getTotalSurvivalProbFor: anAnimal;
- (double) getTotalKnownNonStarvSurvivalProbFor: anAnimal;
- (double) getStarvSurvivalFor: anAnimal;

- createHeaderAndFormatStrings;
- writeSurvOutputWithAnimal: anAnimal;

- (void) drop;

@end

@protocol SurvProb  <CREATABLE>

- (const char *) getName;
- (id <Symbol>) getProbSymbol;
- (BOOL) getIsStarvProb;
- (BOOL) getAnAgentKnows;
- (double) getSurvivalProb;

@end

@class SurvMGR;
@class SurvProb;
