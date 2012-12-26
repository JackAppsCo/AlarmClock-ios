//
//  JAAppDelegate.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/13/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JA_APP_ID @"APPID"

static BOOL L0AccelerationIsShaking(UIAcceleration* last, UIAcceleration* current, double threshold) {
	double
    deltaX = fabs(last.x - current.x),
    deltaY = fabs(last.y - current.y),
    deltaZ = fabs(last.z - current.z);
    
	return
    (deltaX > threshold && deltaY > threshold) ||
    (deltaX > threshold && deltaZ > threshold) ||
    (deltaY > threshold && deltaZ > threshold);
}

@class JAViewController;

@interface JAAppDelegate : UIResponder <UIApplicationDelegate, UIAccelerometerDelegate>
{
    //save the initial brightness so we can reset it
    float _initalBrightness;
    BOOL _flashIsOn;
    
    BOOL histeresisExcited;
	UIAcceleration* lastAcceleration;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) JAViewController *viewController;

@end
