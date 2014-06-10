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

@interface INUEventsTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *selectedIndexPathsWhenViewAppeared;
@property Bookmark *lastOpenedBookmark;

@end

@implementation INUEventsTableViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [INUDataManager sharedInstance].delegate = self;
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
            NSLog(@"bookmark update");
            [[self tableView] reloadRowsAtIndexPaths:_selectedIndexPathsWhenViewAppeared withRowAnimation:UITableViewRowAnimationFade];
            _lastOpenedBookmark.wasChanged = NO;
        }
        _lastOpenedBookmark = nil;
        _selectedIndexPathsWhenViewAppeared = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [INUDataManager sharedInstance].delegate = nil;
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
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[INUDataManager sharedInstance] bookmarks] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPrototypeCell" forIndexPath:indexPath];
    
    Bookmark *bookmark = [[[INUDataManager sharedInstance] bookmarks] objectAtIndex:indexPath.row];
    cell.textLabel.text = bookmark.eventName.length > 0 ? bookmark.eventName : bookmark.eventId;
    
    return cell;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    INUEvent *tappedEvent = [self.events objectAtIndex:indexPath.row];
}*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


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
        Bookmark *selectedBookmark = [[[INUDataManager sharedInstance] bookmarks] objectAtIndex:indexPath.row];
        infoController.bookmark = selectedBookmark;
        _lastOpenedBookmark = selectedBookmark;
    }
}

#pragma mark - INUEventManager delegate

- (void)bookmarksChanged
{
    [[self tableView] reloadData];
}

@end
