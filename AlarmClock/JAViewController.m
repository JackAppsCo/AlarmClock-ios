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

#define WEATHER_API_KEY @"c74edf0183141706121311"

@interface JAViewController ()
- (void) settingsButtonPressed:(id)sender;
- (void) dismissSettingsController:(id)sender;
- (void) panGesture:(UIPanGestureRecognizer *)sender;
- (void) handleAlarmNotification:(NSNotification*)notification;
- (void) stopSleepTimer;
- (void) showAdBanner:(BOOL)show;
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
        
        //iad setup
        self.adBanner.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];
        
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
    [_alarmSettingsController setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Alarms" image:[UIImage imageNamed:@""] tag:0]];
    UIBarButtonItem *doneAlarmButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissSettingsController:)];
    [_alarmSettingsController.navigationItem setLeftBarButtonItem:doneAlarmButton];
    
    
    //display settings    
    JAClockSettingsViewController *_displaySettingsController = [[JAClockSettingsViewController alloc] initWithNibName:@"JAClockSettingsViewController" bundle:[NSBundle mainBundle]];
    [_displaySettingsController setTitle:@"Display"];
    [_displaySettingsController setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Display" image:[UIImage imageNamed:@""] tag:1]];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissSettingsController:)];
    [_displaySettingsController.navigationItem setLeftBarButtonItem:doneButton];
    
    //misc settings
    JAMiscSettingsViewController *_miscSettingsController = [[JAMiscSettingsViewController alloc] init];
    [_miscSettingsController setTitle:@"Settings"];
    [_miscSettingsController setTabBarItem:[[UITabBarItem alloc] initWithTitle:@"Misc" image:[UIImage imageNamed:@""] tag:2]];
    UIBarButtonItem *doneMiscButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissSettingsController:)];
    [_miscSettingsController.navigationItem setLeftBarButtonItem:doneMiscButton];
    
    //navigation controllers
    UINavigationController *alarmNavController = [[UINavigationController alloc] initWithRootViewController:_alarmSettingsController];
    UINavigationController *displayNavController = [[UINavigationController alloc] initWithRootViewController:_displaySettingsController];
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:_miscSettingsController];
    
    //tab bar
    _tabBarController = [[UITabBarController alloc] init];
    [_tabBarController setViewControllers:[NSArray arrayWithObjects:alarmNavController, displayNavController, settingsNavController, nil]];
    
    //weather request
    _weatherRequest = [[MKWeatherRequest alloc] initWithCoordinate:CLLocationCoordinate2DMake(38.906029,-77.043475) APIKey:WEATHER_API_KEY delegate:self];
    [_weatherRequest weatherForcast];
    
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
    
}

- (void) setAlarmIcon
{
    if (![JASettings alarmsEnabled]) {
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
    
}

- (void)viewDidUnload {
    [self setBgImageView:nil];
    [self setDateLabel:nil];
    [self setAlarmButton:nil];
    [self setLowTempLabel:nil];
    [self setHighTempLabel:nil];
    [self setMainView:nil];
    [self setAdBanner:nil];
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
    [self.bgImageView setImage:[JASettings backgroundImage]];
    
    //clock color
    self.clockLabel.textColor = [JASettings clockColor];
    self.dateLabel.textColor = [JASettings clockColor];
    
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
    if (self.adBanner.currentContentSizeIdentifier == ADBannerContentSizeIdentifierPortrait)
        self.clockLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:([JASettings showSeconds]) ? 55 : 85];
    else
        self.clockLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:([JASettings showSeconds]) ? 87 : 110];

    
    
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

- (IBAction)alarmButtonPressed:(id)sender {

    [JASettings setAlarmsEnabled:![JASettings alarmsEnabled]];
    
    [self setAlarmIcon];
    
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
    
    //dont do anything if alarms are disabled
    if (![JASettings alarmsEnabled])
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

        self.clockLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:([JASettings showSeconds]) ? 55 : 85];
//        
//        NSString *zerosString;
//        float zeroCorrection = 0;
//        if ([JASettings showSeconds]) {
//            zerosString = (self.clockLabel.text.length > 7) ? @"14:44:44" : @"4:44:44";
//            zeroCorrection = 4;
//        }
//        else {
//            zerosString = (self.clockLabel.text.length > 7) ? @"14:44 " : @"4:44 ";
//        }
        
        CGSize timeSize = [self.clockLabel.text sizeWithFont:self.clockLabel.font];
        
        self.clockLabel.frame = CGRectMake(0, roundf((self.mainView.frame.size.height - timeSize.height) / 2.0), self.mainView.frame.size.width, timeSize.height);
        self.dateLabel.frame = CGRectMake(00, self.clockLabel.center.y + 40, self.mainView.frame.size.width, 29);
        
        
    }
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        
        self.clockLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:([JASettings showSeconds]) ? 87 : 110];
        
        NSString *zerosString;
        float zeroCorrection = 0;
        if ([JASettings showSeconds]) {
            zerosString = (self.clockLabel.text.length > 7) ? @"14:44:44" : @"4:44:44";
            zeroCorrection = 4;
        }
        else {
            zerosString = (self.clockLabel.text.length > 7) ? @"14:44 " : @"4:44 ";
        }
        
        //fidn label size
        CGSize timeSize = [zerosString sizeWithFont:self.clockLabel.font];
        
        self.clockLabel.frame = CGRectMake(0, roundf((self.mainView.frame.size.height - timeSize.height) / 2.0), self.mainView.frame.size.width, timeSize.height);
        self.dateLabel.frame = CGRectMake(00, self.clockLabel.center.y + 40, self.mainView.frame.size.width, 29);
        
    }
    
    //switch the ad banner layout
    self.adBanner.currentContentSizeIdentifier = (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifierPortrait;
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
        self.highTempLabel.text = [NSString stringWithFormat:@"Hi: %0.0f˚", [[weatherDict objectForKey:([JASettings farenheit]) ? WEATHER_FORCAST_TEMP_MAX_F : WEATHER_FORCAST_TEMP_MAX_C] floatValue], nil];
        self.lowTempLabel.text = [NSString stringWithFormat:@"Low: %0.0f˚", [[weatherDict objectForKey:([JASettings farenheit]) ? WEATHER_FORCAST_TEMP_MIN_F : WEATHER_FORCAST_TEMP_MIN_C] floatValue], nil];
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
            self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.view.frame.size.height - self.adBanner.frame.size.height);
        }
        else {
            self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, self.mainView.frame.origin.y, self.mainView.frame.size.width, self.view.frame.size.height);
        }
    }];
    
}

@end
