//
//  JAAlarm.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/13/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAAlarm : NSObject

@property NSDateComponents *timeComponents;
@property NSDate *lastFireDate;
@property NSNumber *alarmID;

+ (void) saveAlarm:(JAAlarm*)theAlarm;
+ (NSArray*) savedAlarms;

@end
