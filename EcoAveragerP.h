#import <gui.h> // GraphElement

@protocol EcoAverager <MessageProbe, CREATABLE>
//S: Averages together data, gives the data to whomever asks.

//D: Averager objects read a value (via a MessageProbe) from a
//D: collection (typically a list) of objects and collect statistics over them.

CREATING
//M: Sets the collection of objects that will be probed.
- setCollection: aTarget;

//M: Set sampling width for target.
- setWidth: (unsigned)width;

USING
//M: The update method runs through the collection calling the selector on 
//M: each object.
- (void)update;

//M: The getAverage method averages the values the averager collects. The total
//M: and count are read out of the object to compute the average.
- (double)getAverage;

//M: The getMovingAverage method averages the values the averager collects
//M: using the specified sampling width.
- (double)getMovingAverage;

//M: The returns the unbiased estimate of sample variance per the
//M: `corrected' formula (Hays, Statistics 3rd ed, p. 188).
- (double)getVariance;

//M: The returns the unbiased estimate of sample variance using
//M: the specified sampling width.
- (double)getMovingVariance;

//M: The returns the square root of -getVariance.
- (double)getStdDev;

//M: The returns the square root of -getMovingVariance.
- (double)getMovingStdDev;

//M: The getTotal method sums the values the averager collects. The value is 
//M: read out of the object, not computed everytime it is asked for.
- (double)getTotal;

//M: The getMin method returns the minimum value the averager collects. The 
//M: value is read out of the object, not computed everytime it is asked for.
- (double)getMin;

//M: The getCount method returns the number of values the averager collects. 
- (unsigned)getCount;
@end

@class EcoAverager;
