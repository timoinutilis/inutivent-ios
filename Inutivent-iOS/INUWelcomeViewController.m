//
//  INUWelcomeViewController.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 25/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUWelcomeViewController.h"
#import "INUWelcomeContentViewController.h"
#import "INUUtils.h"

@interface INUWelcomeViewController ()

@property NSArray *texts;
@property NSMutableArray *images;
@property UIImage *backgroundImage;

@end

@implementation INUWelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _texts = @[NSLocalizedString(@"Welcome1Text", nil),
               NSLocalizedString(@"Welcome2Text", nil),
               NSLocalizedString(@"Welcome3Text", nil),
               NSLocalizedString(@"Welcome4Text", nil),
               NSLocalizedString(@"Welcome5Text", nil)];
    
    NSArray *filenames = @[@"introduction_welcome.png", @"introduction_email.png", @"introduction_event_info.png", @"introduction_event_guests.png", @"introduction_event_comments.png"];
    
    _images = [NSMutableArray array];
    for (int i = 0; i < [filenames count]; i++)
    {
        UIImage *image = [UIImage imageNamed:filenames[i]];
        [_images addObject:image];
    }
    
    _backgroundImage = [UIImage imageNamed:@"welcome_bg.jpg"];

    self.dataSource = self;
    
    self.view.backgroundColor = [INUUtils bgColor];

    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
    
    INUWelcomeContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    int index = ((INUWelcomeContentViewController *)viewController).pageIndex;
    
    if (index == 0)
    {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    int index = ((INUWelcomeContentViewController *)viewController).pageIndex;
    
    index++;
    if (index == [_texts count])
    {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (INUWelcomeContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([_texts count] == 0) || (index >= [_texts count])) {
        return nil;
    }
    
    BOOL isLastPage = (index == [_texts count] - 1);
    
    // Create a new view controller and pass suitable data.
    INUWelcomeContentViewController *contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeContentView"];
    contentViewController.pageIndex = (int)index;
    contentViewController.text = _texts[index];
    contentViewController.image = _images[index];
    contentViewController.backgroundImage = _backgroundImage;
    if (self.presentingViewController != nil)
    {
        // is modal, show skip/start button
        contentViewController.buttonType = isLastPage ? INUWelcomeButtonTypeStart : INUWelcomeButtonTypeSkip;
    }
    else
    {
        // has navigation, no need for button
        contentViewController.buttonType = INUWelcomeButtonTypeNone;
    }
    
    return contentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [_texts count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
