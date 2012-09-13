//
//  rSkybox.h
//  rTeam
//
//  Created by Nick Wroblewski on 4/30/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

/*
 @try {
 }
 @catch (NSException *e) {
 [rSkybox sendClientLog:@"initManagedDocument" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
 }

 */

#import <Foundation/Foundation.h>
#import "CorbelTitleLabel.h"
#import "CorbelBarButtonItem.h"

@interface rSkybox : NSObject

//rSkybox server communication methods
+ (NSDictionary *)createEndUser;
+(void)sendClientLog:(NSString *)logName logMessage:(NSString *)logMessage logLevel:(NSString *)logLevel exception:(NSException *)exception;
+(void)sendCrashDetect:(NSString *)summary theStackData:(NSData *)stackData;
+(void)sendFeedback:(NSData *)recordedData;

+(void)startThreshold:(NSString *)logName;
+(void)endThreshold:(NSString *)logName logMessage:(NSString *)logMessage maxValue:(double)maxValue;


//App Actions Methods
+(void)initiateSession;
+(void)addEventToSession:(NSString *)event;
+(void)printTraceSession;
+(NSMutableArray *)getActions;
+(NSMutableArray *)getTimestamps;
+(void)setSavedArray:(NSMutableArray *)savedArray :(NSMutableArray *)savedArrayTime;

//Base64 Encoder methods
+ (NSString *)encodeBase64data:(NSData *)encodeData;
+ (NSString *)encodeBase64:(NSString *)stringToEncode;
+ (NSString *)getBasicAuthHeader;


@end
