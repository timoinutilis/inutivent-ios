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

@interface INUEventTabBarController ()

@property INUSpinnerView *spinnerView;

@property (weak, nonatomic) IBOutlet UIView *barView;
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
    
    _barView.layer.shadowOpacity = 1;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.viewControllers = @[
                         [storyboard instantiateViewControllerWithIdentifier:@"EventInfo"],
                         [storyboard instantiateViewControllerWithIdentifier:@"EventGuests"],
                         [storyboard instantiateViewControllerWithIdentifier:@"EventPosts"]
                         ];
    
    _selectedViewController = _viewControllers[0];
    [self displayContentController:_selectedViewController];
    
    if ([[INUDataManager sharedInstance] getEventById:_bookmark.eventId])
    {
        [self updateView];
    }
    else
    {
        _spinnerView = [INUSpinnerView addNewSpinnerToView:self.view];
        [self loadEvent];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:nil object:[INUDataManager sharedInstance]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTapTab:(id)sender
{
    int index = _tabControl.selectedSegmentIndex;
    if (_selectedViewController)
    {
        [self hideContentController:_selectedViewController];
    }
    _selectedViewController = _viewControllers[index];
    [self displayContentController:_selectedViewController];
}

- (void) displayContentController: (UIViewController*)content
{
    [self addChildViewController:content];
    
    // adjust scroll insets for content view
    if ([content respondsToSelector:@selector(tableView)])
    {
        UITableView *contentTableView = (UITableView *)[content performSelector:@selector(tableView)];
        
        CGFloat topUIHeight = _barView.frame.size.height;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            CGRect navBarFrame = self.navigationController.navigationBar.frame;
            topUIHeight += navBarFrame.origin.y + navBarFrame.size.height;
        }
        if (contentTableView.contentInset.top != topUIHeight)
        {
            UIEdgeInsets insets = UIEdgeInsetsMake(topUIHeight, 0.0, 0, 0.0);
            contentTableView.contentInset = insets;
            contentTableView.scrollIndicatorInsets = insets;
        }
    }
    
    content.view.frame = self.view.frame;
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
    [[INUDataManager sharedInstance] requestFromServer:@"getevent.php" params:[NSDictionary dictionaryWithObjectsAndKeys:_bookmark.eventId, @"event_id", _bookmark.userId, @"user_id", nil]];
}

- (void)updateView
{
    Event *event = [[INUDataManager sharedInstance] getEventById:_bookmark.eventId];
    if (event)
    {
        self.navigationItem.title = event.title;
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
    }
}

@end
