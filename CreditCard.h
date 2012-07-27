//
//  CreditCard.h
//  ARC
//
//  Created by Nick Wroblewski on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Customer;

@interface CreditCard : NSManagedObject

@property (nonatomic, retain) NSString * expiration;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * sample;
@property (nonatomic, retain) NSString * securityCode;
@property (nonatomic, retain) Customer *whoOwns;

@end
