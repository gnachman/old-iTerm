/*
 **  ITAddressBookMgr.h
 **
 **  Copyright (c) 2002, 2003
 **
 **  Author: Fabian, Ujwal S. Sathyam
 **	     Initial code by Kiichi Kusama
 **
 **  Project: iTerm
 **
 **  Description: keeps track of the address book data.
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

#import <Foundation/Foundation.h>

extern  NSComparisonResult addressBookComparator (NSDictionary *entry1, NSDictionary *entry2, void *context);
extern BOOL isDefaultEntry( NSDictionary *entry );
extern NSString *entryVisibleName( NSDictionary *entry, id sender );

@interface ITAddressBookMgr : NSObject 
{
    NSMutableArray *_addressBookArray;
}

+ (id)sharedInstance;

- (void)showABWindow;
- (NSArray *)addressBook;
- (NSMutableDictionary *) defaultAddressBookEntry;
- (NSMutableDictionary *)addressBookEntry: (int) entryIndex;
- (void)saveAddressBook;
- (void) addAddressBookEntry: (NSDictionary *) entry;
- (NSArray *)addressBookNames;

@end