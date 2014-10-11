//
//  INUInviteViewController.m
//  Gromf
//
//  Created by Timo Kloss on 30/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUInviteViewController.h"
#import "INUUtils.h"
#import "INUContactManager.h"
#import "INUContact.h"
#import "INUDataManager.h"
#import "INUSpinnerView.h"
#import "INUConstants.h"
#import "Bookmark.h"
#import <AddressBook/AddressBook.h>

@interface INUInviteViewController ()

@property TITokenFieldView *tokenFieldView;
@property UITextView *messageView;
@property UITextView *messagePlaceholderView;
@property CGFloat keyboardHeight;
@property INUContactManager *contactManager;
@property INUSpinnerView *spinnerView;

@end

@implementation INUInviteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [INUUtils initNavigationBar:self.navigationController.navigationBar];

    _contactManager = [[INUContactManager alloc] init];
    
	_tokenFieldView = [[TITokenFieldView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:_tokenFieldView];
	
	[_tokenFieldView.tokenField setDelegate:self];
	[_tokenFieldView setShouldSearchInBackground:NO];
	[_tokenFieldView setShouldSortResults:NO];
	[_tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldFrameDidChange:) forControlEvents:(UIControlEvents)TITokenFieldControlEventFrameDidChange];
	[_tokenFieldView.tokenField setTokenizingCharacters:[NSCharacterSet characterSetWithCharactersInString:@",;"]]; // Default is a comma
    [_tokenFieldView.tokenField setPromptText:NSLocalizedString(@"To:", nil)];
	[_tokenFieldView.tokenField setPlaceholder:NSLocalizedString(@"Type a name", nil)];
	
	UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
	[addButton addTarget:self action:@selector(showContactsPicker:) forControlEvents:UIControlEventTouchUpInside];
	[_tokenFieldView.tokenField setRightView:addButton];
    [_tokenFieldView.tokenField setRightViewMode:UITextFieldViewModeAlways];
	
	_messageView = [[UITextView alloc] initWithFrame:_tokenFieldView.contentView.bounds];
	[_messageView setScrollEnabled:NO];
	[_messageView setAutoresizingMask:UIViewAutoresizingNone];
	[_messageView setDelegate:self];
	[_messageView setFont:[UIFont systemFontOfSize:15]];
	[_tokenFieldView.contentView addSubview:_messageView];
    
    CGRect placeholderRect = _tokenFieldView.contentView.bounds;
    placeholderRect.size.height = 60;
    _messagePlaceholderView = [[UITextView alloc] initWithFrame:placeholderRect];
    _messagePlaceholderView.userInteractionEnabled = NO;
    _messagePlaceholderView.backgroundColor = [UIColor clearColor];
    _messagePlaceholderView.textColor = [UIColor lightGrayColor];
    _messagePlaceholderView.text = NSLocalizedString(@"Optional message. Will only be sent by e-mail and not saved.", nil);
    _messagePlaceholderView.font = [UIFont systemFontOfSize:15];
    [_tokenFieldView.contentView addSubview:_messagePlaceholderView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
    [_contactManager updateContacts:^{
        [_tokenFieldView setSourceArray:_contactManager.contacts];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:nil object:[INUDataManager sharedInstance]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_tokenFieldView becomeFirstResponder];
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

#pragma mark - TITokenFieldDelegate

- (NSString *)tokenField:(TITokenField *)tokenField displayStringForRepresentedObject:(id)object
{
    if ([object isKindOfClass:[INUContact class]])
    {
		return ((INUContact *)object).name;
	}

    return object;
}

- (NSString *)tokenField:(TITokenField *)tokenField searchResultStringForRepresentedObject:(id)object
{
    INUContact *contact = (INUContact *)object;
    return [NSString stringWithFormat:@"%@ (%@)", contact.name, contact.mail];
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
    NSString *name = [INUContactManager nameOfPerson:person];
    NSString *mail = [INUContactManager valueOfPerson:person property:kABPersonEmailProperty];
    
    [self addTokenForName:name mail:mail];
}

// iOS 8 callback
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    NSString *name = [INUContactManager nameOfPerson:person];
    NSString *mail = [INUContactManager valueOfPerson:person property:property identifier:identifier];
    
    [self addTokenForName:name mail:mail];
}


// iOS 6/7 callback
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    if ([INUContactManager countMailAddressesOfPerson:person] == 1)
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

- (void)addTokenForName:(NSString *)name mail:(NSString *)mail
{
    INUContact *contact = [_contactManager getContactByName:name mail:mail];
    [_tokenFieldView.tokenField addTokenWithTitle:name representedObject:contact];
}

#pragma mark - View Layout

- (void)keyboardWillShow:(NSNotification *)notification
{
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	_keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
	[self resizeViews];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	_keyboardHeight = 0;
	[self resizeViews];
}

- (void)resizeViews
{
	[_tokenFieldView setFrame:CGRectMake(_tokenFieldView.frame.origin.x, _tokenFieldView.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.height - _keyboardHeight)];
	[_messageView setFrame:_tokenFieldView.contentView.bounds];
}

- (void)tokenFieldFrameDidChange:(TITokenField *)tokenField
{
	[self textViewDidChange:_messageView];
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGSize textSize = [textView sizeThatFits:CGSizeMake([textView frame].size.width, FLT_MAX)];

	CGFloat oldHeight = _tokenFieldView.frame.size.height - _tokenFieldView.tokenField.frame.size.height;
	CGFloat newHeight = textSize.height + textView.font.lineHeight;
	
	CGRect newTextFrame = textView.frame;
	newTextFrame.size = textView.contentSize;
	newTextFrame.size.height = newHeight;
	
	CGRect newFrame = _tokenFieldView.contentView.frame;
	newFrame.size.height = newHeight;
	
	if (newHeight < oldHeight)
    {
		newTextFrame.size.height = oldHeight;
		newFrame.size.height = oldHeight;
	}
    
	[_tokenFieldView.contentView setFrame:newFrame];
	[textView setFrame:newTextFrame];
	[_tokenFieldView updateContentSize];
    
    _messagePlaceholderView.hidden = (textView.text.length > 0);
}


#pragma mark - Actions

- (IBAction)onDone:(id)sender
{
    [self.view endEditing:YES];
    
    NSArray *tokens = _tokenFieldView.tokenField.tokenObjects;
    
    if (tokens.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please add at least one recipient.", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        _spinnerView = [INUSpinnerView addNewSpinnerToView:self.navigationController.view transparent:YES];
        
        NSMutableArray *mails = [NSMutableArray array];
        for (int i = 0; i < [tokens count]; i++)
        {
            id token = tokens[i];
            if ([token isKindOfClass:[INUContact class]])
            {
                INUContact *contact = token;
                [mails addObject:[NSString stringWithFormat:@"%@ <%@>", contact.name, contact.mail]];
            }
            else
            {
                [mails addObject:(NSString*)token];
            }
        }
        
        NSString *appLocale = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        
        NSDictionary *params = @{@"event_id": _bookmark.eventId,
                                 @"user_id": _bookmark.userId,
                                 @"mails": [mails componentsJoinedByString:@","],
                                 @"information": _messageView.text,
                                 @"reply_to": @"",
                                 @"locale": appLocale};

        [[INUDataManager sharedInstance] requestFromServer:INUServiceInvite params:params info:nil onError:^BOOL(ServiceError *error) {
            [self removeSpinner];
            return NO;
        }];
    }
}

- (IBAction)onCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showContactsPicker:(id)sender
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
            
            [_tokenFieldView.tokenField removeAllTokens];
            _tokenFieldView.tokenField.text = [failedMails componentsJoinedByString:@","];
            [_tokenFieldView.tokenField tokenizeText];
            
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
