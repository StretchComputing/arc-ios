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
#import "ArcClient.h"


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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(merchantListComplete:) name:@"merchantListNotification" object:nil];
    
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
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    footer.backgroundColor = [UIColor clearColor];
    
    self.myTableView.tableFooterView = footer;
    self.myTableView.backgroundColor = [UIColor clearColor];
    self.myTableView.backgroundView.backgroundColor = [UIColor clearColor];
    
    myTableView.separatorColor = [UIColor lightGrayColor];

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
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
		NSDictionary *loginDict = [[NSDictionary alloc] init];
		loginDict = tempDictionary;
        ArcClient *client = [[ArcClient alloc] init];
        [client getMerchantList:loginDict];
    }
    @catch (NSException *e) {
        //[rSkybox sendClientLog:@"getInvoiceFromNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)merchantListComplete:(NSNotification *)notification{
    NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
    NSString *status = [responseInfo valueForKey:@"status"];
    NSDictionary *apiResponse = [responseInfo valueForKey:@"apiResponse"];
    
    self.activityView.hidden = YES;
    if ([status isEqualToString:@"1"]) {
        //success
        NSArray *merchants = [apiResponse valueForKey:@"Merchants"];
        for (int i = 0; i < [merchants count]; i++) {
            
            Merchant *tmpMerchant = [[Merchant alloc] init];
            NSDictionary *theMerchant = [merchants objectAtIndex:i];
            
            tmpMerchant.name = [theMerchant valueForKey:@"Name"];
            tmpMerchant.merchantId = [[theMerchant valueForKey:@"Id"] intValue];
            
            [self.allMerchants addObject:tmpMerchant];
            [self.matchingMerchants addObject:tmpMerchant];
        }
    }else{
        // failure
        self.errorLabel.text = @"*Error finding restaurants";
    }
    
    if ([self.allMerchants count] == 0) {
        self.errorLabel.text = @"*No nearbly restaurants found";
    }else{
        self.myTableView.hidden = NO;
        [self.myTableView reloadData];
    }
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
	
    NSUInteger row = [indexPath row];
    static NSString *FirstLevelCell=@"FirstLevelCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FirstLevelCell];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier: FirstLevelCell];
	}
    
    Merchant *tmpMerchant = [self.matchingMerchants objectAtIndex:row];

    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *adrLabel = (UILabel *)[cell.contentView viewWithTag:2];
	
    nameLabel.text = tmpMerchant.name;
    adrLabel.text = @"201 North Ave, Chicago, IL";
    
 
	return cell;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
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
        
        //::NICK:: needed to store merchant ID temporarily -- I know this is not a good way to do it
        NSString * merchantId = [NSString stringWithFormat:@"%d",tmpMerchant.merchantId];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:merchantId forKey:@"merchantId"];
        
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
