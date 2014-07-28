//
//  INUTextTableViewCell.h
//  Gromf
//
//  Created by Timo Kloss on 24/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INUTextTableViewCell : UITableViewCell <UITextViewDelegate>

@property (readonly) UITextView *textView;
@property UITableView *parentTableView;

- (CGFloat)requiredCellHeight;

@end
