//
//  DwollaAPI.m
//  DwollaSDK
//
//  Created by Nick Schulze on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DwollaAPI.h"
static NSString *const dwollaAPIBaseURL = @"https://www.dwolla.com/oauth/rest";

@implementation DwollaAPI

+(BOOL)hasToken
{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    
    if(token == nil)
    {
        return NO;
    }
    else 
    {
        return YES;
    }
}

+(NSString*)getAccessToken
{
    if (![DwollaAPI hasToken]) 
    {
        @throw [NSException exceptionWithName:@"INVALID_TOKEN_EXCEPTION" 
                                       reason:@"oauth_token is invalid" userInfo:nil];
    }
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    return token;
}

+(void)setAccessToken:(NSString*) token
{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)clearAccessToken
{
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"token"];
}

+(NSString*)sendMoneyWithPIN:(NSString*)pin 
               destinationID:(NSString*)destinationID 
             destinationType:(NSString*)type
                      amount:(NSString*)amount
           facilitatorAmount:(NSString*)facAmount
                 assumeCosts:(NSString*)assumeCosts
                       notes:(NSString*)notes
             fundingSourceID:(NSString*)fundingID
{
    if (![DwollaAPI hasToken]) 
    {
        @throw [NSException exceptionWithName:@"INVALID_TOKEN_EXCEPTION" 
                                       reason:@"oauth_token is invalid" userInfo:nil]; 
    }
    NSString* token = [DwollaAPI getAccessToken];
    
    NSString* url = [dwollaAPIBaseURL stringByAppendingFormat:@"/transactions/send?oauth_token=%@", token]; 
    
    if(pin == nil || [pin isEqualToString:@""])
    {
        @throw [NSException exceptionWithName:@"INVALID_PARAMETER_EXCEPTION" 
                                       reason:@"pin is either nil or empty" userInfo:nil];
    }
    if (destinationID == nil || [destinationID isEqualToString:@""]) 
    {
        @throw [NSException exceptionWithName:@"INVALID_PARAMETER_EXCEPTION" 
                                       reason:@"destinationID is either nil or empty" userInfo:nil];   
    }
    if (amount == nil || [amount isEqualToString:@""])
    {
        @throw [NSException exceptionWithName:@"INVALID_PARAMETER_EXCEPTION" 
                                       reason:@"amount is either nil or empty" userInfo:nil];    
    }
    NSString* json = [NSString stringWithFormat:@"{\"pin\":\"%@\", \"destinationId\":\"%@\", \"amount\":%@", pin, destinationID, amount];
    if (type != nil && ![type isEqualToString:@""]) 
    {
        json = [json stringByAppendingFormat: @", \"destinationType\":\"%@\"", type];
    }
    if (facAmount != nil && ![facAmount isEqualToString:@""]) 
    {
        json = [json stringByAppendingFormat: @", \"facilitatorAmount\":\"%@\"", facAmount];
    }
    if (assumeCosts != nil && ![assumeCosts isEqualToString:@""])
    {
        json = [json stringByAppendingFormat: @", \"assumeCosts\":\"%@\"", assumeCosts];
    }
    if (notes != nil && ![notes isEqualToString:@""]) 
    {
        json = [json stringByAppendingFormat: @", \"notes\":\"%@\"", notes];
    }
    if (fundingID != nil && ![fundingID isEqualToString:@""])
    {
        json = [json stringByAppendingFormat: @", \"fundsSource\":\"%@\"", fundingID];
    }
    json = [json stringByAppendingFormat: @"}", type];
    
    NSData* body = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPMethod: @"POST"];
    
    [request setHTTPBody:body];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSDictionary* dictionary = [DwollaAPI generateDictionaryWithData:result];
    NSLog(@"%@", dictionary);
    
    NSString* data = [[NSString alloc] initWithFormat:@"%@",[dictionary valueForKey:@"Response"]];
    
    NSString* success = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Success"]];
    
    if ([success isEqualToString:@"0"]) 
    {
        @throw [NSException exceptionWithName:@"REQUEST_FAILED_EXCEPTION" reason:data userInfo:nil];
    }
    
    return data;  
}

+(NSString*)requestMoneyWithPIN:(NSString*)pin 
                 sourceID:(NSString*)sourceID 
               sourceType:(NSString*)type
                   amount:(NSString*)amount
        facilitatorAmount:(NSString*)facAmount
                    notes:(NSString*)notes
{
    if (![DwollaAPI hasToken]) 
    {
        @throw [NSException exceptionWithName:@"INVALID_TOKEN_EXCEPTION" 
                                       reason:@"oauth_token is invalid" userInfo:nil];
    }
    
    NSString* token = [DwollaAPI getAccessToken];
    
    NSString* url = [dwollaAPIBaseURL stringByAppendingFormat:@"/transactions/request?oauth_token=%@", token]; 
    
    if(pin == nil || [pin isEqualToString:@""])
    {
        @throw [NSException exceptionWithName:@"INVALID_PARAMETER_EXCEPTION" 
                                       reason:@"pin is either nil or empty" userInfo:nil];  
    }
    if (sourceID == nil || [sourceID isEqualToString:@""]) 
    {
        @throw [NSException exceptionWithName:@"INVALID_PARAMETER_EXCEPTION" 
                                       reason:@"sourceID is either nil or empty" userInfo:nil];
    }
    if (amount == nil || [amount isEqualToString:@""])
    {
        @throw [NSException exceptionWithName:@"INVALID_PARAMETER_EXCEPTION" 
                                       reason:@"amount is either nil or empty" userInfo:nil];
    }
    NSString* json = [NSString stringWithFormat:@"{\"pin\":\"%@\", \"sourceId\":\"%@\", \"amount\":%@", pin, sourceID, amount];
    
    if (type != nil && ![type isEqualToString:@""]) 
    {
        json = [json stringByAppendingFormat: @", \"destinationType\":\"%@\"", type];
    }
    if (facAmount != nil && ![facAmount isEqualToString:@""]) 
    {
        json = [json stringByAppendingFormat: @", \"facilitatorAmount\":\"%@\"", facAmount];
    }
    if (notes != nil && ![notes isEqualToString:@""]) 
    {
        json = [json stringByAppendingFormat: @", \"notes\":\"%@\"", notes];
    }
    json = [json stringByAppendingFormat: @"}", type];
    
    NSData* body = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPMethod: @"POST"];
    
    [request setHTTPBody:body];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSDictionary* dictionary = [DwollaAPI generateDictionaryWithData:result];
    NSLog(@"%@", dictionary);
    
    NSString* data = [[NSString alloc] initWithFormat:@"%@",[dictionary valueForKey:@"Response"]];
    
    NSString* success = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Success"]];
    
    if ([success isEqualToString:@"0"]) 
    {
        @throw [NSException exceptionWithName:@"REQUEST_FAILED_EXCEPTION" reason:data userInfo:nil];
    }
    
    return data;  
}

+(NSDictionary*)getJSONBalance
{
    if (![DwollaAPI hasToken]) 
    {
        @throw [NSException exceptionWithName:@"INVALID_TOKEN_EXCEPTION" 
                                       reason:@"oauth_token is invalid" userInfo:nil];
    }
    
    NSMutableURLRequest* request = [DwollaAPI generateRequestWithString:@"/balance?oauth_token="];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
        
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSDictionary* dictionary = [DwollaAPI generateDictionaryWithData:result];
    
    return dictionary;
}

+(NSString*)getBalance
{

    NSDictionary* dictionary = [DwollaAPI getJSONBalance];
    NSString* data = [[NSString alloc]initWithFormat:@"%@", [dictionary objectForKey:@"Response"]];
    NSString* success = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Success"]];
    
    if ([success isEqualToString:@"0"]) 
    {
        @throw [NSException exceptionWithName:@"REQUEST_FAILED_EXCEPTION" reason:data userInfo:nil];
    }
    else
    {        
        return data;
    }
}

+(NSDictionary*)getJSONContactsByName:(NSString*)name 
                                types:(NSString*)types
                                limit:(NSString*)limit
{
    if (![DwollaAPI hasToken]) 
    {
        @throw [NSException exceptionWithName:@"INVALID_TOKEN_EXCEPTION" 
                                       reason:@"oauth_token is invalid" userInfo:nil];
    }
    NSString* url = @"/contacts?";
    
    if (name != nil && ![name isEqualToString:@""]) 
    {
        url = [url stringByAppendingFormat: @"search=%@&", name];
    }
    if (types != nil && ![types isEqualToString:@""]) 
    {
        url = [url stringByAppendingFormat: @"types=%@&", types];
    }
    if (limit != nil && ![limit isEqualToString:@""])
    {
        url = [url stringByAppendingFormat: @"limit=%@&", limit];
    }

    url = [url stringByAppendingString:@"oauth_token="];
    NSMutableURLRequest* request = [DwollaAPI generateRequestWithString:url];

    [request setHTTPMethod: @"GET"];

    NSError *requestError;
    NSURLResponse *urlResponse = nil;

    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];

    NSDictionary* dictionary = [DwollaAPI generateDictionaryWithData:result];

    return dictionary;
}

+(DwollaContacts*)getContactsByName:(NSString*)name 
                              types:(NSString*)types
                              limit:(NSString*)limit
{
    NSDictionary* dictionary = [DwollaAPI getJSONContactsByName:name types:types limit:limit];
    NSArray* data =[dictionary valueForKey:@"Response"];
    
    NSString* success = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Success"]];
    
    if ([success isEqualToString:@"0"]) 
    {
        NSString* message = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Message"]];
        @throw [NSException exceptionWithName:@"REQUEST_FAILED_EXCEPTION" reason:message userInfo:dictionary];
    }
    
    NSMutableArray* contacts = [[NSMutableArray alloc] initWithCapacity:[data count]];
    for (int i = 0; i < [data count]; i++)
    {
        NSString* info = [[NSString alloc] initWithFormat:@"%@", [data objectAtIndex:i]];
        [contacts addObject:[DwollaAPI generateContactWithString:info]];
    }
    return [[DwollaContacts alloc] initWithSuccess:YES contacts:contacts];
}

+(NSDictionary*)getJSONNearbyWithLatitude:(NSString*)lat 
                                Longitude:(NSString*)lon
                                    Limit:(NSString*)limit
                                    Range:(NSString*)range
{
    NSString* key = [[NSUserDefaults standardUserDefaults] objectForKey:@"key"];
    NSString* secret = [[NSUserDefaults standardUserDefaults] objectForKey:@"secret"];
    
    if (key == nil || secret == nil) 
    {
        @throw [NSException exceptionWithName:@"INVALID_APPLICATION_CREDENTIALS_EXCEPTION" 
                                       reason:@"either your application key or application secret is invalid" 
                                     userInfo:nil];
    }
    
    NSString* url = [dwollaAPIBaseURL stringByAppendingFormat:@"/contacts/nearby?client_id=%@&client_secret=%@", key, secret]; 
    
    if(lat == nil || [lat isEqualToString:@""] || lon == nil || [lon isEqualToString:@""])
    {
        @throw [NSException exceptionWithName:@"INVALID_PARAMETER_EXCEPTION" 
                                       reason:@"latitude or longitude is either nil or empty" userInfo:nil];
    }
    url = [url stringByAppendingFormat:@"&latitude=%@&longitude=%@", lat, lon];
    
    if (range != nil && ![range isEqualToString:@""]) 
    {
        url = [url stringByAppendingFormat:@"&range=%@", range];
    }
    if (limit != nil && ![limit isEqualToString:@""]) 
    {
        url = [url stringByAppendingFormat:@"&limit=%@", limit];
    }
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSDictionary* dictionary = [DwollaAPI generateDictionaryWithData:result];
    
    return dictionary;
}

+(DwollaContacts*)getNearbyWithLatitude:(NSString*)lat 
                            Longitude:(NSString*)lon
                                Limit:(NSString*)limit
                                Range:(NSString*)range
{
    NSDictionary* dictionary = [DwollaAPI getJSONNearbyWithLatitude:lat Longitude:lon Limit:limit Range:range];
    NSArray* data =[dictionary valueForKey:@"Response"];
    
    NSString* success = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Success"]];
    
    if ([success isEqualToString:@"0"]) 
    {
        NSString* message = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Message"]];
        @throw [NSException exceptionWithName:@"REQUEST_FAILED_EXCEPTION" reason:message userInfo:dictionary];
    }
    
    NSMutableArray* contacts = [[NSMutableArray alloc] initWithCapacity:[data count]];
    for (int i = 0; i < [data count]; i++)
    {
        NSString* info = [[NSString alloc] initWithFormat:@"%@", [data objectAtIndex:i]];
        [contacts addObject:[DwollaAPI generateContactWithString:info]];
    }
    return [[DwollaContacts alloc] initWithSuccess:YES contacts:contacts];
}

+(NSDictionary*)getJSONFundingSources
{
    if (![DwollaAPI hasToken]) 
    {
        @throw [NSException exceptionWithName:@"INVALID_TOKEN_EXCEPTION" 
                                       reason:@"oauth_token is invalid" userInfo:nil];
    }
    
    NSMutableURLRequest* request = [DwollaAPI generateRequestWithString:@"/fundingsources?oauth_token="];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSDictionary* dictionary = [DwollaAPI generateDictionaryWithData:result];
    
    return dictionary;
}

+(DwollaFundingSources*)getFundingSources
{
    NSDictionary* dictionary = [DwollaAPI getJSONFundingSources];
    NSArray* data =[dictionary valueForKey:@"Response"];
    
    NSString* success = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Success"]];
    
    if ([success isEqualToString:@"0"]) 
    {
        NSString* message = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Message"]];
        @throw [NSException exceptionWithName:@"REQUEST_FAILED_EXCEPTION" reason:message userInfo:dictionary];
    }
    
    NSMutableArray* sources = [[NSMutableArray alloc] initWithCapacity:[data count]];
    for (int i = 0; i < [data count]; i++)
    {
        NSString* info = [[NSString alloc] initWithFormat:@"%@", [data objectAtIndex:i]];
        [sources addObject:[DwollaAPI generateSourceWithString:info]];
    }
    
    return [[DwollaFundingSources alloc] initWithSuccess:YES sources:sources];
}

+(NSDictionary*)getJSONFundingSource:(NSString*)sourceID
{
    if (![DwollaAPI hasToken]) 
    {
        @throw [NSException exceptionWithName:@"INVALID_TOKEN_EXCEPTION" 
                                       reason:@"oauth_token is invalid" userInfo:nil];
    }
    
    if ([sourceID isEqualToString:@""] || sourceID == nil) 
    {
        @throw [NSException exceptionWithName:@"INVALID_PARAMETER_EXCEPTION" 
                                       reason:@"sourceID is either nil or empty" userInfo:nil];  
    }
    
    NSString* encodedID = [DwollaAPI encodedURLParameterString:sourceID];    
    NSString* parameters = [@"/fundingsources?fundingid=" stringByAppendingString:[NSString stringWithFormat:@"%@",encodedID]];
    NSMutableURLRequest* request = [DwollaAPI generateRequestWithString:[parameters stringByAppendingString: @"&oauth_token="]];
    
    [request setHTTPMethod: @"GET"];

    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSDictionary* dictionary = [DwollaAPI generateDictionaryWithData:result];
    
    return dictionary;   
}

+(DwollaFundingSource*)getFundingSource:(NSString*)sourceID
{
    NSDictionary* dictionary = [DwollaAPI getJSONFundingSource:sourceID];
    NSArray* data =[dictionary valueForKey:@"Response"];
    
    NSString* success = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Success"]];
    
    if ([success isEqualToString:@"0"]) 
    {
        NSString* message = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Message"]];
        @throw [NSException exceptionWithName:@"REQUEST_FAILED_EXCEPTION" reason:message userInfo:dictionary];
    }
    
    NSString* info = [[NSString alloc] initWithFormat:@"%@", [data objectAtIndex:0]];
    return [DwollaAPI generateSourceWithString:info];
}

+(NSDictionary*)getJSONAccountInfo
{
    if (![DwollaAPI hasToken]) 
    {
        @throw [NSException exceptionWithName:@"INVALID_TOKEN_EXCEPTION" 
                                       reason:@"oauth_token is invalid" userInfo:nil];
    }
    
    NSMutableURLRequest* request = [DwollaAPI generateRequestWithString:@"/users?oauth_token="];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSDictionary* dictionary = [DwollaAPI generateDictionaryWithData:result];
    
    return dictionary;
}

+(DwollaUser*)getAccountInfo
{
    NSDictionary* dictionary = [DwollaAPI getJSONAccountInfo];
    NSString* data = [[NSString alloc] initWithFormat:@"%@",[dictionary valueForKey:@"Response"]];
    
    NSString* success = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Success"]];
    
    if ([success isEqualToString:@"0"]) 
    {
        NSString* message = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Message"]];
        @throw [NSException exceptionWithName:@"REQUEST_FAILED_EXCEPTION" reason:message userInfo:dictionary];
    }
    
    NSArray* values = [data componentsSeparatedByString:@"\n"];
    NSString* city = [DwollaAPI findValue:[values objectAtIndex:1]];
    NSString* userID = [DwollaAPI findValue:[values objectAtIndex:2]];
    NSString* latitude = [DwollaAPI findValue:[values objectAtIndex:3]];
    NSString* longitude = [DwollaAPI findValue:[values objectAtIndex:4]];
    NSString* name = [DwollaAPI findValue:[values objectAtIndex:5]];
    NSString* state = [DwollaAPI findValue:[values objectAtIndex:6]];
    NSString* type = [DwollaAPI findValue:[values objectAtIndex:7]];
    
    return [[DwollaUser alloc] initWithUserID:userID name:name city:city state:state 
                                     latitude:latitude longitude:longitude type:type];
}

+(NSDictionary*)getJSONBasicInfoWithAccountID:(NSString*)accountID
{    
    NSString* key = [[NSUserDefaults standardUserDefaults] objectForKey:@"key"];
    NSString* secret = [[NSUserDefaults standardUserDefaults] objectForKey:@"secret"];
    
    if (key == nil || secret == nil) 
    {
        @throw [NSException exceptionWithName:@"INVALID_APPLICATION_CREDENTIALS_EXCEPTION" 
                                       reason:@"either your application key or application secret is invalid" 
                                     userInfo:nil];   
    }
    if (accountID == nil || [accountID isEqualToString:@""])
    {
        @throw [NSException exceptionWithName:@"INVALID_PARAMETER_EXCEPTION" 
                                       reason:@"accountID is either nil or empty" userInfo:nil];
    }
    
    NSString* url = [dwollaAPIBaseURL stringByAppendingFormat:@"/users/%@?client_id=%@&client_secret=%@", accountID, key, secret]; 
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSDictionary* dictionary = [DwollaAPI generateDictionaryWithData:result];
    
    return dictionary;
}

+(DwollaUser*)getBasicInfoWithAccountID:(NSString*)accountID
{
    NSDictionary* dictionary = [DwollaAPI getJSONBasicInfoWithAccountID:accountID];
    NSString* data = [[NSString alloc] initWithFormat:@"%@",[dictionary valueForKey:@"Response"]];
    
    NSString* success = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Success"]];
    
    if ([success isEqualToString:@"0"]) 
    {
        NSString* message = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Message"]];
        @throw [NSException exceptionWithName:@"REQUEST_FAILED_EXCEPTION" reason:message userInfo:dictionary];
    }
    
    NSArray* values = [data componentsSeparatedByString:@"\n"];
    NSString* userID = [DwollaAPI findValue:[values objectAtIndex:1]];
    NSString* latitude = [DwollaAPI findValue:[values objectAtIndex:2]];
    NSString* longitude = [DwollaAPI findValue:[values objectAtIndex:3]];
    NSString* name = [DwollaAPI findValue:[values objectAtIndex:4]];
    
    return [[DwollaUser alloc] initWithUserID:userID name:name city:nil state:nil 
                                     latitude:latitude longitude:longitude type:nil];

}

+(DwollaUser*)registerUserWithEmail:(NSString*) email 
                           password:(NSString*)password 
                                pin:(NSString*)pin
                          firstName:(NSString*)first
                           lastName:(NSString*)last
                            address:(NSString*)address
                           address2:(NSString*)address2
                               city:(NSString*)city
                              state:(NSString*)state
                                zip:(NSString*)zip
                              phone:(NSString*)phone
                          birthDate:(NSString*)dob
                               type:(NSString*)type
                       organization:(NSString*)organization
                                ein:(NSString*)ein
                        acceptTerms:(BOOL)accept
{
    NSString* key = [[NSUserDefaults standardUserDefaults] objectForKey:@"key"];
    NSString* secret = [[NSUserDefaults standardUserDefaults] objectForKey:@"secret"];
    
    if (key == nil || secret == nil) 
    {
        @throw [NSException exceptionWithName:@"INVALID_APPLICATION_CREDENTIALS_EXCEPTION" 
                                       reason:@"either your application key or application secret is invalid" 
                                     userInfo:nil];
    }
    
    NSString* acceptTerms = @"false";
    
    NSString* url = [dwollaAPIBaseURL stringByAppendingFormat:@"/register/?client_id=%@&client_secret=%@", key, secret]; 
    
    if(email == nil || password == nil || pin == nil || first == nil || last == nil || address == nil || 
       city == nil || state == nil || zip == nil || phone == nil || dob == nil || [email isEqualToString:@""] || 
       [password isEqualToString:@""] || [pin isEqualToString:@""] || [first isEqualToString:@""] || 
       [last isEqualToString:@""] || [address isEqualToString:@""] || [city isEqualToString:@""] || 
       [state isEqualToString:@""] || [zip isEqualToString:@""] || [phone isEqualToString:@""] ||
       [dob isEqualToString:@""])
    {
        @throw [NSException exceptionWithName:@"INVALID_PARAMETER_EXCEPTION" 
                                       reason:@"either email, password, pin, first, last, address, city, state, zip, phone, or date of birth is nil or empty" userInfo:nil];
    }
    if(type != nil && ![type isEqualToString:@""] && ![type isEqualToString:@"Personal"] && 
       ![type isEqualToString:@"Commercial"] && ![type isEqualToString:@"NonProfit"]) 
    {
        @throw [NSException exceptionWithName:@"INVALID_PARAMETER_EXCEPTION" 
                                       reason:@"type must be either personal, commercial, or nonprofit" userInfo:nil];
    }
    if(([type isEqualToString:@"Commercial"] || [type isEqualToString:@"NonProfit"]) && 
                                                (organization == nil || [organization isEqualToString:@""] || 
                                                      ein == nil || [ein isEqualToString:@""])) 
    {
        @throw [NSException exceptionWithName:@"INVALID_PARAMETER_EXCEPTION" 
                                       reason:@"if account type is commercial or nonprofit then user must input an organization name as well as an ein" userInfo:nil];
    }
    if (!accept) 
    {
        @throw [NSException exceptionWithName:@"INVALID_TERM_ACCEPTANCE_EXCEPTION" 
                                       reason:@"user must accept the terms, acceptTerms is false or empty" userInfo:nil];
    }
    else 
    {
        acceptTerms = @"true";
    }
 
    NSString* json = [NSString stringWithFormat:@"{\"email\":\"%@\", \"password\":\"%@\", \"pin\":\"%@\", \"firstName\":\"%@\", \"lastName\":\"%@\", \"address\":\"%@\", \"city\":\"%@\", \"state\":\"%@\", \"zip\":\"%@\", \"phone\":\"%@\", \"dateOfBirth\":\"%@\", \"acceptTerms\":\"%@\"", email, password, pin, first, last, address, city, state, zip, phone, dob, acceptTerms, key, secret];
    if (type != nil  && ![type isEqualToString:@""]) 
    {
        json = [json stringByAppendingFormat: @", \"destinationType\":\"%@\"", type];
    }
    if (address2 != nil  && ![address2 isEqualToString:@""]) 
    {
        json = [json stringByAppendingFormat: @", \"address2\":\"%@\"", address2];
    }
    if (organization != nil  && ![organization isEqualToString:@""])
    {
        json = [json stringByAppendingFormat: @", \"organization\":\"%@\"", organization];
    }
    if (ein != nil  && ![ein isEqualToString:@""]) 
    {
        json = [json stringByAppendingFormat: @", \"ein\":\"%@\"", ein];
    } 
    json = [json stringByAppendingFormat: @"}", type];
    
    NSData* body = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",json);

    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPMethod: @"POST"];
    
    [request setHTTPBody:body];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSDictionary* dictionary = [DwollaAPI generateDictionaryWithData:result];
    NSLog(@"%@", dictionary);
    
    NSString* data = [[NSString alloc] initWithFormat:@"%@",[dictionary valueForKey:@"Response"]];
    
    NSString* success = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Success"]];
    
    if ([success isEqualToString:@"0"]) 
    {
        NSString* message = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Message"]];
        @throw [NSException exceptionWithName:@"REQUEST_FAILED_EXCEPTION" reason:message userInfo:dictionary];
    }
    
    NSArray* values = [data componentsSeparatedByString:@"\n"];

    NSString* _city = [DwollaAPI findValue:[values objectAtIndex:1]];
    NSString* _userID = [DwollaAPI findValue:[values objectAtIndex:2]];
    NSString* _latitude = [DwollaAPI findValue:[values objectAtIndex:3]];
    NSString* _longitude = [DwollaAPI findValue:[values objectAtIndex:4]];
    NSString* _name = [DwollaAPI findValue:[values objectAtIndex:5]];
    NSString* _state = [DwollaAPI findValue:[values objectAtIndex:6]];
    NSString* _type = [DwollaAPI findValue:[values objectAtIndex:7]];
    
    return [[DwollaUser alloc] initWithUserID:_userID name:_name city:_city state:_state 
                                     latitude:_latitude longitude:_longitude type:_type];  

}

+(NSDictionary*)getJSONTransactionsSince:(NSString*)date 
                                   limit:(NSString*)limit
                                    skip:(NSString*)skip
{
    if (![DwollaAPI hasToken]) 
    {
        @throw [NSException exceptionWithName:@"INVALID_TOKEN_EXCEPTION" 
                                       reason:@"oauth_token is invalid" userInfo:nil];
    }
    
    NSMutableArray* parameters = [[NSMutableArray alloc] initWithCapacity:4];
    
    if (date != nil  && ![date isEqualToString:@""]) 
    {
        NSString* param = @"sincedate=";
        [parameters addObject:[param stringByAppendingString:date]];
    }
    if (limit != nil  && ![limit isEqualToString:@""])
    {
        NSString* param = @"limit=";
        [parameters addObject:[param stringByAppendingString:limit]];
    }
    if (skip != nil  && ![skip isEqualToString:@""])
    {
        NSString* param = @"skip=";
        [parameters addObject:[param stringByAppendingString:skip]];
    }
    [parameters addObject:@"oauth_token="];
    
    NSString* url = @"/transactions?";
    
    for (int i = 0; i < [parameters count]; i++) 
    {
        url = [url stringByAppendingString:[parameters objectAtIndex:i]];
        if (i < [parameters count]-1)
        {
            url = [url stringByAppendingString:@"&"];
        }
    }

    NSMutableURLRequest* request = [DwollaAPI generateRequestWithString:url];
        
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSDictionary* dictionary = [DwollaAPI generateDictionaryWithData:result];
    
    return dictionary;
}

+(DwollaTransactions*)getTransactionsSince:(NSString*)date 
                                     limit:(NSString*)limit
                                      skip:(NSString*)skip
{
    NSDictionary* dictionary = [DwollaAPI getJSONTransactionsSince:date limit:limit skip:skip];
    NSArray* data =[dictionary valueForKey:@"Response"];
    
    NSString* success = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Success"]];
    
    if ([success isEqualToString:@"0"]) 
    {
        NSString* message = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Message"]];
        @throw [NSException exceptionWithName:@"REQUEST_FAILED_EXCEPTION" reason:message userInfo:dictionary];
    }
    
    NSMutableArray* transactions = [[NSMutableArray alloc] initWithCapacity:[data count]];
    for (int i = 0; i < [data count]; i++)
    {
        NSString* info = [[NSString alloc] initWithFormat:@"%@", [data objectAtIndex:i]];
        [transactions addObject:[DwollaAPI generateTransactionWithString:info]];
    }
    
   return [[DwollaTransactions alloc] initWithSuccess:YES transactions:transactions];
}

+(NSDictionary*)getJSONTransaction:(NSString*)transactionID
{
    if (![DwollaAPI hasToken]) 
    {
        @throw [NSException exceptionWithName:@"INVALID_TOKEN_EXCEPTION" 
                                       reason:@"oauth_token is invalid" userInfo:nil];
    }
    
    NSString* parameters = [@"/transactions/" stringByAppendingString:[NSString stringWithFormat:@"%@", transactionID]];
    NSMutableURLRequest* request = [DwollaAPI generateRequestWithString:[parameters stringByAppendingString: @"?oauth_token="]];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSDictionary* dictionary = [DwollaAPI generateDictionaryWithData:result];
    
    return dictionary; 
}

+(DwollaTransaction*)getTransaction:(NSString*)transactionID
{
    NSDictionary* dictionary = [DwollaAPI getJSONTransaction:transactionID];
    NSArray* pull =[dictionary valueForKey:@"Response"];
    NSString* data = [[NSString alloc] initWithFormat:@"%@", pull];
    
    NSString* success = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Success"]];
    
    if ([success isEqualToString:@"0"]) 
    {
        NSString* message = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Message"]];
        @throw [NSException exceptionWithName:@"REQUEST_FAILED_EXCEPTION" reason:message userInfo:dictionary];
    }
    
    DwollaTransaction* transaction = [DwollaAPI generateTransactionWithString:data];
    return transaction;
}

+(NSDictionary*)getJSONTransactionStats:(NSString*)start 
                                    end:(NSString*)end
{
    if (![DwollaAPI hasToken]) 
    {
        @throw [NSException exceptionWithName:@"INVALID_TOKEN_EXCEPTION" 
                                       reason:@"oauth_token is invalid" userInfo:nil];
    }
    
    NSMutableArray* parameters = [[NSMutableArray alloc] initWithCapacity:3];
    
    if (start != nil  && ![start isEqualToString:@""]) 
    {
        NSString* param = @"startdate=";
        [parameters addObject:[param stringByAppendingString:start]];
    }
    if (end != nil  && ![end isEqualToString:@""])
    {
        NSString* param = @"enddate=";
        [parameters addObject:[param stringByAppendingString:end]];
    }
    [parameters addObject:@"oauth_token="];
    
    NSString* url = @"/transactions/stats?";
    
    for (int i = 0; i < [parameters count]; i++) 
    {
        url = [url stringByAppendingString:[parameters objectAtIndex:i]];
        if (i < [parameters count]-1)
        {
            url = [url stringByAppendingString:@"&"];
        }
    }
    
    NSMutableURLRequest* request = [DwollaAPI generateRequestWithString:url];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    NSDictionary* dictionary = [DwollaAPI generateDictionaryWithData:result];
    
    return dictionary;

}

+(DwollaTransactionStats*)getTransactionStats:(NSString*)start 
                                          end:(NSString*)end
{
    NSDictionary* dictionary = [DwollaAPI getJSONTransactionStats:start end:end];
    NSArray* pull =[dictionary valueForKey:@"Response"];
    NSString* data = [[NSString alloc] initWithFormat:@"%@", pull];
    
    NSString* success = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Success"]];
    
    if ([success isEqualToString:@"0"]) 
    {
        NSString* message = [[NSString alloc] initWithFormat:@"%@", [dictionary valueForKey:@"Message"]];
        @throw [NSException exceptionWithName:@"REQUEST_FAILED_EXCEPTION" reason:message userInfo:dictionary];
    }
    
    NSArray* values = [data componentsSeparatedByString:@"\n"];
    
    NSString* count = [DwollaAPI findValue:[values objectAtIndex:1]];
    NSString* total = [DwollaAPI findValue:[values objectAtIndex:2]];

    return [[DwollaTransactionStats alloc] initWithSuccess:YES count:count total:total];
}


+(NSURLRequest*)generateURLWithKey:(NSString*)key
                          redirect:(NSString*)redirect
                          response:(NSString*)response
                            scopes:(NSArray*)scopes
{   
    if (key == nil || [key isEqualToString:@""])
    {
        @throw [NSException exceptionWithName:@"INVALID_APPLICATION_CREDENTIALS_EXCEPTION" 
                                       reason:@"your application key is invalid" 
                                     userInfo:nil];
    }
    if(redirect == nil || [redirect isEqualToString:@""] || response == nil || 
        [response isEqualToString:@""] || scopes == nil || [scopes count] == 0) 
    {
        @throw [NSException exceptionWithName:@"INVALID_PARAMETER_EXCEPTION" 
                                       reason:@"either redirect, response, or scopes is nil or empty" userInfo:nil];
    }
    NSString* url = [NSString stringWithFormat:@"https://www.dwolla.com/oauth/v2/authenticate?client_id=%@&response_type=%@&redirect_uri=%@&scope=", key, response, redirect];
    
    for (int i = 0; i < [scopes count]; i++) 
    {
        url = [url stringByAppendingString:[scopes objectAtIndex:i]];
        if([scopes count] > 0 && i < [scopes count]-1)
        {
            url = [url stringByAppendingString:@"%7C"];
        }
    }
    
    NSURL* fullURL = [[NSURL alloc] initWithString:url];
    
    NSURLRequest* returnURL = [[NSURLRequest alloc] initWithURL:fullURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:100];
   
    return returnURL;
}

+(NSMutableURLRequest*)generateRequestWithString:(NSString*)string
{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    
    
    NSString* url = [dwollaAPIBaseURL stringByAppendingString:string];
    
    NSURL* fullURL = [NSURL URLWithString:[url stringByAppendingString:token]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fullURL 
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    return request;
}

+(NSDictionary*)generateDictionaryWithData:(NSData*)data
{
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]; 
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSDictionary *dictionary = [parser objectWithString:dataString];
    
    return dictionary;
}

+(DwollaContact*)generateContactWithString:(NSString*)string
{
    NSArray* info = [string componentsSeparatedByString:@"\n"];
    NSString* city = [DwollaAPI findValue:[info objectAtIndex:1]];
    NSString* userID = [DwollaAPI findValue:[info objectAtIndex:2]];
    NSString* image = [DwollaAPI findValue:[info objectAtIndex:3]];
    NSString* name = [DwollaAPI findValue:[info objectAtIndex:4]];
    NSString* state = [DwollaAPI findValue:[info objectAtIndex:5]];
    NSString* type = [DwollaAPI findValue:[info objectAtIndex:6]];
    
    return [[DwollaContact alloc] initWithUserID:userID name:name image:image city:city state:state type:type];
}

+(DwollaFundingSource*)generateSourceWithString:(NSString*)string
{
    NSArray* info = [string componentsSeparatedByString:@"\n"];
    
    NSString* sourceID = [DwollaAPI findValue:[info objectAtIndex:1]];
    NSString* name = [DwollaAPI findValue:[info objectAtIndex:2]];
    NSString* type = [DwollaAPI findValue:[info objectAtIndex:3]];
    NSString* verified = [DwollaAPI findValue:[info objectAtIndex:4]];
    
    return [[DwollaFundingSource alloc] initWithSourceID:sourceID name:name type:type verified:verified];
}

+(DwollaTransaction*)generateTransactionWithString:(NSString*)string
{
    NSArray* info = [string componentsSeparatedByString:@"\n"];
    
    NSString* amount = [DwollaAPI findValue:[info objectAtIndex:1]];
    NSString* clearingDate = [DwollaAPI findValue:[info objectAtIndex:2]];
    NSString* date = [DwollaAPI findValue:[info objectAtIndex:3]];
    NSString* destinationID = [DwollaAPI findValue:[info objectAtIndex:4]];
    NSString* destinationName = [DwollaAPI findValue:[info objectAtIndex:5]];
    NSString* transactionID =  [DwollaAPI findValue:[info objectAtIndex:6]];
    NSString* notes = [DwollaAPI findValue:[info objectAtIndex:7]];
    NSString* sourceID = [DwollaAPI findValue:[info objectAtIndex:8]];
    NSString* sourceName =  [DwollaAPI findValue:[info objectAtIndex:9]];
    NSString* status =  [DwollaAPI findValue:[info objectAtIndex:10]];
    NSString* type =  [DwollaAPI findValue:[info objectAtIndex:11]];
    NSString* userType =  [DwollaAPI findValue:[info objectAtIndex:12]];

    
    return [[DwollaTransaction alloc] initWithAmount:amount clearingDate:clearingDate date:date destinationID:destinationID destinationName:destinationName transactionID:transactionID notes:notes sourceID:sourceID sourceName:sourceName status:status type:type userType:userType];
}

+(NSString*)findValue:(NSString*)string
{
    NSArray* split = [string componentsSeparatedByString:@"= "];
    NSArray* trimmed = [[split objectAtIndex:1] componentsSeparatedByString:@"\""];
    if ([trimmed count] == 3) 
    {
        return [trimmed objectAtIndex:1];
    }
    else 
    {
        NSArray* removed = [[trimmed objectAtIndex:0] componentsSeparatedByString:@";"];
        return (NSString*)[removed objectAtIndex:0];
    }
}

+(NSString *)encodedURLParameterString:(NSString*)string
{
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                             (__bridge_retained CFStringRef)string,
                                                                                             NULL,
                                                                                             CFSTR(":/=,!$&'()*+;[]@#?"),
                                                                                             kCFStringEncodingUTF8);
	return result;
}

@end
