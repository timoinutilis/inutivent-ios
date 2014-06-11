//
//  INUListSection.h
//  Inutivent-iOS
//
//  Created by Timo Kloss on 10/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INUListSection : NSObject

@property NSString *title;
@property NSMutableArray *array;

- (id)initWithTitle:(NSString *)title array:(NSMutableArray *)array;

@end
