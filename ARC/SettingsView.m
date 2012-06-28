//
//  SettingsView.m
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsView.h"
#import "AppDelegate.h"
#import "NewJSON.h"

@interface SettingsView ()

@end

@implementation SettingsView
@synthesize serverData;
@synthesize pointsDisplayLabel;
@synthesize pointsProgressView;
@synthesize activity;

-(void)viewWillAppear:(BOOL)animated{
    [self performSelector:@selector(getPointsBalance)];
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

    
    if ((section == 1) && (row == 3)) {
       
        AppDelegate *mainDelegate = [[UIApplication sharedApplication] delegate];
        mainDelegate.logout = @"true";
        [self.navigationController dismissModalViewControllerAnimated:NO];
    }
}


-(void)getPointsBalance{
    
    @try{
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *customerId = [prefs valueForKey:@"customerId"];
        
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
        
        self.pointsDisplayLabel.text = [NSString stringWithFormat:@"Points Earned: %d", balance];
        
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
- (void)viewDidUnload {
    [self setPointsDisplayLabel:nil];
    [self setPointsProgressView:nil];
    [self setActivity:nil];
    [super viewDidUnload];
}
@end
