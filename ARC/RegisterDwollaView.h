//
//  RegisterDwollaView.h
//  ARC
//
//  Created by Nick Wroblewski on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DwollaOAuth2Client.h"
#import "IDwollaMessages.h"
@interface RegisterDwollaView : UIViewController  <IDwollaMessages>


//Dwolla
-(void)successfulLogin;

-(void)failedLogin:(NSArray*)errors;

@end
