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
                
                NSString *message = @"An internet connection is required for this app.  Please make sure you are connected to the internet to continue.";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Lost" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication]
     setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
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
        [self handleCrashReport]; }
    if (![crashReporter enableCrashReporterAndReturnError: &error]){
        //NSLog(@"*************************Warning: Could not enable crash reporter: %@", error);
    }
    // ***
    
    // Override point for customization after application launch.
    [self initManagedDocument];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // *** for rSkybox
    [self performSelectorInBackground:@selector(createEndUser) withObject:nil];
    // ***
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// *** for rSkybox
- (void) handleCrashReport {
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

- (id)init {
    [rSkybox initiateSession];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; self.appActions = [prefs valueForKey:@"appActions"]; self.appActionsTime = [prefs valueForKey:@"appActionsTime"];
    @try {
        if ([self.appActions length] > 0) {
            //Set the trace session array
            NSMutableArray *tmpTraceArray = [NSMutableArray arrayWithArray:[self.appActions componentsSeparatedByString:@","]];
            NSMutableArray *tmpTraceTimeArray = [NSMutableArray arrayWithArray:[self.appActionsTime componentsSeparatedByString:@","]];
            NSMutableArray *tmpDateArray = [NSMutableArray array];
            for (int i = 0; i < [tmpTraceTimeArray count]; i++) {
                NSString *tmpTime = [tmpTraceTimeArray objectAtIndex:i];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss.SSS"]; NSDate *theDate = [dateFormatter dateFromString:tmpTime];
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
        [crashReporter purgePendingCrashReport]; }
}

-(void)saveUserInfo{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; [prefs setValue:self.appActions forKey:@"appActions"];
    [prefs setValue:self.appActionsTime forKey:@"appActionsTime"]; [prefs synchronize];
}

-(void)createEndUser{ @autoreleasepool {
    [rSkybox createEndUser]; }
}
// ***


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
        
        if (self.managedDocument.documentState == UIDocumentStateNormal) {
            self.managedObjectContext = self.managedDocument.managedObjectContext;
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.documentIsReady" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(void)saveDocument{
    @try {
        [self.managedDocument saveToURL:self.managedDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
            
            if (!success) {
                NSLog(@"Failed to save");
            }else{
                NSLog(@"Saved Document Successfully");
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
                NSLog(@"Failed to close");
            }else{
                NSLog(@"Closed Document");
            }
        }];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.closeDocument" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)insertCustomerWithId:(NSString *)customerId andToken:(NSString *)customerToken{
    
    @try {
        //Only inserts if one doesn't already exist
        Customer *customer = [self getCurrentCustomer];
        
        if (!customer) {
            NSLog(@"Inserting Customer");
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

-(void)insertCreditCardWithNumber:(NSString *)number andSecurityCode:(NSString *)securityCode andExpiration:(NSString *)expiration andPin:(NSString *)pin andCreditDebit:(NSString *)andCreditDebit{
    

    @try {
        [rSkybox addEventToSession:@"insertCreditCardWithNumber"];
                
        Customer *customer = [self getCurrentCustomer];
        
        CreditCard *creditCard = [NSEntityDescription insertNewObjectForEntityForName:@"CreditCard" inManagedObjectContext:self.managedObjectContext];
        
        NSString *sample = [NSString stringWithFormat:@"%@ Card ****%@", andCreditDebit, [number substringFromIndex:[number length]-4]];
        
        creditCard.expiration = expiration;
        creditCard.sample = sample;
        creditCard.number = [FBEncryptorAES encryptBase64String:number keyString:pin separateLines:NO];
        creditCard.securityCode = [FBEncryptorAES encryptBase64String:securityCode keyString:pin separateLines:NO];
        creditCard.whoOwns = customer;
        
        [self saveDocument];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.insertCustomerWithId" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
  
}

-(Customer *)getCurrentCustomer{
    
    @try {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSString *customerId = [prefs valueForKey:@"customerId"];
        NSString *customerToken = [prefs valueForKey:@"customerToken"];
        
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Customer"];
        request.predicate = [NSPredicate predicateWithFormat:@"(customerId == %@) AND (customerToken == %@)", customerId, customerToken];
        
        NSError *error;
        
        NSArray *returnedArray = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (returnedArray == nil) {
            NSLog(@"returnArray was NIL");
            return nil;
        }else if ([returnedArray count] == 0){
            
            return nil;
        }else{
            return (Customer *)[returnedArray objectAtIndex:0];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.getCurrentCustomer" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @[];
    }
   
    
}

-(NSArray *)getAllCreditCardsForCurrentCustomer{
    
  
    @try {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSString *customerId = [prefs valueForKey:@"customerId"];
        NSString *customerToken = [prefs valueForKey:@"customerToken"];
        
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CreditCard"];
        request.predicate = [NSPredicate predicateWithFormat:@"(whoOwns.customerId == %@) AND (whoOwns.customerToken == %@)", customerId, customerToken];
        
        NSError *error;
        
        NSArray *returnedArray = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (returnedArray == nil) {
            NSLog(@"returnArray was NIL");
            return nil;
        }else if ([returnedArray count] == 0){
            NSLog(@"Card Count was NIL");
            return nil;
        }else{
            NSLog(@"Card retreival was GOOD!!!");
            return returnedArray;
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcAppDelegate.getAllCreditCardsForCurrentCustomer" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
            NSLog(@"returnArray was NIL");
            return nil;
        }else if ([returnedArray count] == 0){
            NSLog(@"Card Count was NIL");
            return nil;
        }else{
            NSLog(@"Card retreival was GOOD!!!");
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

@end
