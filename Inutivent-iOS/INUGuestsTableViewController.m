//
//  INUGuestsTableViewController.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 10/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUGuestsTableViewController.h"
#import "INUEventTabBarController.h"
#import "INUDataManager.h"
#import "Bookmark.h"
#import "User.h"
#import "Event.h"
#import "INUListSection.h"

@interface INUGuestsTableViewController ()

@property Bookmark *bookmark;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *guestSections;

@end

@implementation INUGuestsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    INUEventTabBarController *eventTabBarController = (INUEventTabBarController *)self.parentViewController;
    _bookmark = eventTabBarController.bookmark;
    _event = [[INUDataManager sharedInstance] getEventById:_bookmark.eventId];
    if (_event)
    {
        [self updateSections];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:nil object:[INUDataManager sharedInstance]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateSections
{
    _guestSections = [[NSMutableArray alloc] init];
    [self addGuestsWithStatus:UserStatusAttending title:@"Going"];
    [self addGuestsWithStatus:UserStatusMaybeAttending title:@"Maybe"];
    [self addGuestsWithStatus:UserStatusNotAttending title:@"Not Going"];
    [self addGuestsWithStatus:UserStatusUnknown title:@"Invited"];
}

- (void)addGuestsWithStatus:(UserStatus)status title:(NSString *)title
{
    NSMutableArray *statusGuests = [[NSMutableArray alloc] init];
    int count = (int)[_event.users count];
    for (int i = 0; i < count; i++)
    {
        User *user = _event.users[i];
        if (user.status == status)
        {
            [statusGuests addObject:user];
        }
    }
    if ([statusGuests count] > 0)
    {
        [statusGuests sortUsingComparator:^NSComparisonResult(User *user1, User *user2) {
            return [user1.statusChanged compare:user2.statusChanged];
        }];
        [_guestSections addObject:[[INUListSection alloc] initWithTitle:title array:statusGuests]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_guestSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[(INUListSection *)_guestSections[section] array] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [(INUListSection *)_guestSections[section] title];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    
    User *user = [(INUListSection *)_guestSections[indexPath.section] array][indexPath.row];
    NSString *label = user.name;
    if ([user.userId isEqualToString:_event.owner])
    {
        label = [label stringByAppendingString:@" (Host)"];
    }
    if (user.visited == nil)
    {
        label = [label stringByAppendingString:@" *"];
    }
    cell.textLabel.text = label;
    
    return cell;
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

#pragma mark - INUDataManager

- (void)receivedNotification:(NSNotification *)notification
{
    if (notification.name == INUEventLoadedNotification)
    {
        [self updateSections];
        [self.tableView reloadData];
    }
}

@end
