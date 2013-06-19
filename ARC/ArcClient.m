//
//  ArcClient.m
//  ARC
//
//  Created by Joseph Wroblewski on 8/5/12.
//
//

#import "ArcClient.h"
#import "SBJson.h"
#import "ArcAppDelegate.h"
#import "rSkybox.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "Home.h"
#import "ArcIdentifier.h"

//NSString *_arcUrl = @"http://68.57.205.193:8700/arc-dev/rest/v1/";    //Jim's Place
//NSString *_arcUrl = @"http://arc-stage.dagher.mobi/rest/v1/";           // STAGE

//NSString *_arcUrl = @"http://dtnetwork.asuscomm.com:8700/arc-dev/rest/v1/";

//NSString *_arcUrl = @"http://dev.dagher.mobi/rest/v1/";       //DEV - Cloud
//NSString *_arcUrl = @"http://24.14.40.71:8700/arc-dev/rest/v1/";
NSString *_arcUrl = @"https://arc.dagher.mobi/rest/v1/";           // CLOUD
//NSString *_arcUrl = @"http://dtnetwork.dyndns.org:8700/arc-dev/rest/v1/";  // Jim's Place

//NSString *_arcServersUrl = @"http://arc-servers.dagher.mobi/rest/v1/"; // Servers API: CLOUD I
//NSString *_arcServersUrl = @"http://arc-servers.dagher.net.co/rest/v1/"; // Servers API: CLOUD II
NSString *_arcServersUrl = @"http://gateway.dagher.mobi/rest/v1/"; // NEW dedicated ServerURL CLOUD

//NSString *_arcServersUrl = @"http://dtnetwork.dyndns.org:8700/arc-servers/rest/v1/"; // Servers API: Jim's Place

int const USER_ALREADY_EXISTS = 103;
int const INCORRECT_PASSCODE = 105;
int const INCORRECT_LOGIN_INFO = 106;
int const INVOICE_CLOSED = 603;
int const INVOICE_NOT_FOUND = 604;
int const MERCHANT_CANNOT_ACCEPT_PAYMENT_TYPE = 400;
int const OVER_PAID = 401;
int const INVALID_AMOUNT = 402;

int const CANNOT_PROCESS_PAYMENT = 500;
int const CANNOT_TRANSFER_TO_SAME_ACCOUNT = 501;
int const INVALID_ACCOUNT_PIN = 502;
int const INSUFFICIENT_FUNDS = 503;

int const PAYMENT_MAYBE_PROCESSED = 602;
int const FAILED_TO_VALIDATE_CARD = 605;
int const FIELD_FORMAT_ERROR = 606;
int const INVALID_ACCOUNT_NUMBER = 607;
int const CANNOT_GET_PAYMENT_AUTHORIZATION = 608;
int const INVALID_EXPIRATION_DATE = 610;
int const UNKOWN_ISIS_ERROR = 699;
int const DUPLICATE_TRANSACTION = 612;

//Micros
int const CARD_ALREADY_PROCESSED = 628;
int const CHECK_IS_LOCKED = 630;
int const NO_AUTHORIZATION_PROVIDED = 631;

int const MAX_RETRIES_EXCEEDED = 1000;


static NSMutableDictionary *latencyStartTimes = nil;

NSString *const ARC_ERROR_MSG = @"Arc Error, try again later";

@implementation ArcClient

+ (void) initialize{
    latencyStartTimes = [[NSMutableDictionary alloc] init];
}

- (id)init {
    if (self = [super init]) {
        
        self.retryTimes = @[@(6),@(2),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9),@(10)];
        self.retryTimesRegister = @[@(3),@(3),@(2),@(3),@(4),@(6)];
        self.retryTimesInvoice = @[@(2),@(2),@(2),@(3),@(4),@(5)];

        self.serverPingArray = [NSMutableArray array];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        if ([prefs valueForKey:@"arcUrl"] && ([[prefs valueForKey:@"arcUrl"] length] > 0)) {
           _arcUrl = [prefs valueForKey:@"arcUrl"];
        }
        NSLog(@"***** Arc URL = %@ *****", _arcUrl);
    }
    return self;
}

-(NSString *)getCurrentUrl{
    return _arcUrl;
}

-(void)getServer{
    @try {
        [rSkybox addEventToSession:@"getServer"];
        api = GetServer;
        
        //NSString *createUrl = [NSString stringWithFormat:@"%@servers/%@", _arcUrl, [[NSUserDefaults standardUserDefaults] valueForKey:@"customerId"], nil];
        
        NSString *createUrl = [NSString stringWithFormat:@"%@servers/assign/current", _arcServersUrl];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createUrl]];
        
        [request setHTTPMethod: @"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        if (![[self authHeader] isEqualToString:@""]) {
           [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        }

        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"GetServer"];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getServer" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)createCustomer:(NSDictionary *)pairs{
    @try {
        [rSkybox addEventToSession:@"createCustomer"];
        api = CreateCustomer;
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [pairs JSONRepresentation], nil];
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        NSString *createUrl = [NSString stringWithFormat:@"%@customers/create", _arcUrl];
        
        //NSLog(@"CreateUrl: %@", createUrl);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createUrl]];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"CreateCusotmer"];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.createCustomer" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)updateGuestCustomer:(NSDictionary *)pairs{
    @try {
        [rSkybox addEventToSession:@"updateGuestCustomer"];
        api = UpdateGuestCustomer;
        
        NSString *guestId = [[NSUserDefaults standardUserDefaults] valueForKey:@"guestId"];
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [pairs JSONRepresentation], nil];
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        NSString *createUrl = [NSString stringWithFormat:@"%@customers/update/current", _arcUrl];
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createUrl]];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];

        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"UpdateGuestCustomer"];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.updateGuestCustomer" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)getCustomerToken:(NSDictionary *)pairs{
    @try {
        [rSkybox addEventToSession:@"getCustomerToken"];
        api = GetCustomerToken;
        
        
        NSString * login = [ pairs objectForKey:@"userName"];
        NSString * password = [ pairs objectForKey:@"password"];
        
        
        NSMutableDictionary *loginDictionary = [ NSMutableDictionary dictionary];
        [loginDictionary setValue:login forKey:@"Login"];
        [loginDictionary setValue:password forKey:@"Password"];
        // the phone always sets activate to true. The website never does. Only the phone can reactivate a user.
        NSNumber *activate = [NSNumber numberWithBool:YES];
        [loginDictionary setValue:activate forKey:@"Activate"];

        
        NSString *requestString = [NSString stringWithFormat:@"%@", [loginDictionary JSONRepresentation], nil];
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
       // NSString *getCustomerTokenUrl = [NSString stringWithFormat:@"%@customers?login=%@&password=%@", _arcUrl, login, password,nil];
        NSString *getCustomerTokenUrl = [NSString stringWithFormat:@"%@customers/token", _arcUrl, nil];
                

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:getCustomerTokenUrl]];
        [request setHTTPMethod: @"SEARCH"];
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"GetCusotmerToken"];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getCustomerToken" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)getGuestToken:(NSDictionary *)pairs{
    @try {
        [rSkybox addEventToSession:@"getGuestToken"];
        api = GetGuestToken;
        
        
        NSString * login = [ pairs objectForKey:@"userName"];
        NSString * password = [ pairs objectForKey:@"password"];
        
        
        NSMutableDictionary *loginDictionary = [ NSMutableDictionary dictionary];
        [loginDictionary setValue:login forKey:@"Login"];
        [loginDictionary setValue:password forKey:@"Password"];
        [loginDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"IsGuest"];
        // the phone always sets activate to true. The website never does. Only the phone can reactivate a user.
        NSNumber *activate = [NSNumber numberWithBool:YES];
        [loginDictionary setValue:activate forKey:@"Activate"];
        
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [loginDictionary JSONRepresentation], nil];
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        // NSString *getCustomerTokenUrl = [NSString stringWithFormat:@"%@customers?login=%@&password=%@", _arcUrl, login, password,nil];
        NSString *getCustomerTokenUrl = [NSString stringWithFormat:@"%@customers/token", _arcUrl, nil];
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:getCustomerTokenUrl]];
        [request setHTTPMethod: @"SEARCH"];
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSLog(@"Params: %@", requestString);
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"GetGuestToken"];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getCustomerToken" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)getMerchantList:(NSDictionary *)pairs{
    @try {
        [rSkybox addEventToSession:@"getMerchantList"];
        api = GetMerchantList;
        
        pairs = [NSDictionary dictionary];
        NSMutableDictionary *loginDictionary = [NSMutableDictionary dictionaryWithDictionary:pairs];
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [loginDictionary JSONRepresentation], nil];
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        //NSLog(@"getMerchantList requestString = %@", requestString);
        
        NSString *getMerchantListUrl = [NSString stringWithFormat:@"%@merchants/list", _arcUrl, nil];
        //NSLog(@"GertMerchantList URL = %@", getMerchantListUrl);
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:getMerchantListUrl]];
        [request setHTTPMethod: @"SEARCH"];
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];   
        
        NSLog(@"Request: %@", requestString);
        
       // NSLog(@"Auth Header: %@", [self authHeader]);
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"GetMerchantList"];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getMerchantList" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)getInvoice:(NSDictionary *)pairs{
    @try {
        [rSkybox addEventToSession:@"getInvoice"];
        api = GetInvoice;
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

        if (pairs) {
            
            self.getInvoiceInvoiceNumber = [pairs valueForKey:@"invoiceNumber"];
            self.getInvoiceMerchantId = [pairs valueForKey:@"merchantId"];
            [dictionary setValue:[pairs valueForKey:@"invoiceNumber"] forKey:@"Number"];
            [dictionary setValue:[pairs valueForKey:@"merchantId"] forKey:@"MerchantId"];
            [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"Process"];
            
            NSNumber *pos = [NSNumber numberWithBool:YES];
            [dictionary setValue:pos forKey:@"POS"];
        }else{
            
            [dictionary setValue:self.getInvoiceInvoiceNumber forKey:@"Number"];
            [dictionary setValue:self.getInvoiceMerchantId forKey:@"MerchantId"];
            [dictionary setValue:[NSNumber numberWithBool:NO] forKey:@"Process"];
            [dictionary setValue:self.invoiceRequestId forKey:@"RequestId"];
            
            NSNumber *pos = [NSNumber numberWithBool:YES];
            [dictionary setValue:pos forKey:@"POS"];
            
        }
        
       
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [dictionary JSONRepresentation], nil];
        
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        
        NSString *getInvoiceUrl = [NSString stringWithFormat:@"%@invoices/criteria", _arcUrl];

        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:getInvoiceUrl]];
        [request setHTTPMethod: @"SEARCH"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];

        [request setHTTPBody: requestData];

        
        NSLog(@"getInvoiceUrl: %@", getInvoiceUrl);

        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"GetInvoice"];
        [ArcClient startLatency:GetInvoice];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getInvoice" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void) createPayment:(NSDictionary *)pairs{
    
    NSLog(@"Calling Create Payment at: %@", [NSDate date]);

    @try {
        [rSkybox addEventToSession:@"createPayment"];
        api = CreatePayment;
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [pairs JSONRepresentation], nil];
        
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        NSString *createPaymentUrl = [NSString stringWithFormat:@"%@payments/create", _arcUrl, nil];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createPaymentUrl]];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        
        NSLog(@"RequestString: %@", requestString);
        
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"CreatePayment"];
        [ArcClient startLatency:CreatePayment];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.createPayment" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)createReview:(NSDictionary *)pairs{
    @try {
        [rSkybox addEventToSession:@"createReview"];
        api = CreateReview;
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [pairs JSONRepresentation], nil];
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        NSString *createReviewUrl = [NSString stringWithFormat:@"%@reviews/new", _arcUrl, nil];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createReviewUrl]];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"GetReview"];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.createReview" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)getPointBalance:(NSDictionary *)pairs{
    @try {
        [rSkybox addEventToSession:@"getPointBalance"];
        api = GetPointBalance;
        
        NSString * customerId = [pairs valueForKey:@"customerId"];
        
        NSString *createReviewUrl = [NSString stringWithFormat:@"%@points/balance/%@", _arcUrl, customerId, nil];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createReviewUrl]];
        [request setHTTPMethod: @"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"GetPointBalance"];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getPointBalance" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)trackEvent:(NSDictionary *)pairs{
    @try {
        [rSkybox addEventToSession:@"TrackEventAdded"];

        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        [mainDelegate.trackEventArray addObject:pairs];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.trackEventPairs" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)sendTrackEvent:(NSMutableArray *)eventArray{
    
    @try {
        [rSkybox addEventToSession:@"SendTrackEvents"];
        api = TrackEvent;
        
        NSDictionary *myDictionary = @{@"Analytics" : [NSArray arrayWithArray:eventArray]};
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [myDictionary JSONRepresentation], nil];
        NSLog(@"requestString: %@", requestString);
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        NSString *trackEventUrl = [NSString stringWithFormat:@"%@analytics/new", _arcUrl, nil];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:trackEventUrl]];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        @try {
            [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        }
        @catch (NSException *exception) {
            
        }
        
        NSLog(@"TrackEventURL: %@", trackEventUrl);
        
        NSLog(@"RequestString: %@", requestString);
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"SendTrackEvents"];
        //self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:nil startImmediately: YES];
        
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.sendTrackEvent" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)getPasscode:(NSDictionary *)pairs{
    @try {
        [rSkybox addEventToSession:@"getPasscode"];
        api = GetPasscode;
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [pairs JSONRepresentation], nil];
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        NSString *createReviewUrl = [NSString stringWithFormat:@"%@customers/passcode", _arcUrl, nil];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createReviewUrl]];
        //[request setHTTPMethod: @"PUT"];
        [request setHTTPMethod: @"POST"];

        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        //[request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"getPasscode"];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.createReview" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)resetPassword:(NSDictionary *)pairs{
    
    @try {
        [rSkybox addEventToSession:@"resetPassword"];
        api = ResetPassword;
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [pairs JSONRepresentation], nil];
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        NSString *createReviewUrl = [NSString stringWithFormat:@"%@customers/passwordreset", _arcUrl, nil];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createReviewUrl]];
        //[request setHTTPMethod: @"PUT"];
        [request setHTTPMethod: @"POST"];

        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        //[request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        
        //NSLog(@"Request String: %@", requestString);
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"resetPassword"];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.createReview" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)setServer:(NSString *)serverNumber{
    @try {
        [rSkybox addEventToSession:@"setAdminServer"];
        api = SetAdminServer;
        
        NSString *customerId = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerId"];
        
        NSString *createUrl = [NSString stringWithFormat:@"http://arc-servers.dagher.net.co/rest/v1/servers/%@/setserver/%@", customerId, serverNumber];
        
        //NSLog(@"CreateUrl: %@", createUrl);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createUrl]];
        [request setHTTPMethod: @"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];

        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"setAdminServer"];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.setServerNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)updatePushToken{
    
    @try {
        [rSkybox addEventToSession:@"updatePushToken"];
        api = UpdatePushToken;

        NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if ([mainDelegate.pushToken length] > 0) {
            
            [pairs setValue:mainDelegate.pushToken forKey:@"DeviceId"];
            
            [pairs setValue:@"Production" forKey:@"PushType"];
            
#if DEBUG==1
            [pairs setValue:@"Development" forKey:@"PushType"];
#endif
            
            
            
            NSNumber *noMail = [NSNumber numberWithBool:YES];
            [pairs setValue:noMail forKey:@"NoMail"];
            
            NSString *requestString = [NSString stringWithFormat:@"%@", [pairs JSONRepresentation], nil];
            NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
            
            ArcClient *tmp = [[ArcClient alloc] init];
            NSString *arcUrl = [tmp getCurrentUrl];
            
            NSString *merchantId = [[NSUserDefaults standardUserDefaults] valueForKey:@"customerId"];
            merchantId = @"current";
            
            NSString *createReviewUrl = [NSString stringWithFormat:@"%@customers/update/%@", arcUrl, merchantId, nil];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createReviewUrl]];
            [request setHTTPMethod: @"POST"];
            
            [request setHTTPBody: requestData];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:[tmp authHeader] forHTTPHeaderField:@"Authorization"];
            
            NSLog(@"Request String: %@", requestString);
            
            self.serverData = [NSMutableData data];
            [rSkybox startThreshold:@"updatePushToken"];
            self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
            
            
        }
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.updatePushToken" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)referFriend:(NSArray *)emailAddresses{
    
    @try {
        [rSkybox addEventToSession:@"referFriend"];
        api = ReferFriend;
        
        NSMutableArray *emailAddressArray = [NSMutableArray array];
        
        for (int i = 0; i < [emailAddresses count]; i++) {
            
            NSMutableDictionary *pairs = [NSMutableDictionary dictionary];            
            [pairs setValue:[emailAddresses objectAtIndex:i] forKey:@"eMail"];
            
            [emailAddressArray addObject:pairs];
        }
      
        
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [emailAddressArray JSONRepresentation], nil];
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
    
  
        
        NSString *createReviewUrl = [NSString stringWithFormat:@"%@customers/referfriends", _arcUrl, nil];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createReviewUrl]];
        [request setHTTPMethod: @"POST"];
        
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"referFriend"];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.referFriend" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)confirmPayment{
    
    NSLog(@"Calling Confirm Payment at: %@", [NSDate date]);
    
    @try {
        [rSkybox addEventToSession:@"confirmPayment"];
        api = ConfirmPayment;
                
        NSDictionary *params = @{@"TicketId" : self.ticketId};
                
        NSString *requestString = [NSString stringWithFormat:@"%@", [params JSONRepresentation], nil];
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
                
        NSString *createReviewUrl = [NSString stringWithFormat:@"%@payments/confirm", _arcUrl, nil];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createReviewUrl]];
        [request setHTTPMethod: @"SEARCH"];
        
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        

        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"confirmPayment"];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.confirmPayment" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)confirmRegister{
    
    @try {
        [rSkybox addEventToSession:@"confirmRegister"];
        api = ConfirmRegister;
        
        NSDictionary *params = @{@"TicketId" : self.registerTicketId};
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [params JSONRepresentation], nil];
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        NSString *createReviewUrl = [NSString stringWithFormat:@"%@customers/register/confirm", _arcUrl, nil];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createReviewUrl]];
        [request setHTTPMethod: @"SEARCH"];
        
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        //[request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        
    
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"confirmRegister"];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.confirmRegister" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}



-(void)sendServerPings{
    @try {
        [rSkybox addEventToSession:@"sendServerPing"];
        api = PingServer;
        
        
        NSString *pingUrl = @"http://arc.dagher.net.co/rest/v1/tools/ping";
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:pingUrl]];
        
        [request setHTTPMethod: @"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"sendServerPing"];
        self.pingStartTime = [NSDate date];
        [request setTimeoutInterval:5];
        self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.sendServerPings" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}



- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)mdata {
    @try {
        
        [self.serverData appendData:mdata];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.connection" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    self.httpStatusCode = [httpResponse statusCode];
    
    NSLog(@"Server Call: %d", api);
    NSLog(@"HTTP Status Code: %d", self.httpStatusCode);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    @try {
        
        NSString *logName = [NSString stringWithFormat:@"api.%@.threshold", [self apiToString]];
        [rSkybox endThreshold:logName logMessage:@"fake logMessage" maxValue:14000.00];
        
        NSData *returnData = [NSData dataWithData:self.serverData];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
       // NSLog(@"ReturnString: %@", returnString);
        
        SBJsonParser *jsonParser = [SBJsonParser new];
        NSDictionary *response = (NSDictionary *) [jsonParser objectWithString:returnString error:NULL];
        
        NSDictionary *responseInfo;
        NSString *notificationType;
        
        BOOL httpSuccess = self.httpStatusCode == 200 || self.httpStatusCode == 201 || self.httpStatusCode == 422;
        
        BOOL postNotification = YES;
        BOOL isGetServer = NO;

        if(api == CreateCustomer) { //jpw5
            postNotification = NO;
            if (response && httpSuccess) {
                responseInfo = [self createCustomerResponse:response];
            }else{
                postNotification = YES;

            }
            notificationType = @"registerNotification";
        } else if(api == UpdateGuestCustomer) {
        

            if (response && httpSuccess) {
                responseInfo = [self getUpdateGuestCustomerResponse:response];
            }
            notificationType = @"updateGuestCustomerNotification";
        }else if(api == GetCustomerToken) {
            if (response && httpSuccess) {
                responseInfo = [self getCustomerTokenResponse:response];
            }
            notificationType = @"signInNotification";
        } else if(api == GetGuestToken) {
            
            if (response && httpSuccess) {
                responseInfo = [self getGuestTokenResponse:response];
            }
            notificationType = @"signInNotificationGuest";
        }else if(api == GetMerchantList) {
            if (response && httpSuccess) {
                responseInfo = [self getMerchantListResponse:response];
            }
            notificationType = @"merchantListNotification";
        } else if(api == GetInvoice) {
            
            postNotification = NO;
            if (response && httpSuccess) {
                responseInfo = [self getInvoiceResponse:response];
            } else {
                BOOL successful = FALSE;
                postNotification = YES;
                [ArcClient endAndReportLatency:GetInvoice logMessage:@"GetInvoice API completed" successful:successful];
            }
            notificationType = @"invoiceNotification";
            
        } else if(api == CreatePayment) {
            
            postNotification = NO;
            if (response && httpSuccess) {
                responseInfo = [self createPaymentResponse:response];
            } else {
                BOOL successful = FALSE;
                postNotification = YES;
                [ArcClient endAndReportLatency:CreatePayment logMessage:@"CreatePayment API completed" successful:successful];
            }
            notificationType = @"createPaymentNotification";
            
        } else if(api == CreateReview) {
            if (response && httpSuccess) {
                responseInfo = [self createReviewResponse:response];
            }
            notificationType = @"createReviewNotification";
        } else if(api == GetPointBalance) {
            
            notificationType = @"registerNotification";

            if (response && httpSuccess) {
                responseInfo = [self getPointBalanceResponse:response];
            }
            notificationType = @"getPointBalanceNotification";
        }  else if(api == GetPasscode) {
            if (response && httpSuccess) {
                responseInfo = [self getPasscodeResponse:response];
            }
            notificationType = @"getPasscodeNotification";
        } else if(api == ResetPassword) {
            if (response && httpSuccess) {
                responseInfo = [self resetPasswordResponse:response];
            }
            notificationType = @"resetPasswordNotification";
        }else if(api == TrackEvent) {
            if (response && httpSuccess) {
                //responseInfo = [self trackEventResponse:response];
            }
            postNotification = NO;
        }else if (api == GetServer){
            postNotification = NO;
            isGetServer = YES;
            if (response && httpSuccess) {
                [self setUrl:response];
            }
        }else if (api == SetAdminServer){
            if (response && httpSuccess) {
                responseInfo = [self setServerResponse:response];
            }
            notificationType = @"setServerNotification";

        }else if (api == UpdatePushToken){
            postNotification = NO;
        }else if (api == ReferFriend){
            if (response && httpSuccess) {
                responseInfo = [self referFriendResponse:response];
            }
            notificationType = @"referFriendNotification";
            
        }else if (api == ConfirmPayment){
            postNotification = NO;
            if (response && httpSuccess) {
                responseInfo = [self confirmPaymentResponse:response];
            }else{
                notificationType = @"createPaymentNotification";
                postNotification = YES;

            }
        }else if (api == ConfirmRegister){
            postNotification = NO;
            if (response && httpSuccess) {
                responseInfo = [self confirmRegisterResponse:response];
            }else{
                notificationType = @"registerNotification";
                postNotification = YES;
            }
        }else if (api == PingServer){
            postNotification = NO;
            if (response && httpSuccess) {
                responseInfo = [self pingServerResponse:response];
            }
        }
        
        if(!httpSuccess) {
            // failure scenario -- HTTP error code returned -- for this processing, we don't care which API failed
            
            NSString *sendUrl = _arcUrl;
            if (isGetServer) {
                sendUrl = _arcServersUrl;
            }
            NSString *errorMsg = [NSString stringWithFormat:@"HTTP Status Code:%d for API %@ on %@", self.httpStatusCode, [self apiToString], sendUrl];
            responseInfo = @{@"status": @"fail", @"error": @0};
            [rSkybox sendClientLog:@"ArcClient.connectionDidFinishLoading" logMessage:errorMsg logLevel:@"error" exception:nil];
        }

        if (postNotification) {
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationType object:self userInfo:responseInfo];
        }
        
        [self displayErrorsToAdmins:response];
}
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.connectionDidFinishLoading" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    @try {
        [rSkybox endThreshold:@"ErrorEncountered" logMessage:@"NA" maxValue:0.00];
        
        //NSLog(@"Error: %@", error);
        //NSLog(@"Code: %i", error.code);
        //NSLog(@"Description: %@", error.localizedDescription);

        
        NSString *urlString = [[[connection currentRequest] URL] absoluteString];
        
        // TODO make logType a function of the restaurant/location -- not sure the best way to do this yet
        NSString *logName = [NSString stringWithFormat:@"api.%@.%@ - %@", [self apiToString], [self readableErrorCode:error], urlString];
        
        if (api != PingServer) {
            [rSkybox sendClientLog:logName logMessage:error.localizedDescription logLevel:@"error" exception:nil];
        }
        
        BOOL postNotification = YES;
        BOOL successful = FALSE;

        NSDictionary *responseInfo = @{@"status": @"fail", @"error": @0};
        NSString *notificationType;
        if(api == CreateCustomer) {
            notificationType = @"registerNotification";
        } else if(api == UpdateGuestCustomer) {
            notificationType = @"updateGuestCustomerNotification";
        }else if(api == GetCustomerToken) {
            notificationType = @"signInNotification";
        }else if(api == GetCustomerToken) {
            notificationType = @"signInNotificationGuest";
        }
        else if(api == GetMerchantList) {
            notificationType = @"merchantListNotification";
        } else if(api == GetInvoice) {
            notificationType = @"invoiceNotification";
            BOOL successful = FALSE;
            [ArcClient endAndReportLatency:GetInvoice logMessage:@"GetInvoice API completed" successful:successful];
        } else if(api == CreatePayment) {
            notificationType = @"createPaymentNotification";
            BOOL successful = FALSE;
            [ArcClient endAndReportLatency:CreatePayment logMessage:@"CreatePayment API completed" successful:successful];
        } else if(api == CreateReview) {
            notificationType = @"createReviewNotification";
        } else if(api == GetPointBalance) {
            notificationType = @"getPointBalanceNotification";
        } else if(api == TrackEvent) {
            notificationType = @"trackEventNotification";   // posting notification for now, but nobody is listenting
        } else if(api == GetPasscode) {
            notificationType = @"getPasscodeNotification";
        } else if(api == ResetPassword) {
            notificationType = @"resetPasswordNotification";
        }else if (api == SetAdminServer){
            notificationType = @"setServerNotification";
        }else if (api == ConfirmPayment){
            
            if(error.code == -1003){
                //try again
                postNotification = NO;
                
                if (self.numberConfirmPaymentTries > 10) {
                
                    NSString *status = @"error";
                    int errorCode = MAX_RETRIES_EXCEEDED;
                    responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
                    successful = FALSE;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"createPaymentNotification" object:self userInfo:responseInfo];
                    [ArcClient endAndReportLatency:CreatePayment logMessage:@"CreatePayment API completed" successful:successful];
                    
                }else{
                    
                    int retryTime = [[self.retryTimes objectAtIndex:self.numberConfirmPaymentTries] intValue];
                    
                    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:retryTime target:self selector:@selector(confirmPayment) userInfo:nil repeats:NO];
                }
                
            }else{
                
                notificationType = @"createPaymentNotification";
            
                
            }
            
        }else if (api == ConfirmRegister){
            
            if(error.code == -1003){
                //try again
                postNotification = NO;
                if (self.numberRegisterTries > 6) {
                    
                    NSString *status = @"error";
                    int errorCode = MAX_RETRIES_EXCEEDED;
                    responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
                    successful = FALSE;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"registerNotification" object:self userInfo:responseInfo];
                    [ArcClient endAndReportLatency:CreatePayment logMessage:@"CreateCustomer API completed" successful:successful];
                    
                }else{
                    
                    int retryTime = [[self.retryTimesRegister objectAtIndex:self.numberRegisterTries] intValue];
                    
                    self.myRegisterTimer = [NSTimer scheduledTimerWithTimeInterval:retryTime target:self selector:@selector(confirmRegister) userInfo:nil repeats:NO];
                }
                
            }else{
                notificationType = @"registerNotification";

            }
        }else if (api == PingServer){
            postNotification = NO;
            responseInfo = [self pingServerResponse:nil];

        }
        
        if (postNotification == YES) {
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationType object:self userInfo:responseInfo];
        }
        
        [self displayErrorMessageToAdmins:logName];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.connection" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

- (void)displayErrorsToAdmins:(NSDictionary *)response {
    if([self admin]) {
        //NSLog(@"user is an admin");
        
        NSMutableString* errorMsg = [NSMutableString string];
        NSArray *errorArr = [response valueForKey:@"ErrorCodes"];
        NSEnumerator *e = [errorArr objectEnumerator];
        NSDictionary *dict;
        while (dict = [e nextObject]) {
            int code = [[dict valueForKey:@"Code"] intValue];
            NSString *category = [dict valueForKey:@"Category"];
            [errorMsg appendFormat:@"code:%d category:%@", code, category];
        }
        
        if([errorMsg length] > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"For Admins Only"  message:[NSString stringWithString:errorMsg] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alert show];
        }
        
    }
    
}

- (void)displayErrorMessageToAdmins:(NSString *)errorMsg {
    if([self admin]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"For Admins Only"  message:errorMsg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
}

- (int)getErrorCode:(NSDictionary *)response {
    int errorCode = 0;
    NSDictionary *error = [[response valueForKey:@"ErrorCodes"] objectAtIndex:0];
    errorCode = [[error valueForKey:@"Code"] intValue];
    return errorCode;
}

-(NSString *)readableErrorCode:(NSError *)error {
    int errorCode = error.code;
    if(errorCode == -1000) return @"NSURLErrorBadURL";
    else if(errorCode == -1001) return @"TimedOut";
    else if(errorCode == -1002) return @"UnsupportedURL";
    else if(errorCode == -1003) return @"CannotFindHost";
    else if(errorCode == -1004) return @"CannotConnectToHost";
    else if(errorCode == -1005) return @"NetworkConnectionLost";
    else if(errorCode == -1006) return @"DNSLookupFailed";
    else if(errorCode == -1007) return @"HTTPTooManyRedirects";
    else if(errorCode == -1008) return @"ResourceUnavailable";
    else if(errorCode == -1009) return @"NotConnectedToInternet";
    else if(errorCode == -1011) return @"BadServerResponse";
    else return [NSString stringWithFormat:@"%i", error.code];
}

- (NSString*)apiToString {
    NSString *result = nil;
    
    switch(api) {
        case GetServer:
            result = @"GetServer";
            break;
        case CreateCustomer:
            result = @"CreateCustomer";
            break;
        case GetCustomerToken:
            result = @"GetCustomerToken";
            break;
        case GetGuestToken:
            result = @"GetGuestToken";
            break;
        case GetMerchantList:
            result = @"GetMerchantList";
            break;
        case GetInvoice:
            result = @"GetInvoice";
            break;
        case CreatePayment:
            result = @"CreatePayment";
            break;
        case CreateReview:
            result = @"CreateReview";
            break;
        case GetPointBalance:
            result = @"GetPointBalance";
            break;
        case TrackEvent:
            result = @"TrackEvent";
            break;
        case GetPasscode:
            result = @"GetPasscode";
            break;
        case ResetPassword:
            result = @"ResetPassword";
            break;
        case SetAdminServer:
            result = @"SetAdminServer";
            break;
            
        case UpdatePushToken:
            result = @"UpdatePushToken";
            break;
            
        case ReferFriend:
            result = @"ReferFriend";
            break;
            
        case ConfirmPayment:
            result = @"ConfirmPayment";
            break;
            
        case ConfirmRegister:
            result = @"ConfirmRegister";
            break;
            
        case UpdateGuestCustomer:
            result = @"UpdateGuestCustomer";
            break;
            
        case PingServer:
            result = @"PingServer";
            break;
 
        default:
            //[NSException raise:NSGenericException format:@"Unexpected FormatType."];
            break;
    }
    
    return result;
}

-(NSDictionary *) createCustomerResponse:(NSDictionary *)response {
    @try {
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            
            self.registerTicketId = [response valueForKey:@"Results"];
            
            self.numberRegisterTries = 0;
            
            int retryTime = [[self.retryTimesRegister objectAtIndex:self.numberRegisterTries] intValue];
            
            self.myRegisterTimer = [NSTimer scheduledTimerWithTimeInterval:retryTime target:self selector:@selector(confirmRegister) userInfo:nil repeats:NO];
            
            
         
        } else {
            NSString *status = @"error";
            int errorCode = [self getErrorCode:response];
            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"registerNotification" object:self userInfo:responseInfo];
            [ArcClient endAndReportLatency:CreateCustomer logMessage:@"CreateCustomer API completed" successful:success];
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.createCustomerResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};
    }
}


-(NSDictionary *) getUpdateGuestCustomerResponse:(NSDictionary *)response {
    @try {
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
                
            responseInfo = @{@"status": @"success", @"Results": [response valueForKey:@"Results"] };
        } else {
            NSString *status = @"error";
            int errorCode = [self getErrorCode:response];
            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.updateGuestCustomer" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};
        
    }
}




-(NSDictionary *) getCustomerTokenResponse:(NSDictionary *)response {
    @try {
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            
            NSDictionary *customer = [response valueForKey:@"Results"];
            NSString *customerId = [[customer valueForKey:@"Id"] stringValue];
            NSString *customerToken = [customer valueForKey:@"Token"];
            BOOL admin = [[customer valueForKey:@"Admin"] boolValue];
            //admin = YES; // for testing admin role
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            [prefs setObject:customerId forKey:@"customerId"];
            [prefs setObject:customerToken forKey:@"customerToken"];
            NSNumber *adminAsNum = [NSNumber numberWithBool:admin];
            [prefs setObject:adminAsNum forKey:@"admin"];
            [prefs synchronize];
            
            //Add this customer to the DB
            [self performSelector:@selector(addToDatabase) withObject:nil afterDelay:1.5];
            
            responseInfo = @{@"status": @"success"};
        } else {
            NSString *status = @"error";
            int errorCode = [self getErrorCode:response];
            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getCustomerTokenResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};

    }
}


-(NSDictionary *) getGuestTokenResponse:(NSDictionary *)response {
    @try {
        
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            
            NSDictionary *customer = [response valueForKey:@"Results"];
            NSString *customerId = [[customer valueForKey:@"Id"] stringValue];
            NSString *customerToken = [customer valueForKey:@"Token"];
 
            NSLog(@"CustomerToken: %@", customerToken);
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            [prefs setObject:customerId forKey:@"guestId"];
            [prefs setObject:customerToken forKey:@"guestToken"];
            
            NSNumber *adminAsNum = [NSNumber numberWithBool:NO];
            [prefs setObject:adminAsNum forKey:@"admin"];
            [prefs synchronize];
            
            //Add this customer to the DB
            //[self performSelector:@selector(addToDatabase) withObject:nil afterDelay:1.5];
            
            responseInfo = @{@"status": @"success"};
        } else {
            NSString *status = @"error";
            int errorCode = [self getErrorCode:response];
            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getGuestTokenResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};
        
    }
}



-(NSDictionary *) getMerchantListResponse:(NSDictionary *)response {
    @try {
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            responseInfo = @{@"status": @"success", @"apiResponse": response};
        } else {
            NSString *status = @"error";
            int errorCode = [self getErrorCode:response];
            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getMerchantListResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};

    }
}

-(void)recallGetInvoice{
    
    [self getInvoice:nil];
}

-(NSDictionary *) getInvoiceResponse:(NSDictionary *)response {
    
    @try {
        
        
        if ([self.invoiceTicketId length] == 0) {
            //first time
            
            BOOL success = [[response valueForKey:@"Success"] boolValue];
            
            NSDictionary *responseInfo;
            BOOL successful = TRUE;
            if (success){
                
                NSLog(@"Response: %@", response);
                self.invoiceTicketId = [[response valueForKey:@"Results"] valueForKey:@"LastUpdated"];
                self.invoiceRequestId = [[response valueForKey:@"Results"] valueForKey:@"RequestId"];
                self.numberGetInvoiceTries = 0;
                
                int retryTime = [[self.retryTimesInvoice objectAtIndex:self.numberGetInvoiceTries] intValue];
                
                NSLog(@"Retry Time: %d", retryTime);
                
                NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:retryTime target:self selector:@selector(recallGetInvoice) userInfo:nil repeats:NO];
                
            } else {
                
                
                NSString *status = @"error";
                int errorCode = [self getErrorCode:response];
                responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
                successful = FALSE;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"invoiceNotification" object:self userInfo:responseInfo];
                [ArcClient endAndReportLatency:CreatePayment logMessage:@"GetInvoice API completed" successful:successful];
                
            }
            
            
        }else{
            
            NSLog(@"Response: %@", response);
            
            BOOL success = [[response valueForKey:@"Success"] boolValue];
            
            NSDictionary *responseInfo;
            BOOL successful = TRUE;
            if (success){
                
                BOOL haveInvoice = NO;
                id results = [response valueForKey:@"Results"];
                
                NSLog(@"Results Class: %@", [results class]);
                
                @try {
                    if ([results count] > 0) {
                        haveInvoice = YES;
                    }
                }
                @catch (NSException *exception) {
                    
                }
                
                if (haveInvoice){
                    
                    responseInfo = @{@"status": @"success", @"apiResponse": response};

                     [[NSNotificationCenter defaultCenter] postNotificationName:@"invoiceNotification" object:self userInfo:responseInfo];
                    return [NSDictionary dictionary];
                    
                }else{
                        
                        self.numberGetInvoiceTries++;
                        
                        if (self.numberGetInvoiceTries <= [self.retryTimesInvoice count]) {
                            
                            int retryTime = [[self.retryTimesInvoice objectAtIndex:self.numberGetInvoiceTries] intValue];
                            
                            NSLog(@"Retry Time: %d", retryTime);
                            
                            NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:retryTime target:self selector:@selector(recallGetInvoice) userInfo:nil repeats:NO];
                            
                        }else{
                            NSString *status = @"error";
                            int errorCode = [self getErrorCode:response];
                            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
                            successful = FALSE;
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"invoiceNotification" object:self userInfo:responseInfo];
                            [ArcClient endAndReportLatency:CreatePayment logMessage:@"GetInvoice API completed" successful:successful];
                        }
                   
                }
            
            
            
        } else {
            
            
            NSString *status = @"error";
            int errorCode = [self getErrorCode:response];
            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
            successful = FALSE;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"invoiceNotification" object:self userInfo:responseInfo];
            [ArcClient endAndReportLatency:CreatePayment logMessage:@"GetInvoice API completed" successful:successful];
            
        }
        
        
        
        
        
        
    }
    
    
    return [NSDictionary dictionary];
}
@catch (NSException *e) {
    [rSkybox sendClientLog:@"ArcClient.getInvoiceResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    return @{};
    
}
  
    
    
  
}

-(NSDictionary *) createPaymentResponse:(NSDictionary *)response {
    @try {
            
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        BOOL successful = TRUE;
        if (success){
            
            self.ticketId = [response valueForKey:@"Results"];

            self.numberConfirmPaymentTries = 0;
          
            int retryTime = [[self.retryTimes objectAtIndex:self.numberConfirmPaymentTries] intValue];
            
            self.myTimer = [NSTimer scheduledTimerWithTimeInterval:retryTime target:self selector:@selector(confirmPayment) userInfo:nil repeats:NO];
            
            
            //responseInfo = @{@"status": @"success", @"apiResponse": response};
        } else {
            NSString *status = @"error";
            int errorCode = [self getErrorCode:response];
            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
            successful = FALSE;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"createPaymentNotification" object:self userInfo:responseInfo];
            [ArcClient endAndReportLatency:CreatePayment logMessage:@"CreatePayment API completed" successful:successful];

        }
        

        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.createPaymentResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};

    }
}

-(NSDictionary *) confirmPaymentResponse:(NSDictionary *)response {
    @try {
        
        self.numberConfirmPaymentTries++;
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        BOOL successful = TRUE;
        
        if (success){
            
            responseInfo = @{@"status": @"success", @"apiResponse": response};
            
            if ([response valueForKey:@"Results"]) {
                //complete successfully
                   [[NSNotificationCenter defaultCenter] postNotificationName:@"createPaymentNotification" object:self userInfo:responseInfo];
                [ArcClient endAndReportLatency:CreatePayment logMessage:@"CreatePayment API completed" successful:successful];

            }else{
                
                if (self.numberConfirmPaymentTries > 10) {
                    
                    NSString *status = @"error";
                    int errorCode = MAX_RETRIES_EXCEEDED;
                    responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
                    successful = FALSE;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"createPaymentNotification" object:self userInfo:responseInfo];
                    [ArcClient endAndReportLatency:CreatePayment logMessage:@"CreatePayment API completed" successful:successful];

                }else{
                    
                    int retryTime = [[self.retryTimes objectAtIndex:self.numberConfirmPaymentTries] intValue];

                    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:retryTime target:self selector:@selector(confirmPayment) userInfo:nil repeats:NO];
                }
            }
                     
        } else {
            NSString *status = @"error";
            int errorCode = [self getErrorCode:response];
            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
            successful = FALSE;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"createPaymentNotification" object:self userInfo:responseInfo];
            [ArcClient endAndReportLatency:CreatePayment logMessage:@"CreatePayment API completed" successful:successful];

        }
        
        
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.confirmPaymentResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};
        
    }
}


-(NSDictionary *)confirmRegisterResponse:(NSDictionary *)response {
    @try {
        
        self.numberRegisterTries++;
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        BOOL successful = TRUE;
        if (success){
            
         
 
            if ([response valueForKey:@"Results"]) {
                //complete successfully
                
                NSDictionary *customer = [response valueForKey:@"Results"];
                NSString *customerId = [[customer valueForKey:@"Id"] stringValue];
                NSString *customerToken = [customer valueForKey:@"Token"];
                
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                
                [prefs setObject:customerId forKey:@"customerId"];
                [prefs setObject:customerToken forKey:@"customerToken"];
                [prefs synchronize];
                
                //Add this customer to the DB
                // TODO is this still needed?
                [self performSelector:@selector(addToDatabase) withObject:nil afterDelay:1.5];
                
                responseInfo = @{@"status": @"success"};
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"registerNotification" object:self userInfo:responseInfo];
                [ArcClient endAndReportLatency:CreatePayment logMessage:@"CreateCustomer API completed" successful:successful];
                
            }else{
                
                
                if (self.numberRegisterTries > 5) {
                    
                    NSString *status = @"error";
                    int errorCode = MAX_RETRIES_EXCEEDED;
                    responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
                    successful = FALSE;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"registerNotification" object:self userInfo:responseInfo];
                    [ArcClient endAndReportLatency:CreatePayment logMessage:@"CreateCustomer API completed" successful:successful];
                    
                }else{
                    
                    int retryTime = [[self.retryTimesRegister objectAtIndex:self.numberRegisterTries] intValue];
                    
                    self.myRegisterTimer = [NSTimer scheduledTimerWithTimeInterval:retryTime target:self selector:@selector(confirmRegister) userInfo:nil repeats:NO];
                }
            }
            
        } else {
            NSString *status = @"error";
            int errorCode = [self getErrorCode:response];
            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
            successful = FALSE;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"registerNotification" object:self userInfo:responseInfo];
            [ArcClient endAndReportLatency:CreatePayment logMessage:@"CreateCustomer API completed" successful:successful];
            
        }
        
        
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.confirmRegisterResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};
        
    }
}


-(NSDictionary *) createReviewResponse:(NSDictionary *)response {
    @try {
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            responseInfo = @{@"status": @"success", @"apiResponse": response};
        } else {
            NSString *status = @"error";
            int errorCode = [self getErrorCode:response];
            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.createReviewResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};

    }
    
}


-(NSDictionary *)pingServerResponse:(NSDictionary *)response {
    @try {
        
        NSTimeInterval milliseconds = [[NSDate date] timeIntervalSinceDate:self.pingStartTime] * 1000;

        [self.serverPingArray addObject:[NSNumber numberWithDouble:milliseconds]];
        
        if (self.numberServerPings < 4) {
            //send again
            [self sendServerPings];
        }else{
            //calculate average, store in user defaults
            
            double total;
            for (int i = 0; i < [self.serverPingArray count]; i++) {
                
                total += [[self.serverPingArray objectAtIndex:i] doubleValue];
            }
            
            double average = total / (double)[self.serverPingArray count];
            
            NSString *averageTime = [NSString stringWithFormat:@"%.2f", average];
            
            
            [[NSUserDefaults standardUserDefaults] setValue:averageTime forKey:@"averageServerPingTime"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [ArcClient trackEvent:@"GET_SIGNAL_STRENGTH"];
        }
        
        self.numberServerPings ++;
        
        
        return [NSDictionary dictionary];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.pingServerResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};
        
    }
    
}

-(NSDictionary *) getPointBalanceResponse:(NSDictionary *)response {
    
    @try {
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            responseInfo = @{@"status": @"success", @"apiResponse": response};
        } else {
            NSString *status = @"error";
            int errorCode = [self getErrorCode:response];
            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getPointBalanceResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};
    }
    
 
}

-(NSDictionary *) getPasscodeResponse:(NSDictionary *)response {
    
    @try {
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            responseInfo = @{@"status": @"success", @"apiResponse": response};
        } else {
            NSString *status = @"error";
            int errorCode = [self getErrorCode:response];
            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getPasscodeResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};
    }
    
    
}

-(NSDictionary *) resetPasswordResponse:(NSDictionary *)response {
    
    @try {
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            responseInfo = @{@"status": @"success", @"apiResponse": response};
        } else {
            NSString *status = @"error";
            int errorCode = [self getErrorCode:response];
            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.resetPasswordResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};
    }
    
    
}

-(NSDictionary *) setServerResponse:(NSDictionary *)response {
    
    @try {
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            responseInfo = @{@"status": @"success", @"apiResponse": response};
        } else {
            NSString *status = @"error";
            int errorCode = [self getErrorCode:response];
            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.setServerResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};
    }
    
    
}

-(NSDictionary *) referFriendResponse:(NSDictionary *)response {
    
    @try {
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            responseInfo = @{@"status": @"success", @"apiResponse": response};
        } else {
            NSString *status = @"error";
            int errorCode = [self getErrorCode:response];
            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.setServerResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};
    }
    
    
}

-(NSDictionary *) trackEventResponse:(NSDictionary *)response {
    @try {
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            responseInfo = @{@"status": @"success", @"apiResponse": response};
        } else {
            NSString *status = @"error";
            int errorCode = [self getErrorCode:response];
            responseInfo = @{@"status": status, @"error": [NSNumber numberWithInt:errorCode]};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.trackEventResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};
    }
    
}


-(NSString *) authHeader {
    @try {
        
        NSString *customerToken = [self customerToken];
        NSString *guestToken = [self guestToken];

        if (customerToken) {
            
            NSLog(@"CustomerToken: %@", customerToken);
            
            NSString *stringToEncode = [@"customer:" stringByAppendingString:customerToken];
            NSString *authentication = [self encodeBase64:stringToEncode];
            
            return [@"Basic " stringByAppendingString:customerToken];
            return authentication;
        }else{
            
            if ([guestToken length] > 0) {
                //Guest
                NSString *stringToEncode = [@"customer:" stringByAppendingString:guestToken];
                NSString *authentication = [self encodeBase64:stringToEncode];
                
                return [@"Basic " stringByAppendingString:guestToken];
                return authentication;
            }else{
                
                //Guest Token must have failed at some point, need to get it before returning
                
                NSString *identifier = [ArcIdentifier getArcIdentifier];
                
                
                NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
                NSDictionary *loginDict = [[NSDictionary alloc] init];
                [ tempDictionary setObject:identifier forKey:@"userName"];
                [ tempDictionary setObject:identifier forKey:@"password"];
                
                loginDict = tempDictionary;
                ArcClient *client = [[ArcClient alloc] init];
                [client getGuestToken:loginDict];
                
                
                NSException *exception = [NSException exceptionWithName:@"No Guest Token" reason:@"Could not find guest token" userInfo:nil];
                [rSkybox sendClientLog:@"ArcClient.authHeader" logMessage:@"NO Guest Token" logLevel:@"error" exception:exception];

                return @"";
            }
            
        }
        
    }
    @catch (NSException *e) {
        return @"";
        [rSkybox sendClientLog:@"ArcClient.authHeader" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void) addToDatabase {
    @try {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *customerId = [prefs valueForKey:@"customerId"];
        NSString *customerToken = [prefs valueForKey:@"customerToken"];
        
        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        [mainDelegate insertCustomerWithId:customerId andToken:customerToken];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.addToDatabase" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(NSString *) customerToken {
    @try {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *customerToken = [prefs valueForKey:@"customerToken"];
        return customerToken;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.customerToken" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @"";
    }
}

-(NSString *) guestToken {
    @try {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *guestToken = [prefs valueForKey:@"guestToken"];
        return guestToken;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.guestToken" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @"";
    }
}

-(BOOL) admin {
    @try {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        BOOL admin = [[prefs valueForKey:@"admin"] boolValue];
        return admin;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.admin" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return NO;
    }
}

-(NSString *)encodeBase64:(NSString *)stringToEncode{	
    @try {
        
        NSData *encodeData = [stringToEncode dataUsingEncoding:NSUTF8StringEncoding];
        char encodeArray[512];
        memset(encodeArray, '\0', sizeof(encodeArray));
        
        // Base64 Encode username and password
        encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);
        NSString *dataStr = [NSString stringWithCString:encodeArray length:strlen(encodeArray)];
        NSString *encodedString =[@"" stringByAppendingFormat:@"Basic %@", dataStr];
        
        return encodedString;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.encodeBase64" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @"";
    }
}


-(void)setUrl:(NSDictionary *)response{
    @try{
        
        if ([[response valueForKey:@"Success"] boolValue]) {
            
            NSString *serverName = [[response valueForKey:@"Results"] valueForKey:@"Server"];
            BOOL isSSL = [[[response valueForKey:@"Results"] valueForKey:@"SSL"] boolValue];
            NSString *arcTwitterHandler = [[response valueForKey:@"Results"] valueForKey:@"ArcTwitterHandler"];
            NSString *arcFacebookHandler = [[response valueForKey:@"Results"] valueForKey:@"ArcFacebookHandler"];
            NSString *arcPhoneNumber = [[response valueForKey:@"Results"] valueForKey:@"ArcPhoneNumber"];
            NSString *arcMail = [[response valueForKey:@"Results"] valueForKey:@"ArcMail"];
            NSString *userStatus = [[response valueForKey:@"Results"] valueForKey:@"UserStatus"];
            NSString *loginType = [[response valueForKey:@"Results"] valueForKey:@"LoginType"];
            
            
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"didShowVersionWarning"] length] == 0) {
                
                NSString *iosVerion = [[response valueForKey:@"Results"] valueForKey:@"VersionIOS"];
                
                if ([iosVerion length] > 0) {
                    
                                    
                    if ([iosVerion compare:ARC_VERSION_NUMBER options:NSNumericSearch] == NSOrderedDescending) {
                        // ARC_VERSION_NUMBER is lower than the iosVersion
                        [[NSUserDefaults standardUserDefaults] setValue:@"yes" forKey:@"didShowVersionWarning"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
                        [mainDelegate showNewVersionAlert];
                    }
                    
                    
                    
                }

            }
            
            
            if (serverName && ([serverName length] > 0)) {
                NSString *scheme = @"https";
                if(!isSSL) scheme = @"http";
                NSString *arcUrl = [NSString stringWithFormat:@"%@://%@/rest/v1/", scheme, serverName];
                
                [[NSUserDefaults standardUserDefaults] setValue:arcUrl forKey:@"arcUrl"];
            }
            
            if(arcFacebookHandler == nil) {arcFacebookHandler = @"ArcMobileApp";}
            
            [[NSUserDefaults standardUserDefaults] setValue:arcTwitterHandler forKey:@"arcTwitterHandler"];
            [[NSUserDefaults standardUserDefaults] setValue:arcFacebookHandler forKey:@"arcFacebookHandler"];
            [[NSUserDefaults standardUserDefaults] setValue:arcPhoneNumber forKey:@"arcPhoneNumber"];
            [[NSUserDefaults standardUserDefaults] setValue:arcMail forKey:@"arcMail"];
            [[NSUserDefaults standardUserDefaults] setValue:loginType forKey:@"arcLoginType"];
            
            // if account is now inactive, clear out the token and go to login screen
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *customerToken = [prefs valueForKey:@"customerToken"];
            if([userStatus isEqualToString:@"I"] && customerToken != nil) {
                [prefs setObject:nil forKey:@"customerToken"];
                //NSLog(@"GetToken returned UserStatus Inactive -- token has been cleared");
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"customerDeactivatedNotification" object:self userInfo:nil];

            }

            [[NSUserDefaults standardUserDefaults] synchronize];
        
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.setUrl" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

+(void)trackEvent:(NSString *)action{
    @try{
        NSNumber *measureValue = @1.0F;
        [ArcClient trackEvent:action activityType:@"Analytics" measureType:@"Count" measureValue:measureValue successful:TRUE];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.trackEventAction" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


+(void)trackEvent:(NSString *)activity activityType:(NSString *)activityType measureType:(NSString *)measureType measureValue:(NSNumber *)measureValue successful:(BOOL)successful{
    @try{
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
		NSDictionary *trackEventDict = [[NSDictionary alloc] init];
        
        
        @try {
            [ tempDictionary setObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"merchantId"] forKey:@"MerchantId"];
        }
        @catch (NSException *exception) {
            
        }
       
        
    
        
        [ tempDictionary setObject:activity forKey:@"Activity"]; //ACTION
        [ tempDictionary setObject:activityType forKey:@"ActivityType"]; //CATEGORY

        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        @try {
            NSString *customerId = [mainDelegate getCustomerId];
            [ tempDictionary setObject:customerId forKey:@"EntityId"]; //get from auth header?
        }
        @catch (NSException *exception) {
            [ tempDictionary setObject:@"" forKey:@"EntityId"]; //get from auth header?

        }
     
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        
        [tempDictionary setObject:[dateFormat stringFromDate:currentDate] forKey:@"EventDate"];
     
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSString *loginType = [prefs valueForKey:@"arcLoginType"];
        if ([prefs valueForKey:@"arcLoginType"]) {
            [tempDictionary setObject:loginType forKey:@"EntityType"];
        }else{
            [tempDictionary setObject:@"LOGIN_TYPE_CUSTOMER" forKey:@"EntityType"];
        }
        
        [ tempDictionary setObject:@0.0 forKey:@"Latitude"];//optional
        [ tempDictionary setObject:@0.0 forKey:@"Longitude"];//optional
        [ tempDictionary setObject:measureType forKey:@"MeasureType"];//LABEL
        [ tempDictionary setObject:measureValue forKey:@"MeasureValue"];//VALUE
        [ tempDictionary setObject:@"Arc Mobile" forKey:@"Application"];
        
        //Location
        if ([mainDelegate.lastLongitude length] > 0) {
            [tempDictionary setValue:[NSNumber numberWithDouble:[mainDelegate.lastLatitude doubleValue]] forKey:@"Latitude"];
            [tempDictionary setValue:[NSNumber numberWithDouble:[mainDelegate.lastLongitude doubleValue]] forKey:@"Longitude"];
        }
        
        //PingServerResults
        if ([activity isEqualToString:@"GET_SIGNAL_STRENGTH"]) {
            @try {
                NSString *averageTime = [[NSUserDefaults standardUserDefaults] valueForKey:@"averageServerPingTime"];
                
                [ tempDictionary setObject:@"SIGNAL" forKey:@"MeasureType"];//LABEL
                [ tempDictionary setObject:averageTime forKey:@"MeasureValue"];//VALUE
                [ tempDictionary setObject:@"ANALYTICS" forKey:@"ActivityType"];//VALUE
            }
            @catch (NSException *exception) {
                
            }
        }
        
        NSString *mobileCarrier = @"UNKNOWN";
        @try {
            CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
            CTCarrier *carrier = [netinfo subscriberCellularProvider];
            mobileCarrier = [carrier carrierName];
            [ tempDictionary setObject:mobileCarrier forKey:@"Carrier"]; //TODO add real carrier
        }
        @catch (NSException *exception) {

        }

        //[ tempDictionary setObject:@"Profile page viewed" forKey:@"Description"]; //Jim removed description
        [ tempDictionary setObject:@"iOS" forKey:@"Source"];
        [ tempDictionary setObject:@"phone" forKey:@"SourceType"];//remove
        [ tempDictionary setObject:ARC_VERSION_NUMBER forKey:@"Version"];
        if(successful) {
            [ tempDictionary setObject:@(YES) forKey:@"Successful"];
        } else {
            [ tempDictionary setObject:@(NO) forKey:@"Successful"];
        }
        
		trackEventDict = tempDictionary;

        ArcClient *client = [[ArcClient alloc] init];
        [client trackEvent:trackEventDict];
        
    }
    @catch (NSException *e) {
                
        [rSkybox sendClientLog:@"ArcClient.trackEventActivity" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

+(void)startLatency:(APIS)api{
    @try{
        NSDate *startTime = [NSDate date];
        [latencyStartTimes setObject:startTime forKey:[NSNumber numberWithInt:api]];
        //NSLog(@"size of latencyStartTimes dictionary = %d", [latencyStartTimes count]);
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.startLatency" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

+(void)endAndReportLatency:(APIS)api logMessage:(NSString *)logMessage successful:(BOOL)successful {
    @try{
        NSDate *startTime = [latencyStartTimes objectForKey:[NSNumber numberWithInt:api]];
        if(startTime == nil) {
            //NSLog(@"endLatency() could not retrieve startTime");
            return;
        }
        
        NSString *activity = @"UNKNOWN_API";
        NSString *apiName = @"";
        if(api == GetInvoice) {
            activity = @"LATENCY_INVOICES_GET";
            apiName = @"Get Invoice";
        } else if(api == CreatePayment) {
            activity = @"LATENCY_PAYMENT_POST";
            apiName = @"Create Payment";
        } 
        NSTimeInterval milliseconds = [[NSDate date] timeIntervalSinceDate:startTime] * 1000;
        NSInteger roundedMilliseconds = milliseconds;
        //NSLog(@"total latency for %@ API in milliseconds = %@", apiName, [NSString stringWithFormat:@"%d", roundedMilliseconds]);
        
        
        [ArcClient trackEvent:activity activityType:@"Performance" measureType:@"Milliseconds" measureValue:[NSNumber numberWithInt:roundedMilliseconds] successful:successful];

    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.endAndReportLatency" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(void)cancelConnection{
    @try {
        [self.urlConnection cancel];
    }
    @catch (NSException *exception) {
        [rSkybox sendClientLog:@"ArcClient.cancelConnection" logMessage:@"Exception Caught" logLevel:@"error" exception:exception];
    }
  
}
@end
