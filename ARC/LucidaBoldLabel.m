//
//  LucidaBoldLabel.m
//  ARC
//
//  Created by Nick Wroblewski on 9/6/12.
//
//

#import "LucidaBoldLabel.h"

@implementation LucidaBoldLabel

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self setFont: [UIFont fontWithName: @"LucidaGrande-Bold" size: self.font.pointSize+1]];
    }
    return self;
}
@end
