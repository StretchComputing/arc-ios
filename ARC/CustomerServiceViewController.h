//
//  CustomerServiceViewController.h
//  ARC
//
//  Created by Nick Wroblewski on 2/21/13.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "CorbelTextView.h"

@interface CustomerServiceViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate> 


@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *myPlayer;
@property (nonatomic, strong) NSURL *temporaryRecFile;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
- (IBAction)recordAction;

@property BOOL isRecording;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property (nonatomic, strong) NSData *recordedData;
- (IBAction)sendAction;
@property (strong, nonatomic) IBOutlet UILabel *recordingLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *recordingActivity;
@property (strong, nonatomic) IBOutlet CorbelTextView *sendLabel;

@property (strong, nonatomic) IBOutlet UILabel *displayLabel;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *sendingActivity;

@end
