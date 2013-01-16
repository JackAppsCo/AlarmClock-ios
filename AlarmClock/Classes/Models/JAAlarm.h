//
//  JAAlarm.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/13/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JASound.h"

#define RepeatPossibilities [NSArray arrayWithObjects:@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", nil]

@interface JAAlarm : NSObject

@property NSDateComponents *timeComponents;
@property NSDate *lastFireDate, *enabledDate;
@property NSNumber *alarmID, *snoozeTime;
@property NSString *name;
@property BOOL *enabled, *gradualSound, *shineEnabled;
@property JASound *sound;
@property NSArray *repeatDays;

+ (void) saveAlarm:(JAAlarm*)theAlarm;
+ (void) removeAlarm:(JAAlarm*)theAlarm;
+ (NSArray*) savedAlarms;
+ (int)numberOfEnabledAlarms;

//check if alarm should trigger today
//TODO

//repeat days methods
+ (BOOL) justWeekends:(NSArray*)days;
+ (BOOL) justWeekdays:(NSArray*)days;
+ (BOOL) days:(NSArray*)days containsDay:(NSString*)day;
+ (NSArray*) days:(NSArray*)days AfterRemovingDay:(NSString*)day;
+ (NSString*) labelForDays:(NSArray*)days;

@end
