//
//  INUInviteViewController.h
//  Gromf
//
//  Created by Timo Kloss on 30/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/ABPeoplePickerNavigationController.h>
#import "TITokenField.h"

@class Bookmark;

@interface INUInviteViewController : UIViewController <TITokenFieldDelegate, UITextViewDelegate, ABPeoplePickerNavigationControllerDelegate>

@property Bookmark *bookmark;

@end
