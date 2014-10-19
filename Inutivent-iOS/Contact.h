//
//  INUContact.h
//  Gromf
//
//  Created by Timo Kloss on 31/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface Contact : NSObject

@property NSString *name;
@property NSString *mail;
@property (nonatomic, readonly) NSString *fullMailAddress;

- (instancetype)initWithName:(NSString *)name mail:(NSString *)mail;
- (instancetype)initWithFullMailAddress:(NSString *)mailAddress;
- (instancetype)initWithUserDefaults;

- (void)saveUserDefaults;

+ (NSString *)nameOfPerson:(ABRecordRef)person;
+ (NSString *)valueOfPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;
+ (NSString *)valueOfPerson:(ABRecordRef)person property:(ABPropertyID)property;
+ (int)countMailAddressesOfPerson:(ABRecordRef)person;

@end
