//
//  CorbelInputTextField.m
//  ARC
//
//  Created by Nick Wroblewski on 9/10/12.
//
//

#import "CorbelInputTextField.h"

@implementation CorbelInputTextField

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self setFont: [UIFont fontWithName: @"LucidaGrande" size: self.font.pointSize]];
        
        
    }
    return self;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    CGRect myBounds = bounds;
    myBounds.origin.y = 1;
    return myBounds;
}

- (CGRect)textRectForBounds:(CGRect)bounds{
    
    CGRect myBounds = bounds;
    myBounds.origin.y = 1;
    return myBounds;
    
}

@end
