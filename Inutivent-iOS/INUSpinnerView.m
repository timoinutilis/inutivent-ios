//
//  INUSpinnerView.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 18/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUSpinnerView.h"

@implementation INUSpinnerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        
        // Set the resizing mask so it's not stretched
        indicator.autoresizingMask =
            UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleRightMargin |
            UIViewAutoresizingFlexibleBottomMargin |
            UIViewAutoresizingFlexibleLeftMargin;
        
        // Place it in the middle of the view
        indicator.center = CGPointMake(self.center.x, self.frame.size.height * 0.3);
        
        [self addSubview:indicator];
        [indicator startAnimating];
    }
    return self;
}

+ (INUSpinnerView *)addNewSpinnerToView:(UIView *)superView
{
    INUSpinnerView *view = [[INUSpinnerView alloc] initWithFrame:superView.bounds];
    if (view)
    {
        [superView addSubview:view];
    }
    return view;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
