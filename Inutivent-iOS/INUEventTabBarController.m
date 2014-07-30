//
//  INUEventTabBarController.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 17/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUEventTabBarController.h"
#import "INUDataManager.h"
#import "Bookmark.h"
#import "Event.h"
#import "INUSpinnerView.h"
#import "INUUtils.h"
#import "INUConfig.h"
#import "INUConstants.h"
#import "ServiceError.h"

@interface INUEventTabBarController ()

@property INUSpinnerView *spinnerView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *tabControl;

@property NSArray *viewControllers;
@property UIViewController *selectedViewController;

@end

@implementation INUEventTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        _tabControl.tintColor = [UIColor whiteColor];
    }
    else
    {
        _tabControl.tintColor = [INUUtils mainColor];
    }
    
    UIStoryboard *storyboard = self.storyboard;
    self.viewControllers = @[
                         [storyboard instantiateViewControllerWithIdentifier:@"EventInfo"],
                         [storyboard instantiateViewControllerWithIdentifier:@"EventGuests"],
                         [storyboard instantiateViewControllerWithIdentifier:@"EventPosts"]
                         ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:nil object:[INUDataManager sharedInstance]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    Event *event = [[INUDataManager sharedInstance] getEventById:_bookmark.eventId];

    if (event)
    {
        _selectedViewController = _viewControllers[0];
        [self displayContentController:_selectedViewController];
        [self updateView];
    }
    else
    {
        _spinnerView = [INUSpinnerView addNewSpinnerToView:self.view];
    }
    
    NSDate *now = [[NSDate alloc] init];
    if (!event || [now timeIntervalSinceDate:event.lastUpdate] >= INUConfigEventReloadTime)
    {
        [self loadEvent];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTapTab:(id)sender
{
    if (!_spinnerView)
    {
        int index = (int)_tabControl.selectedSegmentIndex;
        if (_selectedViewController)
        {
            [self hideContentController:_selectedViewController];
        }
        _selectedViewController = _viewControllers[index];
        [self displayContentController:_selectedViewController];
    }
}

- (void) displayContentController: (UIViewController*)content
{
    [self addChildViewController:content];
    
    // adjust scroll insets for content view
/*    if ([content respondsToSelector:@selector(tableView)])
    {
        UITableView *contentTableView = (UITableView *)[content performSelector:@selector(tableView)];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            CGRect navBarFrame = self.navigationController.navigationBar.frame;
            CGFloat topUIHeight = navBarFrame.origin.y + navBarFrame.size.height;
            if (contentTableView.contentInset.top != topUIHeight)
            {
                UIEdgeInsets insets = UIEdgeInsetsMake(topUIHeight, 0.0, 0, 0.0);
                contentTableView.contentInset = insets;
                contentTableView.scrollIndicatorInsets = insets;
            }
        }
    }*/
    
    content.view.frame = self.view.bounds;
    [self.view insertSubview:content.view atIndex:0];
    [content didMoveToParentViewController:self];
}

- (void) hideContentController: (UIViewController*)content
{
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

- (void)loadEvent
{
    [[INUDataManager sharedInstance] requestFromServer:INUServiceGetEvent params:@{@"event_id": _bookmark.eventId, @"user_id": _bookmark.userId} info:nil onError:^BOOL(ServiceError *error) {
        if (_spinnerView)
        {
            [_spinnerView showErrorWithTitle:error.title message:error.message];
            return YES;
        }
        return NO;
    }];
}

- (void)updateView
{
    Event *event = [[INUDataManager sharedInstance] getEventById:_bookmark.eventId];
    if (event)
    {
    }
}

- (IBAction)onTapRefresh:(id)sender
{
    [self loadEvent];
}

#pragma mark - INUDataManager

- (void)receivedNotification:(NSNotification *)notification
{
    if (notification.name == INUEventLoadedNotification)
    {
        [self updateView];
        if (_spinnerView)
        {
            [_spinnerView removeFromSuperview];
            _spinnerView = nil;
        }
        if (!_selectedViewController)
        {
            _selectedViewController = _viewControllers[_tabControl.selectedSegmentIndex];
            [self displayContentController:_selectedViewController];
        }
    }
}

@end
