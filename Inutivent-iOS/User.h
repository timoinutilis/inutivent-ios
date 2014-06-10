//
//  INUUser.h
//  Inutivent-iOS
//
//  Created by Timo Kloss on 03/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, UserStatus)
{
    UserStatusUnknown,
    UserStatusAttending,
    UserStatusNotAttending,
    UserStatusMaybeAttending
};

@interface User : NSObject

@property NSString *userId;
@property NSString *name;
@property UserStatus status;
@property NSDate *statusChanged;
@property NSDate *visited;

- (void)parseFromDictionary:(NSDictionary *)dict;
- (UserStatus)parseStatus:(NSString *)status;

@end
