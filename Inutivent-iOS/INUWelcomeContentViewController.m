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

@property CGFloat originalTopSpace;

@end

@implementation INUWelcomeContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _originalTopSpace = _topLayoutConstraint.constant;
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
/*    if (   SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")
        && _buttonType == INUWelcomeButtonTypeNone ) // if skip button -> no navigation bar
    {
        // topLayoutGuide isn't working correctly, hack to fix it.
        CGRect navBarFrame = self.navigationController.navigationBar.frame;
        CGFloat topUIHeight = navBarFrame.origin.y + navBarFrame.size.height - self.topLayoutGuide.length;
        _topLayoutConstraint.constant = topUIHeight + _originalTopSpace;
    }*/
    
    [super viewWillLayoutSubviews];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions

- (IBAction)onTapSkip:(id)sender
{
    [[INUDataManager sharedInstance] setIntroductionDone];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
