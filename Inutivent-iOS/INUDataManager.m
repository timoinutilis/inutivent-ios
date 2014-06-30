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

- (Bookmark *)addBookmarkWithEventId:(NSString *)eventId userId:(NSString *)userId
{
    Bookmark *bookmark = [self getBookmarkByEventId:eventId userId:userId];
    if (!bookmark)
    {
        bookmark = [[Bookmark alloc] initWithEventId:eventId userId:userId];
        [_bookmarks addObject:bookmark];
        [[NSNotificationCenter defaultCenter] postNotificationName:INUBookmarksChangedNotification object:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:INUBookmarkAddedByURLNotification object:self userInfo:@{@"bookmark":bookmark}];
    return bookmark;
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

- (void)requestFromServer:(NSString *)service params:(NSDictionary *)paramsDict
{
    if ([paramsDict[@"event_id"] isEqualToString:ExampleEventId])
    {
        // cancel server requests for example event
        return;
    }
    
    [self beginActivity];
    
    NSMutableArray *paramsArray = [[NSMutableArray alloc] init];
    for (id key in paramsDict)
    {
        NSString *paramValue = [paramsDict[key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [paramsArray addObject:[NSString stringWithFormat:@"%@=%@", key, paramValue]];
    }
    NSString *bodyData = [paramsArray componentsJoinedByString:@"&"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/backend/%@", INUConfigSiteURL, service]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [self endActivity];
        
        if (connectionError)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestErrorService:service errorId:@"failed_connection" error:@"Connection error"];
            });
        }
        else
        {
            NSError *nsError = nil;
            id dataObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&nsError];
            if (nsError)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self requestErrorService:service errorId:@"invalid_response" error:@"Format error"];
                });
            }
            else
            {
                NSDictionary *dataDict = dataObject;
                NSString *dataErrorId = dataObject[@"error_id"];
                NSString *dataError = dataObject[@"error"];
                if (dataErrorId)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self requestErrorService:service errorId:dataErrorId error:dataError];
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self requestCompleteService:service data:dataDict];
                    });
                }
            }
        }
    }];
}

- (void)requestCompleteService:(NSString *)service data:(NSDictionary *)data
{
    if ([service isEqualToString:@"getevent.php"])
    {
        NSString *eventId = data[@"event"][@"id"];
        Event *event = [self getEventById:eventId];
        if (!event)
        {
            event = [[Event alloc] init];
            _events[eventId] = event;
        }
        [event parseFromDictionary:data];
        
        // update bookmarks
        int count = (int)[_bookmarks count];
        BOOL anyChanged = NO;
        for (int i = 0; i < count; i++)
        {
            Bookmark *bookmark = _bookmarks[i];
            if ([bookmark.eventId isEqualToString:eventId])
            {
                [bookmark updateFromEvent:event];
                if (bookmark.wasChanged)
                {
                    anyChanged = YES;
                }

            }
        }
        if (anyChanged)
        {
            [self saveBookmarks];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:INUEventLoadedNotification object:self userInfo:@{@"eventId": eventId}];
    }
}

- (void)requestErrorService:(NSString *)service errorId:(NSString *)errorId error:(NSString *)error
{
    NSString *title = nil;
    NSString *message = nil;
    
    if ([errorId isEqualToString:@"not_found"])
    {
        title = NSLocalizedString(@"Event Doesn't Exist Anymore", nil);
        message = NSLocalizedString(@"Maybe the host deleted it or it was too old already.", nil);
    }
    else if ([errorId isEqualToString:@"failed_connection"])
    {
        title = NSLocalizedString(@"Couldn't Connect to Internet", nil);
        message = NSLocalizedString(@"Please check if your device is connected to any network.", nil);
    }
    else
    {
        title = NSLocalizedString(@"Something Went Wrong", nil);
        message = NSLocalizedString(@"Please try again later.", nil);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:INUErrorNotification object:self userInfo:@{@"title":title, @"message":message, @"errorId":errorId}];
}

- (void)notifyUserUpdate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:INUUserUpdatedNotification object:self userInfo:nil];
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

NSString *const INUBookmarksChangedNotification = @"INUBookmarksChanged";
NSString *const INUBookmarkAddedByURLNotification = @"INUBookmarkAddedByURL";
NSString *const INUEventLoadedNotification = @"INUEventLoaded";
NSString *const INUUserUpdatedNotification = @"INUUserUpdated";
NSString *const INUErrorNotification = @"INUError";
