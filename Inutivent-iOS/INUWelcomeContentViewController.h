//
//  INUWelcomeContentViewController.h
//  Inutivent-iOS
//
//  Created by Timo Kloss on 25/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int, INUWelcomeButtonType)
{
    INUWelcomeButtonTypeSkip,
    INUWelcomeButtonTypeStart,
    INUWelcomeButtonTypeNone
};

@interface INUWelcomeContentViewController : UIViewController

@property UIImage *image;
@property NSString *text;
@property NSString *bubbleText;
@property int pageIndex;
@property INUWelcomeButtonType buttonType;
@property UIImage *backgroundImage;

@end
