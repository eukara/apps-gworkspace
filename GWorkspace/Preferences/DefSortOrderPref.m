/*  -*-objc-*-
 *  DefSortOrderPref.m: Implementation of the DefSortOrderPref Class 
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

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
  #ifdef GNUSTEP 
#include "GWFunctions.h"
  #else
#include <GWorkspace/GWFunctions.h>
  #endif
#include "DefSortOrderPref.h"
#include "GWorkspace.h"
#include "GNUstep.h"

#define byname 0
#define bykind 1
#define bydate 2
#define bysize 3
#define byowner 4

static NSString *nibName = @"DefSortOrderPref";

@implementation DefSortOrderPref

- (void)dealloc
{
	RELEASE (prefbox);
  [super dealloc];
}

- (id)init
{
	self = [super init];
	if(self) {
		if ([NSBundle loadNibNamed: nibName owner: self] == NO) {
      NSLog(@"failed to load %@!", nibName);
    } else {
      RETAIN (prefbox);
      RELEASE (win);

      gw = [GWorkspace gworkspace];	
		  sortType = [gw defaultSortType];
		  [matrix selectCellAtRow: sortType column: 0];	
      
      [setButt setEnabled: NO];	
 
	    /* Internationalization */
	    [setButt setTitle: NSLocalizedString(@"Set", @"")];
	    [selectbox setTitle: NSLocalizedString(@"Sort by", @"")];
	    [sortinfo1 setStringValue: NSLocalizedString(@"The method will apply to all the folders", @"")];
	    [sortinfo2 setStringValue: NSLocalizedString(@"that have no order specified", @"")]; 
	    [[matrix cellAtRow:0 column:0] setStringValue: NSLocalizedString(@"Name", @"")];
	    [[matrix cellAtRow:1 column:0] setStringValue: NSLocalizedString(@"Kind", @"")];
	    [[matrix cellAtRow:2 column:0] setStringValue: NSLocalizedString(@"Date", @"")];
	    [[matrix cellAtRow:3 column:0] setStringValue: NSLocalizedString(@"Size", @"")];
	    [[matrix cellAtRow:4 column:0] setStringValue: NSLocalizedString(@"Owner", @"")];
    }
	}
	
	return self;
}

- (NSView *)prefView
{
  return prefbox;
}

- (NSString *)prefName
{
  return NSLocalizedString(@"Sorting Order", @"");
}

- (void)changeType:(id)sender
{
	sortType = [[sender selectedCell] tag];
	[setButt setEnabled: YES];
}

- (void)setNewSortType:(id)sender
{
  [gw setDefaultSortType: sortType];
	[setButt setEnabled: NO];
}

@end