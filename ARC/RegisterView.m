//
//  RegisterView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RegisterView.h"
#import "NewJSON.h"
#import "ArcAppDelegate.h"
@interface RegisterView ()

-(void)runRegister;

@end

@implementation RegisterView
@synthesize errorLabel;
@synthesize firstNameText;
@synthesize lastNameText;
@synthesize emailText;
@synthesize passwordText;
@synthesize genderSegment;
@synthesize activityView;
@synthesize serverData, dwollaSuccess, registerSuccess, fromDwolla;

-(void)viewDidAppear:(BOOL)animated{
    
    ArcAppDelegate *mainDelegate = [[UIApplication sharedApplication] delegate];
    if ([mainDelegate.logout isEqualToString:@"true"]) {
        [self.navigationController dismissModalViewControllerAnimated:NO];
    }
    
    
    if (self.fromDwolla) {
        self.fromDwolla = NO;
        if (self.dwollaSuccess) {
            if (self.registerSuccess) {
                self.dwollaSuccess = NO;
                self.registerSuccess = NO;
                [self goHome];
            }else{
                self.activityView.hidden = NO;
                CGPoint top = CGPointMake(0, -13);
                [self.tableView setContentOffset:top animated:YES];
            }
        }else{
            self.activityView.hidden = NO;
            CGPoint top = CGPointMake(0, -13);
            [self.tableView setContentOffset:top animated:YES];
            self.errorLabel.text = @"Failed to confirm Dwolla credentials.";
        }
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
   
    
}
- (void)viewDidLoad
{
    self.firstNameText.text = @"";
    self.lastNameText.text = @"";
    self.emailText.text = @"";
    self.passwordText.text = @"";
    
    self.activityView.hidden = YES;
    self.serverData = [NSMutableData data];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
 
}




- (IBAction)login:(UIBarButtonItem *)sender {
    
 
    [self.navigationController dismissModalViewControllerAnimated:YES];

}

- (IBAction)registerNow:(id)sender {
    
    
    if ([self.firstNameText.text isEqualToString:@""] || [self.lastNameText.text isEqualToString:@""] || [self.emailText.text isEqualToString:@""] || [self.passwordText.text isEqualToString:@""]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Field" message:@"Name, Email, and Password are required fields" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
    }else{
        
        self.activityView.hidden = NO;
        CGPoint top = CGPointMake(0, -13);
        [self.tableView setContentOffset:top animated:YES];
        
        self.errorLabel.hidden = YES;
        [self runRegister];
    }
    
    
    

    
}

-(void)runRegister{
    
    @try{
      
        [self.firstNameText resignFirstResponder];
        [self.lastNameText resignFirstResponder];
        [self.emailText resignFirstResponder];
        [self.passwordText resignFirstResponder];
 
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
		NSDictionary *loginDict = [[NSDictionary alloc] init];
        
		[ tempDictionary setObject:self.firstNameText.text forKey:@"FirstName"];
		[ tempDictionary setObject:self.lastNameText.text forKey:@"LastName"];
		[ tempDictionary setObject:self.emailText.text forKey:@"eMail"];
		[ tempDictionary setObject:self.passwordText.text forKey:@"Password"];
        [ tempDictionary setObject:@"1955-05-10" forKey:@"BirthDate"];


        NSNumber *boolAccept = [NSNumber numberWithBool:YES];
        [ tempDictionary setObject:boolAccept forKey:@"AcceptTerms"];

        
        NSString *genderString = @"";
        if (self.genderSegment.selectedSegmentIndex == 0) {
            genderString = @"M";
        }else{
            genderString = @"F";
        }
        
        [ tempDictionary setObject:genderString forKey:@"Gender"];

                
		loginDict = tempDictionary;
        
		NSString *requestString = [NSString stringWithFormat:@"%@", [loginDict JSONFragment], nil];
                        
		NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        NSString *tmpUrl = [NSString stringWithString:@"http://68.57.205.193:8700/rest/v1/customers"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:tmpUrl]];
        [request setHTTPMethod: @"POST"];
		[request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.serverData = [NSMutableData data];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate: self startImmediately: YES];
         
        [self performSegueWithIdentifier:@"confirmDwolla" sender:self];

                
    }
    @catch (NSException *e) {
        
        //[rSkybox sendClientLog:@"getInvoiceFromNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
    
    
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)mdata {
    [self.serverData appendData:mdata]; 
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSData *returnData = [NSData dataWithData:self.serverData];
    
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
              
    NewSBJSON *jsonParser = [NewSBJSON new];
    NSDictionary *response = (NSDictionary *) [jsonParser objectWithString:returnString error:NULL];
    
    BOOL success = [[response valueForKey:@"Success"] boolValue];
    
    if (success){
        
        //self.activityView.hidden = YES;
        CGPoint top = CGPointMake(0, 40);
        [self.tableView setContentOffset:top animated:YES];
        
        NSDictionary *customer = [response valueForKey:@"Customer"];
        
        NSString *customerId = [customer valueForKey:@"Id"];
        NSString *customerToken = [customer valueForKey:@"Token"];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        [prefs setObject:customerId forKey:@"customerId"];
        [prefs setObject:customerToken forKey:@"customerToken"];
       
        [prefs synchronize];
        
        
        self.registerSuccess = YES;
        
    }else{
        
        self.activityView.hidden = NO;
        self.errorLabel.hidden = NO;
        self.errorLabel.text = @"*Error registering, please try again.";
        self.registerSuccess = NO;
    }
    
   
   	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    self.activityView.hidden = NO;
    self.errorLabel.hidden = NO;
    self.errorLabel.text = @"*Error registering, please try again.";
    self.registerSuccess = NO;
}






-(void)goHome{
    [self performSegueWithIdentifier:@"registerHome" sender:self];
    

}



-(void)endText{
    
}

@end
