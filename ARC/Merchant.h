//
//  Merchant.h
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Merchant : NSObject

@property (nonatomic, strong) NSString *name, *email, *ein, *address, *city, *state, *zipCode, *password, *dateCreated, *lastUpdated, *invoiceExpirationUnit, *paymentsAccepted;

@property int merchantId, typeId, invoiceExpiration, invoiceLength;

@property BOOL acceptTerms;

@property double latitude, longitude;

@end
