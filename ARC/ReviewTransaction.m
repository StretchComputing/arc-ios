//
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

@interface ReviewTransaction ()

-(void)changeStarsInRow:(NSString *)row numSelected:(int)selected;
-(void)createPayment;

@end

@implementation ReviewTransaction
@synthesize earnMoreLabel;

-(void)viewDidAppear:(BOOL)animated{
    @try {
        
        NSString *payAmount = [NSString stringWithFormat:@"%.2f", self.totalAmount];
        
        NSString *payString = [NSString stringWithFormat:@"Congratulations, your payment of $%@ was successfully processed!", payAmount];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:payString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
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
        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Review"];
        self.navigationItem.titleView = navLabel;
        
        
        self.earnMoreLabel.text = [NSString stringWithFormat:@"Earn more by giving %@ feedback:", [[NSUserDefaults standardUserDefaults] valueForKey:@"selectedRestaurant"]];
        
        [rSkybox addEventToSession:@"viewReviewScreen"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviewComplete:) name:@"createReviewNotification" object:nil];
        
        self.priceInt = @1;
        self.foodInt = @1;
        self.drinksInt = @1;
        self.serviceInt = @1;
        
        
        [self.navigationItem setHidesBackButton:YES];
        self.commentsText.delegate = self;
        
        /*
        self.commentsText.clipsToBounds = YES;
        self.commentsText.layer.cornerRadius = 5.0;
        
        self.commentsText.layer.borderColor = [[UIColor blackColor] CGColor];
        self.commentsText.layer.borderWidth = 3.0;
         */
        
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
        NSNumber *tmpId = @([customerId intValue]);
        [ tempDictionary setObject:tmpId forKey:@"CustomerId"];
        
        NSNumber *invoice = @(self.invoiceId);
        
        [ tempDictionary setObject:invoice forKey:@"InvoiceId"];
        [ tempDictionary setObject:self.drinksInt forKey:@"Drinks"];
        [ tempDictionary setObject:self.foodInt forKey:@"Food"];
        [ tempDictionary setObject:self.priceInt forKey:@"Price"];
        [ tempDictionary setObject:self.serviceInt forKey:@"Service"];
        [ tempDictionary setObject:self.moodInt forKey:@"Mood"];
        [ tempDictionary setObject:self.twitterInt forKey:@"Twitter"];
        [ tempDictionary setObject:self.facebookInt forKey:@"Facebook"];

		loginDict = tempDictionary;
        ArcClient *client = [[ArcClient alloc] init];
        [client createReview:loginDict];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReviewTransaction.createPayment" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)reviewComplete:(NSNotification *)notification{
    @try {
        
        [rSkybox addEventToSession:@"reviewComplete"];
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        [self.activity stopAnimating];
        
        if ([status isEqualToString:@"1"]) {
            //success
            self.errorLabel.text = @"";
            
            Home *tmp = [[self.navigationController viewControllers] objectAtIndex:0];
            tmp.successReview = YES;
            [self.navigationController popToRootViewControllerAnimated:NO];
        }else{
            self.errorLabel.text = @"*Error submitting review.";
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReviewTransaction.reviewComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (IBAction)skipReview:(id)sender {
    @try {
        
        [rSkybox addEventToSession:@"skipReview"];
        
        Home *tmp = [[self.navigationController viewControllers] objectAtIndex:0];
        tmp.skipReview = YES;
        [self.navigationController popToRootViewControllerAnimated:NO];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReviewTransaction.skipReview" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}
- (void)viewDidUnload {
    [self setEarnMoreLabel:nil];
    [self setValueSlider:nil];
    [self setMoodSlider:nil];
    [self setDrinksSlider:nil];
    [self setServiceSlider:nil];
    [self setFoodSlider:nil];
    @try {
        
        [self setErrorLabel:nil];
        [self setActivity:nil];
        [super viewDidUnload];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReviewTransaction.viewDidUnload" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}
- (IBAction)postTwitter {
    
    TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
    NSString *tweet = [NSString stringWithFormat:@"I just made a purchase at %@ with ARC Mobile.", [[NSUserDefaults standardUserDefaults] valueForKey:@"selectedRestaurant"]];
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
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
        
        [self dismissModalViewControllerAnimated:YES];
    };
    
}

- (NSNumber *)getAverageRating {
    @try {
        return [NSNumber numberWithDouble:([self.foodInt doubleValue] + [self.drinksInt doubleValue] + [self.priceInt doubleValue] +
                                           [self.serviceInt doubleValue] + [self.moodInt doubleValue])/5.0];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReviewTransaction.getAverageRating" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}
@end
