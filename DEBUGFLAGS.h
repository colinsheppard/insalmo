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


//#define DEBUG_TROUT_FISHPARAMS


//
// The following define flags are used
// in Trout.m
//
//#define DEBUG_SPAWN
//#define DEBUG_MOVE
//#define DEBUG_GROW
//#define DEBUG_FEEDING

//
// The following define flags used 
// in Redd.m
//
//#define DEBUG_REDD
//#define DEBUG_REDD_SCOUR
//#define DEBUG_REDD_DEWATER
//#define DEBUG_REDD_LOTEMP
//#define DEBUG_REDD_HITEMP

//
// The following define the debug flags used 
// each of the Survival Probability objects
//
// These flags must be defined when checking
// the values used when the survival probabilities
// create their logistic functions 
//

//#define DEBUG_HT_FISHPARAMS
//#define DEBUG_AQUATICPRED_FISHPARAMS
//#define DEBUG_POORCOND_FISHPARAMS
//
// The next one prints each time a fish accesses 
// spawning surv prob  see SpawningSP.m
//
//#define DEBUG_SPAWNING_FISHPARAMS
//#define DEBUG_STRANDING_FISHPARAMS
//#define DEBUG_TERRPRED_FISHPARAMS
//#define DEBUG_VELOCITY_FISHPARAMS

