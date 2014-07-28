//
//  INUTextFieldTableViewCell.m
//  Gromf
//
//  Created by Timo Kloss on 24/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUInputTableViewCell.h"
#import "INUUtils.h"

@interface INUInputTableViewCell ()

@property UITextField *textField;

@end

@implementation INUInputTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat padding = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? 15 : 10;
    
    CGRect contentFrame = self.contentView.frame;
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(contentFrame.origin.x + padding, contentFrame.origin.y, contentFrame.size.width - 2 * padding, contentFrame.size.height)];
    _textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.delegate = self;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.contentView addSubview:_textField];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected)
    {
        [_textField becomeFirstResponder];
    }
    else
    {
        [_textField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_textField resignFirstResponder];
    return YES;
}

@end
