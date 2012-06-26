//
//  RegisterView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RegisterView.h"
#import "NewJSON.h"

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
@synthesize dwollaView, authEngine, serverData;


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
    
    /*
    self.authEngine = [DwollaOAuthEngine 
                  engineWithConsumerKey:@"KEY" 
                  consumerSecret:@"SECRET"
                  scope: @"AccountAPI:AccountInfoFull|AccountAPI:Send|AccountAPI:Contacts|AccountAPI:Transactions|AccountAPI:Balance"
                  callback: @"http://www.google.com/" //Needs 'http://' and also trailing '/'
                  delegate:self];  
    
    
    self.dwollaView = [DwollaAuthorizationController authorizationControllerWithEngine:self.authEngine delegate:self];
    if( self.dwollaView ) {
        [self presentModalViewController:self.dwollaView animated:YES];
    }*/
    
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
        
        NSString *tmpUrl = [NSString stringWithString:@"https://68.57.205.193:8700/rest/v1/customers"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:tmpUrl]];
        [request setHTTPMethod: @"POST"];
		[request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        
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
    
    NSData *returnData = [NSData dataWithData:self.serverData];
    
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
          
    
    NewSBJSON *jsonParser = [NewSBJSON new];
    NSDictionary *response = (NSDictionary *) [jsonParser objectWithString:returnString error:NULL];
    
    BOOL success = [[response valueForKey:@"Success"] boolValue];
    
    success = NO;
    if (success){
        
        self.activityView.hidden = YES;
        CGPoint top = CGPointMake(0, 40);
        [self.tableView setContentOffset:top animated:YES];
        
        //Do the next thing (go home?)
        
    }else{
        
        self.activityView.hidden = NO;
        self.errorLabel.hidden = NO;
        self.errorLabel.text = @"*Error registering, please try again.";
        
    }
    
   
   	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    self.activityView.hidden = NO;
    self.errorLabel.hidden = NO;
    self.errorLabel.text = @"*Error registering, please try again.";
}


//Dwolla Delegates

//Is called  the AccessToken for storing. Tokens can store themselves with "storeInUserDefaultsWithServiceProviderName:prefix:"
- (void)dwollaEngineAccessToken:(DwollaOAuthEngine *)engine setAccessToken:(DwollaToken *)token{
    
    NSLog(@"Dwolla - 1");
}

//Is called when the DwollaEngine needs the AccessToken out of the data store. Tokens can be recalled with: "initWithUserDefaultsUsingServiceProviderName:prefix:"
- (OAToken *)dwollaEngineAccessToken:(DwollaOAuthEngine *)engine{
    
    NSLog(@"Dwolla - 2");

    OAToken *tmp;
    
    return tmp;
}

//Is called  results from OAuth REST calls. 'results' returns as an NSDictionary with the same structure as the JSON returned from Dwolla.
- (void)dwollaEngine:(DwollaOAuthEngine *)engine requestSucceeded:(DwollaConnectionID *)identifier withResults:(id)results{
    NSLog(@"Dwolla - 3");

}

//Is called  the error to you if a problem occured with a Rest call within the Engine.
- (void)dwollaEngine:(DwollaOAuthEngine *)engine requestFailed:(DwollaConnectionID *)identifier withError:(NSError *)error{
    
    NSLog(@"Dwolla - 4");

}

//Is called if the user is successfully Authorized.
- (void)dwollaAuthorizationControllerSucceeded:(DwollaAuthorizationController *)controller{
    
    NSLog(@"Dwolla - 5");

}

//Is called if the user's authroization Fails.
- (void)dwollaAuthorizationControllerFailed:(DwollaAuthorizationController *)controller{
    
    NSLog(@"Dwolla - 6");

}

//Is called if the user cancels the Authorization.
- (void)dwollaAuthorizationControllerCanceled:(DwollaAuthorizationController *)controller{
    
    NSLog(@"Dwolla - 7");

}


-(void)endText{
    
}
- (void)viewDidUnload {
    [self setFirstNameText:nil];
    [self setLastNameText:nil];
    [self setEmailText:nil];
    [self setPasswordText:nil];
    [self setGenderSegment:nil];
    [self setActivityView:nil];
    [self setErrorLabel:nil];
    [super viewDidUnload];
}
@end
