//
//  INUListSection.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 10/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUListSection.h"

@implementation INUListSection

- (id)initWithTitle:(NSString *)title array:(NSMutableArray *)array
{
    if (self = [super init])
    {
        self.title = title;
        self.array = array;
    }
    return self;
}

@end
