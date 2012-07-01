//
//  DwollaTransactions.m
//  DwollaOAuth
//
//  Created by Nick Schulze on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DwollaTransactions.h"

@implementation DwollaTransactions

-(id)initWithSuccess:(BOOL)_success 
        transactions:(NSMutableArray*)_transactions
{
    if (self)
    {
        success = _success;
        transactions = _transactions;
    }
    return self;
}

-(NSMutableArray*)getAll
{
    return transactions;
}

-(BOOL)getSuccess
{
    return success;
}

-(int)count
{
    return [transactions count];
}

-(DwollaTransaction*)getObjectAtIndex:(int)index
{
    return [transactions objectAtIndex:index];
}

@end
