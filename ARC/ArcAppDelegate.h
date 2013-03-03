//
//  AppDelegate.h
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Customer.h"
#import "Reachability.h"
#import "CreditCard.h"
#import <GameKit/GameKit.h>
#import <CoreLocation/CoreLocation.h>

#define UIAppDelegate ((ArcAppDelegate *)[UIApplication sharedApplication].delegate)

@interface ArcAppDelegate : UIResponder <UIApplicationDelegate, GKSessionDelegate, GKPeerPickerControllerDelegate, CLLocationManagerDelegate>
{
    
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
}
//TrackEvent
@property (nonatomic, strong) NSMutableArray *trackEventArray;

//Bluetooth
@property (strong) GKSession* connectionSession;
@property (nonatomic, strong) NSMutableArray *connectionPeers;
@property (nonatomic, strong) GKPeerPickerController* connectionPicker;

//Location
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) NSString *lastLatitude;
@property (nonatomic, strong) NSString *lastLongitude;

@property BOOL documentReady;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSString *logout;
@property (nonatomic, strong) NSString *pushToken;

@property BOOL waitingCustomerInsertion;

-(NSString *)getCustomerId;
-(NSString *)getCustomerToken;

@property (nonatomic, strong) UIManagedDocument *managedDocument;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


@property (nonatomic, strong) NSString *storedNumber;
@property (nonatomic, strong) NSString *storedSecurityCode;
@property (nonatomic, strong) NSString *storedExpiration;
@property (nonatomic, strong) NSString *storedPin;
@property (nonatomic, strong) NSString *storedCreditDebit;



-(void)documentIsReady;
-(void)initManagedDocument;

-(void)saveDocument;
-(void)closeDocument;

-(void)insertCustomerWithId:(NSString *)customerId andToken:(NSString *)customerToken;

-(void)insertCreditCardWithNumber:(NSString *)number andSecurityCode:(NSString *)securityCode andExpiration:(NSString *)expiration andPin:(NSString *)pin andCreditDebit:(NSString *)andCreditDebit;

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


-(void)doPaymentCheck;
-(void)showNewVersionAlert;

@end
