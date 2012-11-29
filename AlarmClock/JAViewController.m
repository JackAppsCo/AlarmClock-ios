//
//  JAViewController.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/13/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JAViewController.h"
#import "JAAlarmListViewController.h"
#import "JAAlarm.h"
#import "JASettings.h"
#import "JAClockSettingsViewController.h"

#define WEATHER_API_KEY @"c74edf0183141706121311"

@interface JAViewController ()
- (void) settingsButtonPressed:(id)sender;
- (void) dismissSettingsController:(id)sender;
- (void) panGesture:(UIPanGestureRecognizer *)sender;
- (void) handleAlarmNotification:(NSNotification*)notification;
- (void) stopSleepTimer;
@end

@implementation JAViewController

@synthesize clock = _clock, tabBarController = _tabBarController, weatherRequest = _weatherRequest, dimView = _dimView, aPlayer;


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        //initialize and start the shared instance of MKClock
        [[ClockManager instance] delegate];
        [[ClockManager instance] setDelegate:self];
        [[ClockManager instance] start];
        
        _gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        _timeComponents = [[NSDateComponents alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAlarmNotification:) name:@"alarmTriggered" object:nil];
        
        NSError *err = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&err];
        [[AVAudioSession sharedInstance] setActive:YES error:&err];
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //init alarmsOn
    _alarmsOn = YES;
    
    //init clock
    
    //alarm settings
    JAAlarmListViewController *_alarmSettingsController = [[JAAlarmListViewController alloc] init];
    [_alarmSettingsController setTitle:@"Alarms"];
    [_alarmSettingsController setTabBarItem:[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0]];
    UIBarButtonItem *doneAlarmButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissSettingsController:)];
    [_alarmSettingsController.navigationItem setLeftBarButtonItem:doneAlarmButton];
    
    
    //display settings    
    JAClockSettingsViewController *_displaySettingsController = [[JAClockSettingsViewController alloc] initWithNibName:@"JAClockSettingsViewController" bundle:[NSBundle mainBundle]];
    [_displaySettingsController setTitle:@"Display"];
    [_displaySettingsController setTabBarItem:[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1]];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissSettingsController:)];
    [_displaySettingsController.navigationItem setLeftBarButtonItem:doneButton];
    
    //navigation controllers
    UINavigationController *alarmNavController = [[UINavigationController alloc] initWithRootViewController:_alarmSettingsController];
    UINavigationController *displayNavController = [[UINavigationController alloc] initWithRootViewController:_displaySettingsController];
    
    //tab bar
    _tabBarController = [[UITabBarController alloc] init];
    [_tabBarController setViewControllers:[NSArray arrayWithObjects:alarmNavController, displayNavController, nil]];
    
    //weather request
    _weatherRequest = [[MKWeatherRequest alloc] initWithCoordinate:CLLocationCoordinate2DMake(38.906029,-77.043475) APIKey:WEATHER_API_KEY delegate:self];
    [_weatherRequest currentWeather];
    
    //settings button
    [self.settingsButton addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //setup swipe gesture
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self.view addGestureRecognizer:panGesture];
 
    //init dimview
    _dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1200, 1200)];
    _dimView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _dimView.userInteractionEnabled = NO;
    _dimView.backgroundColor = [UIColor blackColor];
    _dimView.alpha = 0.0f;
    [self.view addSubview:_dimView];
    
}

- (void)viewDidUnload {
    [self setBgImageView:nil];
    [self setDateLabel:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //grab alarms
    if (!_myAlarms) {
        _myAlarms = [[NSMutableArray alloc] initWithArray:[JAAlarm savedAlarms]];
    }
    else {
        [_myAlarms removeAllObjects];
        [_myAlarms addObjectsFromArray:[JAAlarm savedAlarms]];
    }
    
    //setup bg image
    [self.bgImageView setImage:[JASettings backgroundImage]];
    
    //clock color
    self.clockLabel.textColor = [JASettings clockColor];
    self.dateLabel.textColor = [JASettings clockColor];
    self.currentTempLabel.textColor = [JASettings clockColor];
    
    //setup seconds
    if (!_formatter)
        _formatter = [[NSDateFormatter alloc] init];
    
    if ([JASettings showSeconds])
        [_formatter setDateFormat:@"h:mm:ss"];
    else
        [_formatter setDateFormat:@"h:mm"];
    
    self.clockLabel.text = [_formatter stringFromDate:[NSDate date]];
    
    if ([JASettings showDate]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"eee MMM dd, yyyy"];
        self.dateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    }
    else {
        self.dateLabel.text = @"";
    }
    
    
}


- (IBAction)sleepButtonPressed:(id)sender {
    
    if (self.aPlayer.playing) {
        [self.aPlayer stop];
        sleepTimer = nil;
        return;
    }
    
    
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"Beach" ofType:@"wav"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    //NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:[JASound defaultSound].soundFilename];
    NSError *err;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                                                   error:&err];
    
    if (err)
        NSLog(@"ERR: %@", err);
    
    sleepTimeLeft = 300.0f;
    

    
    self.aPlayer = player;
    self.aPlayer.delegate = self;
    self.aPlayer.volume = sleepVolume = 1.0f;
    [self.aPlayer setNumberOfLoops:-1];
    [self.aPlayer play];
    
    sleepTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeInterval:300 sinceDate:[NSDate date]] interval:0 target:self selector:@selector(stopSleepTimer) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:sleepTimer forMode:NSDefaultRunLoopMode];

    
}

- (void) stopSleepTimer
{
    if (self.aPlayer.playing) {
        [self.aPlayer stop];
    }

    sleepTimer = nil;
}


- (void) handleAlarmNotification:(NSNotification *)notification
{
    
    _currentAlarm = [notification object];
    
    //create the fileURL obejct
    NSURL *fileURL;
    
    if (_currentAlarm.sound.collection) {
        
        if (!_musicPlayer) {
            _musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
            [_musicPlayer setShuffleMode: MPMusicShuffleModeOff];
            [_musicPlayer setRepeatMode: MPMusicRepeatModeNone];
        }
        
        [_musicPlayer setQueueWithItemCollection:_currentAlarm.sound.collection];
        [_musicPlayer play];
        
        if (_currentAlarm.sound.soundFilename.length <= 0) {
            fileURL = [[NSURL alloc] initFileURLWithPath:[JASound defaultSound].soundFilename];
        }
        else
            fileURL = [[NSURL alloc] initWithString:_currentAlarm.sound.soundFilename];
    }
    else {
        
        NSString *soundFilePath;
        if ([_currentAlarm.sound.soundFilename rangeOfString:@".caf"].location == NSNotFound) {
            soundFilePath = [[NSBundle mainBundle] pathForResource:[[_currentAlarm.sound.soundFilename componentsSeparatedByString:@"."] objectAtIndex:0]
                                                            ofType:[[_currentAlarm.sound.soundFilename componentsSeparatedByString:@"."] objectAtIndex:1]];
        }
        else {
            soundFilePath = _currentAlarm.sound.soundFilename;
        }
        
        fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
        
        NSError *err;
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                                                       error:&err];
        
        if (err)
            NSLog(@"ERR: %@", err);
        
        self.aPlayer = player;
        self.aPlayer.delegate = nil;
        self.aPlayer.volume = 1.0f;
        [self.aPlayer setNumberOfLoops:-1];
        [self.aPlayer play];
    }
    
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_currentAlarm.name message:@"Your alarm went off" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Snooze", nil];
    [alert show];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) settingsButtonPressed:(id)sender
{
    [self presentViewController:_tabBarController animated:YES completion:nil];
}

//hides settings tab controller
- (void) dismissSettingsController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// handle gestures
- (void)panGesture:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        startLocation = [sender locationInView:self.view];
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint stopLocation = [sender locationInView:self.view];
        CGFloat dy = stopLocation.y - startLocation.y;
        
        if(dy > 15) {
            _dimView.alpha += (_dimView.alpha < 1.0f) ? 0.05 : 0.0;
            startLocation = stopLocation;
        }
        else if (dy < -15) {
            _dimView.alpha -= (_dimView.alpha > 0.0f) ? 0.1 : 0.0;
            startLocation = stopLocation;
        }
        
    }
}


#pragma mark - Handle Rotation
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        self.clockLabel.frame = CGRectMake(20, 50, 280, self.view.frame.size.height - 100);
        self.clockLabel.font = [UIFont fontWithName:@"Cochin-Bold" size:110];
        self.dateLabel.frame = CGRectMake(48, self.clockLabel.frame.origin.y + self.clockLabel.frame.size.height - 140, 225, 29);
        self.dateLabel.font = [UIFont fontWithName:@"Cochin" size:23];
        
    }
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.clockLabel.frame = CGRectMake(20, 50, 440, self.view.frame.size.width - 100);
        self.clockLabel.font = [UIFont fontWithName:@"Cochin-Bold" size:150];
        self.dateLabel.frame = CGRectMake(20, self.clockLabel.frame.origin.y + self.clockLabel.frame.size.height - 50, 440, 29);
        self.dateLabel.font = [UIFont fontWithName:@"Cochin" size:23];
        
    }
}

#pragma mark - MKCLock Delegate
- (void)clock:(MKClock *)clock didSetNewString:(NSString *)theString
{
    if (!_formatter)
        _formatter = [[NSDateFormatter alloc] init];
    
    if ([JASettings showSeconds])
        [_formatter setDateFormat:@"h:mm:ss"];
    else
        [_formatter setDateFormat:@"h:mm"];
    
    self.clockLabel.text = [_formatter stringFromDate:[NSDate date]];
    
    //change the date if needed
    if ([JASettings showDate]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"eee MMM dd, yyyy"];
        self.dateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    }
    else {
        self.dateLabel.text = @"";
    }
    
    
    if (sleepTimer) {
        sleepTimeLeft -= 1.0f;
        self.aPlayer.volume = sleepVolume = sleepTimeLeft / 300.0f;
    }
}


- (void)clockDidStart:(MKClock *)clock
{
    //DO NOTHING
}

- (void)clockDidStop:(MKClock *)clock
{
    //DO NOTHING    
}


#pragma mark - MKWeatherRequest Delegate
- (void)weatherData:(NSArray *)data fromRequest:(MKWeatherRequest *)request
{
    if (data.count > 1) {
        NSDictionary *weatherDict = [data objectAtIndex:1];
        self.currentTempLabel.text = [NSString stringWithFormat:@"%0.0f˚F", [[weatherDict objectForKey:WEATHER_TEMP_F] floatValue], nil];
    }
}

#pragma mark - UIAlertViewDelegate 
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        //do nothing
    }
    else {
        [ClockManager snoozeAlarm:_currentAlarm];
    }
    
    if (_musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
        [_musicPlayer stop];
    else
        [self.aPlayer stop];
    
}




#pragma mark - AVAudioPlayer Delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
}
@end
