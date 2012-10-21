//
//  ArcClient.h
//  ARC
//
//  Created by Joseph Wroblewski on 8/5/12.
//
//

#import <Foundation/Foundation.h>

extern int const USER_ALREADY_EXISTS;
extern int const INCORRECT_LOGIN_INFO;
extern int const INVOICE_NOT_FOUND;
extern int const CANNOT_PROCESS_PAYMENT;
extern int const MERCHANT_CANNOT_ACCEPT_PAYMENT_TYPE;
extern int const OVER_PAID;
extern int const INVALID_AMOUNT;
extern int const CANNOT_TRANSFER_TO_SAME_ACCOUNT;
extern int const FAILED_TO_VALIDATE_CARD;
extern int const INVALID_ACCOUNT_NUMBER;
extern int const CANNOT_GET_PAYMENT_AUTHORIZATION;
extern int const INVALID_ACCOUNT_PIN;
extern int const INSUFFICIENT_FUNDS;


extern NSString *const ARC_ERROR_MSG;

typedef enum {
    GetServer = 0,
    CreateCustomer=1,
    GetCustomerToken=2,
    GetMerchantList=3,
    GetInvoice=4,
    CreatePayment=5,
    CreateReview=6,
    GetPointBalance=7,
    TrackEvent=8,
    GetPasscode=9,
    ResetPassword = 10

} APIS;

@interface ArcClient : NSObject <NSURLConnectionDelegate> {
    APIS api;
}
@property (nonatomic, strong) NSMutableData *serverData;
@property int httpStatusCode;

-(void)createCustomer:(NSDictionary *)pairs;
-(NSDictionary *) createCustomerResponse:(NSDictionary *)response;

-(void)getCustomerToken:(NSDictionary *)pairs;
-(NSDictionary *) getCustomerTokenResponse:(NSDictionary *)response;

-(void)getMerchantList:(NSDictionary *)pairs;
-(NSDictionary *) getMerchantListResponse:(NSDictionary *)response;

-(void)getInvoice:(NSDictionary *)pairs;
-(NSDictionary *) getInvoiceResponse:(NSDictionary *)response;

-(void)createPayment:(NSDictionary *)pairs;
-(NSDictionary *) createPaymentResponse:(NSDictionary *)response;

-(void)createReview:(NSDictionary *)pairs;
-(NSDictionary *) createReviewResponse:(NSDictionary *)response;

-(void)getPointBalance:(NSDictionary *)pairs;
-(NSDictionary *) getPointBalanceResponse:(NSDictionary *)response;

-(void)trackEvent:(NSDictionary *)pairs;
-(NSDictionary *) trackEventResponse:(NSDictionary *)response;

-(void)getPasscode:(NSDictionary *)pairs;
-(void)resetPassword:(NSDictionary *)pairs;

-(void)getServer;

+(void)trackEvent:(NSString *)action;

@end

