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
    CreatePayment=5
} APIS;

@interface ArcClient : NSObject {
    APIS api;
}
@property (nonatomic, strong) NSMutableData *serverData;

-(void)createCustomer:(NSDictionary *)pairs;
-(NSDictionary *) createCustomerResponse;

-(void)getCustomerToken:(NSDictionary *)pairs;
-(NSDictionary *) getCustomerTokenResponse;

-(void)getMerchantList:(NSDictionary *)pairs;
-(NSDictionary *) getMerchantListResponse;

-(void)getInvoice:(NSDictionary *)pairs;
-(NSDictionary *) getInvoiceResponse;

-(void)createPayment:(NSDictionary *)pairs;
-(NSDictionary *) createPaymentResponse;

@end

