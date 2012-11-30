//
//  ReferFriendViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 11/29/12.
//
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ReferFriendViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate>
- (IBAction)endText;
- (IBAction)submit;
- (IBAction)addContact;
- (IBAction)cancelRefer:(id)sender;

@property (nonatomic, strong) IBOutlet UITextField *emailAddress;
@property (nonatomic, strong) NSMutableArray *multipleEmailArray;
@property (nonatomic, strong) NSMutableArray *multipleEmailArrayLabels;



@property (nonatomic, strong) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activity;

@end
