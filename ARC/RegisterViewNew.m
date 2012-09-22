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

@interface RegisterViewNew ()

-(void)showDoneButton;
-(void)runRegister;
-(NSString *)creditCardStatus;

@end

@implementation RegisterViewNew

-(void)viewDidAppear:(BOOL)animated{
    @try {
        
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
                }
            }else{
                self.activityView.hidden = NO;
                self.errorLabel.text = @"Failed to confirm Dwolla credentials.";
            }
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.viewDidAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



-(void)registerComplete:(NSNotification *)notification{
    @try {
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        
        [[NSUserDefaults standardUserDefaults] setValue:self.emailText.text forKey:@"customerEmail"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([status isEqualToString:@"1"]) {
            //success
            
            if ([[self creditCardStatus] isEqualToString:@"valid"]) {
                //Save credit card info
                [self performSelector:@selector(addCreditCard) withObject:nil afterDelay:1.0];
            }
            
            if (self.dwollaSegControl.selectedSegmentIndex == 1) {
                [self goHome];
            }
            
        }else{
            self.activityView.hidden = NO;
            self.errorLabel.hidden = NO;
            self.errorLabel.text = @"*Error registering, please try again.";
            self.registerSuccess = NO;
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.registerComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (void)viewDidLoad
{
    @try {
        
        [rSkybox addEventToSession:@"viewRegisterScreen"];
        
  
        
        
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Register"];
		self.navigationItem.backBarButtonItem = temp;
        
        self.isCreditCard = NO;
        
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerComplete:) name:@"registerNotification" object:nil];
        
        
        self.creditCardNumberText.text = @"";
        self.creditCardPinText.text = @"";
        self.creditCardSecurityCodeText.text = @"";
        
        self.expirationMonth = @"01";
        self.expirationYear = @"2012";
        
        self.months = @[@"01 - Jan", @"02 - Feb", @"03 - March", @"04 - April", @"05 - May", @"06 - June", @"07 - July", @"08 - Aug", @"09 - Sept", @"10 - Oct", @"11 - Nov", @"12 - Dec"];
        
        self.years = @[@"2012", @"2013", @"2014", @"2015", @"2016", @"2017", @"2018", @"2019", @"2020", @"2021", @"2022", @"2023", @"2024", @"2025", @"2026", @"2027", @"2028", @"2029", @"2030"];
        
        self.firstNameText.text = @"";
        self.lastNameText.text = @"";
        self.emailText.text = @"";
        self.passwordText.text = @"";
        
        self.activityView.hidden = YES;
        self.serverData = [NSMutableData data];
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.view.bounds;
        self.view.backgroundColor = [UIColor clearColor];
        //UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
        double x = 1.9;
        UIColor *myColor = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];
        
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
        
        [self.myTableView reloadData];
        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Register"];
        self.navigationItem.titleView = navLabel;
                
        if (self.view.frame.size.height > 500) {
            self.isIphone5 = YES;
        }else{
            self.isIphone5 = NO;
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (IBAction)login:(UIBarButtonItem *)sender {
    @try {
        
        [self.navigationController dismissModalViewControllerAnimated:YES];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.login" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (IBAction)registerNow:(id)sender {
    @try {
        
        [rSkybox addEventToSession:@"initiateRegister"];
        
        
        if ([self.firstNameText.text isEqualToString:@""] || [self.lastNameText.text isEqualToString:@""] || [self.emailText.text isEqualToString:@""] || [self.passwordText.text isEqualToString:@""]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Field" message:@"Name, Email, and Password are required fields" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }else if ([[self creditCardStatus] isEqualToString:@"invalid"]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Field" message:@"If you wish to use enter a credit card, please enter all fields" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }else if ((self.dwollaSegControl.selectedSegmentIndex == 1) && [[self creditCardStatus] isEqualToString:@"empty"]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Payment" message:@"You must choose at least 1 form of payment to continue" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }else if ((self.dwollaSegControl.selectedSegmentIndex == 1) && (self.creditDebitSegment.selectedSegmentIndex == -1)) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Credit or Debit" message:@"Please select credit or debit for your card." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }else{
            
            
            if ([self luhnCheck:self.creditCardNumberText.text]) {
                
                
                self.activityView.hidden = NO;
                self.errorLabel.hidden = YES;
                [self runRegister];
                
                
            }else{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Card" message:@"Please enter a valid card number." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
        
        NSString *genderString = @"";
        if (self.genderSegment.selectedSegmentIndex == 0) {
            genderString = @"M";
        }else{
            genderString = @"F";
        }
        [ tempDictionary setObject:genderString forKey:@"Gender"];
        
        // TODO hard coded for now
        [ tempDictionary setObject:@"123" forKey:@"PassPhrase"];
        [ tempDictionary setObject:@"1955-05-10" forKey:@"BirthDate"];
        [ tempDictionary setObject:@(YES) forKey:@"AcceptTerms"];
        [ tempDictionary setObject:@(YES) forKey:@"Notifications"];
        [ tempDictionary setObject:@(NO) forKey:@"Facebook"];
        [ tempDictionary setObject:@(NO) forKey:@"Twitter"];
        
		loginDict = tempDictionary;
        ArcClient *client = [[ArcClient alloc] init];
        [client createCustomer:loginDict];
        
        if (self.dwollaSegControl.selectedSegmentIndex == 0) {
            [self performSegueWithIdentifier:@"confirmDwolla" sender:self];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegiterView.runRegister" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)addCreditCard{
    @try {
        
        NSString *creditDebitString = @"Credit";
        
        if (self.creditDebitSegment.selectedSegmentIndex == 1) {
            creditDebitString = @"Debit";
        }
        
        NSString *expiration = [NSString stringWithFormat:@"%@/%@", self.expirationMonth, self.expirationYear];
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        [mainDelegate insertCreditCardWithNumber:self.creditCardNumberText.text andSecurityCode:self.creditCardSecurityCodeText.text andExpiration:expiration andPin:self.creditCardPinText.text andCreditDebit:creditDebitString];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.addCreditCard" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


-(void)goHome{
    @try {
        
        [self performSegueWithIdentifier:@"registerHome" sender:self];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.goHome" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



-(void)endText{
    @try {
        
        [self.hideKeyboardView removeFromSuperview];
        self.hideKeyboardView = nil;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            int viewHeight = 416;
            if (self.isIphone5) {
                viewHeight = 503;
            }
            self.myTableView.frame = CGRectMake(0, 0, 320, viewHeight);
        }];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.endText" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"confirmDwolla"]) {
            
            RegisterDwollaView *detailViewController = [segue destinationViewController];
            detailViewController.fromRegister = YES;
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (void)editBegin:(id)sender {
    @try {
        
        if (self.isIphone5) {
            
            CGPoint myPoint;
            
            if (self.firstNameText == sender) {
                
                myPoint = CGPointMake(0, 0);
                
            }else if (self.lastNameText == sender){
                myPoint = CGPointMake(0, 0);
                
            }else if (self.birthDateText == sender){
                myPoint = CGPointMake(0, 0);
                
            }else if (self.emailText == sender){
                myPoint = CGPointMake(0, 0);
                
            }else if (self.passwordText == sender){
                myPoint = CGPointMake(0, 150);
                
            }else if (self.creditCardNumberText == sender){
                myPoint = CGPointMake(0, 300);
                
            }else if (self.creditCardSecurityCodeText == sender){
                myPoint = CGPointMake(0, 510);
                
            }else if (self.creditCardPinText == sender){
                myPoint = CGPointMake(0, 520);
                
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                
                self.myTableView.frame = CGRectMake(0, 0, 320, 287);
                [self.myTableView setContentOffset:myPoint animated:YES];
                
            }];

            
        }else{
            CGPoint myPoint;
            
            if (self.firstNameText == sender) {
                
                myPoint = CGPointMake(0, 0);
                
            }else if (self.lastNameText == sender){
                myPoint = CGPointMake(0, 0);
                
            }else if (self.birthDateText == sender){
                myPoint = CGPointMake(0, 45);
                
            }else if (self.emailText == sender){
                myPoint = CGPointMake(0, 95);
                
            }else if (self.passwordText == sender){
                myPoint = CGPointMake(0, 200);
                
            }else if (self.creditCardNumberText == sender){
                myPoint = CGPointMake(0, 300);
                
            }else if (self.creditCardSecurityCodeText == sender){
                myPoint = CGPointMake(0, 510);
                
            }else if (self.creditCardPinText == sender){
                myPoint = CGPointMake(0, 540);
                
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                
                self.myTableView.frame = CGRectMake(0, 0, 320, 200);
                [self.myTableView setContentOffset:myPoint animated:YES];
                
            }];

        }

        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.editBegin" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}











-(void)keyboardWillShow:(id)sender{
    @try {
        
        [self showDoneButton];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.keyboardWillShow" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)showDoneButton{
    @try {
        
        [self.hideKeyboardView removeFromSuperview];
        self.hideKeyboardView = nil;
        
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
        
        UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tmpButton.frame = CGRectMake(8, 5, 69, 35);
        [tmpButton setTitle:@"Done" forState:UIControlStateNormal];
        [tmpButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
        [tmpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tmpButton setBackgroundImage:[UIImage imageNamed:@"rowButton.png"] forState:UIControlStateNormal];
        [tmpButton addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
        
        [self.hideKeyboardView addSubview:tmpButton];
        [self.view addSubview:self.hideKeyboardView];
        
   
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.showDoneButton" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}
-(void)keyboardWillHide:(id)sender{
    @try {
        
        //[self.hideKeyboardView removeFromSuperview];
        //self.hideKeyboardView = nil;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.keyboardWillHide" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)hideKeyboard{
    @try {
        
        [self.firstNameText resignFirstResponder];
        [self.lastNameText resignFirstResponder];
        [self.birthDateText resignFirstResponder];
        [self.emailText resignFirstResponder];
        [self.passwordText resignFirstResponder];
        [self.creditCardPinText resignFirstResponder];
        [self.creditCardNumberText resignFirstResponder];
        [self.creditCardSecurityCodeText resignFirstResponder];
        self.pickerView.hidden = YES;
        [self.hideKeyboardView removeFromSuperview];
        self.hideKeyboardView = nil;
        [self endText];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.hideKeyboard" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
    
}


-(void)changeExpMonth{
    
    self.isExpirationMonth = YES;
    [self changeExpiration];
}


-(void)changeExpYear{
    
    self.isExpirationMonth = NO;
    [self changeExpiration];
}

-(void)changeExpiration{
    @try {
        
        [self.hideKeyboardView removeFromSuperview];
        [self.pickerView removeFromSuperview];
        self.hideKeyboardView = nil;
        self.pickerView = nil;
        
        [self showDoneButton];

        [self.firstNameText resignFirstResponder];
        [self.lastNameText resignFirstResponder];
        [self.emailText resignFirstResponder];
        [self.passwordText resignFirstResponder];
        [self.creditCardPinText resignFirstResponder];
        [self.creditCardNumberText resignFirstResponder];
        [self.creditCardSecurityCodeText resignFirstResponder];
        
        int pickerY = 200;
        if (self.isIphone5) {
            pickerY = 287;
        }
        self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, pickerY, 320, 315)];
        self.pickerView.delegate = self;
        self.pickerView.showsSelectionIndicator = YES;
        
        [self.view.superview addSubview:self.pickerView];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.changeExpiration" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    @try {
        
        if (self.isExpirationMonth) {
            self.creditCardExpirationMonthLabel.text = [self.months objectAtIndex:row];
            self.expirationMonth = [[self.months objectAtIndex:row] substringToIndex:2];
        }else{
            self.creditCardExpirationYearLabel.text = [self.years objectAtIndex:row];
            self.expirationYear = [NSString stringWithString:[self.years objectAtIndex:row]];
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.pickerView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    @try {
        
        NSUInteger numRows;
        
        if (self.isExpirationMonth) {
            numRows = 12;
        }else {
            numRows = 19;
        }
        
        return numRows;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.pickerView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    @try {
        
        if (self.isExpirationMonth) {
            return [self.months objectAtIndex:row];
        }else{
            return [self.years objectAtIndex:row];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.pickerView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    @try {
        
        int sectionWidth = 300;
        
        return sectionWidth;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterView.pickerView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(NSString *)creditCardStatus{
    @try {
        
        if ([self.creditCardSecurityCodeText.text isEqualToString:@""] && [self.creditCardPinText.text isEqualToString:@""] && [self.creditCardNumberText.text isEqualToString:@""]){
            
            return @"empty";
        }else{
            //At least one is entered, must all be entered
            if (![self.creditCardSecurityCodeText.text isEqualToString:@""] && ![self.creditCardPinText.text isEqualToString:@""] && ![self.creditCardNumberText.text isEqualToString:@""]){
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


-(void)paymentChanged{
    if (self.dwollaSegControl.selectedSegmentIndex == 0) {
        self.isCreditCard = NO;
        [self performSelector:@selector(choseDwolla) withObject:nil afterDelay:0.1];

    }else{
        self.isCreditCard = YES;
        [self performSelector:@selector(choseCredit) withObject:nil afterDelay:0.1];

        
    }
    
    [self.myTableView reloadData];


}
-(void)choseCredit{
    [self.creditCardNumberText becomeFirstResponder];
    self.pickerView.hidden = YES;

}

-(void)choseDwolla{
    
    [self.firstNameText resignFirstResponder];
    [self.lastNameText resignFirstResponder];
    [self.birthDateText resignFirstResponder];
    [self.emailText resignFirstResponder];
    [self.passwordText resignFirstResponder];
    [self.creditCardPinText resignFirstResponder];
    [self.creditCardNumberText resignFirstResponder];
    [self.creditCardSecurityCodeText resignFirstResponder];
    self.pickerView.hidden = YES;
    [self.hideKeyboardView removeFromSuperview];
    self.hideKeyboardView = nil;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        int viewHeight = 416;
        if (self.isIphone5) {
            viewHeight = 503;
        }
        
        self.myTableView.frame = CGRectMake(0, 0, 320, viewHeight);
        [self.myTableView setContentOffset:CGPointMake(0, 0) animated:NO];
        
    }];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {

        NSUInteger row = [indexPath row];
        NSUInteger section = [indexPath section];


        UITableViewCell *cell;

        if (section == 0) {
            if (row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"firstNameCell"];

            }else if (row == 1){
                cell = [tableView dequeueReusableCellWithIdentifier:@"lastNameCell"];

            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:@"birthDateCell"];

            }
        }else if (section == 1){
            if (row == 0){
                
                cell = [tableView dequeueReusableCellWithIdentifier:@"emailCell"];

            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:@"passwordCell"];

            }
        }else if (section == 2){
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"paymentCell"];

        }else if (section == 3){
            
            if (row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"cardNumberCell"];

            }else if (row == 1){
                
                cell = [tableView dequeueReusableCellWithIdentifier:@"expirationMonthCell"];

            }else if (row == 2){
                cell = [tableView dequeueReusableCellWithIdentifier:@"expirationYearCell"];

            }else if (row == 3){
                cell = [tableView dequeueReusableCellWithIdentifier:@"securityCodeCell"];

            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:@"cardTypeCell"];

            }
        }else if (section == 4){
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"pinCell"];

        }
        

        if (section == 2) {

            self.dwollaSegControl = (UISegmentedControl *)[cell.contentView viewWithTag:1];
            [self.dwollaSegControl addTarget:self action:@selector(paymentChanged) forControlEvents:UIControlEventValueChanged];
            
        }else if ((section == 3) && ((row == 1) || (row == 2))){

            if (row == 1) {
                
                UILabel *expLabel = (UILabel *)[cell.contentView viewWithTag:1];
                expLabel.text = @"Expiration Month";
                
                self.creditCardExpirationMonthLabel = (UILabel *)[cell.contentView viewWithTag:2];
                self.creditCardExpirationMonthLabel.text = @"01 - Jan";
                
                UIButton *tmpButton = (UIButton *)[cell.contentView viewWithTag:3];
                [tmpButton addTarget:self action:@selector(changeExpMonth) forControlEvents:UIControlEventTouchUpInside];
                
                
            }else{
                
                UILabel *expLabel = (UILabel *)[cell.contentView viewWithTag:1];
                expLabel.text = @"Expiration Year";
                
                self.creditCardExpirationYearLabel = (UILabel *)[cell.contentView viewWithTag:2];
                self.creditCardExpirationYearLabel.text = @"2012";
                
                UIButton *tmpButton = (UIButton *)[cell.contentView viewWithTag:3];
                [tmpButton addTarget:self action:@selector(changeExpYear) forControlEvents:UIControlEventTouchUpInside];
                
            }
            
        }else{

            if (section == 0) {
                
                if (row == 0) {

                    self.firstNameText = (UITextField *)[cell.contentView viewWithTag:1];
                    self.firstNameText.placeholder = @"First Name";
                    [self.firstNameText addTarget:self action:@selector(editBegin:) forControlEvents:UIControlEventEditingDidBegin];
                }else if (row == 1){
                    self.lastNameText = (UITextField *)[cell.contentView viewWithTag:1];
                    self.lastNameText.placeholder = @"Last Name";
                     [self.lastNameText addTarget:self action:@selector(editBegin:) forControlEvents:UIControlEventEditingDidBegin];

                }else if (row == 2){
                    
                    self.birthDateText = (UITextField *)[cell.contentView viewWithTag:1];
                    self.birthDateText.placeholder = @"Birth Date (mm/dd/yyyy)";
                    [self.birthDateText addTarget:self action:@selector(editBegin:) forControlEvents:UIControlEventEditingDidBegin];
                    
                }
            }else if (section == 1){
                
                if (row == 0) {
                    self.emailText = (UITextField *)[cell.contentView viewWithTag:1];
                    self.emailText.placeholder = @"Email Address";
                     [self.emailText addTarget:self action:@selector(editBegin:) forControlEvents:UIControlEventEditingDidBegin];
                }else if (row == 1){

                    self.passwordText = (UITextField *)[cell.contentView viewWithTag:1];
                    self.passwordText.placeholder = @"Choose A Password";
                     //[self.passwordText addTarget:self action:@selector(editBeginPassword) forControlEvents:UIControlEventEditingDidBegin];
                    [self.passwordText addTarget:self action:@selector(editBegin:) forControlEvents:UIControlEventEditingDidBegin];
                    
                }
                
            
            }else if (section == 3){
                
                
                if (row == 0) {
                    self.creditCardNumberText = (UITextField *)[cell.contentView viewWithTag:1];
                    self.creditCardNumberText.placeholder = @"Credit Card Number";
                     [self.creditCardNumberText addTarget:self action:@selector(editBegin:) forControlEvents:UIControlEventEditingDidBegin];
                }else if (row == 3){
                    self.creditCardSecurityCodeText = (UITextField *)[cell.contentView viewWithTag:1];
                    self.creditCardSecurityCodeText.placeholder = @"Security Code";
                     [self.creditCardSecurityCodeText addTarget:self action:@selector(editBegin:) forControlEvents:UIControlEventEditingDidBegin];
                    
                }else if (row == 4){
                    self.creditDebitSegment = (UISegmentedControl *)[cell.contentView viewWithTag:1];

                }
                
            }else if (section == 4){
                
                self.creditCardPinText = (UITextField *)[cell.contentView viewWithTag:1];
                self.creditCardPinText.placeholder = @"Credit Card Pin";
                 [self.creditCardPinText addTarget:self action:@selector(editBegin:) forControlEvents:UIControlEventEditingDidBegin];
            }
            
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RegisterNew.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 2) {
        return 30;
    }
    return 44;
}

 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Personal Information";
    }else if (section == 2){
        return @"Choose Payment";
    }else if (section == 4){
        return @"Create a 4 Digit Credit Card Pin for Security Purposes";
    }else{
        return @"";
    }
 
}
 
 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 3;
    }else if (section == 1){
        return 2;
    }else if (section == 2){
        return 1;
    }else if (section == 3){
        return 5;
    }else{
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (self.isCreditCard) {
        return 5;
    }else{
        return 3;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (section == 2) {
        
        if (!self.isCreditCard) {
            UIView *tmp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
            tmp.backgroundColor = [UIColor clearColor];
            UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
            tmpLabel.backgroundColor = [UIColor clearColor];
            tmpLabel.text = @"*An existing Dwolla account is required for this option";
            tmpLabel.font = [UIFont fontWithName:@"LucidaGrande" size:11];
            tmpLabel.textAlignment = UITextAlignmentCenter;
            [tmp addSubview:tmpLabel];
            return tmp;
            
        }else{
            return [[UIView alloc] init];

        }
    }else{
        return [[UIView alloc] init];
    }

}

- (BOOL) luhnCheck:(NSString *)stringToTest {
    
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


@end
