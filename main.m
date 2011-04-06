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


#import <simtools.h>     // initSwarm () and swarmGUIMode
#import <simtoolsgui.h>  // GUISwarm
#import "ExperSwarm.h"
#import "ExperBatchSwarm.h"

// The main() function is the top-level place where everything starts.
// For a typical Swarm simulation, in main() you create a toplevel
// Swarm, let it build and activate, and set it to running.

int
main (int argc, const char **argv)
{
  id theTopLevelSwarm;
  id batchSwarm;

  // Swarm initialization: all Swarm apps must call this first.
  initSwarm (argc, argv);

  // swarmGUIMode is set in initSwarm(). It's set to be 1 if you
  // typed trout -batchmode. Otherwise, it's set to 0.
  
  if (swarmGUIMode == 1)
    {
      // We've got graphics, so make a full ObserverSwarm to get GUI objects
      theTopLevelSwarm = [ExperSwarm createBegin: globalZone];
      SET_WINDOW_GEOMETRY_RECORD_NAME (theTopLevelSwarm);
      theTopLevelSwarm = [theTopLevelSwarm createEnd];
      [theTopLevelSwarm buildObjects];
      [theTopLevelSwarm buildActions];
      [theTopLevelSwarm activateIn: nil];
      [theTopLevelSwarm go];
    }
  else {
      (void) fprintf(stderr, "In Batchmode \n");
       fflush(stderr);
      batchSwarm = [ExperBatchSwarm createBegin: globalZone];
      batchSwarm = [batchSwarm createEnd];
      [batchSwarm buildObjects];
      [batchSwarm buildActions];
      [batchSwarm activateIn: nil];
      [batchSwarm go];
  }


  // theTopLevelSwarm has finished processing, so it's time to quit.
  return 0;
}
