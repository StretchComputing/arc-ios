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
#import "NewJSON.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize navBar;
@synthesize signInButton;
@synthesize myTableView, username, password, serverData, errorLabel, activity;


-(void)viewDidAppear:(BOOL)animated{

   
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *customerId = [prefs stringForKey:@"customerId"];
    NSString *customerToken = [prefs stringForKey:@"customerToken"];
        
    if (![customerId isEqualToString:@""] && (customerId != nil) && ![customerToken isEqualToString:@""] && (customerToken != nil)) {

        [self performSegueWithIdentifier: @"signIn" sender: self];

    }
    
    

    
}
-(void)viewWillAppear:(BOOL)animated{
    self.errorLabel.text = @"";
    [self.username becomeFirstResponder];
    
    AppDelegate *mainDelegate = [[UIApplication sharedApplication] delegate];
    if ([mainDelegate.logout isEqualToString:@"true"]) {
       
        mainDelegate.logout = @"false";
        self.username.text = @"";
        self.password.text = @"";
        
    }
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
    self.username.keyboardType = UIKeyboardTypeEmailAddress;
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
    
    [self performSelector:@selector(runRegister)];
   
   
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



-(void)runRegister{
    
    self.errorLabel.text = @"";
    
    if ([self.username.text isEqualToString:@""] || [self.password.text isEqualToString:@""]) {
        self.errorLabel.text = @"*Please enter your email and password.";
    }else{
        
        @try{
            
            NSString *tmpUrl = [NSString stringWithFormat:@"http://68.57.205.193:8700/rest/v1/customers?login=%@&password=%@", self.username.text, self.password.text];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:tmpUrl]];
            [request setHTTPMethod: @"GET"];
            
            [self.activity startAnimating];
            self.serverData = [NSMutableData data];
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate: self startImmediately: YES];
            
        }
        @catch (NSException *e) {
            
            //[rSkybox sendClientLog:@"getInvoiceFromNumber" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
            
        }

        
    }
    
       
    
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)mdata {
    [self.serverData appendData:mdata]; 
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [self.activity stopAnimating];
    NSData *returnData = [NSData dataWithData:self.serverData];
    
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
    NewSBJSON *jsonParser = [NewSBJSON new];
    NSDictionary *response = (NSDictionary *) [jsonParser objectWithString:returnString error:NULL];
    
    BOOL success = [[response valueForKey:@"Success"] boolValue];
    
    if (success){
        
    
        
        NSDictionary *customer = [response valueForKey:@"Customer"];
        
        NSString *customerId = [customer valueForKey:@"Id"];
        NSString *customerToken = [customer valueForKey:@"Token"];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        [prefs setObject:customerId forKey:@"customerId"];
        [prefs setObject:customerToken forKey:@"customerToken"];
        
        [prefs synchronize];
        
        
        [self performSegueWithIdentifier: @"signIn" sender: self];
        
        //Do the next thing (go home?)
        
    }else{
        
        self.errorLabel.text = @"*Invalid email/password.";
        
    }
    
    
   	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [self.activity stopAnimating];
    self.errorLabel.text = @"*Error logging, please try again.";
}


@end
