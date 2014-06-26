//
//  INUEvent.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 31/05/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "Event.h"
#import "User.h"
#import "Post.h"
#import "INUUtils.h"

@implementation Event

- (id)init
{
    self = [super init];
    if (self)
    {
        _users = [[NSMutableArray alloc] init];
        _posts = [[NSMutableArray alloc] init];
        _lastUpdate = [[NSDate alloc] init];
    }
    return self;
}

- (void)parseFromDictionary:(NSDictionary *)dict
{
    _lastUpdate = [[NSDate alloc] init];
    
    NSDictionary *event = dict[@"event"];
    if (event)
    {
        _eventId = event[@"id"];
        _title = event[@"title"];
        _details = event[@"details"];
        _owner = event[@"owner"];
        _time = [INUUtils dateFromDatetime:event[@"time"]];
        _cover = event[@"cover"] != [NSNull null] ? event[@"cover"] : nil;
        _created = [INUUtils dateFromDatetime:event[@"created"]];
    }
    
    NSDictionary *users = dict[@"users"];
    if (users)
    {
        _users = [[NSMutableArray alloc] init];
        for (id key in users)
        {
            User *user = [[User alloc] init];
            [user parseFromDictionary:users[key]];
            [_users addObject:user];
        }
    }
    
    NSArray *posts = dict[@"posts"];
    if (posts)
    {
        _posts = [[NSMutableArray alloc] init];
        int count = (int)[posts count];
        for (int i = 0; i < count; i++)
        {
            Post *post = [[Post alloc] init];
            [post parseFromDictionary:posts[i]];
            [_posts addObject:post];
        }
    }
}

- (User *)getUserWithId:(NSString *)userId
{
    int count = (int)[_users count];
    for (int i = 0; i < count; i++)
    {
        User *user = _users[i];
        if ([user.userId isEqualToString:userId])
        {
            return user;
        }
    }
    return nil;
}

@end
