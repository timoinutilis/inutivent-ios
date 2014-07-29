//
//  INUUtils.h
//  Inutivent-iOS
//
//  Created by Timo Kloss on 05/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface INUUtils : NSObject

+ (NSDate *)dateFromDatetime:(NSString *)datetime;
+ (NSDate *)dateAfter:(NSDate *)date atHour:(int)hour minute:(int)minute;
+ (NSMutableDictionary *)getParamsFromURL:(NSURL *)url;
+ (void)initBackground:(UITableView *)tableView;
+ (void)initNavigationBar:(UINavigationBar *)navigationBar;
+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIColor *)mainColor;
+ (UIColor *)buttonColor;
+ (UIColor *)buttonHighlightColor;

@end
