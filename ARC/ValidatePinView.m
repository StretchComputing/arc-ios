//
//  ValidatePinView.m
//  ARC
//
//  Created by Nick Wroblewski on 9/24/12.
//
//

#import "ValidatePinView.h"
#import "ArcAppDelegate.h"
#import "CorbelTitleLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "EditCreditCard.h"
#import "FBEncryptorAES.h"

@interface ValidatePinView ()

@end

@implementation ValidatePinView

-(void)viewDidAppear:(BOOL)animated{
    
    ArcAppDelegate *mainDelegate = [[UIApplication sharedApplication] delegate];
    if ([mainDelegate.logout isEqualToString:@"true"]) {
        [self.navigationController dismissModalViewControllerAnimated:NO];
    }
}

-(void)viewDidLoad{
    
    self.numAttempts = 0;
    self.initialPin = @"";
    self.confirmPin = @"";
    
    
    CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Card Security"];
    self.navigationItem.titleView = navLabel;
    
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
    
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    self.view.backgroundColor = [UIColor clearColor];
    //UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
    double x = 1.0;
    UIColor *myColor = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];
    
    
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    [self.navigationController.navigationItem setHidesBackButton:YES];
    
    [self.navigationItem setHidesBackButton:YES];
    
}

-(void)viewWillAppear:(BOOL)animated{
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
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card Locked" message:@"You have entered the PIN incorrectly too many times.  If you have forgotten your PIN, please delete the card and re enter it." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        [alert show];
                        [self cancel];
                    }
                    self.checkNumFour.text = @"";
                    self.checkNumThree.text = @"";
                    self.checkNumTwo.text = @"";
                    self.checkNumOne.text = @"";
                    self.hiddenText.text = @"";
                    
                    self.descriptionText.text = @"*Incorrect PIN, try again.";
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

-(void)runSuccess:(NSString *)ccNumber :(NSString *)securityCode{
    
 
    NSArray *views = [self.navigationController viewControllers];
    EditCreditCard *tmp = [views objectAtIndex:[views count] - 2];
    tmp.cancelAuth = NO;
    tmp.didAuth = YES;
    tmp.displayNumber = ccNumber;
    tmp.displaySecurityCode = securityCode;
    [self.navigationController popToViewController:tmp animated:NO];
    
}


-(void)goHome{

    
}


-(void)popNow{

    
}

-(void)cancel{
    
    NSArray *views = [self.navigationController viewControllers];
    EditCreditCard *tmp = [views objectAtIndex:[views count] - 2];
    tmp.cancelAuth = YES;
    [self.navigationController popToViewController:tmp animated:NO];
}

@end