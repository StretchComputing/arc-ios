//
//  InvoiceView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InvoiceView.h"

@interface InvoiceView ()

@end

@implementation InvoiceView
@synthesize subLabel;
@synthesize taxLabel;
@synthesize gratLabel;
@synthesize discLabel;
@synthesize amountLabel;
@synthesize totalLabel;
@synthesize discNameLabel;
@synthesize tipText;
@synthesize gratNameLabel;
@synthesize dividerView;
@synthesize myInvoice, myTableView, amountDue;


- (void)viewDidLoad
{
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    double serviceCharge = (self.myInvoice.baseAmount * self.myInvoice.serviceCharge);
    double tax = (self.myInvoice.baseAmount * self.myInvoice.tax);
    double discount = (self.myInvoice.baseAmount * self.myInvoice.discount);


    self.subLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.baseAmount];
    self.taxLabel.text = [NSString stringWithFormat:@"$%.2f", tax];
    self.gratLabel.text = [NSString stringWithFormat:@"$%.2f", serviceCharge];
    self.discLabel.text = [NSString stringWithFormat:@"- $%.2f", discount];
    
    
    
    self.amountDue = self.myInvoice.baseAmount + serviceCharge + tax - discount;
    
    self.amountLabel.text = [NSString stringWithFormat:@"$%.2f", self.amountDue];
    
    self.totalLabel.text = [NSString stringWithFormat:@"Total: $%.2f", self.amountDue];

    
    [super viewDidLoad];
    
    [self.myTableView reloadData];
	// Do any additional setup after loading the view.
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	
	return [self.myInvoice.items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	static NSString *FirstLevelCell=@"FirstLevelCell";
	
	static NSInteger itemTag = 1;
    static NSInteger numberTag = 2;
	static NSInteger priceTag = 3;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FirstLevelCell];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier: FirstLevelCell];
		
	
		
		UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, 185, 20)];
		itemLabel.tag = itemTag;
		[cell.contentView addSubview:itemLabel];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(187, 2, 60, 20)];
		priceLabel.tag = priceTag;
		[cell.contentView addSubview:priceLabel];
        
        UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(251, 2, 25, 20)];
		numberLabel.tag = numberTag;
		[cell.contentView addSubview:numberLabel];
        
  
		
        
	}
	
	UILabel *itemLabel = (UILabel *)[cell.contentView viewWithTag:itemTag];
    UILabel *numberLabel = (UILabel *)[cell.contentView viewWithTag:numberTag];
	UILabel *priceLabel = (UILabel *)[cell.contentView viewWithTag:priceTag];

	
    itemLabel.backgroundColor = [UIColor clearColor];
    numberLabel.backgroundColor = [UIColor clearColor];
    priceLabel.backgroundColor = [UIColor clearColor];
    
    itemLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    numberLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    priceLabel.font = [UIFont fontWithName:@"Helvetica" size:14];

    priceLabel.textAlignment = UITextAlignmentCenter;
    numberLabel.textAlignment = UITextAlignmentCenter;

	NSUInteger row = [indexPath row];
    
    NSDictionary *itemDictionary = [self.myInvoice.items objectAtIndex:row];
    
    itemLabel.text = [itemDictionary valueForKey:@"Description"];
    
    double value = [[itemDictionary valueForKey:@"Value"] doubleValue];
    priceLabel.text = [NSString stringWithFormat:@"$%.2f", value];
        
    numberLabel.text = [NSString stringWithFormat:@"%d", [[itemDictionary valueForKey:@"Amount"] intValue]];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 24;
}


- (IBAction)payNow:(id)sender {
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Select Payment Method" delegate:self cancelButtonTitle:@"Back" destructiveButtonTitle:nil otherButtonTitles:@"Dwolla", @"PayPal", @"Credit Card *7837", nil];
    
    action.actionSheetStyle = UIActionSheetStyleDefault;
    [action showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        //Dwolla
        
        [self performSegueWithIdentifier:@"goPayDwolla" sender:self];
    }
    
}

- (IBAction)editBegin:(id)sender {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    self.view.frame = CGRectMake(0, -200, 320, 416);
    
    
    [UIView commitAnimations];
}

- (IBAction)editEnd:(id)sender {
    
    double tip = [self.tipText.text doubleValue];
  
    self.tipText.text = [NSString stringWithFormat:@"%.2f", tip];
   
    self.totalLabel.text = [NSString stringWithFormat:@"Total: $%.2f", self.amountDue + tip];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    
    self.view.frame = CGRectMake(0, 0, 320, 416);
    
    
    [UIView commitAnimations];

    

    

}
- (void)viewDidUnload {
    [self setTipText:nil];
    [super viewDidUnload];
}
@end
