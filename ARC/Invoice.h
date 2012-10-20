//
//  Invoice.h
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Invoice : NSObject

@property int invoiceId, merchantId, customerId;
@property (strong, nonatomic) NSString *status, *number, *posi, *dateCreated, *paymentsAccepted;
@property double rawBaseAmount, serviceCharge, tax, discount, additionalCharge, gratuity, basePaymentAmount;
@property (strong, nonatomic) NSArray *tags, *items, *payments;

-(double)baseAmount;
-(double)amountDue;
-(double)amountDueForSplit;
-(double)amountDuePlusGratuity;
-(double)calculateAmountPaid;

-(void)setGratuityByAmount:(double)tipAmount;

-(void)setGratuityByPercentage:(double)tipPercent;


//For metrics
@property (nonatomic, strong) NSString *splitType, *splitPercent, *tipEntry;



@end
