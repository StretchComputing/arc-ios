//
//  Invoice.h
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Invoice : NSObject

@property int invoiceId, merchantId, customerId;
@property (strong, nonatomic) NSString *status, *number, *posi, *dateCreated;
@property double baseAmount, serviceCharge, tax, discount, additionalCharge;
@property (strong, nonatomic) NSArray *tags, *items;
@end
