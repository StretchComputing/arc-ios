//
//  SteelfishInputText.m
//  ARC
//
//  Created by Nick Wroblewski on 8/8/13.
//
//

#import "SteelfishInputText.h"
#import "SteelfishLabel.h"


@implementation SteelfishInputText


- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self setFont: [UIFont fontWithName:FONT_REGULAR size: self.font.pointSize]];
        
        
    }
    return self;
}


- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    CGRect myBounds = bounds;
    //myBounds.origin.y = 1;
    myBounds.origin.x = 5;

    myBounds.size.width = bounds.size.width -10;

    return myBounds;
}

- (CGRect)textRectForBounds:(CGRect)bounds{
    
    CGRect myBounds = bounds;
   // myBounds.origin.y = 1;
    myBounds.origin.x = 5;
    myBounds.size.width = bounds.size.width -10;

    return myBounds;
    
}

@end
