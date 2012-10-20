//
//  CreditCard.h
//  ARC
//
//  Created by Nick Wroblewski on 10/20/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Customer;

@interface CreditCard : NSManagedObject

@property (nonatomic, retain) NSString * expiration;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * sample;
@property (nonatomic, retain) NSString * securityCode;
@property (nonatomic, retain) NSString * cardType;
@property (nonatomic, retain) Customer *whoOwns;

@end
