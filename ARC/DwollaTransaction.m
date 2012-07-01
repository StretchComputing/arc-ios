//
//  DwollaTransaction.m
//  DwollaOAuth
//
//  Created by Nick Schulze on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DwollaTransaction.h"

@implementation DwollaTransaction

-(id)initWithAmount:(NSString*)_amount
       clearingDate:(NSString*)_clearingDate
               date:(NSString*)_date
      destinationID:(NSString*)_destinationID 
    destinationName:(NSString*)_destinationName 
      transactionID:(NSString*)_transactionID 
              notes:(NSString*)_notes 
           sourceID:(NSString*)_sourceID
         sourceName:(NSString*)_sourceName 
             status:(NSString*)_status 
               type:(NSString*)_type 
           userType:(NSString*)_userType
{
    if (self) 
    {
        amount = _amount;
        clearingDate = _clearingDate;
        date = _date;
        destinationID = _destinationID;
        destinationName= _destinationName;
        transactionID = _transactionID;
        notes = _notes;
        sourceID = _sourceID;
        sourceName = _sourceName;
        status = _status;
        type = _type;
        userType = _userType;
    }
    return self;
}

-(NSString *)getAmount
{
    return amount;
}

-(NSString*)getTransactionID
{
    return transactionID;
}

-(NSString*)getDestinationID
{
    return destinationID;
}


-(NSString*)getClearingDate
{
    return clearingDate;
}

-(NSString*)getDate
{
    return date;
}

-(NSString*)getDestinationName
{
    return destinationName;
}

-(NSString*)getNotes
{
    return notes;
}

-(NSString*)getSourceID
{
    return sourceID;
}

-(NSString*)getSourceName
{
    return sourceName;
}

-(NSString*)getStatus
{
    return status;
}

-(NSString*)getType
{
    return type;
}

-(NSString*)getUserType
{
    return userType;
}

@end
