//
//  PaymentHistoryViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 10/14/13.
//
//

#import "PaymentHistoryViewController.h"
#import "ArcClient.h"
#import "rSkybox.h"
#import "SteelfishLabel.h"
#import "ISO8601DateFormatter.h"
#import "PaymentHistoryDetail.h"

@interface PaymentHistoryViewController ()

@end

@implementation PaymentHistoryViewController



- (void)viewDidLoad
{
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    footer.backgroundColor = [UIColor darkGrayColor];
    self.myTableView.tableFooterView = footer;
    
    self.loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loadingView"];
    self.loadingViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    [self.loadingViewController stopSpin];
    [self.view addSubview:self.loadingViewController.view];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    self.loadingViewController.displayText.text = @"Loading Payments...";
    [self.loadingViewController startSpin];
    
    
    ArcClient *tmp = [[ArcClient alloc] init];
    [tmp getListOfPayments];
    
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paymentHistoryComplete:) name:@"paymentHistoryNotification" object:nil];
    
    
   
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)paymentHistoryComplete:(NSNotification *)notification{
    @try {
        
        
        self.loadingViewController.view.hidden = YES;
        NSDictionary *responseInfo = [notification valueForKey:@"userInfo"];
        
        NSLog(@"Response Info: %@", responseInfo);
        
        NSString *status = [responseInfo valueForKey:@"status"];
        
        
        NSString *errorMsg = @"";
        if ([status isEqualToString:@"success"]) {
            
            self.paymentsArray = [NSMutableArray arrayWithArray:[[responseInfo valueForKey:@"apiResponse"] valueForKey:@"Results"]];
            
            NSLog(@"Count: %d", [self.paymentsArray count]);
            
            if ([self.paymentsArray count] > 0) {
                [self.myTableView reloadData];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Payments Found" message:@"No payments were found in your history." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
            
            
            
        } else if([status isEqualToString:@"error"]){
            
            errorMsg = ARC_ERROR_MSG;
            
        } else {
            // must be failure -- user notification handled by ArcClient
            errorMsg = ARC_ERROR_MSG;
        }
        
        if([errorMsg length] > 0) {
            //self.errorLabel.text = errorMsg;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payments Error" message:@"We experienced an error loading your payment history, please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"PaymentHistoryViewController.signInComplete" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
        
    }
    
}


//TableMethods


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        
        NSUInteger row = [indexPath row];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"paymentCell"];

        SteelfishBoldLabel *merchantNameLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:1];
        SteelfishLabel *dateLabel = (SteelfishLabel *)[cell.contentView viewWithTag:2];
        SteelfishBoldLabel *amountLabel = (SteelfishBoldLabel *)[cell.contentView viewWithTag:3];
        SteelfishLabel *invoiceNumberLabel = (SteelfishLabel *)[cell.contentView viewWithTag:4];

        
        if ([self.paymentsArray count] > 0) {
            
            NSDictionary *payment = [self.paymentsArray objectAtIndex:row];
            
            merchantNameLabel.text = [payment valueForKey:@"Merchant"];
            dateLabel.text = [self dateStringFromISO:[payment valueForKey:@"DateCreated"]];
            
            double amount = [[payment valueForKey:@"Amount"] doubleValue];
            double tip = [[payment valueForKey:@"Gratuity"] doubleValue];
            double total = amount + tip;
            
            amountLabel.text = [NSString stringWithFormat:@"$%.2f", total];
            invoiceNumberLabel.text = [NSString stringWithFormat:@"Check #: %@", [payment valueForKey:@"Number"]];

        }
    
        return cell;
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"PaymentHistoryViewController.tableView" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 64;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
  
    if ([self.paymentsArray count] > 0) {
        self.selectedRow = indexPath.row;
        
        [self performSegueWithIdentifier:@"goDetail" sender:self];
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        
        if ([[segue identifier] isEqualToString:@"goDetail"]) {
            
            PaymentHistoryDetail *next = [segue destinationViewController];
            next.paymentDictionary = [self.paymentsArray objectAtIndex:self.selectedRow];
          
        }
        
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"PaymentHistoryViewController.prepareForSegue" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.paymentsArray count];
}


-(NSString *)dateStringFromISO:(NSString *)myDate{
    //2013-10-13T21:50:26.81
    
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    NSDate *theDate = [formatter dateFromString:myDate];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd hh:mma"];
    NSString *newDate = [dateFormat stringFromDate:theDate];
    
    return newDate;
}
@end
