//
//  GuestCreateAccount.m
//  ARC
//
//  Created by Nick Wroblewski on 4/21/13.
//
//

#import "GuestCreateAccount.h"
#import "ArcClient.h"
#import "rSkybox.h"

@interface GuestCreateAccount ()

@end

@implementation GuestCreateAccount

-(void)viewDidLoad{
    
    self.registerButton.textColor = [UIColor whiteColor];
    self.registerButton.text = @"Register";
    self.registerButton.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0 blue:125.0/255.0 alpha:1.0];
    
    self.noThanksButton.text = @"No Thanks";
    
}


- (IBAction)noThanksAction {
    
    [self performSegueWithIdentifier:@"goReview" sender:nil];
}

- (IBAction)registerAction {
}



- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	
    if (section == 0) {
        return 2;
    }
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    @try {
        static NSString *FirstLevelCell=@"FirstLevelCell";
        
        static NSInteger fieldTag = 1;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FirstLevelCell];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier: FirstLevelCell];
            
            CGRect frame;
            frame.origin.x = 10;
            frame.origin.y = 8;
            frame.size.height = 22;
            frame.size.width = 80;
            
            LucidaBoldLabel *fieldLabel = [[LucidaBoldLabel alloc] initWithFrame:frame];
            fieldLabel.tag = fieldTag;
            [cell.contentView addSubview:fieldLabel];
            
            
        }
        
        LucidaBoldLabel *fieldLabel = (LucidaBoldLabel *)[cell.contentView viewWithTag:fieldTag];
        
        fieldLabel.textColor = [UIColor blackColor];
        fieldLabel.backgroundColor = [UIColor clearColor];
        NSUInteger row = [indexPath row];
        NSUInteger section = [indexPath section];
        
        if (section == 0) {
            
            fieldLabel.frame = CGRectMake(10, 8, 80, 22);
            fieldLabel.font = [UIFont fontWithName:@"LucidaGrande-Bold" size:15];
            fieldLabel.textAlignment = UITextAlignmentLeft;
            
            if (row == 0) {
                fieldLabel.text = @"Email";
                
                [cell.contentView addSubview:self.username];
                self.username.placeholder = @"Email Address";
            }else if (row == 1){
                fieldLabel.text = @"Password";
                self.password.placeholder = @"Password";
                [cell.contentView addSubview:self.password];
                
            }
            
            [self.username becomeFirstResponder];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            fieldLabel.hidden = YES;
            
        }else{
            
            fieldLabel.frame = CGRectMake(0, 6, 298, 22);
            fieldLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
            fieldLabel.textAlignment = UITextAlignmentCenter;
            
            fieldLabel.text = @"How Arc Works";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        return cell;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"GuestCreateAccount.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}



@end
