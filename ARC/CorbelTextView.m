//
//  CorbelTextView.m
//  ARC
//
//  Created by Nick Wroblewski on 9/10/12.
//
//

#import "CorbelTextView.h"

@implementation CorbelTextView

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self setFont: [UIFont fontWithName: @"LucidaGrande" size: self.font.pointSize]];
        
        
    }
    return self;
}

@end
