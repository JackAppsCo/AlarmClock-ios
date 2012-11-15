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

#define WEATHER_API_KEY @"c74edf0183141706121311"

@interface JAViewController ()
- (void) settingsButtonPressed:(id)sender;
- (void) dismissSettingsController:(id)sender;
- (void) handleUpSwipeGesture:(UIGestureRecognizer*)gesture;
- (void) handleDownSwipeGesture:(UIGestureRecognizer*)gesture;
@end

@implementation JAViewController

@synthesize clock = _clock, tabBarController = _tabBarController, weatherRequest = _weatherRequest, dimView = _dimView;

- (id) init
{
    if ((self = [super init])) {
        
        _gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        _timeComponents = [[NSDateComponents alloc] init];
        
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
    _clock = [[MKClock alloc] initWithDelegate:self];
    [_clock start];
    
    //alarm settings
    JAAlarmListViewController *_alarmSettingsController = [[JAAlarmListViewController alloc] init];
    [_alarmSettingsController setTitle:@"Alarms"];
    [_alarmSettingsController setTabBarItem:[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0]];
    UIBarButtonItem *doneAlarmButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(dismissSettingsController:)];
    [_alarmSettingsController.navigationItem setLeftBarButtonItem:doneAlarmButton];
    
    
    //navigation controllers
    UINavigationController *alarmNavController = [[UINavigationController alloc] initWithRootViewController:_alarmSettingsController];
    
    //tab bar
    _tabBarController = [[UITabBarController alloc] init];
    [_tabBarController setViewControllers:[NSArray arrayWithObject:alarmNavController]];
    
    //weather request
    _weatherRequest = [[MKWeatherRequest alloc] initWithCoordinate:CLLocationCoordinate2DMake(38.906029,-77.043475) APIKey:WEATHER_API_KEY delegate:self];
    [_weatherRequest currentWeather];
    
    //settings button
    [self.settingsButton addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //setup swipe gesture
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self.view addGestureRecognizer:panGesture];
 
    //init dimview
    _dimView = [[UIView alloc] initWithFrame:CGRectInset(self.view.frame, 0, 0)];
    _dimView.userInteractionEnabled = NO;
    _dimView.backgroundColor = [UIColor blackColor];
    _dimView.alpha = 0.0f;
    [self.view addSubview:_dimView];
    
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


#pragma mark - MKCLock Delegate
- (void)clock:(MKClock *)clock didSetNewString:(NSString *)theString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm:ss"];
    self.clockLabel.text = [formatter stringFromDate:[NSDate date]];
    
    //check alarms
    if (_alarmsOn) {
        
        _timeComponents = [_gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
        
        for (JAAlarm *alarm in _myAlarms) {
            if (timeComponents.minute == alarm.timeComponents.minute && timeComponents.hour == alarm.timeComponents.hour) {
                self.view.backgroundColor = [UIColor whiteColor];
            }
        }
        
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

@end
