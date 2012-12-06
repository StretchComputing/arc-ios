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
#import "SMContactsSelector.h"

#define REFRESH_HEADER_HEIGHT 52.0f


@interface Home ()

-(void)getMerchantList;

@end

@implementation Home
@synthesize sloganLabel;


-(void)appActive{
    [self getMerchantList];

}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{
    
    self.retryCount = 0;
    [self getMerchantList];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(referFriendComplete:) name:@"referFriendNotification" object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(merchantListComplete:) name:@"merchantListNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noPaymentSources) name:@"NoPaymentSourcesNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appActive) name:@"appActive" object:nil];

}

-(void)customerDeactivated{
    [self logOut];
}
-(void)logOut{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account Deactivated" message:@"For security purposes, your account has been remotely deactivated.  If this was done in error, please contact ARC support." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"arcUrl"];    
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"customerId"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"customerToken"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"admin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController dismissModalViewControllerAnimated:NO];
    
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
            
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"arcUrl"];
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"customerId"];
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"customerToken"];
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"admin"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.navigationController dismissModalViewControllerAnimated:NO];
            
        }
        
        if (self.skipReview || self.successReview) {
            
            NSString *message = @"";
            
            NSString *points = [[NSUserDefaults standardUserDefaults] valueForKey:@"pointsEarned"];
            
            if (self.successReview) {
                message = @"Your transaction has completed successfully!  Check out your profile to see the points you earned for your review!";
                
                if (points && [points length] > 0) {
                    message = [NSString stringWithFormat:@"Your transaction has been completed successfully!  Thank you for your review, you have earned %@ points!  Check out your point totals in your profile.", points];
                    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"pointsTotal"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                }
                
            }else{
                message = @"Your transaction has completed successfully!  Check out your profile to see the points you have earned!";
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank You!" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            self.skipReview = NO;
            self.successReview = NO;
        }
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"didJustLogin"] isEqualToString:@"yes"]) {
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"didJustLogin"];
            [self checkPayment];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.viewDidAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)checkPayment{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    [mainDelegate doPaymentCheck];
}

- (void)viewDidLoad
{
    @try {

        
        self.refreshListButton.hidden = YES;
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
        double x = 1.8;
        UIColor *myColor = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
        
        self.sloganLabel.font = [UIFont fontWithName:@"Chalet-Tokyo" size:20];
        
        //refresh controller
        //check if refresh control is available
        if(NSClassFromString(@"UIRefreshControl")) {
            self.isIos6 = YES;
        }else{
            self.isIos6 = NO;
        }

        if (self.isIos6) {
            self.refreshControl = [[UIRefreshControl alloc] init];
            [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
            [self.myTableView addSubview:self.refreshControl];
        }else{
            [self setupStrings];
            [self addPullToRefreshHeader];
        }
     

        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)handleRefresh:(id)sender{
    
    [self getMerchantList];
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
        
        if ([self.matchingMerchants count] > 0) {
            self.errorLabel.text = @"";
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
        
        self.refreshListButton.hidden = YES;
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *status = [responseInfo valueForKey:@"status"];
        NSDictionary *apiResponse = [responseInfo valueForKey:@"apiResponse"];
        
        [self.activity stopAnimating];
        [self.refreshControl endRefreshing];
        if (self.shouldCallStop) {
            [self stopLoading];
        }
        
        self.activityView.hidden = YES;
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
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
                tmpMerchant.twitterHandler = [theMerchant valueForKey:@"TwitterHandler"];
                tmpMerchant.facebookHandler = [theMerchant valueForKey:@"FacebookHandler"];
                tmpMerchant.paymentsAccepted = [theMerchant valueForKey:@"PaymentAccepted"];
                
                tmpMerchant.invoiceLength = [[theMerchant valueForKey:@"InvoiceLength"] intValue];
                
                [self.allMerchants addObject:tmpMerchant];
                [self.matchingMerchants addObject:tmpMerchant];
            }
            
            if ([self.allMerchants count] == 0) {
                self.errorLabel.text = @"*No nearbly restaurants found";
            }else{
                self.myTableView.hidden = NO;
                [self.myTableView reloadData];
            }
        } else if([status isEqualToString:@"error"]){
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
                
        if([errorMsg length] > 0) {
            if ([self.allMerchants count] == 0) {
                self.errorLabel.text = errorMsg;
                //if no Merchants found, retry.
                if (self.retryCount < 1) {
                    self.retryCount++;
                    [self getMerchantList];
                }else{
                    self.refreshListButton.hidden = NO;
                }
            }
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.merchantListComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)refreshList{
    [self getMerchantList];
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
            
            Merchant *tmpMerchant = [self.matchingMerchants objectAtIndex:[selectedRowIndex row]];
            
            detailViewController.merchantId = [NSString stringWithFormat:@"%d", tmpMerchant.merchantId];
            detailViewController.name = tmpMerchant.name;
            detailViewController.paymentsAccepted = tmpMerchant.paymentsAccepted;
            
            [[NSUserDefaults standardUserDefaults] setValue:tmpMerchant.name forKey:@"merchantName"];
            [[NSUserDefaults standardUserDefaults] setValue:tmpMerchant.twitterHandler forKey:@"merchantTwitterHandler"];
            [[NSUserDefaults standardUserDefaults] setValue:tmpMerchant.facebookHandler forKey:@"merchantFacebookHandler"];
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


//iOS 5 pull to refresh code




- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    if (!self.isIos6) {
        if (self.isLoading) {
            // Update the content inset, good for section headers
            if (sender.contentOffset.y > 0)
                self.myTableView.contentInset = UIEdgeInsetsZero;
            else if (sender.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
                self.myTableView.contentInset = UIEdgeInsetsMake(-sender.contentOffset.y, 0, 0, 0);
        } else if (self.isDragging && sender.contentOffset.y < 0) {
            // Update the arrow direction and label
            [UIView beginAnimations:nil context:NULL];
            if (sender.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                self.refreshLabel.text = self.textRelease;
                [self.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else { // User is scrolling somewhere within the header
                self.refreshLabel.text = self.textPull;
                [self.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
            [UIView commitAnimations];
        }
    }
   

}




- (void)setupStrings{
    self.textPull = @"Pull down to refresh...";
    self.textRelease = @"Release to refresh...";
    self.textLoading = @"Loading...";
 
}


//Scroll down to refresh method
- (void)addPullToRefreshHeader {
    
    
    self.refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    self.refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    self.refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT)];
    self.refreshLabel.backgroundColor = [UIColor clearColor];
    self.refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    self.refreshLabel.textAlignment = UITextAlignmentCenter;
    
    self.refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    self.refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 27) / 2),
                                    (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                    27, 44);
    
    self.refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    self.refreshSpinner.hidesWhenStopped = YES;
    
    [self.refreshHeaderView addSubview:self.refreshLabel];
    [self.refreshHeaderView addSubview:self.refreshArrow];
    [self.refreshHeaderView addSubview:self.refreshSpinner];
    
    [self.myTableView addSubview:self.refreshHeaderView];
    
      
    
    
}

//Scroll down to refresh method
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.isLoading) return;
    self.isDragging = YES;
}



//Scroll down to refresh method
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (self.isLoading) return;
    self.isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }

    
}

//Scroll down to refresh method
- (void)startLoading {
    self.isLoading = YES;
    
    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        self.myTableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        
        self.refreshLabel.text = self.textLoading;
        self.refreshArrow.hidden = YES;
        [self.refreshSpinner startAnimating];
    }];

    
    // Refresh action!
    [self refresh];
}

//Scroll down to refresh method
- (void)stopLoading {
    self.shouldCallStop = NO;
    self.isLoading = NO;
    
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    
    self.myTableView.contentInset = UIEdgeInsetsZero;
    [self.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
   
    [UIView commitAnimations];
}

//Scroll down to refresh method
- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    self.refreshLabel.text = self.textPull;
    self.refreshArrow.hidden = NO;
    [self.refreshSpinner stopAnimating];

    self.refreshLabel.text = self.textPull;
    self.refreshArrow.hidden = NO;
    [self.refreshSpinner stopAnimating];
        
}

//Scroll down to refresh method
- (void)refresh {
    // Don't forget to call stopLoading at the end.
    self.shouldCallStop = YES;
            
    [self getMerchantList];
        
  
}

-(void)noPaymentSources{
    UIViewController *noPaymentController = [self.storyboard instantiateViewControllerWithIdentifier:@"noPayment"];
    [self.navigationController presentModalViewController:noPaymentController animated:YES];
    
}


-(void)inviteFriend{
    
    SMContactsSelector *controller = [[SMContactsSelector alloc] initWithNibName:@"SMContactsSelector" bundle:nil];
    controller.delegate = self;
    
    // Select your returned data type
    controller.requestData = DATA_CONTACT_EMAIL; // , DATA_CONTACT_TELEPHONE
    
    // Set your contact list setting record ids (optional)
    //controller.recordIDs = [NSArray arrayWithObjects:@"1", @"2", nil];
    
    //Window show in Modal or not
    controller.showModal = YES; //Mandatory: YES or NO
    //Show tick or not
    controller.showCheckButton = YES; //Mandatory: YES or NO
    [self presentModalViewController:controller animated:YES];
    
}


//********Invite a Friend Methods




-(void)referFriendComplete:(NSNotification *)notification{
    @try {
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *status = [responseInfo valueForKey:@"status"];
        
        [self.activity stopAnimating];
        
        
        if ([status isEqualToString:@"success"]) {
            //success
            self.errorLabel.text = @"";
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully invited your friend(s)!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
                        
            
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Friend Invite Failed." message:@"Sorry, we were unable to send your invite(s) at this time, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.referFriendComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (void)numberOfRowsSelected:(NSInteger)numberRows withData:(NSArray *)data andDataType:(DATA_CONTACT)type{
    
    if (numberRows == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Email Addresses" message:@"None of the contacts you selected had email addresses entered." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }else{
        
        ArcClient *tmp = [[ArcClient alloc] init];
        [tmp referFriend:data];
    }
    
}
@end
