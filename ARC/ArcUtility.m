//
//  ArcUtility.m
//  ARC
//
//  Created by Joseph Wroblewski on 10/6/12.
//
//

#import "ArcUtility.h"
#import "rSkybox.h"

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

@end
