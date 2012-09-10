//
//  CorbelButton.m
//  ARC
//
//  Created by Nick Wroblewski on 9/9/12.
//
//

#import "CorbelButton.h"

@implementation CorbelButton

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self.titleLabel setFont: [UIFont fontWithName: @"LucidaGrande" size: self.titleLabel.font.pointSize]];
                
        [self setTitleEdgeInsets:UIEdgeInsetsMake(1.0, 0.0, 0.0, 0.0)];

    }
    return self;
}

@end
