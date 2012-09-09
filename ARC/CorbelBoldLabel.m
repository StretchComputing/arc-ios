//
//  CorbelBoldLabel.m
//  ARC
//
//  Created by Nick Wroblewski on 9/6/12.
//
//

#import "CorbelBoldLabel.h"

@implementation CorbelBoldLabel

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self setFont: [UIFont fontWithName: @"Corbel-Bold" size: self.font.pointSize+3]];
    }
    return self;
}

@end
