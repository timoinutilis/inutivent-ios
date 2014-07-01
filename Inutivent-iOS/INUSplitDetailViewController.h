//
//  INUSplitDetailViewController.h
//  Inutivent-iOS
//
//  Created by Timo Kloss on 30/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Bookmark;

@interface INUSplitDetailViewController : UINavigationController <UISplitViewControllerDelegate>

- (void)showEvent:(Bookmark *)bookmark;
- (void)showWelcome;
- (void)showAbout;

@end
