//
//  CorbelTextField.m
//  ARC
//
//  Created by Nick Wroblewski on 9/9/12.
//
//

#import "CorbelTextField.h"

@implementation CorbelTextField

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self setFont: [UIFont fontWithName: @"LucidaGrande" size: self.font.pointSize]];
    }
    return self;
}

@end
