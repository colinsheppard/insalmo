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


#import <objectbase/SwarmObject.h>

#import "SurvMGRProtocol.h"

#import "BooleanSwitchFunc.h"
#import "LogisticFunc.h"
#import "ConstantFunc.h"
#import "ObjectValueFunc.h"


@interface SurvProb : SwarmObject <SurvProb, CREATABLE>
{


@protected

id <Zone> probZone;

id survMgr;


char *probName;
id <Symbol> probSymbol;

unsigned isStarvProb;
unsigned anAgentKnows;

id <List> funcList;
id <ListIndex> funcListNdx;

}

+ createBegin: aZone;
- createEnd;

- setSurvMgr: aSurvMgr;



- setProbSymbol: (id <Symbol>) aNameSymbol;
- setIsStarvProb: (unsigned) aBool;
- setAnAgentKnows: (unsigned) aBool;

- (const char *) getName;
- (id <Symbol>) getProbSymbol;

- (BOOL) getIsStarvProb;
- (BOOL) getAnAgentKnows;

- (double) getSurvivalProb;

- createLogisticFuncWithInputMethod: (SEL) inputMethod
                withInputObjectType: (id <Symbol>) anObjType
                         andXValue1: (double) xValue1
                         andYValue1: (double) yValue1
                         andXValue2: (double) xValue2
                         andYValue2: (double) yValue2;



- createConstantFuncWithValue: (double) aValue;

- createBoolSwitchFuncWithInputMethod: (SEL) anInputMethod
                         withYesValue: (double) aYesValue
                         withNoValue: (double) aNoValue;



- createCustomFuncWithClassName: (char *) className
              withInputSelector: (SEL) anInputSelector
            withInputObjectType: (id <Symbol>) objType;


- createObjectValueFuncWithInputSelector: (SEL) anObjSelector
                     withInputObjectType: (id) objType;


@end
