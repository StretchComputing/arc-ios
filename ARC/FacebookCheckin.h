//
//  FacebookCheckin.h
//  ARC
//
//  Created by Nick Wroblewski on 11/30/12.
//
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

@interface FacebookCheckin : NSObject

@property (nonatomic, strong) ACAccountStore *store;

-(void)checkInAtLocationWithId:(NSString *)locationId;
@end
