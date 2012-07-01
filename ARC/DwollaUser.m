//
//  DwollaUser.m
//  DwollaOAuth
//
//  Created by Nick Schulze on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DwollaUser.h"

@implementation DwollaUser

-(id)initWithUserID:(NSString*)_userID name:(NSString*)_name city:(NSString*)_city state:(NSString*)_state 
           latitude:(NSString*)_latitude longitude:(NSString*)_longitude type:(NSString*)_type
{
    if (self) 
    {
        userID = _userID;
        name = _name;
        city = _city;
        state = _state;
        latitude = _latitude;
        longitude = _longitude;
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

-(NSString*)getCity
{
    return city;
}

-(NSString*)getState
{
    return state;
}

-(NSString*)getLongitude
{
    return longitude;
}

-(NSString*)getLatitude
{
    return latitude;
}

-(NSString*)getType
{
    return type;
}

@end
