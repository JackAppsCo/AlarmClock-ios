//
//  VoiceRecordViewController.h
//  VoiceRecord
//
//  Created by Avinash on 10/5/10.
//  Copyright PocketPpl 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface VoiceRecordViewController : UIViewController <AVAudioRecorderDelegate, UITextFieldDelegate>
{
	IBOutlet UIProgressView *progressView;
	IBOutlet UILabel *lblStatusMsg;
	
    BOOL _soundRecorded;
    
	NSMutableDictionary *recordSetting;
	NSMutableDictionary *editedObject;
	AVAudioRecorder *recorder;
	
	SystemSoundID soundID;
	NSTimer *timer;
}

@property (strong, nonatomic) AVAudioPlayer *aPlayer;
@property (strong, nonatomic) IBOutlet UIImageView *recordIconImageview;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) NSString *recorderFilePath;
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIButton *redoButton;
@property (strong, nonatomic) IBOutlet UIImageView *arrowImageView;

- (IBAction) startRecording;
- (IBAction) stopRecording;
- (IBAction)playSound;
- (void) handleTimer;
- (void) saveSound:(id)sender;
- (void) rerecordPressed:(id)sender;
@end

