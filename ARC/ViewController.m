//
//  ViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "ViewController.h"
#import "HomeNavigationController.h"
#import "ArcAppDelegate.h"
#import "ArcClient.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"
#import "SteelfishBoldLabel.h"
#import "SteelfishInputText.h"
#import "NVUIGradientButton.h"
#import "MFSideMenu.h"
#import "HomeNavigationController.h"
#import "SteelfishLabel.h"

@interface ViewController ()

@end

@implementation ViewController

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated{


}
-(void)viewWillAppear:(BOOL)animated{
    @try {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInComplete:) name:@"signInNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noUsersFound:) name:@"noUsersFound" object:nil];
        
        
        [self.myTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
        self.errorLabel.text = @"";
        [self.username becomeFirstResponder];
        
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
        
  


    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewController.viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
        
}

-(void)noUsersFound:(NSNotification *)notification{
    [self performSegueWithIdentifier:@"goRegister" sender:self];
}

-(void)selectPassword{
    [self.password becomeFirstResponder];
}



-(void)goHomePage{
    
    /*
    
    
    UIViewController *leftSideMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftSide"];
    UIViewController *rightSideMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"rightSide"];
    
    UIViewController *tmp2 = [[UIViewController alloc] init];
    tmp2.view.frame = CGRectMake(0, 0, 320, 480);
    tmp2.view.backgroundColor = [UIColor purpleColor];
    
    UINavigationController *tmp = [[UINavigationController alloc] initWithRootViewController:tmp2];

    
    MFSideMenu *menu = [MFSideMenu menuWithNavigationController:tmp
                      leftSideMenuController:leftSideMenuViewController
                     rightSideMenuController:rightSideMenuViewController];
    
    
 
    

    
    [self presentModalViewController:menu.navigationController animated:NO];
     
    

    */
    
    
}



- (void)viewDidLoad
{
    @try {
        
        [rSkybox addEventToSession:@"viewViewController"];
        
        self.signInButton.text = @"Sign In";
        self.signInButton.textColor = [UIColor whiteColor];
        self.signInButton.textShadowColor = [UIColor darkGrayColor];
        self.signInButton.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0 blue:125.0/255.0 alpha:1];
        //self.signInButton.highlightedTintColor = [UIColor colorWithRed:(CGFloat)190/255 green:0 blue:0 alpha:1];
        
        
       // self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
      //  self.topLineView.layer.shadowRadius = 1;
      //  self.topLineView.layer.shadowOpacity = 0.2;
        self.topLineView.backgroundColor = dutchTopLineColor;
        self.backView.backgroundColor = dutchTopNavColor;

        
        
        
        
        
        self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
        self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        [self.loadingViewController stopSpin];
        [self.view addSubview:self.loadingViewController.view];
        
        
        SteelfishTitleLabel *navLabel = [[SteelfishTitleLabel alloc] initWithText:@"Sign In"];
        self.navigationItem.titleView = navLabel;
        
        SteelfishBarButtonItem *temp = [[SteelfishBarButtonItem alloc] initWithTitleText:@"Sign In"];
		self.navigationItem.backBarButtonItem = temp;
        


        
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        
        self.username = [[SteelfishInputText alloc] initWithFrame:CGRectMake(5, 7, 290, 24)];
        self.username.autocorrectionType = UITextAutocorrectionTypeNo;
        self.username.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.username.font = [UIFont fontWithName:FONT_REGULAR size:20];
        self.username.returnKeyType = UIReturnKeyNext;
        self.username.keyboardType = UIKeyboardTypeEmailAddress;
        [self.username addTarget:self action:@selector(selectPassword) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        self.password = [[SteelfishInputText alloc] initWithFrame:CGRectMake(5, 7, 290, 24)];
        self.password.autocorrectionType = UITextAutocorrectionTypeNo;
        self.password.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.password.secureTextEntry = YES;
        self.password.font = [UIFont fontWithName:FONT_REGULAR size:20];
        self.password.returnKeyType = UIReturnKeyGo;
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
    [self performSelector:@selector(runSignIn)];
    return NO;
}


-(void)signIn{

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
            fieldLabel.font = [UIFont fontWithName:FONT_BOLD size:15];
            fieldLabel.textAlignment = UITextAlignmentLeft;
            
            if (row == 0) {
                fieldLabel.text = @"Email";
                
                [cell.contentView addSubview:self.username];
                self.username.placeholder = @"Email Address";
                cell.isAccessibilityElement = YES;
                cell.accessibilityLabel = @"user name";
            }else if (row == 1){
                fieldLabel.text = @"Password";
                self.password.placeholder = @"Password";
                [cell.contentView addSubview:self.password];
                
                cell.isAccessibilityElement = YES;
                cell.accessibilityLabel = @"pass word";
            }
            
            [self.username becomeFirstResponder];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            fieldLabel.hidden = YES;
            
        }else{
            
            fieldLabel.frame = CGRectMake(0, 6, 298, 22);
            fieldLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
            fieldLabel.textAlignment = UITextAlignmentCenter;
            
            fieldLabel.text = @"How dutch Works";
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
    return 40;
}

-(void)runSignIn{
    self.errorLabel.text = @"";
    
    if ([self.username.text isEqualToString:@""] || [self.password.text isEqualToString:@""]) {
       // self.errorLabel.text = @"*Please enter your email and password.";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter your email and password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }else{
        @try {
            NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
            NSDictionary *loginDict = [[NSDictionary alloc] init];
            [ tempDictionary setObject:self.username.text forKey:@"userName"];
            [ tempDictionary setObject:self.password.text forKey:@"password"];
            
            [self.loadingViewController startSpin];
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
        
        [self.loadingViewController stopSpin];
        self.registerButton.enabled = YES;
        self.loginButton.enabled = YES;
        
        
        
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
            
            //[self goHomePage];
            [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"didJustLogin"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (self.isInsideApp) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully signed in." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self performSegueWithIdentifier: @"signIn" sender: self];

            }
           // [self performSelector:@selector(checkPayment) withObject:nil afterDelay:1.5];
            
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
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

- (IBAction)backAction {
    
    if (self.isInsideApp) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissModalViewControllerAnimated:YES];

    }
}
@end
