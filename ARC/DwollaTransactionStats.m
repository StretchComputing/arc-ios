//
//  DwollaTransactionStats.m
//  DwollaOAuth
//
//  Created by Nick Schulze on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DwollaTransactionStats.h"

@implementation DwollaTransactionStats

-(id)initWithSuccess:(BOOL)_success 
               count:(NSString*)_count 
               total:(NSString*)_total
{
    if (self) 
    {
        success = _success;
        count = _count;
        total = _total;
    }
    return self;
}

-(BOOL)wasSuccessful
{
    return success;
}

-(NSString*)getCount
{
    return count;
}

-(NSString*)getTotal
{
    return total;
}

@end
