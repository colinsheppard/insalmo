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
