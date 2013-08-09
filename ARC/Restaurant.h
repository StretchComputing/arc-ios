//
//  Restaurant.h
//  ARC
//
//  Created by Nick Wroblewski on 6/26/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Invoice.h"
#import "SteelfishBarButtonItem.h"
#import "SteelfishTextView.h"
#import "ArcClient.h"
#import "LoadingViewController.h"
#import "NVUIGradientButton.h"
#import "CheckHelpOverlay.h"
#import "SteelfishBoldInputText.h"

@class LoadingViewController;

@interface Restaurant : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) CheckHelpOverlay *helpOverlay;

@property (strong, nonatomic) IBOutlet NVUIGradientButton *submitButton;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *topLineView;
@property (strong, nonatomic) IBOutlet UIButton *popAction;
- (IBAction)goBackAction;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *closeHelpButton;

@property (nonatomic, strong) NSMutableArray *paidItemsArray;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (nonatomic, strong) ArcClient *getInvoiceArcClient;
@property (nonatomic, strong) IBOutlet UIView *hintOverlayView;
@property (strong, nonatomic) IBOutlet SteelfishTextView *overlayTextView;

@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;

//@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;
@property (weak, nonatomic) IBOutlet UITextField *checkNumFive;
@property (weak, nonatomic) IBOutlet UITextField *checkNumSix;
@property (nonatomic, strong) NSString *paymentsAccepted;
@property (nonatomic, strong) UIButton *keyboardSubmitButton;
@property (nonatomic, strong) UIView *hideKeyboardView;
- (IBAction)takeCheckPicture;
@property (strong, nonatomic) IBOutlet UIView *leftTopLineView;

@property (strong, nonatomic) IBOutlet UIView *rightTopLineView;
@property BOOL isIphone5;
@property BOOL helpShowing;
- (IBAction)submit:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *nameDisplay;

@property (nonatomic, strong) NSString *name;
@property (strong, nonatomic) IBOutlet UIView *notFoundHelpView;

@property (weak, nonatomic) IBOutlet UIImageView *checkHelpImageView;
@property (weak, nonatomic) IBOutlet UITextField *checkNumFour;
@property (weak, nonatomic) IBOutlet UITextField *checkNumThree;
@property (weak, nonatomic) IBOutlet UITextField *checkNumTwo;

@property BOOL wentInvoice;
@property (strong, nonatomic) IBOutlet UIView *helpBackView;

@property (weak, nonatomic) IBOutlet UITextField *checkNumOne;

@property (nonatomic, strong) NSString *merchantId;

- (IBAction)checkNumberHelp;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (strong, nonatomic) NSMutableData *serverData;

@property (strong, nonatomic) Invoice *myInvoice;
- (IBAction)closeHelp;

@property (nonatomic, strong) IBOutlet SteelfishBoldInputText *hiddenText;

//-(IBAction)showCamera;
@end
