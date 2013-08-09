//
//  SteelfishTextFieldCreditCardiOS6.m
//  ARC
//
//  Created by Nick Wroblewski on 8/8/13.
//
//

#import "SteelfishTextFieldCreditCardiOS6.h"

@implementation SteelfishTextFieldCreditCardiOS6


- (id)initWithCoder:(NSCoder *)decoder {
    
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self setFont: [UIFont fontWithName: @"Steelfish" size: self.font.pointSize]];
        
        
    }
    return self;
}


-(void)deleteBackward{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"backspaceNotification" object:self userInfo:nil];
    
    [super deleteBackward];
    
    
}



@end
