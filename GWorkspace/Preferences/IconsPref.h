/*
 *  Interface and declarations for the IconsPref Class 
 *  of the GNUstep GWorkspace application
 *
 *  Copyright (c) 2002 Enrico Sersale <enrico@imago.ro>
 *  
 *  Author: Enrico Sersale
 *  Date: September 2002
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

#ifndef ICONS_PREF_H
#define ICONS_PREF_H

#include <Foundation/NSObject.h>
  #ifdef GNUSTEP 
#include "PreferencesProtocol.h"
  #else
#include <GWorkspace/PreferencesProtocol.h>
  #endif

@class GWorkspace;

@interface IconsPref : NSObject <PreferencesProtocol>
{
  IBOutlet id win;
  IBOutlet id prefbox;
  IBOutlet id thumbbox; 
  IBOutlet id thumbCheck; 
  IBOutlet id selectbox; 
  IBOutlet id animMatrix;
  IBOutlet id actChangesButt;  
  
  GWorkspace *gw;  
}

- (IBAction)setUnsetThumbnails:(id)sender;

- (IBAction)setUnsetAnimation:(id)sender;

- (IBAction)activateChanges:(id)sender;

@end

#endif // ICONS_PREF_H