//
//  DwollaContact.h
//  DwollaOAuth
//
//  Created by Nick Schulze on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DwollaContact : NSObject
{
    NSString* userID;
    NSString* name;
    NSString* image;
    NSString* city;
    NSString* state;
    NSString* type;
}

/**
 * initializes a new DwollaContact with the given parameters
 *
 * @param userID: a string representation of the contact's userID
 * @param name: a string representation of the contact's name
 * @param image: a string representation of the contact's image
 * @param city: a string representation of the contact's city
 * @param state: a string representation of the contact's state
 * @param type: a string representation of the contact's type
 *
 * @return DwollaContact
 **/
-(id)initWithUserID:(NSString*)userID 
               name:(NSString*)name
              image:(NSString*)image 
               city:(NSString*)city 
              state:(NSString*)state 
               type:(NSString*)type;

/**
 * @return name
 **/
-(NSString*)getName;

/**
 * @return userID
 **/
-(NSString*)getUserID;

/**
 * @return image
 **/
-(NSString*)getImageURL;

/**
 * @return city
 **/
-(NSString*)getCity; 

/**
 * @return state
 **/
-(NSString*)getState;

/**
 * @return type
 **/
-(NSString*)getType;

@end
