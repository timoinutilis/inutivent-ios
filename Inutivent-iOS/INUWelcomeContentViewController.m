//
//  INUWelcomeContentViewController.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 25/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUWelcomeContentViewController.h"
#import "INUDataManager.h"
#import "INUUtils.h"

@interface INUWelcomeContentViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *skipButtonHeightConstraint;

@property UIImageView *background;
@property CGFloat originalTopSpace;

@end

@implementation INUWelcomeContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _originalTopSpace = _topLayoutConstraint.constant;
    
    _background = [[UIImageView alloc] initWithImage:_backgroundImage];
    _background.contentMode = UIViewContentModeScaleAspectFill;
    _background.clipsToBounds = YES;
    [self.view insertSubview:_background atIndex:0];
    
    _textLabel.layer.shadowOpacity = 1;
    _textLabel.layer.shadowOffset = CGSizeMake(0, 1);
    _textLabel.layer.shadowRadius = 1.5;
    
    _textLabel.text = _text;
    _imageView.image = _image;

    if (_buttonType == INUWelcomeButtonTypeNone)
    {
        _skipButton.hidden = YES;
        _skipButtonHeightConstraint.constant = 0;
    }
    else
    {
        _skipButton.hidden = NO;
        [_skipButton setTitle:(_buttonType == INUWelcomeButtonTypeStart) ? NSLocalizedString(@"Start", nil) : NSLocalizedString(@"Skip", nil)
                     forState:UIControlStateNormal];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _background.frame = self.view.bounds;
}

#pragma mark - Actions

- (IBAction)onTapSkip:(id)sender
{
    [[INUDataManager sharedInstance] setIntroductionDone];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
