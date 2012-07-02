//
//  SettingsView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsView.h"
#import "ArcAppDelegate.h"
#import "NewJSON.h"
#import "ArcAppDelegate.h"
#import "DwollaAPI.h"
#import "RegisterDwollaView.h"

@interface SettingsView ()

@end

@implementation SettingsView
@synthesize serverData;
@synthesize pointsDisplayLabel;
@synthesize pointsProgressView;
@synthesize activity;
@synthesize dwollaAuthSwitch, fromDwolla, dwollaSuccess;

-(void)viewWillAppear:(BOOL)animated{
    [self performSelector:@selector(getPointsBalance)];
    
    NSString *dwollaAuthToken = @"";
    @try {
        dwollaAuthToken = [DwollaAPI getAccessToken];
    }
    @catch (NSException *exception) {
        dwollaAuthToken = nil;
    }
    
    if ((dwollaAuthToken == nil) || [dwollaAuthToken isEqualToString:@""]) {
        self.dwollaAuthSwitch.on = NO;
    }else{
        self.dwollaAuthSwitch.on = YES;
    }
    
    if (self.fromDwolla) {
        self.fromDwolla = NO;
        
        NSString *title = @"";
        NSString *message = @"";
        if (self.dwollaSuccess) {
            
            title = @"Success!";
            message = @"Congratulations! You are now authorized for Dwolla!";
            
        }else{
            
            title = @"Authorization Error";
            message = @"You were not successfully authorized for Dwolla.  Please try again";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
}
- (void)viewDidLoad
{
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0427221 green:0.380456 blue:0.785953 alpha:1.0];

    self.serverData = [NSMutableData data];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];

    
    if ((section == 1) && (row == 4)) {
       
        ArcAppDelegate *mainDelegate = [[UIApplication sharedApplication] delegate];
        mainDelegate.logout = @"true";
        [self.navigationController dismissModalViewControllerAnimated:NO];
    }
}


-(void)getPointsBalance{
    
    @try{
                
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *customerId = [mainDelegate getCustomerId];
        
        NSString *tmpUrl = [NSString stringWithFormat:@"http://68.57.205.193:8700/rest/v1/points/%@/balance", customerId];
                
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:tmpUrl]];
        [request setHTTPMethod: @"GET"];
        
        self.serverData = [NSMutableData data];
        [self.activity startAnimating];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate: self startImmediately: YES];
        
    }
    @catch (NSException *e) {
        
        //[rSkybox sendClientLog:@"getInvoiceFromNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
    
    
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)mdata {
    [self.serverData appendData:mdata]; 
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
        
    [self.activity stopAnimating];
    NSData *returnData = [NSData dataWithData:self.serverData];
    
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    
    NewSBJSON *jsonParser = [NewSBJSON new];
    NSDictionary *response = (NSDictionary *) [jsonParser objectWithString:returnString error:NULL];
    
    BOOL success = [[response valueForKey:@"Success"] boolValue];
    
    if (success) {
       
        int balance = [[response valueForKey:@"balance"] intValue];
        
        self.pointsDisplayLabel.text = [NSString stringWithFormat:@"Current Points: %d   -   Level %d", balance, 1];
        
        self.pointsProgressView.progress = (float)balance/900.00;
    }
   	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [self.activity stopAnimating];
    //self.errorLabel.text = @"*Error finding restaurants";
    //self.activityView.hidden = YES;
}




- (IBAction)cancel:(id)sender {
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)dwollaAuthSwitchSelected {
    
    if (self.dwollaAuthSwitch.on) {
       
        [self performSegueWithIdentifier:@"confirmDwolla" sender:self];
        
    }else{
       
        [DwollaAPI clearAccessToken];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([[segue identifier] isEqualToString:@"confirmDwolla"]) {
        
        RegisterDwollaView *detailViewController = [segue destinationViewController];
        detailViewController.fromRegister = YES;
    } 
}

@end
