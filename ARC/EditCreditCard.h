//
//  EditCreditCard.h
//  ARC
//
//  Created by Nick Wroblewski on 7/8/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditCreditCard : UITableViewController


@property (nonatomic, strong) NSString *creditCardNumber;
@property (nonatomic, strong) NSString *creditCardSecurityCode;
@property (nonatomic, strong) NSString *creditCardExpiration;
@property (nonatomic, strong) NSString *creditCardSample;
- (IBAction)deleteCardAction;
@property (weak, nonatomic) IBOutlet UIButton *deleteCardButton;

@end
