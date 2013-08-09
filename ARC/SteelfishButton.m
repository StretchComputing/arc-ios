//
//  SteelfishButton.m
//  ARC
//
//  Created by Nick Wroblewski on 8/8/13.
//
//

#import "SteelfishButton.h"
#import "SteelfishLabel.h"

@implementation SteelfishButton


- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self.titleLabel setFont: [UIFont fontWithName:FONT_REGULAR size: self.titleLabel.font.pointSize]];
        
        [self setTitleEdgeInsets:UIEdgeInsetsMake(1.0, 0.0, 0.0, 0.0)];
        
    }
    return self;
}


@end
