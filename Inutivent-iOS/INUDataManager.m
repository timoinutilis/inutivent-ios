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
        [self addBookmarkWithEventId:@"c38073287c5243c6b7743224e38814a1" userId:@"4ce1cffb"];
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
        [self delegateBookmarksChanged];
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

- (void)delegateBookmarksChanged
{
    if (_delegate && [_delegate respondsToSelector:@selector(bookmarksChanged)])
    {
        [_delegate bookmarksChanged];
    }
}

- (void)delegateRequestCompleteService:(NSString *)service data:(NSDictionary *)data
{
    if (_delegate && [_delegate respondsToSelector:@selector(requestCompleteService:data:)])
    {
        [_delegate requestCompleteService:service data:data];
    }
}

- (void)delegateRequestErrorService:(NSString *)service error:(NSString *)error
{
    if (_delegate && [_delegate respondsToSelector:@selector(requestErrorService:error:)])
    {
        [_delegate requestErrorService:service error:error];
    }
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
                [self delegateRequestErrorService:service error:@"connection error"];
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
                    [self delegateRequestErrorService:service error:@"format error"];
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
                        [self delegateRequestErrorService:service error:dataError];
                    });
                }
                else
                {
                    NSLog(@"data ok");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self delegateRequestCompleteService:service data:dataDict];
                    });
                }
            }
        }
    }];
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
