//
//  ArcClient.h
//  ARC
//
//  Created by Joseph Wroblewski on 8/5/12.
//
//

#import <Foundation/Foundation.h>

@interface ArcClient : NSObject
@property (nonatomic, strong) NSMutableData *serverData;

-(void)createCustomer:(NSDictionary *)pairs error:(NSError **)error;

@end
