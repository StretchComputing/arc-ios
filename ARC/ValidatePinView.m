//
//  ValidatePinView.m
//  ARC
//
//  Created by Nick Wroblewski on 9/24/12.
//
//

#import "ValidatePinView.h"
#import "ArcAppDelegate.h"
#import "SteelfishTitleLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "EditCreditCard.h"
#import "FBEncryptorAES.h"
#import <QuartzCore/QuartzCore.h>

@interface ValidatePinView ()

@end

@implementation ValidatePinView

-(void)viewDidAppear:(BOOL)animated{
    
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([mainDelegate.logout isEqualToString:@"true"]) {
        [self.navigationController dismissModalViewControllerAnimated:NO];
    }
}

-(void)viewDidLoad{
    
    self.forgotPinButton.text = @"Forgot PIN? Delete this card";
    self.forgotPinButton.hidden = YES;
    
    self.deleteCardButton.hidden = YES;
    
    self.numAttempts = 0;
    self.initialPin = @"";
    self.confirmPin = @"";
    
    
   // SteelfishTitleLabel *navLabel = [[SteelfishTitleLabel alloc] initWithText:@"Card Security"];
    //self.navigationItem.titleView = navLabel;
    
    self.isFirstPin = YES;
    
    self.checkNumOne.delegate = self;
    self.checkNumTwo.delegate = self;
    self.checkNumThree.delegate = self;
    self.checkNumFour.delegate = self;
    
    self.hiddenText = [[UITextField alloc] init];
    self.hiddenText.keyboardType = UIKeyboardTypeNumberPad;
    self.hiddenText.delegate = self;
    self.hiddenText.text = @"";
    [self.view addSubview:self.hiddenText];
    
    self.checkNumOne.text = @"";
    self.checkNumTwo.text = @"";
    self.checkNumThree.text = @"";
    self.checkNumFour.text = @"";
    
    self.checkNumOne.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
    self.checkNumTwo.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
    self.checkNumThree.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
    self.checkNumFour.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
    
    

    
    [self.navigationController.navigationItem setHidesBackButton:YES];
    
    [self.navigationItem setHidesBackButton:YES];
    
    self.navBackView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    self.navBackView1.backgroundColor = [UIColor blackColor];
    [self.navigationController.navigationBar addSubview:self.navBackView1];
    
    
    
    self.navBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    self.navBackView .backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
    self.navBackView.backgroundColor = dutchTopNavColor;
    
    [self.navigationController.navigationBar addSubview:self.navBackView ];
    
    
    self.navLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
   // self.navLineView.layer.shadowOffset = CGSizeMake(0, 1);
   // self.navLineView.layer.shadowRadius = 1;
  //  self.navLineView.layer.shadowOpacity = 0.2;
    self.navLineView.backgroundColor = dutchTopLineColor;
    [self.navigationController.navigationBar addSubview:self.navLineView];
    
    self.navButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navButton setImage:[UIImage imageNamed:@"backarrow.png"] forState:UIControlStateNormal];
    self.navButton.frame = CGRectMake(7, 7, 30, 30);
    [self.navButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.navButton];
    
    self.navLabel = [[SteelfishBoldLabel alloc] initWithFrame:CGRectMake(0, 6, 320, 32) andSize:20];
    self.navLabel.text = @"Card Security";
    self.navLabel.textAlignment = UITextAlignmentCenter;
    [self.navigationController.navigationBar addSubview:self.navLabel];
    
    
    UIImageView *imageBackView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 560)];
    imageBackView.image = [UIImage imageNamed:@"newBackground.png"];
    
    [self.view insertSubview:imageBackView atIndex:0];
    
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)customerDeactivated{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.logout = @"true";
    [self.navigationController dismissModalViewControllerAnimated:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];
    
    [self.hiddenText becomeFirstResponder];
}


-(void)setValues:(NSString *)newString{
    
    if ([newString length] < 5) {
        
        @try {
            self.checkNumOne.text = [newString substringWithRange:NSMakeRange(0, 1)];
        }
        @catch (NSException *exception) {
            self.checkNumOne.text = @"";
        }
        
        @try {
            self.checkNumTwo.text = [newString substringWithRange:NSMakeRange(1, 1)];
        }
        @catch (NSException *exception) {
            self.checkNumTwo.text = @"";
        }
        
        @try {
            self.checkNumThree.text = [newString substringWithRange:NSMakeRange(2, 1)];
        }
        @catch (NSException *exception) {
            self.checkNumThree.text = @"";
        }
        
        @try {
            self.checkNumFour.text = [newString substringWithRange:NSMakeRange(3, 1)];
        }
        @catch (NSException *exception) {
            self.checkNumFour.text = @"";
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSUInteger newLength = [self.hiddenText.text length] + [string length] - range.length;
    
    @try {
        if (newLength > 4) {
            return FALSE;
        }else{
            [self setValues:[self.hiddenText.text stringByReplacingCharactersInRange:range withString:string]];
            
            if (newLength == 4) {
               
                self.initialPin = [self.hiddenText.text stringByReplacingCharactersInRange:range withString:string];
                
                
                NSString *ccNumber = [FBEncryptorAES decryptBase64String:self.cardNumber keyString:self.initialPin];
                
                NSString *ccSecurityCode = [FBEncryptorAES decryptBase64String:self.securityCode keyString:self.initialPin];
                
                if (([ccNumber length] > 0) && ([ccSecurityCode length] > 0)) {
                    
                    [self runSuccess:ccNumber :ccSecurityCode];
                }else{
                    self.numAttempts++;
                    
                    if (self.numAttempts > 5) {
                      
                        [self cancelLock];
                    }
                    self.checkNumFour.text = @"";
                    self.checkNumThree.text = @"";
                    self.checkNumTwo.text = @"";
                    self.checkNumOne.text = @"";
                    self.hiddenText.text = @"";
                    
                    self.descriptionText.text = @"*Incorrect PIN, try again.";
                    self.forgotPinButton.hidden = NO;
                    self.descriptionText.textColor = [UIColor redColor];
                    self.descriptionText.textAlignment = UITextAlignmentCenter;
                }

                return FALSE;
            }
            return TRUE;
        }
    }
    @catch (NSException *e) {
        //[rSkybox sendClientLog:@"CreditCardpayment.testField" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

  
}

-(void)runSuccess:(NSString *)ccNumber :(NSString *)securityCode{
    
    [self.navBackView1 removeFromSuperview];
    [self.navBackView removeFromSuperview];
    [self.navLabel removeFromSuperview];
    [self.navLineView removeFromSuperview];
    [self.navButton removeFromSuperview];

    
     NSArray *views = [self.navigationController viewControllers];
    EditCreditCard *tmp = [views objectAtIndex:[views count] - 2];
    tmp.cancelAuth = NO;
    tmp.didAuth = YES;
    tmp.displayNumber = ccNumber;
    tmp.displaySecurityCode = securityCode;
    tmp.oldPin = self.initialPin;
    [self.navigationController popToViewController:tmp animated:NO];
    
}


-(void)goHome{

    
}


-(void)popNow{

    
}

-(void)cancelLock{
    
    NSArray *views = [self.navigationController viewControllers];
    EditCreditCard *tmp = [views objectAtIndex:[views count] - 2];
    tmp.cancelAuthLock = YES;
    
    [self.navigationController popToViewController:tmp animated:NO];
}
-(void)cancel{
    
    NSArray *views = [self.navigationController viewControllers];
    EditCreditCard *tmp = [views objectAtIndex:[views count] - 2];
    tmp.cancelAuth = YES;
        
    [self.navigationController popToViewController:tmp animated:NO];
}

-(void)deleteCardAction{
    
    NSArray *views = [self.navigationController viewControllers];
    EditCreditCard *tmp = [views objectAtIndex:[views count] - 2];
    tmp.deleteCardNow = YES;
    
    [self.navigationController popToViewController:tmp animated:NO];
    
}

- (void)viewDidUnload {
    [self setForgotPinButton:nil];
    [super viewDidUnload];
}
@end