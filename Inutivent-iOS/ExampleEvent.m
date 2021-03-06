//
//  ExampleEvent.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 26/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "ExampleEvent.h"
#import "User.h"
#import "Post.h"

@implementation ExampleEvent

- (id)init
{
    if (self = [super init])
    {
        // event
        
        self.eventId = ExampleEventId;
        self.owner = ExampleOwnerId;
        self.title = NSLocalizedString(@"Example", nil);
        self.details = NSLocalizedString(@"ExampleDetailsText", nil);
        self.time = [[NSDate alloc] initWithTimeIntervalSinceNow:100 * 24 * 60 * 60];
        self.cover = nil;
        self.created = [NSDate date];
        
        // users
        
        User *user;
        
        user = [[User alloc] init];
        user.userId = ExampleOwnerId;
        user.name = @"Gromf";
        user.status = UserStatusAttending;
        user.statusChanged = [NSDate date];
        user.visited = [NSDate date];
        [self.users addObject:user];
        
        user = [[User alloc] init];
        user.userId = ExampleUserId;
        user.name = @"???";
        user.status = UserStatusUnknown;
        user.visited = [NSDate date];
        [self.users addObject:user];

        user = [[User alloc] init];
        user.userId = @"3";
        user.name = NSLocalizedString(@"Timo", nil);
        user.status = UserStatusMaybeAttending;
        user.statusChanged = [NSDate date];
        user.visited = [NSDate date];
        [self.users addObject:user];

        user = [[User alloc] init];
        user.userId = @"4";
        user.name = NSLocalizedString(@"Mara", nil);
        user.status = UserStatusAttending;
        user.statusChanged = [NSDate date];
        user.visited = [NSDate date];
        [self.users addObject:user];
        
        // posts
        
        Post *post;
        
        post = [[Post alloc] init];
        post.userId = ExampleOwnerId;
        post.type = PostTypeText;
        post.data = NSLocalizedString(@"ExamplePost1Text", nil);
        post.created = [NSDate date];
        [self.posts addObject:post];

        post = [[Post alloc] init];
        post.userId = @"4";
        post.type = PostTypeText;
        post.data = NSLocalizedString(@"ExamplePost2Text", nil);
        post.created = [NSDate date];
        [self.posts addObject:post];

    }
    return self;
}

@end

NSString *const ExampleEventId = @"1";
NSString *const ExampleUserId = @"2";
NSString *const ExampleOwnerId = @"1";