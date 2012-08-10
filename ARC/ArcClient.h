//
//  ArcClient.h
//  ARC
//
//  Created by Joseph Wroblewski on 8/5/12.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    CreateCustomer=1,
    GetCustomerToken=2,
    GetMerchantList=3,
    GetInvoice=4,
    CreatePayment=5,
    CreateReview=6,
    GetPointBalance=7
} APIS;

@interface ArcClient : NSObject {
    APIS api;
}
@property (nonatomic, strong) NSMutableData *serverData;

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

@end

