//
//  INUUtils.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 05/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUUtils.h"

@implementation INUUtils

+ (NSDate *)dateFromDatetime:(NSString *)datetime
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setTimeZone:[NSTimeZone defaultTimeZone]];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [fmt dateFromString:datetime];
}

+ (NSMutableDictionary *)getParamsFromURL:(NSURL *)url
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

+ (void)initBackground:(UITableView *)tableView
{
    UIImage *image = [UIImage imageNamed:@"paper"];
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor colorWithPatternImage:image];
}

+ (void)initNavigationBar:(UINavigationBar *)navigationBar
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        navigationBar.tintColor = [UIColor whiteColor];
//        navigationBar.barStyle = UIBarStyleBlackOpaque;
        navigationBar.barTintColor = [INUUtils mainColor];
        navigationBar.translucent = NO;
        navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    }
    else
    {
        navigationBar.tintColor = [INUUtils mainColor];
    }
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIColor *)mainColor
{
    return [UIColor colorWithRed:227.0/255.0 green:70.0/255.0 blue:35.0/255.0 alpha:1.0];
}

+ (UIColor *)buttonColor
{
    return [UIColor colorWithRed:27.0/255.0 green:111.0/255.0 blue:142.0/255.0 alpha:1.0];
}

+ (UIColor *)buttonHighlightColor
{
    return [UIColor colorWithRed:87.0/255.0 green:165.0/255.0 blue:195.0/255.0 alpha:1.0];
}

@end
