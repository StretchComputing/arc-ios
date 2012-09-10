//
//  CorbelBarButtonItem.m
//  ARC
//
//  Created by Nick Wroblewski on 9/9/12.
//
//

#import "CorbelBarButtonItem.h"

@implementation CorbelBarButtonItem


- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"LucidaGrande" size:15]
                                                               forKey:UITextAttributeFont];
        [self setTitleTextAttributes:attributes forState:UIControlStateNormal];
        
        [self setTitlePositionAdjustment:UIOffsetMake(0, 1.0) forBarMetrics:UIBarMetricsDefault];
        
    }
    return self;
}


@end
