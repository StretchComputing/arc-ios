//
//  DwollaContact.m
//  DwollaOAuth
//
//  Created by Nick Schulze on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DwollaContact.h"

@implementation DwollaContact

-(id)initWithUserID:(NSString*)_userID 
               name:(NSString*)_name
              image:(NSString*)_image 
               city:(NSString*)_city 
              state:(NSString*)_state 
               type:(NSString*)_type
{
    if (self) 
    {
        userID = _userID;
        name = _name;
        image = _image;
        city = _city;
        state = _state;
        type = _type;
    }
    return self;
}

-(NSString*)getName
{
    return name;
}

-(NSString*)getUserID
{
    return userID;
}

-(NSString*)getImageURL
{
    return image;
}

-(NSString*)getCity
{
    return city;
}

-(NSString*)getState
{
    return state;
}

-(NSString*)getType
{
    return type;
}

@end
