//
//  JAViewController.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/13/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKClock.h"
#import "MKWeatherRequest.h"

@interface JAViewController : UIViewController <MKClockDelegate, MKWeatherRequestDelegate>
{
    CGPoint startLocation;
    NSMutableArray *_myAlarms;
    NSDateComponents *_timeComponents;
    NSCalendar *_gregorian;
    BOOL _alarmsOn;
}

@property (nonatomic, retain) MKClock *clock;
@property (nonatomic, retain) MKWeatherRequest *weatherRequest;

@property (nonatomic, retain) UIView *dimView;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *clockLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTempLabel;
@property (nonatomic, retain) UITabBarController *tabBarController;

@end
