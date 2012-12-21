//
//  CorbelTextFieldCreditCardiOS6.m
//  ARC
//
//  Created by Nick Wroblewski on 12/21/12.
//
//

#import "CorbelTextFieldCreditCardiOS6.h"

@implementation CorbelTextFieldCreditCardiOS6


- (id)initWithCoder:(NSCoder *)decoder {
    
    
    if ((self = [super initWithCoder: decoder])) {
        
        [self setFont: [UIFont fontWithName: @"LucidaGrande" size: self.font.pointSize]];
        
        
    }
    return self;
}


-(void)deleteBackward{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"backspaceNotification" object:self userInfo:nil];

    [super deleteBackward];
    

}



@end
