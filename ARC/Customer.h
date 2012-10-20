//
//  Customer.h
//  ARC
//
//  Created by Nick Wroblewski on 10/20/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CreditCard;

@interface Customer : NSManagedObject

@property (nonatomic, retain) NSString * customerId;
@property (nonatomic, retain) NSString * customerToken;
@property (nonatomic, retain) NSSet *creditCards;
@end

@interface Customer (CoreDataGeneratedAccessors)

- (void)addCreditCardsObject:(CreditCard *)value;
- (void)removeCreditCardsObject:(CreditCard *)value;
- (void)addCreditCards:(NSSet *)values;
- (void)removeCreditCards:(NSSet *)values;

@end
