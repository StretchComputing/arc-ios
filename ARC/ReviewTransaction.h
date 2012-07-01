//
//  ReviewTransaction.h
//  ARC
//
//  Created by Nick Wroblewski on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewTransaction : UIViewController <UITextViewDelegate>
- (IBAction)submitReview:(id)sender;
- (IBAction)skipReview:(id)sender;


@property (nonatomic, strong) IBOutlet UIButton *food1;
@property (nonatomic, strong) IBOutlet UIButton *food2;
@property (nonatomic, strong) IBOutlet UIButton *food3;
@property (nonatomic, strong) IBOutlet UIButton *food4;
@property (nonatomic, strong) IBOutlet UIButton *food5;

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

  
  @end
