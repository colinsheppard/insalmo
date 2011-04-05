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

#import <objectbase/SwarmObject.h>


@interface PolyPoint : SwarmObject 
{
    id polyCell;

    double xCoordinate;
    double yCoordinate;

    //
    // These will be automatically set when 
    // when the above x- and y- coordinates are set
    //
    long int intXCoordinate;   //we'll need these for the integer arithmetic
    long int intYCoordinate;

    BOOL deletePoint;
 
    unsigned int rasterResolutionX;
    unsigned int rasterResolutionY;

    long int displayX;
    long int displayY;

 


}

+ createBegin: aZone;

- setPolyCell: aPolyCell;
- setXCoordinate: (double) X
            andY: (double) Y;
- createEnd;

- (double) getXCoordinate;
- (double) getYCoordinate;

- (long int) getIntX;
- (long int) getIntY;

- setRasterResolutionX: (unsigned int) aRasterResolutionX;
- setRasterResolutionY: (unsigned int) aRasterResolutionY;

- calcDisplayXWithMinX: (long int) aMinX;
- calcDisplayYWithMaxY: (long int) aMaxY;

- (long int) getDisplayX;
- (long int) getDisplayY;

//- (int) findLowestRightMostPoint: (PolyPoint *) aPolyPoint;
//- (int) findLeftOf: (PolyPoint *) aPolyPoint;
//- (int) grahamScanWith: (id <List>)  aGrahamScanStack;
//- (int) sortFunction: (PolyPoint *) aPolyPoint;
//- (int) comnpare: (PolyPoint *) aPolyPoint;

//- setDeletePointTRUE;
//- (BOOL) getDeletePoint;

- (void) drop;

@end

