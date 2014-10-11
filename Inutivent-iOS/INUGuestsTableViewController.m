//
//  INUGuestsTableViewController.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 10/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUGuestsTableViewController.h"
#import "INUEventTabBarController.h"
#import "INUInviteViewController.h"
#import "INUDataManager.h"
#import "Bookmark.h"
#import "User.h"
#import "Event.h"
#import "INUListSection.h"
#import "INUUtils.h"

static NSString *const INUGuestsInvite = @"INUGuestsInvite";

@interface INUGuestsTableViewController ()

@property Bookmark *bookmark;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *guestSections;
@property BOOL anybodyHasntSeen;

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
    
    [INUUtils initBackground:self.tableView];
    
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
    _anybodyHasntSeen = NO;
    _guestSections = [[NSMutableArray alloc] init];
    
    if ([_bookmark.ownerUserId isEqualToString:_bookmark.userId])
    {
        [_guestSections addObject:[[INUListSection alloc] initWithTitle:nil array:@[INUGuestsInvite]]];
    }
    
    [self addGuestsWithStatus:UserStatusAttending title:NSLocalizedString(@"Going", nil)];
    [self addGuestsWithStatus:UserStatusMaybeAttending title:NSLocalizedString(@"Maybe Going", nil)];
    [self addGuestsWithStatus:UserStatusNotAttending title:NSLocalizedString(@"Not Going", nil)];
    [self addGuestsWithStatus:UserStatusUnknown title:NSLocalizedString(@"Invited", nil)];
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
            if (user.visited == nil)
            {
                _anybodyHasntSeen = YES;
            }
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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (_anybodyHasntSeen && section == [_guestSections count] - 1)
    {
        return NSLocalizedString(@"* hasn't seen it yet", nil);
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id rowObject = [(INUListSection *)_guestSections[indexPath.section] array][indexPath.row];
    UITableViewCell *cell = nil;
    if (rowObject == INUGuestsInvite)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"InviteCell" forIndexPath:indexPath];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
        
        User *user = rowObject;
        NSString *label = user.name;
        if ([user.userId isEqualToString:_event.owner])
        {
            label = [NSString stringWithFormat:@"%@ (%@)", label, NSLocalizedString(@"Host", nil)];
        }
        if (user.visited == nil)
        {
            label = [label stringByAppendingString:@" *"];
        }
        cell.textLabel.text = label;
    }
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"GuestsInvite"])
    {
        UINavigationController *destViewController = segue.destinationViewController;
        INUInviteViewController *inviteController = (INUInviteViewController *)destViewController.topViewController;
        inviteController.bookmark = _bookmark;
    }

}

#pragma mark - INUDataManager

- (void)receivedNotification:(NSNotification *)notification
{
    if (notification.name == INUEventLoadedNotification || notification.name == INUUserUpdatedNotification)
    {
        _event = [[INUDataManager sharedInstance] getEventById:_bookmark.eventId];
        [self updateSections];
        [self.tableView reloadData];
    }
}

@end
