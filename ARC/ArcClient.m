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

//NSString *_arcUrl = @"http://arc-dev.dagher.mobi/rest/v1/";       //DEV - Cloud
NSString *_arcUrl = @"http://arc.dagher.mobi/rest/v1/";           // CLOUD
//NSString *_arcUrl = @"http://dtnetwork.dyndns.org:8700/arc-dev/rest/v1/";  // Jim's Place

NSString *_arcServersUrl = @"http://arc-servers.dagher.mobi/rest/v1/"; // Servers API: CLOUD
//NSString *_arcServersUrl = @"http://dtnetwork.dyndns.org:8700/arc-servers/rest/v1/"; // Servers API: Jim's Place

@implementation ArcClient


- (id)init {
    if (self = [super init]) {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        if ([prefs valueForKey:@"arcUrl"] && ([[prefs valueForKey:@"arcUrl"] length] > 0)) {
            _arcUrl = [NSString stringWithFormat:@"http://%@/rest/v1/", [prefs valueForKey:@"arcUrl"]];
        }
        
    }
    return self;
}
-(void)getServer{
    @try {
        [rSkybox addEventToSession:@"getServer"];
        api = GetServer;
        
        
        //NSString *createUrl = [NSString stringWithFormat:@"%@servers/%@", _arcUrl, [[NSUserDefaults standardUserDefaults] valueForKey:@"customerId"], nil];
        
        NSString *createUrl = [NSString stringWithFormat:@"%@servers/current", _arcServersUrl];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createUrl]];
        
        [request setHTTPMethod: @"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        if (![[self authHeader] isEqualToString:@""]) {
           [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        }

        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"GetServer"];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
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
        
        NSString *createUrl = [NSString stringWithFormat:@"%@customers", _arcUrl, nil];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createUrl]];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"CreateCusotmer"];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.createCustomer" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)getCustomerToken:(NSDictionary *)pairs{
    @try {
        [rSkybox addEventToSession:@"getCustomerToken"];
        api = GetCustomerToken;
        
        
        NSString * login = [ pairs objectForKey:@"userName"];
        NSString * password = [ pairs objectForKey:@"password"];
        
        NSString *getCustomerTokenUrl = [NSString stringWithFormat:@"%@customers?login=%@&password=%@", _arcUrl, login, password,nil];
                

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:getCustomerTokenUrl]];
        [request setHTTPMethod: @"GET"];
        //[request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"GetCusotmerToken"];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getCustomerToken" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)getMerchantList:(NSDictionary *)pairs{
    @try {
        [rSkybox addEventToSession:@"getMerchantList"];
        api = GetMerchantList;
        
        //[rSkybox sendClientLog:@"getMerchantList" logMessage:@"jpw testing rSkybox in Arc" logLevel:@"error" exception:nil];
        
        NSString *getMerchantListUrl = [NSString stringWithFormat:@"%@merchants", _arcUrl, nil];
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:getMerchantListUrl]];
        [request setHTTPMethod: @"GET"];
        //[request setHTTPBody: requestData];
                
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"GetMerchantList"];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getMerchantList" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)getInvoice:(NSDictionary *)pairs{
    @try {
        [rSkybox addEventToSession:@"getInvoice"];
        api = GetInvoice;
        
        NSString * invoiceNumber = [pairs valueForKey:@"invoiceNumber"];
        NSString *merchantId = [pairs valueForKey:@"merchantId"];
        
        NSString *getInvoiceUrl = [NSString stringWithFormat:@"%@Invoices/%@/get/%@", _arcUrl, merchantId, invoiceNumber];
        //NSLog(@"getInvoiceUrl: %@", getInvoiceUrl);

        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:getInvoiceUrl]];
        [request setHTTPMethod: @"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"GetInvoice"];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getInvoice" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)createPayment:(NSDictionary *)pairs{
    @try {
        [rSkybox addEventToSession:@"createPayment"];
        api = CreatePayment;
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [pairs JSONRepresentation], nil];
        
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        NSString *createPaymentUrl = [NSString stringWithFormat:@"%@payments", _arcUrl, nil];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createPaymentUrl]];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
                
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"CreatePayment"];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
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
        
        NSString *createReviewUrl = [NSString stringWithFormat:@"%@reviews", _arcUrl, nil];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createReviewUrl]];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"GetReview"];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
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
        
        NSString *createReviewUrl = [NSString stringWithFormat:@"%@points/%@/balance", _arcUrl, customerId, nil];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createReviewUrl]];
        [request setHTTPMethod: @"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"GetPointBalance"];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getPointBalance" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(void)trackEvent:(NSDictionary *)pairs{
    @try {
        [rSkybox addEventToSession:@"trackEvent"];
        api = TrackEvent;
        
        NSDictionary *myDictionary = @{@"Analytics" : [NSArray arrayWithObject:pairs]};
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [myDictionary JSONRepresentation], nil];
        NSLog(@"requestString: %@", requestString);
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        NSString *trackEventUrl = [NSString stringWithFormat:@"%@analytics", _arcUrl, nil];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:trackEventUrl]];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        
        
        self.serverData = [NSMutableData data];
        [rSkybox startThreshold:@"TrackEvent"];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.trackEvent" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
    NSLog(@"HTTP Status Code: %d", self.httpStatusCode);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    @try {
        
        NSString *logName = [NSString stringWithFormat:@"api.%@.threshold", [self apiToString]];
        [rSkybox endThreshold:logName logMessage:@"fake logMessage" maxValue:5000.00];
        
        NSData *returnData = [NSData dataWithData:self.serverData];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        NSLog(@"ReturnString: %@", returnString);
        
        SBJsonParser *jsonParser = [SBJsonParser new];
        NSDictionary *response = (NSDictionary *) [jsonParser objectWithString:returnString error:NULL];
        
        NSDictionary *responseInfo;
        NSString *notificationType;
        
        if(self.httpStatusCode == 200 || self.httpStatusCode == 201) {
            // success scenario
        } else {
            // something went wrong, so let's figure out what
            if(self.httpStatusCode == 422) {
                // application error scenario
            } else {
                // failure scenario -- calling routine must abort
            }
        }
        
        
        
        BOOL postNotification = YES;
        
        if(api == CreateCustomer) {
            if (response) {
                responseInfo = [self createCustomerResponse:response];
            }
            notificationType = @"registerNotification";
        } else if(api == GetCustomerToken) {
            if (response) {
                responseInfo = [self getCustomerTokenResponse:response];
            }
            notificationType = @"signInNotification";
        } else if(api == GetMerchantList) {
            if (response) {
                responseInfo = [self getMerchantListResponse:response];
            }
            notificationType = @"merchantListNotification";
        } else if(api == GetInvoice) {
            if (response) {
                responseInfo = [self getInvoiceResponse:response];
            }
            notificationType = @"invoiceNotification";
        } else if(api == CreatePayment) {
            if (response) {
                responseInfo = [self createPaymentResponse:response];
            }
            notificationType = @"createPaymentNotification";
        } else if(api == CreateReview) {
            if (response) {
                responseInfo = [self createReviewResponse:response];
            }
            notificationType = @"createReviewNotification";
        } else if(api == GetPointBalance) {
            if (response) {
                responseInfo = [self getPointBalanceResponse:response];
            }
            notificationType = @"getPointBalanceNotification";
        } else if(api == TrackEvent) {
            if (response) {
                responseInfo = [self trackEventResponse:response];
            }
            postNotification = NO;
           // notificationType = @"trackEventNotification";  // posting notification for now, but nobody is listenting
        }else if (api == GetServer){
            
            postNotification = NO;
            if (response) {
                [self setUrl:response];
            }
            
        }

        if (postNotification) {
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationType object:self userInfo:responseInfo];
        }

        [self displayErrorsToAdmins];
}
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.connectionDidFinishLoading" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (void)displayErrorsToAdmins {
    
    // TODO if Admin, display all errors
    BOOL isAdmin = NO;
    if(isAdmin) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Admin Only Errors?"  message:@"Here is where the errors will go" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    @try {
        [rSkybox endThreshold:@"ErrorEncountered" logMessage:@"NA" maxValue:0.00];
        
        //NSLog(@"Error: %@", error);
        NSLog(@"Code: %i", error.code);
        NSLog(@"Description: %@", error.localizedDescription);

        // TODO make logType a function of the restaurant/location -- not sure the best way to do this yet
        NSString *logName = [NSString stringWithFormat:@"api.%@.%@", [self apiToString], [self readableErrorCode:error]];
        [rSkybox sendClientLog:logName logMessage:error.localizedDescription logLevel:@"error" exception:nil];

        NSDictionary *responseInfo = @{@"status": @"fail", @"error": error};
        NSString *notificationType;
        if(api == CreateCustomer) {
            notificationType = @"registerNotification";
        } else if(api == GetCustomerToken) {
            notificationType = @"signInNotification";
        } else if(api == GetMerchantList) {
            notificationType = @"merchantListNotification";
        } else if(api == GetInvoice) {
            notificationType = @"invoiceNotification";
        } else if(api == CreatePayment) {
            notificationType = @"createPaymentNotification";
        } else if(api == CreatePayment) {
            notificationType = @"createReviewNotification";
        } else if(api == GetPointBalance) {
            notificationType = @"getPointBalanceNotification";
        } else if(api == TrackEvent) {
            notificationType = @"trackEventNotification";   // posting notification for now, but nobody is listenting
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationType object:self userInfo:responseInfo];
        
        [self displayErrorsToAdmins];

    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.connection" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
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
            
            NSDictionary *customer = [response valueForKey:@"Results"];
            NSString *customerId = [[customer valueForKey:@"Id"] stringValue];
            NSString *customerToken = [customer valueForKey:@"Token"];
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            [prefs setObject:customerId forKey:@"customerId"];
            [prefs setObject:customerToken forKey:@"customerToken"];
            [prefs synchronize];
            
            //Add this customer to the DB
            [self performSelector:@selector(addToDatabase) withObject:nil afterDelay:1.5];
            
            responseInfo = @{@"status": @"1"};
        } else {
            // TODO:: need to pass the Arc Application error to the calling method
            NSString *message = [response valueForKey:@"Message"];
            //NSString *message = @"Internal Server Error";
            NSString *status = @"0";
            
            responseInfo = @{@"status": status,
            @"error": message};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.createCustomerResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            [prefs setObject:customerId forKey:@"customerId"];
            [prefs setObject:customerToken forKey:@"customerToken"];
            [prefs synchronize];
            
            //Add this customer to the DB
            [self performSelector:@selector(addToDatabase) withObject:nil afterDelay:1.5];
            
            responseInfo = @{@"status": @"1"};
        } else {
            // TODO:: need to pass the Arc Application error to the calling method
            NSString *message = [response valueForKey:@"Message"];
            //NSString *message = @"Internal Server Error";
            NSString *status = @"0";
            
            responseInfo = @{@"status": status,
            @"error": message};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getCustomerTokenResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};

    }
}

-(NSDictionary *) getMerchantListResponse:(NSDictionary *)response {
    @try {
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            responseInfo = @{@"status": @1,
            @"apiResponse": response};
        } else {
            // TODO:: need to pass the Arc Application error to the calling method
            NSString *message = [response valueForKey:@"Message"];
            NSNumber *status = @0;
            
            responseInfo = @{@"status": status,
            @"error": message};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getMerchantListResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};

    }
}

-(NSDictionary *) getInvoiceResponse:(NSDictionary *)response {
    @try {
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            responseInfo = @{@"status": @"1",
            @"apiResponse": response};
        } else {
            // TODO:: need to pass the Arc Application error to the calling method
            NSString *message = [response valueForKey:@"Message"];
            NSString *status = @"0";
            
            responseInfo = @{@"status": status,
            @"error": message};
        }
        return responseInfo;
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
        if (success){
            responseInfo = @{@"status": @"1",
            @"apiResponse": response};
        } else {
            // TODO:: need to pass the Arc Application error to the calling method
            NSString *message = [response valueForKey:@"Message"];
            NSString *status = @"0";
            
            responseInfo = @{@"status": status,
            @"error": message};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.createPaymentResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};

    }
}

-(NSDictionary *) createReviewResponse:(NSDictionary *)response {
    @try {
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            responseInfo = @{@"status": @"1",
            @"apiResponse": response};
        } else {
            // TODO:: need to pass the Arc Application error to the calling method
            NSString *message = [response valueForKey:@"Message"];
            NSString *status = @"0";
            
            responseInfo = @{@"status": status,
            @"error": message};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.createReviewResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};

    }
    
}

-(NSDictionary *) getPointBalanceResponse:(NSDictionary *)response {
    
    @try {
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            responseInfo = @{@"status": @"1",
            @"apiResponse": response};
        } else {
            // TODO:: need to pass the Arc Application error to the calling method
            NSString *message = [response valueForKey:@"Message"];
            NSString *status = @"0";
            
            responseInfo = @{@"status": status,
            @"error": message};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getPointBalanceResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return @{};
    }
    
 
}

-(NSDictionary *) trackEventResponse:(NSDictionary *)response {
    @try {
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            responseInfo = @{@"status": @"1",
            @"apiResponse": response};
        } else {
            // TODO:: need to pass the Arc Application error to the calling method
            NSString *message = [response valueForKey:@"Message"];
            NSString *status = @"0";
            
            responseInfo = @{@"status": status,
            @"error": message};
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
        
        if ([self customerToken]) {
            NSString *stringToEncode = [@"customer:" stringByAppendingString:[self customerToken]];
            NSString *authentication = [self encodeBase64:stringToEncode];
            
            return [@"Basic " stringByAppendingString:[self customerToken]];
            return authentication;
        }else{
            return @"";
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
            
            NSString *serverName = [response valueForKey:@"Results"];
            
            if (serverName && ([serverName length] > 0)) {
                [[NSUserDefaults standardUserDefaults] setValue:serverName forKey:@"arcUrl"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.setUrl" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

+(void)trackEvent:(NSString *)action{
    @try{
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
		NSDictionary *trackEventDict = [[NSDictionary alloc] init];
        
        [ tempDictionary setObject:action forKey:@"Activity"]; //ACTION
        [ tempDictionary setObject:@"Analytics" forKey:@"ActivityType"]; //CATEGORY

        ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *customerId = [mainDelegate getCustomerId];
        [ tempDictionary setObject:customerId forKey:@"EntityId"]; //get from auth header?
        [ tempDictionary setObject:@"Customer" forKey:@"EntityType"]; //get from auth header?
        
        [ tempDictionary setObject:@0.0 forKey:@"Latitude"];//optional
        [ tempDictionary setObject:@0.0 forKey:@"Longitude"];//optional
        [ tempDictionary setObject:@"count" forKey:@"MeasureType"];//LABEL
        [ tempDictionary setObject:@1.0 forKey:@"MeasureValue"];//VALUE
        [ tempDictionary setObject:@"Arc Mobile" forKey:@"Application"];
        [ tempDictionary setObject:@"AT&T" forKey:@"Carrier"]; //TODO add real carrier
        //[ tempDictionary setObject:@"Profile page viewed" forKey:@"Description"]; //Jim removed description
        [ tempDictionary setObject:@"iOS" forKey:@"Source"];
        [ tempDictionary setObject:@"phone" forKey:@"SourceType"];//remove
        [ tempDictionary setObject:@"0.1" forKey:@"Version"];
        
		trackEventDict = tempDictionary;

        ArcClient *client = [[ArcClient alloc] init];
        [client trackEvent:trackEventDict];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.trackEvent" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

@end
