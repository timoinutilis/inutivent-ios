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
#import "INUInviteViewController.h"
#import "Contact.h"
#import "INUSpinnerView.h"
#import "UIImageView+WebCache.h"

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
@property INUSpinnerView *spinnerView;

@end

@implementation INUEventInfoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [INUUtils initBackground:self.tableView];
    
    // correct table header size
    CGRect newFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 3 / 8);
    self.tableView.tableHeaderView.frame = newFrame;
    
    _titleLabel.layer.shadowOpacity = 1;
    _titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    _titleLabel.layer.shadowRadius = 1.5;
    
    _detailsCell.parentTableView = self.tableView;
    _detailsCell.textView.editable = NO;
    
    [self updateNamePlaceholder];
    
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

- (void)removeSpinner
{
    if (_spinnerView)
    {
        [_spinnerView removeFromSuperview];
        _spinnerView = nil;
    }
}

- (void)updateNamePlaceholder
{
    if ([INUDataManager sharedInstance].userContact.name.length > 0)
    {
        _nameField.placeholder = [INUDataManager sharedInstance].userContact.name;
    }
    else
    {
        _nameField.placeholder = NSLocalizedString(@"Enter your name", nil);
    }
}

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
        [_coverImage sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error)
            {
                // default image
                _coverImage.image = [UIImage imageNamed:@"default_header.jpg"];
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
    self.nameField.text = [me isNameUndefined] ? @"" : me.name;
    self.status1Cell.accessoryType = (me.status == UserStatusAttending) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    self.status2Cell.accessoryType = (me.status == UserStatusMaybeAttending) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    self.status3Cell.accessoryType = (me.status == UserStatusNotAttending) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 3)
    {
        return [_detailsCell requiredCellHeight];
    }
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && !(_event && [_bookmark.userId isEqualToString:_event.owner]))
    {
        return 0;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 2)
        {
            // delete
            NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Do you really want to delete the event \"%@\"?", nil), _event.title];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Delete", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
            [alert show];
        }
    }
    else if (indexPath.section == 2)
    {
        [_nameField becomeFirstResponder];
    }
    else if (indexPath.section == 3)
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
        
        NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
        paramsDict[@"event_id"] = _bookmark.eventId;
        paramsDict[@"user_id"] = _bookmark.userId;
        paramsDict[@"status"] = newStatus;
        
        if ([me isNameUndefined] && [INUDataManager sharedInstance].userContact.name.length > 0)
        {
            me.name = [INUDataManager sharedInstance].userContact.name;
            paramsDict[@"name"] = me.name;
        }
        
        [[INUDataManager sharedInstance] notifyUserUpdate];
        
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
    else if ([segue.identifier isEqualToString:@"Invite"])
    {
        UINavigationController *destViewController = segue.destinationViewController;
        INUInviteViewController *inviteController = (INUInviteViewController *)destViewController.topViewController;
        inviteController.bookmark = _bookmark;
    }
}


#pragma mark - Actions

- (IBAction)onExitName:(id)sender
{
    User *me = [self getMe];
    NSString *newName = self.nameField.text;
    if ([newName isEqualToString:@""])
    {
        newName = USER_NO_NAME;
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
        
        //update default user
        [INUDataManager sharedInstance].userContact.name = self.nameField.text; // not me.name, should not be "???"
        [[INUDataManager sharedInstance].userContact saveUserDefaults];
        
        [self updateNamePlaceholder];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // delete?
    if (buttonIndex == 0)
    {
        _spinnerView = [INUSpinnerView addNewSpinnerToView:self.navigationController.view transparent:YES];
        
        NSDictionary *paramsDict = @{@"event_id": _bookmark.eventId,
                                     @"user_id": _bookmark.userId};

        [[INUDataManager sharedInstance] requestFromServer:INUServiceDeleteEvent params:paramsDict info:nil onError:^BOOL(ServiceError *error) {
            [self removeSpinner];
            return NO;
        }];
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
    else if (notification.name == INUEventDeletedNotification)
    {
        if ([notification.userInfo[@"eventId"] isEqualToString:_bookmark.eventId])
        {
            [self removeSpinner];
        }
    }
    else if (notification.name == INUUserUpdatedNotification)
    {
        [self updateUserView];
    }
}

@end
