//
//  SteelfishTextView.m
//  ARC
//
//  Created by Nick Wroblewski on 8/8/13.
//
//

#import "SteelfishTextView.h"
#import "SteelfishLabel.h"

@implementation SteelfishTextView


- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self setFont: [UIFont fontWithName:FONT_REGULAR size: self.font.pointSize]];
        
        
    }
    return self;
}


@end
