/* GWSpatialViewer.m
 *  
 * Copyright (C) 2004 Free Software Foundation, Inc.
 *
 * Author: Enrico Sersale <enrico@imago.ro>
 * Date: June 2004
 *
 * This file is part of the GNUstep GWorkspace application
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#include <AppKit/AppKit.h>
#include <math.h>
#include "GWSpatialViewer.h"
#include "GWViewersManager.h"
#include "GWViewerWindow.h"
#include "GWViewerBrowser.h"
#include "GWViewerIconsView.h"
#include "GWViewerPathsPopUp.h"
#include "GWorkspace.h"
#include "FSNodeRep.h"
#include "FSNIcon.h"
#include "FSNFunctions.h"
 
#define DEFAULT_INCR 150
#define MIN_W_HEIGHT 180

@implementation GWSpatialViewer

- (void)dealloc
{
  RELEASE (baseNode);
  TEST_RELEASE (lastSelection);
  RELEASE (watchedNodes);
  RELEASE (watchedSuspended);
  RELEASE (vwrwin);
  RELEASE (viewType);
  
	[super dealloc];
}

- (id)initForNode:(FSNode *)node
         inWindow:(GWViewerWindow *)win
    showSelection:(BOOL)showsel
{
  self = [super init];
  
  if (self) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	      
    NSString *prefsname = [NSString stringWithFormat: @"viewer_at_%@", [node path]];
    NSDictionary *viewerPrefs = nil;
    id defEntry;

    ASSIGN (baseNode, [FSNode nodeWithRelativePath: [node path] parent: nil]);
    lastSelection = nil;
    watchedNodes = [NSMutableArray new];
    watchedSuspended = [NSMutableArray new];
    manager = [GWViewersManager viewersManager];
    gworkspace = [GWorkspace gworkspace];
    spatial = YES;

    defEntry = [defaults objectForKey: @"browserColsWidth"];
    if (defEntry) {
      resizeIncrement = [defEntry intValue];
    } else {
      resizeIncrement = DEFAULT_INCR;
    }

    rootviewer = ([[baseNode path] isEqual: path_separator()]
                && ([[manager viewersForBaseNode: baseNode] count] == 0));

    if ([baseNode isWritable] && (rootviewer == NO)) {
		  NSString *dictPath = [[baseNode path] stringByAppendingPathComponent: @".gwdir"];

      if ([[NSFileManager defaultManager] fileExistsAtPath: dictPath]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: dictPath];

        if (dict) {
          viewerPrefs = [dict copy];
        }   
      }
    }

    if (viewerPrefs == nil) {
      defEntry = [defaults dictionaryForKey: prefsname];

      if (defEntry) {
        viewerPrefs = [defEntry copy];
      } else {
        viewerPrefs = [NSDictionary new];
      }
    }

    viewType = [viewerPrefs objectForKey: @"viewtype"];

    if (viewType == nil) {
      viewType = @"Icon";
    }
    if (([viewType isEqual: @"Icon"] == NO)
              && ([viewType isEqual: @"Browser"] == NO)) {
      viewType = @"Icon";
    }

    RETAIN (viewType);

    ASSIGN (vwrwin, win);
    [vwrwin setReleasedWhenClosed: NO];
    [vwrwin setDelegate: self];
    [vwrwin setMinSize: NSMakeSize(resizeIncrement * 2, MIN_W_HEIGHT)];    
    [vwrwin setResizeIncrements: NSMakeSize(resizeIncrement, 1)];

    defEntry = [viewerPrefs objectForKey: @"geometry"];

    if (defEntry) {
      [vwrwin setFrameFromString: defEntry];
    } else {
      [vwrwin setFrame: NSMakeRect(200, 200, resizeIncrement * 3, 400) 
               display: NO];
    }

    if (rootviewer) {
      [vwrwin setTitle: NSLocalizedString(@"File Viewer", @"")];
    } else {
      [vwrwin setTitle: [NSString stringWithFormat: @"%@ - %@", [node name], [node parentPath]]];   
    }

    [self createSubviews];

    if ([viewType isEqual: @"Icon"]) {
      nodeView = [[GWViewerIconsView alloc] initForViewer: self];

    } else if ([viewType isEqual: @"Browser"]) {
      nodeView = [[GWViewerBrowser alloc] initWithBaseNode: baseNode
                                      inViewer: self
		                            visibleColumns: visibleCols
                                      scroller: [scroll horizontalScroller]
                                    cellsIcons: YES
                                 editableCells: YES       
                               selectionColumn: NO];
    }

	  [scroll setDocumentView: nodeView];	
    RELEASE (nodeView);                 
    [nodeView showContentsOfNode: baseNode]; 

    /*
    * Beeing "spatial", we always set the selection in the browser
    */      
    if (showsel || ([nodeView isSingleNode] == NO)) {
      defEntry = [viewerPrefs objectForKey: @"lastselection"];
    
      if (defEntry) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSMutableArray *selection = [defEntry mutableCopy];
        int count = [selection count];
        int i;

        for (i = 0; i < count; i++) {
          NSString *s = [selection objectAtIndex: i];

          if ([fm fileExistsAtPath: s] == NO){
            [selection removeObject: s];
            count--;
            i--;
          }
        }

        if ([selection count]) {
          [nodeView selectRepsOfPaths: selection];
        }

        RELEASE (selection);
      }
    }

    [self updeateInfoLabels];

    [self scrollToBeginning];
    
    RELEASE (viewerPrefs);
  }
  
  return self;
}

- (void)createSubviews
{
  NSRect r = [[vwrwin contentView] frame];
  float w = r.size.width;
	float h = r.size.height; 
  int boxh = 32;  
  int labelw = 106;
  int labelh = 20;
  int margin = 8;
  unsigned int resizeMask;

  mainView = [[NSView alloc] initWithFrame: r];
  [mainView setAutoresizingMask: (NSViewWidthSizable | NSViewHeightSizable)];

  r = NSMakeRect(0, h - boxh, w, boxh);
  topBox = [[NSView alloc] initWithFrame: r];
  resizeMask = NSViewNotSizable | NSViewWidthSizable | NSViewMinYMargin;
  [topBox setAutoresizingMask: resizeMask];
  [topBox setAutoresizesSubviews: YES];
  [mainView addSubview: topBox];
  RELEASE (topBox);

  r = NSMakeRect(margin, margin - 2, labelw, labelh);
  elementsLabel = [[NSTextField alloc] initWithFrame: r];
  [elementsLabel setFont: [NSFont systemFontOfSize: 10]];
  [elementsLabel setAlignment: NSLeftTextAlignment];
  [elementsLabel setDrawsBackground: NO];
  [elementsLabel setTextColor: [NSColor controlShadowColor]];
  [elementsLabel setBezeled: NO]; 
  [elementsLabel setEditable: NO]; 
  [elementsLabel setSelectable: NO];
  resizeMask = NSViewNotSizable | NSViewMaxXMargin;
  [elementsLabel setAutoresizingMask: resizeMask];
  [topBox addSubview: elementsLabel];
  RELEASE (elementsLabel);

  r = NSMakeRect(0, margin - 2, labelw, labelh);
  r.origin.x = (w / 2) - (labelw / 2);
  pathsPopUp = [[GWViewerPathsPopUp alloc] initWithFrame: r pullsDown: NO];
  resizeMask = NSViewNotSizable | NSViewMinXMargin | NSViewMaxXMargin;
  [pathsPopUp setAutoresizingMask: resizeMask];
  [pathsPopUp setTarget: self];
  [pathsPopUp setAction: @selector(popUpAction:)];
  [pathsPopUp setItemsToNode: baseNode];
  [topBox addSubview: pathsPopUp];
  RELEASE (pathsPopUp);

  r = NSMakeRect(w - labelw - margin, margin - 2, labelw, labelh);
  spaceLabel = [[NSTextField alloc] initWithFrame: r];
  [spaceLabel setFont: [NSFont systemFontOfSize: 10]];
  [spaceLabel setAlignment: NSRightTextAlignment];
  [spaceLabel setDrawsBackground: NO];
  [spaceLabel setTextColor: [NSColor controlShadowColor]];
  [spaceLabel setBezeled: NO]; 
  [spaceLabel setEditable: NO]; 
  [spaceLabel setSelectable: NO];
  resizeMask = NSViewNotSizable | NSViewMinXMargin;
  [spaceLabel setAutoresizingMask: resizeMask];
  [topBox addSubview: spaceLabel];
  RELEASE (spaceLabel);

  r = NSMakeRect(margin, 0, w - (margin * 2), h - boxh);
  scroll = [[NSScrollView alloc] initWithFrame: r];
  [scroll setBorderType: NSBezelBorder];
  [scroll setHasHorizontalScroller: YES];
  [scroll setHasVerticalScroller: [viewType isEqual: @"Icon"]];
  resizeMask = NSViewNotSizable | NSViewWidthSizable | NSViewHeightSizable;
  [scroll setAutoresizingMask: resizeMask];
  [mainView addSubview: scroll];
  RELEASE (scroll);

  visibleCols = rintf(r.size.width / [vwrwin resizeIncrements].width);  
  
  [vwrwin setContentView: mainView];
  RELEASE (mainView);
}

- (FSNode *)baseNode
{
  return baseNode;
}

- (BOOL)isShowingNode:(FSNode *)anode
{
  return [nodeView isShowingNode: anode];
}

- (BOOL)isShowingPath:(NSString *)apath
{
  return [nodeView isShowingPath: apath];
}

- (void)reloadNodeContents
{
  [nodeView reloadContents];
}

- (void)reloadFromNode:(FSNode *)anode
{
  if ([nodeView isShowingNode: anode]) {
    [nodeView reloadFromNode: anode];
  }
}

- (void)unloadFromNode:(FSNode *)anode
{
  if ([baseNode isEqual: anode] || [baseNode isSubnodeOfNode: anode]) {
    [self deactivate];
  } else if ([nodeView isShowingNode: anode]) {
    [nodeView unloadFromNode: anode];
  }
}

- (GWViewerWindow *)win
{
  return vwrwin;
}

- (id)nodeView
{
  return nodeView;
}

- (NSString *)viewType
{
  return viewType;
}

- (BOOL)isRootViewer
{
  return rootviewer;
}

- (BOOL)isSpatial
{
  return spatial;
}

- (int)vtype
{
  return (spatial ? SPATIAL : BROWSING);
}


- (void)activate
{
  [vwrwin makeKeyAndOrderFront: nil];
  [manager viewer: self didShowNode: baseNode];
}

- (void)deactivate
{
  [vwrwin close];
}

- (void)scrollToBeginning
{
  if ([nodeView isSingleNode]) {
    NSRect r = [nodeView frame];
    [nodeView scrollRectToVisible: NSMakeRect(0, r.size.height - 1, 1, 1)];	
  }
}

- (void)invalidate
{
  invalidated = YES;
}

- (BOOL)invalidated
{
  return invalidated;
}


- (void)setOpened:(BOOL)opened 
        repOfNode:(FSNode *)anode
{
  id rep = [nodeView repOfSubnode: anode];

  if (rep) {
    [rep setOpened: opened];
    
    if ([nodeView isSingleNode]) { 
      [rep select];
    }
  }
}

- (void)unselectAllReps
{
  [nodeView unselectOtherReps: nil];
  [nodeView selectionDidChange];
}

- (void)selectionChanged:(NSArray *)newsel
{
  FSNode *node;
  NSArray *components;
  int i, j, count;

  [manager selectionChanged: newsel];

  if (lastSelection && [newsel isEqual: lastSelection]) {
    return;
  }

  ASSIGN (lastSelection, newsel);
  [self updeateInfoLabels]; 
    
  node = [FSNode nodeWithRelativePath: [newsel objectAtIndex: 0] parent: nil];   
    
  if ([nodeView isSingleNode]) {    
    if ([node isEqual: baseNode] == NO) {
      return;
    }
  }
 
  if (([node isDirectory] == NO) || [node isPackage] || ([newsel count] > 1)) {
    if ([node isEqual: baseNode] == NO) { // if baseNode is a package 
      node = [FSNode nodeWithRelativePath: [node parentPath] parent: nil];
    }
  } 
    
  components = [FSNode nodeComponentsFromNode: baseNode toNode: node];
  count = [components count];

  for (i = 0; i < [watchedNodes count]; i++) {
    FSNode *n1 = [watchedNodes objectAtIndex: i];
    FSNode *n2 = nil;

    if (count > i) {
      n2 = [components objectAtIndex: i];  
    } else {
      i = count;
      break;
    }

    if ([n1 isEqual: n2] == NO) {
      break;
    }    
  }

  for (j = i; j < [watchedNodes count]; j++) {  
    [gworkspace removeWatcherForPath: [[watchedNodes objectAtIndex: j] path]];
  }

  for (j = i; j < [components count]; j++) { 
    [gworkspace addWatcherForPath: [[components objectAtIndex: j] path]];
  }
  
  [watchedNodes removeAllObjects];
  [watchedNodes addObjectsFromArray: components];
}

- (void)setSelectableNodesRange:(NSRange)range
{
  visibleCols = range.length;
}

- (void)updeateInfoLabels
{
  NSArray *reps;
  NSString *labelstr;
  NSDictionary *attributes;
  NSNumber *freefs;

  reps = [nodeView reps];
  labelstr = [NSString stringWithFormat: @"%i ", (reps ? [reps count] : 0)];
  labelstr = [labelstr stringByAppendingString: NSLocalizedString(@"elements", @"")];

  [elementsLabel setStringValue: labelstr];

  attributes = [[NSFileManager defaultManager] fileSystemAttributesAtPath: [[nodeView shownNode] path]];
	freefs = [attributes objectForKey: NSFileSystemFreeSize];

	if (freefs == nil) {  
		labelstr = NSLocalizedString(@"unknown volume size", @"");    
	} else {
		labelstr = [NSString stringWithFormat: @"%@ %@", 
                   sizeDescription([freefs unsignedLongLongValue]),
                                        NSLocalizedString(@"free", @"")];
	}

  [spaceLabel setStringValue: labelstr];
}

- (void)popUpAction:(id)sender
{
  NSString *path = [[sender selectedItem] representedObject];

  if ([path isEqual: [baseNode path]] == NO) {
    FSNode *node = [FSNode nodeWithRelativePath: path parent: nil];
    BOOL close = [sender closeViewer];
  
    if (close) {
      [pathsPopUp setTarget: nil];
    }
  
    [manager newViewerOfType: SPATIAL
                     forNode: node 
              closeOldViewer: (close ? self : nil)];
  } 
}


- (BOOL)involvedByFileOperation:(NSDictionary *)opinfo
{
  return [nodeView involvedByFileOperation: opinfo];
}

- (void)nodeContentsWillChange:(NSDictionary *)info
{
  NSString *operation = [info objectForKey: @"operation"];
  NSString *source = [info objectForKey: @"source"];
  NSString *destination = [info objectForKey: @"destination"];
  NSArray *files = [info objectForKey: @"files"];
  
  if ([operation isEqual: @"GWorkspaceRenameOperation"]) {
    files = [NSArray arrayWithObject: [destination lastPathComponent]];
    destination = [destination stringByDeletingLastPathComponent]; 
  }

  if ([operation isEqual: @"NSWorkspaceMoveOperation"] 
        || [operation isEqual: @"NSWorkspaceCopyOperation"]
        || [operation isEqual: @"NSWorkspaceLinkOperation"]
        || [operation isEqual: @"NSWorkspaceDuplicateOperation"]
        || [operation isEqual: @"GWorkspaceCreateDirOperation"]
        || [operation isEqual: @"GWorkspaceCreateFileOperation"]
        || [operation isEqual: @"GWorkspaceRenameOperation"]
			  || [operation isEqual: @"GWorkspaceRecycleOutOperation"]) { 
    if ([nodeView isShowingPath: destination]
                    || [baseNode isSubnodeOfPath: destination]) {
      [self suspendWatchersFromPath: destination];
    }
  }

  if ([operation isEqual: @"NSWorkspaceMoveOperation"]
        || [operation isEqual: @"NSWorkspaceDestroyOperation"]
				|| [operation isEqual: @"NSWorkspaceRecycleOperation"]
				|| [operation isEqual: @"GWorkspaceRecycleOutOperation"]
				|| [operation isEqual: @"GWorkspaceEmptyRecyclerOperation"]) {
    if ([nodeView isShowingPath: source]
                      || [baseNode isSubnodeOfPath: source]) {
      [self suspendWatchersFromPath: source]; 
    }
  }

  [nodeView nodeContentsWillChange: info];
}

- (void)nodeContentsDidChange:(NSDictionary *)info
{
  NSString *operation = [info objectForKey: @"operation"];
  NSString *source = [info objectForKey: @"source"];
  NSString *destination = [info objectForKey: @"destination"];
  NSArray *files = [info objectForKey: @"files"];

  [nodeView nodeContentsDidChange: info];
  
  if ([operation isEqual: @"GWorkspaceRenameOperation"]) {
    files = [NSArray arrayWithObject: [destination lastPathComponent]];
    destination = [destination stringByDeletingLastPathComponent]; 
  }

  if ([operation isEqual: @"NSWorkspaceMoveOperation"] 
        || [operation isEqual: @"NSWorkspaceCopyOperation"]
        || [operation isEqual: @"NSWorkspaceLinkOperation"]
        || [operation isEqual: @"NSWorkspaceDuplicateOperation"]
        || [operation isEqual: @"GWorkspaceCreateDirOperation"]
        || [operation isEqual: @"GWorkspaceCreateFileOperation"]
        || [operation isEqual: @"GWorkspaceRenameOperation"]
			  || [operation isEqual: @"GWorkspaceRecycleOutOperation"]) { 
    if ([nodeView isShowingPath: destination]
                        || [baseNode isSubnodeOfPath: destination]) {
      [self reactivateWatchersFromPath: destination];
    } 
    
    [self clearSuspendedWatchersFromPath: destination];
  }

  if ([operation isEqual: @"NSWorkspaceMoveOperation"]
        || [operation isEqual: @"NSWorkspaceDestroyOperation"]
				|| [operation isEqual: @"NSWorkspaceRecycleOperation"]
				|| [operation isEqual: @"GWorkspaceRecycleOutOperation"]
				|| [operation isEqual: @"GWorkspaceEmptyRecyclerOperation"]) {
    if ([nodeView isShowingPath: source]
                        || [baseNode isSubnodeOfPath: source]) {
      [self reactivateWatchersFromPath: source];
    } 
    
    [self clearSuspendedWatchersFromPath: source];
  }
}

- (void)suspendWatchersFromPath:(NSString *)path
{
  NSString *start = [baseNode isSubnodeOfPath: path] ? [baseNode path] : path;
  unsigned index = [FSNode indexOfNodeWithPath: start 
                                  inComponents: watchedNodes];

  if (index != NSNotFound) {
    int i;

    for (i = index; i < [watchedNodes count]; i++) {  
      NSString *path = [[watchedNodes objectAtIndex: i] path];
        
      [gworkspace removeWatcherForPath: path];
      [watchedSuspended addObject: path];
    }
  } 
}

- (void)reactivateWatchersFromPath:(NSString *)path
{
  NSString *start = [baseNode isSubnodeOfPath: path] ? [baseNode path] : path;
  unsigned index = [FSNode indexOfNodeWithPath: start 
                                  inComponents: watchedNodes];

  if (index != NSNotFound) {
    int count = [watchedNodes count];
    int i;
    
    for (i = index; i < count; i++) {
      FSNode *node = [watchedNodes objectAtIndex: i];
      NSString *path = [node path];
    
      if ([node isValid] && [node isDirectory]) {
        [gworkspace addWatcherForPath: path];
      } else {
        [watchedNodes removeObjectAtIndex: i];
        count--;
        i--;
      }
    }
  }
}

- (void)clearSuspendedWatchersFromPath:(NSString *)path
{
  int count = [watchedSuspended count];
  int i;

  for (i = 0; i < count; i++) {
    NSString *suspended = [watchedSuspended objectAtIndex: i];

    if ([suspended isEqual: path] || isSubpathOfPath(path, suspended)) {
      [watchedSuspended removeObjectAtIndex: i];
      count--;
      i--;
    }
  }
}

- (void)watchedPathChanged:(NSDictionary *)info
{
  if (invalidated == NO) {
    NSString *path = [info objectForKey: @"path"];
  
    if ([watchedSuspended containsObject: path] == NO) {
      if ([nodeView isShowingPath: path]) {
        [nodeView watchedPathChanged: info];
      }
    }
  }
}

- (NSArray *)watchedNodes
{
  return watchedNodes;
}


- (void)updateDefaults
{
  if ([baseNode isValid]) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	      
    NSString *prefsname = [NSString stringWithFormat: @"viewer_at_%@", [baseNode path]];
    NSString *dictPath = [[baseNode path] stringByAppendingPathComponent: @".gwdir"];
    NSMutableDictionary *updatedprefs = nil;
    id defEntry;
    
    [nodeView updateNodeInfo];
    
    if ([baseNode isWritable] && (rootviewer == NO)) {
      if ([[NSFileManager defaultManager] fileExistsAtPath: dictPath]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: dictPath];

        if (dict) {
          updatedprefs = [dict mutableCopy];
        }   
      }
  
    } else { 
      NSDictionary *prefs = [defaults dictionaryForKey: prefsname];
  
      if (prefs) {
        updatedprefs = [prefs mutableCopy];
      }
    }

    if (updatedprefs == nil) {
      updatedprefs = [NSMutableDictionary new];
    }

    [updatedprefs setObject: viewType forKey: @"viewtype"];

    defEntry = [nodeView selectedPaths];
    if (defEntry) {
      [updatedprefs setObject: defEntry forKey: @"lastselection"];
    }

    [updatedprefs setObject: [vwrwin stringWithSavedFrame] 
                     forKey: @"geometry"];

    if ([baseNode isWritable] && (rootviewer == NO)) {
      [updatedprefs writeToFile: dictPath atomically: YES];
    } else {
      [defaults setObject: updatedprefs forKey: prefsname];
    }
  
    RELEASE (updatedprefs);
  }
}

@end


//
// GWViewerWindow Delegate Methods
//
@implementation GWSpatialViewer (GWViewerWindowDelegateMethods)

- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
  NSArray *selection = [nodeView selectedPaths];  
  int count = [selection count];
  
  [vwrwin makeFirstResponder: nodeView];  

  [manager selectedSpatialViewerChanged: self];

  if (count == 0) {
    selection = [NSArray arrayWithObject: [[nodeView shownNode] path]];
    [manager synchronizeSelectionInParentOfViewer: self];
  
  } else if (count == 1) {
    if (([nodeView isSingleNode] == NO)
             || ([[selection objectAtIndex: 0] isEqual: [baseNode path]])) {
      [manager synchronizeSelectionInParentOfViewer: self];
    }
    
  } else if ([nodeView isSingleNode] == NO) {
    [manager synchronizeSelectionInParentOfViewer: self];
  }
  
  [self selectionChanged: selection];
}

- (BOOL)windowShouldClose:(id)sender
{
	return YES;
}

- (void)windowWillClose:(NSNotification *)aNotification
{
  if (invalidated == NO) {
    [self updateDefaults];
    [manager viewerWillClose: self]; 
  }
}

- (void)windowDidResize:(NSNotification *)aNotification
{
  if (nodeView) {
    [nodeView stopRepNameEditing];
    
    if ([nodeView isKindOfClass: [GWViewerBrowser class]]) { 
      [nodeView updateScroller];
    }
  }
}

- (void)openSelectionInNewViewer:(BOOL)newv
{
  [manager openSelectionInViewer: self closeSender: newv];
}

- (void)openSelectionAsFolder
{
  [manager openAsFolderSelectionInViewer: self];
}

- (void)newFolder
{
  [gworkspace newObjectAtPath: [[nodeView shownNode] path] 
                  isDirectory: YES];
}

- (void)newFile
{
  [gworkspace newObjectAtPath: [[nodeView shownNode] path] 
                  isDirectory: NO];
}

- (void)duplicateFiles
{
  [gworkspace duplicateFiles];
}

- (void)deleteFiles
{
  [gworkspace deleteFiles];
}

- (void)setViewerBehaviour:(id)sender
{
  [manager setBehaviour: [sender title] forViewer: self];
}

- (void)setViewerType:(id)sender
{
  NSString *title = [sender title];
  
	if ([title isEqual: NSLocalizedString(viewType, @"")] == NO) {
    NSArray *selection = [nodeView selectedPaths];
    int i;
    
    [nodeView updateNodeInfo];
    if ([nodeView isSingleNode] && ([selection count] == 0)) {
      selection = [NSArray arrayWithObject: [[nodeView shownNode] path]];
    }    
    RETAIN (selection);
    [scroll setDocumentView: nil];	
    
    if ([title isEqual: NSLocalizedString(@"Browser", @"")]) {
      nodeView = [[GWViewerBrowser alloc] initWithBaseNode: baseNode
                                      inViewer: self
		                            visibleColumns: visibleCols
                                      scroller: [scroll horizontalScroller]
                                    cellsIcons: YES
                                 editableCells: YES   
                               selectionColumn: NO]; 
      
      
   //   [nodeView setExtendedShowType: @"Role"]; // ATTENZIONE !!!!!!!!
      
            
      [scroll setHasVerticalScroller: NO];
      ASSIGN (viewType, @"Browser");
      
    } else if ([title isEqual: NSLocalizedString(@"Icon", @"")]) {
      nodeView = [[GWViewerIconsView alloc] initForViewer: self];
      [scroll setHasVerticalScroller: YES];
      ASSIGN (viewType, @"Icon");
    }

    [scroll setDocumentView: nodeView];	
    RELEASE (nodeView);                 
    [nodeView showContentsOfNode: baseNode]; 
    
    if ([selection count]) {
      [nodeView selectRepsOfPaths: selection];
    }
    
    DESTROY (selection);
    
    [self scrollToBeginning];

    [vwrwin makeFirstResponder: nodeView]; 

    for (i = 0; i < [watchedNodes count]; i++) {  
      [gworkspace removeWatcherForPath: [[watchedNodes objectAtIndex: i] path]];
    }
    [watchedNodes removeAllObjects];
    
    DESTROY (lastSelection);
    selection = [nodeView selectedPaths];
    
    if ([selection count] == 0) {
      selection = [NSArray arrayWithObject: [[nodeView shownNode] path]];
    }
    
    [self selectionChanged: selection];
  }
}

- (void)selectAllInViewer
{
	[nodeView selectAll];
}

- (void)showTerminal
{
  NSString *path;

  if ([nodeView isSingleNode]) {
	  path = [[nodeView shownNode] path];
    
  } else {
    NSArray *selection = [nodeView selectedNodes];
    
    if (selection) {
      FSNode *node = [selection objectAtIndex: 0];
      
      if ([selection count] > 1) {
        path = [node parentPath];
        
      } else {
        if ([node isDirectory] && ([node isPackage] == NO)) {
          path = [node path];
      
        } else {
          path = [node parentPath];
        }
      }
    } else {
      path = [[nodeView shownNode] path];
    }
  }

  [gworkspace startXTermOnDirectory: path];
}

- (BOOL)validateItem:(id)menuItem
{
  return YES;
}

@end













