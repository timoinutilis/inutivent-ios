//
//  ServiceError.h
//  Gromf
//
//  Created by Timo Kloss on 30/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceError : NSObject

@property (readonly) NSString *errorId;
@property (readonly) NSString *error;
@property (readonly) NSString *title;
@property (readonly) NSString *message;

- (id)initWithErrorId:(NSString *)errorId error:(NSString *)error;

@end
