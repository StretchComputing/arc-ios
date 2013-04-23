//
//  InitialController.h
//  ARC
//
//  Created by Nick Wroblewski on 8/24/12.
//
//

#import <UIKit/UIKit.h>

@interface InitialController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *mottoLabel;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *topLineView;
@property (strong, nonatomic) IBOutlet UIView *loadingView;

@end
