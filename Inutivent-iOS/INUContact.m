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

#pragma mark - Person Utils

+ (NSString *)nameOfPerson:(ABRecordRef)person
{
    NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
    
    NSString *name = @"";
    if (firstName && lastName)
    {
        name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    else if (firstName)
    {
        name = firstName;
    }
    else if (lastName)
    {
        name = lastName;
    }
    return name;
}

+ (NSString *)valueOfPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    NSString *value = nil;
    ABMultiValueRef multiValue = ABRecordCopyValue(person, property);
    if (multiValue)
    {
        CFIndex index = ABMultiValueGetIndexForIdentifier(multiValue, identifier);
        value = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(multiValue, index);
        CFRelease(multiValue);
    }
    return value;
}

+ (NSString *)valueOfPerson:(ABRecordRef)person property:(ABPropertyID)property
{
    NSString *value = nil;
    ABMultiValueRef multiValue = ABRecordCopyValue(person, property);
    if (multiValue)
    {
        if (ABMultiValueGetCount(multiValue) > 0)
        {
            value = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(multiValue, 0);
        }
        CFRelease(multiValue);
    }
    return value;
}

+ (int)countMailAddressesOfPerson:(ABRecordRef)person
{
    CFIndex count;
    
    ABMultiValueRef mailAddresses = ABRecordCopyValue(person, kABPersonEmailProperty);
    count = ABMultiValueGetCount(mailAddresses);
    CFRelease(mailAddresses);
    
    return (int)count;
}

@end
