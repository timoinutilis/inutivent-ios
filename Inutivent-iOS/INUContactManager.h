//
//  INUContacts.h
//  Gromf
//
//  Created by Timo Kloss on 31/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@class INUContact;

@interface INUContactManager : NSObject

@property (readonly) NSMutableArray *contacts;

- (void)updateContacts:(void (^)(void))completionBlock;
- (INUContact *)getContactByName:(NSString *)name mail:(NSString *)mail;

+ (NSString *)nameOfPerson:(ABRecordRef)person;
+ (NSString *)valueOfPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;
+ (NSString *)valueOfPerson:(ABRecordRef)person property:(ABPropertyID)property;
+ (int)countMailAddressesOfPerson:(ABRecordRef)person;

@end
