//
//  INUEvent.h
//  Inutivent-iOS
//
//  Created by Timo Kloss on 31/05/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Event : NSObject

@property BOOL isLoaded;

@property NSString *eventId;
@property NSString *owner;
@property NSString *title;
@property NSString *details;
@property NSDate *time;
@property NSString *cover;
@property NSDate *created;

@property (readonly) NSMutableArray *users;

- (void)parseFromDictionary:(NSDictionary *)dict;
- (User *)getUserWithId:(NSString *)userId;

@end
