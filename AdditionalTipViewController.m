//
//  AdditionalTipViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 3/29/13.
//
//

#import "AdditionalTipViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"
#import "ConfirmPaymentViewController.h"


@interface AdditionalTipViewController ()

@end

@implementation AdditionalTipViewController

-(void)viewDidLoad{
    
    self.transactionNotesText.delegate = self;
    
    self.tipTextField.keyboardType = UIKeyboardTypeDecimalPad;

    
    self.continueButton.text = @"Continue";
    self.continueButton.textColor = [UIColor whiteColor];
    self.continueButton.textShadowColor = [UIColor darkGrayColor];
    self.continueButton.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0 blue:125.0/255.0 alpha:1];
    
    self.tipSelectSegment.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0 blue:125.0/255.0 alpha:1];
    
    
    self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
    self.topLineView.layer.shadowRadius = 1;
    self.topLineView.layer.shadowOpacity = 0.5;
    
    self.backView.layer.cornerRadius = 7.0;
    
    
    self.myTotalLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.basePaymentAmount];
    
    
    if (self.myInvoice.serviceCharge == 0.0) {
        
        self.tipSelectSegment.selectedSegmentIndex = 1;
        double doubleValue = self.myInvoice.basePaymentAmount * 0.20;
        
        self.tipTextField.text = [NSString stringWithFormat:@"%.2f", doubleValue];
    }else{
        self.tipSelectSegment.selectedSegmentIndex = -1;
    }
    
}



- (IBAction)continueAction:(id)sender {
    
    if (self.tipTextField.text == nil) {
        self.tipTextField.text = @"";
    }
    
    self.myInvoice.gratuity = [self.tipTextField.text doubleValue];
    
    [self performSegueWithIdentifier:@"goConfirm" sender:self];
    
}

- (IBAction)goBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)endText {
}

- (IBAction)segmentValueChanged:(id)sender {
    
    double tipDouble = 0.0;
    if (self.tipSelectSegment.selectedSegmentIndex == 0) {
        tipDouble = 0.18;
    }else if (self.tipSelectSegment.selectedSegmentIndex == 1){
        tipDouble = 0.20;
    }else{
        tipDouble = 0.22;
    }
    
    double doubleValue = self.myInvoice.basePaymentAmount * tipDouble;
    
    self.tipTextField.text = [NSString stringWithFormat:@"%.2f", doubleValue];
}

- (IBAction)tipTextEditChanged {
    
    self.tipSelectSegment.selectedSegmentIndex = -1;
}

-(void)showDoneButton{
    @try {
        
        [self.hideKeyboardView removeFromSuperview];
        self.hideKeyboardView = nil;
        
        int keyboardY = 200;
        if (self.view.frame.size.height > 500) {
            keyboardY = 288;
        }
        self.hideKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(235, keyboardY, 85, 45)];
        self.hideKeyboardView .backgroundColor = [UIColor clearColor];
        self.hideKeyboardView.layer.masksToBounds = YES;
        self.hideKeyboardView.layer.cornerRadius = 3.0;
        
        UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 85, 45)];
        tmpView.backgroundColor = [UIColor blackColor];
        tmpView.alpha = 0.6;
        [self.hideKeyboardView addSubview:tmpView];
        
        UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tmpButton.frame = CGRectMake(8, 5, 69, 35);
        [tmpButton setTitle:@"Done" forState:UIControlStateNormal];
        [tmpButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
        [tmpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tmpButton setBackgroundImage:[UIImage imageNamed:@"rowButton.png"] forState:UIControlStateNormal];
        [tmpButton addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
        
        [self.hideKeyboardView addSubview:tmpButton];
        [self.view addSubview:self.hideKeyboardView];
        
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AdditionalTipView.showDoneButton" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)hideKeyboard{
    
    [self.hideKeyboardView removeFromSuperview];
    self.hideKeyboardView = nil;

    [self.transactionNotesText resignFirstResponder];
    [self.tipTextField resignFirstResponder];
    
    
    double value = [self.tipTextField.text doubleValue];
    
    self.tipTextField.text = [NSString stringWithFormat:@"%.2f", value];
}


- (IBAction)tipTextEditBegin {
    
    [self showDoneButton];
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    @try {
        
        if ([self.transactionNotesText.text isEqualToString:@"Transaction Notes (*optional):"]){
            self.transactionNotesText.text = @"";
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AdditionaTipVC.textViewDidBeginEditing" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    @try {
        
        if ([text isEqualToString:@""]) {
            return YES;
        }
        
        // Any new character added is passed in as the "text" parameter
        if ([text isEqualToString:@"\n"]) {
            // Be sure to test for equality using the "isEqualToString" message
            [textView resignFirstResponder];
            
            if ([self.transactionNotesText.text isEqualToString:@""]){
                self.transactionNotesText.text = @"Transaction Notes (*optional):";
            }
            
            
            
            // Return FALSE so that the final '\n' character doesn't get added
            return FALSE;
        }else{
            if ([self.transactionNotesText.text length] >= 300) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Reached" message:@"You have reached the character limit for this field." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return FALSE;
            }
        }
        // For any other character return TRUE so that the text gets added to the view
        return TRUE;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"AdditionaTipVC.shouldChangeCharacters" logMessage:@"Exception Caught" logLevel:@"error" exception:e];

    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
       if ([[segue identifier] isEqualToString:@"goConfirm"]) {
            
 
            
            ConfirmPaymentViewController *controller = [segue destinationViewController];
            controller.myInvoice = self.myInvoice;
            
            controller.creditCardSample = self.creditCardSample;
            controller.creditCardNumber = self.creditCardNumber;
            controller.creditCardExpiration = self.creditCardExpiration;
           controller.creditCardSecurityCode = self.creditCardSecurityCode;
           
           if (self.transactionNotesText.text == nil || [self.transactionNotesText.text isEqualToString:@"Transaction Notes (*optional):"]) {
               self.transactionNotesText.text = @"";
           }
           controller.transactionNotes = self.transactionNotesText.text;
           
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}



@end
