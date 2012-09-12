//
//  CorbelTitleLabel.m
//  ARC
//
//  Created by Nick Wroblewski on 9/12/12.
//
//

#import "CorbelTitleLabel.h"

@implementation CorbelTitleLabel

-(id)initWithText:(NSString *)labelTitle{
    
    self.theTitle = labelTitle;
    UIFont* titleFont = [UIFont fontWithName:@"Corbel-Bold" size:26];
    CGSize requestedTitleSize = [labelTitle sizeWithFont:titleFont];
    CGFloat titleWidth = requestedTitleSize.width;
    
    return [self initWithFrame:CGRectMake(0, 0, titleWidth + 8, 44)];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont fontWithName:@"Corbel-Bold" size:26];
        self.textAlignment = UITextAlignmentCenter;
        self.text = self.theTitle;
    }
    return self;
}


- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {9, 0, 0, 0};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}


@end
