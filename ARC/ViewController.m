//
//  ViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "ViewController.h"
#import "Home.h"
#import "HomeNavigationController.h"
#import "ArcAppDelegate.h"
#import "ArcClient.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"
#import "LucidaBoldLabel.h"
#import "CorbelTextField.h"
#import "SBJson.h"

@interface ViewController ()

@end

@implementation ViewController

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated{


}

-(void)keyboardWillShow:(id)sender{
    
    self.signInButton.hidden = NO;
}

-(void)keyboardWillHide:(id)sender{
    self.signInButton.hidden = YES;
}
-(void)viewWillAppear:(BOOL)animated{
    @try {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerComplete:) name:@"registerNotification" object:nil];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
        [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInComplete:) name:@"signInNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noUsersFound:) name:@"noUsersFound" object:nil];
        
        
        [self.myTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
        self.errorLabel.text = @"";
       // [self.username becomeFirstResponder];
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([mainDelegate.logout isEqualToString:@"true"]) {
            
            mainDelegate.logout = @"false";
            self.username.text = @"";
            self.password.text = @"";
            
        }

        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"resetPasswordSuccess"] isEqualToString:@"yes"]) {
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"resetPasswordSuccess"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your password has been reset successfully!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
        if(NSClassFromString(@"UIRefreshControl")) {
            self.isIos6 = YES;
        }else{
            self.isIos6 = NO;
        }
        
        if (self.isIos6) {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                self.facebookButton.hidden = NO;
            }else{
                self.facebookButton.hidden = YES;
            }
        }else{
            self.facebookButton.hidden = YES;
        }


    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewController.viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
        
}

-(void)noUsersFound:(NSNotification *)notification{
   // [self performSegueWithIdentifier:@"goRegister" sender:self];
}

-(void)newUser{
    [self performSegueWithIdentifier:@"goRegister" sender:self];
}
-(void)selectPassword{
    //[self.password becomeFirstResponder];
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
}

- (void)viewDidLoad
{
    @try {
        
        self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
        self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        self.loadingViewController.view.hidden = YES;
        [self.view addSubview:self.loadingViewController.view];
        
        NSLog(@"Height: %f", self.loadingViewController.view.frame.size.height);
        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Sign In"];
        self.navigationItem.titleView = navLabel;
        
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Cancel"];
		self.navigationItem.backBarButtonItem = temp;
        


        
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        
        self.username = [[CorbelTextField alloc] initWithFrame:CGRectMake(95, 10, 205, 20)];
        self.username.autocorrectionType = UITextAutocorrectionTypeNo;
        self.username.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.username.font = [UIFont fontWithName:@"LucidaGrande" size:14];
        self.username.returnKeyType = UIReturnKeyDone;
        self.username.keyboardType = UIKeyboardTypeEmailAddress;
        [self.username addTarget:self action:@selector(selectPassword) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        self.password = [[CorbelTextField alloc] initWithFrame:CGRectMake(95, 10, 205, 20)];
        self.password.autocorrectionType = UITextAutocorrectionTypeNo;
        self.password.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.password.secureTextEntry = YES;
        self.password.font = [UIFont fontWithName:@"LucidaGrande" size:14];
        self.password.returnKeyType = UIReturnKeyDone;
        self.password.delegate = self;
       // [self.password addTarget:self action:@selector(signIn) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        self.username.text = @"";
        self.password.text = @"";
        
        self.username.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.password.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        
        self.navBar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];
        [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
        
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.view.bounds;
        UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewController.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
    
}


- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    //[self performSelector:@selector(runSignIn)];
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    return NO;
}


-(void)signIn{
    NSLog(@"Height: %f", self.loadingViewController.view.frame.size.height);

    [self performSelector:@selector(runSignIn)];
   
   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	
    if (section == 0) {
        return 2;
    }
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    @try {
        static NSString *FirstLevelCell=@"FirstLevelCell";
        
        static NSInteger fieldTag = 1;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FirstLevelCell];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier: FirstLevelCell];
            
            CGRect frame;
            frame.origin.x = 10;
            frame.origin.y = 8;
            frame.size.height = 22;
            frame.size.width = 80;
            
            LucidaBoldLabel *fieldLabel = [[LucidaBoldLabel alloc] initWithFrame:frame];
            fieldLabel.tag = fieldTag;
            [cell.contentView addSubview:fieldLabel];
            
            
        }
        
        LucidaBoldLabel *fieldLabel = (LucidaBoldLabel *)[cell.contentView viewWithTag:fieldTag];
        
        fieldLabel.textColor = [UIColor blackColor];
        fieldLabel.backgroundColor = [UIColor clearColor];
        NSUInteger row = [indexPath row];
        NSUInteger section = [indexPath section];
        
        if (section == 0) {
            
            fieldLabel.frame = CGRectMake(10, 8, 80, 22);
            fieldLabel.font = [UIFont fontWithName:@"LucidaGrande-Bold" size:15];
            fieldLabel.textAlignment = UITextAlignmentLeft;
            
            if (row == 0) {
                fieldLabel.text = @"Email";
                
                [cell.contentView addSubview:self.username];
                
                cell.isAccessibilityElement = YES;
                cell.accessibilityLabel = @"user name";
            }else if (row == 1){
                fieldLabel.text = @"Password";
                [cell.contentView addSubview:self.password];
                
                cell.isAccessibilityElement = YES;
                cell.accessibilityLabel = @"pass word";
            }
            
           // [self.username becomeFirstResponder];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
        }else{
            
            fieldLabel.frame = CGRectMake(0, 6, 298, 22);
            fieldLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
            fieldLabel.textAlignment = UITextAlignmentCenter;
            
            fieldLabel.text = @"How Arc Works";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        return cell;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewController.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

-(void)runSignIn{
    self.errorLabel.text = @"";
    
    if ([self.username.text isEqualToString:@""] || [self.password.text isEqualToString:@""]) {
        self.errorLabel.text = @"*Please enter your email and password.";
    }else{
        @try {
            NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
            NSDictionary *loginDict = [[NSDictionary alloc] init];
            [ tempDictionary setObject:self.username.text forKey:@"userName"];
            [ tempDictionary setObject:self.password.text forKey:@"password"];
            
            self.loadingViewController.view.hidden = NO;
            self.loadingViewController.displayText.text = @"Logging In...";
            
            self.registerButton.enabled = NO;
            self.loginButton.enabled = NO;
            
            loginDict = tempDictionary;
            ArcClient *client = [[ArcClient alloc] init];
            [client getCustomerToken:loginDict];
        }
        @catch (NSException *e) {
            [rSkybox sendClientLog:@"viewController.runSignIn" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        }
    }

}


-(void)signInComplete:(NSNotification *)notification{
    @try {
        
        self.loadingViewController.view.hidden = YES;
        self.registerButton.enabled = YES;
        self.loginButton.enabled = YES;
        
        
        [rSkybox addEventToSession:@"signInComplete"];
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        //NSLog(@"Response Info: %@", responseInfo);
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
      
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            //success
            [[NSUserDefaults standardUserDefaults] setValue:self.username.text forKey:@"customerEmail"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            ArcClient *client = [[ArcClient alloc] init];
            [client getServer];
            
            ArcClient *tmp = [[ArcClient alloc] init];
            [tmp updatePushToken];
            
            //[self performSegueWithIdentifier: @"signIn" sender: self];
            
            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"didJustLogin"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
           // [self performSelector:@selector(checkPayment) withObject:nil afterDelay:1.5];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully signed in." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
            
            //Do the next thing (go home?)
        } else if([status isEqualToString:@"error"]){
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            if(errorCode == INCORRECT_LOGIN_INFO) {
                errorMsg = @"Invalid Email and/or Password";
            } else {
                // TODO -- programming error client/server coordination -- rskybox call
                errorMsg = ARC_ERROR_MSG;
            }
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if([errorMsg length] > 0) {
            self.errorLabel.text = errorMsg;
        }
    
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewController.signInComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    
        
    }
    
}

-(void)checkPayment{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    [mainDelegate doPaymentCheck];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([indexPath section] == 1) {
        //Go to "How it works"
        [self performSegueWithIdentifier:@"howItWorks" sender:self];
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 1) {
        if (self.view.frame.size.height > 500) {
            return 50;
        }else{
            return 25;
        }
    }
    return 0;
}

-(void)forgotPassword{
    [self performSegueWithIdentifier:@"forgotPassword" sender:self];
}


- (IBAction)facebookAction {
    
    self.store = [[ACAccountStore alloc] init];

    ACAccountType *accType = [self.store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"515025721859862", ACFacebookAppIdKey,
                                    [NSArray arrayWithObjects:@"email", nil], ACFacebookPermissionsKey, ACFacebookAudienceFriends, ACFacebookAudienceKey, nil];
    
    [self.store requestAccessToAccountsWithType:accType options:options completion:^(BOOL granted, NSError *error) {
        
        if (granted && error == nil) {
            // NSLog(@"Granted");
            NSURL* URL = [NSURL URLWithString:@"https://graph.facebook.com/me"];
            
            SLRequest* request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                    requestMethod:SLRequestMethodGET
                                                              URL:URL
                                                       parameters:nil];
    
            NSArray *accounts = [self.store accountsWithAccountType:accType];
            ACAccount *facebookAccount = [accounts objectAtIndex:0];
        
            [request setAccount:facebookAccount]; // Authentication - Requires user context
            
            [request performRequestWithHandler:^(NSData* responseData, NSHTTPURLResponse* urlResponse, NSError* error) {
                // parse the response or handle the error
                
                /*
                 sample response -
                 
                 {
                 "id": "100004384750110",
                 "name": "Nick Wroble",
                 "first_name": "Nick",
                 "last_name": "Wroble",
                 "link": "http://www.facebook.com/nick.wroble.9",
                 "username": "nick.wroble.9",
                 "birthday": "08/01/1984",
                 "gender": "male",
                 "email": "nick@rteam.com",
                 "timezone": -6,
                 "locale": "en_US",
                 "verified": true,
                 "updated_time": "2012-12-03T01:30:43+0000"
                 }
                 
                 */
                NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
                if (output) {
                    
                }
                NSString *dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                NSLog(@"Output: %@", output);
                NSLog(@"Error: %@", error);
                NSLog(@"Output: %@", dataString);
                
                if ([output isEqualToString:@"HTTP response status: 200"]) {
                    [self facebookSuccess:dataString];
                }
                
                if ([output isEqualToString:@"HTTP response status: 400"]) {
                    
                    NSArray *accounts = [self.store accountsWithAccountType:accType];
                    ACAccount *facebookAccount = [accounts objectAtIndex:0];
                    
                    [self.store renewCredentialsForAccount:facebookAccount completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                        
                        if (renewResult == ACAccountCredentialRenewResultRenewed ) {
                            [self facebookAction];
                        }
                    }];
                    
                }
                
                
                
            }];
            
            
        } else {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                
            });
            
       
        }
    }];
    
    
    
}

-(void)facebookSuccess:(NSString *)output{
    

    NSLog(@"OutPut: %@", output);
    
    
    SBJsonParser *jsonParser = [SBJsonParser new];
    NSDictionary *response = (NSDictionary *) [jsonParser objectWithString:output error:NULL];
    
    NSString *firstName = [response valueForKey:@"first_name"];
    NSString *lastName = [response valueForKey:@"last_name"];
    NSString *emailAddress = [response valueForKey:@"email"];
    NSString *facebookId = [response valueForKey:@"id"];
    
    
    //Create the user
    
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
    NSDictionary *loginDict = [[NSDictionary alloc] init];
    
    [ tempDictionary setObject:firstName forKey:@"FirstName"];
    [ tempDictionary setObject:lastName forKey:@"LastName"];
    [ tempDictionary setObject:emailAddress forKey:@"eMail"];
    [ tempDictionary setObject:facebookId forKey:@"Password"];
    [ tempDictionary setObject:facebookId forKey:@"FacebookId"];
    [ tempDictionary setObject:@"Phone" forKey:@"Source"];
    
    
    //[ tempDictionary setObject:genderString forKey:@"Gender"];
    
    // TODO hard coded for now
    [ tempDictionary setObject:@"123" forKey:@"PassPhrase"];
    
    
    
    //[ tempDictionary setObject:birthDayString forKey:@"BirthDate"];
    [ tempDictionary setObject:@(YES) forKey:@"AcceptTerms"];
    [ tempDictionary setObject:@(YES) forKey:@"Notifications"];
    [ tempDictionary setObject:@(NO) forKey:@"Facebook"];
    [ tempDictionary setObject:@(NO) forKey:@"Twitter"];
    
    loginDict = tempDictionary;
    ArcClient *client = [[ArcClient alloc] init];
    [client createCustomer:loginDict];

    
    
}


-(void)registerComplete:(NSNotification *)notification{
    //@try {
        
    NSLog(@"Notification: %@", notification);
    NSLog(@"Test");
        /*
        self.loadingViewController.view.hidden = YES;
        self.loginButton.enabled = YES;
        self.registerButton.enabled = YES;
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *status = [responseInfo valueForKey:@"status"];
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            [[NSUserDefaults standardUserDefaults] setValue:self.emailText.text forKey:@"customerEmail"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            ArcClient *client = [[ArcClient alloc] init];
            [client getServer];
            
            self.registerSuccess = YES;
            
            //Save credit card info
            [self performSelector:@selector(addCreditCard) withObject:nil afterDelay:0.0];
            
            
        } else if([status isEqualToString:@"error"]){
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            if(errorCode == USER_ALREADY_EXISTS) {
                errorMsg = @"Email Address already used.";
            } else {
                errorMsg = ARC_ERROR_MSG;
            }
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if([errorMsg length] > 0) {
            //self.activityView.hidden = NO;
            //self.errorLabel.hidden = NO;
            //self.errorLabel.text = errorMsg;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            self.registerSuccess = NO;
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewController.registerComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
         */
        
    
}


@end
