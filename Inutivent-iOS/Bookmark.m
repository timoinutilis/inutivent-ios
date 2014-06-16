//
//  Bookmark.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 03/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "Bookmark.h"
#import "Event.h"

@implementation Bookmark

- (id)initWithEventId:(NSString *)eventId userId:(NSString *)userId
{
    if (self = [super init])
    {
        _eventId = eventId;
        _userId = userId;
        _eventName = @"";
        _ownerUserId = @"";
    }
    return self;
}

- (id)initFromDictionary:(NSDictionary *)dict
{
    self = [self initWithEventId:dict[@"eventId"] userId:dict[@"userId"]];
    if (self)
    {
        _eventName = dict[@"eventName"];
        _ownerUserId = dict[@"ownerUserId"];
        _time = dict[@"time"];
    }
    return self;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"eventId"] = _eventId;
    dict[@"userId"] = _userId;
    dict[@"eventName"] = _eventName;
    dict[@"ownerUserId"] = _ownerUserId;
    if (_time)
    {
        dict[@"time"] = _time;
    }
    return dict;
}

- (void)updateFromEvent:(Event *)event
{
    if (![_eventName isEqualToString:event.title] || ![_time isEqualToDate:event.time])
    {
        _eventName = event.title;
        _ownerUserId = event.owner;
        _time = event.time;
        
        _wasChanged = YES;
    }
}

@end
