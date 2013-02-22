//
//  ReviewTransaction.h
//  ARC
//
//  Created by Nick Wroblewski on 6/29/12.
//  Copyright (c) 2012 Stretch Computing, Inc. All rights reserved.
// change

#import <UIKit/UIKit.h>
#import "LucidaLabel.h"
#import "CorbelBoldLabel.h"
#import <Accounts/Accounts.h>
#import "Invoice.h"
#import "LucidaBoldLabel.h"
#import "LoadingViewController.h"

@class LoadingViewController;

@interface ReviewTransaction : UIViewController <UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
- (IBAction)submitReview:(id)sender;
- (IBAction)skipReview:(id)sender;

@property BOOL shouldShowLoading;
@property (nonatomic, strong) LoadingViewController *loadingViewController;
@property (nonatomic, strong) IBOutlet LucidaBoldLabel *paymentPointsLabel;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *submitButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *skipButton;

@property int paymentPointsReceived;

-(IBAction)sliderValueChanged:(UISlider *)sender;

@property BOOL isIos6;

@property int pointsEarned;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) ACAccountStore *store;

@property (nonatomic, strong) NSNumber *foodInt;
@property (nonatomic, strong) NSNumber *drinksInt;
@property (nonatomic, strong) NSNumber *priceInt;
@property (nonatomic, strong) NSNumber *serviceInt;
@property (nonatomic, strong) NSNumber *moodInt;
@property (nonatomic, strong) NSNumber *twitterInt;
@property (nonatomic, strong) NSNumber *facebookInt;
@property (weak, nonatomic) IBOutlet UISlider *serviceSlider;
@property (weak, nonatomic) IBOutlet UISlider *drinksSlider;
@property (weak, nonatomic) IBOutlet UISlider *moodSlider;
@property (weak, nonatomic) IBOutlet UISlider *valueSlider;
@property (weak, nonatomic) IBOutlet UIButton *postFacebookButton;
@property (weak, nonatomic) IBOutlet LucidaLabel *postFacebookPoints;

@property (weak, nonatomic) IBOutlet UIButton *postTwitterButton;
@property (weak, nonatomic) IBOutlet LucidaLabel *postTwitterPoints;

@property (weak, nonatomic) IBOutlet CorbelBoldLabel *shareLabel;


@property (weak, nonatomic) IBOutlet UILabel *earnMoreLabel;
@property (weak, nonatomic) IBOutlet UISlider *foodSlider;
@property (strong, nonatomic) Invoice *myInvoice;


-(IBAction)postFacebook;

@property (nonatomic, strong) IBOutlet UIButton *food1;
@property (nonatomic, strong) IBOutlet UIButton *food2;
@property (nonatomic, strong) IBOutlet UIButton *food3;
@property (nonatomic, strong) IBOutlet UIButton *food4;
@property (nonatomic, strong) IBOutlet UIButton *food5;
- (IBAction)postTwitter;

@property (nonatomic, strong) IBOutlet UIButton *service1;
@property (nonatomic, strong) IBOutlet UIButton *service2;
@property (nonatomic, strong) IBOutlet UIButton *service3;
@property (nonatomic, strong) IBOutlet UIButton *service4;
@property (nonatomic, strong) IBOutlet UIButton *service5;

@property (nonatomic, strong) IBOutlet UIButton *drinks1;
@property (nonatomic, strong) IBOutlet UIButton *drinks2;
@property (nonatomic, strong) IBOutlet UIButton *drinks3;
@property (nonatomic, strong) IBOutlet UIButton *drinks4;
@property (nonatomic, strong) IBOutlet UIButton *drinks5;

@property (nonatomic, strong) IBOutlet UIButton *atmosphere1;
@property (nonatomic, strong) IBOutlet UIButton *atmosphere2;
@property (nonatomic, strong) IBOutlet UIButton *atmosphere3;
@property (nonatomic, strong) IBOutlet UIButton *atmosphere4;
@property (nonatomic, strong) IBOutlet UIButton *atmosphere5;

@property (nonatomic, strong) IBOutlet UIButton *value1;
@property (nonatomic, strong) IBOutlet UIButton *value2;
@property (nonatomic, strong) IBOutlet UIButton *value3;
@property (nonatomic, strong) IBOutlet UIButton *value4;
@property (nonatomic, strong) IBOutlet UIButton *value5;
@property (weak, nonatomic) IBOutlet UITextView *commentsText;
-(IBAction)starClicked:(id)sender;

@property (nonatomic, strong) NSMutableData *serverData;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

-(IBAction)selectFavoriteItem;




//Favorite Item Picker
@property (nonatomic, strong) IBOutlet UIButton *selectFavoriteButton;
@property (nonatomic, strong) IBOutlet CorbelBoldLabel *selectedItemTextField;
@property (nonatomic, strong) NSString *selectedItemId;
@property (nonatomic, strong) NSString *selectedItemName;
@property (nonatomic, strong) IBOutlet UIView *favoriteItemBackview;
@property (nonatomic, strong) UIView *favoriteItemBackAlphaView;
@property (nonatomic, strong) UIPickerView *favoriteItemPickerView;
@property (nonatomic, strong) UILabel *favoriteItemLabel;




@end
