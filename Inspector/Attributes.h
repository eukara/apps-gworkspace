/* Attributes.h
 *  
 * Copyright (C) 2004 Free Software Foundation, Inc.
 *
 * Author: Enrico Sersale <enrico@imago.ro>
 * Date: January 2004
 *
 * This file is part of the GNUstep Inspector application
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

#ifndef ATTRIBUTES_H
#define ATTRIBUTES_H

#include <Foundation/Foundation.h>

@class NSTextField;
@class NSImage;
@class TimeDateView;
@class Sizer;

@protocol SizerProtocol

- (oneway void)computeSizeOfPaths:(NSArray *)paths;

- (oneway void)stopComputeSize;

@end

@protocol AttributesSizeProtocol

- (oneway void)setSizer:(id)anObject;

- (oneway void)sizeReady:(NSString *)sizeStr;

@end


@interface Attributes : NSObject
{
  IBOutlet id win;
  IBOutlet id mainBox;

  IBOutlet id topBox;
  IBOutlet id iconView;
  IBOutlet id titleField;

  IBOutlet id linkToLabel;
  IBOutlet id linkToField;
  
  IBOutlet id sizeLabel;
  IBOutlet id sizeField;
  IBOutlet id calculateButt;
  IBOutlet id ownerLabel;
  IBOutlet id ownerField;
  IBOutlet id groupLabel;
  IBOutlet id groupField;

  IBOutlet id changedDateBox;
  IBOutlet id permsBox;

  IBOutlet id readLabel;
  IBOutlet id writeLabel;
  IBOutlet id executeLabel;
  IBOutlet id uLabel;
  IBOutlet id gLabel;
  IBOutlet id oLabel;
  IBOutlet id ureadbutt;
  IBOutlet id uwritebutt;
  IBOutlet id uexebutt;
  IBOutlet id greadbutt;
  IBOutlet id gwritebutt;
  IBOutlet id gexebutt;
  IBOutlet id oreadbutt;
  IBOutlet id owritebutt;
  IBOutlet id oexebutt; 
  IBOutlet id insideButt;

  IBOutlet id revertButt;
  IBOutlet id okButt;

	NSArray *insppaths;
	int pathscount;
  
	NSDictionary *attributes;
	BOOL iamRoot, isMyFile;
	NSImage *onImage, *offImage, *multipleImage;
	BOOL multiplePaths;
    
	NSString *currentPath;	
  
	TimeDateView *timeDateView;
	NSTextField *yearlabel;
  
  NSConnection *sizerConn;
  id sizer;
  BOOL autocalculate;
  id inspector;
  
	NSFileManager *fm;
	NSNotificationCenter *nc;  
}

- (NSView *)inspView;

- (NSString *)winname;

- (void)activateForPaths:(NSArray *)paths;

- (IBAction)permsButtonsAction:(id)sender;

- (IBAction)changePermissions:(id)sender;

- (IBAction)revertToOldPermissions:(id)sender;

- (void)setPermissions:(int)perms isActive:(BOOL)active;

- (int)getPermissions:(int)oldperms;

- (void)watchedPathDidChange:(NSData *)dirinfo;

- (void)setCalculateSizes:(BOOL)value;

- (IBAction)calculateSizes:(id)sender;

- (void)startSizer;

- (void)sizerConnDidDie:(NSNotification *)notification;

- (void)setSizer:(id)anObject;

- (void)sizeReady:(NSString *)sizeStr;

- (void)updateDefaults;

@end


@interface Sizer : NSObject
{
  id attributes;
  NSFileManager *fm;
}

+ (void)createSizerWithPorts:(NSArray *)portArray;

- (id)initWithAttributesConnection:(NSConnection *)conn;

- (void)computeSizeOfPaths:(NSArray *)paths;

@end

#endif // ATTRIBUTES_H
