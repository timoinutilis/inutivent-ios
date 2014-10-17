//
//  INUInviteViewController.h
//  Gromf
//
//  Created by Timo Kloss on 30/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/ABPeoplePickerNavigationController.h>

@class Bookmark;

@interface INUInviteViewController : UITableViewController <UITextViewDelegate, ABPeoplePickerNavigationControllerDelegate>

@property Bookmark *bookmark;

@end
