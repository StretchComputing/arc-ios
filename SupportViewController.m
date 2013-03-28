//
//  SupportViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 3/27/13.
//
//

#import "SupportViewController.h"
#import "MFSideMenu.h"
#import "CorbelBoldLabel.h"
#import "rSkybox.h"
#import <QuartzCore/QuartzCore.h>

@interface SupportViewController ()

@end

@implementation SupportViewController

-(void)viewDidLoad{
    self.topLineView.layer.shadowOffset = CGSizeMake(0, 1);
    self.topLineView.layer.shadowRadius = 1;
    self.topLineView.layer.shadowOpacity = 0.5;
    
    self.backView.layer.cornerRadius = 7.0;

}

- (IBAction)openMenuAction {
    [self.navigationController.sideMenu toggleLeftSideMenu];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    @try {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell"];
        
        
        CorbelBoldLabel *supportLabel = (CorbelBoldLabel *)[cell.contentView viewWithTag:1];
        
        
        
        
        if (indexPath.row == 0) {
            supportLabel.text = @"Help Videos";
        }else{
            supportLabel.text = @"Customer Service";
            
        }
        
        
        
        
        
        return cell;
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SupportViewController.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)viewDidUnload {
    [self setBackView:nil];
    [self setTopLineView:nil];
    [super viewDidUnload];
}
@end
