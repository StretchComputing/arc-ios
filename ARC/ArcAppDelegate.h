//
//  AppDelegate.h
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Customer.h"

@interface ArcAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSString *logout;

-(NSString *)getCustomerId;
-(NSString *)getCustomerToken;

@property (nonatomic, strong) UIManagedDocument *managedDocument;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


-(void)documentIsReady;
-(void)initManagedDocument;

-(void)saveDocument;
-(void)closeDocument;

-(void)insertCustomerWithId:(NSString *)customerId andToken:(NSString *)customerToken;

-(void)insertCreditCardWithNumber:(NSString *)number andSecurityCode:(NSString *)securityCode andExpiration:(NSString *)expiration andPin:(NSString *)pin;

-(Customer *)getCurrentCustomer;

-(NSArray *)getAllCreditCardsForCurrentCustomer;


-(NSArray *)getCreditCardWithNumber:(NSString *)number andSecurityCode:(NSString *)securityCode andExpiration:(NSString *)expiration;
-(void)deleteCreditCardWithNumber:(NSString *)number andSecurityCode:(NSString *)securityCode andExpiration:(NSString *)expiration;

// *** copied in for rSkybox
@property (nonatomic, strong) NSString *appActions;
@property (nonatomic, strong) NSString *appActionsTime;
@property (nonatomic, strong) NSString *crashSummary;
@property (nonatomic, strong) NSString *crashUserName;
@property (nonatomic, strong) NSDate *crashDetectDate;
@property (nonatomic, strong) NSData *crashStackData;
@property (nonatomic, strong) NSString *crashInstanceUrl;
-(void)saveUserInfo;
-(void)handleCrashReport;
// ***

@end
