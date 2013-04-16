/*
inSALMO individual-based salmon model, Version 1.2, April 2013.
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




#import <objectbase/SwarmObject.h>
#import <gui.h>
#import <math.h>
#import <stdlib.h>
#import "globals.h"
#import "InterpolationTableP.h"
#import "PolyPoint.h"


struct PolyDisplayCoordStruct {
                          int x;
                          int y;
                        };

typedef struct PolyDisplayCoordStruct PolyDisplayPoint;

struct PolyPixelCoordStruct {
                          unsigned int pixelX;
                          unsigned int pixelY;
                        };

typedef struct PolyPixelCoordStruct PolyPixelCoord;

@interface PolyCell : SwarmObject
{

  int numberOfNodes;

  double** polyCornerCoords;
  int numCornerCoords;
  
  int numPolyCoords;        // this is a count of the number of coords read in form the 
                            // geometry file

  double** polyCoordinates; // not all of these will be valid.
                            // duplicates will be tossed
                            // coordinates on a line segmente joining 
                            // joining true verticies will be tossed 


   id cellZone;
   int polyCellNumber;
   PolyPoint* forSurePolyPoint;
   BOOL polyCellError;

   long int forSurePointX;
   long int forSurePointY;

   PolyPoint* lowestRightMostPoint;


   id <List> polyPointList;
 
   long int minXCoordinate;
   long int maxYCoordinate;

   double polyCellArea;
   double polyCenterX;
   double polyCenterY;

   BOOL tagCell; 

  id <List> listOfAdjacentCells;

  long int minDisplayX;
  long int maxDisplayX;
  long int minDisplayY;
  long int maxDisplayY;
  long int displayCenterX;
  long int displayCenterY;

  unsigned int polyRasterResolutionX;
  unsigned int polyRasterResolutionY;
  char rasterColorVariable[35];

  int* polyCellPixelsX;
  int pixelArraySizeX;
  int* polyCellPixelsY;
  int pixelArraySizeY;

  PolyPixelCoord** polyCellPixels;
  int pixelCount;

  int cellColor; 
  int boundaryColor; 
  int interiorColor; 

}

+ create: aZone;

- (id <Zone>) getPolyCellZone;

- setPolyCellNumber: (int) aPolyCellNumber;
- (int) getPolyCellNumber;

- incrementNumCoordinates: (int) anIncrement;   //This is the total number of coordinates from the geometry file

- setNumberOfNodes: (int) aNumberOfNodes;     // This may go away

- (int) getNumberOfNodes;

- createPolyCoordinateArray;
- setPolyCoordsWith: (double) aPolyCoordX
                and: (double) aPolyCoordY;
- checkPolyCoords;

- createPolyPoints;  // creates the polyPointList and populates it;
- (id <List>) getPolyPointList;

- setMinXCoordinate: (long int) aMinXCoordinate;
- setMaxYCoordinate: (long int) aMaxYCoordinate;

- tagPolyCell;
- unTagPolyCell;
- tagAdjacentCells;
- unTagAdjacentCells;



- setPolyRasterResolutionX: (int) aResolutionX;
- setPolyRasterResolutionY: (int) aResolutionY;
- (int) getPolyRasterResolutionX;
- (int) getPolyRasterResolutionY;

- createPolyCellPixels;
- (double) getPolyCellArea;
- (double) getPolyCenterX;
- (double) getPolyCenterY;


- createPolyAdjacentCellsFrom: (id <ListIndex>) habSpacePolyCellListNdx;
- (id <List>) getListOfAdjacentCells;


- (BOOL) containsRasterX: (long int) aRasterX andRasterY: (long int) aRasterY;
- setRasterColorVariable: (char *) aColorVariable;


- tagPolyCell;
- unTagPolyCell;
- tagAdjacentCells;

- (void) drop;

@end




