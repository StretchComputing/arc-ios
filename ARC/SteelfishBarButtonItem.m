//
//  SteelfishBarButtonItem.m
//  ARC
//
//  Created by Nick Wroblewski on 8/8/13.
//
//

#import "SteelfishBarButtonItem.h"
#import "SteelfishLabel.h"

@implementation SteelfishBarButtonItem


-(id)initWithTitleText:(NSString *)title{
    
    if (self = [self initWithTitle:title style:UIBarButtonItemStyleDone target:nil action:nil]) {
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:FONT_REGULAR size:15]
                                                               forKey:UITextAttributeFont];
        [self setTitleTextAttributes:attributes forState:UIControlStateNormal];
        
        [self setTitlePositionAdjustment:UIOffsetMake(0, 1.0) forBarMetrics:UIBarMetricsDefault];
        
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:FONT_REGULAR size:15]
                                                               forKey:UITextAttributeFont];
        [self setTitleTextAttributes:attributes forState:UIControlStateNormal];
        
        [self setTitlePositionAdjustment:UIOffsetMake(0, 1.0) forBarMetrics:UIBarMetricsDefault];
        
    }
    
    self.width = 100;
    return self;
}




@end
