//
//  INUContact.h
//  Gromf
//
//  Created by Timo Kloss on 31/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface INUContact : NSObject

@property NSString *name;
@property NSString *mail;

- (id)initWithName:(NSString *)name mail:(NSString *)mail;

@end
