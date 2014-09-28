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
#import <AddressBook/AddressBook.h>

@interface INUInviteViewController ()

@property TITokenFieldView *tokenFieldView;
@property UITextView *messageView;
@property CGFloat keyboardHeight;
@property INUContactManager *contactManager;

@end

@implementation INUInviteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

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
    [_tokenFieldView.tokenField setPromptText:@"To:"];
	[_tokenFieldView.tokenField setPlaceholder:@"Type a name"];
	
	UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
	[addButton addTarget:self action:@selector(showContactsPicker:) forControlEvents:UIControlEventTouchUpInside];
	[_tokenFieldView.tokenField setRightView:addButton];
    [_tokenFieldView.tokenField setRightViewMode:UITextFieldViewModeAlways];
	
	_messageView = [[UITextView alloc] initWithFrame:_tokenFieldView.contentView.bounds];
	[_messageView setScrollEnabled:NO];
	[_messageView setAutoresizingMask:UIViewAutoresizingNone];
	[_messageView setDelegate:self];
	[_messageView setFont:[UIFont systemFontOfSize:15]];
	[_messageView setText:@"Some message. The whole view resizes as you type, not just the text view."];
	[_tokenFieldView.contentView addSubview:_messageView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
    [_contactManager updateContacts:^{
        [_tokenFieldView setSourceArray:_contactManager.contacts];
    }];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    if ([INUContactManager countMailAddressesOfPerson:person] == 1)
    {
        NSString *name = [INUContactManager nameOfPerson:person];
        NSString *mail = [INUContactManager valueOfPerson:person property:kABPersonEmailProperty];
        
        [self addTokenForName:name mail:mail];

        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    NSString *name = [INUContactManager nameOfPerson:person];
    NSString *mail = [INUContactManager valueOfPerson:person property:property identifier:identifier];

    [self addTokenForName:name mail:mail];

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
	CGFloat oldHeight = _tokenFieldView.frame.size.height - _tokenFieldView.tokenField.frame.size.height;
	CGFloat newHeight = textView.contentSize.height + textView.font.lineHeight;
	
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
}


#pragma mark - Actions

- (IBAction)onDone:(id)sender
{
    NSArray *tokens = _tokenFieldView.tokenField.tokenObjects;
    for (int i = 0; i < [tokens count]; i++)
    {
        id token = tokens[i];
        if ([token isKindOfClass:[INUContact class]])
        {
            NSLog(@"contact: %@", ((INUContact *)token).mail);
        }
        else
        {
            NSLog(@"text: %@", token);
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    [INUUtils initNavigationBar:picker.navigationBar];
    
    [self presentViewController:picker animated:YES completion:nil];
}

@end
