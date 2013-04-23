//
//  GuestCardObject.h
//  ARC
//
//  Created by Nick Wroblewski on 4/21/13.
//
//

#import <Foundation/Foundation.h>

@interface GuestCardObject : NSObject

@property (nonatomic, strong) NSString *cardNumber;
@property (nonatomic, strong) NSString *expiration;
@property (nonatomic, strong) NSString *ccv;

@end
