//
//  INUEventInfoTableViewController.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 04/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUEventInfoTableViewController.h"
#import "INUEventTabBarController.h"
#import "INUGuestsTableViewController.h"
#import "INUPostsTableViewController.h"
#import "Bookmark.h"
#import "Event.h"
#import "User.h"
#import "INUDataManager.h"
#import "INUUtils.h"
#import "INUConfig.h"
#import "INUConstants.h"
#import "INUTextTableViewCell.h"
#import "INUEditTableViewController.h"

@interface INUEventInfoTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *ownerCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *dateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *hourCell;
@property (weak, nonatomic) IBOutlet INUTextTableViewCell *detailsCell;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailsHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITableViewCell *status1Cell;
@property (weak, nonatomic) IBOutlet UITableViewCell *status2Cell;
@property (weak, nonatomic) IBOutlet UITableViewCell *status3Cell;

@property Event *event;

@end

@implementation INUEventInfoTableViewController

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
    
    _titleLabel.layer.shadowOpacity = 1;
    _titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    _titleLabel.layer.shadowRadius = 1.5;
    
    _detailsCell.parentTableView = self.tableView;
    _detailsCell.textView.editable = NO;
    
    INUEventTabBarController *eventTabBarController = (INUEventTabBarController *)self.parentViewController;
    _bookmark = eventTabBarController.bookmark;
    _event = [[INUDataManager sharedInstance] getEventById:_bookmark.eventId];
    if (_event)
    {
        [self updateView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:nil object:[INUDataManager sharedInstance]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView layoutIfNeeded];
    [self.tableView reloadData];
}
*/
- (void)updateView
{
    [self updateCoverImage];
    _titleLabel.text = _event.title;
    
    [self updateOwner];
    
    _dateCell.textLabel.text = [NSDateFormatter localizedStringFromDate:_event.time dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterNoStyle];
    _hourCell.textLabel.text = [NSDateFormatter localizedStringFromDate:_event.time dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    
    _detailsCell.textView.attributedText = [[NSAttributedString alloc] initWithString:_event.details attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]}];
    
    [self updateUserView];
}

- (void)updateCoverImage
{
    if (_event.cover && ![_event.cover isEqualToString:@""])
    {
        NSString *path = [NSString stringWithFormat:@"%@/uploads/%@/%@", INUConfigSiteURL, _event.eventId, _event.cover];
        NSURL *url = [NSURL URLWithString:path];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError)
            {
                // default image
                _coverImage.image = [UIImage imageNamed:@"default_header.jpg"];
            }
            else
            {
                UIImage *image = [UIImage imageWithData:data];

                dispatch_async( dispatch_get_main_queue(), ^(void) {
                    _coverImage.image = image;
                });
            }
        }];
    }
    else
    {
        _coverImage.image = [UIImage imageNamed:@"default_header.jpg"];
    }
}

- (void)updateOwner
{
    _ownerCell.textLabel.text = [_event getUserWithId:_event.owner].name;
}

- (void)updateUserView
{
    User *me = [self getMe];
    self.nameField.text = [me.name isEqualToString:@"???"] ? @"" : me.name;
    self.status1Cell.accessoryType = (me.status == UserStatusAttending) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    self.status2Cell.accessoryType = (me.status == UserStatusMaybeAttending) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    self.status3Cell.accessoryType = (me.status == UserStatusNotAttending) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 3)
    {
        return [_detailsCell requiredCellHeight];
    }
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (_event && [_bookmark.userId isEqualToString:_event.owner])
    {
        return 4;
    }
    else
    {
        return 3;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        [_nameField becomeFirstResponder];
    }
    else if (indexPath.section == 2)
    {
        NSString *newStatus = @"U";
        if (indexPath.row == 0)
        {
            newStatus = @"A";
        }
        else if (indexPath.row == 1)
        {
            newStatus = @"M";
        }
        else if (indexPath.row == 2)
        {
            newStatus = @"N";
        }
        
        User *me = [self getMe];
        me.status = [me parseStatus:newStatus];
        me.statusChanged = [[NSDate alloc] init];
        [self updateUserView];
        [[INUDataManager sharedInstance] notifyUserUpdate];
        
        NSDictionary *paramsDict = @{@"event_id": _bookmark.eventId,
                                     @"user_id": _bookmark.userId,
                                     @"status": newStatus};
        [[INUDataManager sharedInstance] requestFromServer:INUServiceUpdateUser params:paramsDict info:nil onError:nil];

    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (User *)getMe
{
    return [_event getUserWithId:_bookmark.userId];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"EditEvent"])
    {
        UINavigationController *destViewController = segue.destinationViewController;
        INUEditTableViewController *editController = (INUEditTableViewController *)destViewController.topViewController;
        editController.bookmarkToEdit = _bookmark;
    }
}


#pragma mark - Actions

- (IBAction)onExitName:(id)sender
{
    User *me = [self getMe];
    NSString *newName = self.nameField.text;
    if ([newName isEqualToString:@""])
    {
        newName = @"???";
    }
    
    if (![newName isEqualToString:me.name])
    {
        me.name = newName;
        [self updateOwner];
        [[INUDataManager sharedInstance] notifyUserUpdate];
        
        NSDictionary *paramsDict = @{@"event_id": _bookmark.eventId,
                                     @"user_id": _bookmark.userId,
                                     @"name": newName};
        [[INUDataManager sharedInstance] requestFromServer:INUServiceUpdateUser params:paramsDict info:nil onError:nil];
    }
}

#pragma mark - INUDataManager

- (void)receivedNotification:(NSNotification *)notification
{
    if (   notification.name == INUEventLoadedNotification
        || notification.name == INUEventUpdatedNotification )
    {
        _event = [[INUDataManager sharedInstance] getEventById:_bookmark.eventId];
        [self updateView];
        [self.tableView reloadData];
    }
}

@end
