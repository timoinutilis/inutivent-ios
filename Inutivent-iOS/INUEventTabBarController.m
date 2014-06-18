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

@interface INUEventTabBarController ()

@property INUSpinnerView *spinnerView;

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
