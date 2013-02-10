//
//  AppDelegate.m
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "ArcAppDelegate.h"
#import "CreditCard.h"
#import "FBEncryptorAES.h"
#import <CrashReporter/CrashReporter.h>
#import "UIDevice-Hardware.h"
#import "rSkybox.h"
#import "Reachability.h"
#import "ArcClient.h"
#import "ArcUtility.h"
#import "DwollaAPI.h"

@implementation ArcAppDelegate

//Reachability
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
    [self updateInterfaceWithReachability:curReach];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    if(curReach == internetReach)
	{
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        //BOOL connectionRequired= [curReach connectionRequired];
		
		switch (netStatus)
		{
			case NotReachable:
			{
                
                //NSString *message = @"An internet connection is required for this app.  Please make sure you are connected to the internet to continue.";
               // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Lost" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
                
				break;
			}
				
			case ReachableViaWWAN:
			{
                
				break;
			}
			case ReachableViaWiFi:
			{
				
				break;
			}
		}
	}

    
	if(curReach == internetReach)
	{
		
	}
	if(curReach == wifiReach)
	{
		
	}
	
}

//Bluetooth delegate methods
#pragma mark - GKPeerPickerControllerDelegate
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    // Create a session with a unique session ID - displayName:nil = Takes the iPhone Name
    GKSession* session = [[GKSession alloc] initWithSessionID:@"com.arcmobile.connect" displayName:nil sessionMode:GKSessionModePeer];
    return session;
}

// Tells us that the peer was connected
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    // Get the session and assign it locally
    self.connectionSession = session;
    session.delegate = self;
    
    [picker dismiss];
}


- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    if (state == GKPeerStateConnected) {
        // Add the peer to the Array
        [self.connectionPeers addObject:peerID];
        
        // Used to acknowledge that we will be sending data
        [session setDataReceiveHandler:self withContext:nil];
        
        //In case you need to do something else when a peer connects, do it here
    }
    else if (state == GKPeerStateDisconnected) {
        [self.connectionPeers removeObject:peerID];
        //Any processing when a peer disconnects
    }
}







- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.trackEventArray = [NSMutableArray array];
    //Checking versionNumber
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"didShowVersionWarning"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Bluetooth
    self.connectionPicker = [[GKPeerPickerController alloc] init];
    self.connectionPicker.delegate = self;
    //NOTE - GKPeerPickerConnectionTypeNearby is for Bluetooth connection, you can do the same thing over Wi-Fi with different type of connection
    self.connectionPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    self.connectionPeers = [[NSMutableArray alloc] init];
    
    
     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    // one reason this method is called is if a push notification is received while the app is in the background
    // if custom data in push notification payload, then establish appropriate "context" in this app
    if (launchOptions != nil)
    {
        NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            NSLog(@"Launched from push notification: %@", dictionary);
            
            // TODO  look for custom payload and establish context
        }
    }
    
    self.logout = @"";
    
    [[UIApplication sharedApplication]
     setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    //Switch storyboards if iPhone 5
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        UIStoryboard *storyBoard;
        
        CGSize result = [[UIScreen mainScreen] bounds].size;
        CGFloat scale = [UIScreen mainScreen].scale;
        result = CGSizeMake(result.width * scale, result.height * scale);
        
        if(result.height == 1136){
            storyBoard = [UIStoryboard storyboardWithName:@"ArcMainStoryboardiPhone5" bundle:nil];
            UIViewController *initViewController = [storyBoard instantiateInitialViewController];
            [self.window setRootViewController:initViewController];
        }
    }
    
    //Reachability
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name:kReachabilityChangedNotification object: nil];
    
    //::Change to ARC Server
    hostReach = [Reachability reachabilityWithHostName: @"arc-stage.dagher.mobi"];
	[hostReach startNotifier];
	[self updateInterfaceWithReachability: hostReach];
	
    internetReach = [Reachability reachabilityForInternetConnection];
	[internetReach startNotifier];
	[self updateInterfaceWithReachability: internetReach];
    
    wifiReach = [Reachability reachabilityForLocalWiFi];
	[wifiReach startNotifier];
	[self updateInterfaceWithReachability: wifiReach];
    
    
    // *** for rSkybox
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter]; NSError *error;
    /* Check if we previously crashed */
    if ([crashReporter hasPendingCrashReport]) {
    
        [self handleCrashReport];
    }
    
    if (![crashReporter enableCrashReporterAndReturnError: &error]){
        //NSLog(@"*************************Warning: Could not enable crash reporter: %@", error);
    }
    // ***
    
    // Override point for customization after application launch.
    [self initManagedDocument];
    
    
    return YES;
}



// this method is called if a push notification is received while the app is already running
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    //  Push notification received while the app is running
    
    NSLog(@"Received notification: %@", userInfo);
    
    // TODO  look for custom payload and establish context
}


//Push Notification Delegate methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
    
    NSString *deviceTokenStr = [[[devToken description]
                                 stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                                stringByReplacingOccurrencesOfString:@" "
                                withString:@""];
    
    self.pushToken = [deviceTokenStr uppercaseString];
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *customerId = [prefs stringForKey:@"customerId"];
    NSString *customerToken = [prefs stringForKey:@"customerToken"];
    
    
    if (![customerId isEqualToString:@""] && (customerId != nil) && ![customerToken isEqualToString:@""] && (customerToken != nil)) {
        //[self performSegueWithIdentifier: @"signInNoAnimation" sender: self];
        //self.autoSignIn = YES;
        ArcClient *tmp = [[ArcClient alloc] init];
        [tmp updatePushToken];
    }
 
    
}



- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSLog(@"Token Failed: %@", err);
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    ArcClient *tmp = [[ArcClient alloc] init];
    [tmp sendTrackEvent:self.trackEventArray];
    
    self.trackEventArray = [NSMutableArray array];
    
    [self.connectionSession disconnectFromAllPeers];
    [self.connectionPeers removeAllObjects];
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appActive" object:self userInfo:nil];

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    ArcClient *client = [[ArcClient alloc] init];
    [client getServer];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // *** for rSkybox
    [self performSelectorInBackground:@selector(createEndUser) withObject:nil];
    // ***
    
    
    @try {
        if (self.documentReady) {
            
            [self doPaymentCheck];
            
        }
    }
    @catch (NSException *exception) {
        
    }
  
    
}

-(void)doPaymentCheck{
    
    @try {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSString *customerId = [prefs stringForKey:@"customerId"];
        NSString *customerToken = [prefs stringForKey:@"customerToken"];
        
        
        if (![customerId isEqualToString:@""] && (customerId != nil) && ![customerToken isEqualToString:@""] && (customerToken != nil)) {
            
            //If the user is logged in
            BOOL hasToken = [DwollaAPI hasToken];
            
            NSArray *creditCards = [NSArray arrayWithArray:[self getAllCreditCardsForCurrentCustomer]];
            
            if (([creditCards count] == 0) && !hasToken) {
                //No payment sources found
                NSLog(@"NONE FOUND");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NoPaymentSourcesNotification" object:self userInfo:nil];
                
            }
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }
   

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// *** for rSkybox
- (void) handleCrashReport {

    
    @try {
        PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
        NSData *crashData;
        NSError *error;
        self.crashDetectDate = [NSDate date];
        self.crashStackData = nil;
        //self.crashUserName = mainDelegate.token;
        /* Try loading the crash report */
        bool isNil = false;
        crashData = [crashReporter loadPendingCrashReportDataAndReturnError: &error];
        
        if (crashData == nil) {
            //NSLog(@"Could not load crash report: %@", error);
            isNil = true;
        }
        
        if(!isNil) {
            PLCrashReport *report = [[PLCrashReport alloc] initWithData:crashData error:&error];
            bool thisIsNil = false;
            if(report == nil) {
                self.crashSummary = @"Could not parse crash report";
                [self performSelectorInBackground:@selector(sendCrashDetect) withObject:nil];
                thisIsNil = true;
            }
            
            if(!thisIsNil) {
                @try {
                    NSString *platform = [[UIDevice currentDevice] platformString];
                    self.crashSummary = [NSString stringWithFormat:@"Crashed with signal=%@, app version=%@,osversion=%@, hardware=%@", report.signalInfo.name, report.applicationInfo.applicationVersion, report.systemInfo.operatingSystemVersion, platform];
                    self.crashStackData = [crashReporter loadPendingCrashReportDataAndReturnError: &error];
                    [self performSelectorInBackground:@selector(sendCrashDetect) withObject:nil];
                }
                @catch (NSException *exception) { }
            }else{
                [crashReporter purgePendingCrashReport]; return;
            }
        } else{
            [crashReporter purgePendingCrashReport]; return;
        }

    }
    @catch (NSException *exception) {
        
        
    }
   
    
   
}

- (id)init {
    [rSkybox initiateSession];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.appActions = [prefs valueForKey:@"appActions"];
    self.appActionsTime = [prefs valueForKey:@"appActionsTime"];
    @try {
        if ([self.appActions length] > 0) {
            //Set the trace session array
            NSMutableArray *tmpTraceArray = [NSMutableArray arrayWithArray:[self.appActions componentsSeparatedByString:@","]];
            NSMutableArray *tmpTraceTimeArray = [NSMutableArray arrayWithArray:[self.appActionsTime componentsSeparatedByString:@","]];
            NSMutableArray *tmpDateArray = [NSMutableArray array];
            for (int i = 0; i < [tmpTraceTimeArray count]; i++) {
                NSString *tmpTime = [tmpTraceTimeArray objectAtIndex:i];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]; NSDate *theDate = [dateFormatter dateFromString:tmpTime];
                [tmpDateArray addObject:theDate];
            }
            [rSkybox setSavedArray:tmpTraceArray :tmpDateArray];
        }
    }
    @catch (NSException *exception) {
    }
    return self;
}

-(void)sendCrashDetect {
    @autoreleasepool {
        // send crash detect to GAE
        [rSkybox sendCrashDetect:self.crashSummary theStackData:self.crashStackData];
        PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
        [crashReporter purgePendingCrashReport];
    }
}

-(void)saveUserInfo{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:self.appActions forKey:@"appActions"];
    [prefs setValue:self.appActionsTime forKey:@"appActionsTime"];
    [prefs synchronize];
}

-(void)createEndUser{
    @autoreleasepool {
    [rSkybox createEndUser];
    }
}
// ***

- (void)handleError:(NSError *)error userInteractionPermitted:(BOOL)userInteractionPermitted{

    NSLog(@"Error: %@", error);
    
}

- (BOOL)loadFromContents:(id)contents
ofType:(NSString *)typeName
                   error:(NSError **)outError{
    
    //NSLog(@"Error: %@", outError);
    return YES;

}
-(void)initManagedDocument{
    @try {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"DataBase"];
        

        
        self.managedDocument = [[UIManagedDocument alloc] initWithFileURL:url];
        

        if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]){
            
            [self.managedDocument openWithCompletionHandler:^(BOOL success){
                if (success) {
                    [self documentIsReady];
                }else{
                    NSLog(@"Could not open document");
                }

            }];
            
        }else{
            
            [self.managedDocument saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
                
                if (success) {
                    [self documentIsReady];
                }else{
                    NSLog(@"Could not create document");
                }
            }];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.initManagedDocument" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)documentIsReady{
    @try {
        NSLog(@"Document is ready!!");
        self.documentReady = YES;
        if (self.managedDocument.documentState == UIDocumentStateNormal) {
            self.managedObjectContext = self.managedDocument.managedObjectContext;
        }
        
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"checkedNoUsers"] length] == 0) {
     
        [self checkNoUsers];
    }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.documentIsReady" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)checkNoUsers{
    @try {
        NSArray *customers = [self getAllCustomers];
        
        if (!customers) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noUsersFound" object:self userInfo:nil];

        }else{
            //there are users
            NSLog(@"Here");
        }
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ArcAppDelegate.checkNoUsers" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];

    }
   
}

-(void)saveDocument{
    @try {
        [self.managedDocument saveToURL:self.managedDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
            
            if (!success) {
                NSLog(@"******************Failed to save");
            }else{
                NSLog(@"******************Saved Document Successfully");
            }
        }];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.saveDocument" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)closeDocument{
    @try {
        [self.managedDocument closeWithCompletionHandler:^(BOOL success){
            
            if (!success) {
                //NSLog(@"Failed to close");
            }else{
               // NSLog(@"Closed Document");
            }
        }];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.closeDocument" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)insertCustomerWithId:(NSString *)customerId andToken:(NSString *)customerToken{
    
    @try {
        
        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"checkedNoUsers"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"Inserting Customer***********");
        
        [rSkybox addEventToSession:@"insertCustomerWithId"];

        //Only inserts if one doesn't already exist
        Customer *customer = [self getCurrentCustomer];
        
        if (!customer) {
            
            NSLog(@"Test");
           // NSLog(@"Inserting Customer");
            Customer *customer = [NSEntityDescription insertNewObjectForEntityForName:@"Customer" inManagedObjectContext:self.managedObjectContext];
            
            customer.customerId = customerId;
            customer.customerToken = customerToken;
            
            
            [self saveDocument];
            
        }else{
            NSLog(@"Customer Already Exists");
        }
    }
    @catch (NSException *e) {
        
        [rSkybox sendClientLog:@"ArcAppDelegate.insertCustomerWithId" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
  
}

-(void)reInsertCard{
    
    [self insertCreditCardWithNumber:self.storedNumber andSecurityCode:self.storedSecurityCode andExpiration:self.storedExpiration andPin:self.storedPin andCreditDebit:self.storedCreditDebit];
}


-(void)insertCreditCardWithNumber:(NSString *)number andSecurityCode:(NSString *)securityCode andExpiration:(NSString *)expiration andPin:(NSString *)pin andCreditDebit:(NSString *)andCreditDebit{
    

    @try {
        [rSkybox addEventToSession:@"insertCreditCardWithNumber"];
                
        Customer *customer = [self getCurrentCustomer];
        
        
        if (!customer) {
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *customerId = [prefs valueForKey:@"customerId"];
            NSString *customerToken = [prefs valueForKey:@"customerToken"];
            
            [self insertCustomerWithId:customerId andToken:customerToken];
            
            self.waitingCustomerInsertion = YES;
            
            self.storedNumber = number;
            self.storedSecurityCode = securityCode;
            self.storedExpiration = expiration;
            self.storedPin = pin;
            self.storedCreditDebit = andCreditDebit;
            
            [self performSelector:@selector(reInsertCard) withObject:nil afterDelay:1.5];

        }else{
            
            [ArcClient trackEvent:@"CREDIT_CARD_ADD"];

            CreditCard *creditCard = [NSEntityDescription insertNewObjectForEntityForName:@"CreditCard" inManagedObjectContext:self.managedObjectContext];
            
            NSString *sample = [NSString stringWithFormat:@"%@ Card ****%@", andCreditDebit, [number substringFromIndex:[number length]-4]];
            
            creditCard.expiration = expiration;
            creditCard.sample = sample;
            creditCard.number = [FBEncryptorAES encryptBase64String:number keyString:pin separateLines:NO];
            creditCard.securityCode = [FBEncryptorAES encryptBase64String:securityCode keyString:pin separateLines:NO];
            creditCard.whoOwns = customer;
            creditCard.cardType = [ArcUtility getCardTypeForNumber:number];
            

            [self saveDocument];
            
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.insertCreditCardWithNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
  
}

-(Customer *)getCurrentCustomer{
    
    @try {
        [rSkybox addEventToSession:@"getCurentCustomer"];

        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSString *customerId = [prefs valueForKey:@"customerId"];
        //NSString *customerToken = [prefs valueForKey:@"customerToken"];
        
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Customer"];
        request.predicate = [NSPredicate predicateWithFormat:@"customerId == %@", customerId];
        
        NSError *error;
        
        NSArray *returnedArray = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (returnedArray == nil) {
            NSLog(@"returnArray was NIL");
            return nil;
        }else if ([returnedArray count] == 0){
            NSLog(@"NIL");
            return nil;
        }else{
            NSLog(@"RETURNING A CUSTOMER");
            return (Customer *)[returnedArray objectAtIndex:0];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.getCurrentCustomer" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return nil;
    }
   
    
}

-(NSArray *)getAllCreditCardsForCurrentCustomer{
    
  
    @try {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSString *customerId = [prefs valueForKey:@"customerId"];
       // NSString *customerToken = [prefs valueForKey:@"customerToken"];
        
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CreditCard"];
        request.predicate = [NSPredicate predicateWithFormat:@"whoOwns.customerId == %@", customerId];
        
        NSError *error;
        
        NSArray *returnedArray = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (returnedArray == nil) {
            //NSLog(@"returnArray was NIL");
            return nil;
        }else if ([returnedArray count] == 0){
            //NSLog(@"Card Count was NIL");
            return nil;
        }else{
           // NSLog(@"Card retreival was GOOD!!!");
            return returnedArray;
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.getAllCreditCardsForCurrentCustomer" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @[];
    }
   
    
}

-(NSArray *)getAllCustomers{
    
    
    @try {
           
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Customer"];
        
        NSError *error;
        
        NSArray *returnedArray = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (returnedArray == nil) {
            //NSLog(@"returnArray was NIL");
            return nil;
        }else if ([returnedArray count] == 0){
            //NSLog(@"Card Count was NIL");
            return nil;
        }else{
            // NSLog(@"Card retreival was GOOD!!!");
            return returnedArray;
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.getAllCustomers" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @[];
    }
    
    
}


-(NSArray *)getCreditCardWithNumber:(NSString *)number andSecurityCode:(NSString *)securityCode andExpiration:(NSString *)expiration{
    
    @try {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CreditCard"];
        request.predicate = [NSPredicate predicateWithFormat:@"(number == %@) AND (securityCode == %@) AND (expiration == %@)", number, securityCode, expiration];
        
        NSError *error;
        
        NSArray *returnedArray = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (returnedArray == nil) {
           // NSLog(@"returnArray was NIL");
            return nil;
        }else if ([returnedArray count] == 0){
           // NSLog(@"Card Count was NIL");
            return nil;
        }else{
            //NSLog(@"Card retreival was GOOD!!!");
            return returnedArray;
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.getCreditCardWithNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @[];
    }
    
}


-(void)deleteCreditCardWithNumber:(NSString *)number andSecurityCode:(NSString *)securityCode andExpiration:(NSString *)expiration{
    
    @try {
        [rSkybox addEventToSession:@"deleteCreditCardWithNumber"];

        NSArray *tmp = [self getCreditCardWithNumber:number andSecurityCode:securityCode andExpiration:expiration];
        
        if ([tmp count] > 0){
            
            CreditCard *tmpCard = [tmp objectAtIndex:0];
            
            [self.managedObjectContext deleteObject:tmpCard];
            
            [self saveDocument];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.deleteCreditCardWithNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
  
}

-(NSString *)getCustomerId{
    @try {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        return [prefs valueForKey:@"customerId"];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.getCustomerId" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
    
}

-(NSString *)getCustomerToken{
    @try {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        return [prefs valueForKey:@"customerToken"];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.getCustomerId" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
    
}

-(void)showNewVersionAlert{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Version Available!" message:@"A new version of ARC is available for download.  Would you like to update now?" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Update", nil];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 1) {
        //Go to ARC in app store
        
        NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa";
        str = [NSString stringWithFormat:@"%@/wa/viewContentsUserReviews?", str];
        str = [NSString stringWithFormat:@"%@type=Purple+Software&id=", str];
        
        // Here is the app id from itunesconnect
        str = [NSString stringWithFormat:@"%@563542097", str];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

    }
    
}


@end
