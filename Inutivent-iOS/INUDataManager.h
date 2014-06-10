//
//  INUEventManager.h
//  Inutivent-iOS
//
//  Created by Timo Kloss on 03/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INUDataManagerDelegate.h"

@class Bookmark;

@interface INUDataManager : NSObject

@property (readonly) NSMutableArray *bookmarks;
@property (weak) id<INUDataManagerDelegate> delegate;

+ (INUDataManager *)sharedInstance;

- (void)loadBookmarks;
- (void)saveBookmarks;
- (Bookmark *)addBookmarkWithEventId:(NSString *)eventId userId:(NSString *)userId;
- (Bookmark *)getBookmarkByEventId:(NSString *)eventId userId:(NSString *)userId;

- (void)requestFromServer:(NSString *)service params:(NSDictionary *)paramsDict;

@end
