//
//  INUTextFieldTableViewCell.h
//  Gromf
//
//  Created by Timo Kloss on 24/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INUInputTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (readonly) UITextField *textField;

@end
