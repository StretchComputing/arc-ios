//
//  InvoiceDetail.h
//  ArcMobile
//
//  Created by Nick Wroblewski on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvoiceDetail : UIViewController

@property (nonatomic, strong) NSString *invoiceId;
@property (nonatomic, strong) NSString *merchantId;
@property (nonatomic, strong) NSString *totalCost;

@property (nonatomic, strong) IBOutlet UILabel *displayCost;
@property (nonatomic, strong) IBOutlet UITextField *tipField;
@property (nonatomic, strong) IBOutlet UILabel *totalPlusTip;
-(IBAction)submitPayment;

-(IBAction)endText;
@end
