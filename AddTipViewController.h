//
//  AddTipViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 3/28/13.
//
//

#import <UIKit/UIKit.h>
#import "Invoice.h"
#import "LucidaBoldLabel.h"


@interface AddTipViewController : UIViewController


@property (strong, nonatomic) Invoice *myInvoice;

@property (nonatomic, strong) NSString *creditCardNumber;
@property (nonatomic, strong) NSString *creditCardSecurityCode;
@property (nonatomic, strong) NSString *creditCardExpiration;
@property (nonatomic, strong) NSString *creditCardSample;

@property double mySplitPercent;
@property (nonatomic, strong) NSArray *myItemsArray;

@property (nonatomic, strong) IBOutlet LucidaBoldLabel *myTotalLabel;

@end
