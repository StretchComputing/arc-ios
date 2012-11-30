//
//  NoPaymentSourcesViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 11/29/12.
//
//

#import <UIKit/UIKit.h>

@interface NoPaymentSourcesViewController : UIViewController


-(IBAction)creditCard;
-(IBAction)dwolla;

@property BOOL fromDwolla;
@property BOOL dwollaSuccess;
@property BOOL creditCardAdded;

@end
