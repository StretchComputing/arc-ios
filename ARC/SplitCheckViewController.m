//
//  SplitCheckViewController.m
//  ARC
//
//  Created by Nick Wroblewski on 8/15/12.
//
//

#import "SplitCheckViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "rSkybox.h"

@interface SplitCheckViewController ()

@end

@implementation SplitCheckViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    @try {
        [rSkybox addEventToSession:@"signInComplete"];
        
        self.dollarView.hidden = NO;
        self.percentView.hidden = YES;
        self.itemView.hidden = YES;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.view.bounds;
        self.view.backgroundColor = [UIColor clearColor];
        UIColor *myColor = [UIColor colorWithRed:114.0/255.0 green:168.0/255.0 blue:192.0/255.0 alpha:1.0];
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[myColor CGColor], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
        
        double amountPaid = [self calculateAmountPaid];
        double amountDue = self.myInvoice.baseAmount - amountPaid;
        self.dollarTotalBillLabel.text = [NSString stringWithFormat:@"$%.2f", self.myInvoice.baseAmount];
        self.dollarAmountPaidLabel.text = [NSString stringWithFormat:@"$%.2f", amountPaid];
        self.dollarAmountDueLabel.text = [NSString stringWithFormat:@"$%.2f", amountDue];
        
        //@property (weak, nonatomic) IBOutlet UILabel *dollarTotalBillNameLabel;
        //@property (weak, nonatomic) IBOutlet UILabel *dollarTotalBillLabel;
        //@property (weak, nonatomic) IBOutlet UILabel *dollarAmountPaidNameLabel;
        //@property (weak, nonatomic) IBOutlet UILabel *dollarAmountPaidLabel;
        //@property (weak, nonatomic) IBOutlet UILabel *dollarAmountDueNameLabel;
        //@property (weak, nonatomic) IBOutlet UILabel *dollarAmountDueLabel;


        
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
        self.dollarView.backgroundColor = [UIColor clearColor];
        self.percentView.backgroundColor = [UIColor clearColor];
        self.itemView.backgroundColor = [UIColor clearColor];
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }

}

- (void)viewDidUnload
{
    [self setPercentView:nil];
    [self setDollarView:nil];
    [self setItemView:nil];
    [self setTypeSegment:nil];
    [self setTypeSegment:nil];
    [self setDollarTotalBillNameLabel:nil];
    [self setDollarTotalBillLabel:nil];
    [self setDollarAmountPaidNameLabel:nil];
    [self setDollarAmountPaidLabel:nil];
    [self setDollarAmountDueNameLabel:nil];
    [self setDollarAmountDueLabel:nil];
    [self setDollarYourPaymentNameLabel:nil];
    [self setDollarYourPaymentText:nil];
    [self setDollarTipText:nil];
    [self setDollarTipSegment:nil];
    [self setDollarYourTotalPaymentLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)typeSegmentChanged {
    @try {
        if (self.typeSegment.selectedSegmentIndex == 0) {
            
            self.dollarView.hidden = NO;
            self.percentView.hidden = YES;
            self.itemView.hidden = YES;
            
        }else if (self.typeSegment.selectedSegmentIndex == 1){
            
            self.dollarView.hidden = YES;
            self.percentView.hidden = NO;
            self.itemView.hidden = YES;
            
        }else{
            
            self.dollarView.hidden = YES;
            self.percentView.hidden = YES;
            self.itemView.hidden = NO;
            
        }
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"SplitCheckViewController.viewDidLoad" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
        
    }
    
}

-(void)endText{
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.dollarView.frame = CGRectMake(0, 44, 320, 328);
        self.percentView.frame = CGRectMake(0, 44, 320, 328);
    }];
    
}

- (IBAction)dollarTipDidBegin {
    [rSkybox addEventToSession:@"dollarTipDidBegin"];
    
    [UIView animateWithDuration:0.3 animations:^{
       
        self.dollarView.frame = CGRectMake(0, -120, 320, 328);
    }];
}

- (IBAction)percentTipDidBegin {
    [rSkybox addEventToSession:@"percentTipDidBegin"];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.percentView.frame = CGRectMake(0, -120, 320, 328);
    }];
}
- (IBAction)dollarEditBegin:(id)sender {
}

- (IBAction)dollarEditEnd:(id)sender {
}

- (IBAction)dollarTipSegmentSelect:(id)sender {
    @try {
        //::nick -- what does this do?
        [self performSelector:@selector(resetSegment) withObject:nil afterDelay:0.2];
        
        double tipPercent = 0.0;
        if (self.dollarTipSegment.selectedSegmentIndex == 0) {
            tipPercent = .10;
        }else if (self.dollarTipSegment.selectedSegmentIndex == 1){
            tipPercent = .15;
        }else{
            tipPercent = .20;
        }
        
        double yourPayment = [self.dollarYourPaymentText.text doubleValue];
        double tipAmount = tipPercent * yourPayment;
        self.dollarTipText.text = [NSString stringWithFormat:@"%.2f", tipAmount];
        self.dollarYourTotalPaymentLabel.text = [NSString stringWithFormat:@"Your Total Payment: $%.2f", yourPayment + tipAmount];
        
        //::nick?
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        
        //::nick?
        self.view.frame = CGRectMake(0, 0, 320, 416);
        [self.dollarTipText resignFirstResponder];
        
        [UIView commitAnimations];
        
    }
    @catch (NSException *e) {
        [rSkybox sendClientLog:@"InvoiceView.segmentSelect" logMessage:@"Exception Caught" logLevel:@"error" exception:e];
    }

}

- (IBAction)dollarPayNow:(id)sender {
}

//::nick::todo what happens if Amount cannot be converted to a float?
- (double)calculateAmountPaid {
    double amountPaid = 0.0;
    double paymentAmount = 0.0;
    for (int i = 0; i < [self.myInvoice.payments count]; i++) {
        NSDictionary *paymentDictionary = [self.myInvoice.payments objectAtIndex:i];
        paymentAmount = [[paymentDictionary valueForKey:@"Amount"] doubleValue];
        amountPaid += paymentAmount;
    }
    return amountPaid;
}

- (IBAction)dollarTipSegmentSelect {
    
       
}

-(void)resetSegment{
    self.dollarTipSegment.selectedSegmentIndex = -1;
}

@end
