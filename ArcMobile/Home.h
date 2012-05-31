//
//  Home.h
//  ArcMobile
//
//  Created by Nick Wroblewski on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Home : UIViewController <UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong) NSArray *restaurantNames;

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
- (IBAction)selectAction:(id)sender;

@end
