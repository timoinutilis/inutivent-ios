//
//  INUPostsTableViewController.h
//  Inutivent-iOS
//
//  Created by Timo Kloss on 11/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;
@class Bookmark;

@interface INUPostsTableViewController : UITableViewController

@property Event *event;
@property Bookmark *bookmark;

@end
