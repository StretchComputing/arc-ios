//
//  Restaurant.m
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "Restaurant.h"
#import "InvoiceView.h"
#import "ArcClient.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"
#import "HomeNavigationController.h"

#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}



@interface Restaurant ()

@end

@implementation Restaurant




-(void)showHintOverlay{
    
    @try {
        [UIView animateWithDuration:1.0 animations:^{
            CGRect frame = self.hintOverlayView.frame;
            frame.origin.y += 100;
            self.hintOverlayView.frame = frame;
        }];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"Restaurant.showHintOverlay" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
}

-(void)hideHintOverlay{
    
    @try {
        [UIView animateWithDuration:1.0 animations:^{
            CGRect frame = self.hintOverlayView.frame;
            frame.origin.y -= 100;
            self.hintOverlayView.frame = frame;
        }];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"Resaurant.hideHintOverlay" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
}





-(void)viewDidAppear:(BOOL)animated{
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"didShowAlertRestaurant"] length] == 0) {
  /*
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"didShowAlertRestaurant"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.overlayTextView.layer.masksToBounds = YES;
        self.overlayTextView.layer.cornerRadius = 10.0;
        self.overlayTextView.layer.borderColor = [[UIColor blackColor] CGColor];
        self.overlayTextView.layer.borderWidth = 2.0;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.overlayTextView.bounds;
        self.overlayTextView.backgroundColor = [UIColor clearColor];
        double x = 1.4;
        UIColor *myColor = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
        [self.overlayTextView.layer insertSublayer:gradient atIndex:0];
        
        [self showHintOverlay];
        
        NSTimer *tmp = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideHintOverlay) userInfo:nil repeats:NO];
        
        if (tmp) {
            
        }
    */
    
    
     }

    //[self connectToPeers:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.getInvoiceArcClient cancelConnection];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)noPaymentSources{
    UIViewController *noPaymentController = [self.storyboard instantiateViewControllerWithIdentifier:@"noPayment"];
    [self.navigationController presentModalViewController:noPaymentController animated:YES];
    
}

-(void)customerDeactivated{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.logout = @"true";
    [self.navigationController dismissModalViewControllerAnimated:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    

    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"hasShownCheckHint"] length] == 0) {
        [self showInvoiceHint];
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"hasShownCheckHint"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invoiceComplete:) name:@"invoiceNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noPaymentSources) name:@"NoPaymentSourcesNotification" object:nil];
    
    @try {
        
        /*
        if (self.wentInvoice) {
            self.wentInvoice = NO;
            [self.checkNumFour becomeFirstResponder];
        }else{
            [self.checkNumOne becomeFirstResponder];
            
        }
         */
        [self.hiddenText becomeFirstResponder];
        
        self.serverData = [NSMutableData data];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)setValues:(NSString *)newString{

    
    if ([newString length] < 7) {
        
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
        
        @try {
            self.checkNumFive.text = [newString substringWithRange:NSMakeRange(4, 1)];
        }
        @catch (NSException *exception) {
            self.checkNumFive.text = @"";
        }
        
        @try {
            self.checkNumSix.text = [newString substringWithRange:NSMakeRange(5, 1)];
        }
        @catch (NSException *exception) {
            self.checkNumSix.text = @"";
        }
       
        
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
        
   // NSLog(@"NewString: %@", string);
    //NSLog(@"RangeLength: %d", range.length);
    //NSLog(@"RangeLoc: %d", range.location);
    
    
    NSUInteger newLength = [self.hiddenText.text length] + [string length] - range.length;
    
    @try {
        self.errorLabel.text = @"";
        
        if (newLength == 0) {
            [self.hideKeyboardView removeFromSuperview];
            self.hideKeyboardView = nil;
        }else{
            //[self showDoneButton];
        }
   
        if (newLength > 6) {
            return FALSE;
        }else{
            
            [self setValues:[self.hiddenText.text stringByReplacingCharactersInRange:range withString:string]];
            return TRUE;

        }
        /*
        if ([textField.text isEqualToString:@" "]) {
            
            if ([string isEqualToString:@""]) {
                
                [self performSelector:@selector(previousField) withObject:nil afterDelay:0.0];
                
            }else{
                textField.text = string;
                [self performSelector:@selector(nextField) withObject:nil afterDelay:0.0];
            }
        }else{
            
            if ([string isEqualToString:@""]) {
                textField.text = @" ";
            }
        }
        
        return FALSE;
         */
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.testField" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)previousField{

    @try {
        
        if ([self.checkNumSix isFirstResponder]) {
            [self.checkNumFive becomeFirstResponder];
            self.checkNumFive.text = @" ";
        }else if ([self.checkNumFive isFirstResponder]) {
            [self.checkNumFour becomeFirstResponder];
            self.checkNumFour.text = @" ";
        }if ([self.checkNumFour isFirstResponder]) {
            [self.checkNumThree becomeFirstResponder];
            self.checkNumThree.text = @" ";
        }else if ([self.checkNumThree isFirstResponder]){
            [self.checkNumTwo becomeFirstResponder];
            self.checkNumTwo.text = @" ";
            
        }else if ([self.checkNumTwo isFirstResponder]){
            [self.checkNumOne becomeFirstResponder];
            self.checkNumOne.text = @" ";
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.previousField" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)nextField{
    @try {
        
        if ([self.checkNumOne isFirstResponder]) {
            [self.checkNumTwo becomeFirstResponder];
        }else if ([self.checkNumTwo isFirstResponder]){
            [self.checkNumThree becomeFirstResponder];
        }else if ([self.checkNumThree isFirstResponder]){
            [self.checkNumFour becomeFirstResponder];
        }else if ([self.checkNumFour isFirstResponder]){
            [self.checkNumFive becomeFirstResponder];
        }else if ([self.checkNumFive isFirstResponder]){
            [self.checkNumSix becomeFirstResponder];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.nextField" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)loadLogoImage{
    
    ArcClient *tmp = [[ArcClient alloc] init];
    NSString *serverUrl = [tmp getCurrentUrl];
    
    
    NSString *logoImageUrl = [NSString stringWithFormat:@"%@Images/App/Logos/%@.jpg", serverUrl, self.merchantId];
    logoImageUrl = [logoImageUrl stringByReplacingOccurrencesOfString:@"/rest/v1" withString:@""];
    NSLog(@"LogoImageURL: %@", logoImageUrl);
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:logoImageUrl]];
        
        if ( data == nil ){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.logoImageView.image = [UIImage imageNamed:@"silverware.png"];

            
            });
            return;

        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIImage *logoImage = [UIImage imageWithData:data];
            
            if (logoImage) {
                self.logoImageView.image = logoImage;
                //self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
            }else{
                self.logoImageView.image = [UIImage imageNamed:@"silverware.png"];
            }
        });
    });
    
}

-(void)loadHelpImage{
    
    ArcClient *tmp = [[ArcClient alloc] init];
    NSString *serverUrl = [tmp getCurrentUrl];
    
    NSString *helpImageUrl = [NSString stringWithFormat:@"%@Images/App/Receipts/%@.jpg", serverUrl, self.merchantId];
    helpImageUrl = [helpImageUrl stringByReplacingOccurrencesOfString:@"/rest/v1" withString:@""];
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:helpImageUrl]];
        
        if ( data == nil ){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.checkHelpImageView.image = nil;
                self.notFoundHelpView.hidden = NO;
            });
                           
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIImage *helpImage = [UIImage imageWithData:data];
                
                if (helpImage) {
                    self.checkHelpImageView.image = helpImage;
                    //self.checkHelpImageView.contentMode = UIViewContentModeScaleAspectFit;
                    self.checkHelpImageView.hidden = NO;
                }else{
                    self.checkHelpImageView.image = nil;
                    self.notFoundHelpView.hidden = NO;
                    
                }
            });
        }
       
    });
    
}
- (void)viewDidLoad
{
    @try {
        
        @try {
            self.helpOverlay = [self.storyboard instantiateViewControllerWithIdentifier:@"checkHelpOverlay"];
            self.helpOverlay.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
            [self.view addSubview:self.helpOverlay.view];
            self.helpOverlay.view.alpha = 0.0;
        }
        @catch (NSException *exception) {
            
        }
        
        self.closeHelpButton.text = @"Done";
     
        self.closeHelpButton.borderColor = [UIColor darkGrayColor];
        self.closeHelpButton.borderWidth = 0.5;
        self.closeHelpButton.cornerRadius = 3.0;
        
        self.submitButton.text = @"Submit";

        self.submitButton.textColor = [UIColor whiteColor];
        self.submitButton.textShadowColor = [UIColor darkGrayColor];
        self.submitButton.tintColor = dutchDarkBlueColor;
        self.submitButton.borderColor = [UIColor darkGrayColor];
        self.submitButton.borderWidth = 0.5;
        self.submitButton.cornerRadius = 3.0;
        
        self.helpBackView.hidden = YES;
        self.closeHelpButton.hidden = YES;

        [self loadLogoImage];
        [self loadHelpImage];
   
        self.logoImageView.layer.borderWidth = 1.0;
        self.logoImageView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        self.logoImageView.layer.cornerRadius = 3.0;
        self.logoImageView.layer.masksToBounds = YES;
        
        
       
        //self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
       // self.topLineView.layer.shadowRadius = 1;
       // self.topLineView.layer.shadowOpacity = 0.2;
        self.topLineView.backgroundColor = dutchTopLineColor;
        self.backView.backgroundColor = dutchTopNavColor;
        
        
        self.leftTopLineView.layer.shadowOffset = CGSizeMake(-1, 0);
        self.leftTopLineView.layer.shadowRadius = 1;
        self.leftTopLineView.layer.shadowOpacity = 0.5;
        
        
        self.rightTopLineView.layer.shadowOffset = CGSizeMake(1, 0);
        self.rightTopLineView.layer.shadowRadius = 1;
        self.rightTopLineView.layer.shadowOpacity = 0.5;
        
        
        
        
        self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
        self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        [self.loadingViewController stopSpin];
        [self.view addSubview:self.loadingViewController.view];
        
        if (self.view.frame.size.height > 500) {
            self.isIphone5 = YES;
        }else{
            self.isIphone5 = NO;
        }
        
       
        SteelfishTitleLabel *navLabel = [[SteelfishTitleLabel alloc] initWithText:@"Invoice #"];
        self.navigationItem.titleView = navLabel;
        
        SteelfishBarButtonItem *temp = [[SteelfishBarButtonItem alloc] initWithTitleText:@"Invoice #"];
		self.navigationItem.backBarButtonItem = temp;
        
       
  
        
       // self.hiddenText = [[UITextField alloc] init];
        self.hiddenText.keyboardType = UIKeyboardTypeNumberPad;
        self.hiddenText.delegate = self;
        self.hiddenText.textColor = dutchDarkBlueColor;
        self.hiddenText.text = @"";
       // [self.view addSubview:self.hiddenText];
    

        
        NSLog(@"Name; %@", self.name);
        
        self.nameDisplay.text = [NSString stringWithFormat:@"%@", self.name];
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
   
        
    }
    @catch (NSException *e) {
        
        NSLog(@"Exception: %@", e);
        
        [rSkybox sendClientLog:@"Restaurant.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}





- (IBAction)submit:(id)sender {
    @try {
        
      
        self.errorLabel.text = @"";
        
        if ([self.hiddenText.text length] < 1) {
            
            self.errorLabel.text = @"*Please enter the full check number";
        }else{
            
            @try{
                //[self.activity startAnimating];
                
                self.loadingViewController.displayText.text = @"Getting Invoice...";
                [self.loadingViewController startSpin];
                
                NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
                
                NSString *invoiceNumber = self.hiddenText.text;
                
                
                
             
                
            
                [tempDictionary setValue:invoiceNumber forKey:@"invoiceNumber"];
                [tempDictionary setValue:self.merchantId forKey:@"merchantId"];
                
                NSDictionary *loginDict = [[NSDictionary alloc] init];
                loginDict = tempDictionary;
                
                self.submitButton.enabled = NO;
                self.keyboardSubmitButton.enabled = NO;
            
                self.getInvoiceArcClient = [[ArcClient alloc] init];
                [self.getInvoiceArcClient getInvoice:loginDict];
            }
            @catch (NSException *e) {
                //[rSkybox sendClientLog:@"getInvoiceFromNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];                
            }
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.submit" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)invoiceComplete:(NSNotification *)notification{
    @try {
        
        
        
        ArcClient *pingClient = [[ArcClient alloc] init];
        [pingClient sendServerPings];
        
        //[self.activity stopAnimating];
        [self.loadingViewController stopSpin];
        BOOL displayAlert = NO;

        self.submitButton.enabled = YES;
        self.keyboardSubmitButton.enabled = YES;
     

        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
       // NSLog(@"ResponseInfo: %@", responseInfo);
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            //NSDictionary *theInvoice = [[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] objectAtIndex:0];
            
            NSDictionary *theInvoice = [[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"];
            
            self.myInvoice = [[Invoice alloc] init];
            self.myInvoice.invoiceId = [[theInvoice valueForKey:@"Id"] intValue];
            self.myInvoice.status = [theInvoice valueForKey:@"Status"];
            self.myInvoice.number = [theInvoice valueForKey:@"Number"];
            self.myInvoice.merchantId = [[theInvoice valueForKey:@"MerchantId"] intValue];
            self.myInvoice.customerId = [[theInvoice valueForKey:@"CustomerId"] intValue];
            self.myInvoice.posi = [theInvoice valueForKey:@"POSI"];
            
            self.myInvoice.subtotal = [[theInvoice valueForKey:@"BaseAmount"] doubleValue];
            self.myInvoice.serviceCharge = [[theInvoice valueForKey:@"ServiceCharge"] doubleValue];
            self.myInvoice.tax = [[theInvoice valueForKey:@"Tax"] doubleValue];
            self.myInvoice.discount = [[theInvoice valueForKey:@"Discount"] doubleValue];
            self.myInvoice.additionalCharge = [[theInvoice valueForKey:@"AdditionalCharge"] doubleValue];
            
            self.myInvoice.dateCreated = [theInvoice valueForKey:@"DateCreated"];
            
            self.myInvoice.tags = [NSArray arrayWithArray:[theInvoice valueForKey:@"Tags"]];
            self.myInvoice.items = [NSArray arrayWithArray:[theInvoice valueForKey:@"Items"]];
            self.myInvoice.payments = [NSArray arrayWithArray:[theInvoice valueForKey:@"Payments"]];
            self.myInvoice.paymentsAccepted = self.paymentsAccepted;
            
            self.wentInvoice = YES;
            
            self.paidItemsArray = [NSMutableArray array];
            @try {
                NSArray *payments = [theInvoice valueForKey:@"Payments"];
                for (int i = 0; i < [payments count]; i++) {
                    NSDictionary *payment = [payments objectAtIndex:i];
                    
                    NSArray *paidItems = [payment valueForKey:@"PaidItems"];
                    
                    NSString *paidBy = [[payments valueForKey:@"Name"] objectAtIndex:0];
                    NSString *paidByAct = [[payments valueForKey:@"Account"] objectAtIndex:0];
                    
                    for (int j = 0; j < [paidItems count]; j++) {
                        NSDictionary *paidItem = [paidItems objectAtIndex:j];
                        [paidItem setValue:paidBy forKey:@"PaidBy"];
                        [paidItem setValue:paidByAct forKey:@"PaidByAct"];
                        
                        [self.paidItemsArray addObject:paidItem];
                    }
                }
                
                
                
            }
            @catch (NSException *exception) {
                
            }
            
            
            [self performSegueWithIdentifier:@"goInvoice" sender:self];
            
        } else if([status isEqualToString:@"error"]){
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            if(errorCode == INVOICE_NOT_FOUND) {
                errorMsg = @"Can not find invoice.";
            } else if(errorCode == INVOICE_CLOSED) {
                errorMsg = @"Invoice closed.";
            }else if (errorCode == CHECK_IS_LOCKED){
                errorMsg = @"Invoice being accessed by your waiter.  Try again in a few minutes.";
            } else if (errorCode == NETWORK_ERROR){
                displayAlert = YES;
                errorMsg = @"dutch is having problems connecting to the internet.  Please check your connection and try again.  Thank you!";
                
            } else {
                errorMsg = ARC_ERROR_MSG;
            }
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if([errorMsg length] > 0) {
            
            if (displayAlert) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could Not Get Invoice" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
            }else{
                self.errorLabel.text = errorMsg;
                
            }
        }
    }
    @catch (NSException *e) {
        [self.loadingViewController stopSpin];
        self.errorLabel.text = ARC_ERROR_MSG;
        
        [rSkybox sendClientLog:@"Restaurant.invoiceComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"goInvoice"]) {
            
            InvoiceView *nextView = [segue destinationViewController];
            nextView.myInvoice = self.myInvoice;
            nextView.paymentsAccepted = self.paymentsAccepted;
            nextView.paidItemsArray = [NSMutableArray arrayWithArray:self.paidItemsArray];
            
            
        } 
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
    
}

- (IBAction)checkNumberHelp {
    @try {
        
        self.helpOverlay.view.hidden = YES;
        
        if (self.helpShowing) {
            [self touchesBegan:nil withEvent:nil];
        }else{
            [self.hideKeyboardView removeFromSuperview];
            self.hideKeyboardView = nil;
            
            self.helpShowing = YES;
            
            self.helpBackView.hidden = NO;
            self.closeHelpButton.hidden = NO;

            [self.checkNumOne resignFirstResponder];
            [self.checkNumTwo resignFirstResponder];
            [self.checkNumThree resignFirstResponder];
            [self.checkNumFour resignFirstResponder];
            [self.hiddenText resignFirstResponder];
            
            self.checkNumOne.enabled = NO;
            self.checkNumTwo.enabled = NO;
            self.checkNumThree.enabled = NO;
            self.checkNumFour.enabled = NO;
            
            self.submitButton.enabled = NO;
        }
     
        //self.nameDisplay.hidden = YES;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.checkNumberHelp" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    @try {
        
        if (self.helpShowing) {
            
            self.helpShowing = NO;
            self.helpBackView.hidden = YES;
            self.closeHelpButton.hidden = YES;

            
            self.checkNumOne.enabled = YES;
            self.checkNumTwo.enabled = YES;
            self.checkNumThree.enabled = YES;
            self.checkNumFour.enabled = YES;
            
            [self.hiddenText becomeFirstResponder];
            
            self.nameDisplay.hidden = NO;
            self.submitButton.enabled = YES;
            
            if ([self.hiddenText.text length] > 0) {
                //[self showDoneButton];
            }
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.touchesBegan" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
    
}









-(void)showDoneButton{
    @try {
        
        [self.hideKeyboardView removeFromSuperview];
        self.hideKeyboardView = nil;
        
        int keyboardY = 158;
        if (self.isIphone5) {
            keyboardY = 245;
        }
        self.hideKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(235, keyboardY, 85, 45)];
        self.hideKeyboardView .backgroundColor = [UIColor clearColor];
        self.hideKeyboardView.layer.masksToBounds = YES;
        self.hideKeyboardView.layer.cornerRadius = 3.0;
        
        UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 85, 45)];
        tmpView.backgroundColor = [UIColor blackColor];
        tmpView.alpha = 0.6;
        [self.hideKeyboardView addSubview:tmpView];
        
        self.keyboardSubmitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.keyboardSubmitButton.frame = CGRectMake(8, 5, 69, 35);
        [self.keyboardSubmitButton setTitle:@"Submit" forState:UIControlStateNormal];
        [self.keyboardSubmitButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
        [self.keyboardSubmitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.keyboardSubmitButton setBackgroundImage:[UIImage imageNamed:@"rowButton.png"] forState:UIControlStateNormal];
        [self.keyboardSubmitButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.hideKeyboardView addSubview:self.keyboardSubmitButton];
        [self.view addSubview:self.hideKeyboardView];
        
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.showDoneButton" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



- (void)closeHelp {
    
    @try {
        
        if (self.helpShowing) {
            
            self.helpShowing = NO;
            self.helpBackView.hidden = YES;
            self.closeHelpButton.hidden = YES;

            
            self.checkNumOne.enabled = YES;
            self.checkNumTwo.enabled = YES;
            self.checkNumThree.enabled = YES;
            self.checkNumFour.enabled = YES;
            
            [self.checkNumOne becomeFirstResponder];
            [self.hiddenText becomeFirstResponder];
            
            self.nameDisplay.hidden = NO;
            self.submitButton.enabled = YES;
            
            if ([self.hiddenText.text length] > 0) {
                //[self showDoneButton];
            }
            
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Restaurant.closeHelp" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

//BlueTooth

- (void)sendData:(NSArray*)data
{
    NSData* encodedArray = [NSKeyedArchiver archivedDataWithRootObject:data];
    [UIAppDelegate.connectionSession sendDataToAllPeers:encodedArray withDataMode:GKSendDataReliable error:nil];
    
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    //NSArray *receivedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //Handle the data received in the array
    
}


- (void)connectToPeers:(id)sender
{
    [UIAppDelegate.connectionPicker show];
}

- (void)disconnect:(id)sender
{
    [UIAppDelegate.connectionSession disconnectFromAllPeers];
    [UIAppDelegate.connectionPeers removeAllObjects];
}




- (IBAction)takeCheckPicture {
    
    /*
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 320, 5)];
    lineView.backgroundColor = [ UIColor greenColor];
    [self.imagePickerController.view addSubview:lineView];
    
	[self presentModalViewController:self.imagePickerController animated:YES];
     */
    
}


- (NSString *) applicationDocumentsDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
	return documentsDirectoryPath;
}




//http://www.iphonedevsdk.com/forum/iphone-sdk-development/7307-resizing-photo-new-uiimage.html#post33912
-(UIImage *)resizeImage:(UIImage *)image {
    
    /*
	CGImageRef imageRef = [image CGImage];
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
    
	if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
    
	int width, height;
    
	width = 640;//[image size].width;
	height = 640;//[image size].height;
    
	CGContextRef bitmap;
    
	if (image.imageOrientation == UIImageOrientationUp | image.imageOrientation == UIImageOrientationDown) {
		bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
        
	} else {
		bitmap = CGBitmapContextCreate(NULL, height, width, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
        
	}
    
	if (image.imageOrientation == UIImageOrientationLeft) {
		NSLog(@"image orientation left");
		CGContextRotateCTM (bitmap, radians(90));
		CGContextTranslateCTM (bitmap, 0, -height);
        
	} else if (image.imageOrientation == UIImageOrientationRight) {
		NSLog(@"image orientation right");
		CGContextRotateCTM (bitmap, radians(-90));
		CGContextTranslateCTM (bitmap, -width, 0);
        
	} else if (image.imageOrientation == UIImageOrientationUp) {
		NSLog(@"image orientation up");
        
	} else if (image.imageOrientation == UIImageOrientationDown) {
		NSLog(@"image orientation down");
		CGContextTranslateCTM (bitmap, width,height);
		CGContextRotateCTM (bitmap, radians(-180.));
        
	}
    
	CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage *result = [UIImage imageWithCGImage:ref];
    
	CGContextRelease(bitmap);
	CGImageRelease(ref);
    
	return result;
     */
    return nil;
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
		didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
    
    /*
    
	// Dismiss the image selection, hide the picker and
    
	//show the image view with the picked image
    
	[picker dismissModalViewControllerAnimated:YES];
	UIImage *newImage = [self resizeImage:image];
	//NSString *text = [self ocrImage:newImage];
 
    
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
    //[tesseract setVariableValue:@"0123456789CHEK:" forKey:@"tessedit_char_whitelist"];
    //[tesseract setImage:[UIImage imageNamed:@"untitledReceipt.png"]];
    [tesseract setImage:newImage];
    
    
    dispatch_queue_t queue = dispatch_queue_create("recognize.task", NULL);
    dispatch_queue_t main = dispatch_get_main_queue();
    
    
    self.loadingViewController.displayText.text = @"Processing...";
     [self.loadingViewController startSpin];
     dispatch_async(queue,^{
     
         @try {
        
             [tesseract recognize];

             NSString *foundCheck = @"NOT FOUND";
             
             foundCheck = [self getCheckNumberFromString:[tesseract recognizedText]];
             
             dispatch_async(main,^{
     
     [self.loadingViewController stopSpin];
     
                 UITextView *tmp = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
                 tmp.backgroundColor = [UIColor whiteColor];
                 tmp.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
                 tmp.text = [NSString stringWithFormat:@"RESULTS:                                                        Check # FOUND: %@                                                                  Full Results:                                                                 %@", foundCheck, [tesseract recognizedText]];
                 [self.view addSubview:tmp];
                 
                 UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                 [removeButton setTitle:@"Close" forState:UIControlStateNormal];
                 removeButton.frame = CGRectMake(200, 0, 120, 35);
                 [tmp addSubview:removeButton];
                 [removeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
     
             });
    
         }
         @catch (NSException *exception) {
     
     
         }
     
     
     });
     
    */

    
}
-(NSString *)getCheckNumberFromString:(NSString *)recognizedText{
    
    @try {
        NSString *returnString = @"";
        recognizedText = [recognizedText stringByReplacingOccurrencesOfString:@"O" withString:@"0"];
        if ([recognizedText rangeOfString:@"CHK"].location != NSNotFound) {
            
            int location = [recognizedText rangeOfString:@"CHK"].location;
            
            NSString *substring = [recognizedText substringFromIndex:location + 4];
            
            for (int i = 0; i < 8; i++) {
                
                
                NSCharacterSet *_NumericOnly = [NSCharacterSet decimalDigitCharacterSet];
                NSCharacterSet *myStringSet = [NSCharacterSet characterSetWithCharactersInString:[substring substringWithRange:NSMakeRange(i, 1)]];
                
                if ([_NumericOnly isSupersetOfSet: myStringSet])
                {
                    //Is a a number
                    
                    returnString = [returnString stringByAppendingString:[substring substringWithRange:NSMakeRange(i, 1)]];
                }
                
                
                
            }
            
            
            return returnString;
            
            
        }else{
            return @"NOT FOUND";
        }
    }
    @catch (NSException *exception) {
        return @"NOT FOUND";
    }
 
    
}


-(void)close:(id)sender{
    
    UIButton *tmp = (UIButton *)sender;
    
    [tmp.superview removeFromSuperview];
}





- (IBAction)goBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)showInvoiceHint{
    
    NSTimer *myTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showHint) userInfo:nil repeats:NO];
    if (myTimer) {
        
    }
    
    
}

-(void)showHint{
    
    NSTimer *myTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideHint) userInfo:nil repeats:NO];
    if (myTimer) {
        
    }
    [UIView animateWithDuration:1.0 animations:^{
        self.helpOverlay.view.alpha = 1.0;
    }];
    
    
    
    
    
}

-(void)hideHint{
    
    
    [UIView animateWithDuration:1.0 animations:^{
        self.helpOverlay.view.alpha = 0.0;
    }];
}


@end
