//
//  INUAboutTableViewController.m
//  Inutivent-iOS
//
//  Created by Timo Kloss on 21/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUAboutTableViewController.h"
#import "INUConfig.h"
#import "INUUtils.h"

@interface INUAboutTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *moreInfoURLLabel;
@property (weak, nonatomic) IBOutlet UILabel *developerURLLabel;
@property (weak, nonatomic) IBOutlet UILabel *developerMailLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation INUAboutTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [INUUtils initBackground:self.tableView];
    
    // correct table header size
    CGRect newFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 3 / 8);
    self.tableView.tableHeaderView.frame = newFrame;
    
    self.versionLabel.text = [self appVersion];
    
    self.moreInfoURLLabel.text = INUConfigSiteURL;
    self.developerURLLabel.text = INUConfigDeveloperURL;
    self.developerMailLabel.text = INUConfigDeveloperMail;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            NSURL *url = [NSURL URLWithString:INUConfigSiteURL];
            [[UIApplication sharedApplication] openURL:url];
        }
        else if (indexPath.row == 1)
        {
            NSURL *url = [NSURL URLWithString:INUConfigiTunesURL];
            [[UIApplication sharedApplication] openURL:url];
        }
        else if (indexPath.row == 2)
        {
            NSURL *url = [NSURL URLWithString:INUConfigDeveloperURL];
            [[UIApplication sharedApplication] openURL:url];
        }
        else if (indexPath.row == 3)
        {
            [self sendMail];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

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
        
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            mailViewController.navigationBar.tintColor = [INUUtils mainColor];
        }
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
