 /*
 *  Viewer.h: Interface and declarations for the Viewer Class 
 *  of the GNUstep GWRemote application
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

#ifndef VIEWER_H
#define VIEWER_H

#include <AppKit/NSView.h>

@class NSString;
@class NSMutableArray;
@class NSFileManager;
@class NSDictionary;
@class NSNotification;
@class Browser2;

@interface Viewer : NSView 
{
  NSString *serverName;
  Browser2 *browser;
  int resizeIncrement;
  int columns;
  float columnsWidth;  
  NSString *rootPath;
  NSString *lastPath;  
	NSArray *selectedPaths;
  BOOL autoSynchronize;
  BOOL viewsapps;
  NSMutableArray *watchedPaths;  
	id delegate;
	id gwremote;
}

- (void)setRootPath:(NSString *)rpath 
         viewedPath:(NSString *)vpath 
          selection:(NSArray *)selection
           delegate:(id)adelegate
           viewApps:(BOOL)canview
             server:(NSString *)sname;

- (void)setCurrentSelection:(NSArray *)paths;

- (void)setSelectedPaths:(NSArray *)paths;

- (NSArray *)selectedPaths;

- (NSString *)currentViewedPath;

- (void)validateRootPathAfterOperation:(NSDictionary *)opdict;

- (void)fileSystemDidChange:(NSDictionary *)info;

- (void)setWatchers;

- (void)setWatcherForPath:(NSString *)path;

- (void)unsetWatchers;

- (void)unsetWatcherForPath:(NSString *)path;

- (void)unsetWatchersFromPath:(NSString *)path;

- (void)reSetWatchersFromPath:(NSString *)path;

- (void)sortTypeDidChange:(NSNotification *)notification;

- (NSSize)resizeIncrements;

- (void)setResizeIncrement:(int)increment;

- (void)setAutoSynchronize:(BOOL)value;

- (NSPoint)locationOfIconForPath:(NSString *)path;

- (NSPoint)positionForSlidedImage;

- (id)viewerView;

- (BOOL)viewsApps;

- (void)selectAll;

- (void)renewAll;

- (void)closeNicely;

- (void)close:(id)sender;

- (id)delegate;

- (void)setDelegate:(id)anObject;

@end

//
// Methods Implemented by the Delegate 
//
@interface NSObject (ViewerDelegateMethods)

- (void)setTheSelectedPaths:(id)paths;

- (NSArray *)selectedPaths;

- (void)setTitleAndPath:(id)apath selectedPaths:(id)paths;

- (void)updateTheInfoString;

- (int)browserColumnsWidth;

- (int)iconCellsWidth;

- (int)getWindowFrameWidth;

- (int)getWindowFrameHeight;

- (void)startIndicatorForOperation:(NSString *)operation;

- (void)stopIndicatorForOperation:(NSString *)operation;

@end

@interface Viewer (Browser2DelegateMethods)

- (void)currentSelectedPaths:(NSArray *)paths;

- (void)openSelectedPaths:(NSArray *)paths newViewer:(BOOL)isnew;

@end

#endif // VIEWER_H
