//
//  JASettings.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/22/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CLOCK_COLORS [NSArray arrayWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:[UIColor whiteColor], @"color", @"White", @"name", nil], [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor], @"color", @"Black", @"name", nil], [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor colorWithRed:243.0/255.0 green:246.0/255.0 blue:113.0/255.0 alpha:1.0], @"color", @"Yellow", @"name", nil], [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor colorWithRed:38.0/255.0 green:82.0/255.0 blue:163.0/255.0 alpha:1.0], @"color", @"Blue", @"name", nil], [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor colorWithRed:143.0/255.0 green:82.0/255.0 blue:237/255.0 alpha:1.0], @"color", @"Purple", @"name", nil], [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor colorWithRed:53.0/255.0 green:123.0/149.0 blue:58.0/255.0 alpha:1.0], @"color", @"Green", @"name", nil], nil]

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
+ (void) setShowBackdrop:(BOOL)show;
+ (BOOL) showBackdrop;
+ (void) setShowDate:(BOOL)show;
+ (BOOL) farenheit;
+ (void) setFarenheit:(BOOL)farenheit;
+ (BOOL) alarmsDisabled;
+ (void) setAlarmsDisabled:(BOOL)enabled;
+ (int) sleepLength;
+ (void) setSleepLength:(int)length;
+ (NSDictionary *)sleepSound;
+ (void) setSleepSound:(NSDictionary*)sleepSound;
+ (void) setShine:(BOOL)shine;
+ (BOOL) shine;
+ (void) setStayAwake:(BOOL)awake;
+ (BOOL) stayAwake;
+ (BOOL) isPaid;
@end
