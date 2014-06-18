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

@implementation INUDataManager
{
    int _numNumActivities;
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
        [self addBookmarkWithEventId:@"cb852c9195962267613bc110e08abfad" userId:@"03727bee"];
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

- (Event *)getEventById:(NSString *)eventId
{
    return _events[eventId];
}

- (void)requestFromServer:(NSString *)service params:(NSDictionary *)paramsDict
{
    [self beginActivity];
    
    NSMutableArray *paramsArray = [[NSMutableArray alloc] init];
    for (id key in paramsDict)
    {
        NSString *paramValue = [paramsDict[key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [paramsArray addObject:[NSString stringWithFormat:@"%@=%@", key, paramValue]];
    }
    NSString *bodyData = [paramsArray componentsJoinedByString:@"&"];
    
    NSURL *url = [NSURL URLWithString:[@"http://events.inutilis.com/backend/" stringByAppendingString:service]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [self endActivity];
        
        if (connectionError)
        {
            NSLog(@"connection error");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestErrorService:service error:@"connection error"];
            });
        }
        else
        {
            NSError *nsError = nil;
            id dataObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&nsError];
            if (nsError)
            {
                NSLog(@"format error");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self requestErrorService:service error:@"format error"];
                });
            }
            else
            {
                NSDictionary *dataDict = dataObject;
                NSString *dataError = dataObject[@"error"];
                if (dataError)
                {
                    NSLog(@"data error: %@", dataError);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self requestErrorService:service error:dataError];
                    });
                }
                else
                {
                    NSLog(@"data ok");
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
    else if ([service isEqualToString:@"updateuser.php"])
    {
/*        User *me = [self getMe];
        if (data[@"status"])
        {
            me.status = [me parseStatus:data[@"status"]];
            me.statusChanged = [[NSDate alloc] init];
        }
        if (data[@"name"])
        {
            me.name = data[@"name"];
        }
        [self updateUserView];
        
        if (_selectedRow)
        {
            [self.tableView deselectRowAtIndexPath:_selectedRow animated:YES];
            _selectedRow = nil;
        }*/
    }
}

- (void)requestErrorService:(NSString *)service error:(NSString *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
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
NSString *const INUEventLoadedNotification = @"INUEventLoaded";
