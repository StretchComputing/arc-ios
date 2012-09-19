//
//  Home.m
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "Home.h"
#import "Merchant.h"
#import "Restaurant.h"
#import "ArcAppDelegate.h"
#import "CreditCard.h"
#import "ArcClient.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"
#import "HomeNavigationController.h"

@interface Home ()

-(void)getMerchantList;

@end

@implementation Home
@synthesize sloganLabel;


-(void)appActive{
    [self getMerchantList];

}

-(void)viewDidAppear:(BOOL)animated{
    @try {
        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Home"];
        self.navigationItem.titleView = navLabel;
        
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Home"];
		self.navigationItem.backBarButtonItem = temp;
        
        
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
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.viewDidAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (void)viewDidLoad
{
    @try {
        
        
      
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(merchantListComplete:) name:@"merchantListNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appActive) name:@"appActive" object:nil];
        
        self.matchingMerchants = [NSMutableArray array];
        self.searchTextField.delegate = self;
        self.toolbar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];
        
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
        
        self.myTableView.separatorColor = [UIColor darkGrayColor];
        
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.view.bounds;
        self.view.backgroundColor = [UIColor clearColor];
        //UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
        double x = 1.8;
        UIColor *myColor = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];

        double y = 2.4;
        //myColor = [UIColor colorWithRed:64.0*y/255.0 green:74.0*y/255.0 blue:81.0*y/255.0 alpha:1.0];
        
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
        
        self.sloganLabel.font = [UIFont fontWithName:@"Chalet-Tokyo" size:20];
        
        
     
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)textFieldDidChange{
    @try {
        
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
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.textFieldDidChange" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
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
        [rSkybox sendClientLog:@"Home.getMerchantList" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)merchantListComplete:(NSNotification *)notification{
    @try {
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *status = [responseInfo valueForKey:@"status"];
        NSDictionary *apiResponse = [responseInfo valueForKey:@"apiResponse"];
        
        [self.activity stopAnimating];
        
        self.activityView.hidden = YES;
        if ([status isEqualToString:@"1"]) {
            //success
            self.errorLabel.text = @"";
            
            NSArray *merchants = [apiResponse valueForKey:@"Results"];
            
            if ([merchants count] > 0) {
                self.allMerchants = [NSMutableArray array];
                self.matchingMerchants = [NSMutableArray array];
            }
            
            for (int i = 0; i < [merchants count]; i++) {
                
                Merchant *tmpMerchant = [[Merchant alloc] init];
                NSDictionary *theMerchant = [merchants objectAtIndex:i];
                
                tmpMerchant.name = [theMerchant valueForKey:@"Name"];
                tmpMerchant.merchantId = [[theMerchant valueForKey:@"Id"] intValue];
                
                tmpMerchant.address = [theMerchant valueForKey:@"Street"];
                tmpMerchant.city = [theMerchant valueForKey:@"City"];
                tmpMerchant.state = [theMerchant valueForKey:@"State"];
                tmpMerchant.zipCode = [theMerchant valueForKey:@"Zipcode"];
                
                tmpMerchant.invoiceLength = [[theMerchant valueForKey:@"InvoiceLength"] intValue];
                
                
                [self.allMerchants addObject:tmpMerchant];
                [self.matchingMerchants addObject:tmpMerchant];
            }
        }else{
            // failure
            if ([self.allMerchants count] == 0) {
                self.errorLabel.text = @"*Error finding restaurants";
            }
        }
        
        if ([self.allMerchants count] == 0) {
            self.errorLabel.text = @"*No nearbly restaurants found";
        }else{
            self.myTableView.hidden = NO;
            [self.myTableView reloadData];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.merchantListComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    @try {
        
        if ([self.matchingMerchants count] == 0) {
            //self.myTableView.hidden = YES;
            return 0;
        }else {
            self.myTableView.hidden = NO;
            return [self.matchingMerchants count];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
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
        
        if (tmpMerchant.address) {
            adrLabel.text = [NSString stringWithFormat:@"%@, %@, %@ %@", tmpMerchant.address, tmpMerchant.city, tmpMerchant.state, tmpMerchant.zipCode];
        }else{
            adrLabel.text = @"201 North Ave, Chicago, IL";
        }
        
        
        return cell;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
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
    @try {
        
        if ([[segue identifier] isEqualToString:@"goRestaurant"]) {
            
            NSIndexPath *selectedRowIndex = [self.myTableView indexPathForSelectedRow];
            Restaurant *detailViewController = [segue destinationViewController];
            
            Merchant *tmpMerchant = [self.allMerchants objectAtIndex:[selectedRowIndex row]];
            
            detailViewController.merchantId = [NSString stringWithFormat:@"%d", tmpMerchant.merchantId];
            detailViewController.name = tmpMerchant.name;
            
            [[NSUserDefaults standardUserDefaults] setValue:tmpMerchant.name forKey:@"selectedRestaurant"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        } 
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (IBAction)refreshMerchants:(id)sender {
    
    [self.activity startAnimating];

    [self getMerchantList];

    
}

-(void)endText{
    @try {
        
        if ([self.matchingMerchants count] == 0) {
            self.myTableView.hidden = YES;
            self.errorLabel.text = @"*No matches found.";
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.endText" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (void)viewDidUnload {
    @try {
        
        [self setSloganLabel:nil];
        [super viewDidUnload];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.viewDidUnload" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}
@end
