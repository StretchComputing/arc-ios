#import <UIKit/UIKit.h>
#import "SMContactsSelector.h"
#import "CorbelTextView.h"
#import "iCarousel.h"
#import "CorbelBoldLabel.h"
#import "NVUIGradientButton.h"

@interface HomeNew : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SMContactsSelectorDelegate, iCarouselDataSource, iCarouselDelegate, UISearchBarDelegate>

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property BOOL successReview;
@property BOOL skipReview;
@property BOOL isGettingMerchantList;
- (IBAction)checkNumberDown;

@property BOOL didShowPayment;
@property (strong, nonatomic) IBOutlet UIView *checkNumberView;
@property (strong, nonatomic) IBOutlet UIImageView *checkImage;
- (IBAction)searchAction;

@property (nonatomic, strong) IBOutlet UIView *hintOverlayView;
@property (strong, nonatomic) IBOutlet CorbelTextView *overlayTextView;
- (IBAction)valueChanged;
-(IBAction)textFieldDidChange;
@property int retryCount;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *sloganLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *restaurantSegment;
@property (strong, nonatomic) IBOutlet UIView *roundView;
@property (nonatomic, strong) IBOutlet UIView *borderLine1;
@property (nonatomic, strong) IBOutlet UIView *borderLine2;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *payBillButton;
- (IBAction)payBillAction;
@property (strong, nonatomic) IBOutlet NVUIGradientButton *moreInfoButton;
- (IBAction)moreInfoAction:(id)sender;

@property (nonatomic, strong) IBOutlet UIImageView *topImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activity;
- (IBAction)searchCancelAction;

@property (strong, nonatomic) IBOutlet UIButton *searchCancelButton;
@property BOOL isDragging;
@property BOOL isLoading;
@property BOOL shouldCallStop;
@property BOOL isIos6;
@property (nonatomic, weak) IBOutlet UIButton *refreshListButton;
@property (strong, nonatomic) IBOutlet CorbelBoldLabel *placeNameLabel;
@property (strong, nonatomic) IBOutlet CorbelBoldLabel *placeAddressLabel;

@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) NSMutableData *serverData;

@property (nonatomic, strong) NSMutableArray *allMerchants;
@property (nonatomic, strong) NSMutableArray *matchingMerchants;

@property (nonatomic, strong) IBOutlet UITableView *myTableView;
- (IBAction)refreshMerchants:(id)sender;

-(IBAction)endText;
-(IBAction)inviteFriend;

@property BOOL isRotary;
@property (nonatomic, weak) IBOutlet UITextField *searchTextField;
-(IBAction)menuAction;

@property (nonatomic, strong) UIView *refreshHeaderView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UIImageView *refreshArrow;
@property (nonatomic, strong) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, strong) NSString *textPull;
@property (nonatomic, strong) NSString *textRelease;
@property (nonatomic, strong) NSString *textLoading;
-(IBAction)refreshList;

@property (nonatomic, strong) NSMutableArray *multipleEmailArray;

//-(void)hideAlert;

-(IBAction)searchEditDidBegin;

@property (nonatomic, strong) UIView *enterCheckNumberView;
//Carousel

@property (nonatomic, assign) BOOL wrap;
@property (nonatomic, retain) NSMutableArray *items;

@property (nonatomic, retain) IBOutlet iCarousel *carousel;
@property (nonatomic, retain) IBOutlet UINavigationItem *navItem;
@property (nonatomic, retain) IBOutlet UIBarItem *orientationBarItem;
@property (nonatomic, retain) IBOutlet UIBarItem *wrapBarItem;
@property (nonatomic, retain) IBOutlet UISlider *arcSlider;
@property (nonatomic, retain) IBOutlet UISlider *radiusSlider;
@property (nonatomic, retain) IBOutlet UISlider *tiltSlider;
@property (nonatomic, retain) IBOutlet UISlider *spacingSlider;


//- (IBAction)switchCarouselType;
//- (IBAction)toggleOrientation;
//- (IBAction)toggleWrap;
//- (IBAction)insertItem;
//- (IBAction)removeItem;
- (IBAction)reloadCarousel;


@property (nonatomic, strong) IBOutlet UIButton *menuButton;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *searchButton;
@property (nonatomic, strong) IBOutlet UIView *wholeCheckNumberView;
-(IBAction)menuBackAction;


@end