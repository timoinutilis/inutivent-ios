//
//  Post.h
//  Inutivent-iOS
//
//  Created by Timo Kloss on 11/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, PostType)
{
    PostTypeText
};

@interface Post : NSObject

@property int postId;
@property NSString *userId;
@property PostType type;
@property NSString *data;
@property NSDate *created;

- (void)parseFromDictionary:(NSDictionary *)dict;
- (PostType)parseType:(NSString *)type;

@end
