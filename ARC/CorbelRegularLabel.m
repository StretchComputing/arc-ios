//
//  CorbelRegularLabel.m
//  ARC
//
//  Created by Nick Wroblewski on 9/6/12.
//
//

#import "CorbelRegularLabel.h"

@implementation CorbelRegularLabel

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder])
    {
        [self setFont: [UIFont fontWithName:@"LucidaGrande" size: self.font.pointSize]];
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
