 /*
 *  InspectorsProtocol.h: Interface and declarations for the InspectorsProtocol
 *  protocol of the GNUstep GWorkspace application
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

#ifndef INSPECTORSPROTOCOL_H
#define INSPECTORSPROTOCOL_H

@protocol InspectorsProtocol

- (id)inspView;

- (void)activateForPaths:(NSArray *)paths;

- (void)deactivate;

- (NSString *)inspname;

- (NSString *)winname;

- (NSButton *)revertButton;

- (NSButton *)okButton;

@end 

#endif // INSPECTORSPROTOCOL_H
