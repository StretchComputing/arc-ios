//
//  RightViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 3/26/13.
//
//

#import "RightViewController.h"
#import "CorbelTextView.h"
#import "rSkybox.h"
#import <QuartzCore/QuartzCore.h>
#import "NumberLineButton.h"

@interface RightViewController ()

@end

@implementation RightViewController

-(void)viewDidLoad{
    
    [self setUpScrollView];
    
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
    self.payRemainingButton.tintColor = [UIColor colorWithRed:17.0/255.0 green:196.0/255.0 blue:29.0/215.0 alpha:1];
    
    self.alreadyPaidTable.delegate = self;
    self.alreadyPaidTable.dataSource = self;
    
    self.alreadyPaidTable.separatorColor = [UIColor blackColor];
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @try {
        
        
        return [self.paymentsArray count];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RightMenu.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        static NSString *alreadyPaidCell=@"alreadyPaidCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:alreadyPaidCell];
        
        
        LucidaBoldLabel *nameLabel = (LucidaBoldLabel *)[cell.contentView viewWithTag:1];
        LucidaBoldLabel *amountLabel = (LucidaBoldLabel *)[cell.contentView viewWithTag:2];
        CorbelTextView *notesText = (CorbelTextView *)[cell.contentView viewWithTag:3];
        

        NSUInteger row = [indexPath row];
        
        NSDictionary *payment = [self.paymentsArray objectAtIndex:row];
        
        nameLabel.text = [payment valueForKey:@"Name"];
        
        double amountDouble = [[payment valueForKey:@"Amount"] doubleValue];
        
        amountLabel.text = [NSString stringWithFormat:@"$%.2f", amountDouble];
        
        if ([payment valueForKey:@"Notes"] && [[payment valueForKey:@"Notes"] length] > 0) {
            notesText.hidden = NO;
            notesText.text = [payment valueForKey:@"Notes"];
            
            CGSize constraints = CGSizeMake(250, 900);
            CGSize totalSize = [[payment valueForKey:@"Notes"] sizeWithFont:[UIFont fontWithName:@"LucidaGrande" size:14] constrainedToSize:constraints];
            
            CGRect frame = notesText.frame;
            frame.size.height = totalSize.height + 15;
            notesText.frame = frame;
            
            
        }else{
            notesText.hidden = YES;
        }
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;

        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"RightMenu.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        
        NSDictionary *payment = [self.paymentsArray objectAtIndex:indexPath.row];
        
        if ([payment valueForKey:@"Notes"]) {
            if ([[payment valueForKey:@"Notes"] length] > 0) {
                
                CGSize constraints = CGSizeMake(250, 900);
                CGSize totalSize = [[payment valueForKey:@"Notes"] sizeWithFont:[UIFont fontWithName:@"LucidaGrande" size:14] constrainedToSize:constraints];
                
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
    [self.sideMenu toggleRightSideMenu];
    
    [self performSelector:@selector(payNow) withObject:nil afterDelay:0.4];
}


-(void)payNow{
    
    [self.invoiceController payNow:nil];
}


- (IBAction)cancelSplitAction {
    self.splitView.hidden = YES;
}

- (IBAction)saveSplitAction {
    
    self.splitView.hidden = YES;
    
    double newDue = [self.splitYourPaymentLabel.text doubleValue];
    
    self.invoiceController.totalLabel.text = [NSString stringWithFormat:@"$%.2f", newDue];
    self.invoiceController.totalLabel.text = [@"My Total:  " stringByAppendingString:self.invoiceController.totalLabel.text];
    
    [self.invoiceController deselectAllItems];
    [self.sideMenu toggleRightSideMenu];
    
    [self performSelector:@selector(payNow) withObject:nil afterDelay:0.4];

}





-(void)setUpScrollView{
    
    
    @try {
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
                size = 35;
            }else{
                size = 16;
            }
            
            LucidaBoldLabel *numberLabel = [[LucidaBoldLabel alloc] initWithFrame:CGRectMake(i * 45, 5, 45, 45) andSize:size];
            numberLabel.textAlignment = UITextAlignmentCenter;
            numberLabel.text = numberText;
            numberLabel.clipsToBounds = YES;
            numberLabel.userInteractionEnabled = YES;
            
            if (addButton) {
                NumberLineButton *numberButton = [NumberLineButton buttonWithType:UIButtonTypeCustom];
                numberButton.frame = CGRectMake(0, 0, 45, 45);
                numberButton.offset = i * 45;
                [numberButton addTarget:self action:@selector(scrollToNumber:) forControlEvents:UIControlEventTouchUpInside];
                [numberLabel addSubview:numberButton];
                
                UIView *rightCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 18, 5, 3)];
                rightCircle.backgroundColor = [UIColor blackColor];
                rightCircle.layer.cornerRadius = 6.0;
                [numberLabel addSubview:rightCircle];
                
            }
            
            [self.numberSliderScrollView addSubview:numberLabel];
            
            
            
            
            
            
            
        }
        
        self.numberSliderScrollView.contentSize = CGSizeMake(1080, 45);
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
        
        LucidaBoldLabel *myLabel = (LucidaBoldLabel *)[[self.numberSliderScrollView subviews] objectAtIndex:xValue/45];
        
        double yourPercent;
        
        if ([myLabel.text isEqualToString:@"-"]) {
            self.numberOfPeopleSelected = 0;
            yourPercent = 0;
            
        }else{
            self.numberOfPeopleSelected = [myLabel.text intValue];
            yourPercent = 1.0/self.numberOfPeopleSelected * 100;
            
        }
        
        
        double amountRemaining = self.myInvoice.amountDue - [self.myInvoice calculateAmountPaid];
        
        double myDue = amountRemaining * yourPercent / 100.0;
    
        self.splitYourPaymentLabel.text = [NSString stringWithFormat:@"%.2f", myDue];
        
        
        
        
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
                if ([LucidaBoldLabel class] == [[[self.numberSliderScrollView subviews] objectAtIndex:i] class]) {
                    LucidaBoldLabel *otherLabel = (LucidaBoldLabel *)[[self.numberSliderScrollView subviews] objectAtIndex:i];
                    [otherLabel setFont: [UIFont fontWithName: @"LucidaGrande-Bold" size:16]];
                    
                }
            }
        }
        
        LucidaBoldLabel *myLabel = (LucidaBoldLabel *)[[self.numberSliderScrollView subviews] objectAtIndex:index];
        [myLabel setFont: [UIFont fontWithName: @"LucidaGrande-Bold" size:35]];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"RightMenu.scrollViewDidScroll" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
    
    
}






@end
