//
//  RegisterView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/25/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "RegisterViewNew.h"
#import "ArcAppDelegate.h"
#import "RegisterDwollaView.h"
#import <QuartzCore/QuartzCore.h>
#import "FBEncryptorAES.h"
#import "ArcClient.h"
#import "rSkybox.h"
#import "NSString+CharArray.h"
#import "CreatePinView.h"
#import "PrivacyTermsViewController.h"
#import "CorbelBarButtonItem.h"

@interface RegisterViewNew ()


@end

@implementation RegisterViewNew

-(void)viewWillDisappear:(BOOL)animated{
    
    @try {
        self.scrollViewOffset = self.myScrollView.contentOffset;
        
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterView.viewWillDisappear" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
}
-(void)viewWillAppear:(BOOL)animated{

    @try {
        
        [ArcClient trackEvent:@"TEST_REG_NO_AUTH"];

        
        [self.myScrollView setContentOffset:self.scrollViewOffset animated:NO];
        
        
        self.errorLabel.text = @"";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerComplete:) name:@"registerNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backspaceHit) name:@"backspaceNotification" object:nil];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterView.viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    @try {
        
        if (!self.didFirstRun) {
            self.didFirstRun = YES;
            [self.emailText becomeFirstResponder];
        }else{
            [self.creditCardNumberText becomeFirstResponder];
        }

        
     
        
        
        if (self.fromCreditCard) {
            self.fromCreditCard = NO;
            [self goHome];
        }
        
        
        ArcAppDelegate *mainDelegate = [[UIApplication sharedApplication] delegate];
        if ([mainDelegate.logout isEqualToString:@"true"]) {
            [self.navigationController dismissModalViewControllerAnimated:NO];
        }
        
                
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.viewDidAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (void)viewDidLoad
{
    @try {
        
        if(NSClassFromString(@"UIRefreshControl")) {
            self.isIos6 = YES;
        }else{
            self.isIos6 = NO;
        }
       
        self.pageNumber = 1;
        [rSkybox addEventToSession:@"viewRegisterScreen"];
    
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Back"];
		self.navigationItem.backBarButtonItem = temp;
        
        
        self.myScrollView.contentSize = CGSizeMake(640, 504);
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        
        self.myTableViewTwo.delegate = self;
        self.myTableViewTwo.dataSource = self;
        
        self.myTableViewThree.delegate = self;
        self.myTableViewThree.dataSource = self;

 
        
        self.navigationItem.rightBarButtonItem = nil;
   
        self.emailText.text = @"";
        self.passwordText.text = @"";
     
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
       
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.view.bounds;
        self.view.backgroundColor = [UIColor clearColor];
        //UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
        double x = 1.0;
        UIColor *myColor = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];
        
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
        
        [self.myTableView reloadData];
        [self.myTableViewTwo reloadData];
        [self.myTableViewThree reloadData];

        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Create Account"];
        self.navigationItem.titleView = navLabel;
                
        if (self.view.frame.size.height > 500) {
            self.isIphone5 = YES;
        }else{
            self.isIphone5 = NO;
        }
        
        [self.loginButton setTitle:@"Login"];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (IBAction)login:(UIBarButtonItem *)sender {
    @try {
        
        if (self.pageNumber > 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cancel Registration?" message:@"Are you sure you want to cancel? Your registration information will be lost." delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
            [alert show];
        }else{
            [self.navigationController dismissModalViewControllerAnimated:YES];
        }
      
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.login" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 0) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}


-(BOOL)isValidEntries{
    
    
    @try {
        

        if (self.pageNumber == 1) {
            if (([self.emailText.text length] > 0) && ([self.passwordText.text length] >=5)) {
                return YES;
            }else{
                return NO;
            }
        }else if (self.pageNumber == 2){
            if (([self.firstNameText.text length] > 0) && ([self.lastNameText.text length] > 0)) {
                return YES;
            }else{
                return NO;
            }
        }else if (self.pageNumber == 3){
            
        }
        
        return NO;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.isValidEntries" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return NO;

    }
    
   
}


- (IBAction)goNext {
    
    @try {
        if (self.pageNumber == 1) {
            
            if ([self isValidEntries]){
                
                [UIView animateWithDuration:0.4 animations:^{
                    [self.myScrollView setContentOffset:CGPointMake(320, 0) animated:NO];
                }];
                
                [self hideDoneButton];
                self.pageNumber = 2;
                self.errorLabel.text = @"";
                CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Create Profile"];
                self.navigationItem.titleView = navLabel;
                [self.firstNameText becomeFirstResponder];
                [self.loginButton setTitle:@"Cancel"];

            }else{
                self.errorLabel.text = @"Please enter all fields.";
            }
            
        }else if (self.pageNumber == 2){
            if ([self isValidEntries]){
                
                [UIView animateWithDuration:0.4 animations:^{
                    [self.myScrollView setContentOffset:CGPointMake(640, 0) animated:NO];
                }];
                
                [self hideDoneButton];
                self.pageNumber = 3;
                self.errorLabel.text = @"";
                CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Add A Card"];
                self.navigationItem.titleView = navLabel;
                
                self.registerButton = [[CorbelBarButtonItem alloc] initWithTitleText:@"Submit"];
                [self.registerButton setTarget:self];
                [self.registerButton setAction:@selector(registerNow:)];
                
                self.registerButton.tintColor = [UIColor blueColor];
                
                self.navigationItem.rightBarButtonItem = self.registerButton;
                
                
                [self.creditCardNumberText becomeFirstResponder];
                [self.loginButton setTitle:@"Cancel"];

            }else{
                self.errorLabel.text = @"Please enter all fields.";
            }
        }else{
            
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterView.goNext" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
  
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        @try {
            
            if ([[segue identifier] isEqualToString:@"confirmDwolla"]) {
                
                RegisterDwollaView *detailViewController = [segue destinationViewController];
                detailViewController.fromRegister = YES;
            }
            
            if ([[segue identifier] isEqualToString:@"goPrivacy"]) {
                
                UINavigationController *tmp = [segue destinationViewController];
                PrivacyTermsViewController *detailViewController = [[tmp viewControllers] objectAtIndex:0];
                detailViewController.isPrivacy = YES;
                [self.creditCardNumberText resignFirstResponder];
                
            }
            
            if ([[segue identifier] isEqualToString:@"goTerms"]) {
                
                UINavigationController *tmp = [segue destinationViewController];
                PrivacyTermsViewController *detailViewController = [[tmp viewControllers] objectAtIndex:0];
                detailViewController.isPrivacy = NO;
                [self.creditCardNumberText resignFirstResponder];

            }
        }
        @catch (NSException *e) {
            [rSkybox sendClientLog:@"Register3View.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        }
        
      
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {

        if (tableView == self.myTableView) {
            
            NSUInteger row = [indexPath row];
            
            
            UITableViewCell *cell;
            
            if (row == 0){
                
                cell = [tableView dequeueReusableCellWithIdentifier:@"emailCell"];
                
            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:@"passwordCell"];
                
            }
            
            
            if (row == 0) {
                self.emailText = (UITextField *)[cell.contentView viewWithTag:1];
                self.emailText.placeholder = @"Email Address";
                self.emailText.delegate = self;
                
                //[self.emailText addTarget:self action:@selector(editBegin:) forControlEvents:UIControlEventEditingDidBegin];
            }else if (row == 1){
                
                self.passwordText = (UITextField *)[cell.contentView viewWithTag:1];
                self.passwordText.placeholder = @"Choose A Password";
                //[self.passwordText addTarget:self action:@selector(editBeginPassword) forControlEvents:UIControlEventEditingDidBegin];
                self.passwordText.delegate = self;
                
                //[self.passwordText addTarget:self action:@selector(editBegin:) forControlEvents:UIControlEventEditingDidBegin];
                
            }
            
            
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;

            
        }else if (tableView == self.myTableViewTwo){
            NSUInteger row = [indexPath row];
            
            
            UITableViewCell *cell;
            
            if (row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"firstNameCell"];
                
            }else if (row == 1){
                cell = [tableView dequeueReusableCellWithIdentifier:@"lastNameCell"];
                
            }
            
            
            if (row == 0) {
                
                self.firstNameText = (UITextField *)[cell.contentView viewWithTag:1];
                self.firstNameText.placeholder = @"First Name";
                self.firstNameText.delegate = self;
            }else if (row == 1){
                self.lastNameText = (UITextField *)[cell.contentView viewWithTag:1];
                self.lastNameText.placeholder = @"Last Name";
                self.lastNameText.delegate = self;
                
                
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;

        }else if (tableView == self.myTableViewThree){
            NSUInteger row = [indexPath row];
            
            
            UITableViewCell *cell;
            
            if (row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"cardNumberCell"];
                
            }else if (row == 1){
                cell = [tableView dequeueReusableCellWithIdentifier:@"securityCodeCell"];
                
            }
            
            
            if (row == 0) {
                self.creditCardNumberText = (UITextField *)[cell.contentView viewWithTag:1];
                self.creditCardNumberText.placeholder = @"1234 5678 9102 3456";
                self.creditCardNumberText.delegate = self;
                
                
                [self.creditCardNumberText addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
                
            }else if (row == 1){
                self.expirationText = (UITextField *)[cell.contentView viewWithTag:1];
                self.expirationText.placeholder = @"MM/YY";
                self.expirationText.delegate = self;
                
                [self.expirationText addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
                
                
                self.creditCardSecurityCodeText = (UITextField *)[cell.contentView viewWithTag:2];
                self.creditCardSecurityCodeText.placeholder = @"CVV";
                self.creditCardSecurityCodeText.delegate = self;
                
                
                
            }
            
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;

        }
               
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterNew.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
 
    return 44;
}


 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
    

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
  
}




- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    self.errorLabel.text = @"";

    [self performSelector:@selector(checkValid) withObject:nil afterDelay:0.2];

    @try {
        self.isDelete = NO;
        
        
        
        if (textField == self.emailText){
            
            if ([string isEqualToString:@""]) {
                return TRUE;
            }
            if ([self.emailText.text length] >= 100) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Reached" message:@"You have reached the character limit for this field." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return FALSE;
            }
            
        }else if (textField == self.passwordText){
            if ([string isEqualToString:@""]) {
                return TRUE;
            }
            if ([self.passwordText.text length] >= 50) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Reached" message:@"You have reached the character limit for this field." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return FALSE;
            }
            
        }else if (textField == self.firstNameText) {
            
            if ([string isEqualToString:@""]) {
                return TRUE;
            }
            if ([self.firstNameText.text length] >= 50) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Reached" message:@"You have reached the character limit for this field." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return FALSE;
            }
            
        }else if (textField == self.lastNameText){
            
            if ([string isEqualToString:@""]) {
                return TRUE;
            }
            if ([self.lastNameText.text length] >= 50) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Character Limit Reached" message:@"You have reached the character limit for this field." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return FALSE;
            }
            
        }else if (textField == self.creditCardNumberText){
            
            if ([string isEqualToString:@""]) {
                self.isDelete = YES;
                return TRUE;
            }
            
            if ([self.creditCardNumberText.text length] >= 20) {
                
                return FALSE;
            }
            
        }else if (textField == self.expirationText){
            
            if ([string isEqualToString:@""]) {
                self.isDelete = YES;
                
                return TRUE;
            }
            if ([self.expirationText.text length] >= 5) {
                
                return FALSE;
            }
            
        }else if (textField == self.creditCardSecurityCodeText){
            if ([string isEqualToString:@""]) {
                return TRUE;
            }
            
            if ([self.creditCardSecurityCodeText.text length] >= 4) {
                
                return FALSE;
            }
            
        }
        
        return TRUE;
        

    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterViewNew.shouldChangeCharacters" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        return TRUE;
    }
    
   
}

-(void)checkValid{
    @try {
        if ([self isValidEntries]) {
            [self showDoneButton];
        }else{
            [self hideDoneButton];
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterView.checkValid" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
   
}

-(void)showDoneButton{
    @try {
        
        [self hideDoneButton];
        
        int keyboardY = 158;
        if (self.isIphone5) {
            keyboardY = 245;
        }
        self.hideKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(235, keyboardY, 85, 45)];
        self.hideKeyboardView .backgroundColor = [UIColor clearColor];
        self.hideKeyboardView.layer.masksToBounds = YES;
        self.hideKeyboardView.layer.cornerRadius = 3.0;
        
        UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 85, 45)];
        tmpView.backgroundColor = [UIColor blackColor];
        tmpView.alpha = 0.6;
        [self.hideKeyboardView addSubview:tmpView];
        
        self.keyboardSubmitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.keyboardSubmitButton.frame = CGRectMake(8, 5, 69, 35);
        [self.keyboardSubmitButton setTitle:@"Next" forState:UIControlStateNormal];
        [self.keyboardSubmitButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
        [self.keyboardSubmitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.keyboardSubmitButton setBackgroundImage:[UIImage imageNamed:@"rowButton.png"] forState:UIControlStateNormal];
        [self.keyboardSubmitButton addTarget:self action:@selector(goNext) forControlEvents:UIControlEventTouchUpInside];
        
        [self.hideKeyboardView addSubview:self.keyboardSubmitButton];
        [self.view addSubview:self.hideKeyboardView];
        
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.showDoneButton" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    @try {
        if (textField == self.passwordText) {
            [self goNext];
            
        }else if (textField == self.emailText){
            [self.passwordText becomeFirstResponder];
            
        }else if (textField == self.firstNameText){
            [self.lastNameText becomeFirstResponder];
        }else if (textField == self.lastNameText){
            [self goNext];
        }
        return NO;
    }
    @catch (NSException *exception) {
    
        [rSkybox sendClientLog:@"RegisterView.textFieldShouldReturn" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        return NO;
        
    }
    
  
}

-(void)hideDoneButton{
    @try {
        [self.hideKeyboardView removeFromSuperview];
        self.hideKeyboardView = nil;
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterView.hideDoneButton" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
  
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    @try {
        [self hideDoneButton];
        return YES;
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterView.textFieldShouldClear" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        return YES;
        
    }
    
  
}



-(void)valueChanged:(id)sender{
    
    @try {
        if (self.isIos6) {
            if (sender == self.expirationText) {
                
                [self formatExpiration];
            }else if (sender == self.creditCardNumberText){
                [self formatCreditCard:NO];
            }else{
                
            }
        }else{
            
            if (self.shouldIgnoreValueChanged) {
                self.shouldIgnoreValueChanged = NO;
            }else{
                if (sender == self.creditCardNumberText){
                    [self formatCreditCard:NO];
                }
            }
            
            if (self.shouldIgnoreValueChangedExpiration) {
                self.shouldIgnoreValueChangedExpiration = NO;
            }else{
                if (sender == self.expirationText) {
                    
                    [self formatExpiration];
                }
            }
            
            
            
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterViewNew.valueChanged" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
    
}

-(void)formatCreditCard:(BOOL)final{
    
    @try {
        if (!self.isDelete) {
            
            
            NSString *cardNumber = self.creditCardNumberText.text;
            BOOL isAmex = NO;
            
            if ([cardNumber length] > 1) {
                if ([[cardNumber substringToIndex:2] isEqualToString:@"34"] || [[cardNumber substringToIndex:2] isEqualToString:@"37"]) {
                    isAmex = YES;
                }
            }
            
            if (isAmex) {
                
                
                if (final) {
                    
                    cardNumber = [NSString stringWithFormat:@"%@ %@ %@", [cardNumber substringToIndex:4], [cardNumber substringWithRange:NSMakeRange(4, 6)], [cardNumber substringFromIndex:10]];
                    
                }else{
                    if ([cardNumber length] == 4) {
                        cardNumber = [cardNumber stringByAppendingString:@" "];
                    }else if ([cardNumber length] == 11){
                        cardNumber = [cardNumber stringByAppendingString:@" "];
                    }else if ([cardNumber length] == 17){
                        [self.expirationText becomeFirstResponder];
                    }else if ([cardNumber length] == 5) {
                        cardNumber = [NSString stringWithFormat:@"%@ %@", [cardNumber substringToIndex:4], [cardNumber substringFromIndex:4]];
                    }else if ([cardNumber length] == 12){
                        cardNumber = [NSString stringWithFormat:@"%@ %@", [cardNumber substringToIndex:11], [cardNumber substringFromIndex:11]];
                        
                    }
                }
                
                
                
            }else{
                
                if (final) {
                    
                    cardNumber = [NSString stringWithFormat:@"%@ %@ %@ %@", [cardNumber substringToIndex:4], [cardNumber substringWithRange:NSMakeRange(4, 4)], [cardNumber substringWithRange:NSMakeRange(8, 4)], [cardNumber substringFromIndex:12]];
                }else{
                    if ([cardNumber length] == 4) {
                        cardNumber = [cardNumber stringByAppendingString:@" "];
                    }else if ([cardNumber length] == 9){
                        cardNumber = [cardNumber stringByAppendingString:@" "];
                    }else if ([cardNumber length] == 14){
                        cardNumber = [cardNumber stringByAppendingString:@" "];
                    }else if ([cardNumber length] == 19){
                        [self.expirationText becomeFirstResponder];
                    }else if ([cardNumber length] == 5) {
                        cardNumber = [NSString stringWithFormat:@"%@ %@", [cardNumber substringToIndex:4], [cardNumber substringFromIndex:4]];
                    }else if ([cardNumber length] == 10){
                        cardNumber = [NSString stringWithFormat:@"%@ %@", [cardNumber substringToIndex:9], [cardNumber substringFromIndex:9]];
                        
                    }else if ([cardNumber length] == 15){
                        cardNumber = [NSString stringWithFormat:@"%@ %@", [cardNumber substringToIndex:14], [cardNumber substringFromIndex:14]];
                    }
                }
                
            }
            
            
            
            if (!self.isIos6) {
                self.shouldIgnoreValueChanged = YES;
            }
            self.creditCardNumberText.text = cardNumber;
        }
    }
    
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterViewNew.formatCreditCard" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
    
}

-(void)formatExpiration{
    
    @try {
        NSString *expiration = self.expirationText.text;
        
        if (self.isDelete) {
            
            if ([expiration length] == 2) {
                expiration = [expiration substringToIndex:1];
            }
            
        }else{
            if ([expiration length] == 5) {
                [self.creditCardSecurityCodeText becomeFirstResponder];
            }
            
            if ([expiration length] == 1) {
                if (![expiration isEqualToString:@"1"] && ![expiration isEqualToString:@"0"]) {
                    expiration = [NSString stringWithFormat:@"0%@/", expiration];
                }
            }else if ([expiration length] == 2){
                expiration = [expiration stringByAppendingString:@"/"];
            }
        }
        
        if (!self.isIos6) {
            self.shouldIgnoreValueChangedExpiration = YES;
        }
        
        self.expirationText.text = expiration;
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterViewNew.formatException" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
}



-(void)backspaceHit{
    
    @try {
        if (([self.creditCardSecurityCodeText.text length] == 0) && [self.creditCardSecurityCodeText isFirstResponder]) {
            [self.expirationText becomeFirstResponder];
        }else if (([self.expirationText.text length] == 0) && [self.expirationText isFirstResponder]) {
            [self.creditCardNumberText becomeFirstResponder];
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterViewNew.backSpaceHit" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
}


-(void)registerComplete:(NSNotification *)notification{
    @try {
        [self.activity stopAnimating];
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
        [rSkybox sendClientLog:@"RegisterView.registerComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (IBAction)registerNow:(id)sender {
    
    @try {
        
        [rSkybox addEventToSession:@"initiateRegister"];
        
        
        if ([[self creditCardStatus] isEqualToString:@"invalid"]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Field" message:@"Please enter all credit card fiels." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }else if ([[self creditCardStatus] isEqualToString:@"empty"]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Field" message:@"Please enter all credit card fiels." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }
     
        
        else{
            
            
            if ([self luhnCheck:self.creditCardNumberText.text]) {
                
                
                self.errorLabel.hidden = YES;
                [self.activity startAnimating];
                
                self.registerButton.enabled = NO;
                self.loginButton.enabled = NO;
                [self runRegister];
                
            }else{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Card" message:@"Please enter a valid card number." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
            }
            
            
            
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.registerNow" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegiterView.runRegister" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


-(void)addCreditCard{
    @try {
        
        CreatePinView *tmp = [self.storyboard instantiateViewControllerWithIdentifier:@"createPin"];
        [self.navigationController pushViewController:tmp animated:NO];
        
        NSString *creditDebitString = @"Credit";
        
        //if (self.creditDebitSegment.selectedSegmentIndex == 1) {
        //   creditDebitString = @"Debit";
        // }
        
        //NSString *expiration = [NSString stringWithFormat:@"%@/%@", self.expirationMonth, self.expirationYear];
        
        NSString *expiration = self.expirationText.text;
        
        tmp.creditDebitString = creditDebitString;
        tmp.expiration = expiration;
        tmp.securityCode = self.creditCardSecurityCodeText.text;
        tmp.cardNumber = [self.creditCardNumberText.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        tmp.fromRegister = YES;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.addCreditCard" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


-(void)goHome{
    @try {
        
        NSString *welcomeMsg = @"Thank you for choosing Arc. You are now ready to start using mobile payments.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Complete" message:welcomeMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        //[alert show];
        
        [self performSegueWithIdentifier:@"registerHome" sender:self];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.goHome" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (BOOL) luhnCheck:(NSString *)stringToTest {
    
    
    @try {
     
        stringToTest = [stringToTest stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSMutableArray *stringAsChars = [stringToTest toCharArray];
        
        BOOL isOdd = YES;
        int oddSum = 0;
        int evenSum = 0;
        
        for (int i = [stringToTest length] - 1; i >= 0; i--) {
            
            int digit = [(NSString *)[stringAsChars objectAtIndex:i] intValue];
            
            if (isOdd)
                oddSum += digit;
            else
                evenSum += digit/5 + (2*digit) % 10;
            
            isOdd = !isOdd;
        }
        
        return ((oddSum + evenSum) % 10 == 0);
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterView.userDidProvideCreditCardInfo" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        return NO;
        
    }
    
   
}

-(NSString *)creditCardStatus{
    @try {
        
        if ([self.creditCardSecurityCodeText.text isEqualToString:@""] && [self.creditCardNumberText.text isEqualToString:@""] && [self.expirationText.text isEqualToString:@""]){
            
            return @"empty";
        }else{
            //At least one is entered, must all be entered
            if (![self.creditCardSecurityCodeText.text isEqualToString:@""] && ![self.creditCardNumberText.text isEqualToString:@""] && ([self.expirationText.text length] == 5)){
                return @"valid";
            }else{
                return @"invalid";
            }
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.creditCardStatus" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



-(void)scanCard{
 
    @try {
        
        [ArcClient trackEvent:@"CARD.IO_SCAN_ATTEMPTED"];

        
        CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
        scanViewController.collectCVV = YES;
        scanViewController.collectExpiry = YES;
        
        //54bb17d6425a400194570cefaeaf5219
        scanViewController.appToken = @"54bb17d6425a400194570cefaeaf5219"; // get your app token from the card.io website
        [self presentModalViewController:scanViewController animated:YES];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterView.scanCard" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
  
 
 }
 
 - (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
 
     @try {
         
         [ArcClient trackEvent:@"CARD.IO_SCAN_CANCELED"];

         [scanViewController dismissModalViewControllerAnimated:YES];

     }
     @catch (NSException *exception) {
         [rSkybox sendClientLog:@"RegisterView.userDidCancelPayment" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
         
     }
     
 }
 
 - (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController
{
    
    @try {
        
        [ArcClient trackEvent:@"CARD.IO_SCAN_SUCCESSFULL"];
        
        self.creditCardNumberText.text = info.cardNumber;
        NSString *expirationYearString = [NSString stringWithFormat:@"%i", info.expiryYear];
        self.expirationText.text = [NSString stringWithFormat:@"%02i/%@", info.expiryMonth, [expirationYearString substringFromIndex:2]];
        self.creditCardSecurityCodeText.text = info.cvv;
        [self formatCreditCard:YES];
        
        [scanViewController dismissModalViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RegisterView.userDidProvideCreditCardInfo" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
  
 

     
 }
 
 

@end
