//
//  Bookmark.h
//  Inutivent-iOS
//
//  Created by Timo Kloss on 03/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Event;

@interface Bookmark : NSObject

@property BOOL wasChanged;

@property NSString *eventId;
@property NSString *userId;
@property NSString *eventName;
@property NSString *ownerUserId;
@property NSDate *time;

- (id)initWithEventId:(NSString *)eventId userId:(NSString *)userId;
- (id)initFromDictionary:(NSDictionary *)dict;
- (NSMutableDictionary *)toDictionary;

- (void)updateFromEvent:(Event *)event;

@end
