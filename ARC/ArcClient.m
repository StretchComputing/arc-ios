//
//  ArcClient.m
//  ARC
//
//  Created by Joseph Wroblewski on 8/5/12.
//
//

#import "ArcClient.h"
#import "NewJSON.h"
#import "ArcAppDelegate.h"

static NSString *_arcUrl = @"http://arc-stage.dagher.mobi/rest/v1/";
//static NSString *_arcUrl = @"http://dtnetwork.dyndns.org:8700/arc-dev/rest/v1/";

@implementation ArcClient
@synthesize serverData;

-(void)createCustomer:(NSDictionary *)pairs{
    @try {
        api = CreateCustomer;
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [pairs JSONFragment], nil];
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        NSString *createUrl = [NSString stringWithFormat:@"%@customers", _arcUrl, nil];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:createUrl]];
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.serverData = [NSMutableData data];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *exception) {
        // TODO add in rSkybox call
    }
}

-(void)getCustomerToken:(NSDictionary *)pairs{
    @try {
        api = GetCustomerToken;
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [pairs JSONFragment], nil];
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
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
    @catch (NSException *exception) {
        // TODO add in rSkybox call
    }
}

-(void)getMerchantList:(NSDictionary *)pairs{
    @try {
        api = GetMerchantList;
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [pairs JSONFragment], nil];
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        
        NSString *getMerchantListUrl = [NSString stringWithFormat:@"%@merchants", _arcUrl, nil];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:getMerchantListUrl]];
        [request setHTTPMethod: @"GET"];
        //[request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        
        self.serverData = [NSMutableData data];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *exception) {
        // TODO add in rSkybox call
    }
}

-(void)getInvoice:(NSDictionary *)pairs{
    @try {
        api = GetInvoice;
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [pairs JSONFragment], nil];
        NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
        NSString * invoiceNumber = [pairs valueForKey:@"invoiceNumber"];
        
        NSString *getInvoiceUrl = [NSString stringWithFormat:@"%@Invoices/%@", _arcUrl, invoiceNumber];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:getInvoiceUrl]];
        [request setHTTPMethod: @"GET"];
        //[request setHTTPBody: requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self authHeader] forHTTPHeaderField:@"Authorization"];
        
        self.serverData = [NSMutableData data];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately: YES];
    }
    @catch (NSException *exception) {
        // TODO add in rSkybox call
    }
}

-(void)createPayment:(NSDictionary *)pairs{
    @try {
        api = CreatePayment;
        
        NSString *requestString = [NSString stringWithFormat:@"%@", [pairs JSONFragment], nil];
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
    @catch (NSException *exception) {
        // TODO add in rSkybox call
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)mdata {
    [self.serverData appendData:mdata];
}

// ::NICK ok that this one method handles all cases?  I don't think there should be any threading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSData *returnData = [NSData dataWithData:self.serverData];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"ReturnString: %@", returnString);
    
    NewSBJSON *jsonParser = [NewSBJSON new];
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
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationType object:self userInfo:responseInfo];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"Error: %@", error);
    
    NSDictionary *responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"fail", @"status",
                              error, @"error",
                              nil];
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
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationType object:self userInfo:responseInfo];
}

-(NSDictionary *) createCustomerResponse:(NSDictionary *)response {
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
        
        // NICK:: called addToDatabase instead like for getTokenResponse() below -- is this a better way to do it?
        //ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
        //[mainDelegate insertCustomerWithId:customerId andToken:customerToken];
        //Add this customer to the DB
        [self performSelector:@selector(addToDatabase) withObject:nil afterDelay:1.5];
        
        responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"1", @"status",
                    nil];
    } else {
        NSString *message = [response valueForKey:@"Message"];
        //NSString *message = @"Internal Server Error";
        NSString *status = @"0";
        
        responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    status, @"status",
                    message, @"error",
                    nil];
    }
    return responseInfo;
}

-(NSDictionary *) getCustomerTokenResponse:(NSDictionary *)response {
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
         
         responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                     @"1", @"status",
                     nil];
     } else {
         NSString *message = [response valueForKey:@"Message"];
         //NSString *message = @"Internal Server Error";
         NSString *status = @"0";
         
         responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                     status, @"status",
                     message, @"error",
                     nil];
     }
    return responseInfo;
}

-(NSDictionary *) getMerchantListResponse:(NSDictionary *)response {
    BOOL success = [[response valueForKey:@"Success"] boolValue];
    
    NSDictionary *responseInfo;
    if (success){
        responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"1", @"status",
                    response, @"apiResponse",
                    nil];
    } else {
        NSString *message = [response valueForKey:@"Message"];
        NSString *status = @"0";
        
        responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    status, @"status",
                    message, @"error",
                    nil];
    }
    return responseInfo;
}

-(NSDictionary *) getInvoiceResponse:(NSDictionary *)response {
    BOOL success = [[response valueForKey:@"Success"] boolValue];
    
    NSDictionary *responseInfo;
    if (success){
        responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"1", @"status",
                        response, @"apiResponse",
                        nil];
    } else {
        NSString *message = [response valueForKey:@"Message"];
        NSString *status = @"0";
        
        responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        status, @"status",
                        message, @"error",
                        nil];
    }
    return responseInfo;
}

-(NSDictionary *) createPaymentResponse:(NSDictionary *)response {
    BOOL success = [[response valueForKey:@"Success"] boolValue];
    
    NSDictionary *responseInfo;
    if (success){
        responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"1", @"status",
                        response, @"apiResponse",
                        nil];
    } else {
        NSString *message = [response valueForKey:@"Message"];
        NSString *status = @"0";
        
        responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        status, @"status",
                        message, @"error",
                        nil];
    }
    return responseInfo;
}


-(NSString *) authHeader {
    NSString *stringToEncode = [@"customer:" stringByAppendingString:[self customerToken]];
    NSString *authentication = [self encodeBase64:stringToEncode];
    return authentication;
}

-(void) addToDatabase {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *customerId = [prefs valueForKey:@"customerId"];
    NSString *customerToken = [prefs valueForKey:@"customerToken"];
    
    ArcAppDelegate *mainDelegate = (ArcAppDelegate *)[[UIApplication sharedApplication] delegate];
    [mainDelegate insertCustomerWithId:customerId andToken:customerToken];
}

-(NSString *) customerToken {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *customerToken = [prefs valueForKey:@"customerToken"];
    return customerToken;
}

-(NSString *)encodeBase64:(NSString *)stringToEncode{	
	NSData *encodeData = [stringToEncode dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray, '\0', sizeof(encodeArray));
	
	// Base64 Encode username and password
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);
	NSString *dataStr = [NSString stringWithCString:encodeArray length:strlen(encodeArray)];
	NSString *encodedString =[@"" stringByAppendingFormat:@"Basic %@", dataStr];
	
	return encodedString;
}



@end
