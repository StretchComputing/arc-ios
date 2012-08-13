//
//  PresentSegueNoAnimation.m
//  ARC
//
//  Created by Nick Wroblewski on 8/12/12.
//
//

#import "PresentSegueNoAnimation.h"

@implementation PresentSegueNoAnimation


- (void)perform {
    
    [self.sourceViewController presentModalViewController:self.destinationViewController animated:NO];
    
}



@end
