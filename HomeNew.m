//
//  Home.m
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "HomeNew.h"
#import "Merchant.h"
#import "Restaurant.h"
#import "ArcAppDelegate.h"
#import "CreditCard.h"
#import "ArcClient.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"
#import "HomeNavigationController.h"
#import "SMContactsSelector.h"
#import "iCarousel.h"
#import "MFSideMenu.h"
#import "LucidaBoldLabel.h"
#import "LeftViewController.h"
#import "RightViewController.h"

#define REFRESH_HEADER_HEIGHT 52.0f



@interface HomeNew ()

-(void)getMerchantList;


@end




@implementation HomeNew
@synthesize sloganLabel;


-(void)appActive{
    [self getMerchantList];
    
}

-(void)viewWillDisappear:(BOOL)animated{
}


-(void)newLocation{
    
    [self getMerchantList];
}
-(void)viewWillAppear:(BOOL)animated{
    
    self.retryCount = 0;
    
    if (!self.isGettingMerchantList) {
        self.isGettingMerchantList = YES;
        [self getMerchantList];
        
    }
    
    
    
}

-(void)customerDeactivated{
    
    @try {
        if (self.navigationController.topViewController == self) {
            [self logOut];
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.customerDeactivated" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
    
}
-(void)logOut{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account Deactivated" message:@"For security purposes, your account has been remotely deactivated.  If this was done in error, please contact Arc support." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"arcUrl"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"customerId"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"customerToken"];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"admin"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"arcLoginType"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"customerEmail"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController dismissModalViewControllerAnimated:NO];
    
}
-(void)viewDidAppear:(BOOL)animated{
    
    
    
    @try {
        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Home"];
        // self.navigationItem.titleView = navLabel;
        
        CorbelBarButtonItem *temp = [[CorbelBarButtonItem alloc] initWithTitleText:@"Home"];
		//self.navigationItem.backBarButtonItem = temp;
        
        
        for (int i = 0; i < [self.allMerchants count]; i++) {
            
            NSIndexPath *myPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.myTableView deselectRowAtIndexPath:myPath animated:NO];
        }
        
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([mainDelegate.logout isEqualToString:@"true"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"You have successfully logged out.  You may continue to use Arc as a guest." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            mainDelegate.logout = @"";
            
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"arcUrl"];
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"customerId"];
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"customerToken"];
            [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"admin"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"arcLoginType"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"customerEmail"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autoPostFacebook"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"autoPostTwitter"];

            [[NSUserDefaults standardUserDefaults] synchronize];
            
           // [self.navigationController dismissModalViewControllerAnimated:NO];
            
        }
        
        if (self.skipReview || self.successReview) {
            
            NSString *message = @"";
            
            NSString *points = [[NSUserDefaults standardUserDefaults] valueForKey:@"pointsEarned"];
            
            if (self.successReview) {
                message = @"Your transaction has completed successfully!  Thank you for your review!";
                
                if (points && [points length] > 0) {
                    message = @"Your transaction has been completed successfully!  Thank you for your review!";
                    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"pointsTotal"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                }
                
            }else{
                message = @"Your transaction has completed successfully!  Thank you for your purchase!";
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
        
        //Home Alert
        
        if (!self.didShowPayment) {
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"didShowAlertHome"] length] == 0) {
                [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"didShowAlertHome"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                self.overlayTextView.layer.masksToBounds = YES;
                self.overlayTextView.layer.cornerRadius = 10.0;
                self.overlayTextView.layer.borderColor = [[UIColor blackColor] CGColor];
                self.overlayTextView.layer.borderWidth = 2.0;
                
                CAGradientLayer *gradient = [CAGradientLayer layer];
                gradient.frame = self.overlayTextView.bounds;
                self.overlayTextView.backgroundColor = [UIColor clearColor];
                double x = 1.4;
                UIColor *myColor = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];
                //UIColor *myColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
                gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
                [self.overlayTextView.layer insertSublayer:gradient atIndex:0];
                
                //[self showHintOverlay];
                
                //NSTimer *tmp = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideHintOverlay) userInfo:nil repeats:NO];
                
                //if (tmp) {
                    
              //  }
                
                
                
            }
        }
        self.didShowPayment = NO;
        
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.viewDidAppear" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)checkPayment{
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    [mainDelegate doPaymentCheck];
}

-(void)goToMerchant:(id)sender{
    
    UIButton *myButton = (UIButton *)sender;
    
    self.carousel.currentItemIndex = myButton.tag;
    
    [self payBillAction];
    
    
}
- (void)viewDidLoad
{
    self.searchBar.delegate = self;
    self.matchingMerchants = [NSMutableArray array];
    self.payBillButton.text = @"Pay Bill!";
    self.payBillButton.textColor = [UIColor whiteColor];
    self.payBillButton.textShadowColor = [UIColor darkGrayColor];
    self.payBillButton.cornerRadius = 3.0;
    self.payBillButton.borderColor = [UIColor darkGrayColor];
    self.payBillButton.borderWidth = 0.5;

    self.payBillButton.tintColor = dutchGreenColor;
    
    
    self.moreInfoButton.text = @"More Info";
    self.moreInfoButton.cornerRadius = 3.0;
    self.moreInfoButton.borderWidth = 0.5;
    self.moreInfoButton.borderColor = [UIColor darkGrayColor];
    //self.moreInfoButton.textColor = [UIColor blackColor];
   // self.moreInfoButton.textShadowColor = [UIColor darkGrayColor];
    //self.moreInfoButton.tintColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:225.0/215.0 alpha:1];

    LeftViewController *leftSideMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftSide"];
    RightViewController *rightSideMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"rightSide"];
    
    
    
    MFSideMenu *menu = [MFSideMenu menuWithNavigationController:self.navigationController
                      leftSideMenuController:leftSideMenuViewController
                     rightSideMenuController:rightSideMenuViewController];
    
    menu.allowSwipeOpenLeft = YES;
    leftSideMenuViewController.sideMenu = menu;
    rightSideMenuViewController.sideMenu = menu;
    
    
    //Carousel
    //self.roundView.layer.cornerRadius = 9.0;
    self.navigationController.navigationBarHidden = YES;
    
    self.carousel.type = iCarouselTypeCoverFlow2;
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
    self.carousel.backgroundColor = [UIColor clearColor];
    self.carousel.bounces = NO;
    self.carousel.vertical = NO;
    [self updateSliders];
    
    int y = 90;
    if (self.view.frame.size.height < 500) {
        y = 80;
    }
    self.carousel.frame = CGRectMake(0, y, 320, 200);
    self.carousel.clipsToBounds = YES;
    
    
    self.borderLine1.layer.shadowOffset = CGSizeMake(0, 1);
    self.borderLine1.layer.shadowRadius = 1;
    self.borderLine1.layer.shadowOpacity = 0.2;
    
    //self.borderLine2.layer.shadowOffset = CGSizeMake(0, -1);
    //self.borderLine2.layer.shadowRadius = 1;
    //self.borderLine2.layer.shadowOpacity = 0.5;
    
    
    @try {
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBarLogo.png"]
                                                      forBarMetrics:UIBarMetricsDefault];
        
        UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(162, 0, 1, 44)];
        verticalLine.backgroundColor = [UIColor whiteColor];
        //[self.navigationController.navigationBar addSubview:verticalLine];
        
        UIView *verticalLine1 = [[UIView alloc] initWithFrame:CGRectMake(215, 0, 1, 44)];
        verticalLine1.backgroundColor = [UIColor whiteColor];
       // [self.navigationController.navigationBar addSubview:verticalLine1];
        
        UIView *verticalLine2 = [[UIView alloc] initWithFrame:CGRectMake(263, 0, 1, 44)];
        verticalLine2.backgroundColor = [UIColor whiteColor];
        //[self.navigationController.navigationBar addSubview:verticalLine2];
        
        UIView *horizLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        horizLine.backgroundColor = [UIColor whiteColor];
       // [self.navigationController.navigationBar addSubview:horizLine];
        
        UIView *horizLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
        horizLine2.backgroundColor = [UIColor whiteColor];
        horizLine2.layer.shadowOffset = CGSizeMake(-1, 1);
        horizLine2.layer.shadowRadius = 1;
        horizLine2.layer.shadowOpacity = 0.5;
       // [self.navigationController.navigationBar addSubview:horizLine2];
        
        UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImageView *gearImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 39, 28)];
        gearImage.image = [UIImage imageNamed:@"newgear.png"];
        gearImage.contentMode = UIViewContentModeScaleAspectFit;
        [tmpButton addSubview:gearImage];
        tmpButton.frame = CGRectMake(263, 0, 53, 44);
        [tmpButton addTarget:self action:@selector(fakeSelection) forControlEvents:UIControlEventTouchUpInside];
        // [tmpButton setImage:[UIImage imageNamed:@"gear.png"] forState:UIControlStateNormal];
        //[self.navigationController.navigationBar addSubview:tmpButton];
        
        
        UIButton *tmpButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImageView *lockImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 39, 28)];
        lockImage.image = [UIImage imageNamed:@"newlock.png"];
        lockImage.contentMode = UIViewContentModeScaleAspectFit;
        [tmpButton1 addSubview:lockImage];
        tmpButton1.frame = CGRectMake(162, 0, 53, 44);
        // [tmpButton setImage:[UIImage imageNamed:@"gear.png"] forState:UIControlStateNormal];
       // [self.navigationController.navigationBar addSubview:tmpButton1];
        
        
        
        UIButton *tmpButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImageView *friendImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 39, 28)];
        friendImage.image = [UIImage imageNamed:@"newprofile.png"];
        friendImage.contentMode = UIViewContentModeScaleAspectFit;
        [tmpButton2 addSubview:friendImage];
        tmpButton2.frame = CGRectMake(215, 0, 53, 44);
        // [tmpButton setImage:[UIImage imageNamed:@"gear.png"] forState:UIControlStateNormal];
       // [self.navigationController.navigationBar addSubview:tmpButton2];
        
        
        CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Arc"];
        navLabel.frame = CGRectMake(0, 0, 100, 44);
        //[self.navigationController.navigationBar addSubview:navLabel];
        
        self.checkImage.layer.cornerRadius = 6.0;
        self.checkNumberView.layer.masksToBounds = YES;
        self.checkNumberView.layer.cornerRadius = 6.0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(referFriendComplete:) name:@"referFriendNotification" object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerDeactivated) name:@"customerDeactivatedNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(merchantListComplete:) name:@"merchantListNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noPaymentSources) name:@"NoPaymentSourcesNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newLocation) name:@"newLocation" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appActive) name:@"appActive" object:nil];
        
        
        
        self.searchCancelButton.hidden = YES;
        
        self.refreshListButton.hidden = YES;
        self.matchingMerchants = [NSMutableArray array];
        self.searchTextField.delegate = self;
        self.restaurantSegment.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];
        
        // [self.toolbar setBackgroundImage:[UIImage imageNamed:@"navBarLogo.png"]
        //                  forBarMetrics:UIBarMetricsDefault];
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
        
        /*
         CAGradientLayer *gradient = [CAGradientLayer layer];
         gradient.frame = self.view.bounds;
         self.view.backgroundColor = [UIColor clearColor];
         double x = 1.8;
         UIColor *myColor = [UIColor colorWithRed:114.0*x/255.0 green:168.0*x/255.0 blue:192.0*x/255.0 alpha:1.0];
         // UIColor *myColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
         gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
         [self.view.layer insertSublayer:gradient atIndex:0];
         
         */
        
        for (UIView *subview in self.searchBar.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [subview removeFromSuperview];
                break;
            }
        }
        
        //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
        
        double color = 230.0/255.0;
        self.view.backgroundColor = [UIColor colorWithRed:color green:color blue:color alpha:1.0];
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
        
        self.carousel.hidden = YES;
        self.payBillButton.enabled = NO;
        self.moreInfoButton.enabled = NO;
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)handleRefresh:(id)sender{
    
    [self getMerchantList];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    @try {
        
        self.matchingMerchants = [NSMutableArray array];
        if ((searchText == nil) || [searchText isEqualToString:@""]) {
            self.matchingMerchants = [NSMutableArray arrayWithArray:self.allMerchants];
        }else{
            
            NSString *currentStringToMatch = [searchText lowercaseString];
            
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
        
        NSLog(@"Count: %d", [self.matchingMerchants count]);
        [self.carousel reloadData];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.textFieldDidChange" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
        
        if ([self.matchingMerchants count] > 0) {
            self.errorLabel.text = @"";
        }
        
        NSLog(@"Count: %d", [self.matchingMerchants count]);
        [self.carousel reloadData];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.textFieldDidChange" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}
-(void)getMerchantList{
    @try{
       
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([mainDelegate.lastLongitude length] > 0) {
            [tempDictionary setValue:[NSNumber numberWithDouble:[mainDelegate.lastLatitude doubleValue]] forKey:@"Latitude"];
            [tempDictionary setValue:[NSNumber numberWithDouble:[mainDelegate.lastLongitude doubleValue]] forKey:@"Longitude"];
        }
        
        //For limiting number of Merchants retrieved
        //[tempDictionary setValue:[NSNumber numberWithInt:25] forKey:@"Top"];
        
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
        
        self.carousel.hidden = NO;
        self.payBillButton.enabled = YES;
        self.moreInfoButton.enabled = YES;
        
        self.isGettingMerchantList = NO;
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
                
                
                //For Test Videos:
                /*
                if (i == 0) {
                    tmpMerchant.name = @"Untitled";
                    tmpMerchant.address = @"111 W Kinzie Chicago, IL";
                    tmpMerchant.city = @"Chicago";
                    tmpMerchant.state = @"IL";
                    tmpMerchant.zipCode = @"60654";
                }else{
                    tmpMerchant.name = @"Union Sushi";
                }
                 */
            
                
                
                [self.allMerchants addObject:tmpMerchant];
                //[self.allMerchants addObject:tmpMerchant];
                //[self.allMerchants addObject:tmpMerchant];
                //[self.allMerchants addObject:tmpMerchant];
                
                [self.matchingMerchants addObject:tmpMerchant];
                //[self.matchingMerchants addObject:tmpMerchant];
                //[self.matchingMerchants addObject:tmpMerchant];
                //[self.matchingMerchants addObject:tmpMerchant];
                
            }
            
            if ([self.allMerchants count] == 0) {
                self.errorLabel.text = @"*No nearbly restaurants found";
            }else{
                //self.myTableView.hidden = NO;
                //[self.myTableView reloadData];
                [self.carousel reloadData];
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
        UIView *backView = (UIView *)[cell.contentView viewWithTag:5];
        
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:6];
        
        
        backView.layer.cornerRadius = 5.0;
        backView.layer.borderWidth = 1.0;
        backView.layer.borderColor = [[UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0] CGColor];
        
        backView.layer.shadowOffset = CGSizeMake(-1, 1);
        backView.layer.shadowRadius = 1;
        backView.layer.shadowOpacity = 0.5;
        
        nameLabel.text = tmpMerchant.name;
        
        
        imageView.layer.shadowOffset = CGSizeMake(-1, 3);
        imageView.layer.shadowRadius = 1;
        imageView.layer.shadowOpacity = 0.5;
        
        UIImage *buttonImageNormal = [UIImage imageNamed:@"gradient.png"];
        UIImage *stretch = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
        imageView.image = stretch;
        
        if (tmpMerchant.address) {
            adrLabel.text = [NSString stringWithFormat:@"%@, %@, %@ %@", tmpMerchant.address, tmpMerchant.city, tmpMerchant.state, tmpMerchant.zipCode];
        }else{
            adrLabel.text = @"201 North Ave, Chicago, IL";
        }
        
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        return cell;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
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
            
            //NSIndexPath *selectedRowIndex = [self.myTableView indexPathForSelectedRow];
            Restaurant *detailViewController = [segue destinationViewController];
            
            Merchant *tmpMerchant = [self.matchingMerchants objectAtIndex:self.carousel.currentItemIndex];
            
            detailViewController.merchantId = [NSString stringWithFormat:@"%d", tmpMerchant.merchantId];
            detailViewController.name = tmpMerchant.name;
            detailViewController.paymentsAccepted = tmpMerchant.paymentsAccepted;
            
            [[NSUserDefaults standardUserDefaults] setValue:tmpMerchant.name forKey:@"merchantName"];
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:tmpMerchant.merchantId] forKey:@"merchantId"];

            
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
        
        self.searchCancelButton.hidden = YES;
        if ([self.matchingMerchants count] == 0) {
            self.myTableView.hidden = YES;
            self.errorLabel.text = @"*No matches found.";
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"Home.endText" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
    self.didShowPayment = YES;
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
        //   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Email Addresses" message:@"None of the contacts you selected had email addresses entered." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        //[alert show];
    }else{
        
        ArcClient *tmp = [[ArcClient alloc] init];
        [tmp referFriend:data];
    }
    
}



-(void)showHintOverlay{
    
    @try {
        [UIView animateWithDuration:1.0 animations:^{
            CGRect frame = self.hintOverlayView.frame;
            frame.origin.x += 300;
            self.hintOverlayView.frame = frame;
        }];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"Home.showHintOverlay" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
}

-(void)hideHintOverlay{
    
    @try {
        [UIView animateWithDuration:1.0 animations:^{
            CGRect frame = self.hintOverlayView.frame;
            frame.origin.x += 300;
            self.hintOverlayView.frame = frame;
        }];
        
        [self performSelector:@selector(hideOverlay) withObject:nil afterDelay:1.0];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"Home.hideHintOverlay" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
        
    }
    
    
}

-(void)hideOverlay{
    self.hintOverlayView.hidden = YES;
}



- (IBAction)searchCancelAction {
    
    self.searchTextField.text = @"";
    
    self.searchCancelButton.hidden = YES;
    [self.searchTextField resignFirstResponder];
    
    self.matchingMerchants = [NSMutableArray arrayWithArray:self.allMerchants];
    
    [self.carousel reloadData];
}

-(void)searchEditDidBegin{
    self.searchCancelButton.hidden = NO;
}
- (IBAction)checkNumberDown {
    
    [UIView animateWithDuration:1.0 animations:^{
        CGRect frame = self.checkNumberView.frame;
        frame.origin.y = 503;
        self.checkNumberView.frame = frame;
    }];
}








- (void)updateSliders
{
    switch (self.carousel.type)
    {
        case iCarouselTypeLinear:
        {
            self.arcSlider.enabled = NO;
        	self.radiusSlider.enabled = NO;
            self.tiltSlider.enabled = NO;
            self.spacingSlider.enabled = YES;
            break;
        }
        case iCarouselTypeCylinder:
        case iCarouselTypeInvertedCylinder:
        case iCarouselTypeRotary:
        case iCarouselTypeInvertedRotary:
        case iCarouselTypeWheel:
        case iCarouselTypeInvertedWheel:
        {
            self.arcSlider.enabled = YES;
        	self.radiusSlider.enabled = YES;
            self.tiltSlider.enabled = NO;
            self.spacingSlider.enabled = YES;
            break;
        }
        default:
        {
            self.arcSlider.enabled = NO;
        	self.radiusSlider.enabled = NO;
            self.tiltSlider.enabled = YES;
            self.spacingSlider.enabled = YES;
            break;
        }
    }
}





- (void)setUp
{
	//set up data
	self.wrap = YES;
	self.items = [NSMutableArray array];
	for (int i = 0; i < 1000; i++)
	{
		[self.items addObject:[NSNumber numberWithInt:i]];
	}
}


- (IBAction)reloadCarousel
{
    [self.carousel reloadData];
}

#pragma mark -
#pragma mark UIActionSheet methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex	>= 0)
    {
        //map button index to carousel type
        iCarouselType type = buttonIndex;
        
        //carousel can smoothly animate between types
        [UIView beginAnimations:nil context:nil];
        self.carousel.type = type;
        [self updateSliders];
        [UIView commitAnimations];
        
        //update title
        self.navItem.title = [actionSheet buttonTitleAtIndex:buttonIndex];
    }
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [self.matchingMerchants count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    @try {
        UILabel *label = nil;
        
        //create new view if no view is available for recycling
        if (view == nil)
        {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180.0f, 160.0f)];
            view.backgroundColor = [UIColor clearColor];
            view.layer.borderWidth = 1.0;
            view.layer.borderColor = [[UIColor darkGrayColor] CGColor];
            view.layer.cornerRadius = 3.0;
            
           // view.layer.shadowOffset = CGSizeMake(-1, 3);
           // view.layer.shadowRadius = 0.5;
           // view.layer.shadowOpacity = 0.5;
            
            UIImageView *imageLogo = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 178, 158)];
            imageLogo.layer.cornerRadius = 3.0;
            //imageLogo.layer.masksToBounds = YES;
            
            if (index % 2 == 0) {
                imageLogo.image = [UIImage imageNamed:@"untitledLogo.png"];
                
            }else{
                imageLogo.image = [UIImage imageNamed:@"junkieLogo.png"];
                
            }
            [view addSubview:imageLogo];
            
            UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 148, 146, 44)];
            tmpLabel.font = [UIFont fontWithName:@"Corbel-Bold" size:19];
            tmpLabel.backgroundColor = [UIColor clearColor];
            
            UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
            selectButton.frame = CGRectMake(0, 0, 150, 150);
            selectButton.tag = index;
            [selectButton addTarget:self action:@selector(goToMerchant:) forControlEvents:UIControlEventTouchUpInside];
            
            Merchant *tmpMerchant = [self.matchingMerchants objectAtIndex:index];
            tmpLabel.text = tmpMerchant.name;
            
            tmpLabel.textAlignment = UITextAlignmentCenter;
          //  [view addSubview:tmpLabel];
            
            [view addSubview:selectButton];

            
        }
        else
        {
            //get a reference to the label in the recycled view
        }
        
        
        
        return view;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        return [[UIView alloc] init];
    }
 
    
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    @try {
        switch (option)
        {
            case iCarouselOptionWrap:
            {
                return self.wrap;
            }
            case iCarouselOptionFadeMax:
            {
                if (self.carousel.type == iCarouselTypeCustom)
                {
                    return 0.0f;
                }
                return value;
            }
            case iCarouselOptionArc:
            {
                return 2 * M_PI * 0.342;
            }
            case iCarouselOptionRadius:
            {
                return value * 0.9;
            }
            case iCarouselOptionTilt:
            {
                return 0.8;
            }
            case iCarouselOptionSpacing:
            {
                
                return 0.315;
                /*
                 if (self.isRotary) {
                 return 1.4;
                 }
                 
                 return value * 0.9;
                 */
            }
            default:
            {
                return value;
            }
                
        }
    }
    @catch (NSException *exception) {
        NSLog(@"E: %@", exception);
        return 0.0;
    }
   
}



- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel{
    
    
    @try {
        if ([self.matchingMerchants count] > carousel.currentItemIndex) {
            Merchant *tmpMerchant = [self.matchingMerchants objectAtIndex:carousel.currentItemIndex];
            self.placeNameLabel.text = tmpMerchant.name;
            self.placeAddressLabel.text = tmpMerchant.address;
        }
     
    }
    @catch (NSException *exception) {
        NSLog(@"E: %@", exception);
    }



}
- (IBAction)valueChanged {
}
- (IBAction)searchAction {
    
    int newy = 51;
    if (self.searchBar.frame.origin.y == 51) {
        newy = 7;
        [self performSelector:@selector(becomeResp:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.0];

    }else{
        [self performSelector:@selector(becomeResp:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.0];
    }
    
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.searchBar.frame;
        frame.origin.y = newy;
        self.searchBar.frame = frame;
    }];
    
    
}

-(void)becomeResp:(NSNumber *)yesOrNo{
    
    if ([yesOrNo boolValue]) {
        [self.searchBar becomeFirstResponder];

    }else{
        [self.searchBar resignFirstResponder];
        self.matchingMerchants = [NSMutableArray arrayWithArray:self.allMerchants];
        [self.carousel reloadData];
        self.searchBar.text = @"";

    }
}

-(IBAction)menuAction{
    [self.navigationController.sideMenu toggleLeftSideMenu];
    
}

-(void)menuBackAction{
    
  
    
    [UIView animateWithDuration:1.0 animations:^{
        
        self.topImageView.frame = CGRectMake(90, 106, 140, 140);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.menuButton.alpha = 1.0;
        self.backButton.alpha = 0.0;
        self.carousel.alpha = 1.0;
        [self.view bringSubviewToFront:self.menuButton];
        
    }];
    self.placeAddressLabel.hidden = NO;
    self.placeNameLabel.hidden = NO;
    self.payBillButton.hidden = NO;
    self.moreInfoButton.hidden = NO;
    self.searchButton.hidden = NO;

    [self.enterCheckNumberView removeFromSuperview];
    self.enterCheckNumberView = nil;
    
    [self performSelector:@selector(goAway) withObject:nil afterDelay:1.0];
    
}
-(void)goAway{
    [self.topImageView removeFromSuperview];
    self.topImageView = nil;
}
- (IBAction)payBillAction {
    
    [self performSegueWithIdentifier:@"goRestaurant" sender:self];
    /*
    self.topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(90, 106, 140, 140)];
    self.topImageView.image = [UIImage imageNamed:@"untitledLogo.png"];
    [self.view addSubview:self.topImageView];
    
    [UIView animateWithDuration:1.0 animations:^{
        
        self.topImageView.frame = CGRectMake(0, 46, 320, 130);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.menuButton.alpha = 0.0;
        self.backButton.alpha = 1.0;
        self.carousel.alpha = 0.0;
        [self.view bringSubviewToFront:self.backButton];
        
    }];
    
    self.placeAddressLabel.hidden = YES;
    self.placeNameLabel.hidden = YES;
    self.payBillButton.hidden = YES;
    self.moreInfoButton.hidden = YES;
    self.searchButton.hidden = YES;
    
    self.enterCheckNumberView = [[UIView alloc] initWithFrame:CGRectMake(0, 175, 320, 35)];
    self.enterCheckNumberView.backgroundColor = [UIColor clearColor];
    
    UIView *backAlphaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
    backAlphaView.backgroundColor = [UIColor blackColor];
    backAlphaView.alpha = 0.7;
    [self.enterCheckNumberView addSubview:backAlphaView];
    
    LucidaBoldLabel *tmp = [[LucidaBoldLabel alloc] initWithFrame:CGRectMake(5, 0, 320, 35) andSize:18];
    tmp.textColor = [UIColor whiteColor];
    tmp.backgroundColor = [UIColor clearColor];
    tmp.text = @"Please enter your check number:";
    [self.enterCheckNumberView addSubview:tmp];
    
    [self performSelector:@selector(addAlert) withObject:nil afterDelay:0.9];
    
    */
    
}

-(void)addAlert{
    [self.view addSubview:self.enterCheckNumberView];

}
- (IBAction)moreInfoAction:(id)sender {
}
@end
