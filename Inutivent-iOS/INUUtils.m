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

@end
