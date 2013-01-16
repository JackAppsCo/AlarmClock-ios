//
//  ClockManager.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/19/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "ClockManager.h"
#import "JASettings.h"


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
    NSDateComponents *timeComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    
    //check every minute to see if the time matches a current alarm
    if (timeComponents.second == 0) {
        
        for (JAAlarm *alarm in [JAAlarm savedAlarms]) {
            if (alarm.enabled && alarm.shineEnabled && [ClockManager shouldStartShineForComponents:alarm.timeComponents atComponents:timeComponents]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"shineTriggered" object:alarm];
            }
            else if (alarm.enabled && timeComponents.minute == alarm.timeComponents.minute && timeComponents.hour == alarm.timeComponents.hour) {
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


+ (BOOL)shouldStartShineForComponents:(NSDateComponents*)shineComps atComponents:(NSDateComponents*)atComps
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDate *shineDate;
//    if (shineComps.hour == 0 && shineComps.minute < 30) {
//        shineDate = [cal dateByAddingComponents:shineComps toDate:[NSDate dateWithTimeInterval:(60 * 60 * 24) sinceDate:[NSDate date]] options:0];
//    }
//    else {
//        //shineDate = [cal dateByAddingComponents:shineComps toDate:[NSDate date] options:0];
//        shineDate = [cal dateFromComponents:shineComps];
//    }
    
    shineDate = [cal dateFromComponents:shineComps];
    
    NSDate *atDate = [cal dateFromComponents:atComps];
    
    //get abs value of time interval
    int seconds = [shineDate timeIntervalSinceDate:atDate];
    seconds = abs(seconds);
    
    return (seconds >= 1770 && seconds < 1830);
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
    NSDateComponents *timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate dateWithTimeIntervalSinceNow:(60 * [JASettings snoozeLength])]];
    
    JAAlarm *newSnoozeAlarm = anAlarm;
    newSnoozeAlarm.timeComponents = timeComponents;
    newSnoozeAlarm.repeatDays = nil;
    
    [[ClockManager instance].snoozeAlarms addObject:newSnoozeAlarm];

}

@end
