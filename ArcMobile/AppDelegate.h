//
//  AppDelegate.h
//  ArcMobile
//
//  Created by Nick Wroblewski on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@property (nonatomic, strong) NSString *token;

@property (nonatomic, strong) NSString *appActions;
@property (nonatomic, strong) NSString *appActionsTime; 
@property (nonatomic, strong) NSString *crashSummary; 
@property (nonatomic, strong) NSString *crashUserName;
@property (nonatomic, strong) NSDate *crashDetectDate; 
@property (nonatomic, strong) NSData *crashStackData; 
@property (nonatomic, strong) NSString *crashInstanceUrl;

-(void)saveUserInfo; 
-(void)handleCrashReport;

@end
