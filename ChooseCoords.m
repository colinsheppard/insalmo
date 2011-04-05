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
#import "ChooseCoords.h"

#ifdef pi
 #undef pi
#endif

#define pi 3.14159265358979324

@implementation ChooseCoords

+ createBegin: aZone
{
     //
     // aZone should be scratchZone;
     //

     ChooseCoords* chooseCoords = [super createBegin: aZone];

     //fprintf(stdout, "ChooseCoords >>>> createBegin >>>> BEGIN\n");
     //fflush(0);


     chooseCoords->polyVectorList = [List create: aZone];
     chooseCoords->closePolyVectors = [List create: aZone];

     chooseCoords->myXCoordinate = -1;
     chooseCoords->myYCoordinate = -1;
     chooseCoords->theSelectedPolyVector = (PolyVector *) nil;

     //fprintf(stdout, "ChooseCoords >>>> createBegin >>>> END\n");
     //fflush(0);

     return chooseCoords;
}


//////////////////////////////////////
//
// setMyXCoordinate
//
//////////////////////////////////////
- setMyXCoordinate: (double) xCoord
{
     myXCoordinate = xCoord;
     return self;
}


//////////////////////////////////////
//
// setMyYCoordinate
//
//////////////////////////////////////
- setMyYCoordinate: (double) yCoord
{
      myYCoordinate = yCoord;
      return self;
}



/////////////////////////////////////////////
//
// createEnd
//
///////////////////////////////////////////
- createEnd
{
    if((myXCoordinate == -1.0) || (myYCoordinate == -1.0))
    {
         fprintf(stderr, "ERROR: ChooseCoords >>>> createEnd >>>> x- and y- coordinates not set\n");
         fflush(0);
         exit(1);
    }

    return [super createEnd];
}




////////////////////////////////////////////
//
// addAPolyVectorWithXCoord
//
////////////////////////////////////////////
- addAPolyVectorWithXCoord: (double) xCoord 
                    YCoord: (double) yCoord
{
      double x1 = xCoord - myXCoordinate;
      double x2 = yCoord - myYCoordinate;
      PolyVector* firstPolyVector = NULL;
      PolyVector* newPolyVector   = NULL;
      PolyVector* lastPolyVector  = NULL;
      double thisCosineTheta; 
      double length;
      double diff = 0.0;

      fprintf(stdout, "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
      fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> BEGIN\n");
      fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> myXCoordinate = %f\n", myXCoordinate);
      fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> myYCoordinate = %f\n", myYCoordinate);
      fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> xCoord = %f\n", xCoord);
      fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> yCoord = %f\n", yCoord);
      
      {
           double arg = 2.999998/2.9999999;
           fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> acos(%f) = %f\n", arg, acos(arg));
           fflush(0);
      }

      if((xCoord == myXCoordinate) && (yCoord == myYCoordinate))
      {
           // don't need a zero vector;
           // skip; 
      }
      else if((xCoord != myXCoordinate) || (yCoord != myYCoordinate))
      {
          newPolyVector = (PolyVector *) [scratchZone alloc: sizeof(PolyVector)];
    
          newPolyVector->x1 = x1;
          newPolyVector->x2 = x2;
          length = sqrt(x1*x1 + x2*x2);

          if(length <= 0.00001)
          {
               fprintf(stderr, "ERROR: ChooseCoords >>>> addAPolyVectorWithXCoord >>>> creating a vector with close to zero length\n");
               fflush(0);
               exit(1);
          }

          newPolyVector->length = length;

          if([polyVectorList getCount] > 0)
          {
                int cosInt = 0;
                firstPolyVector = (PolyVector *) [polyVectorList getFirst];
                lastPolyVector = (PolyVector *) [polyVectorList getLast];
 

                newPolyVector->label = lastPolyVector->label + 1; 

                thisCosineTheta = (firstPolyVector->x1 * x1 + firstPolyVector->x2 * x2)/((firstPolyVector->length)*length);

                //fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> myXCoordinate = %f\n", myXCoordinate);
                //fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> myYCoordinate = %f\n", myYCoordinate);
                fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> firstPolyVector->x1 = %f\n", firstPolyVector->x1);
                fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> firstPolyVector->x2 = %f\n", firstPolyVector->x2);
                fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> firstPolyVector->length = %f\n", firstPolyVector->length);
                fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> label = %d\n", newPolyVector->label);
                fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> xCoord = %f\n", xCoord);
                fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> yCoord = %f\n", yCoord);
                fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> x1 = %f\n", x1);
                fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> x2 = %f\n", x2);
                fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> length = %f\n", length);
                fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> thisCosineTheta = %lf\n", thisCosineTheta);
                fprintf(stdout, "(firstPolyVector->x1 * x1 + firstPolyVector->x2 * x2) = %f\n", (firstPolyVector->x1 * x1 + firstPolyVector->x2 * x2));
                fprintf(stdout, "((firstPolyVector->length)*length) = %f\n", ((firstPolyVector->length)*length));
                fprintf(stdout, "thisCosineTheta = (firstPolyVector->x1 * x1 + firstPolyVector->x2 * x2)/((firstPolyVector->length)*length) = %f\n", (firstPolyVector->x1 * x1 + firstPolyVector->x2 * x2)/((firstPolyVector->length)*length));
                fflush(0);


                if(thisCosineTheta > 0.0)
                {
                   cosInt = floor(1E6*thisCosineTheta);
                }
                if(thisCosineTheta < 0.0)
                {
                   cosInt = ceil(1E6*thisCosineTheta);
                }

                if(cosInt == 1E6)
                {
                    fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> cosInt = %d\n", cosInt);
                    fflush(0);

                   thisCosineTheta = 1.0;

                    //exit(0);
                }
                else if(cosInt == -1E6)
                {
                    fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> cosInt = %d\n", cosInt);
                    fflush(0);

                   thisCosineTheta = -1.0;

                    //exit(0);
                }

                
                //thisCosineTheta = 1.0;
                
                if((thisCosineTheta < -1.00000000000) || (thisCosineTheta > 1.000000000000))
                {
                    fprintf(stderr, "ERROR: ChooseCoords >>>> addAPolyVectorWithXCoord >>>> acos is undefined\n");
                    fflush(0);
                    exit(1);
                }
                if((thisCosineTheta + 1.0) == -0.0)
                {
                       newPolyVector->theta = pi;
                }
                else if((thisCosineTheta - 1.0) == 0.0)
                {
                       newPolyVector->theta = 0;
                }
                else
                { 
                       newPolyVector->theta = acos(thisCosineTheta);
                }

                fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> newPolyVector->theta = %f\n", newPolyVector->theta);
                fflush(0);

          }       
          else
          {
                //
                // This is the *first* vector, and the angle it has with itself
                // is 0.
                //
                newPolyVector->label = 1; 
                newPolyVector->theta = 0.0;
          }

          [polyVectorList addLast: (void *) newPolyVector];

      }

      xprint(polyVectorList);
     
      fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> myXCoordinate = %f\n", myXCoordinate);
      fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> myYCoordinate = %f\n", myYCoordinate);
      fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> xCoord = %f\n", xCoord);
      fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> yCoord = %f\n", yCoord);
      fprintf(stdout, "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
      fprintf(stdout, "ChooseCoords >>>> addAPolyVectorWithXCoord >>>> END\n");
      fflush(0);

      return self;
}



///////////////////////////////////////////
//
// selectNextVector
//
///////////////////////////////////////////
- selectNextVector
{
     //id <ListIndex> ndx = [polyVectorList listBeginScratchZone];
     PolyVector*  theReferencePolyVector = (PolyVector *) nil;
     PolyVector*  theNextPolyVector = (PolyVector *) nil;
     //PolyVector*  thePreviousPolyVector = (PolyVector *) nil;
     int listCount = [polyVectorList getCount];
     int i;

     fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>> BEGIN\n");
     fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>> [polyVectorList getCount] = %d\n", [polyVectorList getCount]);
     fflush(0);

     theSelectedPolyVector = theReferencePolyVector;
     if([polyVectorList getCount] == 0)
     {
             exit(99);
     }

     if([polyVectorList getCount] > 1)
     {
          theReferencePolyVector = (PolyVector *) [polyVectorList getFirst];
          for(i = 1; i < listCount; i++)
          {
              theNextPolyVector = (PolyVector *) [polyVectorList atOffset: i];
     
              if(theNextPolyVector == theReferencePolyVector)
              {
                    theSelectedPolyVector = theReferencePolyVector;
                    continue;
              } 
             
              fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>>   myXCoordinate = %f\n",   myXCoordinate);
              fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>>   myXCoordinate = %f\n",   myXCoordinate);
              fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>>   theReferencePolyVector->label = %d\n",   theReferencePolyVector->label);
              fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>>   theReferencePolyVector->theta = %f\n",   theReferencePolyVector->theta);
              fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>>   theReferencePolyVector xCoordinate = %f\n",   theReferencePolyVector->x1 + myXCoordinate);
              fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>>   theReferencePolyVector yCoordinate = %f\n",   theReferencePolyVector->x2 + myYCoordinate);
              fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>> theNextPolyVector->label = %d\n",   theNextPolyVector->label);
              fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>> theNextPolyVector xCoordinate = %f\n", theNextPolyVector->x1 + myXCoordinate);
              fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>> theNextPolyVector yCoordinate = %f\n", theNextPolyVector->x2 + myYCoordinate);
              fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>> theNextPolyVector->theta = %f\n", theNextPolyVector->theta);
              fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>> fabs(theReferencePolyVector->theta - theNextPolyVector->theta) = %f\n", fabs(theReferencePolyVector->theta - theNextPolyVector->theta));
              fflush(0);
              //
              // is the reference poly vector the one we want?
              //
              if(fabs(theReferencePolyVector->theta - theNextPolyVector->theta) <= 0.1745)
              //if(fabs(theReferencePolyVector->theta - theNextPolyVector->theta) <= 0.1500)
              {
                     [closePolyVectors addLast: (void *) theNextPolyVector]; 
              }
              else if(fabs(theReferencePolyVector->theta - theNextPolyVector->theta) > 0.1745)
              {
                    break;

              } 
          } // for

          //
          // Now, get our vector
          //
          if([closePolyVectors getCount] != 0)
          {
                theSelectedPolyVector = (PolyVector *) [closePolyVectors getLast];
          }
          else
          {
                theSelectedPolyVector = theReferencePolyVector;
          }



          theSelectedVectorCartX =  theSelectedPolyVector->x1 + myXCoordinate;
          theSelectedVectorCartY =  theSelectedPolyVector->x2 + myYCoordinate;
     } 
     else
     {
          theSelectedPolyVector = (PolyVector *) [polyVectorList getFirst];
          theSelectedVectorCartX =  theSelectedPolyVector->x1 + myXCoordinate;
          theSelectedVectorCartY =  theSelectedPolyVector->x2 + myYCoordinate;
     }


     if(theSelectedPolyVector == (PolyVector *) nil)
     {
          exit(22);
     } 

     fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>>   myXCoordinate = %f\n",   myXCoordinate);
     fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>>   myXCoordinate = %f\n",   myXCoordinate);
     fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>> the selected vector >>>> thePreviousPolyVector->label = %d\n",   theReferencePolyVector->label);
     fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>> thePreviousPolyVector->theta = %f\n", theReferencePolyVector->theta);
     fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>> fabs(theReferencePolyVector->theta - theNextPolyVector->theta) = %f\n", fabs(theReferencePolyVector->theta - theNextPolyVector->theta));
     fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>> theNextPolyVector xCoordinate = %f\n", theNextPolyVector->x1 + myXCoordinate);
     fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>> theNextPolyVector yCoordinate = %f\n", theNextPolyVector->x2 + myYCoordinate);

     fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>>   myXCoordinate = %f\n",   myXCoordinate);
     fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>>   myXCoordinate = %f\n",   myXCoordinate);
     fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>> theSelectedPolyVector xCoordinate = %f\n", theSelectedPolyVector->x1 + myXCoordinate);
     fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>> theSelectedPolyVector yCoordinate = %f\n", theSelectedPolyVector->x2 + myYCoordinate);

     fprintf(stdout, "ChooseCoords >>>> selectNextVector >>>> END\n");
     fflush(0);

    return self;
}


////////////////////////////////
//
// getXCoordinateOfNextVector
//
////////////////////////////////
- (double) getXCoordinateOfSelectedVector
{
   return theSelectedVectorCartX;
}


////////////////////////////////
//
// getYCoordinateOfNextVector
//
////////////////////////////////
- (double) getYCoordinateOfSelectedVector
{
   return theSelectedVectorCartY;
}



////////////////////////////////////////////
//
// drop
//
///////////////////////////////////////////
- (void) drop
{


     if([polyVectorList getCount] > 0)
     {
          id <ListIndex> ndx = nil;
          PolyVector* polyVector = (PolyVector *) nil;

          ndx = [polyVectorList listBegin:scratchZone];
          while(([ndx getLoc] != End) && ((polyVector = (PolyVector *) [ndx next]) != (PolyVector *) nil))
          {
                 [scratchZone free: polyVector];
                 polyVector = (PolyVector *) nil;
          }
          [ndx drop];

          [polyVectorList drop];
          polyVectorList = nil;
     }

     [super drop];
}

@end

