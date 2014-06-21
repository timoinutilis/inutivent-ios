//
//  INUSpinnerView.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 18/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUSpinnerView.h"

@interface INUSpinnerView ()

@property UIActivityIndicatorView *indicator;
@property UITextView *messageTextView;

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
    
    if (!_messageTextView)
    {
        _messageTextView = [[UITextView alloc] init];
        _messageTextView.editable = NO;
        [self addSubview:_messageTextView];
    }
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    UIColor *color = [UIColor lightGrayColor];
    
    
    NSMutableAttributedString *attrMessage = [[NSMutableAttributedString alloc] initWithString:title attributes:@{
        NSFontAttributeName:[UIFont boldSystemFontOfSize:20],
        NSForegroundColorAttributeName: color,
        NSParagraphStyleAttributeName: paragraph
    }];
    
    [attrMessage appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n\n%@", message] attributes:@{
        NSFontAttributeName:[UIFont systemFontOfSize:18],
        NSForegroundColorAttributeName: color,
        NSParagraphStyleAttributeName: paragraph
    }]];
    
    _messageTextView.attributedText = attrMessage;
    
    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    _indicator.center = CGPointMake(self.center.x, self.frame.size.height * 0.4);
    if (_messageTextView)
    {
        _messageTextView.frame = CGRectMake(10, self.frame.size.height * 0.5 - 75, self.frame.size.width - 20, 150);
    }
}

@end
