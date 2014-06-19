//
//  INUSpinnerView.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 18/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUSpinnerView.h"

@interface INUSpinnerView ()

@property UILabel *titleLabel;
@property UILabel *messageLabel;
@property UIActivityIndicatorView *indicator;

@end

@implementation INUSpinnerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        [self addSubview:_indicator];
        [_indicator startAnimating];
    }
    return self;
}

+ (INUSpinnerView *)addNewSpinnerToView:(UIView *)superView
{
    INUSpinnerView *view = [[INUSpinnerView alloc] initWithFrame:superView.frame];
    if (view)
    {
        [superView addSubview:view];
    }
    return view;
}

- (void)showErrorWithTitle:(NSString *)title message:(NSString *)message
{
    [_indicator removeFromSuperview];
    [_indicator stopAnimating];
    
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:20];
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor grayColor];
        
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:18];
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.numberOfLines = 0;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.textColor = [UIColor grayColor];
        
        [self addSubview:_titleLabel];
        [self addSubview:_messageLabel];
    }
    
    _titleLabel.text = title;
    _messageLabel.text = message;
    
    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    _indicator.center = CGPointMake(self.center.x, self.frame.size.height * 0.4);
    if (_titleLabel)
    {
        _titleLabel.frame = CGRectMake(10, self.frame.size.height * 0.2, self.frame.size.width - 20, 60);
        _messageLabel.frame = CGRectMake(10, _titleLabel.frame.origin.y + _titleLabel.frame.size.height, self.frame.size.width - 20, 100);
    }
}

@end
