 /*
 *  IconsViewer.h: Interface and declarations for the IconsViewer Class 
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

#ifndef ICONSVIEWER_H
#define ICONSVIEWER_H

#include <AppKit/NSView.h>
  #ifdef GNUSTEP 
#include "ViewersProtocol.h"
  #else
#include <GWorkspace/ViewersProtocol.h>
  #endif

@class NSString;
@class NSArray;
@class NSDictionary;
@class NSNotification;
@class NSFileManager;
@class PathIcon;
@class IconsPath;
@class IconsPanel;
@class NSScrollView;
@class GWScrollView;
@class IconsViewerPref;

@interface IconsViewer : NSView <ViewersProtocol, NSCopying>
{
  IconsPanel *panel;
  IconsPath *iconsPath;
  GWScrollView *pathsScroll;
	NSScrollView *panelScroll;
  BOOL usesShelf;
  BOOL viewsapps;
  BOOL autoSynchronize;
  BOOL firstResize;
  int resizeIncrement;
  int columns;
  float columnsWidth;
  NSString *rootPath;
  NSString *lastPath;  
	NSArray *selectedPaths;
	NSMutableArray *savedSelection;	
  NSMutableArray *watchedPaths;
  IconsViewerPref *prefs;
	id delegate;
	id gworkspace;
  NSFileManager *fm;
}

- (void)checkUsesShelf;

- (void)validateRootPathAfterOperation:(NSDictionary *)opdict;

- (void)fileSystemWillChange:(NSNotification *)notification;

- (void)fileSystemDidChange:(NSNotification *)notification;

- (void)sortTypeDidChange:(NSNotification *)notification;

- (void)watcherNotification:(NSNotification *)notification;

- (void)setWatchers;

- (void)setWatcherForPath:(NSString *)path;

- (void)unsetWatcherForPath:(NSString *)path;

- (void)unsetWatchersFromPath:(NSString *)path;

- (void)reSetWatchersFromPath:(NSString *)path;

- (void)openCurrentSelection:(NSArray *)paths newViewer:(BOOL)newv;

- (void)clickOnIcon:(PathIcon *)icon;

- (void)doubleClickOnIcon:(PathIcon *)icon newViewer:(BOOL)isnew;

- (void)synchronize;

- (void)closeNicely;

- (void)close:(id)sender;

@end

//
// Methods Implemented by the Delegate 
//

@interface NSObject (ViewerDelegateMethods)

- (void)setTheSelectedPaths:(id)paths;

- (NSArray *)selectedPaths;

- (void)setTitleAndPath:(id)apath selectedPaths:(id)paths;

- (void)addPathToHistory:(NSArray *)paths;

- (void)updateTheInfoString;

- (int)browserColumnsWidth;

- (int)iconCellsWidth;

- (int)getWindowFrameWidth;

- (int)getWindowFrameHeight;

- (void)startIndicatorForOperation:(NSString *)operation;

- (void)stopIndicatorForOperation:(NSString *)operation;

@end

//
// IconsPanel Delegate Methods
//

@interface IconsViewer (IconsPanelDelegateMethods)

- (void)setTheSelectedPaths:(id)paths;

- (void)openTheCurrentSelection:(id)paths newViewer:(BOOL)newv;

- (int)iconCellsWidth;

@end

//
// IconsPath Delegate Methods
//

@interface IconsViewer (IconsPathDelegateMethods)

- (void)clickedIcon:(id)anicon;

- (void)doubleClickedIcon:(id)anicon newViewer:(BOOL)isnew;

@end

#endif // ICONSVIEWER_H
