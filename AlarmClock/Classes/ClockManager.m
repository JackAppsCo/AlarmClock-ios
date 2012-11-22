//
//  ClockManager.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/19/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "ClockManager.h"



static ClockManager *sharedInstance = nil;


@implementation ClockManager

@synthesize snoozeAlarms = _snoozeAlarms;

- (id)initWithDelegate:(id<MKClockDelegate>)theDelegate {
	if (self = [super initWithDelegate:theDelegate]) {
        
        //init snooze alarms
		_snoozeAlarms = [[NSMutableArray alloc] init];

	}
	return self;
}


- (void)timerFireMethod:(NSTimer *)theTimer {
    [super timerFireMethod:theTimer];

    
    //get time components
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    
    //check every minute to see if the time matches a current alarm
    if (timeComponents.second == 0) {
        
        for (JAAlarm *alarm in [JAAlarm savedAlarms]) {
            if (alarm.enabled && timeComponents.minute == alarm.timeComponents.minute && timeComponents.hour == alarm.timeComponents.hour) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"alarmTriggered" object:alarm];
            }
        }
        
        for (int alarmIndex = 0; alarmIndex < self.snoozeAlarms.count; alarmIndex++) {
            JAAlarm *alarm = [self.snoozeAlarms objectAtIndex:alarmIndex];
            if (timeComponents.minute == alarm.timeComponents.minute && timeComponents.hour == alarm.timeComponents.hour) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"alarmTriggered" object:alarm];
                [self.snoozeAlarms removeObject:alarm];
            }
        }
        
    }
    
}



#pragma mark - Class Methods

+ (ClockManager *)instance {
	@synchronized(self)	{
		//initialize the shared singleton if it has not yet been created
		if (sharedInstance == nil) {
			sharedInstance = [[ClockManager alloc] initWithDelegate:nil];
		}
	}
	return sharedInstance;
}

+ (void) snoozeAlarm:(JAAlarm*)anAlarm
{
    //get time components
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    //Set the snooze alarm for 10 minutes from now
    NSDateComponents *timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate dateWithTimeIntervalSinceNow:(60)]];
    
    JAAlarm *newSnoozeAlarm = anAlarm;
    newSnoozeAlarm.timeComponents = timeComponents;
    
    [[ClockManager instance].snoozeAlarms addObject:newSnoozeAlarm];

}

@end
