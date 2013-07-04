//
//  CheckHelpOverlay.m
//  ARC
//
//  Created by Nick Wroblewski on 7/3/13.
//
//

#import "CheckHelpOverlay.h"
#import "Restaurant.h"

@interface CheckHelpOverlay ()

@end

@implementation CheckHelpOverlay

-(void)viewDidLoad{
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.view.hidden = YES;
}
- (IBAction)helpClicked {
    
    id mainViewController = [self.view.superview nextResponder];
    
    if ([mainViewController class] == [Restaurant class]) {
        
        Restaurant *tmp = (Restaurant *) [self.view.superview nextResponder];
        
        [tmp checkNumberHelp];
    }
}
@end
