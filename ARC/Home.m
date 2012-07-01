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

@interface Home ()

-(void)getMerchantList;

@end

@implementation Home
@synthesize activityView;
@synthesize errorLabel;
@synthesize toolbar, serverData, allMerchants, myTableView;

-(void)viewDidAppear:(BOOL)animated{
    
    for (int i = 0; i < [self.allMerchants count]; i++) {
        
        NSIndexPath *myPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.myTableView deselectRowAtIndexPath:myPath animated:NO];
    }
    
    ArcAppDelegate *mainDelegate = [[UIApplication sharedApplication] delegate];
    if ([mainDelegate.logout isEqualToString:@"true"]) {
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        [self.navigationController dismissModalViewControllerAnimated:NO];
    }
}

- (void)viewDidLoad
{
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
}

-(void)getMerchantList{
    
    @try{
        
        NSString *tmpUrl = [NSString stringWithString:@"http://68.57.205.193:8700/rest/v1/merchants"];
        
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
	
	if ([self.allMerchants count] == 0) {
        self.myTableView.hidden = YES;
        return 0;
    }else {
        return [self.allMerchants count];
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
	
    Merchant *tmpMerchant = [self.allMerchants objectAtIndex:row];
        
    cell.textLabel.text = tmpMerchant.name;
 
	return cell;

}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
    return @"Select a restaurant:";
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    
    if ([[segue identifier] isEqualToString:@"goRestaurant"]) {
        
        NSIndexPath *selectedRowIndex = [self.myTableView indexPathForSelectedRow];
        Restaurant *detailViewController = [segue destinationViewController];
        
        Merchant *tmpMerchant = [self.allMerchants objectAtIndex:[selectedRowIndex row]];
        
        detailViewController.name = tmpMerchant.name;
    } 
}
@end
