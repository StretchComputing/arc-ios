//
//  ArcUtility.h
//  ARC
//
//  Created by Joseph Wroblewski on 10/6/12.
//
//

#import <Foundation/Foundation.h>

@interface ArcUtility : NSObject

+(double)roundUpToNearestPenny:(double)dollarAmount;
+(double)roundDownToNearestPenny:(double)dollarAmount;

+(NSString *)getCardTypeForNumber:(NSString *)cardNumber;

+(NSString *)getCardNameForType:(NSString *)cardType;
+(NSString *)roundDoubleUp:(double)myDouble;


@end


