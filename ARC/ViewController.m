//
//  ViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "Home.h"
#import "HomeNavigationController.h"
@interface ViewController ()

@end

@implementation ViewController
@synthesize navBar;
@synthesize signInButton;
@synthesize myTableView, username, password;


-(void)viewWillAppear:(BOOL)animated{
    [self.username becomeFirstResponder];
}

-(void)selectPassword{
    [self.password becomeFirstResponder];
}

- (void)viewDidLoad
{
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    self.username = [[UITextField alloc] initWithFrame:CGRectMake(95, 8, 205, 20)];
    self.username.autocorrectionType = UITextAutocorrectionTypeNo;
    self.username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.username.font = [UIFont fontWithName:@"Helvetica" size:14];
    self.username.returnKeyType = UIReturnKeyNext;
    [self.username addTarget:self action:@selector(selectPassword) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    self.password = [[UITextField alloc] initWithFrame:CGRectMake(95, 8, 205, 20)];
    self.password.autocorrectionType = UITextAutocorrectionTypeNo;
    self.password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.password.secureTextEntry = YES;
    self.password.font = [UIFont fontWithName:@"Helvetica" size:14];
    self.password.returnKeyType = UIReturnKeyGo;
    [self.password addTarget:self action:@selector(signIn) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    self.username.text = @"";
    self.password.text = @"";
    
    self.username.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.password.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.navBar.tintColor = [UIColor colorWithRed:0.0427221 green:0.380456 blue:0.785953 alpha:1.0];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)signIn{
    
    // - 0.0427221 0.380456 0.785953 1
    //[self.signInButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    //HomeNavigationController *tmp = [[HomeNavigationController alloc] init];
    //[self presentModalViewController:tmp animated:YES];
    
    
    [self performSegueWithIdentifier: @"signIn" sender: self];
   
   
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
		
		[cell.contentView addSubview:self.username];
        
        cell.isAccessibilityElement = YES;
        cell.accessibilityLabel = @"user name";
	}else if (row == 1){
		fieldLabel.text = @"Password";
		[cell.contentView addSubview:self.password];
        
        cell.isAccessibilityElement = YES;
        cell.accessibilityLabel = @"pass word";
	}
    
	[self.username becomeFirstResponder];
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

- (void)viewDidUnload {
    [self setNavBar:nil];
    [super viewDidUnload];
}
@end
