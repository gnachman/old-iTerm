
/*
 **  ITAddressBookMgr.m
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

#import "ITAddressBookMgr.h"
#import "AddressBookWindowController.h"

static NSString* OLD_ADDRESS_BOOK_FILE = @"~/Library/Application Support/iTerm Address Book";
static NSString* ADDRESS_BOOK_FILE = @"~/Library/Application Support/iTerm/AddressBook";

@interface ITAddressBookMgr (Private)
- (void)initAddressBook;
- (NSDictionary *)newDefaultAddressBookEntry;
@end

@implementation ITAddressBookMgr

+ (id)sharedInstance;
{
    static ITAddressBookMgr* shared = nil;
    
    if (!shared)
        shared = [[ITAddressBookMgr alloc] init];
    
    return shared;
}

- (id)init;
{
    self = [super init];
    
    [self initAddressBook]; 
        
    return self;
}

- (void)dealloc;
{
    [_addressBookArray release];
    [super dealloc];
}

- (NSArray *) addressBook
{
    return _addressBookArray;
}

- (void)showABWindow;
{
    AddressBookWindowController *abWindowController;
        
    abWindowController = [AddressBookWindowController singleInstance];
    [abWindowController setAddressBook: _addressBookArray];
    [abWindowController run];
}

- (void)saveAddressBook
{
    if (![NSArchiver archiveRootObject:_addressBookArray toFile:[ADDRESS_BOOK_FILE stringByExpandingTildeInPath]])
        NSLog(@"Save failed");
}

// Returns an entry from the addressbook
- (NSMutableDictionary *)addressBookEntry: (int) entryIndex
{
    if((entryIndex < 0) || (entryIndex >= [_addressBookArray count]))
        return (nil);
    
    return ([_addressBookArray objectAtIndex: entryIndex]);
}

- (NSMutableDictionary *) defaultAddressBookEntry
{
    int i;
    
    for(i = 0; i < [_addressBookArray count]; i++)
    {
        NSMutableDictionary *entry = [_addressBookArray objectAtIndex: i];
        
        if([entry objectForKey: @"DefaultEntry"] != nil)
            return (entry);
    }
    
    return (nil);
}

- (void) addAddressBookEntry: (NSDictionary *) entry
{
    [_addressBookArray addObject:entry];
    [_addressBookArray sortUsingFunction: addressBookComparator context: nil];
}

- (void) replaceAddressBookEntry:(NSDictionary *) old with:(NSDictionary *)new
{
    [_addressBookArray replaceObjectAtIndex:[_addressBookArray indexOfObject:old] withObject:new];
}

// Returns the entries in the addressbook
- (NSArray *)addressBookNames
{
    NSMutableArray *anArray;
    int i;
    NSDictionary *anEntry;
    
    anArray = [[NSMutableArray alloc] init];
    
    for(i = 0; i < [_addressBookArray count]; i++)
    {
        anEntry = [_addressBookArray objectAtIndex: i];
        [anArray addObject: entryVisibleName( anEntry, self )];
    }
    
    return ([anArray autorelease]);
}

@end

@implementation ITAddressBookMgr (Private);

- (void)initAddressBook;
{
    // We have a new location for the addressbook
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath: [OLD_ADDRESS_BOOK_FILE stringByExpandingTildeInPath]])
    {
        // move the addressbook to the new location
        [fileManager movePath: [OLD_ADDRESS_BOOK_FILE stringByExpandingTildeInPath]
                       toPath: [ADDRESS_BOOK_FILE stringByExpandingTildeInPath] handler: nil];
    }
    
    _addressBookArray = [[NSUnarchiver unarchiveObjectWithFile: [ADDRESS_BOOK_FILE stringByExpandingTildeInPath]] retain];
    if (_addressBookArray == nil) {
        NSLog(@"No file loaded");
        _addressBookArray=[[NSMutableArray array] retain];
    }
    
    // Insert default entry
    if ( [_addressBookArray count] < 1 || ![[_addressBookArray objectAtIndex: 0] objectForKey:@"DefaultEntry"] ) {
        [_addressBookArray insertObject:[self newDefaultAddressBookEntry] atIndex: 0];
    }
    // There can be only one
    int i;
    for ( i = 1; i < [_addressBookArray count]; i++) {
        if ( isDefaultEntry( [_addressBookArray objectAtIndex: i] ) ) {
            NSDictionary *entry = [_addressBookArray objectAtIndex: i];
            NSMutableDictionary *newentry = [NSMutableDictionary dictionaryWithDictionary:entry];
            // [entry release]?
            [newentry removeObjectForKey:@"DefaultEntry"];
            entry = [NSDictionary dictionaryWithDictionary:newentry];
            [_addressBookArray replaceObjectAtIndex:i withObject:entry];
        }
    }
}

- (NSDictionary *)newDefaultAddressBookEntry
{
    char *userShell, *thisUser;
    NSString *shell;
    
    // This would be better read from a file stored in the package (with some bits added at run time)
    
    // Get the user's default shell
    if((thisUser = getenv("USER")) != NULL) {
        shell = [NSString stringWithFormat: @"login -fp %s", thisUser];
    } else if((userShell = getenv("SHELL")) != NULL) {
        shell = [NSString stringWithCString: userShell];
    } else {
        shell = @"/bin/bash --login";
    }
    
    NSDictionary *ae = [[[NSDictionary alloc] initWithObjectsAndKeys:
        NSLocalizedStringFromTableInBundle(@"Default Session",@"iTerm", [NSBundle bundleForClass: [self class]], @"Default Session"),@"Name",
        shell,@"Command",
        [NSNumber numberWithUnsignedInt:1],@"Encoding",
        [NSColor colorWithCalibratedRed:0.8f
                                  green:0.8f
                                   blue:0.8f
                                  alpha:1.0f],@"Foreground",
        [NSColor blackColor],@"Background",
        [NSColor colorWithCalibratedRed:0.45f
                                  green:0.5f
                                   blue:0.55f
                                  alpha:1.0f],@"SelectionColor",
        [NSColor redColor],@"BoldColor",
        [NSNumber numberWithUnsignedInt:25],@"Row",
        [NSNumber numberWithUnsignedInt:80],@"Col",
        [NSNumber numberWithInt:10],@"Transparency",
        @"xterm",@"Term Type",
        [@"~"  stringByExpandingTildeInPath],@"Directory",
        [NSFont fontWithName:@"FreeMonoBold" size:13],@"Font",
        [NSFont fontWithName:@"Osaka-Mono" size:14],@"NAFont",
        [NSNumber numberWithBool:false],@"AntiIdle",
        [NSNumber numberWithUnsignedInt:0],@"AICode",
        [NSNumber numberWithBool:true],@"AutoClose",
        [NSNumber numberWithBool:false],@"DoubleWidth",
        [NSNumber numberWithUnsignedInt:0],@"Shortcut",
        [NSNumber numberWithBool:true],@"DefaultEntry",
        NULL] autorelease];
    
    return ae;
}

@end

NSComparisonResult addressBookComparator (NSDictionary *entry1, NSDictionary *entry2, void *context)
{
    // Default entry is always first
    if ( isDefaultEntry( entry1 ) ) return -1;
    if ( isDefaultEntry( entry2 ) ) return 1;
    
    return ([(NSString *)[entry1 objectForKey: @"Name"] caseInsensitiveCompare: (NSString *)[entry2 objectForKey: @"Name"]]);
}

// comaparator function for addressbook entries
BOOL isDefaultEntry( NSDictionary *entry )
{
    return [entry objectForKey: @"DefaultEntry"] && [[entry objectForKey: @"DefaultEntry"] boolValue];
}

NSString *entryVisibleName( NSDictionary *entry, id sender )
{
    if ( isDefaultEntry( entry ) ) {
        return NSLocalizedStringFromTableInBundle(@"Default Session",@"iTerm", [NSBundle bundleForClass: [sender class]], @"Default Session");
    } else {
        return [entry objectForKey:@"Name"];
    }
}
