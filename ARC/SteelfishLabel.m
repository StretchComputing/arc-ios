//
//  SteelfishLabel.m
//  ARC
//
//  Created by Nick Wroblewski on 8/8/13.
//
//

#import "SteelfishLabel.h"

@implementation SteelfishLabel

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self setFont: [UIFont fontWithName:FONT_REGULAR size: self.font.pointSize+4]];
    }
    return self;
}

@end