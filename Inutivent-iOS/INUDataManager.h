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

@interface INUDataManager : NSObject

@property (readonly) NSMutableArray *bookmarks;
@property (readonly) NSMutableDictionary *events;

+ (INUDataManager *)sharedInstance;

- (void)loadBookmarks;
- (void)saveBookmarks;
- (Bookmark *)addBookmarkWithEventId:(NSString *)eventId userId:(NSString *)userId;
- (Bookmark *)getBookmarkByEventId:(NSString *)eventId userId:(NSString *)userId;
- (void)deleteBookmark:(Bookmark *)bookmark;

- (BOOL)needsIntroduction;
- (void)setIntroductionDone;

- (Event *)getEventById:(NSString *)eventId;

- (void)requestFromServer:(NSString *)service params:(NSDictionary *)paramsDict;

- (void)notifyUserUpdate;

@end

extern NSString *const INUBookmarksChangedNotification;
extern NSString *const INUBookmarkAddedByURLNotification;
extern NSString *const INUEventLoadedNotification;
extern NSString *const INUUserUpdatedNotification;
extern NSString *const INUErrorNotification;
