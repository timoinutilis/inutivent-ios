//
//  INUEventManager.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 03/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUDataManager.h"
#import "Event.h"
#import "User.h"
#import "Bookmark.h"
#import "ExampleEvent.h"
#import "INUConfig.h"
#import "INUConstants.h"
#import "INUUtils.h"
#import "ServiceError.h"
#import "AFNetworking.h"
#import "Contact.h"

@implementation INUDataManager
{
    int _numNumActivities;
    ExampleEvent *_exampleEvent;
}

static INUDataManager *_sharedInstance;

+ (INUDataManager *)sharedInstance
{
    if (_sharedInstance == nil)
    {
        _sharedInstance = [[super allocWithZone:NULL] init];
    }
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _bookmarks = [[NSMutableArray alloc] init];
        _events = [[NSMutableDictionary alloc] init];
        _userContact = [[Contact alloc] initWithUserDefaults];
    }
    return self;
}

- (void)loadBookmarks
{
    NSArray *bookmarksArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"bookmarks"];
    if (bookmarksArray)
    {
        for (int i = 0; i < [bookmarksArray count]; i++)
        {
            Bookmark *bookmark = [[Bookmark alloc] initFromDictionary:bookmarksArray[i]];
            [_bookmarks addObject:bookmark];
        }
    }
    else
    {
        Bookmark *bookmark = [[Bookmark alloc] initWithEventId:ExampleEventId userId:ExampleUserId];
        Event *exampleEvent = [self getEventById:ExampleEventId];
        [bookmark updateFromEvent:exampleEvent];
        [_bookmarks addObject:bookmark];
    }
}

- (void)saveBookmarks
{
    NSMutableArray *bookmarksArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [_bookmarks count]; i++)
    {
        [bookmarksArray addObject:[_bookmarks[i] toDictionary]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:bookmarksArray forKey:@"bookmarks"];
}

- (Bookmark *)addBookmarkFromURLWithEventId:(NSString *)eventId userId:(NSString *)userId
{
    Bookmark *bookmark = [self getBookmarkByEventId:eventId userId:userId];
    if (!bookmark)
    {
        bookmark = [[Bookmark alloc] initWithEventId:eventId userId:userId];
        [_bookmarks addObject:bookmark];
        [[NSNotificationCenter defaultCenter] postNotificationName:INUBookmarkChangedNotification object:self userInfo:@{@"bookmark":bookmark}];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:INUBookmarkOpenedByURLNotification object:self userInfo:@{@"bookmark":bookmark}];
    return bookmark;
}

- (void)addBookmark:(Bookmark *)bookmark
{
    [_bookmarks addObject:bookmark];
    [[NSNotificationCenter defaultCenter] postNotificationName:INUBookmarkChangedNotification object:self userInfo:@{@"bookmark":bookmark}];
}

- (Bookmark *)getBookmarkByEventId:(NSString *)eventId userId:(NSString *)userId
{
    for (int i = 0; i < [_bookmarks count]; i++)
    {
        Bookmark *bookmark = _bookmarks[i];
        if ([bookmark.eventId isEqualToString:eventId] && [bookmark.userId isEqualToString:userId])
        {
            return bookmark;
        }
    }
    return nil;
}

- (void)deleteBookmark:(Bookmark *)bookmark
{
    [_events removeObjectForKey:bookmark.eventId];
    [_bookmarks removeObject:bookmark];
    [self saveBookmarks];
}

- (void)deleteBookmarksForEvent:(Event *)event
{
    int count = (int)[_bookmarks count];
    BOOL anyChanged = NO;
    for (int i = 0; i < count; i++)
    {
        Bookmark *bookmark = _bookmarks[i];
        if ([bookmark.eventId isEqualToString:event.eventId])
        {
            anyChanged = YES;
            [self deleteBookmark:bookmark];
        }
    }
    if (anyChanged)
    {
        [self saveBookmarks];
        [[NSNotificationCenter defaultCenter] postNotificationName:INUBookmarksDeletedNotification object:self userInfo:nil];
    }
}

- (void)updateBookmarksForEvent:(Event *)event
{
    int count = (int)[_bookmarks count];
    BOOL anyChanged = NO;
    for (int i = 0; i < count; i++)
    {
        Bookmark *bookmark = _bookmarks[i];
        if ([bookmark.eventId isEqualToString:event.eventId])
        {
            BOOL changed = [bookmark updateFromEvent:event];
            if (changed)
            {
                anyChanged = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:INUBookmarkChangedNotification object:self userInfo:@{@"bookmark":bookmark}];
            }
            
        }
    }
    if (anyChanged)
    {
        [self saveBookmarks];
    }
}

- (BOOL)needsIntroduction
{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:@"introductionDone"];
}
    
- (void)setIntroductionDone
{
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"introductionDone"];
}

- (Event *)getEventById:(NSString *)eventId
{
    if ([eventId isEqualToString:ExampleEventId])
    {
        if (!_exampleEvent)
        {
            _exampleEvent = [[ExampleEvent alloc] init];
        }
        return _exampleEvent;
    }
    
    // real event
    return _events[eventId];
}

- (void)requestFromServer:(NSString *)service params:(NSDictionary *)paramsDict info:(NSDictionary *)infoDict onError:(BOOL (^)(ServiceError *))errorBlock
{
    [self requestFromServer:service params:paramsDict info:infoDict uploadData:nil onError:errorBlock];
}

- (void)requestFromServer:(NSString *)service params:(NSDictionary *)paramsDict info:(NSDictionary *)infoDict uploadData:(NSDictionary *)uploadDataDict onError:(BOOL (^)(ServiceError *))errorBlock
{
    if ([paramsDict[@"event_id"] isEqualToString:ExampleEventId])
    {
        // cancel server requests for example event
        return;
    }
    
    [self beginActivity];
    
    NSString *url = [NSString stringWithFormat:@"%@/backend/%@", INUConfigSiteURL, service];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if (uploadDataDict)
    {
        [manager POST:url parameters:paramsDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

            for (NSString *key in uploadDataDict.allKeys)
            {
                [formData appendPartWithFileData:(NSData *)uploadDataDict[key] name:key fileName:@"photo.jpg" mimeType:@"image/jpeg"];
            }
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self handleResponse:(NSDictionary *)responseObject service:service params:paramsDict info:infoDict errorBlock:errorBlock];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handleErrorWithBlock:errorBlock];
        }];
    }
    else
    {
        [manager POST:url parameters:paramsDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self handleResponse:(NSDictionary *)responseObject service:service params:paramsDict info:infoDict errorBlock:errorBlock];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handleErrorWithBlock:errorBlock];
        }];
    }
}

- (void)handleResponse:(NSDictionary *)dataDict service:(NSString *)service params:(NSDictionary *)paramsDict info:(NSDictionary *)infoDict errorBlock:(BOOL (^)(ServiceError *))errorBlock {
    [self endActivity];
    
    NSString *dataErrorId = dataDict[@"error_id"];
    NSString *dataError = dataDict[@"error"];
    if (dataErrorId)
    {
        ServiceError *serviceError = [[ServiceError alloc] initWithErrorId:dataErrorId error:dataError];
        [self showError:serviceError block:errorBlock];
    }
    else
    {
        if ([service isEqualToString:INUServiceGetEvent])
        {
            NSString *eventId = dataDict[@"event"][@"id"];
            Event *event = [self getEventById:eventId];
            if (!event)
            {
                event = [[Event alloc] init];
                _events[eventId] = event;
            }
            [event parseFromDictionary:dataDict];
            
            [self updateBookmarksForEvent:event];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:INUEventLoadedNotification object:self userInfo:@{@"eventId": eventId}];
        }
        else if ([service isEqualToString:INUServiceCreateEvent])
        {
            NSString *eventId = dataDict[@"event_id"];
            NSString *userId = dataDict[@"user_id"];
            
            Bookmark *bookmark = [[Bookmark alloc] initWithEventId:eventId userId:userId];
            bookmark.ownerUserId = userId;
            bookmark.eventName = infoDict[@"title"];
            bookmark.time = infoDict[@"time"];
            
            [self addBookmark:bookmark];
            [self saveBookmarks];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:INUEventCreatedNotification object:self userInfo:@{@"bookmark": bookmark}];
        }
        else if (   [service isEqualToString:INUServiceUpdateEvent]
                 || [service isEqualToString:INUServiceUploadCover] )
        {
            NSString *filename = dataDict[@"filename"];
            
            if (filename && ![filename isEqualToString:@""])
            {
                NSString *eventId = paramsDict[@"event_id"];
                Event *event = [[INUDataManager sharedInstance] getEventById:eventId];
                event.cover = filename;
                [[INUDataManager sharedInstance] notifyEventUpdate];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:INUEventSavedNotification object:self userInfo:nil];
        }
        else if ([service isEqualToString:INUServiceInvite])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:INUInvitedNotification object:self userInfo:dataDict];
            NSArray *users = dataDict[@"users"];
            if (users)
            {
                NSString *eventId = paramsDict[@"event_id"];
                Event *event = [self getEventById:eventId];
                [event parseFromDictionary:@{@"users":users}];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:INUEventLoadedNotification object:self userInfo:@{@"eventId": eventId}];
            }
        }
        else if ([service isEqualToString:INUServiceDeleteEvent])
        {
            NSString *eventId = paramsDict[@"event_id"];
            [self deleteBookmarksForEvent:[self getEventById:eventId]];
            [[NSNotificationCenter defaultCenter] postNotificationName:INUEventDeletedNotification object:self userInfo:@{@"eventId": eventId}];
        }
    }
}

- (void)handleErrorWithBlock:(BOOL (^)(ServiceError *))errorBlock {
    [self endActivity];
    
    ServiceError *serviceError = [[ServiceError alloc] initWithErrorId:@"failed_connection" error:@"Connection error"];
    [self showError:serviceError block:errorBlock];
}

- (void)showError:(ServiceError *)error block:(BOOL (^)(ServiceError *))errorBlock
{
    BOOL showed = NO;
    if (errorBlock)
    {
        showed = errorBlock(error);
    }
    
    if (!showed)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.title message:error.message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
}

- (void)notifyNewEventViewClosed:(Bookmark *)bookmark
{
    [[NSNotificationCenter defaultCenter] postNotificationName:INUNewEventViewClosedNotification object:self userInfo:@{@"bookmark": bookmark}];
}

- (void)notifyUserUpdate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:INUUserUpdatedNotification object:self userInfo:nil];
}

- (void)notifyEventUpdate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:INUEventUpdatedNotification object:self userInfo:nil];
}

- (void)notifyAppToFront
{
    [[NSNotificationCenter defaultCenter] postNotificationName:INUAppToFrontNotification object:self userInfo:nil];
}

- (void) beginActivity
{
    _numNumActivities++;
    if (_numNumActivities == 1)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

- (void) endActivity
{
    _numNumActivities--;
    if (_numNumActivities == 0)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

@end

NSString *const INUBookmarkChangedNotification = @"INUBookmarksChanged";
NSString *const INUBookmarkOpenedByURLNotification = @"INUBookmarkOpenedByURL";
NSString *const INUBookmarksDeletedNotification = @"INUBookmarksDeleted";
NSString *const INUEventCreatedNotification = @"INUEventCreated";
NSString *const INUEventSavedNotification = @"INUEventSaved";
NSString *const INUEventLoadedNotification = @"INUEventLoaded";
NSString *const INUEventUpdatedNotification = @"INUEventUpdated";
NSString *const INUEventDeletedNotification = @"INUEventDeleted";
NSString *const INUNewEventViewClosedNotification = @"INUNewEventViewClosed";
NSString *const INUUserUpdatedNotification = @"INUUserUpdated";
NSString *const INUInvitedNotification = @"INUInvited";
NSString *const INUAppToFrontNotification = @"INUAppToFront";
