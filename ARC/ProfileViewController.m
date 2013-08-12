//
//  ProfileViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 3/27/13.
//
//

#import "ProfileViewController.h"
#import "rSkybox.h"
#import "MFSideMenu.h"
#import "ArcAppDelegate.h"
#import "ViewController.h"
#import "RegisterViewNew.h"
#import <QuartzCore/QuartzCore.h>
#import "ArcClient.h"
#import "ArcIdentifier.h"
#import <FacebookSDK/FacebookSDK.h>

@interface ProfileViewController ()

@end

@implementation ProfileViewController

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInComplete:) name:@"signInNotificationGuest" object:nil];

    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] > 0) {
        self.isLoggedIn = YES;
    }
    self.createAccountButton.text = @"Create";
    self.logInButton.text = @"Log In";
    self.signOutButton.text = @"Sign Out";
    
    if (self.isLoggedIn) {
        
        self.newProfileText.hidden = YES;
        self.logInButton.hidden = YES;
        self.facebookLoginView.hidden = YES;
        self.createAccountButton.hidden = YES;
        
        
        self.myTableView.hidden = NO;
        self.signOutButton.hidden = NO;
        
    }else{
        
        self.newProfileText.hidden = NO;
        self.logInButton.hidden = NO;
        self.facebookLoginView.hidden = NO;

        self.createAccountButton.hidden = NO;
        
        self.myTableView.hidden = YES;
        self.signOutButton.hidden = YES;
    }
    
    ArcClient *tmp = [[ArcClient alloc] init];
    if (![tmp admin]) {
        self.viewChangeServerButton.hidden = YES;
    }else{
        self.viewChangeServerButton.hidden = NO;
    }
    
    [self.myTableView reloadData];
}
-(void)viewDidLoad{
    
    
    self.viewChangeServerButton.text = @"View/Change Dutch Server";
 
    
    
    self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
    self.topLineView.layer.shadowRadius = 1;
    self.topLineView.layer.shadowOpacity = 0.2;
    self.topLineView.backgroundColor = dutchTopLineColor;
    self.backView.backgroundColor = dutchTopNavColor;
    
    
    self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
    self.loadingViewController.view.frame = CGRectMake(0, 30, 320, self.view.frame.size.height + 100);
    self.loadingViewController.view.hidden = YES;
    [self.view addSubview:self.loadingViewController.view];
  
}

-(void)endText{
    
}

- (IBAction)signOutAction{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    
    NSString *guestId = [prefs stringForKey:@"guestId"];
    NSString *guestToken = [prefs stringForKey:@"guestToken"];
    
    if (![guestId isEqualToString:@""] && (guestId != nil) && ![guestToken isEqualToString:@""] && (guestToken != nil)) {
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        mainDelegate.logout = @"true";
        [self.navigationController popToRootViewControllerAnimated:NO];
        
    }else{
        //Get the Guest Token, then push to InitHelpPage        
        NSString *identifier = [ArcIdentifier getArcIdentifier];
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
        NSDictionary *loginDict = [[NSDictionary alloc] init];
        [ tempDictionary setObject:identifier forKey:@"userName"];
        [ tempDictionary setObject:identifier forKey:@"password"];
        
        loginDict = tempDictionary;
        ArcClient *client = [[ArcClient alloc] init];
        
        self.loadingViewController.view.hidden = NO;
        self.loadingViewController.displayText.text = @"Logging Out";
        [client getGuestToken:loginDict];
        
    }
    
    
   
}
- (IBAction)logInAction{
    
    ViewController *signIn = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInPage"];
    signIn.isInsideApp = YES;
    [self.navigationController pushViewController:signIn animated:YES];
}
- (IBAction)createAction{
    RegisterViewNew *signIn = [self.storyboard instantiateViewControllerWithIdentifier:@"registerPage"];
    signIn.isInsideApp = YES;
    [self.navigationController pushViewController:signIn animated:YES];
}

-(void)openMenuAction{
    [self.navigationController.sideMenu toggleLeftSideMenu];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    @try {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell"];
        
    
        UITextField *textField = (UITextField *)[cell.contentView viewWithTag:1];
     
        
 
            
            if (indexPath.row == 0) {
                textField.placeholder = @"Email Address";
                self.emailTextField = textField;
                [self.emailTextField addTarget:self action:@selector(endText) forControlEvents:UIControlEventEditingDidEndOnExit];
                
                if (self.isLoggedIn) {
                    self.emailTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"];

                }
                
            }else{
                textField.placeholder = @"Password";
                self.passwordTextField = textField;
                [self.passwordTextField setSecureTextEntry:YES];
                [self.passwordTextField addTarget:self action:@selector(endText) forControlEvents:UIControlEventEditingDidEndOnExit];
                
                if (self.isLoggedIn) {
                    self.passwordTextField.text = @"password";
                    self.passwordTextField.enabled = NO;
                }

            }
        
          
            
      
        
        return cell;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ProfileViewController.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}




- (IBAction)viewChangeServerAction {
    
    UIViewController *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"editServer"];
    [self.navigationController pushViewController:tmp animated:YES];
}
- (IBAction)facebookConnectAction {
}



//Facebook

#pragma mark - FBLoginView delegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    // Upon login, transition to the main UI by pushing it onto the navigation stack.
    
    
    NSLog(@"Logged In to FACEBOOK!");
}

- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error{
    NSString *alertMessage, *alertTitle;
    
    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // Since this sample uses the FBLoginView, this delegate will respond to
    // login failures, or other failures that have closed the session (such
    // as a token becoming invalid). Please see the [- postOpenGraphAction:]
    // and [- requestPermissionAndPost] on `SCViewController` for further
    // error handling on other operations.
    
    if (error.fberrorShouldNotifyUser) {
        // If the SDK has a message for the user, surface it. This conveniently
        // handles cases like password change or iOS6 app slider state.
        alertTitle = @"Something Went Wrong";
        alertMessage = error.fberrorUserMessage;
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        // It is important to handle session closures as mentioned. You can inspect
        // the error for more context but this sample generically notifies the user.
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        NSLog(@"user cancelled login");
    } else {
        // For simplicity, this sample treats other errors blindly, but you should
        // refer to https://developers.facebook.com/docs/technical-guides/iossdk/errors/ for more information.
        alertTitle  = @"Unknown Error";
        alertMessage = @"Error. Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    // Facebook SDK * login flow *
    // It is important to always handle session closure because it can happen
    // externally; for example, if the current session's access token becomes
    // invalid. For this sample, we simply pop back to the landing page.
    
    /*
    SCAppDelegate *appDelegate = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.isNavigating) {
        // The delay is for the edge case where a session is immediately closed after
        // logging in and our navigation controller is still animating a push.
        [self performSelector:@selector(logOut) withObject:nil afterDelay:.5];
    } else {
        [self logOut];
    }
     */
}



-(void)signInComplete:(NSNotification *)notification{
    @try {
        
        
        self.loadingViewController.view.hidden = YES;
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        // NSLog(@"Response Info: %@", responseInfo);
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            //success
            
            ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
            mainDelegate.logout = @"true";
            [self.navigationController popToRootViewControllerAnimated:NO];
           
            
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
            //self.errorLabel.text = errorMsg;
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading Error" message:@"We experienced an error loading your guest account, please try again!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InitialHelpPageVC.signInComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
        
    }
    
}




@end
