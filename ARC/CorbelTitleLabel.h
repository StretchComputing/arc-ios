//
//  CorbelTitleLabel.h
//  ARC
//
//  Created by Nick Wroblewski on 9/12/12.
//
//

#import <UIKit/UIKit.h>

@interface CorbelTitleLabel : UILabel

-(id)initWithText:(NSString *)labelTitle;
@property (nonatomic, strong) NSString *theTitle;
@end
