//
//  VoiceRecordViewController.m
//  VoiceRecord
//
//  Created by Avinash on 10/5/10.
//  Copyright PocketPpl 2010. All rights reserved.
//

#import "VoiceRecordViewController.h"
#import "JASound.h"
#import "JASettings.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]


@implementation VoiceRecordViewController

@synthesize recorderFilePath, aPlayer;

- (void)viewDidLoad
{
	[super viewDidLoad];
    self.title = @"Record"; 
	lblStatusMsg.text = @"Ready";
	progressView.progress = 0.0;
    _soundRecorded = NO;
    
    //setup buttons
    [self.saveButton addTarget:self action:@selector(saveSound:) forControlEvents:UIControlEventTouchUpInside];
    [self.redoButton addTarget:self action:@selector(rerecordPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //make text field first responder
    [self.nameField becomeFirstResponder];
    
    
    
}

- (void) rerecordPressed:(id)sender
{
    _soundRecorded = NO;
    [self setupView];
}

- (void) handleTimer
{
	progressView.progress += .0066;
	if(progressView.progress == 1.0)
	{
        if ([timer isValid])
            [timer invalidate];
		lblStatusMsg.text = @"Stopped";
	}
}

- (void)setupView
{
    [UIView animateWithDuration:0.15f
                     animations:^{
                         
                         //enable and disable buttons
                         if (self.nameField.text.length > 0) {
                             self.startButton.enabled = YES;
                             [self.recordIconImageview setHighlighted:YES];
                         }
                         else {
                             [self.recordIconImageview setHighlighted:NO];
                         }
                         
                         if (_soundRecorded) {
                             self.playButton.enabled = YES;
                             self.saveButton.enabled = YES;
                             self.redoButton.enabled = YES;
                             self.startButton.enabled = YES;
                             
                         }
                         else {
                             self.playButton.enabled = NO;
                             self.saveButton.enabled = NO;
                             self.redoButton.enabled = NO;
                             
                         }
                         
                         //update the rec button
                         if (recorder.isRecording) {
                             [self.startButton setTitle:@"Stop" forState:UIControlStateNormal];
                             [self.startButton removeTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchUpInside];
                             [self.startButton addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
                         }
                         else if (_soundRecorded) {
                             [self.startButton setTitle:@"Play" forState:UIControlStateNormal];
                             [self.startButton removeTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
                             [self.startButton addTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
                         }
                         else {
                             [self.startButton setTitle:@"Start Recording" forState:UIControlStateNormal];
                             [self.startButton removeTarget:self action:@selector(playSound) forControlEvents:UIControlEventTouchUpInside];
                             [self.startButton addTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchUpInside];
                             [lblStatusMsg setText:@"Ready"];
                             [progressView setProgress:0.0f];
                         }
                         
                         self.arrowImageView.alpha = 0.0;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         //move arrow
                         if (self.nameField.isFirstResponder) {
                             self.arrowImageView.center = CGPointMake(self.arrowImageView.center.x, self.nameField.center.y);
                         }
                         else if (self.nameField.text.length > 0 && !_soundRecorded) {
                             self.arrowImageView.center = CGPointMake(self.arrowImageView.center.x, self.startButton.center.y);
                         }
                         else {
                             self.arrowImageView.center = CGPointMake(self.arrowImageView.center.x, self.saveButton.center.y);
                         }
                         
                         [UIView animateWithDuration:0.15
                                          animations:^{
                                              
                                              self.arrowImageView.alpha = 1.0f;
                                        
                                          }];
                         
                     }];
}

- (void)saveSound:(id)sender
{
    JASound *newSound = [[JASound alloc] init];
    newSound.name = self.nameField.text;
    newSound.soundFilename = recorderFilePath;
    [JASound saveSound:newSound];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) startRecording
{
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	NSError *err = nil;
	[audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
	if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
	}
	[audioSession setActive:YES error:&err];
	err = nil;
	if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
	}
	
	recordSetting = [[NSMutableDictionary alloc] init];
	
	// We can use kAudioFormatAppleIMA4 (4:1 compression) or kAudioFormatLinearPCM for nocompression
	[recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
    
	// We can use 44100, 32000, 24000, 16000 or 12000 depending on sound quality
	[recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
	
	// We can use 2(if using additional h/w) or 1 (iPhone only has one microphone)
	[recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
	
	// These settings are used if we are using kAudioFormatLinearPCM format
	//[recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
	//[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
	//[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
	
	
	
	// Create a new dated file
	//NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    //	NSString *caldate = [now description];
    //	recorderFilePath = [[NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, caldate] retain];
	recorderFilePath = [[NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, self.nameField.text] retain];
	
	NSLog(@"recorderFilePath: %@",recorderFilePath);
	
	NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
	
	err = nil;
	
	NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
	if(audioData)
	{
		NSFileManager *fm = [NSFileManager defaultManager];
		[fm removeItemAtPath:[url path] error:&err];
	}
	
	err = nil;
	recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
	if(!recorder){
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
								   message: [err localizedDescription]
								  delegate: nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
	}
	
	//prepare to record
	[recorder setDelegate:self];
	[recorder prepareToRecord];
	recorder.meteringEnabled = YES;
	
	BOOL audioHWAvailable = audioSession.inputIsAvailable;
	if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
								   message: @"Audio input hardware not available"
								  delegate: nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
        [cantRecordAlert show];
        [cantRecordAlert release];
        return;
	}
	
	// start recording
	[recorder recordForDuration:(NSTimeInterval) 30];
	
	lblStatusMsg.text = @"Recording...";
	progressView.progress = 0.0;
	timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
    
    [self setupView];
}

- (IBAction) stopRecording
{
	[recorder stop];
	
    //	if ([timer isValid])
    //        [timer invalidate];
	lblStatusMsg.text = @"Stopped";
	progressView.progress = 1.0;
	
	//NSURL *url = [NSURL fileURLWithPath: recorderFilePath];
    //	NSError *err = nil;
    //	NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    //	if(!audioData)
    //        NSLog(@"audio data: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    //	[editedObject setValue:[NSData dataWithContentsOfURL:url] forKey:@"editedFieldKey"];
    //
    //	//[recorder deleteRecording];
    //
    //
    //	NSFileManager *fm = [NSFileManager defaultManager];
    //
    //	err = nil;
    //	[fm removeItemAtPath:[url path] error:&err];
    //	if(err)
    //        NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
	
	
}

- (IBAction)playSound
{
	if(!recorderFilePath)
		recorderFilePath = [[NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER, self.nameField.text] retain];
    
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:recorderFilePath];
    
    NSError *err;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&err];

    
	UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                            sizeof (doChangeDefaultRoute),
                            &doChangeDefaultRoute
                            );
	
    
    if (err)
        NSLog(@"ERR: %@", err);
    
    self.aPlayer = player;
    self.aPlayer.delegate = nil;
    self.aPlayer.volume = 1.0f;
    [self.aPlayer setNumberOfLoops:0];
    [self.aPlayer play];
	
	//Use audio sevices to create the sound
	//AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
	
	//Use audio services to play the sound
	//AudioServicesPlaySystemSound(soundID);
    
    [self setupView];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
	NSLog (@"audioRecorderDidFinishRecording:successfully:%i", flag);
	if (timer && [timer isValid])
        [timer invalidate];
	progressView.progress = 1.0;
    
    
    _soundRecorded = YES;
    
    [self setupView];
    
    
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setRecordIconImageview:nil];
    [self setArrowImageView:nil];
    [self setRedoButton:nil];
    [self setSaveButton:nil];
    [self setPlayButton:nil];
    [self setStartButton:nil];
    [self setSaveButton:nil];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark - Rotate  Methods
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

#pragma mark - UITextField Delegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.nameField resignFirstResponder];
    
    [self setupView];
    
    return YES;
}

@end
