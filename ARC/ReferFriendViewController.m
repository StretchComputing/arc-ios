//
//  ReferFriendViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 11/29/12.
//
//

#import "ReferFriendViewController.h"
#import "CorbelTitleLabel.h"
#import "CorbelBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>
#import "ArcClient.h"
#import "rSkybox.h"

@interface ReferFriendViewController ()

@end

@implementation ReferFriendViewController


-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(referFriendComplete:) name:@"referFriendNotification" object:nil];

    
}


-(void)viewDidLoad{
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];
    
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    self.view.backgroundColor = [UIColor clearColor];
    double x = 1.0;
    UIColor *myColor = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Refer A Friend"];
    self.navigationItem.titleView = navLabel;
    
    CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Refer"];
    self.navigationItem.backBarButtonItem = temp;
    
}



- (IBAction)submit {
    
    self.errorLabel.text = @"";
    
    if (!self.emailAddress.text || [self.emailAddress.text isEqualToString:@""]) {
        
        self.errorLabel.text = @"*Please choose or enter an email address first";
        
    }else{
        [self.activity startAnimating];

        ArcClient *tmp = [[ArcClient alloc] init];
        [tmp referFriend:self.emailAddress.text];
    }
}


-(void)referFriendComplete:(NSNotification *)notification{
    @try {
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *status = [responseInfo valueForKey:@"status"];
        NSDictionary *apiResponse = [responseInfo valueForKey:@"apiResponse"];
        
        [self.activity stopAnimating];
     
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            //success
            self.errorLabel.text = @"";
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully invited your friend!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            [self.navigationController dismissModalViewControllerAnimated:YES];
            
            
        }else if([status isEqualToString:@"error"]){
            int errorCode = [[responseInfo valueForKey:@"error"] intValue];
            // TODO create static values maybe in ArcClient
            // TODO need real error code from Santiago
            if(errorCode == 999) {
                errorMsg = @"Can not find merchants.";
            } else {
                errorMsg = ARC_ERROR_MSG;
            }
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        self.errorLabel.text = errorMsg;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ReferFriendViewController.referFriendComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}





- (IBAction)cancelRefer:(id)sender {
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)endText {
}

- (IBAction)addContact {
    self.errorLabel.text = @"";
    self.multipleEmailArray = [NSMutableArray array];
    ABPeoplePickerNavigationController *picker =
	[[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.navigationBar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];
	
    [self presentModalViewController:picker animated:YES];
}

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}


-(NSString *)getType:(NSString *)typeLabel{
    
    if ([typeLabel isEqualToString:@"iPhone"]){
        return @"iPhone";
    }
    
    NSString *returnString = @"";
    
    NSArray *tmpArray = [typeLabel componentsSeparatedByString:@">"];
    
    NSString *tmpString = tmpArray[0];
    
    returnString = [tmpString substringFromIndex:4];
    
    return returnString;
    
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
    @try {
               
     
        
        NSString *emailAddress = @"";
        
        @try {
            ABMultiValueRef emails = (ABMultiValueRef) ABRecordCopyValue(person, kABPersonEmailProperty);
            
            NSArray *emailArray1 = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emails);
            
            if ([emailArray1 count] > 0) {
                emailAddress = emailArray1[0];
                self.multipleEmailArray = [NSMutableArray arrayWithArray:emailArray1];
                
                int countHere = ABMultiValueGetCount(emails);
                
                for(int i = 0; i < countHere; i++)
                {
                    @try {
                        NSString *test = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(emails, i);
                        
                        NSString *final = [self getType:test];
                        
                        [self.multipleEmailArrayLabels addObject:final];
                    }
                    @catch (NSException *exception) {
                        [self.multipleEmailArrayLabels addObject:@""];
                    }
                    
                    
                    
                }
                
            }
            
        }
        @catch (NSException *exception) {
                       
        }
        
    
    }
    @catch (NSException *exception) {
        
        
        
    }
    
    
    if ([self.multipleEmailArray count] > 0) {
        self.emailAddress.text = [self.multipleEmailArray objectAtIndex:0];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Email Address" message:@"The contact you selected did not have an email address, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    [self dismissModalViewControllerAnimated:YES];
	
    return NO;
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

@end
