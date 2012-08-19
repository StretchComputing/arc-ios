//
//  PushSegueNoAnimation.m
//  ARC
//
//  Created by Nick Wroblewski on 6/28/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import "PushSegueNoAnimation.h"

@implementation PushSegueNoAnimation


- (void)perform {
        
    [[self.sourceViewController navigationController ] pushViewController:self.destinationViewController animated:NO]; 
} 


@end
