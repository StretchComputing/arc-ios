//
//  DwollaFundingSource.h
//  DwollaOAuth
//
//  Created by Nick Schulze on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DwollaFundingSource : NSObject
{
    NSString* sourceID;
    NSString* name;
    NSString* type;
    BOOL verified;
}

/**
 * initializes a new DwollaFundingSource with the given parameters
 *
 * @param sourceID: a string representation of the funding source's userID
 * @param name: a string representation of the funding source's name
 * @param type: a string representation of the funding source's type
 * @param verified: a string representation of the funding source's current status
 *
 * @return DwollaFundingSource
 **/
-(id)initWithSourceID:(NSString*)sourceID 
                 name:(NSString*)name 
                 type:(NSString*)type 
             verified:(NSString*)verified;

/**
 * @return sourceID
 **/
-(NSString*)getSourceID;

/**
 * @return name
 **/
-(NSString*)getName;

/**
 * @return type
 **/
-(NSString*)getType;

/**
 * @return verified
 **/
-(BOOL)isVerified;

@end
