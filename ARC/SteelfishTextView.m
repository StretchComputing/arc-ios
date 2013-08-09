//
//  SteelfishTextView.m
//  ARC
//
//  Created by Nick Wroblewski on 8/8/13.
//
//

#import "SteelfishTextView.h"

@implementation SteelfishTextView


- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self setFont: [UIFont fontWithName: @"Steelfish" size: self.font.pointSize]];
        
        
    }
    return self;
}


@end
