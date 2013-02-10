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

- (id)initWithFrame:(CGRect)frame andSize:(int)size
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor blackColor];
        [self setFont: [UIFont fontWithName: @"LucidaGrande-Bold" size:size]];
        self.textAlignment = UITextAlignmentCenter;
    }
    return self;
}


@end
