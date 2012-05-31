//
//  ServerAPI.m
//  ArcMobile
//
//  Created by Nick Wroblewski on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerAPI.h"
#import "JSON.h"
#import "Encoder.h"
#import "rSkybox.h"

@implementation ServerAPI



+(NSDictionary *)getInvoiceFromNumber:(NSString *)invoiceNumber andRestaurantId:(NSString *)restaurantId{
    
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionary];
    NSString *statusReturn = @"";
    
    if ((invoiceNumber == nil) || (restaurantId == nil)) {
        statusReturn = @"0";
        [returnDictionary setValue:statusReturn forKey:@"status"];
        return returnDictionary;
    }
    
    @try{
        
    
        NSString *tmpUrl = [NSString stringWithFormat:@"http://68.57.205.193:8700/rest/v1/invoices/%@", invoiceNumber];
        
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:tmpUrl]];
        //[request setValue:authentication forHTTPHeaderField:@"Authorization"];
        [request setHTTPMethod: @"GET"];
        
        NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil ];
        
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        NSLog(@"Response: %@", returnString);
        
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *response = (NSDictionary *) [jsonParser objectWithString:returnString error:NULL];
        
        NSString *apiStatus = [response valueForKey:@"apiStatus"];
        
        if ([apiStatus isEqualToString:@"100"]) {
            
        }
        
        statusReturn = apiStatus;
        
        [returnDictionary setValue:statusReturn forKey:@"status"];
        [returnDictionary setValue:response forKey:@"values"];
        
        return returnDictionary;
        
    }
    @catch (NSException *e) {
        
        [rSkybox sendClientLog:@"getInvoiceFromNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        return returnDictionary;
        
    }

    
    
    
}


+(NSDictionary *)updateInvoiceWithId:(NSString *)invoiceId andRestaurantId:(NSString *)restaurantId gratuity:(NSString *)gratuity paymentMethod:(NSString *)paymentMethod percentage:(NSString *)percentage invoiceStatus:(NSString *)invoiceStatus userToken:(NSString *)userToken{
    
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionary];
    NSString *statusReturn = @"";
    
    if ((invoiceId == nil) || (restaurantId == nil)) {
        statusReturn = @"0";
        [returnDictionary setValue:statusReturn forKey:@"status"];
        return returnDictionary;
    }
    
    @try{
        
        
        
        NSString *tmpUrl = [NSString stringWithFormat:@"http://68.57.205.193:8700/rest/v1/invoices/%@", invoiceId];
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
		NSDictionary *loginDict = [[NSDictionary alloc] init];
        
		
		NSString *stringToEncode = [@"login:" stringByAppendingString:userToken];
		
		NSString *authentication = [ServerAPI encodeBase64:stringToEncode];
        
				
        if (![gratuity isEqualToString:@""]) {
            [ tempDictionary setObject:gratuity forKey:@"gratuity"];
        }
        
        if (![paymentMethod isEqualToString:@""]) {
            [ tempDictionary setObject:paymentMethod forKey:@"paymentMethod"];
        }
        
        if (![percentage isEqualToString:@""]) {
            [ tempDictionary setObject:percentage forKey:@"percentage"];
        }
        
        if (![invoiceStatus isEqualToString:@""]) {
            [ tempDictionary setObject:invoiceStatus forKey:@"invoiceStatus"];
        }
       
		loginDict = tempDictionary;
        
        
		NSString *requestString = [NSString stringWithFormat:@"%@", [loginDict JSONFragment], nil];
    
        
		NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];

        
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:tmpUrl]];
        [request setValue:authentication forHTTPHeaderField:@"Authorization"];
        [request setHTTPMethod: @"PUT"];
        [request setHTTPBody:requestData];
        
        NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil ];
        
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *response = (NSDictionary *) [jsonParser objectWithString:returnString error:NULL];
        
        NSString *apiStatus = [response valueForKey:@"apiStatus"];
        
        if ([apiStatus isEqualToString:@"100"]) {
            
        }
        
        statusReturn = apiStatus;
        
        [returnDictionary setValue:statusReturn forKey:@"status"];
        [returnDictionary setValue:response forKey:@"values"];
        
        return returnDictionary;
        
    }
    @catch (NSException *e) {
        
        //return [ServerAPI exceptionReturnValue:@"getUserInfo" :e];
        return returnDictionary;
        
    }
    
    
}


+ (NSString *)encodeBase64:(NSString *)stringToEncode{
	
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
        
        
        //[GoogleAppEngine sendClientLog:@"encodeBase64 - String" logMessage:[e reason] logLevel:@"exception" exception:e];
        
        
        return @"";
    }
    
}

+ (NSString *)encodeBase64data:(NSData *)encodeData{
	
    @try {
        //NSData *encodeData = [stringToEncode dataUsingEncoding:NSUTF8StringEncoding]
        char encodeArray[500000];
        
        memset(encodeArray, '\0', sizeof(encodeArray));
        
        // Base64 Encode username and password
        encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);
        NSString *dataStr = [NSString stringWithCString:encodeArray length:strlen(encodeArray)];
        
        // NSString *dataStr = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding];
        
        NSString *encodedString =[@"" stringByAppendingFormat:@"%@", dataStr];
        
        
        return encodedString;
    }
    @catch (NSException *e) {
        //[GoogleAppEngine sendClientLog:@"encodeBase64 - Data" logMessage:[e reason] logLevel:@"exception" exception:e];
        
        
        return @"";
    }
    
    
}


@end
