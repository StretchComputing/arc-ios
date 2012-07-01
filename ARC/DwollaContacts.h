//
//  DwollaContacts.h
//  DwollaOAuth
//
//  Created by Nick Schulze on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DwollaContact.h"

@interface DwollaContacts : NSObject
{
    BOOL success;
    NSMutableArray* contacts;
}

/**
 * initializes a DwollaContacts object with the given parameters
 *
 * @param success: set to YES if the request was successful 
 * @param contacts: an array of type DwollaContact
 *
 * @return a DwollaContacts object
 **/
-(id)initWithSuccess:(BOOL)success 
            contacts:(NSMutableArray*)contacts;

/**
 * @return success
 **/
-(BOOL)getSuccess;

/**
 * @return contacts
 **/
-(NSMutableArray*)getAll;

/**
 * alphabetizes the contacts array
 *
 * @param direction: defaults to ascending order, will only be descending when declared @"DESC"
 *
 * @return contacts
 **/
-(NSMutableArray*)getAlphabetized:(NSString*)direction;

/**
 * @param index: the index of the object to be returned
 *
 * @return DwollaContact at the given index
 **/
-(DwollaContact*)getObjectAtIndex:(int)index;

/**
 * @return count of objects in contacts
 **/
-(int)count;

@end
