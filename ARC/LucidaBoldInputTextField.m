//
//  LucidaBoldInputTextField.m
//  ARC
//
//  Created by Nick Wroblewski on 3/29/13.
//
//

#import "LucidaBoldInputTextField.h"

@implementation LucidaBoldInputTextField

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self setFont: [UIFont fontWithName: @"LucidaGrande-Bold" size: self.font.pointSize]];
        
        
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
