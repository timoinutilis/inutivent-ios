//
//  INUTextTableViewCell.m
//  Gromf
//
//  Created by Timo Kloss on 24/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "INUTextTableViewCell.h"
#import "INUUtils.h"

@interface INUTextTableViewCell ()

@property UITextView *textView;
@property UIToolbar *toolBar;

@property CGFloat cellHeight;
@property CGFloat lastTextViewHeight;
@property CGFloat currentTableWidth;
@property CGFloat paddingHorizontal;
@property CGFloat paddingVertical;

@end

@implementation INUTextTableViewCell

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

    _lastTextViewHeight = 0;
    _currentTableWidth = 0;
    _cellHeight = 1;
    
    _textView = [[UITextView alloc] init];
    _textView.scrollEnabled = NO;
    _textView.delegate = self;
    _textView.backgroundColor = self.backgroundColor;
    [self.contentView addSubview:_textView];
    
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
    _toolBar.barStyle = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? UIBarStyleDefault : UIBarStyleBlack;
    _toolBar.translucent = YES;
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *okButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onButtonDone)];
    [_toolBar setItems:@[space, okButton]];
    
    _textView.inputAccessoryView = _toolBar;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        _paddingHorizontal = 15 - _textView.textContainer.lineFragmentPadding - _textView.textContainerInset.left;
    }
    else
    {
        _paddingHorizontal = 2;
    }
    _paddingVertical = 3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected)
    {
        [_textView becomeFirstResponder];
    }
    else
    {
        [_textView resignFirstResponder];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect contentFrame = self.contentView.frame;
    [_textView setFrame:CGRectMake(_paddingHorizontal, _paddingVertical, contentFrame.size.width - 2 * _paddingHorizontal, _textView.frame.size.height)];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateSizeWithTableUpdate:YES];
}

- (void)updateSizeWithTableUpdate:(BOOL)tableUpdate
{
    CGFloat width = _currentTableWidth - 2 * _paddingHorizontal;
    CGSize textViewSize = [_textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    
    if (textViewSize.height != _lastTextViewHeight)
    {
        [_textView setFrame:CGRectMake(_paddingHorizontal, _paddingVertical, _currentTableWidth - 2 * _paddingHorizontal, textViewSize.height)];
        _lastTextViewHeight = textViewSize.height;

        _cellHeight = textViewSize.height + 2 * _paddingVertical + 1; // 1 for separator line
        if (_textView.editable)
        {
            _cellHeight += _textView.font.lineHeight; // room for next line
        }
        
        if (tableUpdate && _parentTableView)
        {
            // update cell heights
            [_parentTableView beginUpdates];
            [_parentTableView endUpdates];
        }
    }
    
}

- (CGFloat)requiredCellHeightForWidth:(CGFloat)width
{
    width -= self.contentView.frame.origin.x * 2;
    if (width != _currentTableWidth)
    {
        _currentTableWidth = width;
        [self updateSizeWithTableUpdate:NO];
    }
    return _cellHeight;
}

- (void)setText:(NSString *)text
{
    self.textView.text = text;
    _currentTableWidth = 0;
}

- (void)setAttributedText:(NSAttributedString *)text
{
    self.textView.attributedText = text;
    _currentTableWidth = 0;
}

- (void)onButtonDone
{
    [_textView resignFirstResponder];
}

@end
