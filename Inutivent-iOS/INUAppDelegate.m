//
//  INUAppDelegate.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 31/05/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUAppDelegate.h"
#import "INUDataManager.h"
#import "INUUtils.h"

@implementation INUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        self.window.tintColor = [UIColor colorWithRed:227.0/255.0 green:70.0/255.0 blue:35.0/255.0 alpha:1.0];
    }

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
    if ([[url scheme] isEqualToString:@"gromf"])
    {
        NSMutableDictionary *params = [INUUtils getParamsFromURL:url];
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

@end
