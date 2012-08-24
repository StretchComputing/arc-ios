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

static NSString *_arcUrl = @"http://arc-stage.dagher.mobi/rest/v1/";           // CLOUD
//static NSString *_arcUrl = @"http://dtnetwork.dyndns.org:8700/arc-dev/rest/v1/";  // Server at Jim's Place

@implementation ArcClient

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
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getPointBalance" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    @try {
        
        NSData *returnData = [NSData dataWithData:self.serverData];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        //NSLog(@"ReturnString: %@", returnString);
        
        SBJsonParser *jsonParser = [SBJsonParser new];
        NSDictionary *response = (NSDictionary *) [jsonParser objectWithString:returnString error:NULL];
        
        NSDictionary *responseInfo;
        NSString *notificationType;
        if(api == CreateCustomer) {
            responseInfo = [self createCustomerResponse:response];
            notificationType = @"registerNotification";
        } else if(api == GetCustomerToken) {
            responseInfo = [self getCustomerTokenResponse:response];
            notificationType = @"signInNotification";
        } else if(api == GetMerchantList) {
            responseInfo = [self getMerchantListResponse:response];
            notificationType = @"merchantListNotification";
        } else if(api == GetInvoice) {
            responseInfo = [self getInvoiceResponse:response];
            notificationType = @"invoiceNotification";
        } else if(api == CreatePayment) {
            responseInfo = [self createPaymentResponse:response];
            notificationType = @"createPaymentNotification";
        } else if(api == CreateReview) {
            responseInfo = [self createReviewResponse:response];
            notificationType = @"createReviewNotification";
        } else if(api == GetPointBalance) {
            responseInfo = [self getPointBalanceResponse:response];
            notificationType = @"getPointBalanceNotification";
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationType object:self userInfo:responseInfo];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.connectionDidFinishLoading" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    @try {
        
        NSLog(@"Error: %@", error);
        
        NSDictionary *responseInfo = @{@"status": @"fail",
        @"error": error};
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
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationType object:self userInfo:responseInfo];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.connection" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
    
}

-(NSDictionary *) createCustomerResponse:(NSDictionary *)response {
    @try {
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            NSDictionary *customer = [response valueForKey:@"Customer"];
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
    }
}

-(NSDictionary *) getCustomerTokenResponse:(NSDictionary *)response {
    @try {
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            NSDictionary *customer = [response valueForKey:@"Customer"];
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
    }
}

-(NSDictionary *) getMerchantListResponse:(NSDictionary *)response {
    @try {
        
        BOOL success = [[response valueForKey:@"Success"] boolValue];
        
        NSDictionary *responseInfo;
        if (success){
            responseInfo = @{@"status": @"1",
            @"apiResponse": response};
        } else {
            NSString *message = [response valueForKey:@"Message"];
            NSString *status = @"0";
            
            responseInfo = @{@"status": status,
            @"error": message};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getMerchantListResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
            NSString *message = [response valueForKey:@"Message"];
            NSString *status = @"0";
            
            responseInfo = @{@"status": status,
            @"error": message};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getInvoiceResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
            NSString *message = [response valueForKey:@"Message"];
            NSString *status = @"0";
            
            responseInfo = @{@"status": status,
            @"error": message};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.createPaymentResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
            NSString *message = [response valueForKey:@"Message"];
            NSString *status = @"0";
            
            responseInfo = @{@"status": status,
            @"error": message};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.createReviewResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
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
            NSString *message = [response valueForKey:@"Message"];
            NSString *status = @"0";
            
            responseInfo = @{@"status": status,
            @"error": message};
        }
        return responseInfo;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcClient.getPointBalanceResponse" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


-(NSString *) authHeader {
    @try {
        
        NSString *stringToEncode = [@"customer:" stringByAppendingString:[self customerToken]];
        NSString *authentication = [self encodeBase64:stringToEncode];
        return authentication;
    }
    @catch (NSException *e) {
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
    }
}



@end
