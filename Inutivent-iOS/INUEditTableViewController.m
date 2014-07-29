//
//  INUEditTableViewController.m
//  Gromf
//
//  Created by Timo Kloss on 22/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUEditTableViewController.h"
#import "INUUtils.h"
#import "INUInputTableViewCell.h"
#import "INUDateTableViewCell.h"
#import "INUTextTableViewCell.h"
#import "Event.h"
#import "INUDataManager.h"
#import "INUSpinnerView.h"
#import "Bookmark.h"

@interface INUEditTableViewController ()

@property (weak, nonatomic) IBOutlet INUInputTableViewCell *titleCell;
@property (weak, nonatomic) IBOutlet INUDateTableViewCell *whenCell;
@property (weak, nonatomic) IBOutlet INUTextTableViewCell *detailsCell;
@property (weak, nonatomic) IBOutlet INUInputTableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet INUInputTableViewCell *mailCell;

@property INUSpinnerView *spinnerView;

@end

@implementation INUEditTableViewController

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
    
    [INUUtils initNavigationBar:self.navigationController.navigationBar];
    [INUUtils initBackground:self.tableView];
    
    _titleCell.textField.placeholder = @"Example: Birthday Party";
    
    _whenCell.datePicker.minimumDate = [[NSDate alloc] initWithTimeIntervalSinceNow:(60 * 60)];
    _whenCell.datePicker.maximumDate = [[NSDate alloc] initWithTimeIntervalSinceNow:(365 * 24 * 60 * 60)];
    NSDate *defaultDate = [INUUtils dateAfter:_whenCell.datePicker.minimumDate atHour:20 minute:0];
    _whenCell.currentDate = defaultDate;
    
    _detailsCell.parentTableView = self.tableView;
    _detailsCell.textView.font = [UIFont systemFontOfSize:18];
    
    _nameCell.textField.placeholder = @"Enter your name";
    _nameCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    _mailCell.textField.placeholder = @"Enter your e-mail address";
    _mailCell.textField.keyboardType = UIKeyboardTypeEmailAddress;
    _mailCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _mailCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (void)removeSpinner
{
    if (_spinnerView)
    {
        [_spinnerView removeFromSuperview];
        _spinnerView = nil;
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0)
    {
        CGFloat height = [_detailsCell requiredCellHeight];
        return MAX(88, height);
    }
    return UITableViewAutomaticDimension;
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
*/
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
*/

#pragma mark - Actions

- (IBAction)onCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onDone:(id)sender
{
    if ([self validateUserInput])
    {
        _spinnerView = [INUSpinnerView addNewSpinnerToView:self.view];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        formatter.dateFormat = @"dd/MM/yyyy";
        NSString *date = [formatter stringFromDate:_whenCell.currentDate];

        formatter.dateFormat = @"HH:mm";
        NSString *hour = [formatter stringFromDate:_whenCell.currentDate];
        
        // Create new event
        NSDictionary *params = @{@"name": _nameCell.textField.text,
                                 @"mail": _mailCell.textField.text,
                                 @"title": _titleCell.textField.text,
                                 @"date": date,
                                 @"hour": hour,
                                 @"details": _detailsCell.textView.text};
        
        NSDictionary *info = @{@"title": _titleCell.textField.text,
                               @"time": _whenCell.currentDate};
        
        [[INUDataManager sharedInstance] requestFromServer:@"createevent.php" params:params info:info];
    }
}

- (BOOL)validateUserInput
{
    if (   [_titleCell.textField.text length] == 0
        || [_detailsCell.textView.text length] == 0
        || [_nameCell.textField.text length] == 0
        || [_mailCell.textField.text length] == 0 )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please fill out all fields.", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    return YES;
}

#pragma mark - Navigation
/*
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
    if (notification.name == INUEventCreatedNotification)
    {
        Bookmark *bookmark = notification.userInfo[@"bookmark"];

        [self dismissViewControllerAnimated:YES completion:^(void) {
            [[INUDataManager sharedInstance] notifyNewEventViewClosed:bookmark];
        }];
    }
    else if (notification.name == INUErrorNotification)
    {
        [self removeSpinner];

        NSString *title = notification.userInfo[@"title"];
        NSString *message = notification.userInfo[@"message"];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
}

@end
