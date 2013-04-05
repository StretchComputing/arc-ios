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

@interface RightViewController ()

@end

@implementation RightViewController

-(void)viewDidLoad{
    
    self.paymentsArray = [NSArray array];
    
    self.learnToSplitButton.text = @"Learn to split the bill!";
    
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
        
        NSLog(@"Class1: %@", [nameLabel class]);
        NSLog(@"Class2: %@", [amountLabel class]);
        NSLog(@"Class3: %@", [notesText class]);

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




@end
