//
//  ServiceError.m
//  Gromf
//
//  Created by Timo Kloss on 30/07/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "ServiceError.h"

@implementation ServiceError

- (id)initWithErrorId:(NSString *)errorId error:(NSString *)error
{
    if (self = [super init])
    {
        _errorId = errorId;
        _error = error;
        
        if ([errorId isEqualToString:@"not_found"])
        {
            _title = NSLocalizedString(@"Event Doesn't Exist Anymore", nil);
            _message = NSLocalizedString(@"Maybe the host deleted it or it was too old already.", nil);
        }
        else if ([errorId isEqualToString:@"failed_connection"])
        {
            _title = NSLocalizedString(@"Couldn't Connect to Internet", nil);
            _message = NSLocalizedString(@"Please check if your device is connected to any network.", nil);
        }
        else
        {
            _title = NSLocalizedString(@"Something Went Wrong", nil);
            _message = error;
        }
    }
    return self;
}

@end
