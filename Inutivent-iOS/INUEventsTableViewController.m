//
//  INUEventsTableViewController.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 31/05/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUEventsTableViewController.h"
#import "INUEventTabBarController.h"
#import "Bookmark.h"
#import "Event.h"
#import "INUDataManager.h"
#import "INUListSection.h"
#import "INUWelcomeViewController.h"
#import "INUConfig.h"

typedef NS_ENUM(int, INUEventsAlertTag)
{
    INUEventsAlertTagCreate = 1,
    INUEventsAlertTagDelete
};

@interface INUEventsTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property Bookmark *lastOpenedBookmark;
@property NSIndexPath *tappedIndexPath;
@property NSMutableArray *sections;

@end

@implementation INUEventsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
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
    
    [self updateSections];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:nil object:[INUDataManager sharedInstance]];
    
    // Show introduction on first app start
    if ([[INUDataManager sharedInstance] needsIntroduction])
    {
        INUWelcomeViewController *welcomeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeView"];
        [self presentViewController:welcomeViewController animated:NO completion:nil];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_lastOpenedBookmark && _lastOpenedBookmark.wasChanged)
    {
        [self updateSections];
        [[self tableView] reloadData];
        _lastOpenedBookmark.wasChanged = NO;
        
        NSIndexPath *indexPath = [self getPathIndexOfBookmark:_lastOpenedBookmark];
        if (indexPath)
        {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    _lastOpenedBookmark = nil;

    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateSections
{
    _sections = [[NSMutableArray alloc] init];
    [self addEventsWithIsOwner:YES title:NSLocalizedString(@"Your Events", nil)];
    [self addEventsWithIsOwner:NO title:NSLocalizedString(@"Events", nil)];
    [_sections addObject:[[INUListSection alloc] initWithTitle:NSLocalizedString(@"Information", nil)
                                                         array:[NSMutableArray arrayWithObjects:NSLocalizedString(@"Introduction", nil), NSLocalizedString(@"About", nil), nil]]];
}

- (void)addEventsWithIsOwner:(BOOL)isOwner title:(NSString *)title
{
    NSMutableArray *bookmarks = [[INUDataManager sharedInstance] bookmarks];
    NSMutableArray *sectionEvents = [[NSMutableArray alloc] init];
    int count = (int)[bookmarks count];
    for (int i = 0; i < count; i++)
    {
        Bookmark *bookmark = bookmarks[i];
        BOOL bookmarkIsOwner = [bookmark.userId isEqualToString:bookmark.ownerUserId];
        if (bookmarkIsOwner == isOwner)
        {
            [sectionEvents addObject:bookmark];
        }
    }
    if ([sectionEvents count] > 0)
    {
        [sectionEvents sortUsingComparator:^NSComparisonResult(Bookmark *bookmark1, Bookmark *bookmark2) {
            if (!bookmark1.time && !bookmark2.time)
            {
                return NSOrderedSame;
            }
            if (!bookmark1.time)
            {
                return NSOrderedDescending;
            }
            if (!bookmark2.time)
            {
                return NSOrderedAscending;
            }
            return [bookmark1.time compare:bookmark2.time];
        }];
        [_sections addObject:[[INUListSection alloc] initWithTitle:title array:sectionEvents]];
    }
}

- (NSIndexPath *)getPathIndexOfBookmark:(Bookmark *)bookmark
{
    int count = (int)[_sections count];
    for (int section = 0; section < count; section++)
    {
        NSArray *sectionBookmarks = [(INUListSection *)_sections[section] array];
        NSUInteger row = [sectionBookmarks indexOfObject:bookmark];
        if (row != NSNotFound)
        {
            return [NSIndexPath indexPathForRow:row inSection:section];
        }
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[(INUListSection *)_sections[section] array] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [(INUListSection *)_sections[section] title];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    id item = [(INUListSection *)_sections[indexPath.section] array][indexPath.row];
    if (indexPath.section < [_sections count] - 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
        Bookmark *bookmark = item;
        cell.textLabel.text = bookmark.eventName.length > 0 ? bookmark.eventName : NSLocalizedString(@"Event", nil);
        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:bookmark.time dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterShortStyle];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NavPrototypeCell" forIndexPath:indexPath];
        NSString *label = item;
        cell.textLabel.text = label;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == [_sections count] - 1)
    {
        if (indexPath.row == 0)
        {
            [self performSegueWithIdentifier:@"ShowWelcome" sender:self];
        }
        else if (indexPath.row == 1)
        {
            [self performSegueWithIdentifier:@"ShowAbout" sender:self];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ShowEvent"])
    {
        INUEventTabBarController *tabController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        Bookmark *selectedBookmark = [(INUListSection *)_sections[indexPath.section] array][indexPath.row];
        tabController.bookmark = selectedBookmark;
        _lastOpenedBookmark = selectedBookmark;
    }
}

#pragma mark - Actions

- (IBAction)onTapCreate:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Create New Event", nil)
                                                    message:NSLocalizedString(@"You can create new events on the website only.", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"Go to Website", nil), nil];
    alert.tag = INUEventsAlertTagCreate;
    [alert show];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    _tappedIndexPath = indexPath;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remove Event from List", nil)
                                                    message:NSLocalizedString(@"The event will not be deleted from the website.", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Remove", nil)
                                          otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
    alert.tag = INUEventsAlertTagDelete;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == INUEventsAlertTagCreate)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex)
        {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/create.php", INUConfigSiteURL]];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    else if (alertView.tag == INUEventsAlertTagDelete)
    {
        if (buttonIndex == alertView.cancelButtonIndex)
        {
            [self deleteBookmarkFromIndexPath:_tappedIndexPath];
        }
        _tappedIndexPath = nil;
    }
}

- (void)deleteBookmarkFromIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sectionBookmarks = [(INUListSection *)_sections[indexPath.section] array];
    BOOL wasLastInSection = [sectionBookmarks count] == 1;

    Bookmark *bookmark = sectionBookmarks[indexPath.row];
    [[INUDataManager sharedInstance] deleteBookmark:bookmark];
    [self updateSections];
    
    [self.tableView beginUpdates];
    if (wasLastInSection)
    {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView endUpdates];
}

#pragma mark - INUDataManager

- (void)receivedNotification:(NSNotification *)notification
{
    if (notification.name == INUBookmarksChangedNotification)
    {
        [self updateSections];
        [self.tableView reloadData];
    }
    else if (notification.name == INUBookmarkAddedByURLNotification)
    {
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        Bookmark *bookmark = notification.userInfo[@"bookmark"];
        NSIndexPath *indexPath = [self getPathIndexOfBookmark:bookmark];
        if (indexPath)
        {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self performSegueWithIdentifier:@"ShowEvent" sender:self];
        }
    }
}

@end
