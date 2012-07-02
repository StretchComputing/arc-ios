//
//  ReviewTransaction.m
//  ARC
//
//  Created by Nick Wroblewski on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReviewTransaction.h"
#import <QuartzCore/QuartzCore.h>
#import "NewJSON.h"
#import "Home.h"
#import "ArcAppDelegate.h"

@interface ReviewTransaction ()

-(void)changeStarsInRow:(NSString *)row numSelected:(int)selected;
-(void)createPayment;

@end

@implementation ReviewTransaction
@synthesize activity;
@synthesize errorLabel;
@synthesize commentsText, foodInt, drinksInt, priceInt, serviceInt, invoiceId;
@synthesize food1, food2, food3, food4, food5, service1, service2, service3, service4, service5, drinks1, drinks2, drinks3, drinks4, drinks5, atmosphere1, atmosphere2, atmosphere3, atmosphere4, atmosphere5, value1, value2, value3, value4, value5, serverData;

-(void)viewDidLoad{
    
    
    self.priceInt = [NSNumber numberWithInt:1];
    self.foodInt = [NSNumber numberWithInt:1];
    self.drinksInt = [NSNumber numberWithInt:1];
    self.serviceInt = [NSNumber numberWithInt:1];


    [self.navigationItem setHidesBackButton:YES];
    self.commentsText.delegate = self;
    
    self.commentsText.layer.masksToBounds = YES;
    self.commentsText.layer.cornerRadius = 5.0;
    
    [self.food1 setImage:[UIImage imageNamed:@"fullStar.png"] forState:UIControlStateNormal];
    [self.service1 setImage:[UIImage imageNamed:@"fullStar.png"] forState:UIControlStateNormal];
    [self.drinks1 setImage:[UIImage imageNamed:@"fullStar.png"] forState:UIControlStateNormal];
    [self.atmosphere1 setImage:[UIImage imageNamed:@"fullStar.png"] forState:UIControlStateNormal];
    [self.value1 setImage:[UIImage imageNamed:@"fullStar.png"] forState:UIControlStateNormal];

}

-(IBAction)starClicked:(id)sender{
    
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

-(void)changeStarsInRow:(NSString *)row numSelected:(int)selected{
    
    UIImage *full = [UIImage imageNamed:@"fullStar.png"];
    UIImage *empty = [UIImage imageNamed:@"emptyStar.png"];
    
    if ([row isEqualToString:@"food"]) {
        
        [self.food5 setImage:full forState:UIControlStateNormal];
        [self.food4 setImage:full forState:UIControlStateNormal];
        [self.food3 setImage:full forState:UIControlStateNormal];
        [self.food2 setImage:full forState:UIControlStateNormal];
        [self.food1 setImage:full forState:UIControlStateNormal];
        
        self.foodInt = [NSNumber numberWithInt:5];
        
        if (selected == 4){
            self.foodInt = [NSNumber numberWithInt:4];

            [self.food5 setImage:empty forState:UIControlStateNormal];

        }else if (selected == 3){
            self.foodInt = [NSNumber numberWithInt:3];

            [self.food5 setImage:empty forState:UIControlStateNormal];
            [self.food4 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 2){
            
            self.foodInt = [NSNumber numberWithInt:2];

            [self.food5 setImage:empty forState:UIControlStateNormal];
            [self.food4 setImage:empty forState:UIControlStateNormal];
            [self.food3 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 1){
            
            self.foodInt = [NSNumber numberWithInt:1];

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
        
        self.serviceInt = [NSNumber numberWithInt:5];

        
        if (selected == 4){
            self.serviceInt = [NSNumber numberWithInt:4];

            [self.service5 setImage:empty forState:UIControlStateNormal];
            
        }else if (selected == 3){
        
            self.serviceInt = [NSNumber numberWithInt:3];

            [self.service5 setImage:empty forState:UIControlStateNormal];
            [self.service4 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 2){
            
            self.serviceInt = [NSNumber numberWithInt:2];

            [self.service5 setImage:empty forState:UIControlStateNormal];
            [self.service4 setImage:empty forState:UIControlStateNormal];
            [self.service3 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 1){
            
            self.serviceInt = [NSNumber numberWithInt:1];

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
        
        self.drinksInt = [NSNumber numberWithInt:5];

        if (selected == 4){
            
            self.drinksInt = [NSNumber numberWithInt:4];

            [self.drinks5 setImage:empty forState:UIControlStateNormal];
            
        }else if (selected == 3){
            
            self.drinksInt = [NSNumber numberWithInt:3];

            [self.drinks5 setImage:empty forState:UIControlStateNormal];
            [self.drinks4 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 2){
            
            self.drinksInt = [NSNumber numberWithInt:2];

            [self.drinks5 setImage:empty forState:UIControlStateNormal];
            [self.drinks4 setImage:empty forState:UIControlStateNormal];
            [self.drinks3 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 1){
            
            self.drinksInt = [NSNumber numberWithInt:1];

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
        
        self.priceInt = [NSNumber numberWithInt:5];

        if (selected == 4){
            
            self.priceInt = [NSNumber numberWithInt:4];

            [self.value5 setImage:empty forState:UIControlStateNormal];
            
        }else if (selected == 3){
            
            self.priceInt = [NSNumber numberWithInt:3];
            
            [self.value5 setImage:empty forState:UIControlStateNormal];
            [self.value4 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 2){
            
            self.priceInt = [NSNumber numberWithInt:2];

            [self.value5 setImage:empty forState:UIControlStateNormal];
            [self.value4 setImage:empty forState:UIControlStateNormal];
            [self.value3 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 1){
            
            self.priceInt = [NSNumber numberWithInt:1];

            [self.value5 setImage:empty forState:UIControlStateNormal];
            [self.value4 setImage:empty forState:UIControlStateNormal];
            [self.value3 setImage:empty forState:UIControlStateNormal];
            [self.value2 setImage:empty forState:UIControlStateNormal];
        }
        
    }
              
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    if ([self.commentsText.text isEqualToString:@"Additional Comments: (+5pts)"]){
		self.commentsText.text = @"";
	}
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    self.view.frame = CGRectMake(0, -165, 320, 416);
    
    
    [UIView commitAnimations];
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
        
        if ([self.commentsText.text isEqualToString:@""]){
            self.commentsText.text = @"Additional Comments: (+5pts)";
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


- (IBAction)submitReview:(id)sender {
    
    [self createPayment];
}

-(void)createPayment{
    
    @try{     
        
        [self.activity startAnimating];
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
		NSDictionary *loginDict = [[NSDictionary alloc] init];
        
        NSString *commentsString = @"";
        
        if ([self.commentsText.text isEqualToString:@"Additional Comments: (+5pts)"]){
            self.commentsText.text = @"";
        }else {
            commentsString = self.commentsText.text;
        }
   
        [ tempDictionary setObject:commentsString forKey:@"Comments"];

        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *customerId = [mainDelegate getCustomerId];
        NSNumber *tmpId = [NSNumber numberWithInt:[customerId intValue]];
        [ tempDictionary setObject:tmpId forKey:@"CustomerId"];
        
        
        NSNumber *invoice = [NSNumber numberWithInt:self.invoiceId];
        
        [ tempDictionary setObject:invoice forKey:@"InvoiceId"];

        
        [ tempDictionary setObject:self.drinksInt forKey:@"Drinks"];
        [ tempDictionary setObject:self.foodInt forKey:@"Food"];
        [ tempDictionary setObject:self.priceInt forKey:@"Price"];
        [ tempDictionary setObject:self.serviceInt forKey:@"Service"];

        
		loginDict = tempDictionary;
        
		NSString *requestString = [NSString stringWithFormat:@"%@", [loginDict JSONFragment], nil];
        
        NSLog(@"RequestString: %@", requestString);
        
		NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        NSString *tmpUrl = [NSString stringWithString:@"http://68.57.205.193:8700/rest/v1/reviews"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:tmpUrl]];
        [request setHTTPMethod: @"POST"];
		[request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.serverData = [NSMutableData data];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate: self startImmediately: YES];
        
        
        
    }
    @catch (NSException *e) {
        
        //[rSkybox sendClientLog:@"getInvoiceFromNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
    
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)mdata {
    [self.serverData appendData:mdata]; 
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [self.activity stopAnimating];
    
    NSData *returnData = [NSData dataWithData:self.serverData];
    
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"ReturnString: %@", returnString);
    
    NewSBJSON *jsonParser = [NewSBJSON new];
    NSDictionary *response = (NSDictionary *) [jsonParser objectWithString:returnString error:NULL];
    
    BOOL success = [[response valueForKey:@"Success"] boolValue];
    
    if (success) {
        
        self.errorLabel.text = @"";
        
        Home *tmp = [[self.navigationController viewControllers] objectAtIndex:0];
        tmp.successReview = YES;
        [self.navigationController popToRootViewControllerAnimated:NO];

        
    }else{
        self.errorLabel.text = @"*Error submitting payment.";
    }
    
    
   	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    self.errorLabel.text = @"*Internet connection error.";
    [self.activity stopAnimating];
}



- (IBAction)skipReview:(id)sender {
    
    Home *tmp = [[self.navigationController viewControllers] objectAtIndex:0];
    tmp.skipReview = YES;
    [self.navigationController popToRootViewControllerAnimated:NO];

}
- (void)viewDidUnload {
    [self setErrorLabel:nil];
    [self setActivity:nil];
    [super viewDidUnload];
}
@end
