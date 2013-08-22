//
//  ArcUtility.m
//  ARC
//
//  Created by Joseph Wroblewski on 10/6/12.
//
//

#import "ArcUtility.h"
#import "rSkybox.h"
#import "AddCreditCard.h"

@implementation ArcUtility

+(double)roundUpToNearestPenny:(double)dollarAmount {
    @try{
        int threePlaceInt = dollarAmount * 1000;
        double threePlaceDouble = ((double)threePlaceInt)/1000;
        
        int twoPlaceInt = dollarAmount * 100;
        double twoPlaceDouble = ((double)twoPlaceInt)/100;
        
        if(threePlaceDouble > twoPlaceDouble){
            twoPlaceDouble += 0.01;
        }
        return twoPlaceDouble;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcUtility.roundUpToNearestPenny" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

+(double)roundDownToNearestPenny:(double)dollarAmount {
    @try{
        int twoPlaceInt = dollarAmount * 100;
        double twoPlaceDouble = ((double)twoPlaceInt)/100;
        
        return twoPlaceDouble;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcUtility.roundDownToNearestPenny" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


/*
 NSString *const DINERS_CLUB = @"N";
 */

+(NSString *)getCardTypeForNumber:(NSString *)cardNumber{
    
    @try {
        
        if ([cardNumber length] > 0) {
            
            NSString *firstOne = [cardNumber substringToIndex:1];
            NSString *firstTwo = [cardNumber substringToIndex:2];
            NSString *firstThree = [cardNumber substringToIndex:3];
            NSString *firstFour = [cardNumber substringToIndex:4];

            int numberLength = [cardNumber length];

            if ([firstOne isEqualToString:@"4"] && ((numberLength == 15) || (numberLength == 16))) {
                return VISA;
            }
            
            double cardDigits = [firstTwo doubleValue];
            if ((cardDigits >= 51) && (cardDigits <= 55) && (numberLength == 16)) {
                return MASTER_CARD;
            }
            
            if (([firstTwo isEqualToString:@"34"] || [firstTwo isEqualToString:@"37"]) && (numberLength == 15)) {
                return AMERICAN_EXPRESS;
            }
            
            if (([firstTwo isEqualToString:@"65"] || [firstFour isEqualToString:@"6011"]) && (numberLength == 16)) {
                return DISCOVER;
            }
            
            double threeDigits = [firstThree doubleValue];            
            if ((numberLength == 14) && ([firstTwo isEqualToString:@"36"] || [firstTwo isEqualToString:@"38"] || ((threeDigits >= 300) && (threeDigits <= 305) ))) {
                return DINERS_CLUB;
            }
            
            return @"UNKOWN";
        }else{
            return @"";
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"ArcUtility.getCardTypeForNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
 
  
}

+(NSString *)getCardNameForType:(NSString *)cardType{
    
    if ([cardType isEqualToString:VISA]) {
        return @"Visa";
    }else if ([cardType isEqualToString:MASTER_CARD]) {
        return @"MasterCard";
    }else if ([cardType isEqualToString:AMERICAN_EXPRESS]) {
        return @"Amex";
    }else if ([cardType isEqualToString:DISCOVER]) {
        return @"Discover";
    }else if ([cardType isEqualToString:DINERS_CLUB]) {
        return @"Diners";
    }else{
        return @"";
    }
}

+(NSString *)roundDoubleUp:(double)myDouble{
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode: NSNumberFormatterRoundUp];
    NSString *numberString = [formatter stringFromNumber:[NSNumber numberWithDouble:myDouble]];
    return numberString;
    
}
@end
