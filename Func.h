/*
EcoSwarm library for individual-based modeling, last revised April 2013.
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


#import <stdlib.h>
#import <objectbase/SwarmObject.h>
#import <string.h>
#import "globals.h"

@interface Func : SwarmObject
{
@private
    id <List> classMessageProbeList;

@protected

   double funcValue;

   SEL inputMethod;
   id <MessageProbe> messageProbe;
   BOOL dropMessageProbe;

}

+ create: aZone;
+ createBegin: aZone;
+      createBegin: aZone
    setInputMethod: (SEL) anInputMethod;
- createEnd;

- setInputMethod: (SEL) anInputMethod;
- (id <MessageProbe>) createInputMethodMessageProbeFor: (SEL) anInputMethod;


- (const char *) getProbedMessage;
- (BOOL) isResultId;
- (val_t) getProbedMessageValWithAnObj: anObj;
- (double) getProbedMessageRetValWithAnObj: anObj;
- getProbedMessageIDRetValWithAnObj: anObj;

- updateWith: anObj;

- (double) getFuncValue;

- (void) drop;

@end


