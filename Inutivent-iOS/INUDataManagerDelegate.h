//
//  INUEventManagerDelegate.h
//  Inutivent-iOS
//
//  Created by Timo Kloss on 03/06/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol INUDataManagerDelegate <NSObject>

@optional
- (void)bookmarksChanged;
- (void)requestCompleteService:(NSString *)service data:(NSDictionary *)data;
- (void)requestErrorService:(NSString *)service error:(NSString *)error;

@end
