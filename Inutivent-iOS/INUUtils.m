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

@end
