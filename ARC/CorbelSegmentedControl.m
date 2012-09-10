//
//  CorbelSegmentedControl.m
//  ARC
//
//  Created by Nick Wroblewski on 9/9/12.
//
//

#import "CorbelSegmentedControl.h"

@implementation CorbelSegmentedControl

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"LucidaGrande" size:13]
                                                               forKey:UITextAttributeFont];
        [self setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    }
    return self;
}

    
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
