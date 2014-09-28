//
//  INUContacts.m
//  Gromf
//
//  Created by Timo Kloss on 31/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUContactManager.h"
#import "INUContact.h"

@implementation INUContactManager

#pragma mark - Manager

- (void)updateContacts:(void (^)(void))completionBlock
{
    _contacts = [[NSMutableArray alloc] init];
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    if (status == kABAuthorizationStatusNotDetermined)
    {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted)
            {
                [self loadContacts];
                dispatch_async(dispatch_get_main_queue(), completionBlock);
            }
        });
        CFRelease(addressBook);
    }
    else if (status == kABAuthorizationStatusAuthorized)
    {
        [self loadContacts];
        completionBlock();
    }
}

- (void)loadContacts
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (CFIndex i = 0; i < numberOfPeople; i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        
        NSString *name = [INUContactManager nameOfPerson:person];
        
        ABMultiValueRef mailAddresses = ABRecordCopyValue(person, kABPersonEmailProperty);
        
        for (CFIndex i = 0; i < ABMultiValueGetCount(mailAddresses); i++)
        {
            NSString *mailAddress = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(mailAddresses, i);
            INUContact *contact = [[INUContact alloc] initWithName:name mail:mailAddress];
            
            [_contacts addObject:contact];
        }
        
        CFRelease(mailAddresses);
    }
    
    CFRelease(addressBook);
    CFRelease(allPeople);
}

- (INUContact *)getContactByName:(NSString *)name mail:(NSString *)mail
{
    for (int i = 0; i < [_contacts count]; i++)
    {
        INUContact *contact = _contacts[i];
        if ([contact.name isEqualToString:name] && [contact.mail isEqualToString:mail])
        {
            return contact;
        }
    }
    return nil;
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
    
    return count;
}

@end
