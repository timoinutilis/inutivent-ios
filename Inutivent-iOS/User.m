//
//  INUUser.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 03/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "User.h"
#import "INUUtils.h"

@implementation User

- (void)parseFromDictionary:(NSDictionary *)dict
{
    _userId = dict[@"id"];
    _name = dict[@"name"];
    _status = [self parseStatus:dict[@"status"]];
    _statusChanged = [INUUtils dateFromDatetime:dict[@"status_changed"]];
    _visited = [INUUtils dateFromDatetime:dict[@"visited"]];
}

- (UserStatus)parseStatus:(NSString *)status
{
    if ([status isEqualToString:@"A"])
    {
        return UserStatusAttending;
    }
    if ([status isEqualToString:@"N"])
    {
        return UserStatusNotAttending;
    }
    if ([status isEqualToString:@"M"])
    {
        return UserStatusMaybeAttending;
    }
    return UserStatusUnknown;
}

@end
