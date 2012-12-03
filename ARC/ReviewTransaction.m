
//  ReviewTransaction.m
//  ARC
//
//  Created by Nick Wroblewski on 6/29/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "ReviewTransaction.h"
#import <QuartzCore/QuartzCore.h>
#import "Home.h"
#import "ArcAppDelegate.h"
#import "ArcClient.h"
#import "rSkybox.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import "Invoice.h"
#import "Merchant.h"

@interface ReviewTransaction ()

-(void)changeStarsInRow:(NSString *)row numSelected:(int)selected;

@end

@implementation ReviewTransaction
@synthesize earnMoreLabel;

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviewComplete:) name:@"createReviewNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noPaymentSources) name:@"NoPaymentSourcesNotification" object:nil];
    
    if (self.isIos6) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            if ([[prefs valueForKey:@"autoPostFacebook"] isEqualToString:@"yes"]) {
                self.postFacebookButton.hidden = YES;
                self.postFacebookPoints.hidden  = YES;
                
            }
        }else{
            [prefs setValue:@"no" forKey:@"autoPostFacebook"];
            [prefs synchronize];
        }
        
        
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            if ([[prefs valueForKey:@"autoPostTwitter"] isEqualToString:@"yes"]) {
                self.postTwitterButton.hidden = YES;
                self.postTwitterPoints.hidden  = YES;
                
            }
        }else{
            [prefs setValue:@"no" forKey:@"autoPostTwitter"];
            [prefs synchronize];
        }
        
        if (self.postFacebookButton.hidden && self.postTwitterButton.hidden) {
            self.shareLabel.hidden = YES;
        }
    }
   
    
}
-(void)viewDidAppear:(BOOL)animated{
    @try {
        double totalPayment = [self.myInvoice basePaymentAmount] + [self.myInvoice gratuity];
        NSString *payAmount = [NSString stringWithFormat:@"%.2f", totalPayment];
        
        NSString *payString = @"";
        NSString *title = @"";
        if([self.myInvoice paidInFull]) {
            title = @"Paid in Full";
            payString = [NSString stringWithFormat:@"Please confirm payment with server before leaving the restaurant."];
        } else {
            title = @"Success!";
            payString = [NSString stringWithFormat:@"Congratulations, your payment of $%@ was successfully processed!", payAmount];
        }        
                
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:payString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        self.foodInt = @(0.0);
        self.drinksInt = @(0.0);
        self.priceInt = @(0.0);
        self.serviceInt = @(0.0);
        self.moodInt = @(0.0);
        self.twitterInt = @(0.0);
        self.facebookInt = @(0.0);

        [alert show];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReviewTransaction.viewDidAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)sliderValueChanged:(UISlider *)sender{
    
    
    if (sender.value < 0.30) {
        [sender setMinimumTrackTintColor:[UIColor redColor]];
    }else if (sender.value < 0.67){
        [sender setMinimumTrackTintColor:[UIColor yellowColor]];

    }else{
        [sender setMinimumTrackTintColor:[UIColor greenColor]];
    }
    
    self.foodInt = [NSNumber numberWithDouble:(self.foodSlider.value * 10)/2.0];
    self.drinksInt = [NSNumber numberWithDouble:(self.drinksSlider.value * 10)/2.0];
    self.priceInt = [NSNumber numberWithDouble:(self.valueSlider.value * 10)/2.0];
    self.serviceInt = [NSNumber numberWithDouble:(self.serviceSlider.value * 10)/2.0];
    self.moodInt = [NSNumber numberWithDouble:(self.moodSlider.value * 10)/2.0];

    
    int tag = sender.tag;
    
    UILabel *tmpLabel = (UILabel *)[self.view viewWithTag:tag+1];
    
    tmpLabel.text = [NSString stringWithFormat:@"%.1f", (sender.value * 10)/2.0];
    
    
    
    
}
-(void)viewDidLoad{
    @try {
        
        if(NSClassFromString(@"SLComposeViewController")) {
            self.isIos6 = YES;
        }else{
            self.isIos6 = NO;
            self.postFacebookButton.hidden = YES;
            self.postFacebookPoints.hidden = YES;
        }
        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Review"];
        self.navigationItem.titleView = navLabel;
        
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Review"];
		self.navigationItem.backBarButtonItem = temp;
        
        self.earnMoreLabel.text = [NSString stringWithFormat:@"Earn more by giving %@ feedback:", [[NSUserDefaults standardUserDefaults] valueForKey:@"merchantName"]];
        
        [rSkybox addEventToSession:@"viewReviewScreen"];
       
        
        self.priceInt = @1;
        self.foodInt = @1;
        self.drinksInt = @1;
        self.serviceInt = @1;
        
        
        [self.navigationItem setHidesBackButton:YES];
        self.commentsText.delegate = self;
        
        
        //self.commentsText.clipsToBounds = YES;
        //self.commentsText.layer.cornerRadius = 5.0;
        
        //self.commentsText.layer.borderColor = [[UIColor blackColor] CGColor];
        //self.commentsText.layer.borderWidth = 3.0;
         
        
        [[self.commentsText layer] setBorderColor:[[UIColor blackColor] CGColor]];
        [[self.commentsText layer] setBorderWidth:1.0];
        [[self.commentsText layer] setCornerRadius:7];
        [self.commentsText setClipsToBounds: YES];
        
        [self.food1 setImage:[UIImage imageNamed:@"fullStar.png"] forState:UIControlStateNormal];
        [self.service1 setImage:[UIImage imageNamed:@"fullStar.png"] forState:UIControlStateNormal];
        [self.drinks1 setImage:[UIImage imageNamed:@"fullStar.png"] forState:UIControlStateNormal];
        [self.atmosphere1 setImage:[UIImage imageNamed:@"fullStar.png"] forState:UIControlStateNormal];
        [self.value1 setImage:[UIImage imageNamed:@"fullStar.png"] forState:UIControlStateNormal];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.view.bounds;
        self.view.backgroundColor = [UIColor clearColor];
        UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReviewTransaction.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(IBAction)starClicked:(id)sender{
    @try {
        
        NSString *row = @"";
        UIButton *tmpButton = sender;
        
        int myTag = tmpButton.tag;
        
        if (myTag < 6) {
            row = @"food";
            [self changeStarsInRow:row numSelected:myTag];
            
        }else if(myTag < 11){
            row = @"service";
            [self changeStarsInRow:row numSelected:myTag - 5];
        }else if (myTag < 16){
            row = @"drinks";
            [self changeStarsInRow:row numSelected:myTag - 10];
            
        }else if (myTag < 21){
            row = @"atmosphere";
            [self changeStarsInRow:row numSelected:myTag - 15];
            
        }else{
            row = @"value";
            [self changeStarsInRow:row numSelected:myTag - 20];
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReviewTransaction.starClicked" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
    
}

-(void)changeStarsInRow:(NSString *)row numSelected:(int)selected{
    @try {
        
        UIImage *full = [UIImage imageNamed:@"fullStar.png"];
        UIImage *empty = [UIImage imageNamed:@"emptyStar.png"];
        
        if ([row isEqualToString:@"food"]) {
            
            [self.food5 setImage:full forState:UIControlStateNormal];
            [self.food4 setImage:full forState:UIControlStateNormal];
            [self.food3 setImage:full forState:UIControlStateNormal];
            [self.food2 setImage:full forState:UIControlStateNormal];
            [self.food1 setImage:full forState:UIControlStateNormal];
            
            self.foodInt = @5;
            
            if (selected == 4){
                self.foodInt = @4;
                
                [self.food5 setImage:empty forState:UIControlStateNormal];
                
            }else if (selected == 3){
                self.foodInt = @3;
                
                [self.food5 setImage:empty forState:UIControlStateNormal];
                [self.food4 setImage:empty forState:UIControlStateNormal];
            }else if (selected == 2){
                
                self.foodInt = @2;
                
                [self.food5 setImage:empty forState:UIControlStateNormal];
                [self.food4 setImage:empty forState:UIControlStateNormal];
                [self.food3 setImage:empty forState:UIControlStateNormal];
            }else if (selected == 1){
                
                self.foodInt = @1;
                
                [self.food5 setImage:empty forState:UIControlStateNormal];
                [self.food4 setImage:empty forState:UIControlStateNormal];
                [self.food3 setImage:empty forState:UIControlStateNormal];
                [self.food2 setImage:empty forState:UIControlStateNormal];
            }
            
            
        }else if ([row isEqualToString:@"service"]){
            
            [self.service5 setImage:full forState:UIControlStateNormal];
            [self.service4 setImage:full forState:UIControlStateNormal];
            [self.service3 setImage:full forState:UIControlStateNormal];
            [self.service2 setImage:full forState:UIControlStateNormal];
            [self.service1 setImage:full forState:UIControlStateNormal];
            
            self.serviceInt = @5;
            
            
            if (selected == 4){
                self.serviceInt = @4;
                
                [self.service5 setImage:empty forState:UIControlStateNormal];
                
            }else if (selected == 3){
                
                self.serviceInt = @3;
                
                [self.service5 setImage:empty forState:UIControlStateNormal];
                [self.service4 setImage:empty forState:UIControlStateNormal];
            }else if (selected == 2){
                
                self.serviceInt = @2;
                
                [self.service5 setImage:empty forState:UIControlStateNormal];
                [self.service4 setImage:empty forState:UIControlStateNormal];
                [self.service3 setImage:empty forState:UIControlStateNormal];
            }else if (selected == 1){
                
                self.serviceInt = @1;
                
                [self.service5 setImage:empty forState:UIControlStateNormal];
                [self.service4 setImage:empty forState:UIControlStateNormal];
                [self.service3 setImage:empty forState:UIControlStateNormal];
                [self.service2 setImage:empty forState:UIControlStateNormal];
            }
            
        }else if ([row isEqualToString:@"drinks"]){
            
            [self.drinks5 setImage:full forState:UIControlStateNormal];
            [self.drinks4 setImage:full forState:UIControlStateNormal];
            [self.drinks3 setImage:full forState:UIControlStateNormal];
            [self.drinks2 setImage:full forState:UIControlStateNormal];
            [self.drinks1 setImage:full forState:UIControlStateNormal];
            
            self.drinksInt = @5;
            
            if (selected == 4){
                
                self.drinksInt = @4;
                
                [self.drinks5 setImage:empty forState:UIControlStateNormal];
                
            }else if (selected == 3){
                
                self.drinksInt = @3;
                
                [self.drinks5 setImage:empty forState:UIControlStateNormal];
                [self.drinks4 setImage:empty forState:UIControlStateNormal];
            }else if (selected == 2){
                
                self.drinksInt = @2;
                
                [self.drinks5 setImage:empty forState:UIControlStateNormal];
                [self.drinks4 setImage:empty forState:UIControlStateNormal];
                [self.drinks3 setImage:empty forState:UIControlStateNormal];
            }else if (selected == 1){
                
                self.drinksInt = @1;
                
                [self.drinks5 setImage:empty forState:UIControlStateNormal];
                [self.drinks4 setImage:empty forState:UIControlStateNormal];
                [self.drinks3 setImage:empty forState:UIControlStateNormal];
                [self.drinks2 setImage:empty forState:UIControlStateNormal];
            }
            
        }else if ([row isEqualToString:@"atmosphere"]){
            
            [self.atmosphere5 setImage:full forState:UIControlStateNormal];
            [self.atmosphere4 setImage:full forState:UIControlStateNormal];
            [self.atmosphere3 setImage:full forState:UIControlStateNormal];
            [self.atmosphere2 setImage:full forState:UIControlStateNormal];
            [self.atmosphere1 setImage:full forState:UIControlStateNormal];
            
            if (selected == 4){
                
                [self.atmosphere5 setImage:empty forState:UIControlStateNormal];
                
            }else if (selected == 3){
                
                [self.atmosphere5 setImage:empty forState:UIControlStateNormal];
                [self.atmosphere4 setImage:empty forState:UIControlStateNormal];
            }else if (selected == 2){
                
                [self.atmosphere5 setImage:empty forState:UIControlStateNormal];
                [self.atmosphere4 setImage:empty forState:UIControlStateNormal];
                [self.atmosphere3 setImage:empty forState:UIControlStateNormal];
            }else if (selected == 1){
                
                [self.atmosphere5 setImage:empty forState:UIControlStateNormal];
                [self.atmosphere4 setImage:empty forState:UIControlStateNormal];
                [self.atmosphere3 setImage:empty forState:UIControlStateNormal];
                [self.atmosphere2 setImage:empty forState:UIControlStateNormal];
            }
            
        }else{
            
            [self.value5 setImage:full forState:UIControlStateNormal];
            [self.value4 setImage:full forState:UIControlStateNormal];
            [self.value3 setImage:full forState:UIControlStateNormal];
            [self.value2 setImage:full forState:UIControlStateNormal];
            [self.value1 setImage:full forState:UIControlStateNormal];
            
            self.priceInt = @5;
            
            if (selected == 4){
                
                self.priceInt = @4;
                
                [self.value5 setImage:empty forState:UIControlStateNormal];
                
            }else if (selected == 3){
                
                self.priceInt = @3;
                
                [self.value5 setImage:empty forState:UIControlStateNormal];
                [self.value4 setImage:empty forState:UIControlStateNormal];
            }else if (selected == 2){
                
                self.priceInt = @2;
                
                [self.value5 setImage:empty forState:UIControlStateNormal];
                [self.value4 setImage:empty forState:UIControlStateNormal];
                [self.value3 setImage:empty forState:UIControlStateNormal];
            }else if (selected == 1){
                
                self.priceInt = @1;
                
                [self.value5 setImage:empty forState:UIControlStateNormal];
                [self.value4 setImage:empty forState:UIControlStateNormal];
                [self.value3 setImage:empty forState:UIControlStateNormal];
                [self.value2 setImage:empty forState:UIControlStateNormal];
            }
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReviewTransaction.changeStarsInRow" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    @try {
        
        if ([self.commentsText.text isEqualToString:@"Earn +5 pts for an in depth review:"]){
            self.commentsText.text = @"";
        }
        
        
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -165, 320, 416);
        }];
        
     
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReviewTransaction.textViewDidBeginEditing" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    @try {
        
        // Any new character added is passed in as the "text" parameter
        if ([text isEqualToString:@"\n"]) {
            // Be sure to test for equality using the "isEqualToString" message
            [textView resignFirstResponder];
            
            if ([self.commentsText.text isEqualToString:@""]){
                self.commentsText.text = @"Earn +5 pts for an in depth review:";
            }
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
            
            self.view.frame = CGRectMake(0, 0, 320, 416);
            
            
            [UIView commitAnimations];
            
            // Return FALSE so that the final '\n' character doesn't get added
            return FALSE;
        }else{
            
            if ([self.commentsText.text length] >= 500) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Reached" message:@"You have reached the character limit for this field." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return FALSE;
            }
        }
        // For any other character return TRUE so that the text gets added to the view
        return TRUE;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReviewTransaction.textView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (IBAction)submitReview:(id)sender {
    @try {
        
        [rSkybox addEventToSession:@"submitReview"];
        
        [self createReview];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReviewTransaction.submitReview" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)createReview{
    
    @try{     
        
        [self.activity startAnimating];
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
		NSDictionary *loginDict = [[NSDictionary alloc] init];
        
        NSString *commentsString = @"";
        
        if ([self.commentsText.text isEqualToString:@"Earn +5 pts for an in depth review:"]){
            self.commentsText.text = @"";
        }else {
            commentsString = self.commentsText.text;
        }
        [ tempDictionary setObject:commentsString forKey:@"Comments"];

        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *customerId = [mainDelegate getCustomerId];
        [tempDictionary setObject:customerId forKey:@"CustomerId"];

        NSString *invoiceIdString = [NSString stringWithFormat:@"%d", self.myInvoice.invoiceId];
        [ tempDictionary setObject:invoiceIdString forKey:@"InvoiceId"];
        [ tempDictionary setObject:self.drinksInt forKey:@"Drinks"];
        [ tempDictionary setObject:self.foodInt forKey:@"Food"];
        [ tempDictionary setObject:self.priceInt forKey:@"Price"];
        [ tempDictionary setObject:self.serviceInt forKey:@"Service"];
        [ tempDictionary setObject:self.moodInt forKey:@"Mood"];        
        [ tempDictionary setObject:self.twitterInt forKey:@"Twitter"];
        [ tempDictionary setObject:self.facebookInt forKey:@"Facebook"];
        NSString *paymentIdString = [NSString stringWithFormat:@"%d", self.myInvoice.paymentId];
        [ tempDictionary setObject:paymentIdString forKey:@"PaymentId"];
        
		loginDict = tempDictionary;
        self.submitButton.enabled = NO;
        self.skipButton.enabled = NO;
        ArcClient *client = [[ArcClient alloc] init];
        [client createReview:loginDict];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReviewTransaction.createReview" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)reviewComplete:(NSNotification *)notification{
    @try {
        
        self.submitButton.enabled = YES;
        self.skipButton.enabled = YES;
        [rSkybox addEventToSession:@"reviewComplete"];
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        [self.activity stopAnimating];
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            //success
            self.errorLabel.text = @"";
            
            NSString *points = [[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] stringValue];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setValue:points forKey:@"pointsEarned"];
            [prefs synchronize];
            
            
            if (self.isIos6) {
                if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                    if ([[prefs valueForKey:@"autoPostFacebook"] isEqualToString:@"yes"]) {
                        [self autoPostFacebook];
                        self.facebookInt = @(5);
                    }
                }else{
                    [prefs setValue:@"no" forKey:@"autoPostFacebook"];
                    [prefs synchronize];
                }
                
                if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                    if ([[prefs valueForKey:@"autoPostTwitter"] isEqualToString:@"yes"]) {
                        [self autPostTwitter];
                        self.twitterInt = @(5);
                    }
                }else{
                    [prefs setValue:@"no" forKey:@"autoPostTwitter"];
                    [prefs synchronize];
                }
            }
       
     
            Home *tmp = [[self.navigationController viewControllers] objectAtIndex:0];
            tmp.successReview = YES;
            [self.navigationController popToRootViewControllerAnimated:NO];
        } else if([status isEqualToString:@"error"]){
            //int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            errorMsg = ARC_ERROR_MSG;
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if([errorMsg length] > 0) {
            self.errorLabel.text = errorMsg;
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReviewTransaction.reviewComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (IBAction)skipReview:(id)sender {
    @try {
        
        [rSkybox addEventToSession:@"skipReview"];
        
        
        if (self.isIos6) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                if ([[prefs valueForKey:@"autoPostFacebook"] isEqualToString:@"yes"]) {
                    //[self autoPostFacebook];
                    //self.facebookInt = @(5);
                }
            }else{
                [prefs setValue:@"no" forKey:@"autoPostFacebook"];
                [prefs synchronize];
            }
            
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                if ([[prefs valueForKey:@"autoPostTwitter"] isEqualToString:@"yes"]) {
                    //[self autPostTwitter];
                    //self.twitterInt = @(5);
                }
            }else{
                [prefs setValue:@"no" forKey:@"autoPostTwitter"];
                [prefs synchronize];
            }
        }
     
        
        
        Home *tmp = [[self.navigationController viewControllers] objectAtIndex:0];
        tmp.skipReview = YES;
        [self.navigationController popToRootViewControllerAnimated:NO];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReviewTransaction.skipReview" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(IBAction)postFacebook{
    
    SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    
   // if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
   // {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            [fbController dismissViewControllerAnimated:YES completion:nil];
            NSString *title = @"Facebook Post";
            NSString *msg = @"";
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    msg = @"You bailed on your post...";
                    
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    msg = @"Hurray! Your message was posted!";
                    self.facebookInt = @(5.0);

                }   
                    break;
            }
        
        
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
        
        };
    
        //NSString *post = [NSString stringWithFormat:@"I just made a purchase at %@ with %@.", [[NSUserDefaults standardUserDefaults] valueForKey:@"merchantFacebookHandler"], [[NSUserDefaults standardUserDefaults] valueForKey:@"arcFacebookHandler"]];
        NSString *post = [NSString stringWithFormat:@"I just made a purchase at %@ with Arc Mobile.", [[NSUserDefaults standardUserDefaults] valueForKey:@"merchantName"]];
    
        NSNumber *avgRating = [self getAverageRating];
        if([avgRating doubleValue] > 0) {
            post = [post stringByAppendingFormat:@" I gave the restaurant an average rating of %0.1f out of 5.", [avgRating doubleValue]];
        }
        
        [fbController setInitialText:post];
        [fbController addURL:[NSURL URLWithString:@"http://arcmobileapp.com"]];
        [fbController setCompletionHandler:completionHandler];
        [self presentViewController:fbController animated:YES completion:nil];
   // }
    
}

- (IBAction)postTwitter {
    
    if (self.isIos6) {

        SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        
       // if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        //{
            SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
                
                [fbController dismissViewControllerAnimated:YES completion:nil];
                NSString *title = @"Tweet";
                NSString *msg = @"";
                
                switch(result){
                    case SLComposeViewControllerResultCancelled:
                    default:
                    {
                        msg = @"You bailed on your tweet...";
                        
                    }
                        break;
                    case SLComposeViewControllerResultDone:
                    {
                        msg = @"Hurray! Your tweet was tweeted!";
                        self.twitterInt = @(5.0);
                        
                    }
                        break;
                }
                
                
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
                
            };
            
        
        NSString *tweet = [NSString stringWithFormat:@"I just made a purchase at %@ with %@.", [[NSUserDefaults standardUserDefaults] valueForKey:@"merchantTwitterHandler"], [[NSUserDefaults standardUserDefaults] valueForKey:@"arcTwitterHandler"]];
        
            NSNumber *avgRating = [self getAverageRating];
            if([avgRating doubleValue] > 0) {
                tweet = [tweet stringByAppendingFormat:@" I gave the restaurant an average rating of %0.1f out of 5.", [avgRating doubleValue]];
            }
            
            [fbController setInitialText:tweet];
            [fbController addURL:[NSURL URLWithString:@"http://arcmobileapp.com"]];
            [fbController setCompletionHandler:completionHandler];
            [self presentViewController:fbController animated:YES completion:nil];
       // }

        
        
        
    }else{
        TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
        NSString *tweet = [NSString stringWithFormat:@"I just made a purchase at %@ with %@.", [[NSUserDefaults standardUserDefaults] valueForKey:@"merchantTwitterHandler"], [[NSUserDefaults standardUserDefaults] valueForKey:@"arcTwitterHandler"]];
        
        
        NSNumber *avgRating = [self getAverageRating];
        if([avgRating doubleValue] > 0) {
            tweet = [tweet stringByAppendingFormat:@" I gave the restaurant an average rating of %0.1f out of 5.", [avgRating doubleValue]];
        }
        [twitter setInitialText:tweet];
        [self presentModalViewController:twitter animated:YES];
        
        twitter.completionHandler = ^(TWTweetComposeViewControllerResult result) {
            NSString *title = @"Tweet";
            NSString *msg;
            
            if (result == TWTweetComposeViewControllerResultCancelled){
                msg = @"You bailed on your tweet...";
            }
            else if (result == TWTweetComposeViewControllerResultDone) {
                msg = @"Hurray! Your tweet was tweeted!";
                self.twitterInt = @(5.0);
            }
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            
            [self dismissModalViewControllerAnimated:YES];
        };
    }
    
  
    
    
}

- (NSNumber *)getAverageRating {
    @try {
        int numOfRatings = 0;
        if([self.foodInt doubleValue] > 0.0) numOfRatings++;
        if([self.drinksInt doubleValue] > 0.0) numOfRatings++;
        if([self.priceInt doubleValue] > 0.0) numOfRatings++;
        if([self.serviceInt doubleValue] > 0.0) numOfRatings++;
        if([self.moodInt doubleValue] > 0.0) numOfRatings++;
        
        if(numOfRatings == 0) {
            return [NSNumber numberWithDouble:0.0];
        }
        
        return [NSNumber numberWithDouble:([self.foodInt doubleValue] + [self.drinksInt doubleValue] + [self.priceInt doubleValue] +
                                           [self.serviceInt doubleValue] + [self.moodInt doubleValue])/numOfRatings];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReviewTransaction.getAverageRating" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)autPostTwitter{
    
    @try {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
            if(granted) {
                NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
                
                if ([accountsArray count] > 0) {
                    
                    NSString *tweet = [NSString stringWithFormat:@"I just made a purchase at %@ with %@.", [[NSUserDefaults standardUserDefaults] valueForKey:@"merchantTwitterHandler"], [[NSUserDefaults standardUserDefaults] valueForKey:@"arcTwitterHandler"]];
                    
                    NSNumber *avgRating = [self getAverageRating];
                    if([avgRating doubleValue] > 0) {
                        tweet = [tweet stringByAppendingFormat:@" I gave the restaurant an average rating of %0.1f out of 5.", [avgRating doubleValue]];
                    }
                    
                    
                    ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                    
                    SLRequest* postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                requestMethod:SLRequestMethodPOST
                                                                          URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"]
                                                                   parameters:[NSDictionary dictionaryWithObject:tweet forKey:@"status"]];
                    
                    [postRequest setAccount:twitterAccount];
                    
                    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
                        if (output) {
                            
                        }
                        //NSLog(@"%@", output);
                        //[self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
                    }];
                    
                }
            }else{
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                [prefs setValue:@"no" forKey:@"autoPostTwitter"];
                [prefs synchronize];
            }
        }];

    }
    @catch (NSException *exception) {
        
    }
  
   
}

-(void)autoPostFacebook{
    
    //change
    @try {
        self.store = [[ACAccountStore alloc] init];
        
        ACAccountType *accType = [self.store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"515025721859862", ACFacebookAppIdKey,
                                        [NSArray arrayWithObjects:@"publish_stream", @"publish_checkins", nil], ACFacebookPermissionsKey, ACFacebookAudienceFriends, ACFacebookAudienceKey, nil];
        
        [self.store requestAccessToAccountsWithType:accType options:options completion:^(BOOL granted, NSError *error) {
            if (granted && error == nil) {
                //NSLog(@"Granted");
                
                NSArray *accounts = [self.store accountsWithAccountType:accType];
                ACAccount *facebookAccount = [accounts objectAtIndex:0];
                
                //NSString *post = [NSString stringWithFormat:@"I just made a purchase at %@ with %@.", [[NSUserDefaults standardUserDefaults] valueForKey:@"merchantFacebookHandler"], [[NSUserDefaults standardUserDefaults] valueForKey:@"arcFacebookHandler"]];
                NSString *post = [NSString stringWithFormat:@"I just made a purchase at %@ with Arc Mobile.", [[NSUserDefaults standardUserDefaults] valueForKey:@"merchantName"]];
                NSNumber *avgRating = [self getAverageRating];
                if([avgRating doubleValue] > 0) {
                    post = [post stringByAppendingFormat:@" I gave the restaurant an average rating of %0.1f out of 5.", [avgRating doubleValue]];
                }
                
                post = @"I just made a purchase at @[223133961125265:1:test] via @[334720129933220:answer]";
           
                NSDictionary *parameters = @{@"message": post};
                
                NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/feed/"];
                
                SLRequest *feedRequest = [SLRequest
                                          requestForServiceType:SLServiceTypeFacebook
                                          requestMethod:SLRequestMethodPOST
                                          URL:feedURL
                                          parameters:parameters];
                
                feedRequest.account = facebookAccount;
                
                [feedRequest performRequestWithHandler:^(NSData *responseData,
                                                         NSHTTPURLResponse *urlResponse, NSError *error)
                 {
                     // Handle response
                     NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
                     if (output) {
                         
                     }
                     //NSLog(@"Output: %@", output);
                     
                 }];
                
                
                
            } else {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                [prefs setValue:@"no" forKey:@"autoPostFacebook"];
                [prefs synchronize];
                //
                //NSLog(@"Error: %@", [error description]);
                //NSLog(@"Access denied");
            }
        }];

    }
    
    @catch (NSException *exception) {
        
    }
 
}


-(void)noPaymentSources{
    UIViewController *noPaymentController = [self.storyboard instantiateViewControllerWithIdentifier:@"noPayment"];
    [self.navigationController presentModalViewController:noPaymentController animated:YES];
    
}


@end


