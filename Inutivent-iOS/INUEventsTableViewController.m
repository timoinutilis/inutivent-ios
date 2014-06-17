//
//  INUEventsTableViewController.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 31/05/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUEventsTableViewController.h"
#import "INUEventInfoTableViewController.h"
#import "Bookmark.h"
#import "Event.h"
#import "INUDataManager.h"
#import "INUListSection.h"

@interface INUEventsTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *selectedIndexPathsWhenViewAppeared;
@property Bookmark *lastOpenedBookmark;
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
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    _selectedIndexPathsWhenViewAppeared = self.tableView.indexPathsForSelectedRows;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_selectedIndexPathsWhenViewAppeared)
    {
        if (_lastOpenedBookmark && _lastOpenedBookmark.wasChanged)
        {
            [self updateSections];
            [[self tableView] reloadData];
            _lastOpenedBookmark.wasChanged = NO;
        }
        _lastOpenedBookmark = nil;
        _selectedIndexPathsWhenViewAppeared = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateSections
{
    _sections = [[NSMutableArray alloc] init];
    [self addEventsWithIsOwner:YES title:@"Your Events"];
    [self addEventsWithIsOwner:NO title:@"Events"];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    
    Bookmark *bookmark = [(INUListSection *)_sections[indexPath.section] array][indexPath.row];
    cell.textLabel.text = bookmark.eventName.length > 0 ? bookmark.eventName : bookmark.eventId;
    cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:bookmark.time dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterShortStyle];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ShowEvent"])
    {
        INUEventInfoTableViewController *infoController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        Bookmark *selectedBookmark = [(INUListSection *)_sections[indexPath.section] array][indexPath.row];
        infoController.bookmark = selectedBookmark;
        _lastOpenedBookmark = selectedBookmark;
    }
}

#pragma mark - INUDataManager

- (void)receivedNotification:(NSNotification *)notification
{
    if (notification.name == INUBookmarksChangedNotification)
    {
        [self updateSections];
        [[self tableView] reloadData];
    }
}

@end
