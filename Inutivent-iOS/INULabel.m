//
//  INULabel.m
//  Gromf
//
//  Created by Timo Kloss on 02/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INULabel.h"

@implementation INULabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    if (bounds.size.width != self.preferredMaxLayoutWidth)
    {
        self.preferredMaxLayoutWidth = bounds.size.width;
    }
}

@end
