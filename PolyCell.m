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




#include <math.h>
#include <stdlib.h>

#import <simtools.h>


#import "PolyCell.h"

@implementation PolyCell

+ create: aZone 
{
  PolyCell* polyCell = [super create: aZone];

  polyCell->cellZone = [Zone create: aZone];

  polyCell->tagCell = NO;


  polyCell->numPolyCoords = 0;
  polyCell->numCornerCoords = 0;


  polyCell->forSurePolyPoint = nil;
  polyCell->polyCellError = NO;

  return polyCell;
}




/////////////////////////////////////
//
// getPolyCellZone
//
/////////////////////////////////////
- (id <Zone>) getPolyCellZone
{
    return cellZone;
}

////////////////////////////////////
//
// setCellNumber
//
///////////////////////////////////
- setPolyCellNumber: (int) aPolyCellNumber
{
    polyCellNumber = aPolyCellNumber;
    return self;
}


////////////////////////////////
//
// getPolyCellNumber
//
////////////////////////////////
- (int) getPolyCellNumber
{
     return polyCellNumber;
}


////////////////////////////////////////
//
// setNumberOfNodes
//
////////////////////////////////////////
- setNumberOfNodes: (int) aNumberOfNodes
{
    numberOfNodes = aNumberOfNodes;
    return self;
}


//////////////////////////////////////
//
// getNumberOfNodes
//
/////////////////////////////////////
- (int) getNumberOfNodes
{
   return numberOfNodes;
}



/////////////////////////////////////////////////
//
// incrementNumCoordinatess
//
/////////////////////////////////////////////////
- incrementNumCoordinates: (int) anIncrement
{
     numPolyCoords += anIncrement;
     return self;
} 


//////////////////////////////////////////////////
//
// createPolyCoordinateArray
//
/////////////////////////////////////////////////
- createPolyCoordinateArray
{
    int i;

    //fprintf(stdout, "PolyCell >>>> createPolyCoordinateArray >>> BEGIN\n");
    //fflush(0);

    polyCoordinates = (double **) [cellZone alloc: (2*numPolyCoords) * sizeof(double *)];

    for(i = 0; i < numPolyCoords; i++)
    {
         polyCoordinates[i] = (double *) [cellZone alloc: 2*sizeof(double)]; 

         polyCoordinates[i][0] = -1;
         polyCoordinates[i][1] = -1;
    }

    //fprintf(stdout, "PolyCell >>>> createPolyCoordinateArray >>> END\n");
    //fflush(0);

    return self;
}



//////////////////////////////////////////////////
//
// setPolyCooordsWith
//
//////////////////////////////////////////////////
- setPolyCoordsWith: (double) aPolyCoordX
                and: (double) aPolyCoordY;
{
     int i;

     //fprintf(stdout, "PolyCell >>>> setPolyCoordsWith >>>>  polyCellNumber = %d\n", polyCellNumber);
     //fprintf(stdout, "PolyCell >>>> setPolyCoordsWith >>>>  numPolyCoords = %d\n", numPolyCoords);
     //fprintf(stdout, "PolyCell >>>> setPolyCoordsWith >>>> X = %f >>>> Y = %f\n", aPolyCoordX, aPolyCoordY);
     //fflush(0); 

     for(i = 0; i < numPolyCoords; i++)
     {     
            if((polyCoordinates[i][0] != -1) && (polyCoordinates[i][1] != -1))
            {
                continue;
            }

            break;
     }

     polyCoordinates[i][0] = aPolyCoordX; 
     polyCoordinates[i][1] = aPolyCoordY; 
     //fprintf(stdout, "PolyCell >>>> setPolyCoordsWith >>>> X = %f >>>> Y = %f\n", aPolyCoordX, aPolyCoordY);
     //fflush(0); 

     return self;
}


/////////////////////////////////////////////////////////////
//
// checkPolyCoords
//
//////////////////////////////////////////////////////////////
- checkPolyCoords
{
     //int i;

     //fprintf(stdout, "PolyCell >>>> checkPolyCoords >>>>  BEGIN\n");
     //fprintf(stdout, "PolyCell >>>> checkPolyCoords >>>>  polyCellNumber = %d\n", polyCellNumber);
     //fprintf(stdout, "PolyCell >>>> checkPolyCoords >>>>  numPolyCoords = %d\n", numPolyCoords);
     //fflush(0); 

     //for(i = 0; i < numPolyCoords; i++)
     //{     
            //fprintf(stdout, "PolyCell >>>> checkPolyCoords >>>> X = %f \n", polyCoordinates[i][0]); 
            //fprintf(stdout, "PolyCell >>>> checkPolyCoords >>>> Y = %f \n", polyCoordinates[i][1]); 
            //fflush(0);
     //}

     //fprintf(stdout, "PolyCell >>>> checkPolyCoords >>>>  BEGIN\n");
     //fflush(0);

     return self;
}

/////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

             /// HERE ////////////

/////////////////////////////////////////////////////////////////
//
// createPolyPoints
// creates the polyPointList and populates it;
//
////////////////////////////////////////////////////////////////
- createPolyPoints
{
    int i;

    //fprintf(stdout, "PolyCell >>>> createPolyPoints >>>> BEGIN\n");
    //fflush(0);

    polyPointList = [List create: cellZone]; 

    for(i = 0; i < numPolyCoords; i++)
    {
         PolyPoint* polyPoint = [PolyPoint createBegin: cellZone];
 
         [polyPoint setPolyCell: self];

         [polyPoint setXCoordinate: 100 * polyCoordinates[i][0]
                              andY: 100 * polyCoordinates[i][1]];

         polyPoint = [polyPoint createEnd];

         [polyPointList addFirst: polyPoint];

         if(i == 0)
         {
              forSurePolyPoint = polyPoint;
              forSurePointX = [forSurePolyPoint getIntX];
              forSurePointY = [forSurePolyPoint getIntY];
         }

         if(forSurePolyPoint != polyPoint)
         {
              if((forSurePointX == [polyPoint getIntX]) && (forSurePointY == [polyPoint getIntY]))
              {
                    [polyPointList remove: polyPoint];
                    [polyPoint drop];
                    polyPoint = nil;
              }
         }
    
    }

         

    //fprintf(stdout, "PolyCell >>>> createPolyPoints >>>> END\n");
    //fflush(0);

    return self;
}


///////////////////////////////////////////
//
// getPolyPointList
//
///////////////////////////////////////////
- (id <List>) getPolyPointList
{
     return polyPointList;
}


///////////////////////////////////////////////
//
// setMinXCoordinate
//
////////////////////////////////////////////////
- setMinXCoordinate: (long int) aMinXCoordinate
{
    minXCoordinate = aMinXCoordinate;
    return self;
}

/////////////////////////////////////////////////
//
// setMaxYCoordinate
//
/////////////////////////////////////////////////
- setMaxYCoordinate: (long int) aMaxYCoordinate
{
    maxYCoordinate = aMaxYCoordinate;
    return self;
}


////////////////////////////////////////////////
//
// tagPolyCell
//
////////////////////////////////////////////////
- tagPolyCell
{
    tagCell = YES;

    return self;
}


///////////////////////////////////////////////////
//
// unTagPolyCell
//
//////////////////////////////////////////////////
- unTagPolyCell
{
    tagCell = NO;
    return self;
}


////////////////////////////////////////
//
// tagAdjacentCells
//
///////////////////////////////////////
- tagAdjacentCells
{
    [listOfAdjacentCells forEach: M(tagPolyCell)];
    return self;
}

////////////////////////////////////////
//
// unTagAdjacentCells
//
///////////////////////////////////////
- unTagAdjacentCells
{
    [listOfAdjacentCells forEach: M(unTagPolyCell)];
    return self;
}



////////////////////////////////////////////////
//
// setRaster* 
//
///////////////////////////////////////////

- setPolyRasterResolutionX: (int) aResolutionX 
{
  polyRasterResolutionX = aResolutionX;
  return self;
}

- (int) getPolyRasterResolutionX 
{
  return polyRasterResolutionX;
}

- setPolyRasterResolutionY: (int) aResolutionY 
{
  polyRasterResolutionY = aResolutionY;
  return self;
}

- (int) getPolyRasterResolutionY 
{
  return polyRasterResolutionY;
}



/////////////////////////////////////
//
// createPolyCellPixels
//
////////////////////////////////////
- createPolyCellPixels
{

  id <ListIndex> ndx = [polyPointList listBegin: scratchZone];
  PolyPoint* polyPoint = nil;

  long int aDisplayX = 0;
  long int aDisplayY = 0;
  int i;

  //fprintf(stdout, "PolyCell >>>> createPolyCellPixels >>>> BEGIN\n");
  //fflush(0);

  maxDisplayX = -1;
  maxDisplayY = -1;

  while(([ndx getLoc] != End) && ((polyPoint = [ndx next]) != nil))
  {
      long int ppDisplayX = [polyPoint getDisplayX];
      long int ppDisplayY = [polyPoint getDisplayY];

      maxDisplayX = (maxDisplayX > ppDisplayX) ? maxDisplayX : ppDisplayX;
      maxDisplayY = (maxDisplayY > ppDisplayY) ? maxDisplayY : ppDisplayY;
  }

  [ndx setLoc: Start];
  minDisplayX = maxDisplayX;
  minDisplayY = maxDisplayY;
  while(([ndx getLoc] != End) && ((polyPoint = [ndx next]) != nil))
  {
      long int ppDisplayX = [polyPoint getDisplayX];
      long int ppDisplayY = [polyPoint getDisplayY];
      minDisplayX = (minDisplayX < ppDisplayX) ? minDisplayX : ppDisplayX;
      minDisplayY = (minDisplayY < ppDisplayY) ? minDisplayY : ppDisplayY;
  }
  [ndx drop];
  ndx = nil;

  pixelCount = 0;
  for(aDisplayX = minDisplayX; aDisplayX <= maxDisplayX; aDisplayX++)
  {
      for(aDisplayY = minDisplayY; aDisplayY <= maxDisplayY; aDisplayY++)
      {
          if([self containsRasterX: aDisplayX andRasterY: aDisplayY])
          {
               pixelCount++;
          }
      }
  }

  if(pixelCount > 0)
  {
     i = 0;
     polyCellPixels = (PolyPixelCoord **) [cellZone alloc: pixelCount * sizeof(PolyPixelCoord *)];

     for(aDisplayX = minDisplayX; aDisplayX <= maxDisplayX; aDisplayX++)
     {
         for(aDisplayY = minDisplayY; aDisplayY <= maxDisplayY; aDisplayY++)
         {
             if([self containsRasterX: aDisplayX andRasterY: aDisplayY])
             {
                  if(i < pixelCount)
                  {
                      polyCellPixels[i] = (PolyPixelCoord *) [cellZone alloc: sizeof(PolyPixelCoord)];
                  
                      polyCellPixels[i]->pixelX = aDisplayX;
                      polyCellPixels[i]->pixelY = aDisplayY;
                      i++;
                   
                  }
             }
         }
     }
   }
  
  //fprintf(stdout, "PolyCell >>>> createPolyCellPixels >>>> END\n");
  //fflush(0);
  
  return self;
} 


/////////////////////////////////////////////////////////////
//
// calcPolyCellCentroid
//
// This method also calculates the polyCellArea
// Area Reference: O'Rourke, J (1998),
//                 Computational Geometry in C, 2nd Edition
//                 Cambridge University Press, Cambridge
//                 p. 21
//
// Centroid Reference: Harris, J.W., Stocker, H., (1998)
//                     Handbook of Mathematics and Computational Science
//                     Springer-Verlag, New York
//                     p. 378
/////////////////////////////////////////////////////////////
- calcPolyCellCentroid
{
   int i;
   int j;
   PolyPoint* polyPointI;
   PolyPoint* polyPointJ;
   int numberOfPPoints = 0;
  


   //fprintf(stdout, "PolyCell >>>> calcPolyCellCentroid >>>> BEGIN\n");
   //fflush(0);

   polyCellArea = 0.0;
   polyCenterX = 0.0;
   polyCenterY = 0.0;

   numberOfPPoints = [polyPointList getCount];
   
   //
   // The points must be labeled counter clockwise.
   //
   for(i = 0; i < numberOfPPoints; i++) 
   {
      j = (i + 1) % numberOfPPoints;
      
      polyPointI = [polyPointList atOffset: i];
      polyPointJ = [polyPointList atOffset: j];

      polyCellArea += [polyPointI getXCoordinate] * [polyPointJ getYCoordinate];
      polyCellArea -= [polyPointI getYCoordinate] * [polyPointJ getXCoordinate];


   }

   polyCellArea /= 2;

   if(polyCellArea <= 0.0)
   {
      fprintf(stderr, "ERROR: PolyCell >>>> calcPolyCellCentroid >>>> polyCellNumber = %d polyCellArea = %f\n", polyCellNumber, polyCellArea);
      fflush(0);
      exit(1);
   }

   polyCenterX = 0.0;
   polyCenterY = 0.0;

   for(i = 0; i < numberOfPPoints; i++) 
   {
      polyPointI = [polyPointList atOffset: i];
      polyCenterX  += [polyPointI getIntX];
      polyCenterY  += [polyPointI getIntY];
   }

   polyCenterX = polyCenterX/numberOfPPoints;
   polyCenterY = polyCenterY/numberOfPPoints;

   displayCenterX = (unsigned int) (polyCenterX - minXCoordinate) + 0.5;
   displayCenterX = displayCenterX/polyRasterResolutionX + 0.5;
   displayCenterY = (unsigned int) (maxYCoordinate - polyCenterY) + 0.5;
   displayCenterY = displayCenterY/polyRasterResolutionY + 0.5;

   //fprintf(stdout, "PolyCell >>>> calcPolyCellCentroid >>>> END\n");
   //fflush(0);

   return self;
}


////////////////////////////
//
// getPolyCenterX
//
////////////////////////////
- (double) getPolyCenterX
{
    return polyCenterX;
}



///////////////////////////////
//
// getPolyCenterY
//
///////////////////////////////
- (double) getPolyCenterY
{
    return polyCenterY;
}


/////////////////////////////
//
// getPolyCellArea
//
////////////////////////////
- (double) getPolyCellArea
{
    return polyCellArea;
}


////////////////////////////////////////////////////////////////////////
//
// createPolyAdjacentCellsFrom
//
////////////////////////////////////////////////////////////////////////
- createPolyAdjacentCellsFrom: (id <ListIndex>) habSpacePolyCellListNdx
{
   id <ListIndex> ndx = habSpacePolyCellListNdx;
   PolyCell* otherPolyCell = nil;
   id <ListIndex> ppNdx = nil;

   //fprintf(stdout, "PolyCell >>>> createPolyAdjacentCells >>>> BEGIN\n");
   //fflush(0);

   listOfAdjacentCells = [List create: cellZone];

   [ndx setLoc: Start];

   ppNdx  = [polyPointList listBegin: scratchZone];

   while(([ndx getLoc] != End) && ((otherPolyCell = [ndx next]) != nil))
   {
       id <List> otherPolyPointList = nil;
       id <ListIndex> oppNdx = nil;
       PolyPoint* polyPoint = nil;
       PolyPoint* otherPolyPoint = nil;

       if(otherPolyCell == self)
       {
          continue;
       }

       if((otherPolyPointList = [otherPolyCell getPolyPointList]) == nil)
       {
           fprintf(stderr, "ERROR: PolyCell >>> createPolyAdjacentCellsFrom >>>> nil polyPointList\n");
           fflush(0);
           exit(1);
       }
 
       [ppNdx setLoc: Start];
       while(([ppNdx getLoc] != End) && ((polyPoint = [ppNdx next]) != nil))
       {
           oppNdx = [otherPolyPointList listBegin: scratchZone];
           while(([oppNdx getLoc] != End) && ((otherPolyPoint = [oppNdx next]) != nil))
           {
                if(([polyPoint getIntX] == [otherPolyPoint getIntX]) && ([polyPoint getIntY] == [otherPolyPoint getIntY]))
                {
                     if([listOfAdjacentCells contains: otherPolyCell])
                     {
                         continue;
                     }

                     [listOfAdjacentCells addLast: otherPolyCell];
                }
           } //while
           [oppNdx drop];
           oppNdx = nil;
       }
   }
   [ppNdx drop];
   ppNdx = nil;

   //
   // The list of adjacent cells shouldn't be empty
   //
   if([listOfAdjacentCells getCount] < 1)
   {
     fprintf(stderr, "ERROR: PolyCell >>>> createPolyAdjacentCellsFrom >>>> adjacentCells is empty at CellNum: %d\n", 
        polyCellNumber);
     fflush(0);
     exit(1);
   }



   //
   // Do not drop ndx, it belongs to HabitatSpace!!
   //

   //fprintf(stdout, "PolyCell >>>> createPolyAdjacentCells >>>> END\n");
   //fflush(0);

   return self;

}


/////////////////////////////////////
//
// getListOfAdjacentCells
//
////////////////////////////////////
- (id <List>) getListOfAdjacentCells
{
    return listOfAdjacentCells;
}


//////////////////////////////////////////////////////////////////////////////
//
// containsRasterX
//
// Point in Polygon Reference: O'Rourke, J (1998),
//                             Computational Geometry in C, 2nd Edition
//                             Cambridge University Press, Cambridge
//                             pp 239-245
//
// Note: A point must be strictly interior for a 'YES' return value.
//       Points on the boundary are not handled consistently.
//
//////////////////////////////////////////////////////////////////////////////
- (BOOL) containsRasterX: (long int) aRasterX andRasterY: (long int) aRasterY
{
  int i;
  BOOL interiorPoint = NO; 
  double polyX;  
  double polyY;  

  int counter = 0;
  double xIntersect;

  int ppListCount = [polyPointList getCount];

  PolyPoint* p1 = nil;
  PolyPoint* p2 = nil;
 
  polyX = (double) (aRasterX * polyRasterResolutionX) + minXCoordinate;
  polyY = maxYCoordinate - (double) (aRasterY * polyRasterResolutionY);


  p1 = [polyPointList atOffset: 0]; 

  for(i = 1; i <= ppListCount; i++) 
  {
    //
    // Change these two sets of vars from long int to double
    //
    double minP1P2Y;
    double maxP1P2Y;
    double maxP1P2X;
    
    double p1X;
    double p1Y;
    double p2X;
    double p2Y;

    p2 = [polyPointList atOffset: (i % ppListCount)];

    p1X = [p1 getXCoordinate];
    p1Y = [p1 getYCoordinate];
    p2X = [p2 getXCoordinate];
    p2Y = [p2 getYCoordinate];

    maxP1P2X = (p1X > p2X) ? p1X : p2X;
    minP1P2Y = (p1Y < p2Y) ? p1Y : p2Y;
    maxP1P2Y = (p1Y > p2Y) ? p1Y : p2Y;


    if(polyY > minP1P2Y)
    {
      if(polyY <= maxP1P2Y)
      {
        if(polyX <= maxP1P2X)
        {
          if(p1Y != p2Y) 
          {
            xIntersect = (polyY - p1Y) * (p2X - p1X)/(p2Y - p1Y) + p1X;
            if (p1X == p2X || polyX <= xIntersect)
            {
              counter++;
            }
          }
        }
      }
    }

    p1 = p2;


  } //for 

  if (counter % 2 == 0) 
  {
     interiorPoint = NO;
  }
  else
  {
     interiorPoint = YES;
  
  }

      
  //fprintf(stdout, "PolyCell >>>> containsProbedX: anProbedY: >>>> cell number %d END\n", polyCellNumber);
  //fflush(0);

  return interiorPoint;
}


////////////////////////////////////////////////
//
// setRasterColorVariable
//
////////////////////////////////////////////////
- setRasterColorVariable: (char *) aColorVariable 
{
   strncpy(rasterColorVariable, aColorVariable, 35);

   return self;
}





/////////////////////////////////////////
//
// drop
//
////////////////////////////////////////
- (void) drop
{
    int i = 0;

    //fprintf(stdout, "PolyCell >>>> drop >>>> BEGIN\n");
    //fflush(0);
    
    for(i = 0; i < pixelCount; i++)
    {
          [cellZone free: polyCellPixels[i]];
          polyCellPixels[i] = NULL; 
    }
    [cellZone free: polyCellPixels];
    polyCellPixels = NULL;

    for(i = 0; i < numberOfNodes; i++)
    {
         [cellZone free: polyCoordinates[i]]; 
         polyCoordinates[i] = NULL;
    }
    [cellZone free: polyCoordinates]; 
    polyCoordinates = NULL;

    [polyPointList deleteAll];
    polyPointList = nil;

    //fprintf(stdout, "PolyCell >>>> drop >>>> pixelCount = %d \n",pixelCount);
    //fflush(0);

   [cellZone drop];

   [super drop];
   self = nil;

   //fprintf(stdout, "PolyCell >>>> drop >>>> END\n");
   //fflush(0);
}

@end
