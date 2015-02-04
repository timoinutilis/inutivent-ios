//
//  INUPostTableViewCell.h
//  Inutivent-iOS
//
//  Created by Timo Kloss on 11/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Post;
@class Event;

@interface INUPostTableViewCell : UITableViewCell

- (void)setPost:(Post *)post event:(Event *)event;
- (CGFloat)heightForWidth:(CGFloat)width;

@end
