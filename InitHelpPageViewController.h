//
//  InitHelpPageViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 3/26/13.
//
//

#import <UIKit/UIKit.h>

@interface InitHelpPageViewController : UIViewController <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *helpView;

@property (strong, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *helpImage1;
@property (strong, nonatomic) IBOutlet UIImageView *helpImage2;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIImageView *helpImage3;
@property (strong, nonatomic) IBOutlet UIView *topLine;
@property (strong, nonatomic) IBOutlet UIView *bottomLine;
@property (strong, nonatomic) IBOutlet UIView *vertLine1;
@property (strong, nonatomic) IBOutlet UIView *vertLine2;
@property (strong, nonatomic) IBOutlet UIToolbar *myToolbar;

-(IBAction)startUsingAction;
@end
