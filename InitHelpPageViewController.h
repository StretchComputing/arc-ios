//
//  InitHelpPageViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 3/26/13.
//
//

#import <UIKit/UIKit.h>
#import "NVUIGradientButton.h"
#import "LoadingViewController.h"

@class  LoadingViewController;


@interface InitHelpPageViewController : UIViewController <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *helpView;
@property BOOL isGoingPrivacyTerms;
@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property BOOL doesHaveGuestToken;
@property BOOL didPushStart;
@property BOOL guestTokenError;
@property BOOL didFailToken;
@property (strong, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *helpImage1;
@property (strong, nonatomic) IBOutlet UIImageView *helpImage2;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *startUsingButton;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIImageView *helpImage3;
@property (strong, nonatomic) IBOutlet UIView *topLine;
@property (strong, nonatomic) IBOutlet UIView *bottomLine;
@property (strong, nonatomic) IBOutlet UIView *vertLine1;
@property (strong, nonatomic) IBOutlet UIView *vertLine2;

-(IBAction)startUsingAction;
@end
