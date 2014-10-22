//
//  INUSplitDetailViewController.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 30/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUSplitDetailViewController.h"
#import "Bookmark.h"
#import "INUEventTabBarController.h"
#import "INUUtils.h"

@interface INUSplitDetailViewController ()

@end

@implementation INUSplitDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.splitViewController.delegate = self;
    
    [INUUtils initNavigationBar:self.navigationBar];
    
    UIImage *image = [UIImage imageNamed:@"paper"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
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

- (void)showEvent:(Bookmark *)bookmark
{
    INUEventTabBarController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EventTabBarView"];
    viewController.bookmark = bookmark;
    [self setViewControllers:@[viewController] animated:NO];
}

- (void)showWelcome
{
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeView"];
    [self setViewControllers:@[viewController] animated:NO];
}

- (void)showAbout
{
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutView"];
    [self setViewControllers:@[viewController] animated:NO];
}

@end
