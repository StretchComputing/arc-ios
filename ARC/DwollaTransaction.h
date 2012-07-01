//
//  DwollaTransaction.h
//  DwollaOAuth
//
//  Created by Nick Schulze on 6/7/12.
//  Copyright (c) 2012 __MyCompanyclearingDate__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DwollaTransaction : NSObject
{
    NSString* amount;
    NSString* clearingDate;
    NSString* date;
    NSString* destinationID;
    NSString* destinationName;
    NSString* transactionID;
    NSString* notes;
    NSString* sourceID;
    NSString* sourceName;
    NSString* status;
    NSString* type;
    NSString* userType;
}

/**
 * initializes a new DwollaTransaction with the given parameters
 *
 * @param amount: a string representation of the transaction's amount
 * @param clearingDate: a string representation of the transaction's clearingDate
 * @param date: a string representation of the transaction's date
 * @param destinationID: a string representation of the transaction's destinationID
 * @param destinationName: a string representation of the transaction's destinationName
 * @param transactionID: a string representation of the transaction's transactionID
 * @param notes: a string representation of the transaction's notes
 * @param sourceID: a string representation of the transaction's sourceID
 * @param sourceName: a string representation of the transaction's sourceName
 * @param status: a string representation of the transaction's status
 * @param type: a string representation of the transaction's type
 * @param userType: a string representation of the transaction's userType
 *
 * @return DwollaTransaction
 **/
-(id)initWithAmount:(NSString*)amount
       clearingDate:(NSString*)clearingDate
               date:(NSString*)date
      destinationID:(NSString*)destinationID 
    destinationName:(NSString*)destinationName 
      transactionID:(NSString*)transactionID 
              notes:(NSString*)notes 
           sourceID:(NSString*)sourceID
         sourceName:(NSString*)sourceName 
             status:(NSString*)status 
               type:(NSString*)type 
           userType:(NSString*)userType;

/**
 * @return amount
 **/
-(NSString*)getAmount;

/**
 * @return clearingDate
 **/
-(NSString*)getClearingDate;

/**
 * @return date
 **/
-(NSString*)getDate;

/**
 * @return destinationID
 **/
-(NSString*)getDestinationID;

/**
 * @return destinationName
 **/
-(NSString*)getDestinationName;

/**
 * @return transactionID
 **/
-(NSString*)getTransactionID;

/**
 * @return notes
 **/
-(NSString*)getNotes;

/**
 * @return sourceID
 **/
-(NSString*)getSourceID;

/**
 * @return sourceName
 **/
-(NSString*)getSourceName;

/**
 * @return status
 **/
-(NSString*)getStatus;

/**
 * @return type
 **/
-(NSString*)getType;

/**
 * @return userType
 **/
-(NSString*)getUserType;

@end
