//
//  SteelfishTitleLabel.m
//  ARC
//
//  Created by Nick Wroblewski on 8/8/13.
//
//

#import "SteelfishTitleLabel.h"
#import "SteelfishLabel.h"

@implementation SteelfishTitleLabel


-(id)initWithText:(NSString *)labelTitle{
    
    self.theTitle = labelTitle;
    UIFont* titleFont = [UIFont fontWithName:FONT_BOLD size:28];
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
        self.font = [UIFont fontWithName:FONT_BOLD size:28];
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
