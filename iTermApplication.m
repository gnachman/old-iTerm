// -*- mode:objc -*-
// $Id: iTermApplication.m,v 1.6 2005-04-03 17:50:29 ujwal Exp $
//
/*
 **  iTermApplication.m
 **
 **  Copyright (c) 2002-2004
 **
 **  Author: Ujwal S. Setlur
 **
 **  Project: iTerm
 **
 **  Description: overrides sendEvent: so that key mappings with command mask  
 **				  are handled properly.
 **
 **  This program is free software; you can redistribute it and/or modify
 **  it under the terms of the GNU General Public License as published by
 **  the Free Software Foundation; either version 2 of the License, or
 **  (at your option) any later version.
 **
 **  This program is distributed in the hope that it will be useful,
 **  but WITHOUT ANY WARRANTY; without even the implied warranty of
 **  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 **  GNU General Public License for more details.
 **
 **  You should have received a copy of the GNU General Public License
 **  along with this program; if not, write to the Free Software
 **  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#import "iTermApplication.h"
#import <iTerm/iTermController.h>
#import <iTerm/PTYWindow.h>
#import <iTerm/PseudoTerminal.h>
#import <iTerm/PTYSession.h>


@implementation iTermApplication

// override to catch key mappings with command key down
- (void)sendEvent:(NSEvent *)anEvent
{
	id aWindow;
	PseudoTerminal *currentTerminal;
	PTYSession *currentSession;
	unsigned int modflag;
    NSString *unmodkeystr;
    unichar unmodunicode = 0;	
	
	
	if([anEvent type] == NSKeyDown)
	{
		modflag = [anEvent modifierFlags];
		unmodkeystr = [anEvent charactersIgnoringModifiers];
		unmodunicode = [unmodkeystr length]>0?[unmodkeystr characterAtIndex:0]:0;	
	}
	
	if([anEvent type] == NSKeyDown && (([anEvent modifierFlags] & NSCommandKeyMask) || (unmodunicode == NSHelpFunctionKey)))
	{
		
		aWindow = [self keyWindow];
		
		if([aWindow isKindOfClass: [PTYWindow class]])
		{
						
			currentTerminal = [[iTermController sharedInstance] currentTerminal];
			currentSession = [currentTerminal currentSession];
			
			if([currentSession hasKeyMappingForEvent: anEvent])
				[currentSession keyDown: anEvent];
			else
				[super sendEvent: anEvent];
		}
		else
		   [super sendEvent: anEvent];

	}
	else
		[super sendEvent: anEvent];
}

@end