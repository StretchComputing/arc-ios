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

@interface ViewCreditCards ()

@end

@implementation ViewCreditCards


-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)customerDeactivated{
    ArcAppDelegate *mainDelegate = [[UIApplication sharedApplication] delegate];
    mainDelegate.logout = @"true";
    [self.navigationController dismissModalViewControllerAnimated:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];
    
    @try {
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.creditCards = [NSArray arrayWithArray:[mainDelegate getAllCreditCardsForCurrentCustomer]];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ViewCreditCards.viewWillAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)viewDidLoad{
    @try {
        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Credit Cards"];
        self.navigationItem.titleView = navLabel;
        
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Cards"];
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
                displayLabel.text = [NSString stringWithFormat:@"%@", tmp.sample];
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
        
        int lastRow = 0;
        if ([self.creditCards count] == 0) {
            lastRow = 1;
        }else{
            lastRow = [self.creditCards count];
        }
        
        if (row == lastRow) {
            [self performSegueWithIdentifier:@"addCard" sender:self];
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



@end
