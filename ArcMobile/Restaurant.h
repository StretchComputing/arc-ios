//
//  Restaurant.h
//  ArcMobile
//
//  Created by Nick Wroblewski on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Restaurant : UIViewController

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) IBOutlet UITextField *invoiceNumber;

-(IBAction)submitAction;

@end
