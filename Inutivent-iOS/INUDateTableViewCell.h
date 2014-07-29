//
//  INUDateTableViewCell.h
//  Gromf
//
//  Created by Timo Kloss on 22/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INUDateTableViewCell : UITableViewCell

@property (readonly) UIDatePicker *datePicker;

- (NSDate *)currentDate;
- (void)setCurrentDate:(NSDate *)date;

@end
