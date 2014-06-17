//
//  INUAppDelegate.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 31/05/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUAppDelegate.h"
#import "INUDataManager.h"

@implementation INUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[INUDataManager sharedInstance] loadBookmarks];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url scheme] isEqualToString:@"inutivent"])
    {
        NSMutableDictionary *params = [self getParamsFromURL:url];
        NSString *eventId = params[@"event"];
        NSString *userId = params[@"user"];
        if (eventId && userId)
        {
            [[INUDataManager sharedInstance] addBookmarkWithEventId:eventId userId:userId];
            [[INUDataManager sharedInstance] saveBookmarks];
        }
        return YES;
    }
    return NO;
}

- ()getParamsFromURL:(NSURL *)url
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *query = [url query];
    if (query)
    {
        NSArray *components = [query componentsSeparatedByString:@"&"];
        for (NSString *param in components)
        {
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if ([elts count] == 2)
            {
                [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
            }
        }
    }
    return params;
}

@end