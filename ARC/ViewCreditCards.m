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

-(void)viewWillAppear:(BOOL)animated{
    
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.creditCards = [NSArray arrayWithArray:[mainDelegate getAllCreditCardsForCurrentCustomer]];
}

-(void)viewDidLoad{
    [rSkybox addEventToSession:@"viewCreditCardScreen"];
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	
	if ([self.creditCards count] == 0) {
        return 2;
    }else{
        return [self.creditCards count] + 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
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
            displayLabel.text = [NSString stringWithFormat:@"Credit Card:  %@", tmp.sample];
        }
    }
    
	return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
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

-(void)deselectRow:(NSIndexPath *)indexPath{
    [self.myTableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
    return @"Credit Cards";
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"editCard"]) {
        
        EditCreditCard *controller = [segue destinationViewController];
        
        controller.creditCardSample = self.creditCardSample;
        controller.creditCardNumber = self.creditCardNumber;
        controller.creditCardExpiration = self.creditCardExpiration;
        controller.creditCardSecurityCode = self.creditCardSecurityCode;

    } 
}



@end
