//
//  RightViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 3/26/13.
//
//

#import "RightViewController.h"
#import "SteelfishTextView.h"
#import "rSkybox.h"
#import <QuartzCore/QuartzCore.h>
#import "NumberLineButton.h"
#import "SteelfishLabel.h"
#import "ArcAppDelegate.h"
#import "SteelfishLabel.h"
#import "ArcUtility.h"

@interface RightViewController ()

@end

@implementation RightViewController


int const MAIN_MENU_ITEMS = 5;  //How many maine menu items (+ headers)

-(void)didBeginClose:(NSNotification *)notification{
    
    [self.payDollarTextView resignFirstResponder];
    self.expandedElement = @"";
    self.payDollarTextView.text = @"";
    [self.numberSliderScrollView setContentOffset:CGPointMake(0, 0)];
    self.splitYourPaymentLabel.text = @"You Pay: $0.00";
    [self.mainTableView reloadData];
}

   

-(void)viewDidLoad{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginClose:) name:@"RightMenuClose" object:nil];
    
    self.payDollarTextView = [[UITextView alloc] init];
    self.payPercentLabel = [[SteelfishBoldLabel alloc] init];
    self.myScrollView = [[UIScrollView alloc] init];
    self.splitYourPaymentLabel = [[SteelfishBoldLabel alloc] init];
    self.expandedElement = @"";
    
   // [self setUpScrollView];
    
    self.saveSplitButton.textColor = [UIColor whiteColor];
    self.saveSplitButton.text = @"Save";
    self.saveSplitButton.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0 blue:125.0/255.0 alpha:1.0];
    
    
    self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
    self.topLineView.layer.shadowRadius = 1;
    self.topLineView.layer.shadowOpacity = 0.5;
    
    self.splitTopLineView.layer.shadowOffset = CGSizeMake(0, 1);
    self.splitTopLineView.layer.shadowRadius = 1;
    self.splitTopLineView.layer.shadowOpacity = 0.5;
    
    
    self.paymentsArray = [NSArray array];
    
    self.splitRemainingButton.text = @"Split Remaining";
    
    self.payRemainingButton.text = @"Pay Remaining";
    self.payRemainingButton.textColor = [UIColor whiteColor];
    self.payRemainingButton.textShadowColor = [UIColor darkGrayColor];
    self.payRemainingButton.tintColor = dutchGreenColor;
    
    self.alreadyPaidTable.delegate = self;
    self.alreadyPaidTable.dataSource = self;
    
    self.alreadyPaidTable.separatorColor = [UIColor blackColor];
    
    [self.mainTableView reloadData];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @try {
        
        if (tableView == self.mainTableView) {
            if ([self.expandedElement isEqualToString:@""]) {
                return MAIN_MENU_ITEMS;
            }else if ([self.expandedElement isEqualToString:@"alreadyPaid"]){
                
                if ([self.paymentsArray count] == 0) {
                    return (MAIN_MENU_ITEMS + 1);

                }else{
                    return (MAIN_MENU_ITEMS + [self.paymentsArray count]);

                }
            }else if ([self.expandedElement isEqualToString:@"splitDollar"] || [self.expandedElement isEqualToString:@"splitPercent"]){
                return MAIN_MENU_ITEMS + 1;
            }
        }
        
        if ([self.paymentsArray count] == 0) {
            return 1;
        }
        return [self.paymentsArray count];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RightMenu.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)payPercent{
    
    NSString *amount = [self.splitYourPaymentLabel.text stringByReplacingOccurrencesOfString:@"You Pay: $" withString:@""];
    double newDue = [amount doubleValue];

    

    if (newDue > 0) {
        self.invoiceController.splitMyDue = newDue;
        [self.invoiceController splitSaveAction];
        [self.sideMenu toggleRightSideMenu];
        
        
    }
    
    
    /*
    if (newDue > 0) {
        
        double amountRemaining = self.myInvoice.amountDue - [self.myInvoice calculateAmountPaid];
        
        if (newDue > amountRemaining) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Over Payment" message:@"You cannot pay more than is remaining." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }else{
            self.invoiceController.splitMyDue = newDue;
            [self.invoiceController splitSaveAction];
            [self.sideMenu toggleRightSideMenu];
        }
      
        
        
    }
    */
}
-(void)payDollar{
    
    [self.payDollarTextView resignFirstResponder];
    double myDouble = [self.payDollarTextView.text doubleValue];
    if (myDouble > 0) {
        self.invoiceController.splitMyDue = myDouble;
        [self.invoiceController splitSaveAction];
        [self.sideMenu toggleRightSideMenu];


    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        if (tableView == self.mainTableView){
            
            BOOL isHeader = NO;
            
            static NSString *headerCell=@"headerCell";
            static NSString *menuCell=@"menuCell";
            static NSString *dollarSplitCell=@"dollarSplitCell";
            static NSString *paidCell=@"paidCell";

            static NSString *percentSplitCell = @"percentSplitCell";

            UITableViewCell *cell;
            
            if ([self.expandedElement isEqualToString:@"splitDollar"]) {
                
                if (indexPath.row == 0 || indexPath.row == 4) {
                    isHeader = YES;
                    cell = [tableView dequeueReusableCellWithIdentifier:headerCell];
                }else if (indexPath.row == 2){
                    cell = [tableView dequeueReusableCellWithIdentifier:dollarSplitCell];
                }else{
                    cell = [tableView dequeueReusableCellWithIdentifier:menuCell];

                }
                
                
            }else if ([self.expandedElement isEqualToString:@"splitPercent"]){
                
                
                if (indexPath.row == 0 || indexPath.row == 4) {
                    isHeader = YES;
                    cell = [tableView dequeueReusableCellWithIdentifier:headerCell];
                }else if (indexPath.row == 3){
                    cell = [tableView dequeueReusableCellWithIdentifier:percentSplitCell];
                }else{
                    cell = [tableView dequeueReusableCellWithIdentifier:menuCell];
                    
                }
                
                
            }else if ([self.expandedElement isEqualToString:@"alreadyPaid"]){
                
                if (indexPath.row == 0 || indexPath.row == 3) {
                    isHeader = YES;
                    cell = [tableView dequeueReusableCellWithIdentifier:headerCell];
                }else if (indexPath.row >= 5){
                    cell = [tableView dequeueReusableCellWithIdentifier:paidCell];
                }else{
                    cell = [tableView dequeueReusableCellWithIdentifier:menuCell];
                    
                }
                
                
            }else{
                if (indexPath.row == 0 || indexPath.row == 3) {
                    isHeader = YES;
                    cell = [tableView dequeueReusableCellWithIdentifier:headerCell];
                }else{
                    cell = [tableView dequeueReusableCellWithIdentifier:menuCell];
                }
            }
            
            
            
            NSString *nameLabelString = @"";
           
            if (isHeader) {
                
                SteelfishLabel *nameLabel = (SteelfishLabel *)[cell.contentView viewWithTag:1];

                if (indexPath.row == 0){
                    nameLabel.text = @"SPLIT";
                }else{
                    nameLabel.text = @"INVOICE";
                }
                
                
            }else{
                SteelfishBoldLabel *nameLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:1];

                
                if ([self.expandedElement isEqualToString:@"splitDollar"]) {
                    
                    if (indexPath.row == 1) {
                       nameLabelString =  nameLabel.text = @"Split by Dollar Amount";
                    }else if (indexPath.row == 3){
                        nameLabelString = nameLabel.text = @"Split by # People";
                    }else if (indexPath.row == 5){
                        nameLabelString = nameLabel.text = @"See Who Paid";
                    }else if (indexPath.row == 2){
                        
                        UITextView *myTextView = (UITextView *) [cell.contentView viewWithTag:2];
                        self.payDollarTextView = myTextView;
                        [myTextView resignFirstResponder];
                        [myTextView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
                        
                        NVUIGradientButton *payDollarButton = (NVUIGradientButton *) [cell.contentView viewWithTag:3];
                        payDollarButton.tintColor = dutchGreenColor;
                        payDollarButton.text = @"Pay This Amount";
                        payDollarButton.textColor = [UIColor whiteColor];
                        [payDollarButton addTarget:self action:@selector(payDollar) forControlEvents:UIControlEventTouchUpInside];
                    }
                    
                    
                }else if ([self.expandedElement isEqualToString:@"splitPercent"]){
                    
                    
                    if (indexPath.row == 1) {
                        nameLabelString = nameLabel.text = @"Split by Dollar Amount";
                    }else if (indexPath.row == 2){
                        nameLabelString = nameLabel.text = @"Split by # People";
                    }else if (indexPath.row == 5){
                        nameLabelString = nameLabel.text = @"See Who Paid";
                    }else if (indexPath.row == 3){
                        
                        
                        UIScrollView *theScroll = (UIScrollView *) [cell.contentView viewWithTag:2];
                        self.numberSliderScrollView = theScroll;
                        
                        [self setUpScrollView];

                        SteelfishBoldLabel *myLabel = (SteelfishBoldLabel *) [cell.contentView viewWithTag:3];
                        self.splitYourPaymentLabel = myLabel;
                        
                        NVUIGradientButton *payPercentButton = (NVUIGradientButton *) [cell.contentView viewWithTag:4];
                        payPercentButton.tintColor = dutchGreenColor;
                        payPercentButton.text = @"Pay This Amount";
                        payPercentButton.textColor = [UIColor whiteColor];
                        [payPercentButton addTarget:self action:@selector(payPercent) forControlEvents:UIControlEventTouchUpInside];
                        
                        
                        
                        
                    }
                    
                    
                }else if ([self.expandedElement isEqualToString:@"alreadyPaid"]){
                    
                    if (indexPath.row == 1) {
                        nameLabelString = nameLabel.text = @"Split by Dollar Amount";
                    }else if (indexPath.row == 2){
                        nameLabelString = nameLabel.text = @"Split by # People";
                    }else if (indexPath.row == 4){
                        nameLabelString = nameLabel.text = @"See Who Paid";
                    }else{
                        //Rows for the who paid.
                        
                        SteelfishBoldLabel *nameLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:1];
                        SteelfishBoldLabel *amountLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:2];
                        SteelfishLabel *notesLabel = (SteelfishLabel *)[cell.contentView viewWithTag:3];
                        
                        
                        if ([self.paymentsArray count] == 0) {
                            
                            nameLabel.text = @"No payments yet.";
                            amountLabel.text = @"";
                            notesLabel.text = @"";
                            
                        }else{
                            NSDictionary *payment = [self.paymentsArray objectAtIndex:indexPath.row - 5];
                            
                            nameLabel.text = [payment valueForKey:@"Name"];
                            
                            double amountDouble = [[payment valueForKey:@"Amount"] doubleValue];
                            
                            amountLabel.text = [NSString stringWithFormat:@"$%.2f", amountDouble];
                            
                            if ([payment valueForKey:@"Notes"] && [[payment valueForKey:@"Notes"] length] > 0) {
                                notesLabel.hidden = NO;
                                notesLabel.text = [payment valueForKey:@"Notes"];
                             
                                
                            }else{
                                notesLabel.hidden = YES;
                            }
                        }
                        
                        
                        
                        
                      
                    }
                    
                    
                }else{
                    if (indexPath.row == 1) {
                        nameLabelString = nameLabel.text = @"Split by Dollar Amount";
                    }else if (indexPath.row == 2){
                        nameLabelString = nameLabel.text = @"Split by # People";
                    }else if (indexPath.row == 4){
                        nameLabelString = nameLabel.text = @"See Who Paid";
                    }
                }
                
                
               
            }
            
           
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]];

            double color;
            if (isHeader) {
                color = 31.0/255.0;
            }else{
                
                if ([self.expandedElement isEqualToString:@"splitDollar"] && [nameLabelString isEqualToString:@"Split by Dollar Amount"]) {
                    [cell.contentView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];

                }else if ([self.expandedElement isEqualToString:@"splitPercent"] && [nameLabelString isEqualToString:@"Split by # People"]) {
                    [cell.contentView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];

                } else if ([self.expandedElement isEqualToString:@"alreadyPaid"] && [nameLabelString isEqualToString:@"See Who Paid"]) {
                    [cell.contentView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];

                }else if ([self.expandedElement isEqualToString:@"splitDollar"] && indexPath.row == 2) {
                    [cell.contentView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
                }else if ([self.expandedElement isEqualToString:@"splitPercent"] && indexPath.row == 3) {
                    [cell.contentView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
                }else if ([self.expandedElement isEqualToString:@"alreadyPaid"] && indexPath.row >= 5) {
                    [cell.contentView setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
                }else{
                    color = 26.0/255.0;

                }
            }
            
           // [cell.contentView setBackgroundColor:[UIColor clearColor]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
            
            
        }else{
            static NSString *alreadyPaidCell=@"alreadyPaidCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:alreadyPaidCell];
            
            
            SteelfishBoldLabel *nameLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:1];
            SteelfishBoldLabel *amountLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:2];
            SteelfishTextView *notesText = (SteelfishTextView *)[cell.contentView viewWithTag:3];
            
            
            NSUInteger row = [indexPath row];
            
            NSDictionary *payment = [self.paymentsArray objectAtIndex:row];
            
            nameLabel.text = [payment valueForKey:@"Name"];
            
            double amountDouble = [[payment valueForKey:@"Amount"] doubleValue];
            
            amountLabel.text = [NSString stringWithFormat:@"$%.2f", amountDouble];
            
            if ([payment valueForKey:@"Notes"] && [[payment valueForKey:@"Notes"] length] > 0) {
                notesText.hidden = NO;
                notesText.text = [payment valueForKey:@"Notes"];
                
                CGSize constraints = CGSizeMake(250, 900);
                CGSize totalSize = [[payment valueForKey:@"Notes"] sizeWithFont:[UIFont fontWithName:FONT_REGULAR size:14] constrainedToSize:constraints];
                
                CGRect frame = notesText.frame;
                frame.size.height = totalSize.height + 15;
                notesText.frame = frame;
                
                
            }else{
                notesText.hidden = YES;
            }
            
           
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
  

        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RightMenu.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        
        if (tableView == self.mainTableView){
            if ([self.expandedElement isEqualToString:@"splitDollar"]) {
                
                if (indexPath.row == 0 || indexPath.row == 4) {
                    return 30;
                }else if (indexPath.row == 2){
                    return 176;
                }
                
                
            }else if ([self.expandedElement isEqualToString:@"splitPercent"]){
                
                
                if (indexPath.row == 0 || indexPath.row == 4) {
                    return 30;
                }else if (indexPath.row == 3){
                    return 190;
                }
                
                
            }else if ([self.expandedElement isEqualToString:@"alreadyPaid"]){
                
                if (indexPath.row == 0 || indexPath.row == 3) {
                    return 30;
                }else if (indexPath.row >= 5){
                    return 63;
                }
                
                
            }else{
                if (indexPath.row == 0 || indexPath.row == 3) {
                    return 30;
                }
            }
            
            return 44;
        }
        
        if ([self.paymentsArray count] == 0) {
            return 33;
        }
        NSDictionary *payment = [self.paymentsArray objectAtIndex:indexPath.row];
        
        if ([payment valueForKey:@"Notes"]) {
            if ([[payment valueForKey:@"Notes"] length] > 0) {
                
                CGSize constraints = CGSizeMake(250, 900);
                CGSize totalSize = [[payment valueForKey:@"Notes"] sizeWithFont:[UIFont fontWithName:FONT_REGULAR size:14] constrainedToSize:constraints];
                
                return 25 + totalSize.height + 15;
                
            }
        }
        return 33;
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RightMenu.heightForRow" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
    
}




- (IBAction)splitRemainingAction {
    
    self.splitView.hidden = NO;
}

-(void)payRemainingAction{
    
    self.splitView.hidden = YES;
    [self.invoiceController showFullTotal];
    [self.invoiceController deselectAllItems];
    [self.invoiceController payNow:nil];

    
    [self performSelector:@selector(payNow) withObject:nil afterDelay:0.4];
}


-(void)payNow{

    [self.sideMenu toggleRightSideMenu];

}


- (IBAction)cancelSplitAction {
    self.splitView.hidden = YES;
}

- (IBAction)saveSplitAction {
    
    self.splitView.hidden = YES;
    
    NSString *amount = [self.splitYourPaymentLabel.text stringByReplacingOccurrencesOfString:@"You Pay: $" withString:@""];
    double newDue = [amount doubleValue];
    
    self.invoiceController.totalLabel.text = [NSString stringWithFormat:@"$%.2f", newDue];
    self.invoiceController.totalLabel.text = [@"My Total:  " stringByAppendingString:self.invoiceController.totalLabel.text];
    
    [self.invoiceController deselectAllItems];
    [self.sideMenu toggleRightSideMenu];
    
    [self performSelector:@selector(payNow) withObject:nil afterDelay:0.4];

}





-(void)setUpScrollView{
    
    
    @try {
        
        for (UIView *view in [self.numberSliderScrollView subviews]) {
            [view removeFromSuperview];
        }
        for (int i = 0; i < 22; i++) {
            
            BOOL addButton = NO;
            NSString *numberText;
            if ((i < 3) || (i > 21)) {
                if (i == 2) {
                    numberText = @"-";
                }else{
                    numberText = @"";
                }
            }else{
                addButton = YES;
                numberText = [NSString stringWithFormat:@"%d", i-1];
            }
            
            int size;
            if (i == 2) {
                size = 38;
            }else{
                size = 16;
            }
            
            SteelfishBoldLabel *numberLabel = [[SteelfishBoldLabel alloc] initWithFrame:CGRectMake(i * 45, 5, 45, 45) andSize:size];
            numberLabel.textAlignment = UITextAlignmentCenter;
            numberLabel.text = numberText;
            numberLabel.clipsToBounds = YES;
            numberLabel.textColor = dutchDarkBlueColor;
            numberLabel.userInteractionEnabled = YES;
            
            if (addButton) {
                NumberLineButton *numberButton = [NumberLineButton buttonWithType:UIButtonTypeCustom];
                numberButton.frame = CGRectMake(0, 0, 45, 45);
                numberButton.offset = i * 45;
                [numberButton addTarget:self action:@selector(scrollToNumber:) forControlEvents:UIControlEventTouchUpInside];
                [numberLabel addSubview:numberButton];
                
                UIView *rightCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 18, 5, 3)];
                rightCircle.backgroundColor = dutchDarkBlueColor;
                rightCircle.layer.cornerRadius = 6.0;
                [numberLabel addSubview:rightCircle];
                
            }
            
            [self.numberSliderScrollView addSubview:numberLabel];
            
            
            
            
            
            
            
        }
        
        self.numberSliderScrollView.contentSize = CGSizeMake(1080, 0);
        [self.numberSliderScrollView setContentOffset:CGPointMake(0, 0)];
        self.numberSliderScrollView.backgroundColor = [UIColor clearColor];
        self.numberSliderScrollView.delegate = self;
        self.numberSliderScrollView.showsHorizontalScrollIndicator = NO;
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RightMenu.setUpScrollView" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
    
}


-(void)setValueForOffset:(int)offset{
    
    @try {
        int xValue = offset + 90;
        
        SteelfishBoldLabel *myLabel = (SteelfishBoldLabel *)[[self.numberSliderScrollView subviews] objectAtIndex:xValue/45];
        
        double yourPercent;
        
        if ([myLabel.text isEqualToString:@"-"]) {
            self.numberOfPeopleSelected = 0;
            yourPercent = 0;
            
        }else{
            self.numberOfPeopleSelected = [myLabel.text intValue];
            yourPercent = 1.0/self.numberOfPeopleSelected * 100;
            
        }
        
        
        double amountRemaining = self.myInvoice.amountDue;
        
        double myDue = amountRemaining * yourPercent / 100.0;
        myDue = [ArcUtility roundUpToNearestPenny:myDue];
        
        self.splitYourPaymentLabel.text = [NSString stringWithFormat:@"You Pay: $%.2f", myDue];
        
        
        
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RightMenu.setValueForOffset" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
}

-(void)scrollToNumber:(id)sender{
    
    @try {
        NumberLineButton *myButton = (NumberLineButton *)sender;
        
        int newOffset = myButton.offset - 90;
        [self.numberSliderScrollView setContentOffset:CGPointMake(newOffset, 0) animated:YES];
        [self setValueForOffset:newOffset];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RightMenu.scrollToNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
    
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    
    @try {
        NSLog(@"Velocitiy: %f", velocity.x);
        
        CGFloat xOffset = targetContentOffset->x;
        int intOffset = round(xOffset);
        
        int whole = floor(intOffset/45.0);
        
        int remainder = intOffset % 45;
        
        if (remainder >= 22) {
            whole++;
        }
        
        int newOffset = 45 * whole;
        
        if (velocity.x == 0) {
            [self.numberSliderScrollView setContentOffset:CGPointMake(newOffset, 0) animated:YES];
            [self setValueForOffset:newOffset];
        }
        
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RightMenu.scrollViewWillEndDragging" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    @try {
        CGFloat xOffset = scrollView.contentOffset.x;
        int intOffset = round(xOffset);
        
        int whole = floor(intOffset/45.0);
        
        int remainder = intOffset % 45;
        
        if (remainder >= 22) {
            whole++;
        }
        
        int newOffset = 45 * whole;
        
        [self.numberSliderScrollView setContentOffset:CGPointMake(newOffset, 0) animated:YES];
        [self setValueForOffset:newOffset];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RightMenu.scrollViewDidEndDecelerating" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    @try {
        CGFloat xOffset = scrollView.contentOffset.x;
        xOffset +=23;
        
        int index = floor(xOffset/45.0);
        index = index + 2;
        
        for (int i = 0; i < [[self.numberSliderScrollView subviews] count]; i++) {
            
            if (i != index) {
                if ([SteelfishBoldLabel class] == [[[self.numberSliderScrollView subviews] objectAtIndex:i] class]) {
                    SteelfishBoldLabel *otherLabel = (SteelfishBoldLabel *)[[self.numberSliderScrollView subviews] objectAtIndex:i];
                    [otherLabel setFont: [UIFont fontWithName:FONT_BOLD size:16]];
                    
                }
            }
        }
        
        if (index < [[self.numberSliderScrollView subviews] count]) {
            SteelfishBoldLabel *myLabel = (SteelfishBoldLabel *)[[self.numberSliderScrollView subviews] objectAtIndex:index];
            [myLabel setFont: [UIFont fontWithName:FONT_BOLD size:35]];
        }
       
    }
    @catch (NSException *exception) {
        NSLog(@"RSKYBOX");
        //[rSkybox sendClientLog:@"RightMenu.scrollViewDidScroll" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (tableView == self.mainTableView) {
        
        self.mainTableView.scrollEnabled = NO;
        if (indexPath.row == 1) {
            if ([self.expandedElement isEqualToString:@"splitDollar"]) {
                self.expandedElement = @"";
            }else{
                self.expandedElement = @"splitDollar";

            }

        }else{
            
            int percentIndex = 2;
            int paidIndex = 4;
            
            if ([self.expandedElement isEqualToString:@"splitDollar"]) {
                percentIndex = 3;
                paidIndex = 5;

            }
            
            if ([self.expandedElement isEqualToString:@"splitPercent"]) {
                paidIndex = 5;

            }
            
            if (indexPath.row == percentIndex){
                if ([self.expandedElement isEqualToString:@"splitPercent"]) {
                    self.expandedElement = @"";
                }else{
                    self.expandedElement = @"splitPercent";
                    
                }
            }else if (indexPath.row == paidIndex){
                if ([self.expandedElement isEqualToString:@"alreadyPaid"]) {
                    self.expandedElement = @"";
                }else{
                    self.mainTableView.scrollEnabled = YES;

                    self.expandedElement = @"alreadyPaid";
                    
                }
            }
            
            
        }
        
        [self.mainTableView reloadData];
    }
}


- (void)viewDidUnload {
    [self setMainTableView:nil];
    [super viewDidUnload];
}
@end
