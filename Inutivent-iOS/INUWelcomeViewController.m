//
//  INUWelcomeViewController.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 25/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUWelcomeViewController.h"
#import "INUWelcomeContentViewController.h"

@interface INUWelcomeViewController ()

@property NSArray *texts;
@property NSMutableArray *images;

@end

@implementation INUWelcomeViewController

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
    
    _texts = @[NSLocalizedString(@"Welcome1Text", nil),
               NSLocalizedString(@"Welcome2Text", nil),
               NSLocalizedString(@"Welcome3Text", nil),
               NSLocalizedString(@"Welcome4Text", nil),
               NSLocalizedString(@"Welcome5Text", nil)];
    
    NSArray *filenames = @[@"introduction_welcome.png", @"introduction_email.png", @"introduction_event_info.png", @"introduction_event_guests.png", @"introduction_event_comments.png"];

    _images = [NSMutableArray array];
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    for (int i = 0; i < [filenames count]; i++)
    {
        NSString *filename = [NSString stringWithFormat:@"%@/%@", bundlePath, filenames[i]];
        UIImage *image = [UIImage imageWithContentsOfFile:filename];
        [_images addObject:image];
    }

    self.dataSource = self;
    
    self.view.backgroundColor = [UIColor whiteColor];

    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    INUWelcomeContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
