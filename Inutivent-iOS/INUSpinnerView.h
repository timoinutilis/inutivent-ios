//
//  INUSpinnerView.h
//  Inutivent-iOS
//
//  Created by Timo Kloss on 18/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INUSpinnerView : UIView

+ (INUSpinnerView *)addNewSpinnerToView:(UIView *)superView;

- (void)showErrorWithTitle:(NSString *)title message:(NSString *)message;

@end
