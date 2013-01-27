//
//  JASettings.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/22/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TITLE_FONT @"Avenir-Black"
#define CELL_TEXT_FONT @"Avenir-Heavy"
#define CELL_DETAIL_TEXT_FONT @"Avenir-Medium"

#define CLOCK_COLORS [NSArray arrayWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:[UIColor whiteColor], @"color", @"White", @"name", nil], [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor], @"color", @"Black", @"name", nil], nil]

@interface JASettings : NSObject
{
}


+ (JASettings *)instance;
+ (UIImage*) filterImageNamed:(NSString*)imageName ofType:(NSString*)type darker:(BOOL)darker;

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
+ (BOOL) celsius;
+ (void) setCelsius:(BOOL)celsius;
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
+ (int) snoozeLength;
+ (void) setSnoozeLength:(int)length;
+ (void) setFlashlightDisabled:(BOOL)enabled;
+ (BOOL) flashlightDisabled;
+ (void) setDimDisabled:(BOOL)enabled;
+ (BOOL) dimDisabled;
+ (int) previousLaunchCount;
+ (void) increaseLaunchCount;
@end
