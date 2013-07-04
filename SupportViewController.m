//
//  SupportViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 3/27/13.
//
//

#import "SupportViewController.h"
#import "MFSideMenu.h"
#import "CorbelBoldLabel.h"
#import "rSkybox.h"
#import <QuartzCore/QuartzCore.h>
#import "ArcClient.h"

@interface SupportViewController ()

@end

@implementation SupportViewController

-(void)viewDidLoad{
    
    self.callButton.text = @"Call Us";
    self.emailButton.text = @"Send Us An Email";
   
    self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
    self.topLineView.layer.shadowRadius = 1;
    self.topLineView.layer.shadowOpacity = 0.2;
    self.topLineView.backgroundColor = dutchTopLineColor;
    self.backView.backgroundColor = dutchTopNavColor;
    
    
    
    [ArcClient trackEvent:@"SUPPORT_VIEW"];
    
    

}

- (IBAction)openMenuAction {
    [self.navigationController.sideMenu toggleLeftSideMenu];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	
    if (section == 0) {
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    @try {
        
        NSUInteger row = indexPath.row;
        NSUInteger section = indexPath.section;
        UITableViewCell *cell;
        
        if (section == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"contactUsCell"];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"supportCell"];
        }
        
        
        
        
        if (section == 1) {
            CorbelBoldLabel *supportLabel = (CorbelBoldLabel *)[cell.contentView viewWithTag:1];
            CorbelBoldLabel *infoLabel = (CorbelBoldLabel *)[cell.contentView viewWithTag:2];
            
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            NSString *phoneNumber = @"";
            NSString *emailAddress = @"";
            
            if (![prefs valueForKey:@"arcPhoneNumber"]) {
                [prefs setValue:@"630-215-6979" forKey:@"arcPhoneNumber"];
            }
            
            if (![prefs valueForKey:@"arcMail"]) {
                [prefs setValue:@"support@arcmobileapp.com" forKey:@"arcMail"];
            }
            
            phoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"arcPhoneNumber"];
            emailAddress = [[NSUserDefaults standardUserDefaults] valueForKey:@"arcMail"];
            
            
            if (row == 0) {
                
                supportLabel.text = @"Email";
                infoLabel.text = emailAddress;
            }else{
                supportLabel.text = @"Phone";
                infoLabel.text = phoneNumber;
            }

        }else{
            CorbelBoldLabel *supportLabel = (CorbelBoldLabel *)[cell.contentView viewWithTag:1];

            if (section == 0) {
                supportLabel.text = @"Help Videos";

            }else{
                if (row == 0) {
                    supportLabel.text = @"Feedback";

                }else{
                    supportLabel.text = @"Audio Feedback";

                }
            }
        }
       
        
        
        
        
        
        return cell;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SupportViewController.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        //Help
        UIViewController *customerService = [self.storyboard instantiateViewControllerWithIdentifier:@"help"];
        [self.navigationController pushViewController:customerService animated:YES];
    }else{
        //Customer Service
        UIViewController *customerService = [self.storyboard instantiateViewControllerWithIdentifier:@"customerService"];
        [self.navigationController pushViewController:customerService animated:YES];
    }
}


- (void)viewDidUnload {
    [self setCallButton:nil];
    [self setEmailButton:nil];
    [super viewDidUnload];
}
- (IBAction)callAction {
    
    @try {
        
        [rSkybox addEventToSession:@"phoneCallToArc"];
        
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]){
            
            NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"arcPhoneNumber"];
            
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
            
            
            
            NSString *url = [@"tel://" stringByAppendingString:phoneNumber];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            
            
            
        }else {
            
            NSString *message1 = @"You cannot make calls from this device.";
            UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"Invalid Device." message:message1 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert1 show];
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SupportViewController.call" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }

    
    
}
- (IBAction)emailAction {
    
    @try {
        
        [rSkybox addEventToSession:@"emailToArc"];
        
        if ([MFMailComposeViewController canSendMail]) {
            
            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
            mailViewController.mailComposeDelegate = self;
            [mailViewController setToRecipients:@[[[NSUserDefaults standardUserDefaults] valueForKey:@"arcMail"]]];
            
            [self presentModalViewController:mailViewController animated:YES];
            
        }else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Device." message:@"Your device cannot currently send email." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SupportViewController.email" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return @"Tutorials";
    }else if (section == 1){
        return @"Contact Us";
    }else{
        return @"Feedback";
    }
}
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    @try {
        
        switch (result)
        {
            case MFMailComposeResultCancelled:
                break;
            case MFMailComposeResultSent:
                
                break;
            case MFMailComposeResultFailed:
                
                break;
                
            case MFMailComposeResultSaved:
                
                break;
            default:
                
                break;
        }
        
        
        [self dismissModalViewControllerAnimated:YES];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SupportVC.mailComposeController" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


@end
