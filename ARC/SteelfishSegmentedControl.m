//
//  SteelfishSegmentedControl.m
//  ARC
//
//  Created by Nick Wroblewski on 8/8/13.
//
//

#import "SteelfishSegmentedControl.h"
#import "SteelfishLabel.h"

@implementation SteelfishSegmentedControl


- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:FONT_REGULAR size:13]
                                                               forKey:UITextAttributeFont];
        [self setTitleTextAttributes:attributes forState:UIControlStateNormal];
        
    }
    return self;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */


@end
