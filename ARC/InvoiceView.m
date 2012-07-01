//
//  InvoiceView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InvoiceView.h"
#import "DwollaPayment.h"

@interface InvoiceView ()

@end

@implementation InvoiceView
@synthesize bottomHalfView;
@synthesize scrollView;
@synthesize dividerLabel;
@synthesize subLabel;
@synthesize taxLabel;
@synthesize gratLabel;
@synthesize discLabel;
@synthesize amountLabel;
@synthesize totalLabel;
@synthesize discNameLabel;
@synthesize tipText;
@synthesize tipSegment;
@synthesize amountNameLabel;
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
    
    //Set up scroll view sizes
    
    int tableCount = [self.myInvoice.items count];
    
    int tableHeight = tableCount * 24 + tableCount + 10;
    
    self.myTableView.frame = CGRectMake(0, 20, 300, tableHeight);
    
    self.dividerLabel.frame = CGRectMake(0, tableHeight + 10, 300, 21);
    int bottomViewY = tableHeight + 20;
    
    if (bottomViewY < 120) {
        bottomViewY = 120;
        int height = (120 - tableHeight)/2 + tableHeight;
        self.dividerLabel.frame = CGRectMake(0, height, 300, 21);
    }
    
    self.bottomHalfView.frame = CGRectMake(0, bottomViewY, 300, 134);
    
    [self.scrollView setContentSize:CGSizeMake(300, bottomViewY + 140)];
    
    
    //bottom view
    int movedown = 0;
    if (self.myInvoice.serviceCharge == 0.0) {
        self.gratLabel.hidden = YES;
        self.gratNameLabel.hidden = YES;
        movedown += 15;
    }
    
    if (self.myInvoice.discount == 0.0) {
        self.discLabel.hidden = YES;
        self.discNameLabel.hidden = YES;
        movedown +=15;
    }else{
        
        if (self.myInvoice.serviceCharge == 0.0) {
            self.discNameLabel.frame = CGRectMake(10, 52, 95, 21);
            self.discLabel.frame = CGRectMake(219, 52, 71, 21);
        }
    }
    
    CGRect frame = self.bottomHalfView.frame;
    frame.origin.y += movedown;
    frame.size.height -= movedown;
    self.bottomHalfView.frame = frame;
    
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
		
	
		
		UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 2, 207, 20)];
		itemLabel.tag = itemTag;
		[cell.contentView addSubview:itemLabel];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(234, 2, 60, 20)];
		priceLabel.tag = priceTag;
		[cell.contentView addSubview:priceLabel];
        
        UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 2, 20, 20)];
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

    priceLabel.textAlignment = UITextAlignmentRight;
    numberLabel.textAlignment = UITextAlignmentLeft;

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
    
    [self.tipText resignFirstResponder];
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Select Payment Method" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Dwolla", @"PayPal", @"Credit Card *7837", nil];
    
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
    
    self.view.frame = CGRectMake(0, -165, 320, 416);
    
    
    [UIView commitAnimations];
}

- (IBAction)editEnd:(id)sender {
    
    double tip = [self.tipText.text doubleValue];
    
    if (tip < 0.0) {
        tip = 0.0;
    }
  
    self.tipText.text = [NSString stringWithFormat:@"%.2f", tip];
   
    self.totalLabel.text = [NSString stringWithFormat:@"Total: $%.2f", self.amountDue + tip];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    
    self.view.frame = CGRectMake(0, 0, 320, 416);
    
    
    [UIView commitAnimations];

    

    

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([[segue identifier] isEqualToString:@"goPayDwolla"]) {
                
        DwollaPayment *controller = [segue destinationViewController];
        controller.totalAmount = [[NSString stringWithFormat:@"%f", self.amountDue] doubleValue];
        controller.gratuity = [self.tipText.text doubleValue];
        controller.invoiceId = self.myInvoice.invoiceId;
  
       
    } 
}


- (IBAction)segmentSelect {
    
    [self performSelector:@selector(resetSegment) withObject:nil afterDelay:0.2];

    double tipPercent = 0.0;
    if (self.tipSegment.selectedSegmentIndex == 0) {
        tipPercent = .10;
    }else if (self.tipSegment.selectedSegmentIndex == 1){
        tipPercent = .15;
    }else{
        tipPercent = .20;
    }
    
    double tipAmount = tipPercent * self.amountDue;
        
    self.tipText.text = [NSString stringWithFormat:@"%.2f", tipAmount];
    
    self.totalLabel.text = [NSString stringWithFormat:@"Total: $%.2f", self.amountDue + tipAmount];
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    
    self.view.frame = CGRectMake(0, 0, 320, 416);
    [self.tipText resignFirstResponder];
    
    
    [UIView commitAnimations];
    
    
    
}

-(void)resetSegment{
    self.tipSegment.selectedSegmentIndex = -1;
}
- (void)viewDidUnload {
    [self setBottomHalfView:nil];
    [self setScrollView:nil];
    [self setDividerLabel:nil];
    [self setAmountNameLabel:nil];
    [super viewDidUnload];
}
@end
