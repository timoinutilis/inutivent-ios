//
//  INUAboutTableViewController.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 21/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUAboutTableViewController.h"
#import "INUConfig.h"

@interface INUAboutTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *developerURLLabel;
@property (weak, nonatomic) IBOutlet UILabel *developerMailLabel;

@end

@implementation INUAboutTableViewController

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
    
    self.versionLabel.text = [self appVersion];
    self.developerURLLabel.text = INUConfigDeveloperURL;
    self.developerMailLabel.text = INUConfigDeveloperMail;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            NSURL *url = [NSURL URLWithString:INUConfigiTunesURL];
            [[UIApplication sharedApplication] openURL:url];
        }
        else if (indexPath.row == 1)
        {
            NSURL *url = [NSURL URLWithString:INUConfigDeveloperURL];
            [[UIApplication sharedApplication] openURL:url];
        }
        else if (indexPath.row == 2)
        {
            [self sendMail];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (void)sendMail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        
        UIDevice *device = [UIDevice currentDevice];
        
        [mailViewController setToRecipients:@[INUConfigDeveloperMail]];
        [mailViewController setSubject:@"Gromf App"];
        [mailViewController setMessageBody:[NSString stringWithFormat:@"\n\n\n\n%@\n%@ %@\nApp %@", device.model, device.systemName, device.systemVersion, [self appVersion]] isHTML:NO];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Send Mail", nil)
                                                        message:NSLocalizedString(@"Probably Mail is not configured.", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
}

@end
