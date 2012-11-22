//
//  ClockManager.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/19/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "MKClock.h"
#import "JAAlarm.h"

@interface ClockManager : MKClock <MKClockDelegate>
{
}

@property (strong, nonatomic) NSMutableArray *snoozeAlarms;

+ (ClockManager *)instance;
+ (void) snoozeAlarm:(JAAlarm*)anAlarm;

@end
