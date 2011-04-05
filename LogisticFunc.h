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



#import "Func.h"

@interface LogisticFunc: Func
{

    double logisticLimiter;

    double pA;
    double pB;

    double prevInputVal;
    double prevFuncVal;
 
 

}

+      createBegin: aZone 
   withInputMethod: (SEL) anInputMethod
        usingIndep: (double) xValue1
               dep: (double) yValue1
             indep: (double) xValue2
               dep: (double) yValue2;

- createEnd;

- updateWith: anObj;

- setLogisticFuncLimiterTo: (double) aLimiter;

- initializeWithIndep: (double) x1 dep: (double) y1
	       indep: (double) x2 dep: (double) y2;
-(double) evaluateFor: (double) x; 
- (double) getpA;
- (double) getpB;

- (void) drop;

@end

