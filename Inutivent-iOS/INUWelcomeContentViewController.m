//
//  INUWelcomeContentViewController.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 25/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUWelcomeContentViewController.h"
#import "INUDataManager.h"

@interface INUWelcomeContentViewController ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UILabel *bubbleLabel;

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
    
    _textLabel.text = _text;
    _bubbleLabel.text = _bubbleText;
    _bubbleLabel.hidden = [_bubbleText isEqualToString:@""];
    
    NSString *filename = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], _image];
    _imageView.image = [UIImage imageWithContentsOfFile:filename];

    if (_buttonType == INUWelcomeButtonTypeNone)
    {
        _skipButton.hidden = YES;
    }
    else
    {
        _skipButton.hidden = NO;
        [_skipButton setTitle:(_buttonType == INUWelcomeButtonTypeStart) ? @"Start" : @"Skip" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
