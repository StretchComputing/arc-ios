//
//  SteelfishTitleLabel.h
//  ARC
//
//  Created by Nick Wroblewski on 8/8/13.
//
//

#import <UIKit/UIKit.h>

@interface SteelfishTitleLabel : UILabel


-(id)initWithText:(NSString *)labelTitle;
@property (nonatomic, strong) NSString *theTitle;

@end
