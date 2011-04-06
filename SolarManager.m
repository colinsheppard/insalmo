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
#include <math.h>
#include <stdlib.h>


#import "SolarManager.h"


@implementation SolarManager

//
// CREATING
//
+ create: aZone
{
   SolarManager* anObj = [super create: aZone];

   anObj->latitude = -1;
   anObj->horizonAngle = -1;
   anObj->twilightLength = -1;


   anObj->pi = 3.14159265358979323846;
   anObj->twoPi = 2.0 * 3.14159265358979323846;

   return anObj;

}

+              create: aZone
         withLatitude: (double) aLatitude
     withHorizonAngle: (double) aHorizonAngle
   withTwilightLength: (double) aTwilightLength
{

   SolarManager* anObj = [super create: aZone];

   if((aLatitude < 0.0) || (aLatitude > 90.0))
   {
       fprintf(stderr, "ERROR: SolarManager >>>> create:withLatitude... >>>> aLatitude is not between zero and ninety\n");
       fflush(0);
       exit(1);
   }

   if((aHorizonAngle < 0.0) || (aHorizonAngle > 90.0))
   {
       fprintf(stderr, "ERROR: SolarManager >>>> create:withLatitude... >>>> aHorizonAngle is not between zero and ninety\n");
       fflush(0);
       exit(1);
   }

   if((aTwilightLength < 0.0) || (aTwilightLength > 12.0))
   {
       fprintf(stderr, "ERROR: SolarManager >>>> create:withLatitude... >>>> aTwilightLength is not between zero and twelve\n");
       fflush(0);
       exit(1);
   }

   anObj->latitude = aLatitude;
   anObj->horizonAngle = aHorizonAngle;
   anObj->twilightLength = aTwilightLength;

   anObj->pi = 3.14159265358979323846;
   anObj->twoPi = 2.0 * 3.14159265358979323846;

   return anObj;


}


//
// SETTING
//


////////////////////////////////
//
// setLatitude
//
////////////////////////////////
- setLatitude: (double) aLatitude
{
   if((aLatitude < 0.0) || (aLatitude > 90.0))
   {
       fprintf(stderr, "ERROR: SolarManager >>>> setLatitude >>>> aLatitude is not between zero and ninety\n");
       fflush(0);
       exit(1);
   }

   latitude = aLatitude;
   return self;
}


/////////////////////////////////////////
//
// setHorizonAngle
//
/////////////////////////////////////////
- setHorizonAngle: (double) aHorizonAngle
{
   if((aHorizonAngle < 0.0) || (aHorizonAngle > 90.0))
   {
       fprintf(stderr, "ERROR: SolarManager >>>> setHorizonAngle >>>> aHorizonAngle is not between zero and ninety\n");
       fflush(0);
       exit(1);
   }

   horizonAngle = aHorizonAngle;
   return self;
}


/////////////////////////////////////////////
//
// setTwilightLength
//
/////////////////////////////////////////////
- setTwilightLength: (double) aTwilightLength
{
   if((aTwilightLength < 0.0) || (aTwilightLength > 12.0))
   {
       fprintf(stderr, "ERROR: SolarManager >>>> setTwilightLength >>>> aTwilightLength is not between zero and twelve\n");
       fflush(0);
       exit(1);
   }

   twilightLength = aTwilightLength;
   return self;
}


//
// USING
//

///////////////////////////////////////////////////////////
//
// updateDayLengthWithJulianDay:
//
///////////////////////////////////////////////////////////
- (double) updateDayLengthWithJulianDate: (int) aJulianDate
{

   double horizonAngleR;
   double latitudeR;
   double delta;

   double numerator;
   double denominator;
   //double declination;
   double arcCosArg;


   if((aJulianDate < 1) || (aJulianDate > 366))
   {
       fprintf(stderr, "ERROR: SolarManager >>>> updateDayLengthWithJulianDate >>>> aJulianDate is not between 0 or 366\n");
       fflush(0);
       exit(1);
   }

   if(horizonAngle < 0)
   {
       fprintf(stderr, "ERROR: SolarManager >>>> updateDayLengthWithJulianDate >>>> horizonAngle has not been set\n");
       fflush(0);
       exit(1);
   }
   if(latitude < 0)
   {
       fprintf(stderr, "ERROR: SolarManager >>>> updateDayLengthWithJulianDate >>>> latitude has not been set\n");
       fflush(0);
       exit(1);
   }

   horizonAngleR = horizonAngle * pi/180.0;
   latitudeR = latitude * pi/180.0;

   delta = 0.4093*cos((twoPi/365.0) * (double) (172 - aJulianDate));


   numerator = sin(horizonAngleR) - (sin(latitudeR)*sin(delta));
   denominator = cos(latitudeR)*cos(delta); 

   //arcCosArg = (sin(horizonAngleR) - (sin(latitudeR)*sin(delta)))/(cos(latitudeR)*cos(delta));
   arcCosArg = numerator/denominator;

   if(arcCosArg > 1.0)
   {
       dayLength = 0.0;
   }
   else if (arcCosArg < -1.0)
   {
       dayLength = 24.0;
   }
   else
   {
       dayLength = (24.0/pi) * acos(arcCosArg);
   }

   //
   // Now, update th following variables
   //
   sunriseHour = 12.0 - (dayLength/2.0);
   sunsetHour = 12.0 + (dayLength/2.0);
   dawnHour = sunriseHour - twilightLength;
   duskHour = sunsetHour + twilightLength;


   /*
   declination = delta;
   fprintf(stdout, "SolarManager >>>> JulianDate = %d\n", aJulianDate);
   fprintf(stdout, "Solarmanager >>>> declination = %f\n", declination);
   fprintf(stdout, "Solarmanager >>>> numerator = %f\n", numerator);
   fprintf(stdout, "Solarmanager >>>> denominator = %f\n", denominator);
   fprintf(stdout, "Solarmanager >>>> dayLength = %f\n", dayLength);
   fflush(0);
   */ 





   return dayLength;
}

- (double) getDayLength
{
   return dayLength;
}

- (double) getSunriseHour
{
   return sunriseHour;
}

- (double) getSunsetHour
{
   return sunsetHour;
}

- (double) getDawnHour
{
   return dawnHour;
}

- (double) getDuskHour
{
   return duskHour;
}


- (double) getTemperatureAtHour: (double) anHour
           withDailyMinTemp: (double) aMinTemp
           withDailyMaxTemp: (double) aMaxTemp
           withDayLength: (double) aDayLength
           withMinTempLag: (double) aMinTempLag
           withMaxTempLag: (double) aMaxTempLag
           withBCoefficient: (double) aBCoef
{
    double airTempAtHour;
    double minTempHour;
    double intermed1;
    double intermed2;

    double aSunsetHour;

    if((anHour < 0.0) || (anHour > 24.0))
    {
         fprintf(stderr, "ERROR: SolarManager >>>> getTemperatureAtHour... >>>> anHour is not between 0 and 24\n");
         fflush(0);
         exit(1);
    }

    if((aDayLength < 0.0) || (aDayLength > 24.0))
    {
         fprintf(stderr, "ERROR: SolarManager >>>> getTemperatureAtHour... >>>> aDayLength is not between 0 and 24\n");
         fflush(0);
         exit(1);
    }

    if((aMinTempLag < 0.0) || (aMinTempLag > 24.0))
    {
         fprintf(stderr, "ERROR: SolarManager >>>> getTemperatureAtHour... >>>> aMinTempLag is not between 0 and 24\n");
         fflush(0);
         exit(1);
    }

    if((aMaxTempLag < 0.0) || (aMaxTempLag > 24.0))
    {
         fprintf(stderr, "ERROR: SolarManager >>>> getTemperatureAtHour... >>>> aMaxTempLag is not between 0 and 24\n");
         fflush(0);
         exit(1);
    }

    minTempHour = 12.0 - (aDayLength/2.0) + aMinTempLag;
    aSunsetHour = 12.0 + (aDayLength/2.0);

    if(anHour > aSunsetHour)
    {
         intermed1 = aDayLength - aMinTempLag;

         intermed2 =   (aMaxTemp - aMinTemp)
                     * sin(pi*intermed1/(aDayLength + 2.0*aMaxTempLag)) + aMinTemp;

         airTempAtHour =   aMinTemp 
                       + (intermed2 - aMinTemp) 
                       * exp(-aBCoef * (anHour - aSunsetHour)/(24.0 - aDayLength));
    }
    else if(anHour < minTempHour)
    {
         intermed1 = aDayLength - aMinTempLag;

         intermed2 =   (aMaxTemp - aMinTemp)
                     * sin(pi*intermed1/(aDayLength + 2.0*aMaxTempLag)) + aMinTemp;

         airTempAtHour =   aMinTemp 
                       + (intermed2 - aMinTemp)
                       * exp(-aBCoef * (24.0 - aSunsetHour + anHour)/(24.0 - aDayLength));
    }
    else
    {
         airTempAtHour =  (aMaxTemp - aMinTemp)
                       * sin(pi*(anHour - minTempHour)/(aDayLength + 2.0*aMaxTempLag))
                       + aMinTemp;
 
    }
   

   return airTempAtHour;
}


- (double) getDailyMeanInsolationWithJulianDate: (int) aJulianDate
                                 withCloudCover: (double) aCloudCover
                                 withCalibParam: (double) aCalibParam
{
   double dailyInsolation;
   double extraTerrIns;
   double theta;
   double h;
   double delta;
   double percentSunshine;
   double cloudCorrection;
   double horizonAngleR = horizonAngle * (pi/180.0);
   double latitudeR = latitude * (pi/180.0);

   double arcCosArg;

   double numerator;
   double denominator;

   /*
   double firstTerm;
   double secondTerm;
   double thirdTerm;
   */

   if((aJulianDate < 1) || (aJulianDate > 366))
   {
       fprintf(stderr, "ERROR: SolarManager >>>> getDailyMeanInsolationWithJulianDate... >>>> aJulianDate is not between 1 and 366\n");
       fflush(0);
       exit(1);
   }

   if((aCloudCover < 0.0) || (aCloudCover > 1.0))
   {
       fprintf(stderr, "ERROR: SolarManager >>>> getDailyMeanInsolationWithJulianDate... >>>> aCloudCover is not between 0 and 1\n");
       fflush(0);
       exit(1);
   }


   theta = (twoPi/365) * (aJulianDate - 2);

   delta = 0.4093*cos((twoPi/365)*(172 - aJulianDate));

   numerator = sin(horizonAngleR) - (sin(latitudeR)*sin(delta));
   denominator = cos(latitudeR)*cos(delta);
   
   //arcCosArg = (sin(horizonAngleR) - (sin(latitudeR)*sin(delta)))/(cos(latitudeR)*cos(delta));
   arcCosArg = numerator/denominator;
   
   if(arcCosArg > 1.0)
   {
       h = 0.0;
   }
   else if(arcCosArg < -1.0)
   {
       h = pi;
   }
   else
   {
       h = acos(arcCosArg);
   }
   

   extraTerrIns =  (1377.0/pi) 
                  * pow((1.0+0.01672*cos(theta)),2)/(1-pow(0.01672,2))
                  * (h*sin(latitudeR)*sin(delta)
                  + sin(h)*cos(latitudeR)*cos(delta));

   percentSunshine = 1.0 - pow(aCloudCover, 5/3);
   cloudCorrection = 0.22 + 0.78*pow(percentSunshine, 2/3);


   /*
   firstTerm = (1377/pi);
   secondTerm = pow((1.0+0.01672*cos(theta)),2)/(1-pow(0.01672,2)); 
   thirdTerm = h*sin(latitudeR)*sin(delta)
               + sin(h)*cos(latitudeR)*cos(delta);


   fprintf(stdout, "SolarManager >>>> firstTerm = %f secondTerm = %f thirdTerm = %f \n", firstTerm, secondTerm, thirdTerm);
   fprintf(stdout, "SolarManager >>>> delta = %f numerator = %f denominator = %f \n", delta, numerator, denominator);
   fprintf(stdout, "SolarManager >>>> h = %f extraTerrIns = %f cloudCorrection = %f aCalibParam = %f\n", h, extraTerrIns, cloudCorrection, aCalibParam);
   fflush(0);
   */

   dailyInsolation = extraTerrIns * cloudCorrection * aCalibParam;

   return dailyInsolation;
}


- (double) getInsolationAtHour: (double) anHour
       withDailyMeanInsolation: (double) aMeanInsolation
               withSunriseHour: (double) aSunriseHour
                withSunsetHour: (double) aSunsetHour
{
   double insolationAtHour;

   if((anHour < 0) || (anHour > 24))
   {
       fprintf(stderr, "ERROR: SolarManager >>>> getInsolationAtHour... >>>> anHour is not between 0 and 24\n");
       fflush(0);
       exit(1);
   }

   if((aSunriseHour < 0) || (aSunriseHour > 24))
   {
       fprintf(stderr, "ERROR: SolarManager >>>> getInsolationAtHour... >>>> aSunriseHour is not between 0 and 24\n");
       fflush(0);
       exit(1);
   }

   if((aSunsetHour < 0) || (aSunsetHour > 24))
   {
       fprintf(stderr, "ERROR: SolarManager >>>> getInsolationAtHour... >>>> aSunsetHour is not between 0 and 24\n");
       fflush(0);
       exit(1);
   }
   if(aSunriseHour == aSunsetHour)
   {
       fprintf(stderr, "ERROR: SolarManager >>>> getInsolationAtHour... >>>> aSunriseHour equals aSunsetHour \n");
       fflush(0);
       exit(1);
   }


   
   if(anHour < aSunriseHour)
   {
       insolationAtHour = 0.0;
   }
   else if(anHour > aSunsetHour)
   {
       insolationAtHour = 0.0;
   }
   else 
   {
       insolationAtHour =  aMeanInsolation * (pi/2) 
                          * sin(pi*(anHour - aSunriseHour)/(aSunsetHour - aSunriseHour))
                          / ((aSunsetHour - aSunriseHour)/24.0); 
   }

   return insolationAtHour;
}



//
// Clean-up
//
- (void) drop
{
    [super drop];
}

@end

