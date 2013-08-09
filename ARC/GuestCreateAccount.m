//
//  GuestCreateAccount.m
//  ARC
//
//  Created by Nick Wroblewski on 4/21/13.
//
//

#import "GuestCreateAccount.h"
#import "ArcClient.h"
#import "rSkybox.h"
#import "SteelfishInputText.h"
#import "ReviewTransaction.h"
#import "CreatePinView.h"
#import <QuartzCore/QuartzCore.h>

@interface GuestCreateAccount ()

@end

@implementation GuestCreateAccount

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInComplete:) name:@"signInNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateComplete:) name:@"updateGuestCustomerNotification" object:nil];

}
-(void)viewDidLoad{
    
    self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
    self.topLineView.layer.shadowRadius = 1;
    self.topLineView.layer.shadowOpacity = 0.2;
    self.topLineView.backgroundColor = dutchTopLineColor;
    self.backView.backgroundColor = dutchTopNavColor;
    
    
    self.backButton.hidden = YES;
    self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
    self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    [self.loadingViewController stopSpin];
    [self.view addSubview:self.loadingViewController.view];
    
    self.registerButton.textColor = [UIColor whiteColor];
    self.registerButton.text = @"Register";
    self.registerButton.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0 blue:125.0/255.0 alpha:1.0];
    
    self.noThanksButton.text = @"No Thanks";
    
    
    self.username = [[SteelfishInputText alloc] initWithFrame:CGRectMake(10, 11, 290, 20)];
    self.username.autocorrectionType = UITextAutocorrectionTypeNo;
    self.username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.username.font = [UIFont fontWithName:@"Steelfish" size:18];
    self.username.returnKeyType = UIReturnKeyNext;
    self.username.keyboardType = UIKeyboardTypeEmailAddress;
    [self.username addTarget:self action:@selector(selectPassword) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    self.password = [[SteelfishInputText alloc] initWithFrame:CGRectMake(10, 11, 290, 20)];
    self.password.autocorrectionType = UITextAutocorrectionTypeNo;
    self.password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.password.secureTextEntry = YES;
    self.password.font = [UIFont fontWithName:@"Steelfish" size:18];
    self.password.returnKeyType = UIReturnKeyGo;
    self.password.delegate = self;
    self.password.placeholder = @"Password";
    // [self.password addTarget:self action:@selector(signIn) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    self.username.text = @"";
    self.password.text = @"";
    
    self.username.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.password.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    
    [self.myTableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [self performSelector:@selector(registerAction)];
    return NO;
}

- (IBAction)noThanksAction {
    
    [self performSegueWithIdentifier:@"goReview" sender:nil];
}

- (IBAction)registerAction {
    
    self.errorLabel.text = @"";
    
    @try {
        if (self.isSignIn) {
            if ([self.username.text isEqualToString:@""] || [self.password.text isEqualToString:@""]) {
                self.errorLabel.text = @"*Please enter your email and password.";
            }else{
                NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
                NSDictionary *loginDict = [[NSDictionary alloc] init];
                [ tempDictionary setObject:self.username.text forKey:@"userName"];
                [ tempDictionary setObject:self.password.text forKey:@"password"];
                
                [self.loadingViewController startSpin];
                self.loadingViewController.displayText.text = @"Logging In...";
                
                self.registerButton.enabled = NO;
                self.noThanksButton.enabled = NO;
                
                loginDict = tempDictionary;
                ArcClient *client = [[ArcClient alloc] init];
                [client getCustomerToken:loginDict];
                
            }
            
        }else{
            if (![self validateEmail:self.username.text]) {
                self.errorLabel.text = @"Please enter a valid email address.";
            }else if ([self.password.text length] < 5){
                self.errorLabel.text = @"Password must be at least 5 characters.";
            }else{
                
                //Create new user, or Update User?
                
                
                self.loadingViewController.displayText.text = @"Creating...";
                [self.loadingViewController startSpin];
                
                NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
                
                
                
                
                [tempDictionary setValue:self.username.text forKey:@"eMail"];
                [tempDictionary setValue:self.password.text forKey:@"Password"];
                [tempDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"IsGuest"];
                
                
                NSDictionary *loginDict = [[NSDictionary alloc] init];
                loginDict = tempDictionary;
                
                self.registerButton.enabled = NO;
                self.noThanksButton.enabled = NO;
                
                ArcClient *tmp = [[ArcClient alloc] init];
                [tmp updateGuestCustomer:loginDict];
                
                
                
            }
            
        }

    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"GuestCreateAccount.registerAction" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
 
    
    
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}



-(void)selectPassword{
    [self.password becomeFirstResponder];
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
            
            SteelfishBoldLabel *fieldLabel = [[SteelfishBoldLabel alloc] initWithFrame:frame];
            fieldLabel.tag = fieldTag;
            [cell.contentView addSubview:fieldLabel];
            
            
        }
        
        SteelfishBoldLabel *fieldLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:fieldTag];
        
        fieldLabel.textColor = [UIColor blackColor];
        fieldLabel.backgroundColor = [UIColor clearColor];
        NSUInteger row = [indexPath row];
        NSUInteger section = [indexPath section];
        
        if (section == 0) {
            
            fieldLabel.frame = CGRectMake(10, 8, 80, 22);
            fieldLabel.font = [UIFont fontWithName:@"SteelfishEb-Regular" size:15];
            fieldLabel.textAlignment = UITextAlignmentLeft;
            
            if (row == 0) {
                fieldLabel.text = @"Email";
                
                [cell.contentView addSubview:self.username];
                self.username.placeholder = @"Email Address";
            }else if (row == 1){
                fieldLabel.text = @"Password";
                if (self.view.frame.size.height < 500) {
                    self.password.placeholder = @"Password (minimum 5 characters)";

                }else{
                    
                }
                [cell.contentView addSubview:self.password];
                
            }
            
            [self.username becomeFirstResponder];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            fieldLabel.hidden = YES;
            
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
        [rSkybox sendClientLog:@"GuestCreateAccount.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"goReview"]) {
            
            ReviewTransaction *next = [segue destinationViewController];
            next.myInvoice = self.myInvoice;
            next.isFromGuest = YES;
        }
        
    
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"GuestCreateAccount.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}




-(void)updateComplete:(NSNotification *)notification{
    @try {

        
        [self.loadingViewController stopSpin];
        
        self.registerButton.enabled = YES;
        self.noThanksButton.enabled = YES;
        
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        NSLog(@"ResponseInfo: %@", responseInfo);
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        BOOL isAlreadyRegistered = NO;
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            //NSDictionary *theInvoice = [[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"] objectAtIndex:0];
            
            
            NSString *newToken = [responseInfo valueForKey:@"Results"];
            
            
            NSLog(@"NewToken: %@", newToken);
            
            //Successful conversion from guest->customer
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Thank your for registering, email receipts will now be sent to your address.  Please create a PIN to securely encrypt your payment information." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *guestId = [prefs valueForKey:@"guestId"];
            //NSString *guestToken = [prefs valueForKey:@"guestToken"];
    
            
            ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
            [mainDelegate insertCustomerWithId:guestId andToken:newToken];
            
            
            //Convert Guest Id/Token to customer Id/Token
            
            [prefs setValue:self.username.text forKey:@"customerEmail"];
            [prefs setValue:guestId forKey:@"customerId"];
            [prefs setValue:newToken forKey:@"customerToken"];
            
            [prefs setValue:@"" forKey:@"guestId"];
            [prefs setValue:@"" forKey:@"guestToken"];
            
            [prefs synchronize];
            
            
            
            //Add the user to the database
            
          
            
            
            //Save the credit card information                        
    
            [self goPin];
            
            
           
            
            
            
        } else if([status isEqualToString:@"error"]){
            
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            
            if(errorCode == 103) {
                isAlreadyRegistered = YES;
            } else {
                errorMsg = @"Unable to register account, please try again.";
            }
            
            
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = @"Unable to register account, please try again.";
        }
        
        if (isAlreadyRegistered) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email In Use" message:@"The email address you entered is already being used.  If you already have an account, please sign in." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:@"Sign In", nil];
            [alert show];
        }else{
            if([errorMsg length] > 0) {
                self.errorLabel.text = errorMsg;
            }
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"GuestCreateAccount.invoiceComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



-(void)goPin{
    
    @try {
        
        CreatePinView *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"createPin"];
        
        NSString *creditDebitString = @"Credit";    
        
        tmp.creditDebitString = creditDebitString;
        tmp.expiration = self.ccExpiration;
        tmp.securityCode = self.ccSecurityCode;
        tmp.cardNumber = [self.ccNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        tmp.fromCreateGuest = YES;
        
        // determine what type of credit card this is
        
        // NSString *action = [NSString stringWithFormat:@"%@_CARD_ADD", creditDebitString];
        //[ArcClient trackEvent:action];
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController pushViewController:tmp animated:NO];
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"GuestCreateAccount.addCreditCard" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}




- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    self.errorLabel.text = @"";
    if (buttonIndex == 1) {
        self.titleLabel.text = @"Sign In";
        self.backButton.hidden = NO;
        self.minCharText.hidden = YES;
        self.createAccountText.hidden = YES;
        self.password.text = @"";
        self.registerButton.text = @"Sign In";
        self.isSignIn = YES;
    }
}
- (IBAction)goBack {
    
    self.errorLabel.text = @"";
    self.isSignIn = NO;
    self.titleLabel.text = @"Email Receipt?";
    self.backButton.hidden = YES;
    self.minCharText.hidden = NO;
    self.createAccountText.hidden = NO;
    self.registerButton.text = @"Register";

}


-(void)signInComplete:(NSNotification *)notification{
    @try {
        
        [self.loadingViewController stopSpin];
        self.registerButton.enabled = YES;
        self.noThanksButton.enabled = YES;
        
        
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
            
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"guestId"];
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"guestToken"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully signed in.  Please create a PIN to securely encrypt your payment information." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            
            [self goPin];

            
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
        [rSkybox sendClientLog:@"GuestCreateAccountg.signInComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
        
    }
    
}

@end
