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

@interface INUEditTableViewController ()

@property (weak, nonatomic) IBOutlet INUInputTableViewCell *titleCell;
@property (weak, nonatomic) IBOutlet INUDateTableViewCell *whenCell;
@property (weak, nonatomic) IBOutlet INUTextTableViewCell *detailsCell;
@property (weak, nonatomic) IBOutlet INUInputTableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet INUInputTableViewCell *mailCell;

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
    _detailsCell.parentTableView = self.tableView;
    _detailsCell.textView.font = [UIFont systemFontOfSize:18];
    _nameCell.textField.placeholder = @"Enter your name";
    _mailCell.textField.placeholder = @"Enter your e-mail address";
    _mailCell.textField.keyboardType = UIKeyboardTypeEmailAddress;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
