/*
 *  Fiend.h: Interface and declarations for the Fiend Class 
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

#ifndef FIEND_H
#define FIEND_H

#include <AppKit/NSView.h>

@class NSString;
@class NSArray;
@class NSNotification;
@class NSWindow;
@class NSImage;
@class NSMutableArray;
@class NSTextFieldCell;
@class NSButton;
@class FiendLeaf;
@class GWorkspace;

@interface Fiend : NSView 
{
  NSWindow *myWin;
  NSImage *tile;
  NSImage *leftArr;
  NSImage *rightArr;
  NSMutableDictionary *layers;
  NSString *currentName;
  
  NSMutableArray *leavesPlaces, *freePositions;
  
	NSTextFieldCell *namelabel;	
  NSButton *ffButt, *rewButt;
  
  BOOL leaveshidden;
  BOOL isDragTarget;

  GWorkspace *gw;
}

- (void)activate;

- (NSWindow *)myWin;

- (id)fiendLeafOfType:(NSString *)type withName:(NSString *)name;

- (NSPoint)positionOfLeaf:(id)aleaf;

- (BOOL)dissolveLeaf:(id)aleaf;

- (void)addLayer;

- (void)removeCurrentLayer;

- (void)renameCurrentLayer;

- (void)goToLayerNamed:(NSString *)lname;

- (void)switchLayer:(id)sender;

- (void)draggedFiendLeaf:(FiendLeaf *)leaf
                 atPoint:(NSPoint)location 
                 mouseUp:(BOOL)mouseup;

- (void)findFreePositions;

- (NSArray *)positionsAroundLeafAtPosX:(int)posx posY:(int)posy;

- (void)orderFrontLeaves;

- (void)hide;

- (void)verifyDraggingExited:(id)sender;

- (void)updateDefaults;

@end

@interface Fiend (DraggingDestination)

- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender;

- (unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender;

- (void)draggingExited:(id <NSDraggingInfo>)sender;

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender;

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender;

@end

#endif // FIEND_H