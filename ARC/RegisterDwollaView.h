//
//  RegisterDwollaView.h
//  ARC
//
//  Created by Nick Wroblewski on 6/28/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DwollaOAuth2Client.h"
#import "IDwollaMessages.h"
@interface RegisterDwollaView : UIViewController  <IDwollaMessages>

@property BOOL fromRegister;
@property BOOL fromSettings;
@property BOOL fromInvoice;
@property BOOL fromSplitCheck;
@property BOOL fromMain;

//Dwolla
-(void)successfulLogin;
-(void)failedLogin:(NSArray*)errors;

@end
