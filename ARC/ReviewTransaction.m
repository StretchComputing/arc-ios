//
//  ReviewTransaction.m
//  ARC
//
//  Created by Nick Wroblewski on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReviewTransaction.h"
#import <QuartzCore/QuartzCore.h>

@interface ReviewTransaction ()

-(void)changeStarsInRow:(NSString *)row numSelected:(int)selected;

@end

@implementation ReviewTransaction
@synthesize commentsText;
@synthesize food1, food2, food3, food4, food5, service1, service2, service3, service4, service5, drinks1, drinks2, drinks3, drinks4, drinks5, atmosphere1, atmosphere2, atmosphere3, atmosphere4, atmosphere5, value1, value2, value3, value4, value5;

-(void)viewDidLoad{
    
    [self.navigationItem setHidesBackButton:YES];
    self.commentsText.delegate = self;
    
    self.commentsText.layer.masksToBounds = YES;
    self.commentsText.layer.cornerRadius = 5.0;
    
    [self.food1 setImage:[UIImage imageNamed:@"fullStar.png"] forState:UIControlStateNormal];
    [self.service1 setImage:[UIImage imageNamed:@"fullStar.png"] forState:UIControlStateNormal];
    [self.drinks1 setImage:[UIImage imageNamed:@"fullStar.png"] forState:UIControlStateNormal];
    [self.atmosphere1 setImage:[UIImage imageNamed:@"fullStar.png"] forState:UIControlStateNormal];
    [self.value1 setImage:[UIImage imageNamed:@"fullStar.png"] forState:UIControlStateNormal];

}

-(IBAction)starClicked:(id)sender{
    
    NSString *row = @"";
    UIButton *tmpButton = sender;

    int myTag = tmpButton.tag;
    
    if (myTag < 6) {
        row = @"food";
        [self changeStarsInRow:row numSelected:myTag];
        
    }else if(myTag < 11){
        row = @"service";
        [self changeStarsInRow:row numSelected:myTag - 5];
    }else if (myTag < 16){
        row = @"drinks";
        [self changeStarsInRow:row numSelected:myTag - 10];

    }else if (myTag < 21){
        row = @"atmosphere";
        [self changeStarsInRow:row numSelected:myTag - 15];

    }else{
        row = @"value";
        [self changeStarsInRow:row numSelected:myTag - 20];

    }
    
    
    
    
}

-(void)changeStarsInRow:(NSString *)row numSelected:(int)selected{
    
    UIImage *full = [UIImage imageNamed:@"fullStar.png"];
    UIImage *empty = [UIImage imageNamed:@"emptyStar.png"];
    
    if ([row isEqualToString:@"food"]) {
        
        [self.food5 setImage:full forState:UIControlStateNormal];
        [self.food4 setImage:full forState:UIControlStateNormal];
        [self.food3 setImage:full forState:UIControlStateNormal];
        [self.food2 setImage:full forState:UIControlStateNormal];
        [self.food1 setImage:full forState:UIControlStateNormal];
        
        if (selected == 4){
            
            [self.food5 setImage:empty forState:UIControlStateNormal];

        }else if (selected == 3){
            
            [self.food5 setImage:empty forState:UIControlStateNormal];
            [self.food4 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 2){
            
            [self.food5 setImage:empty forState:UIControlStateNormal];
            [self.food4 setImage:empty forState:UIControlStateNormal];
            [self.food3 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 1){
            
            [self.food5 setImage:empty forState:UIControlStateNormal];
            [self.food4 setImage:empty forState:UIControlStateNormal];
            [self.food3 setImage:empty forState:UIControlStateNormal];
            [self.food2 setImage:empty forState:UIControlStateNormal];
        }
        
        
    }else if ([row isEqualToString:@"service"]){
        
        [self.service5 setImage:full forState:UIControlStateNormal];
        [self.service4 setImage:full forState:UIControlStateNormal];
        [self.service3 setImage:full forState:UIControlStateNormal];
        [self.service2 setImage:full forState:UIControlStateNormal];
        [self.service1 setImage:full forState:UIControlStateNormal];
        
        if (selected == 4){
            
            [self.service5 setImage:empty forState:UIControlStateNormal];
            
        }else if (selected == 3){
            
            [self.service5 setImage:empty forState:UIControlStateNormal];
            [self.service4 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 2){
            
            [self.service5 setImage:empty forState:UIControlStateNormal];
            [self.service4 setImage:empty forState:UIControlStateNormal];
            [self.service3 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 1){
            
            [self.service5 setImage:empty forState:UIControlStateNormal];
            [self.service4 setImage:empty forState:UIControlStateNormal];
            [self.service3 setImage:empty forState:UIControlStateNormal];
            [self.service2 setImage:empty forState:UIControlStateNormal];
        }
        
    }else if ([row isEqualToString:@"drinks"]){
        
        [self.drinks5 setImage:full forState:UIControlStateNormal];
        [self.drinks4 setImage:full forState:UIControlStateNormal];
        [self.drinks3 setImage:full forState:UIControlStateNormal];
        [self.drinks2 setImage:full forState:UIControlStateNormal];
        [self.drinks1 setImage:full forState:UIControlStateNormal];
        
        if (selected == 4){
            
            [self.drinks5 setImage:empty forState:UIControlStateNormal];
            
        }else if (selected == 3){
            
            [self.drinks5 setImage:empty forState:UIControlStateNormal];
            [self.drinks4 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 2){
            
            [self.drinks5 setImage:empty forState:UIControlStateNormal];
            [self.drinks4 setImage:empty forState:UIControlStateNormal];
            [self.drinks3 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 1){
            
            [self.drinks5 setImage:empty forState:UIControlStateNormal];
            [self.drinks4 setImage:empty forState:UIControlStateNormal];
            [self.drinks3 setImage:empty forState:UIControlStateNormal];
            [self.drinks2 setImage:empty forState:UIControlStateNormal];
        }
        
    }else if ([row isEqualToString:@"atmosphere"]){
        
        [self.atmosphere5 setImage:full forState:UIControlStateNormal];
        [self.atmosphere4 setImage:full forState:UIControlStateNormal];
        [self.atmosphere3 setImage:full forState:UIControlStateNormal];
        [self.atmosphere2 setImage:full forState:UIControlStateNormal];
        [self.atmosphere1 setImage:full forState:UIControlStateNormal];
        
        if (selected == 4){
            
            [self.atmosphere5 setImage:empty forState:UIControlStateNormal];
            
        }else if (selected == 3){
            
            [self.atmosphere5 setImage:empty forState:UIControlStateNormal];
            [self.atmosphere4 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 2){
            
            [self.atmosphere5 setImage:empty forState:UIControlStateNormal];
            [self.atmosphere4 setImage:empty forState:UIControlStateNormal];
            [self.atmosphere3 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 1){
            
            [self.atmosphere5 setImage:empty forState:UIControlStateNormal];
            [self.atmosphere4 setImage:empty forState:UIControlStateNormal];
            [self.atmosphere3 setImage:empty forState:UIControlStateNormal];
            [self.atmosphere2 setImage:empty forState:UIControlStateNormal];
        }
        
    }else{
        
        [self.value5 setImage:full forState:UIControlStateNormal];
        [self.value4 setImage:full forState:UIControlStateNormal];
        [self.value3 setImage:full forState:UIControlStateNormal];
        [self.value2 setImage:full forState:UIControlStateNormal];
        [self.value1 setImage:full forState:UIControlStateNormal];
        
        if (selected == 4){
            
            [self.value5 setImage:empty forState:UIControlStateNormal];
            
        }else if (selected == 3){
            
            [self.value5 setImage:empty forState:UIControlStateNormal];
            [self.value4 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 2){
            
            [self.value5 setImage:empty forState:UIControlStateNormal];
            [self.value4 setImage:empty forState:UIControlStateNormal];
            [self.value3 setImage:empty forState:UIControlStateNormal];
        }else if (selected == 1){
            
            [self.value5 setImage:empty forState:UIControlStateNormal];
            [self.value4 setImage:empty forState:UIControlStateNormal];
            [self.value3 setImage:empty forState:UIControlStateNormal];
            [self.value2 setImage:empty forState:UIControlStateNormal];
        }
        
    }
              
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    if ([self.commentsText.text isEqualToString:@"Additional Comments: (+5pts)"]){
		self.commentsText.text = @"";
	}
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    self.view.frame = CGRectMake(0, -165, 320, 416);
    
    
    [UIView commitAnimations];
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
        
        if ([self.commentsText.text isEqualToString:@""]){
            self.commentsText.text = @"Additional Comments: (+5pts)";
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        
        self.view.frame = CGRectMake(0, 0, 320, 416);
        
        
        [UIView commitAnimations];
        
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}


- (IBAction)submitReview:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction)skipReview:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];

}
@end
