//
//  INUInviteViewController.m
//  Gromf
//
//  Created by Timo Kloss on 30/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUInviteViewController.h"
#import "INUUtils.h"
#import "INUContact.h"
#import "INUDataManager.h"
#import "INUSpinnerView.h"
#import "INUConstants.h"
#import "Bookmark.h"
#import <AddressBook/AddressBook.h>

@interface INUInviteViewController ()

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextField *replyTextField;

@property INUSpinnerView *spinnerView;

@property (nonatomic) NSMutableArray *recipients;

@end

@implementation INUInviteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [INUUtils initNavigationBar:self.navigationController.navigationBar];
    
    _recipients = [NSMutableArray array];
    
    _messageTextView.layer.borderWidth = 1.0f;
    _messageTextView.layer.cornerRadius = 4.0f;
    _messageTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _messageTextView.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    
    _replyTextField.text = @"";
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
    {
        return _recipients.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0)
    {
        INUContact *contact = _recipients[indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:@"RecipientCell" forIndexPath:indexPath];
        if (contact.name)
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", contact.name, contact.mail];
        }
        else
        {
            cell.textLabel.text = contact.mail;
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"AddCell" forIndexPath:indexPath];
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        [self.view endEditing:YES];
        [self showContactsPicker];
    }
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// iOS 8 callback
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person
{
    NSString *name = [INUContact nameOfPerson:person];
    NSString *mail = [INUContact valueOfPerson:person property:kABPersonEmailProperty];
    
    [self addRecipientWithName:name mail:mail];
}

// iOS 8 callback
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    NSString *name = [INUContact nameOfPerson:person];
    NSString *mail = [INUContact valueOfPerson:person property:property identifier:identifier];
    
    [self addRecipientWithName:name mail:mail];
}


// iOS 6/7 callback
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    if ([INUContact countMailAddressesOfPerson:person] == 1)
    {
        [self peoplePickerNavigationController:peoplePicker didSelectPerson:person];

        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    return YES;
}

// iOS 6/7 callback
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    [self peoplePickerNavigationController:peoplePicker didSelectPerson:person property:property identifier:identifier];

    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

- (void)addRecipientWithName:(NSString *)name mail:(NSString *)mail
{
    INUContact *contact = [self findRecipientWithMail:mail];
    if (!contact)
    {
        contact = [[INUContact alloc] initWithName:name mail:mail];
        [_recipients addObject:contact];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(_recipients.count - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (INUContact *)findRecipientWithMail:(NSString *)mail
{
    mail = mail.lowercaseString;
    for (INUContact *contact in _recipients)
    {
        if ([contact.mail.lowercaseString isEqualToString:mail])
        {
            return contact;
        }
    }
    return nil;
}

#pragma mark - Actions

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [_recipients removeObjectAtIndex:indexPath.row];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (IBAction)onDone:(id)sender
{
    [self.view endEditing:YES];
    
    if (_recipients.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please add at least one recipient.", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        _spinnerView = [INUSpinnerView addNewSpinnerToView:self.navigationController.view transparent:YES];
        
        NSMutableArray *mails = [NSMutableArray array];
        for (INUContact *contact in _recipients)
        {
            [mails addObject:contact.fullMailAddress];
        }
        NSString *mailsString = [mails componentsJoinedByString:@","];
        
        NSString *appLocale = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        
        NSDictionary *params = @{@"event_id": _bookmark.eventId,
                                 @"user_id": _bookmark.userId,
                                 @"mails": mailsString,
                                 @"information": _messageTextView.text,
                                 @"reply_to": _replyTextField.text,
                                 @"locale": appLocale};

        [[INUDataManager sharedInstance] requestFromServer:INUServiceInvite params:params info:nil onError:^BOOL(ServiceError *error) {
            [self removeSpinner];
            return NO;
        }];
    }
}

- (IBAction)onCancel:(id)sender
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showContactsPicker
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.displayedProperties = @[[NSNumber numberWithInt:kABPersonEmailProperty]];
    picker.peoplePickerDelegate = self;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        picker.predicateForSelectionOfPerson = [NSPredicate predicateWithFormat:@"%K.@count == 1", ABPersonEmailAddressesProperty];
        picker.predicateForSelectionOfProperty = [NSPredicate predicateWithValue:YES];
    }
    
    [INUUtils initNavigationBar:picker.navigationBar];
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)receivedNotification:(NSNotification *)notification
{
    if (notification.name == INUInvitedNotification)
    {
        NSDictionary *data = notification.userInfo;
        NSArray *failedMails = data[@"failed"];
        if (failedMails.count > 0)
        {
            [self removeSpinner];
            
            [_recipients removeAllObjects];
            for (NSString *mail in failedMails)
            {
                INUContact *contact = [[INUContact alloc] initWithFullMailAddress:mail];
                [_recipients addObject:contact];
            }
            [self.tableView reloadData];
            
            int numSent = [data[@"num_sent"] intValue];
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%d invitation(s) sent successfully. You can correct now the other addresses and try again.", nil), numSent];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Some Invitations Failed", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

@end
