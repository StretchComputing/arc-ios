//
//  LucidaLabel.m
//  ARC
//
//  Created by Nick Wroblewski on 9/6/12.
//
//

#import "LucidaLabel.h"

@implementation LucidaLabel

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self setFont: [UIFont fontWithName: @"LucidaGrande" size: self.font.pointSize]];
    }
    return self;
}

@end
