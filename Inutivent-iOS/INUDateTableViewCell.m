//
//  INUDateTableViewCell.m
//  Gromf
//
//  Created by Timo Kloss on 22/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUDateTableViewCell.h"
#import "INUUtils.h"

@interface INUDateTableViewCell ()

@property UITextField *textField;
@property UIDatePicker *datePicker;
@property UIToolbar *toolBar;

@end

@implementation INUDateTableViewCell

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
    _textField.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_textField];
    
    _datePicker = [[UIDatePicker alloc] init];
    [_datePicker addTarget:self action:@selector(onDateChanged:) forControlEvents:UIControlEventValueChanged];
    
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
    _toolBar.barStyle = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? UIBarStyleDefault : UIBarStyleBlack;
    _toolBar.translucent = YES;
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *okButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onButtonDone)];
    [_toolBar setItems:@[space, okButton]];
    
    _textField.inputView = _datePicker;
    _textField.inputAccessoryView = _toolBar;
    
    [self updateText];
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

- (void)onDateChanged:(id)sender
{
    [self updateText];
}
     
- (void)onButtonDone
{
    [_textField resignFirstResponder];
}

- (void)updateText
{
    _textField.text = [NSDateFormatter localizedStringFromDate:_datePicker.date dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSDate *)currentDate
{
    return _datePicker.date;
}

- (void)setCurrentDate:(NSDate *)date
{
    [_datePicker setDate:date];
    if (_textField)
    {
        [self updateText];
    }
}

@end
