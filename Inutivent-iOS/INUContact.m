//
//  INUContact.m
//  Gromf
//
//  Created by Timo Kloss on 31/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUContact.h"

@implementation INUContact

- (instancetype)initWithName:(NSString *)name mail:(NSString *)mail
{
    if (self = [super init])
    {
        _name = name;
        _mail = mail;
    }
    return self;
}

- (instancetype)initWithFullMailAddress:(NSString *)mailAddress
{
    if (self = [super init])
    {
        NSRange startRange = [mailAddress rangeOfString:@"<"];
        NSRange endRange = [mailAddress rangeOfString:@">"];
        if (startRange.location != NSNotFound && endRange.location != NSNotFound)
        {
            NSRange mailRange = {startRange.location + 1, endRange.location - startRange.location - 1};
            _name = [mailAddress substringToIndex:startRange.location - 1];
            _mail = [mailAddress substringWithRange:mailRange];
        }
        else
        {
            _name = nil;
            _mail = mailAddress;
        }
    }
    return self;
}

- (NSString *)fullMailAddress
{
    if (_name)
    {
        return [NSString stringWithFormat:@"%@ <%@>", _name, _mail];
    }
    return _mail;
}

@end
