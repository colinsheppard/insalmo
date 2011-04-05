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


