//
//  Merchant.h
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Merchant : NSObject

@property (nonatomic, strong) NSString *name, *email, *ein, *address, *city, *state, *zipCode, *password, *dateCreated, *lastUpdated, *invoiceExpirationUnit;

@property int merchantId, typeId, invoiceExpiration;

@property BOOL acceptTerms;

@property double latitude, longitude;

@end
