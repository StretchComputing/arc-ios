//
//  CorbelRegularLabel.m
//  ARC
//
//  Created by Nick Wroblewski on 9/6/12.
//
//

#import "CorbelRegularLabel.h"

@implementation CorbelRegularLabel

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self setFont: [UIFont fontWithName: @"Corbel" size: self.font.pointSize]];
    }
    return self;
}
@end
