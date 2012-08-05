//
//  ArcClient.m
//  ARC
//
//  Created by Joseph Wroblewski on 8/5/12.
//
//

#import "ArcClient.h"
#import "NewJSON.h"

static NSString *_arcUrl = @"http://arc-stage.dagher.mobi/rest/v1/";

@implementation ArcClient
@synthesize serverData;

-(void)createCustomer:(NSDictionary *)pairs error:(NSError **)error{
    @try {
        NSString *requestString = [NSString stringWithFormat:@"%@", [pairs JSONFragment], nil];
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        NSString *createUrl = [NSString stringWithFormat:@"%@%@", _arcUrl, @"customers", nil];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createUrl]];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.serverData = [NSMutableData data];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
        
        // TODO
        // add in error handling so it can be returned to calling routing
    }
    @catch (NSException *exception) {
        // TODO add in rSkybox call
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)mdata {
    [self.serverData appendData:mdata];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSData *returnData = [NSData dataWithData:self.serverData];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NewSBJSON *jsonParser = [NewSBJSON new];
    NSDictionary *response = (NSDictionary *) [jsonParser objectWithString:returnString error:NULL];
    
    BOOL success = [[response valueForKey:@"Success"] boolValue];
    
    if (success){
        
        //self.activityView.hidden = YES;
        CGPoint top = CGPointMake(0, 40);
        [self.tableView setContentOffset:top animated:YES];
        
        NSDictionary *customer = [response valueForKey:@"Customer"];
        
        NSString *customerId = [[customer valueForKey:@"Id"] stringValue];
        NSString *customerToken = [customer valueForKey:@"Token"];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        [prefs setObject:customerId forKey:@"customerId"];
        [prefs setObject:customerToken forKey:@"customerToken"];
        [prefs synchronize];
        
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        [mainDelegate insertCustomerWithId:customerId andToken:customerToken];
        
        if ([[self creditCardStatus] isEqualToString:@"valid"]) {
            //Save credit card info
            [self performSelector:@selector(addCreditCard) withObject:nil afterDelay:1.0];
            
        }
        
        self.registerSuccess = YES;
        
        if (self.dwollaSegControl.selectedSegmentIndex == 1) {
            [self goHome];
        }
    }else{
        self.activityView.hidden = NO;
        self.errorLabel.hidden = NO;
        self.errorLabel.text = @"*Error registering, please try again.";
        self.registerSuccess = NO;
    }
}


@end
