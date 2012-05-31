//
//  AppDelegate.m
//  ArcMobile
//
//  Created by Nick Wroblewski on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import <CrashReporter/CrashReporter.h>
#import "UIDevice-Hardware.h"
#import "rSkybox.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController, token;
@synthesize appActions, appActionsTime, crashSummary, crashUserName, crashStackData, crashDetectDate, crashInstanceUrl;


- (id) init {
    
    [rSkybox initiateSession];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; self.appActions = [prefs valueForKey:@"appActions"]; self.appActionsTime = [prefs valueForKey:@"appActionsTime"];
    @try {
        if ([self.appActions length] > 0) {
            //Set the trace session array
            NSMutableArray *tmpTraceArray = [NSMutableArray arrayWithArray:[self.appActions
                                                                            componentsSeparatedByString:@","]];
            NSMutableArray *tmpTraceTimeArray = [NSMutableArray arrayWithArray:[self.appActionsTime componentsSeparatedByString:@","]];
            NSMutableArray *tmpDateArray = [NSMutableArray array];
            for (int i = 0; i < [tmpTraceTimeArray count]; i++) {
                NSString *tmpTime = [tmpTraceTimeArray objectAtIndex:i];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss.SSS"]; NSDate *theDate = [dateFormatter dateFromString:tmpTime];
                [tmpDateArray addObject:theDate]; }
            [rSkybox setSavedArray:tmpTraceArray :tmpDateArray]; }
    }
    @catch (NSException *exception) {
    }
    
    self.token = @"asf87sdf78sfd78ds";
    
    return self; 
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter]; NSError *error;
    /* Check if we previously crashed */
    if ([crashReporter hasPendingCrashReport]) {
        [self handleCrashReport]; }
    if (![crashReporter enableCrashReporterAndReturnError: &error]){ //NSLog(@"*************************Warning: Could not enable crash reporter: %@", error);
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
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
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self performSelectorInBackground:@selector(createEndUser) withObject:nil];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) handleCrashReport {
    
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter]; 
    
    NSData *crashData;
    NSError *error;
    self.crashDetectDate = [NSDate date];
    self.crashStackData = nil; //self.crashUserName = mainDelegate.token;
    /* Try loading the crash report */
    bool isNil = false;
    crashData = [crashReporter loadPendingCrashReportDataAndReturnError: &error]; 
    
    if (crashData == nil) {
        //NSLog(@"Could not load crash report: %@", error);
        isNil = true;
    
    }
    if (!isNil) {
        PLCrashReport *report = [[PLCrashReport alloc] initWithData: crashData error: &error];
        bool thisIsNil = false;
        
        if (report == nil) {
            self.crashSummary = @"Could not parse crash report";
            [self performSelectorInBackground:@selector(sendCrashDetect) withObject:nil]; 
            thisIsNil = true;
        }
        

        
        if (!thisIsNil){
            
            @try {
                NSString *platform = [[UIDevice currentDevice] platformString];
                self.crashSummary = [NSString stringWithFormat:@"Crashed with signal=%@, app version=%@, os version=%@, hardware=%@", report.signalInfo.name, report.applicationInfo.applicationVersion, report.systemInfo.operatingSystemVersion, platform];
                self.crashStackData = [crashReporter loadPendingCrashReportDataAndReturnError: &error];
                [self performSelectorInBackground:@selector(sendCrashDetect) withObject:nil];
                
            }
            @catch (NSException *exception){
                
            }
            
        }else{
            [crashReporter purgePendingCrashReport]; 
            return;
        }
       
        
       
        
       
    }else{
        [crashReporter purgePendingCrashReport]; return;
    }
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

@end
