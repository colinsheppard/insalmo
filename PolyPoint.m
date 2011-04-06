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




#import <stdlib.h>
#import <math.h>
#import "globals.h"
#import "PolyPoint.h"
#import "PolyCell.h"

@protocol PolyCell
   
- (int) getPolyCellNumber;
- (PolyPoint *) getLowestRightMostPoint;

@end


#ifdef pi
 #undef pi
#endif

#define pi 3.14159265358979324


@implementation PolyPoint

+ createBegin: aZone
{
     //
     // aZone should be scratchZone;
     //

     PolyPoint* polyPoint = [super createBegin: aZone];

     //fprintf(stdout, "PolyPoint >>>> createBegin >>>> BEGIN\n");
     //fflush(0);

     polyPoint->polyCell = nil;
     polyPoint->intXCoordinate = -1;
     polyPoint->intYCoordinate = -1;
     polyPoint->deletePoint = FALSE;
     polyPoint->rasterResolutionX = -1;
     polyPoint->rasterResolutionY = -1;
  
     //fprintf(stdout, "PolyPoint >>>> createBegin >>>> END\n");
     //fflush(0);

     return polyPoint;
}



/////////////////////////////////////////
//
// setPolyCell
//
//////////////////////////////////////////
- setPolyCell: aPolyCell
{
      polyCell = (id <PolyCell>) aPolyCell;
      return self;
}

//////////////////////////////////////////////////////////
//
// setXCoordinate
//
//////////////////////////////////////////////////////////
- setXCoordinate: (double) X
            andY: (double) Y
{
      xCoordinate = X;
      yCoordinate = Y;

      intXCoordinate = floor(xCoordinate + 0.5);
      intYCoordinate = floor(yCoordinate + 0.5);

      return self;
}


////////////////////////////////////////
//
// setRasterResolutionX
//
///////////////////////////////////////
- setRasterResolutionX: (unsigned int) aRasterResolutionX
{
    rasterResolutionX = aRasterResolutionX;
    return self;
}
- setRasterResolutionY: (unsigned int) aRasterResolutionY
{
    rasterResolutionY = aRasterResolutionY;
    return self;
}

///////////////////////////////////////////////
//
//  createEnd
//
//////////////////////////////////////////////
- createEnd
{
    if(polyCell == nil)   
    {
         fprintf(stderr, "ERROR: PolyPoint >>>> createEnd >>>> polyCell not set\n");
         fflush(0);
         exit(1);
    }

    if((intXCoordinate == -1) || (intYCoordinate == -1))   
    {
         fprintf(stderr, "ERROR: PolyPoint >>>> createEnd >>>> coordinates not set\n");
         fflush(0);
         exit(1);
    }

    return [super createEnd];
}


////////////////////////////////////////
//
// getXCoordinate
//
////////////////////////////////////////
- (double) getXCoordinate
{
    return xCoordinate;
}



/////////////////////////////////////////
//
// getYCoordinate
//
/////////////////////////////////////////
- (double) getYCoordinate
{
    return yCoordinate;
}

/////////////////////////////////////////
//
// getIntX
//
/////////////////////////////////////////
- (long int) getIntX
{
    return intXCoordinate;
}


/////////////////////////////////////////
//
// getIntY
//
/////////////////////////////////////////
- (long int) getIntY;
{
    return intYCoordinate;
}


////////////////////////////////////
//
// calcDisplayX;
//
///////////////////////////////////
- calcDisplayXWithMinX: (long int) aMinX
{
     if(rasterResolutionX == -1)
     {
         fprintf(stdout, "ERROR: PolyPoint >>>> calcDisplayX >>>> rasterResolutionX not set\n");
         fflush(0);
         exit(1);
     }

     displayX = intXCoordinate - aMinX; 
     displayX = displayX/rasterResolutionX + 0.5;

         //fprintf(stdout, "ERROR: PolyPoint >>>> calcDisplayX >>>> aMinX %ld\n", aMinX);
         //fprintf(stdout, "ERROR: PolyPoint >>>> calcDisplayX >>>> intXCoordinate %ld\n", intXCoordinate);
         //fprintf(stdout, "ERROR: PolyPoint >>>> calcDisplayX >>>> displayX %ld\n", displayX);
         //fflush(0);
 
     return self;
}


/////////////////////////////////////
//
// calcDisplayYWithMaxY
//
/////////////////////////////////////
- calcDisplayYWithMaxY: (long int) aMaxY;
{
     if(rasterResolutionY == -1)
     {
         fprintf(stdout, "ERROR: PolyPoint >>>> calcDisplayY >>>> rasterResolutionY not set\n");
         fflush(0);
         exit(1);
     }

     displayY = aMaxY - intYCoordinate;
     displayY = displayY/rasterResolutionY + 0.5;

         //fprintf(stdout, "ERROR: PolyPoint >>>> calcDisplayY >>>> aMaxY %ld\n", aMaxY);
         //fprintf(stdout, "ERROR: PolyPoint >>>> calcDisplayY >>>> intYCoordinate %ld\n", intYCoordinate);
         //fprintf(stdout, "ERROR: PolyPoint >>>> calcDisplayY >>>> displayY %ld\n", displayY);
         //fflush(0);

     return self;
}

////////////////////////////////////
//
// getDisplayX
//
//////////////////////////////////
- (long int) getDisplayX
{
     return displayX;
}


//////////////////////////////////
//
// getDisplayY
//
//////////////////////////////////
- (long int) getDisplayY
{
    return displayY;
}

/*
/////////////////////////////////////////////////////////
//
// findLowestRightMostPoint
//
//////////////////////////////////////////////////////////
- (int) findLowestRightMostPoint: (PolyPoint *) aPolyPoint
{
     if([(id <PolyCell>) polyCell getPolyCellNumber] == 2)
     {
         fprintf(stdout, "PolyPoint >>>> findLowestMostRight >>>> BEGIN\n");
         fprintf(stdout, "PolyPoint >>>> findLowestMostRight >>>> aPolyPoint = %p\n", aPolyPoint);
         fprintf(stdout, "PolyPoint >>>> findLowestMostRight >>>> aPolyPoint getIntY  = %ld\n", [aPolyPoint getIntY]);
         fprintf(stdout, "PolyPoint >>>> findLowestMostRight >>>> self intYCoordinate  = %ld\n", intYCoordinate);
         fflush(0);
     }
     if([aPolyPoint getIntY] < intYCoordinate)
     {
          return 1;
     }
     else if(([aPolyPoint getIntY] == intYCoordinate) && ([aPolyPoint getIntX] > intXCoordinate))
     {
          return 1;
     }
     else if(([aPolyPoint getIntY] == intYCoordinate) && ([aPolyPoint getIntX] == intXCoordinate))
     {
          return 0;
     }
     else
     {
           return -1;
     } 

     //fprintf(stdout, "PolyPoint >>>> findLowestMostRight >>>> END\n");
     //fflush(0);
}
*/


/*
/////////////////////////////////////////////////////////
//
// findLeftOf
//
//////////////////////////////////////////////////////////
- (int) findLeftOf: (PolyPoint *) aPolyPoint
{
     long int area = 1;
     PolyPoint* polyPointA = nil;
     PolyPoint* polyPointB = nil;
     PolyPoint* polyPointC = nil;

     PolyPoint* lowestRightMostPoint = [(id <PolyCell>) polyCell getLowestRightMostPoint];

     long int x = 0;
     long int y = 0;

      
     fprintf(stdout, "PolyPoint >>>> findLeftOf >>>> BEGIN\n");
     fflush(0);

     polyPointA = lowestRightMostPoint;
     polyPointB = self;
     polyPointC = aPolyPoint;

     if(polyPointB == polyPointC)
     {
           return 0;
     }


     {
         long int ax = [polyPointA getIntX];
         long int ay = [polyPointA getIntY];
         long int bx = [polyPointB getIntX];
         long int by = [polyPointB getIntY];
         long int cx = [polyPointC getIntX];
         long int cy = [polyPointC getIntY];

         


         area = (bx - ax)*(cy - ay) - (cx - ax)*(by - ay);

         if(area == 0)
         {
             x = abs(bx - ax) - abs(cx - ax);     
             y = abs(by - ay) - abs(cy - ay);     
	 }

         if([(id <PolyCell>) polyCell getPolyCellNumber] == 2)
         {
                 fprintf(stdout, "PolyPoint >>>> findeLeftOf >>>> ax = %ld\n", ax);
                 fprintf(stdout, "PolyPoint >>>> findeLeftOf >>>> ay = %ld\n", ay);
                 fprintf(stdout, "PolyPoint >>>> findeLeftOf ME >>>> bx = %ld\n", bx);
                 fprintf(stdout, "PolyPoint >>>> findeLeftOf ME >>>> by = %ld\n", by);
                 fprintf(stdout, "PolyPoint >>>> findeLeftOf >>>> cx = %ld\n", cx);
                 fprintf(stdout, "PolyPoint >>>> findeLeftOf >>>> cy = %ld\n", cy);
                 fprintf(stdout, "PolyPoint >>>> findLeftOf >>>> area = %ld\n", area);
                 fprintf(stdout, "PolyPoint >>>> findLeftOf >>>> x = %ld\n", x);
                 fprintf(stdout, "PolyPoint >>>> findLeftOf >>>> y = %ld\n", y);
                 fflush(0);
         }

     if(area > 0)
     {
          return -1;
     }
     else if(area < 0)
     {
          return 1;
     }
     else
     {
          if((x < 0) || (y < 0))
          {
               [self setDeletePointTRUE];
               fprintf(stdout, "PolyPoint >>>> DELETE findeLeftOf ME >>>> bx = %ld\n", bx);
               fprintf(stdout, "PolyPoint >>>> DELETE findeLeftOf ME >>>> by = %ld\n", by);
               fflush(0);
               return -1;
          }
          else if((x > 0) || (y > 0))
          {
                [polyPointC setDeletePointTRUE];
                fprintf(stdout, "PolyPoint >>>> DELETE findeLeftOf >>>> cx = %ld\n", cx);
                fprintf(stdout, "PolyPoint >>>> DELETE findeLeftOf >>>> cy = %ld\n", cy);
                fflush(0);
                return 1;
          }
          else
          {
                //
                // points are coincidental
                //
                [polyPointC setDeletePointTRUE];
                fprintf(stdout, "PolyPoint >>>> DELETE findeLeftOf >>>> cx = %ld\n", cx);
                fprintf(stdout, "PolyPoint >>>> DELETE findeLeftOf >>>> cy = %ld\n", cy);
                fflush(0);
                return 0;
          }
     }

     }
     fprintf(stdout, "PolyPoint >>>> findLeftOf >>>> END\n");
     fflush(0);
}

*/

/*
////////////////////////////////////////////////
//
// grahamScanWith
//
///////////////////////////////////////////////
- (int) grahamScanWith: (id <List>)  aGrahamScanStack
{
     long int area = 1;
     PolyPoint* polyPointA = nil;
     PolyPoint* polyPointB = nil;
     PolyPoint* polyPointC = nil;

     //PolyPoint* lowestRightMostPoint = [(id <PolyCell>) polyCell getLowestRightMostPoint];
      
     fprintf(stdout, "PolyPoint >>>> grahamScanWith >>>> BEGIN\n");
     fflush(0);

     //polyPointA = self;
     //polyPointB = [aGrahamScanStack atOffset: 0];
     //polyPointC = [aGrahamScanStack atOffset: 1];

     polyPointA = [aGrahamScanStack atOffset: 1];
     polyPointB = [aGrahamScanStack atOffset: 0];
     polyPointC = self;

     {
         long int a0 = [polyPointA getIntX];
         long int a1 = [polyPointA getIntY];
         long int b0 = [polyPointB getIntX];
         long int b1 = [polyPointB getIntY];
         long int c0 = [polyPointC getIntX];
         long int c1 = [polyPointC getIntY];

         area = (b0 - a0)*(c1 - a1) - (c0 - a0)*(b1 - a1);
     }

     fprintf(stdout, "PolyPoint >>>> grahamScanWith >>>> area = %ld\n", area);
     fflush(0);

     if(area > 0)
     {
          return 1;
          //[aGrahamScanStack addFirst: polyPointC];
     }
     else if(area < 0)
     {
          return 0;
          [polyPointB setDeletePointTRUE];
     }
     else
     {
          //
          // Make sure in the prviuos sort that 
          // we don't get here.
          //
     fprintf(stdout, "PolyPoint >>>> grahamScanWith >>>> else\n");
     fflush(0);
         return 0;
         [polyPointB setDeletePointTRUE];
 
     } 

     fprintf(stdout, "PolyPoint >>>> grahamScanWith >>>> END\n");
     fflush(0);
     //return self;
}

*/

/*
- (int) sortFunction: (PolyPoint *) aPolyPoint
{
     fprintf(stdout, "PolyPoint >>>> sortFunction >>>> BEGIN\n");
     fprintf(stdout, "PolyPoint >>>> sortFunction >>>> aPolyPoint = %p\n", aPolyPoint);
     fflush(0);


     fprintf(stdout, "PolyPoint >>>> sortFunction >>>> END\n");
     fflush(0);
     return 1;
}
*/

/*
- (int) comnpare: (PolyPoint *) aPolyPoint
{
     fprintf(stdout, "PolyPoint >>>> compare >>>> BEGIN\n");
     fflush(0);

     xprint(aPolyPoint);

     fprintf(stdout, "PolyPoint >>>> compare >>>> END\n");
     fflush(0);
     return 1;
}

*/

/*
/////////////////////////////////////
//
// setDeletePointTRUE
//
////////////////////////////////////
- setDeletePointTRUE
{
    deletePoint = TRUE;
    return self;
}
*/


/*
///////////////////////////////////////
//
// getDeletePoint
//
/////////////////////////////////////
- (BOOL) getDeletePoint
{
     return deletePoint;
}

*/

////////////////////////////////////////////
//
// drop
//
///////////////////////////////////////////
- (void) drop
{
     [super drop];
}

@end

