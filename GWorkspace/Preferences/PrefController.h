/*
 *  Interface and declarations for the PrefController Class 
 *  of the GNUstep GWorkspace application
 *
 *  Copyright (c) 2001 Enrico Sersale <enrico@imago.ro>
 *  
 *  Author: Enrico Sersale
 *  Date: August 2001
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#ifndef PREF_CONTROLLER_H
#define PREF_CONTROLLER_H

#include <Foundation/NSObject.h>
  #ifdef GNUSTEP 
#include "PreferencesProtocol.h"
  #else
#include <GWorkspace/PreferencesProtocol.h>
  #endif

@class NSMutableArray;
@class NSView;

@interface PrefController : NSObject
{
  IBOutlet id win;
  IBOutlet id topBox;
  IBOutlet id popUp;
  IBOutlet id viewsBox;
  NSMutableArray *preferences;
  id currentPref;
}

- (void)activate;

- (void)addPreference:(id <PreferencesProtocol>)anobject;

- (void)removePreference:(id <PreferencesProtocol>)anobject;

- (IBAction)activatePrefView:(id)sender;

- (void)updateDefaults;

- (id)myWin;

@end

#endif // PREF_CONTROLLER_H