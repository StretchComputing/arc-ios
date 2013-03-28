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

@interface ProfileViewController ()

@end

@implementation ProfileViewController

-(void)viewWillAppear:(BOOL)animated{
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] > 0) {
        self.isLoggedIn = YES;
    }
    self.createAccountButton.text = @"Create";
    self.logInButton.text = @"Log In";
    self.signOutButton.text = @"Sign Out";
    
    if (self.isLoggedIn) {
        
        self.newProfileText.hidden = YES;
        self.logInButton.hidden = YES;
        self.createAccountButton.hidden = YES;
        
        
        self.myTableView.hidden = NO;
        self.signOutButton.hidden = NO;
        
    }else{
        
        self.newProfileText.hidden = NO;
        self.logInButton.hidden = NO;
        self.createAccountButton.hidden = NO;
        
        self.myTableView.hidden = YES;
        self.signOutButton.hidden = YES;
    }
    
    [self.myTableView reloadData];
}
-(void)viewDidLoad{
    
    self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
    self.topLineView.layer.shadowRadius = 1;
    self.topLineView.layer.shadowOpacity = 0.5;
    
    self.backView.layer.cornerRadius = 7.0;
    
  
}

-(void)endText{
    
}

- (IBAction)signOutAction{
    
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.logout = @"true";
    [self.navigationController popToRootViewControllerAnimated:NO];
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



- (void)viewDidUnload {
    [self setBackView:nil];
    [self setTopLineView:nil];
    [super viewDidUnload];
}
@end
