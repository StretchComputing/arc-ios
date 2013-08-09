//
//  SteelfishBoldLabel.m
//  ARC
//
//  Created by Nick Wroblewski on 8/8/13.
//
//

#import "SteelfishBoldLabel.h"

@implementation SteelfishBoldLabel


- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self setFont: [UIFont fontWithName: @"SteelfishEb-Regular" size: self.font.pointSize+4]];
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
        [self setFont: [UIFont fontWithName: @"SteelfishEb-Regular" size:size+4]];
        self.textAlignment = UITextAlignmentCenter;
    }
    return self;
}





@end
