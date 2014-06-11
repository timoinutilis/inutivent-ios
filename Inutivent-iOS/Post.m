//
//  Post.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 11/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "Post.h"
#import "INUUtils.h"

@implementation Post

- (void)parseFromDictionary:(NSDictionary *)dict
{
    _postId = [dict[@"id"] intValue];
    _userId = dict[@"user_id"];
    _type = [self parseType:dict[@"type"]];
    _data = dict[@"data"];
    _created = [INUUtils dateFromDatetime:dict[@"created"]];
}

- (PostType)parseType:(NSString *)type
{
    return PostTypeText;
}

@end
