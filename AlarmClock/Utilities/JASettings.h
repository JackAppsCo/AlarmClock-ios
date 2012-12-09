//
//  JASettings.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/22/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JASettings : NSObject
{
}

+ (JASettings *)instance;

+ (UIImage *)backgroundImage;
+ (void) setBackgroundImage:(NSString*)image;
+ (NSString *)backgroundImageName;
+ (void) setBackgroundImageName:(NSString*)imageName;
+ (UIColor*) clockColor;
+ (NSString*) clockColorName;
+ (void) setClockColorName:(NSString*)cColorName;
+ (BOOL) showSeconds;
+ (void) setShowSeconds:(BOOL)show;
+ (BOOL) showDate;
+ (void) setShowDate:(BOOL)show;
+ (BOOL) farenheit;
+ (void) setFarenheit:(BOOL)farenheit;
+ (BOOL) alarmsEnabled;
+ (void) setAlarmsEnabled:(BOOL)enabled;
+ (int) sleepLength;
+ (void) setSleepLength:(int)length;


@end
