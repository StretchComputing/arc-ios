//
//  DwollaFundingSource.m
//  DwollaOAuth
//
//  Created by Nick Schulze on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DwollaFundingSource.h"

@implementation DwollaFundingSource

-(id)initWithSourceID:(NSString*)_sourceID 
                 name:(NSString*)_name 
                 type:(NSString*)_type 
             verified:(NSString*)_verified
{
    if (self) 
    {
        sourceID = _sourceID;
        name = _name;
        type = _type;
        if ([_verified isEqualToString:@"1"]) 
        {
            verified = YES;
        }
        else
        {
            verified = NO;
        }
    }
    return self;
}

-(NSString*)getSourceID
{
    return sourceID;
}

-(NSString*)getName
{
    return name;
}

-(NSString*)getType
{
    return type;
}

-(BOOL)isVerified
{
    return verified;
}

@end
