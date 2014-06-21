//
//  INUEventInfoTableViewController.h
//  Inutivent-iOS
//
//  Created by Timo Kloss on 04/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Bookmark;

@interface INUEventInfoTableViewController : UITableViewController <UIAlertViewDelegate>

@property Bookmark *bookmark;

@end
