//
//  EditServerController.m
//  ARC
//
//  Created by Nick Wroblewski on 11/8/12.
//
//

#import "EditServerController.h"
#import "rSkybox.h"
#import "ArcClient.h"
#import <QuartzCore/QuartzCore.h>
@interface EditServerController ()

@end

@implementation EditServerController

-(void)viewDidLoad{
    
    CorbelTitleLabel *navLabel = [[CorbelTitleLabel alloc] initWithText:@"Edit Server"];
    self.navigationItem.titleView = navLabel;
    
    self.toolbar.tintColor = [UIColor colorWithRed:21.0/255.0 green:80.0/255.0  blue:125.0/255.0 alpha:1.0];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setServerComplete:) name:@"setServerNotification" object:nil];
    
    ArcClient *tmp = [[ArcClient alloc] init];
    NSString *server = [tmp getCurrentUrl];
    
    if ([server rangeOfString:@"arc.dagher.mobi"].location != NSNotFound) {
        self.currentServer = 1;
    }else if ([server rangeOfString:@"arc.dagher.net.co"].location != NSNotFound){
        self.currentServer = 2;
    }else if ([server rangeOfString:@"arc-dev.dagher.mobi"].location != NSNotFound){
        self.currentServer = 5;
    }else if (([server rangeOfString:@"dtnetwork.dyndns"].location != NSNotFound) || ([server rangeOfString:@"68.57.205.193:8700"].location != NSNotFound)){
        self.currentServer = 8;
    }
    
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    self.view.backgroundColor = [UIColor clearColor];
    UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

-(void)cancel{
    [self dismissModalViewControllerAnimated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        NSUInteger row = [indexPath row];
        
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"serverCell"];

        UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
        UIImageView *checkImage = (UIImageView *)[cell.contentView viewWithTag:2];
        
       
        checkImage.hidden = YES;
        if (row==0) {
            nameLabel.text = @"Production Cloud Server";
            if (self.currentServer == 1) {
                checkImage.hidden = NO;
            }
        }else if (row == 1){
            nameLabel.text = @"Backup Production Cloud Server";
            if (self.currentServer == 2) {
                checkImage.hidden = NO;
            }
        }else if (row == 2){
            nameLabel.text = @"Development Cloud Server";
            if (self.currentServer == 5) {
                checkImage.hidden = NO;
            }

        }else{
            nameLabel.text = @"Development Debug Server";
            if (self.currentServer == 8) {
                checkImage.hidden = NO;
            }

        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"EditServerController.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSUInteger row = [indexPath row];
    if (!self.isCallingServer) {
        
        int sendInt;
        
        if (row == 0) {
            sendInt = 1;
        }else if (row == 1){
            sendInt = 2;
        }else if (row == 2){
            sendInt = 5;
        }else{
            sendInt = 8;
        }
        
        [self makeServerCallWithNumber:sendInt];
    }
 
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 4;
}

-(void)makeServerCallWithNumber:(int)serverNumber{
    
    self.isCallingServer = YES;
    [self.activity startAnimating];
    ArcClient *tmp = [[ArcClient alloc] init];
    [tmp setServer:[NSString stringWithFormat:@"%d", serverNumber]];
}

-(void)setServerComplete:(NSNotification *)notification{
    @try {
        
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        NSString *status = [responseInfo valueForKey:@"status"];
       // NSDictionary *apiResponse = [responseInfo valueForKey:@"apiResponse"];
        
        [self.activity stopAnimating];
        self.isCallingServer = NO;
      
        
        if ([status isEqualToString:@"success"]) {
           
            ArcClient *tmp = [[ArcClient alloc] init];
            [tmp getServer];
            
            NSString *message = @"You are now pointing to the new server.";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [self dismissModalViewControllerAnimated:YES];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Set Server Failed" message:@"Failed to set server" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"EditServerController.setServerComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


@end
