//
//  PaymentHistoryDetail.m
//  ARC
//
//  Created by Nick Wroblewski on 10/14/13.
//
//

#import "PaymentHistoryDetail.h"
#import "ArcClient.h"
#import "rSkybox.h"
#import "ISO8601DateFormatter.h"

@interface PaymentHistoryDetail ()

@end

@implementation PaymentHistoryDetail

- (void)viewDidLoad
{
    self.resendButton.text = @"Re-send Email Receipt";
    
    self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
    self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    [self.loadingViewController stopSpin];
    [self.view addSubview:self.loadingViewController.view];
    
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    
    @try {
        
        double amount = [[self.paymentDictionary valueForKey:@"Amount"] doubleValue];
        double tip = [[self.paymentDictionary valueForKey:@"Gratuity"] doubleValue];
        double total = amount + tip;
        
        self.totalAmountLabel.text = [NSString stringWithFormat:@"$%.2f", total];
        
        self.merchantNameLabel.text = [self.paymentDictionary valueForKey:@"Merchant"];
        
        self.dateLabel.text = [self dateStringFromISO:[self.paymentDictionary valueForKey:@"DateCreated"]];
        
        
        self.baseAmountLabel.text = [NSString stringWithFormat:@"$%.2f", amount];
        self.tipLabel.text = [NSString stringWithFormat:@"$%.2f", tip];

        self.paymentLabel.text = [self.paymentDictionary valueForKey:@"Card"];
        
        self.checkNumberLabel.text = [self.paymentDictionary valueForKey:@"Number"];
        
        self.confirmationLabel.text = [self.paymentDictionary valueForKey:@"Confirmation"];
        
        if ([[self.paymentDictionary valueForKey:@"Notes"] length] > 0) {
            self.notesTextView.text = [self.paymentDictionary valueForKey:@"Notes"];
        }else{
            self.notesTextView.text = @"--";
        }
        
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentHistoryComplete:) name:@"sendEmailReceiptNotification" object:nil];
        
    }
    @catch (NSException *e) {
         [rSkybox sendClientLog:@"PaymentHistoryDetail.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
 
    
    
}


-(void)paymentHistoryComplete:(NSNotification *)notification{
    @try {
        
        
        self.loadingViewController.view.hidden = YES;
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        NSLog(@"Response Info: %@", responseInfo);
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your receipt has been sent to your email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if([errorMsg length] > 0) {
            //self.errorLabel.text = errorMsg;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email not Sent" message:@"We were unable to send your email receipt at this time, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"PaymentHistoryDetail.signInComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
        
    }
    
}


-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)resendAction{
    
    self.loadingViewController.displayText.text = @"Sending...";
    [self.loadingViewController startSpin];
    
    ArcClient *tmp = [[ArcClient alloc] init];
    NSDictionary *pairs = @{@"TicketId": [self.paymentDictionary valueForKey:@"PaymentId"]};
    [tmp sendEmailReceipt:pairs];
}



-(NSString *)dateStringFromISO:(NSString *)myDate{
    //2013-10-13T21:50:26.81
    
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    NSDate *theDate = [formatter dateFromString:myDate];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd hh:mma"];
    NSString *newDate = [dateFormat stringFromDate:theDate];
    
    return newDate;
}

@end
