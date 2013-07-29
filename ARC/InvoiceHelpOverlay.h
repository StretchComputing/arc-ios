//
//  InvoiceHelpOverlay.h
//  ARC
//
//  Created by Nick Wroblewski on 7/3/13.
//
//

#import <UIKit/UIKit.h>

@interface InvoiceHelpOverlay : UIViewController
@property (strong, nonatomic) IBOutlet UIView *topOpenView;
@property (strong, nonatomic) IBOutlet UIView *stepOneView;
@property (strong, nonatomic) IBOutlet UIView *stepTwoView;
@property (strong, nonatomic) IBOutlet UIView *stepThreeView;
@property int currentStep;
@property (nonatomic, strong) NSTimer *myTimer;
@property (strong, nonatomic) IBOutlet UIView *viewTwo;

@property (strong, nonatomic) IBOutlet UIView *viewOne;
-(void)startNow;
@end
