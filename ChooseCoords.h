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

struct Vector2D {
                          //
                          // Vector2D is a vector computed *from* ChooseCoord's
                          // x- and y- coordinates 
                          //
                          int label;
                          double x1;
                          double x2;
                          double length;
                          double theta;
                };

typedef struct Vector2D PolyVector;


@interface ChooseCoords : SwarmObject 
{
      int myCoordinateLabel;

      double myXCoordinate;
      double myYCoordinate;

      id <List> polyVectorList; 

      PolyVector* theSelectedPolyVector;
      double theSelectedVectorCartX;
      double theSelectedVectorCartY;

      id <List> closePolyVectors;

}

+ createBegin: aZone;
- createEnd;

- setMyXCoordinate: (double) xCoord;
- setMyYCoordinate: (double) yCoord;

- addAPolyVectorWithXCoord: (double) xCoord 
                    YCoord: (double) yCoord;

- selectNextVector;
- (double) getXCoordinateOfSelectedVector;
- (double) getYCoordinateOfSelectedVector;

- (void) drop;

@end

