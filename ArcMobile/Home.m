//
//  Home.m
//  ArcMobile
//
//  Created by Nick Wroblewski on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Home.h"
#import "Restaurant.h"

@interface Home ()

@end

@implementation Home
@synthesize selectButton;
@synthesize myTableView, restaurantNames;


- (void)viewDidLoad
{
    self.title = @"ARC";
    
    self.restaurantNames = [NSArray arrayWithObjects:@"Petterino's", @"Untitled", @"McDonalds", @"Signature Room", nil];
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    self.myTableView.backgroundView = nil;
    self.myTableView.backgroundColor = [UIColor clearColor];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setMyTableView:nil];
    [self setSelectButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)selectAction:(id)sender {
    
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	
	return [self.restaurantNames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
    static NSString *FirstLevelCell=@"FirstLevelCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FirstLevelCell];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier: FirstLevelCell];
	}
    
	
	//Configure the cell
	NSUInteger row = [indexPath row];
	
    if ([self.restaurantNames count] == 0) {
        
        cell.textLabel.text = @"No restaurants found...";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.font = [UIFont fontWithName:@"Verdana" size:14];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }else {
        
        NSString *name = [self.restaurantNames objectAtIndex:row];
        
        cell.textLabel.text = name;
        
    }
		
		
		
	
	
	
	return cell;
	

    
	
}





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSUInteger row = [indexPath row];
    
    Restaurant *restOne = [[Restaurant alloc] init];
    restOne.name = [self.restaurantNames objectAtIndex:row];
    
    [self.navigationController pushViewController:restOne animated:YES];
    
    
}


@end
