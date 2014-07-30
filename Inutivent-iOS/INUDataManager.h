//
//  INUEventManager.h
//  Inutivent-iOS
//
//  Created by Timo Kloss on 03/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Bookmark;
@class Event;
@class ServiceError;

@interface INUDataManager : NSObject

@property (readonly) NSMutableArray *bookmarks;
@property (readonly) NSMutableDictionary *events;

+ (INUDataManager *)sharedInstance;

- (void)loadBookmarks;
- (void)saveBookmarks;
- (Bookmark *)addBookmarkFromURLWithEventId:(NSString *)eventId userId:(NSString *)userId;
- (Bookmark *)getBookmarkByEventId:(NSString *)eventId userId:(NSString *)userId;
- (void)deleteBookmark:(Bookmark *)bookmark;
- (void)updateBookmarksForEvent:(Event *)event;

- (BOOL)needsIntroduction;
- (void)setIntroductionDone;

- (Event *)getEventById:(NSString *)eventId;

- (void)requestFromServer:(NSString *)service params:(NSDictionary *)paramsDict info:(NSDictionary *)infoDict onError:(BOOL (^)(ServiceError *))errorBlock;

- (void)notifyNewEventViewClosed:(Bookmark *)bookmark;
- (void)notifyUserUpdate;
- (void)notifyEventUpdate;
- (void)notifyAppToFront;

@end

extern NSString *const INUBookmarkChangedNotification;
extern NSString *const INUBookmarkOpenedByURLNotification;
extern NSString *const INUEventCreatedNotification;
extern NSString *const INUEventLoadedNotification;
extern NSString *const INUEventUpdatedNotification;
extern NSString *const INUNewEventViewClosedNotification;
extern NSString *const INUUserUpdatedNotification;
extern NSString *const INUAppToFrontNotification;