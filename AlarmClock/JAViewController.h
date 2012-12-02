//
//  JAViewController.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/13/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClockManager.h"
#import "MKWeatherRequest.h"
#import <AVFoundation/AVFoundation.h>

@interface JAViewController : UIViewController <MKClockDelegate, MKWeatherRequestDelegate, UIAlertViewDelegate, AVAudioPlayerDelegate>
{
    CGPoint startLocation;
    NSMutableArray *_myAlarms;
    NSDateComponents *_timeComponents;
    NSDateFormatter *_formatter;
    NSCalendar *_gregorian;
    BOOL _alarmsOn;
    NSArray *_weatherData;
    JAAlarm *_currentAlarm;
    MPMusicPlayerController *_musicPlayer;
    float sleepVolume;
    float sleepTimeLeft;
    NSTimer *sleepTimer;
    BOOL alarmEnabled;
}


@property (strong, nonatomic) AVAudioPlayer *aPlayer;
@property (nonatomic, retain) ClockManager *clock;
@property (nonatomic, retain) MKWeatherRequest *weatherRequest;

@property (nonatomic, retain) UIView *dimView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *clockLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *highTempLabel;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *alarmButton;

- (IBAction)sleepButtonPressed:(id)sender;
- (IBAction)alarmButtonPressed:(id)sender;

@end
