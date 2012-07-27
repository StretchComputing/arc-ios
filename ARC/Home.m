//
//  Home.m
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Home.h"
#import "NewJSON.h"
#import "Merchant.h"
#import "Restaurant.h"
#import "ArcAppDelegate.h"
#import "CreditCard.h"

@interface Home ()

-(void)getMerchantList;

@end

@implementation Home
@synthesize activityView;
@synthesize errorLabel, matchingMerchants;
@synthesize toolbar, serverData, allMerchants, myTableView, successReview, skipReview, searchTextField;


-(void)viewDidAppear:(BOOL)animated{
    
    for (int i = 0; i < [self.allMerchants count]; i++) {
        
        NSIndexPath *myPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.myTableView deselectRowAtIndexPath:myPath animated:NO];
    }
    
    ArcAppDelegate *mainDelegate = [[UIApplication sharedApplication] delegate];
    if ([mainDelegate.logout isEqualToString:@"true"]) {
        
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"customerId"];
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"customerToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self.navigationController dismissModalViewControllerAnimated:NO];
    }
    
    if (self.skipReview || self.successReview) {
        
        NSString *message = @"";
        
        if (self.successReview) {
            message = @"Your transaction has completed successfully!  Check out your profile to see the points you earned for your review!";
        }else{
            message = @"Your transaction has completed successfully!  Check out your profile to see the points you have earned!";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank You!" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        self.skipReview = NO;
        self.successReview = NO;
    }
}

- (void)viewDidLoad
{
    self.matchingMerchants = [NSMutableArray array];
    self.searchTextField.delegate = self;
    self.toolbar.tintColor = [UIColor colorWithRed:0.0427221 green:0.380456 blue:0.785953 alpha:1.0];
    self.serverData = [NSMutableData data];
    self.allMerchants = [NSMutableArray array];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.hidden = YES;
    
    self.activityView.hidden = NO;
    self.errorLabel.text = @"";
    [self getMerchantList];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.searchTextField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];

}

-(void)textFieldDidChange{
    
    self.matchingMerchants = [NSMutableArray array];
    if ((self.searchTextField.text == nil) || [self.searchTextField.text isEqualToString:@""]) {
        self.matchingMerchants = [NSMutableArray arrayWithArray:self.allMerchants];
    }else{
        
        NSString *currentStringToMatch = [self.searchTextField.text lowercaseString];
        
        for (int i = 0; i < [self.allMerchants count]; i++) {
            Merchant *tmpMerchant = [self.allMerchants objectAtIndex:i];
            NSString *merchantName = [tmpMerchant.name lowercaseString];
            
            if ([merchantName rangeOfString:currentStringToMatch].location != NSNotFound) {
                [self.matchingMerchants addObject:tmpMerchant];
            }
        }
    }
    
    
    [self.myTableView reloadData];
    
}
-(void)getMerchantList{
    
    @try{
        
        NSString *tmpUrl = [NSString stringWithString:@"http://arc-stage.dagher.mobi/rest/v1/merchants"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:tmpUrl]];
        [request setHTTPMethod: @"GET"];
        
        self.serverData = [NSMutableData data];
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
    
    self.activityView.hidden = YES;

    NSData *returnData = [NSData dataWithData:self.serverData];
    
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NewSBJSON *jsonParser = [NewSBJSON new];
    NSDictionary *response = (NSDictionary *) [jsonParser objectWithString:returnString error:NULL];
    
    BOOL success = [[response valueForKey:@"Success"] boolValue];
    
    if (success) {
        NSArray *merchants = [response valueForKey:@"Merchants"];
        
        for (int i = 0; i < [merchants count]; i++) {
            
            Merchant *tmpMerchant = [[Merchant alloc] init];
            NSDictionary *theMerchant = [merchants objectAtIndex:i];
            
            tmpMerchant.name = [theMerchant valueForKey:@"Name"];
            tmpMerchant.merchantId = [[theMerchant valueForKey:@"Id"] intValue];
            
            [self.allMerchants addObject:tmpMerchant];
            [self.matchingMerchants addObject:tmpMerchant];
            
            
        }
    }else{
        self.errorLabel.text = @"*Error finding restaurants";
    }

    if ([self.allMerchants count] == 0) {
        self.errorLabel.text = @"*No nearbly restaurants found";
    }else{
        self.myTableView.hidden = NO;
        [self.myTableView reloadData];
    }
   	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
   self.errorLabel.text = @"*Error finding restaurants";
    self.activityView.hidden = YES;
}



- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	
	if ([self.matchingMerchants count] == 0) {
        //self.myTableView.hidden = YES;
        return 0;
    }else {
        self.myTableView.hidden = NO;
        return [self.matchingMerchants count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *FirstLevelCell=@"FirstLevelCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FirstLevelCell];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier: FirstLevelCell];
	}
    
	
	//Configure the cell
	NSUInteger row = [indexPath row];
	
    Merchant *tmpMerchant = [self.matchingMerchants objectAtIndex:row];
        
    cell.textLabel.text = tmpMerchant.name;
 
	return cell;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
    return @"Select a restaurant:";
}

*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"goRestaurant"]) {
        
        NSIndexPath *selectedRowIndex = [self.myTableView indexPathForSelectedRow];
        Restaurant *detailViewController = [segue destinationViewController];
        
        Merchant *tmpMerchant = [self.allMerchants objectAtIndex:[selectedRowIndex row]];
        
        detailViewController.name = tmpMerchant.name;
    } 
}

-(void)endText{
    
    if ([self.matchingMerchants count] == 0) {
        self.myTableView.hidden = YES;
        self.errorLabel.text = @"*No matches found.";
    }
}
@end
