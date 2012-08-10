//
//  AppDelegate.m
//  ARC
//
//  Created by Nick Wroblewski on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArcAppDelegate.h"
#import "CreditCard.h"
#import "FBEncryptorAES.h"

@implementation ArcAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   
    // Override point for customization after application launch.
    [self initManagedDocument];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)initManagedDocument{
    
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"DataBase"];
    
    self.managedDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]){
        
        [self.managedDocument openWithCompletionHandler:^(BOOL success){
            if (success) {
                [self documentIsReady];
            }else{
                NSLog(@"Could not open document");
            }
        }];
        
    }else{
        
        [self.managedDocument saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
           
            if (success) {
                [self documentIsReady];
            }else{
                NSLog(@"Could not create document");
            }
        }];
    }
}

-(void)documentIsReady{
    
    NSLog(@"Document is ready!!");
    
    if (self.managedDocument.documentState == UIDocumentStateNormal) {
        self.managedObjectContext = self.managedDocument.managedObjectContext;
    }
    
}

-(void)saveDocument{
    
    [self.managedDocument saveToURL:self.managedDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        
        if (!success) {
            NSLog(@"Failed to save");
        }else{
            NSLog(@"Saved Document Successfully");
        }
    }];
}

-(void)closeDocument{
    [self.managedDocument closeWithCompletionHandler:^(BOOL success){
       
        if (!success) {
            NSLog(@"Failed to close");
        }else{
            NSLog(@"Closed Document");
        }
    }];
}


-(void)insertCustomerWithId:(NSString *)customerId andToken:(NSString *)customerToken{
    
    @try {
        //Only inserts if one doesn't already exist
        Customer *customer = [self getCurrentCustomer];
        
        if (!customer) {
            NSLog(@"Inserting Customer");
            Customer *customer = [NSEntityDescription insertNewObjectForEntityForName:@"Customer" inManagedObjectContext:self.managedObjectContext];
            
            customer.customerId = customerId;
            customer.customerToken = customerToken;
            
            
            [self saveDocument];
            
        }else{
            NSLog(@"Customer Already Exists");
        }
    }
    @catch (NSException *exception) {
        
    }
  
  
    
    
}

-(void)insertCreditCardWithNumber:(NSString *)number andSecurityCode:(NSString *)securityCode andExpiration:(NSString *)expiration andPin:(NSString *)pin{
    

    @try {
        
        Customer *customer = [self getCurrentCustomer];
        
        CreditCard *creditCard = [NSEntityDescription insertNewObjectForEntityForName:@"CreditCard" inManagedObjectContext:self.managedObjectContext];
        
        NSString *sample = [NSString stringWithFormat:@"****%@", [number substringFromIndex:[number length]-4]];
        
        creditCard.expiration = expiration;
        creditCard.sample = sample;
        creditCard.number = [FBEncryptorAES encryptBase64String:number keyString:pin separateLines:NO];
        creditCard.securityCode = [FBEncryptorAES encryptBase64String:securityCode keyString:pin separateLines:NO];
        creditCard.whoOwns = customer;
        
        [self saveDocument];
    }
    @catch (NSException *exception) {

    }
  
    
    
}

-(Customer *)getCurrentCustomer{
    
    @try {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSString *customerId = [prefs valueForKey:@"customerId"];
        NSString *customerToken = [prefs valueForKey:@"customerToken"];
        
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Customer"];
        request.predicate = [NSPredicate predicateWithFormat:@"(customerId == %@) AND (customerToken == %@)", customerId, customerToken];
        
        NSError *error;
        
        NSArray *returnedArray = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (returnedArray == nil) {
            NSLog(@"returnArray was NIL");
            return nil;
        }else if ([returnedArray count] == 0){
            
            return nil;
        }else{
            return (Customer *)[returnedArray objectAtIndex:0];
        }
    }
    @catch (NSException *exception) {
        return @[];
    }
   
    
}

-(NSArray *)getAllCreditCardsForCurrentCustomer{
    
  
    @try {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSString *customerId = [prefs valueForKey:@"customerId"];
        NSString *customerToken = [prefs valueForKey:@"customerToken"];
        
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CreditCard"];
        request.predicate = [NSPredicate predicateWithFormat:@"(whoOwns.customerId == %@) AND (whoOwns.customerToken == %@)", customerId, customerToken];
        
        NSError *error;
        
        NSArray *returnedArray = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (returnedArray == nil) {
            NSLog(@"returnArray was NIL");
            return nil;
        }else if ([returnedArray count] == 0){
            NSLog(@"Card Count was NIL");
            return nil;
        }else{
            NSLog(@"Card retreival was GOOD!!!");
            return returnedArray;
        }
        
    }
    @catch (NSException *exception) {
        return @[];
    }
   
    
}


-(NSArray *)getCreditCardWithNumber:(NSString *)number andSecurityCode:(NSString *)securityCode andExpiration:(NSString *)expiration{
    
    @try {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CreditCard"];
        request.predicate = [NSPredicate predicateWithFormat:@"(number == %@) AND (securityCode == %@) AND (expiration == %@)", number, securityCode, expiration];
        
        NSError *error;
        
        NSArray *returnedArray = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (returnedArray == nil) {
            NSLog(@"returnArray was NIL");
            return nil;
        }else if ([returnedArray count] == 0){
            NSLog(@"Card Count was NIL");
            return nil;
        }else{
            NSLog(@"Card retreival was GOOD!!!");
            return returnedArray;
        }
        
    }
    @catch (NSException *exception) {
        return @[];
    }
    
}


-(void)deleteCreditCardWithNumber:(NSString *)number andSecurityCode:(NSString *)securityCode andExpiration:(NSString *)expiration{
    
    @try {
        NSArray *tmp = [self getCreditCardWithNumber:number andSecurityCode:securityCode andExpiration:expiration];
        
        if ([tmp count] > 0){
            
            CreditCard *tmpCard = [tmp objectAtIndex:0];
            
            [self.managedObjectContext deleteObject:tmpCard];
            
            [self saveDocument];
        }
    }
    @catch (NSException *exception) {
        
    }
  
}

-(NSString *)getCustomerId{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    return [prefs valueForKey:@"customerId"];
        
}

-(NSString *)getCustomerToken{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    return [prefs valueForKey:@"customerToken"];
    
}

@end
