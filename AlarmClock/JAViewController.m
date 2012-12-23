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
#import "JAMiscSettingsViewController.h"
#import "UIImage+fixOrientation.h"

#define WEATHER_API_KEY @"c74edf0183141706121311"

@interface JAViewController ()
- (void) settingsButtonPressed:(id)sender;
- (void) dismissSettingsController:(id)sender;
- (void) panGesture:(UIPanGestureRecognizer *)sender;
- (void) handleAlarmNotification:(NSNotification*)notification;
- (void) handleShineNotification:(NSNotification*)notification;
- (void) stopSleepTimer;
- (void) showAdBanner:(BOOL)show;
- (void) disableShine:(id)sender;
- (void) layoutClockLabelForFrame:(CGRect)frame;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShineNotification:) name:@"shineTriggered" object:nil];
        
        NSError *err = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&err];
        [[AVAudioSession sharedInstance] setActive:YES error:&err];
        
        //iad setup
        self.adBanner.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];
        
        //init flags
        _shineEnabled = NO;
        _alarmEnabled = NO;

        //location
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        [_locationManager startUpdatingLocation];
        
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
    [_alarmSettingsController setTitle:NSLocalizedString(@"Alarms", nil)];
    [_alarmSettingsController setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Alarms", nil) image:[UIImage imageNamed:@"tabIconAlarms.png"] tag:0]];
    UIBarButtonItem *doneAlarmButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(dismissSettingsController:)];
    [_alarmSettingsController.navigationItem setLeftBarButtonItem:doneAlarmButton];
    
    
    //display settings    
    JAClockSettingsViewController *_displaySettingsController = [[JAClockSettingsViewController alloc] initWithNibName:@"JAClockSettingsViewController" bundle:[NSBundle mainBundle]];
    [_displaySettingsController setTitle:NSLocalizedString(@"Display", nil)];
    [_displaySettingsController setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Display", nil) image:[UIImage imageNamed:@"tabIconDisplay.png"] tag:1]];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(dismissSettingsController:)];
    [_displaySettingsController.navigationItem setLeftBarButtonItem:doneButton];
    
    //misc settings
    JAMiscSettingsViewController *_miscSettingsController = [[JAMiscSettingsViewController alloc] init];
    [_miscSettingsController setTitle:NSLocalizedString(@"Settings", nil)];
    [_miscSettingsController setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Misc", nil) image:[UIImage imageNamed:@"tabIconSettings.png"] tag:2]];
    UIBarButtonItem *doneMiscButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(dismissSettingsController:)];
    [_miscSettingsController.navigationItem setLeftBarButtonItem:doneMiscButton];
    
    //navigation controllers
    UINavigationController *alarmNavController = [[UINavigationController alloc] initWithRootViewController:_alarmSettingsController];
    UINavigationController *displayNavController = [[UINavigationController alloc] initWithRootViewController:_displaySettingsController];
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:_miscSettingsController];
    
    //tab bar
    _tabBarController = [[UITabBarController alloc] init];
    [_tabBarController setViewControllers:[NSArray arrayWithObjects:alarmNavController, displayNavController, settingsNavController, nil]];
    
    
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
    
    //setup clock label frame and font
    self.clockLabel.frame = CGRectMake(20, 50, self.view.frame.size.width - 40, self.view.frame.size.height - 100);
    self.clockLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:([JASettings showSeconds]) ? 55 : 85];
    self.dateLabel.frame = CGRectMake(20, self.clockLabel.center.y + 40, self.view.frame.size.width - 40, 29);
    self.dateLabel.font = [UIFont fontWithName:@"Cochin" size:23];
    
    //setup shine disbale button
    _shineDisableButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shineDisableButton addTarget:self action:@selector(disableShine:) forControlEvents:UIControlEventTouchUpInside];
    [_shineDisableButton setBackgroundColor:[UIColor whiteColor]];
    [_shineDisableButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_shineDisableButton setAlpha:0.0];
    CGRect shineFrame = CGRectInset(self.view.frame, 0, 0);
    shineFrame.origin.y = 0;
    [_shineDisableButton setFrame:shineFrame];
    [self.mainView addSubview:_shineDisableButton];
    
    //backdrop view
    _backdropImageview = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"backdrop.png"] stretchableImageWithLeftCapWidth:45 topCapHeight:45]];
    _backdropImageview.frame = CGRectInset(self.mainView.frame, 15.0, 0.0);
    _backdropImageview.frame = CGRectMake(self.mainView.frame.origin.x, self.clockLabel.frame.origin.y - 10, self.mainView.frame.size.width, self.clockLabel.frame.size.height + 20);
    _backdropImageview.hidden = ![JASettings showBackdrop];
    [self.mainView addSubview:_backdropImageview];
    [self.mainView insertSubview:_backdropImageview belowSubview:self.amPmLabel];
    
    //setup clock labels
    self.clockLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:([JASettings showSeconds]) ? 87 : 110];
    [self layoutClockLabelForFrame:CGRectMake(15.0, 100.0, self.mainView.frame.size.width - 30.0, self.mainView.frame.size.height - 200.0)];
    
    //bring clock label to front
    [self.mainView bringSubviewToFront:self.clockLabel];
    
    //hide temp labels
    self.currentTempLabel.alpha = 0.0;
    self.lowTempLabel.alpha = 0.0;
    self.highTempLabel.alpha = 0.0;
}

- (void) setAlarmIcon
{
    if ([JASettings alarmsDisabled]) {
        [self.alarmButton setBackgroundImage:[UIImage imageNamed:@"alarmOffIcon.png"] forState:UIControlStateNormal];
        return;
    }
    
    if ([JAAlarm numberOfEnabledAlarms] <= 0) {
        [self.alarmButton setHidden:YES];
    }
    else if ([JAAlarm numberOfEnabledAlarms] <= 6) {
        [self.alarmButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"fullAlarmIcon%i.png", [JAAlarm numberOfEnabledAlarms]]] forState:UIControlStateNormal];
        [self.alarmButton setHidden:NO];
    }
    else {
        [self.alarmButton setBackgroundImage:[UIImage imageNamed:@"fullAlarmIcon.png"] forState:UIControlStateNormal];
        [self.alarmButton setHidden:NO];
    }
    
    //if Paid rmeove ads
    if ([JASettings isPaid])
        [self.adBanner removeFromSuperview];


}

- (void)viewDidUnload {
    [self setBgImageView:nil];
    [self setDateLabel:nil];
    [self setAlarmButton:nil];
    [self setLowTempLabel:nil];
    [self setHighTempLabel:nil];
    [self setMainView:nil];
    [self setAdBanner:nil];
    [self setAmPmLabel:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setAlarmIcon];
    
    //grab alarms
    if (!_myAlarms) {
        _myAlarms = [[NSMutableArray alloc] initWithArray:[JAAlarm savedAlarms]];
    }
    else {
        [_myAlarms removeAllObjects];
        [_myAlarms addObjectsFromArray:[JAAlarm savedAlarms]];
    }
    
    //setup bg image
    [self.bgImageView setImage:[(UIImage*)[JASettings backgroundImage] fixOrientation]];
    
    //clock color
    self.clockLabel.textColor = [JASettings clockColor];
    self.amPmLabel.textColor = [JASettings clockColor];
    self.dateLabel.textColor = [JASettings clockColor];
    
    //set backdrop
    _backdropImageview.hidden = ![JASettings showBackdrop];
    
    //setup seconds
    if (!_formatter)
        _formatter = [[NSDateFormatter alloc] init];
    
    if ([JASettings showSeconds]) {
        [_formatter setDateFormat:@"h:mm:ss"];
    }
    else {
        [_formatter setDateFormat:@"h:mm"];
    }
    
    self.clockLabel.text = [_formatter stringFromDate:[NSDate date]];
    
    //am pm
    NSDateComponents *comps = [_gregorian components:NSHourCalendarUnit fromDate:[NSDate date]];
    self.amPmLabel.text = (comps.hour >= 12) ? @"PM" : @"AM";
    
    if ([JASettings showDate]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"eee MMM dd, yyyy"];
        self.dateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    }
    else {
        self.dateLabel.text = @"";
    }
    
    //setup the weather labels
    [self setupWeather];
    
    //clock font size
    if (self.mainView.frame.size.width <= 320) {
        
        self.clockLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:([JASettings showSeconds]) ? 55 : 85];
        
        [self layoutClockLabelForFrame:CGRectMake(15.0, 100.0, self.mainView.frame.size.width - 30.0, self.mainView.frame.size.height - 200.0)];
    }
    else {
        
        self.clockLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:([JASettings showSeconds]) ? 87 : 110];
        
        [self layoutClockLabelForFrame:CGRectMake(75.0, 25.0, self.mainView.frame.size.width - 150.0, self.mainView.frame.size.height - 50.0)];
    }

    
}


- (IBAction)sleepButtonPressed:(id)sender {
    
    if (self.aPlayer.playing) {
        [self.aPlayer stop];
        sleepTimer = nil;
        return;
    }
    
    NSString *soundFilename = [[JASettings sleepSound] objectForKey:@"filename"];
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:[[soundFilename componentsSeparatedByString:@"."] objectAtIndex:0] ofType:[[soundFilename componentsSeparatedByString:@"."] objectAtIndex:1]];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];

    NSError *err;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                                                   error:&err];
    
    if (err)
        NSLog(@"ERR: %@", err);
    
    sleepTimeLeft = ([JASettings sleepLength] * 60);
    

    
    self.aPlayer = player;
    self.aPlayer.delegate = self;
    self.aPlayer.volume = sleepVolume = 1.0f;
    [self.aPlayer setNumberOfLoops:-1];
    [self.aPlayer play];
    
    sleepTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeInterval:([JASettings sleepLength] * 60) sinceDate:[NSDate date]] interval:0 target:self selector:@selector(stopSleepTimer) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:sleepTimer forMode:NSDefaultRunLoopMode];

    
}

- (IBAction)alarmButtonPressed:(id)sender {

    [JASettings setAlarmsDisabled:![JASettings alarmsDisabled]];
    
    [self setAlarmIcon];
    
}

- (void) stopSleepTimer
{
    if (self.aPlayer.playing) {
        [self.aPlayer stop];
    }

    sleepTimer = nil;
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
    
    if (_shineEnabled) {
        [self disableShine:nil];
    }
    
    self.dimView.backgroundColor = [UIColor blackColor];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        startLocation = [sender locationInView:self.view];
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint stopLocation = [sender locationInView:self.view];
        CGFloat dy = stopLocation.y - startLocation.y;
        
        if(dy > 15) {
            _dimView.alpha += (_dimView.alpha < 1.0f) ? 0.05 : 0.0;
            [UIScreen mainScreen].brightness -= ([UIScreen mainScreen].brightness > 0.0f) ? 0.05 : 0.0;
            startLocation = stopLocation;
        }
        else if (dy < -15) {
            _dimView.alpha -= (_dimView.alpha > 0.0f) ? 0.05 : 0.0;
            [UIScreen mainScreen].brightness += ([UIScreen mainScreen].brightness < 1.0f) ? 0.05 : 0.0;
            startLocation = stopLocation;
        }
        
    }
}

//stop shine feature
- (void) disableShine:(id)sender
{
    _shineEnabled = NO;
    _shineDisableButton.alpha = 0;
    
    if ([[[JASettings clockColorName] uppercaseString] isEqualToString:@"WHITE"]) {
        [self.clockLabel setTextColor:[JASettings clockColor]];
        [self.amPmLabel setTextColor:[JASettings clockColor]];
    }
}

#pragma mark - Handle Alarms
- (void) handleAlarmNotification:(NSNotification *)notification
{
    
    //dont do anything if alarms are disabled
    if ([JASettings alarmsDisabled])
        return;
    
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
        
        if (_currentAlarm.gradualSound) {
            _musicPlayer.volume = 0.0f;
        }
        else {
            _musicPlayer.volume = 1.0f;
        }
        
        [_musicPlayer play];
        
        
        
        
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
        if (_currentAlarm.gradualSound) {
            self.aPlayer.volume = 0.0f;
        }
        else {
            self.aPlayer.volume = 1.0f;
        }
        [self.aPlayer setNumberOfLoops:-1];
        [self.aPlayer play];
    }
    
    _alarmEnabled = YES;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_currentAlarm.name message:@"Your alarm went off" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Snooze", nil];
    [alert show];
    
}

- (void) handleShineNotification:(NSNotification*)notification
{
    if (!_shineEnabled) {
        [_shineDisableButton setAlpha:0.0f];
        _shineEnabled = YES;
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

        self.clockLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:([JASettings showSeconds]) ? 65 : 75];
        
        [self layoutClockLabelForFrame:CGRectMake(25.0, 50.0, self.mainView.frame.size.width - 50.0, self.mainView.frame.size.height - 100.0)];
        
        
    }
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        
        self.clockLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:([JASettings showSeconds]) ? 87 : 110];
        
        [self layoutClockLabelForFrame:CGRectMake(60.0, 15.0, self.mainView.frame.size.width - 120.0, self.mainView.frame.size.height - 30.0)];
        
    }
    
    //switch the ad banner layout
    self.adBanner.currentContentSizeIdentifier = (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifierPortrait;
}

- (void) layoutClockLabelForFrame:(CGRect)frame
{
    
    
    CGRect insetFrame = CGRectInset(frame, 10.0, 10.0);
    
    CGFloat *fontSize = 0;
    
    CGSize clockSize = [self.clockLabel.text sizeWithFont:self.clockLabel.font minFontSize:self.clockLabel.minimumFontSize actualFontSize:fontSize forWidth:insetFrame.size.width lineBreakMode:NSLineBreakByClipping];
    CGSize dateSize = [self.dateLabel.text sizeWithFont:self.dateLabel.font minFontSize:self.dateLabel.minimumFontSize actualFontSize:fontSize forWidth:insetFrame.size.width lineBreakMode:NSLineBreakByClipping];
    
    float dateAdjustment = ([JASettings showDate]) ? -dateSize.height : 0;
    
    CGRect clockFrame = CGRectInset(insetFrame, roundf((insetFrame.size.width - clockSize.width) / 2), roundf((insetFrame.size.height - clockSize.height) / 2));
    clockFrame.origin.y += dateAdjustment;
    CGRect dateFrame = CGRectMake(frame.origin.x, clockFrame.origin.y + clockFrame.size.height + 20, frame.size.width, dateSize.height);
    dateFrame.origin.y += dateAdjustment;
    CGRect amFrame = CGRectMake(clockFrame.origin.x + clockFrame.size.width, clockFrame.origin.y + 18, self.amPmLabel.frame.size.width, self.amPmLabel.frame.size.height);

    
    
    self.clockLabel.frame = clockFrame;
    self.dateLabel.frame = dateFrame;
    self.amPmLabel.frame = amFrame;
    
    CGRect totalFrame = CGRectMake(clockFrame.origin.x - (1.5 * amFrame.size.width), ([JASettings showDate]) ? clockFrame.origin.y - 5 : clockFrame.origin.y - 20, clockFrame.size.width + (amFrame.size.width * 3), dateFrame.origin.y + dateFrame.size.height - clockFrame.origin.y + 20);
    _backdropImageview.frame = totalFrame;
    
    
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
    
    //am/pm
    NSDateComponents *comps = [_gregorian components:NSHourCalendarUnit fromDate:[NSDate date]];
    self.amPmLabel.text = (comps.hour >= 12) ? @"PM" : @"AM";
    
    //change the date if needed
    if ([JASettings showDate]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"eee MMM dd, yyyy"];
        self.dateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    }
    else {
        self.dateLabel.text = @"";
    }
    
    if (self.aPlayer.playing) {
        
    }
    
    if (sleepTimer) {
        sleepTimeLeft -= 1.0f;
        self.aPlayer.volume = sleepVolume = sleepTimeLeft / ([JASettings sleepLength] * 60.0f);
    }
    
    if (_shineEnabled) {
        _shineDisableButton.alpha = _shineDisableButton.alpha + (1.0 / 1800.0);
        [UIScreen mainScreen].brightness += ([UIScreen mainScreen].brightness < 1.0f) ?  + (1.0 / 1800.0) : 0.0;
        _dimView.alpha -= (_dimView.alpha > 0.0f) ? (1.0 / 1800.0) : 0.0;
        
        if ([[[JASettings clockColorName] uppercaseString] isEqualToString:@"WHITE"]) {
            if (_shineDisableButton.alpha >= 0.5) {
                [self.clockLabel setTextColor:[UIColor darkGrayColor]];
                [self.amPmLabel setTextColor:[UIColor darkGrayColor]];
            }
        }
    }
    
    if (_alarmEnabled) {
        if (_musicPlayer.playbackState == MPMusicPlaybackStatePlaying && _musicPlayer.volume < 1.0)
            _musicPlayer.volume = _musicPlayer.volume + .01;
        else if (self.aPlayer.playing && self.aPlayer.volume < 1.0)
            self.aPlayer.volume = self.aPlayer.volume + .01;

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
    _weatherData = [[NSArray alloc] initWithArray:data];
    
    [self setupWeather];
    
}

- (void) setupWeather
{
    if (_weatherData.count > 1) {
        NSDictionary *weatherDict = [_weatherData objectAtIndex:1];
        self.currentTempLabel.text = [NSString stringWithFormat:@"%0.0f˚", [[weatherDict objectForKey:([JASettings farenheit]) ? WEATHER_TEMP_F : WEATHER_TEMP_C] floatValue], nil];
    }
    
    if (_weatherData.count > 2) {
        NSDictionary *weatherDict = [_weatherData objectAtIndex:2];
        self.highTempLabel.text = [NSString stringWithFormat:@"%@: %0.0f˚", NSLocalizedString(@"H", nil), [[weatherDict objectForKey:([JASettings farenheit]) ? WEATHER_FORCAST_TEMP_MAX_F : WEATHER_FORCAST_TEMP_MAX_C] floatValue], nil];
        self.lowTempLabel.text = [NSString stringWithFormat:@"%@: %0.0f˚", NSLocalizedString(@"L", nil), [[weatherDict objectForKey:([JASettings farenheit]) ? WEATHER_FORCAST_TEMP_MIN_F : WEATHER_FORCAST_TEMP_MIN_C] floatValue], nil];
    }
    
    self.currentTempLabel.alpha = 1.0;
    self.lowTempLabel.alpha = 1.0;
    self.highTempLabel.alpha = 1.0;
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
    
    _alarmEnabled = NO;
    
}




#pragma mark - AVAudioPlayer Delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
}

#pragma mark - iAd Delegate
- (void)bannerViewWillLoadAd:(ADBannerView *)banner
{
    [self showAdBanner:YES];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self showAdBanner:NO];
}

- (void) showAdBanner:(BOOL)show
{

    [UIView animateWithDuration:0.3 animations:^{
    
        if (show) {
            self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.adBanner.frame.origin.y);
        }
        else {
            self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.adBanner.frame.origin.y + self.adBanner.frame.size.height);
        }
    }];
    
}

#pragma mark - Location Delegate
- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //weather request
    _weatherRequest = [[MKWeatherRequest alloc] initWithCoordinate:CLLocationCoordinate2DMake(38.906029,-77.043475) APIKey:WEATHER_API_KEY delegate:self];
    [_weatherRequest weatherForcast];
}

@end
