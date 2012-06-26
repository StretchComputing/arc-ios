//
//  Register.m
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Register.h"

@interface Register ()

@end

@implementation Register
@synthesize myTableView;


- (void)viewDidLoad
{
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	static NSString *FirstLevelCell=@"FirstLevelCell";
	
	static NSInteger fieldTag = 1;
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FirstLevelCell];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier: FirstLevelCell];
		
		CGRect frame;
		frame.origin.x = 10;
		frame.origin.y = 6;
		frame.size.height = 22;
		frame.size.width = 80;
		
		UILabel *fieldLabel = [[UILabel alloc] initWithFrame:frame];
		fieldLabel.tag = fieldTag;
		[cell.contentView addSubview:fieldLabel];
		
        
	}
	
	UILabel *fieldLabel = (UILabel *)[cell.contentView viewWithTag:fieldTag];
	
	fieldLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
	fieldLabel.textColor = [UIColor blackColor];
	fieldLabel.backgroundColor = [UIColor clearColor];
	NSUInteger row = [indexPath row];
    
    
	if (row == 0) {
		fieldLabel.text = @"Email";
		
        
        cell.isAccessibilityElement = YES;
        cell.accessibilityLabel = @"user name";
	}else if (row == 1){
		fieldLabel.text = @"Password";
        
        cell.isAccessibilityElement = YES;
        cell.accessibilityLabel = @"pass word";
	}
    
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return @"Personal Information";
}

- (IBAction)login:(UIBarButtonItem *)sender {
    [self dismissModalViewControllerAnimated:YES];
}


@end
