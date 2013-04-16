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




#include <time.h>
#include <objectbase.h>

@protocol TroutModelSwarm

- (time_t)getModelTime;
- addToEmptyReddList: aRedd;

//- createNewFishWithSpeciesIndex: (int) speciesNdx  
//                        Species: (id <Symbol>) species
//                         Length: (double) fishLength;

- addAFish: aTrout;
- (id <List>) getLiveFishList;
- (BOOL) getAppendFiles;
- (int) getScenario;
- (int) getReplicate;
- (FILE *) getReddSummaryFilePtr;
- (FILE *) getReddReportFilePtr;


//- createANewFishFrom: aRedd;
- addToKilledList: aFish;
- (id <List>) getReddList;
- addToNewOutmigrants: aJuve;

- (int) getNumberOfSpecies;
- (id <Symbol>) getSpeciesSymbolWithName: (char *) aName;
- (id <List>) getSpeciesSymbolList;
- (id <Zone>) getModelZone;

- (id <Symbol>) getFishMortalitySymbolWithName: (char *) aName;
- (id <Symbol>) getReddMortalitySymbolWithName: (char *) aName;
- (id <Symbol>) getAgeSymbolForAge: (int) anAge;
- (id) createNewFishWithSpeciesIndex: (int) speciesNdx  
                           Species: (id <Symbol>) species
                            Length: (double) fishLength
                            Sex: (id <Symbol>) sex;
- (id <Symbol>) getOutmigrationSymbol;
- (int) getNumOutmigrants;

- (id <List>) getAgeSymbolList;

- (id <List>) getLifestageSymbolList;
- (id <Symbol>) getAdultLifestageSymbol;
- (id <Symbol>) getJuvenileLifestageSymbol;

- (id <Symbol>) getSizeSymbolForLength: (double) aLength;
- (id <List>) getSizeSymbolList;
- (id <Symbol>) getReachSymbolWithName: (char *) aName;
//- (id <BinomialDist>) getReddBinomialDist;
- getReddBinomialDist;
- updateTkEventsFor: aReach;

- switchColorRepFor: aHabitatSpace;
- (int) getJuvenileSuperindividualRatio;


@end

@class TroutModelSwarm;
