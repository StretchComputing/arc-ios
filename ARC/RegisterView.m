//
//  RegisterView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/25/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "RegisterView.h"
#import "ArcAppDelegate.h"
#import "RegisterDwollaView.h"
#import <QuartzCore/QuartzCore.h>
#import "FBEncryptorAES.h"
#import "ArcClient.h"
#import "rSkybox.h"

@interface RegisterView ()

-(void)showDoneButton;
-(void)runRegister;
-(NSString *)creditCardStatus;

@end

@implementation RegisterView

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

-(void)registerComplete:(NSNotification *)notification{
        
    NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
    NSString *status = [responseInfo valueForKey:@"status"];
        
    if ([status isEqualToString:@"1"]) {
        //success
        CGPoint top = CGPointMake(0, 40);
        [self.tableView setContentOffset:top animated:YES];
        
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

- (void)viewDidLoad
{
    [rSkybox addEventToSession:@"viewRegisterScreen"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerComplete:) name:@"registerNotification" object:nil];

    
    self.creditCardNumberText.text = @"";
    self.creditCardPinText.text = @"";
    self.creditCardSecurityCodeText.text = @"";
    
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
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = backView.bounds;
    UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
    [backView.layer insertSublayer:gradient atIndex:0];
    
    self.tableView.backgroundView = backView;
    
    [self.tableView setContentSize:CGSizeMake(320, 100)];
}




- (IBAction)login:(UIBarButtonItem *)sender {
 
    [self.navigationController dismissModalViewControllerAnimated:YES];

}

- (IBAction)registerNow:(id)sender {
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
        //[rSkybox sendClientLog:@"getInvoiceFromNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)addCreditCard{
    
    NSString *expiration = [NSString stringWithFormat:@"%@/%@", self.expirationMonth, self.expirationYear];
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    [mainDelegate insertCreditCardWithNumber:self.creditCardNumberText.text andSecurityCode:self.creditCardSecurityCodeText.text andExpiration:expiration andPin:self.creditCardPinText.text];
    
}


-(void)goHome{
    [self performSegueWithIdentifier:@"registerHome" sender:self];
    

}



-(void)endText{
    
    [self.hideKeyboardView removeFromSuperview];
    self.hideKeyboardView = nil;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1];
    
    self.tableView.frame = CGRectMake(0, 0, 320, 416);
    
    
    [UIView commitAnimations];

    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([[segue identifier] isEqualToString:@"confirmDwolla"]) {
        
        RegisterDwollaView *detailViewController = [segue destinationViewController];
        detailViewController.fromRegister = YES;
    } 
}


- (IBAction)editBegin:(id)sender {
    

    UITextField *selectedField = (UITextField *)sender;
    
    CGPoint myPoint;
    
    if (selectedField.tag == 10) {
        //CC #
        myPoint = CGPointMake(0, 405);
        
    }else if (selectedField.tag == 11){
        //security code
        
        myPoint = CGPointMake(0, 405);
        
    }else if (selectedField.tag == 12){
        //pin
        
        myPoint = CGPointMake(0, 540);
        
    }

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    
    [self.tableView setContentOffset:myPoint animated:YES];
    
    
    [UIView commitAnimations];
    
    

}

- (IBAction)editEnd:(id)sender {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    
    self.tableView.frame = CGRectMake(0, 64, 320, 416);
    
    
    [UIView commitAnimations];

    
}



-(void)keyboardWillShow:(id)sender{
    
   
    [self showDoneButton];
    
    
}

-(void)showDoneButton{
    
    [self.hideKeyboardView removeFromSuperview];
    self.hideKeyboardView = nil;
    
    self.hideKeyboardView = [[UIView alloc] initWithFrame:CGRectMake(235, 158, 85, 45)];
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
    [self.view.superview addSubview:self.hideKeyboardView];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    self.tableView.frame = CGRectMake(0, 0, 320, 200);
    
    
    [UIView commitAnimations];
    
}
-(void)keyboardWillHide:(id)sender{
    //[self.hideKeyboardView removeFromSuperview];
    //self.hideKeyboardView = nil;
}


-(void)hideKeyboard{

    [self.firstNameText resignFirstResponder];
    [self.lastNameText resignFirstResponder];
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



-(void)changeExpiration:(UIButton *)sender{
    
    [self.hideKeyboardView removeFromSuperview];
    [self.pickerView removeFromSuperview];
    self.hideKeyboardView = nil;
    self.pickerView = nil;
    
    [self showDoneButton];

    if (sender.tag == 22) {
        //month
        self.isExpirationMonth = YES;
    }else{
        //year
        self.isExpirationMonth = NO;
    }
    
    [self.firstNameText resignFirstResponder];
    [self.lastNameText resignFirstResponder];
    [self.emailText resignFirstResponder];
    [self.passwordText resignFirstResponder];
    [self.creditCardPinText resignFirstResponder];
    [self.creditCardNumberText resignFirstResponder];
    [self.creditCardSecurityCodeText resignFirstResponder];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, 320, 315)];
    self.pickerView.delegate = self;
    self.pickerView.showsSelectionIndicator = YES;
    
    [self.view.superview addSubview:self.pickerView];
}



- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    
    if (self.isExpirationMonth) {
        self.creditCardExpirationMonthLabel.text = [self.months objectAtIndex:row];
        self.expirationMonth = [[self.months objectAtIndex:row] substringToIndex:2];
    }else{
        self.creditCardExpirationYearLabel.text = [self.years objectAtIndex:row];
        self.expirationYear = [NSString stringWithString:[self.years objectAtIndex:row]];
                               
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows;
    
    if (self.isExpirationMonth) {
        numRows = 12;
    }else {
        numRows = 19;
    }
    
    return numRows;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (self.isExpirationMonth) {
        return [self.months objectAtIndex:row];
    }else{
        return [self.years objectAtIndex:row];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}

-(NSString *)creditCardStatus{
    
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



@end
