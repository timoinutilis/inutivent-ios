//
//  INUSpinnerView.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 18/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUSpinnerView.h"
#import "INUUtils.h"

@interface INUSpinnerView ()

@property UIActivityIndicatorView *indicator;
@property UITextView *messageTextView;
@property UIView *backgroundView;

@end

@implementation INUSpinnerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
//        UIImage *image = [UIImage imageNamed:@"paper"];
        _backgroundView = [[UIView alloc] initWithFrame:frame];
//        _backgroundView.backgroundColor = [UIColor colorWithPatternImage:image];
        _backgroundView.backgroundColor = [INUUtils bgColor];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_backgroundView];
        
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        [self addSubview:_indicator];
        [_indicator startAnimating];
    }
    return self;
}

+ (INUSpinnerView *)addNewSpinnerToView:(UIView *)superView
{
    return [INUSpinnerView addNewSpinnerToView:superView transparent:NO];
}

+ (INUSpinnerView *)addNewSpinnerToView:(UIView *)superView transparent:(BOOL)transparent
{
    INUSpinnerView *view = [[INUSpinnerView alloc] initWithFrame:superView.bounds];
    if (view)
    {
        if (transparent)
        {
            view.backgroundView.alpha = 0.75;
        }
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
        _messageTextView.backgroundColor = [UIColor clearColor];
        [self addSubview:_messageTextView];
    }
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    UIColor *color = [UIColor grayColor];
    
    
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
    _indicator.center = CGPointMake(self.center.x, self.frame.size.height * 0.5);
    if (_messageTextView)
    {
        _messageTextView.frame = CGRectMake(10, self.frame.size.height * 0.5 - 75, self.frame.size.width - 20, 150);
    }
}

@end
