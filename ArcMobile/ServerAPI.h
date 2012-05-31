//
//  ServerAPI.h
//  ArcMobile
//
//  Created by Nick Wroblewski on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerAPI : NSObject


+(NSDictionary *)getInvoiceFromNumber:(NSString *)invoiceNumber andRestaurantId:(NSString *)restaurantId;

+(NSDictionary *)updateInvoiceWithId:(NSString *)invoiceId andRestaurantId:(NSString *)restaurantId gratuity:(NSString *)gratuity paymentMethod:(NSString *)paymentMethod percentage:(NSString *)percentage invoiceStatus:(NSString *)invoiceStatus userToken:(NSString *)userToken;

+ (NSString *)encodeBase64:(NSString *)stringToEncode;
+ (NSString *)encodeBase64data:(NSData *)encodeData;
@end
