//
//  ViewCreditCards.m
//  ARC
//
//  Created by Nick Wroblewski on 7/8/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "ViewCreditCards.h"
#import "ArcAppDelegate.h"
#import "CreditCard.h"
#import "EditCreditCard.h"
#import "rSkybox.h"
#import "ArcClient.h"
#import "SettingsView.h"
#import "MFSideMenu.h"
#import <QuartzCore/QuartzCore.h>
#import "LeftViewController.h"
#import "ArcUtility.h"

@interface ViewCreditCards ()

@end

@implementation ViewCreditCards


-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)customerDeactivated{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    mainDelegate.logout = @"true";
    [self.navigationController dismissModalViewControllerAnimated:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    
    
    NSString *customerId = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerId"];
    NSString *defaultTipName = [NSString stringWithFormat:@"%@%@", customerId, @"defaultTip"];
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:defaultTipName] length] > 0 ) {
        self.defaultTipText.text = [[NSUserDefaults standardUserDefaults] valueForKey:defaultTipName];
        
        for (int i = 0; i < 4; i++) {
            
            if ([[[self.defaultTipSegmentControl titleForSegmentAtIndex:i] stringByReplacingOccurrencesOfString:@"%" withString:@""] isEqualToString:self.defaultTipText.text]) {
                self.defaultTipSegmentControl.selectedSegmentIndex = i;
                break;
            }
            
            self.defaultTipSegmentControl.selectedSegmentIndex = -1;
        }
    }
    
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerToken"] length] > 0) {
        self.defaultTipView.hidden = NO;
    }else{
        self.defaultTipView.hidden = YES;
    }
    
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];
    
    @try {
        
        if (self.showCardLocked) {
            self.showCardLocked = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card Locked" message:@"You have entered the PIN incorrectly too many times.  Please wait and try again, or delete this card and re-enter it with a new PIN." delegate:self cancelButtonTitle:@"Delete Card" otherButtonTitles:@"Ok", nil];
            [alert show];
        }else if (self.deleteCardNow) {
            self.deleteCardNow = NO;
            [self deleteCurrentCard];
        }
        
        if (self.creditCardAdded) {
            self.creditCardAdded = NO;
            
            if (self.duplicateCard ) {
                self.duplicateCard = NO;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Card" message:@"You have already added this card!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card Added!" message:@"You have successfully added a new credit card!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
            
        }
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.creditCards = [NSArray arrayWithArray:[mainDelegate getAllCreditCardsForCurrentCustomer]];
        
        [self.myTableView reloadData];
        NSLog(@"Count: %d", [self.creditCards count]);
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewCreditCards.viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    @try {
        
        if (alertView == self.logInAlert) {
            
            if (buttonIndex == 1) {
                //Go Profile
                
                LeftViewController *tmp = [self.navigationController.sideMenu getLeftSideMenu];
                [tmp profileSelected];
            }
        }else{
            if (buttonIndex == 0) {
                //Delete
                [self deleteCurrentCard];
                
                
            }
        }
       
    }
    @catch (NSException *exception) {
         [rSkybox sendClientLog:@"ViewCreditCards.clickedButtonAtIndex" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
}

-(void)deleteCurrentCard{
    
    @try {
        
        self.loadingViewController.displayText.text = @"Deleting Card...";
        [self.loadingViewController startSpin];
        
        CreditCard *tmpCard = [self.creditCards objectAtIndex:self.selectedRow];
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        [mainDelegate deleteCreditCardWithNumber:tmpCard.number andSecurityCode:tmpCard.securityCode andExpiration:tmpCard.expiration];
    
        [self performSelector:@selector(doneDelete) withObject:nil afterDelay:1.0];
        
        NSString *action = [NSString stringWithFormat:@"%@_CARD_DELETE", [self getCardType]];
        [ArcClient trackEvent:action];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ViewCreditCards.deleteCurrentCard" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
}

-(void)doneDelete{
    [self viewWillAppear:NO];
    [self.loadingViewController stopSpin];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Card deleted!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
}
- (NSString *)getCardType {
    @try {
        NSString *creditDebitString = @"";
        CreditCard *tmp = [self.creditCards objectAtIndex:self.selectedRow];
        NSString *sample = [tmp.sample lowercaseString];
        if ([sample rangeOfString:@"credit"].location == NSNotFound) {
            creditDebitString = @"DEBIT";
        } else {
            creditDebitString = @"CREDIT";
        }
        return creditDebitString;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewCreditCards.getCardType" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)viewDidLoad{
    @try {
        
        self.paymentHistoryButton.text = @"View Payment History";

        self.defaultTipClearButton.text = @"Clear";
        
        self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
        self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        [self.loadingViewController stopSpin];
        [self.view addSubview:self.loadingViewController.view];
        
 
     //   self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
      //  self.topLineView.layer.shadowRadius = 1;
     //   self.topLineView.layer.shadowOpacity = 0.2;
        self.topLineView.backgroundColor = dutchTopLineColor;
        self.backView.backgroundColor = dutchTopNavColor;
        
        
        
        SteelfishTitleLabel *navLabel = [[SteelfishTitleLabel alloc] initWithText:@"Credit Cards"];
        self.navigationItem.titleView = navLabel;
        
        SteelfishBarButtonItem *temp = [[SteelfishBarButtonItem alloc] initWithTitleText:@"Cards"];
		self.navigationItem.backBarButtonItem = temp;
        
        [rSkybox addEventToSession:@"viewCreditCardScreen"];
        
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewCreditCards.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @try {
        
        if ([self.creditCards count] == 0) {
            return 2;
        }else{
            return [self.creditCards count] + 1;
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewCreditCards.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        static NSString *creditCardCell=@"creditCardCell";
        static NSString *newCardCell=@"newCardCell";
        
        NSUInteger row = [indexPath row];
        
        int lastRow = 0;
        if ([self.creditCards count] == 0) {
            lastRow = 1;
        }else{
            lastRow = [self.creditCards count];
        }
        
        UITableViewCell *cell;
        
        if (row == lastRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:newCardCell];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:creditCardCell];
            
        }
        
        if (cell == nil) {
            
            
            if (row == lastRow) {
                cell = [[UITableViewCell alloc]
                        initWithStyle:UITableViewCellStyleDefault
                        reuseIdentifier: newCardCell];
            }else{
                cell = [[UITableViewCell alloc]
                        initWithStyle:UITableViewCellStyleDefault
                        reuseIdentifier: creditCardCell];
                
            }
            
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UILabel *displayLabel = (UILabel *)[cell.contentView viewWithTag:3];
        
        if (row != lastRow) {
            
            if ([self.creditCards count] == 0) {
                displayLabel.text = @"- No Cards Found -";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
            }else{
            
                CreditCard *tmp = [self.creditCards objectAtIndex:row];
        
                NSLog(@"RETREIVING SAMPLE: %@", tmp.sample);
                
                if ([tmp.sample rangeOfString:@"Credit Card"].location == NSNotFound && [tmp.sample rangeOfString:@"Debit Card"].location == NSNotFound) {
                    
                    displayLabel.text = [NSString stringWithFormat:@"%@", tmp.sample];

                }else{
                    displayLabel.text = [NSString stringWithFormat:@"%@  %@", [ArcUtility getCardNameForType:tmp.cardType], [tmp.sample substringFromIndex:[tmp.sample length] - 8] ];

                }

            }
        }
        
        return cell;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewCreditCards.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    @try {
        
        NSUInteger row = [indexPath row];
        
        self.selectedRow = row;

        
        int lastRow = 0;
        if ([self.creditCards count] == 0) {
            lastRow = 1;
        }else{
            lastRow = [self.creditCards count];
        }
        
        if (row == lastRow) {
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] > 0) {
                [self performSegueWithIdentifier:@"addCard" sender:self];
            }else{
                self.logInAlert = [[UIAlertView alloc] initWithTitle:@"Not Signed In." message:@"Only signed in users can add credit cards. Select 'Go Profile' to log in or create an account." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Go Profile", nil];
                [self.logInAlert show];
            }
        }else{
            if ([self.creditCards count] != 0) {
                
                CreditCard *selectedCard = [self.creditCards objectAtIndex:row];
                
                self.creditCardNumber = selectedCard.number;
                self.creditCardSecurityCode = selectedCard.securityCode;
                self.creditCardExpiration = selectedCard.expiration;
                self.creditCardSample = selectedCard.sample;
                
                [self performSegueWithIdentifier:@"editCard" sender:self];
            }
        }
        
        [self performSelector:@selector(deselectRow:) withObject:indexPath afterDelay:0.5];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewCreditCards.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)deselectRow:(NSIndexPath *)indexPath{
    @try {
        
        [self.myTableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewCreditCards.deselectRow" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Credit Cards";
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"editCard"]) {
            
            EditCreditCard *controller = [segue destinationViewController];
            
            controller.creditCardSample = self.creditCardSample;
            controller.creditCardNumber = self.creditCardNumber;
            controller.creditCardExpiration = self.creditCardExpiration;
            controller.creditCardSecurityCode = self.creditCardSecurityCode;
            
        } 
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewCreditCards.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}



- (IBAction)openMenuAction {
    
    [self.navigationController.sideMenu toggleLeftSideMenu];

}
- (void)viewDidUnload {
    [self setBackView:nil];
    [self setTopLineView:nil];
    [self setDefaultTipText:nil];
    [self setDefaultTipClearButton:nil];
    [self setDefaultTipSegmentControl:nil];
    [super viewDidUnload];
}
- (IBAction)defaultTipClearAction {
    
    
    if (self.isEditingTip) {
        self.isEditingTip = NO;
        
        [self.defaultTipText resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect frame = self.view.frame;
            frame.origin.y += 216;
            self.view.frame = frame;
        }];
        if (self.defaultTipText.text == nil) {
            self.defaultTipText.text = @"";
        }
        
        self.defaultTipClearButton.text = @"Clear";
        
        self.defaultTipClearButton.tintColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
        self.defaultTipClearButton.textColor = [UIColor blackColor];

        NSString *customerId = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerId"];
        NSString *defaultTipName = [NSString stringWithFormat:@"%@%@", customerId, @"defaultTip"];
        [[NSUserDefaults standardUserDefaults] setValue:self.defaultTipText.text forKey:defaultTipName];
        [[NSUserDefaults standardUserDefaults] synchronize];

        
    }else{
        
        
        self.defaultTipText.text = @"";
        self.defaultTipSegmentControl.selectedSegmentIndex = -1;
        
        
        NSString *customerId = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerId"];
        NSString *defaultTipName = [NSString stringWithFormat:@"%@%@", customerId, @"defaultTip"];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:defaultTipName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
   
    
}
- (IBAction)paymentHistoryAction {
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"customerEmail"] length] > 0) {
        [self performSegueWithIdentifier:@"goHistory" sender:self];

    }else{
        self.logInAlert = [[UIAlertView alloc] initWithTitle:@"Not Signed In." message:@"Only signed in users view their payment history. Select 'Go Profile' to log in or create an account." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Go Profile", nil];
        [self.logInAlert show];
    }

}

- (IBAction)defaultTipSegmentControlValueChanged {
    
    
    NSString *defaultString = [[self.defaultTipSegmentControl titleForSegmentAtIndex:self.defaultTipSegmentControl.selectedSegmentIndex] stringByReplacingOccurrencesOfString:@"%" withString:@""];
    
    self.defaultTipText.text = defaultString;
    
    NSString *customerId = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerId"];
    NSString *defaultTipName = [NSString stringWithFormat:@"%@%@", customerId, @"defaultTip"];
    
    [[NSUserDefaults standardUserDefaults] setValue:defaultString forKey:defaultTipName];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
- (IBAction)defaultTipEditBegin {
    
    self.isEditingTip = YES;
    
    self.defaultTipClearButton.text = @"Save";
    
    self.defaultTipClearButton.tintColor = dutchDarkBlueColor;
    self.defaultTipClearButton.textColor = [UIColor whiteColor];
    [UIView animateWithDuration:0.3 animations:^{
       
        CGRect frame = self.view.frame;
        frame.origin.y -= 216;
        self.view.frame = frame;
    }];
}

- (IBAction)defaultTipEditChanged {
    
    self.defaultTipSegmentControl.selectedSegmentIndex = -1;
    
    
}
@end
