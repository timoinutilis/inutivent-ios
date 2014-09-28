//
//  INUContact.m
//  Gromf
//
//  Created by Timo Kloss on 31/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUContact.h"

@implementation INUContact

- (id)initWithName:(NSString *)name mail:(NSString *)mail
{
    if (self = [super init])
    {
        _name = name;
        _mail = mail;
    }
    return self;
}

@end
