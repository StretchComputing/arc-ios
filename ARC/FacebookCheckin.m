//
//  FacebookCheckin.m
//  ARC
//
//  Created by Nick Wroblewski on 11/30/12.
//
//

#import "FacebookCheckin.h"
#import <Social/Social.h>

@implementation FacebookCheckin


-(void)checkInAtLocationWithId:(NSString *)locationId{
    
    //change
    @try {
        self.store = [[ACAccountStore alloc] init];
        
        ACAccountType *accType = [self.store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"515025721859862", ACFacebookAppIdKey,
                                        [NSArray arrayWithObjects:@"publish_checkins", nil], ACFacebookPermissionsKey, ACFacebookAudienceFriends, ACFacebookAudienceKey, nil];
        
        
        [self.store requestAccessToAccountsWithType:accType options:options completion:^(BOOL granted, NSError *error) {
            if (granted && error == nil) {
                //NSLog(@"Granted");
                
                NSArray *accounts = [self.store accountsWithAccountType:accType];
                ACAccount *facebookAccount = [accounts objectAtIndex:0];
                
    
                NSString *post = [NSString stringWithFormat:@"I just made a purchase at %@ with dutch!", [[NSUserDefaults standardUserDefaults] valueForKey:@"merchantName"]];
             
                
                
                NSDictionary *parameters = @{@"message": post};
                
                NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/feed/"];
                
                SLRequest *feedRequest = [SLRequest
                                          requestForServiceType:SLServiceTypeFacebook
                                          requestMethod:SLRequestMethodPOST
                                          URL:feedURL
                                          parameters:parameters];
                
                feedRequest.account = facebookAccount;
                
                [feedRequest performRequestWithHandler:^(NSData *responseData,
                                                         NSHTTPURLResponse *urlResponse, NSError *error)
                 {
                     // Handle response
                     NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
                     if (output) {
                         
                     }
                     //NSLog(@"Output: %@", output);
                     
                 }];
                
                
                
            } else {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                [prefs setValue:@"no" forKey:@"autoPostFacebook"];
                [prefs synchronize];
                //
                //NSLog(@"Error: %@", [error description]);
                //NSLog(@"Access denied");
            }
        }];
        
    }
    
    @catch (NSException *exception) {
        
    }

    
}

@end
