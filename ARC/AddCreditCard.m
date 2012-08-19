//
//  AddCreditCard.m
//  ARC
//
//  Created by Nick Wroblewski on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddCreditCard.h"
#import <QuartzCore/QuartzCore.h>
#import "ArcAppDelegate.h"
#import "SettingsView.h"
#import "rSkybox.h"

@interface AddCreditCard ()

-(void)showDoneButton;
-(NSString *)creditCardStatus;

@end

@implementation AddCreditCard



-(void)viewDidLoad{
    [rSkybox addEventToSession:@"viewAddCreditCardScreen"];
    
    self.creditCardNumberText.text = @"";
    self.creditCardPinText.text = @"";
    self.creditCardSecurityCodeText.text = @"";
    
    self.months = @[@"01 - Jan", @"02 - Feb", @"03 - March", @"04 - April", @"05 - May", @"06 - June", @"07 - July", @"08 - Aug", @"09 - Sept", @"10 - Oct", @"11 - Nov", @"12 - Dec"];
    
    self.years = @[@"2012", @"2013", @"2014", @"2015", @"2016", @"2017", @"2018", @"2019", @"2020", @"2021", @"2022", @"2023", @"2024", @"2025", @"2026", @"2027", @"2028", @"2029", @"2030"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (IBAction)editBegin:(id)sender {
    
    
    UITextField *selectedField = (UITextField *)sender;
    
    CGPoint myPoint;
    
    if (selectedField.tag == 10) {
        //CC #
        myPoint = CGPointMake(0, 0);
        
    }else if (selectedField.tag == 11){
        //security code
        
        myPoint = CGPointMake(0, 0);
        
    }else if (selectedField.tag == 12){
        //pin
        
        myPoint = CGPointMake(0, 130);
        
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

-(void)endText{
    
    [self.hideKeyboardView removeFromSuperview];
    self.hideKeyboardView = nil;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1];
    
    self.tableView.frame = CGRectMake(0, 0, 320, 416);
    
    
    [UIView commitAnimations];
    
    
}


-(void)addCard{
    [rSkybox addEventToSession:@"clickAddCreditCardButton"];
    
    if ([[self creditCardStatus] isEqualToString:@"valid"]) {
        
        NSString *expiration = [NSString stringWithFormat:@"%@/%@", self.expirationMonth, self.expirationYear];
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        [mainDelegate insertCreditCardWithNumber:self.creditCardNumberText.text andSecurityCode:self.creditCardSecurityCodeText.text andExpiration:expiration andPin:self.creditCardPinText.text];
        
        [self performSelector:@selector(popNow) withObject:nil afterDelay:0.5];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Field" message:@"Please fill out all credit card information first" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)popNow{
    
    SettingsView *tmp = [[self.navigationController viewControllers] objectAtIndex:0];
    tmp.creditCardAdded = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
