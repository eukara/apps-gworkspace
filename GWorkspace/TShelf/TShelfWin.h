 /*
 *  TShelfWin.h: Interface and declarations for the TShelfWin Class 
 *  of the GNUstep GWorkspace application
 *
 *  Copyright (c) 2003 Enrico Sersale <enrico@imago.ro>
 *  
 *  Author: Enrico Sersale
 *  Date: August 2003
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

#ifndef TSHELF_WIN_H
#define TSHELF_WIN_H

#include <Foundation/Foundation.h>
#include <AppKit/NSWindow.h>

@class TShelfView;

@interface TShelfWin : NSWindow
{
  TShelfView *tView;
}

- (void)activate;

- (void)deactivate;

- (void)addTab;

- (void)removeTab;

- (void)renameTab;

- (void)updateIcons;

- (void)saveDefaults;

@end

#endif // TABBED_SHELF_WIN_H