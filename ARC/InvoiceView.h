//
//  InvoiceView.h
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Invoice.h"

@interface InvoiceView : UIViewController

- (IBAction)payNow:(id)sender;
@property (strong, nonatomic) Invoice *myInvoice;
@end
