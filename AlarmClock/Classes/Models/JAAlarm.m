//
//  JAAlarm.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/13/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JAAlarm.h"

@implementation JAAlarm
@synthesize timeComponents = _timeComponents, alarmID = _alarmID, lastFireDate = _lastFireDate;

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_timeComponents forKey:@"alarmDate"];
    [encoder encodeObject:_alarmID forKey:@"alarmID"];
    [encoder encodeObject:_lastFireDate forKey:@"lastFireDate"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self != nil)
	{
		[self setTimeComponents:[coder decodeObjectForKey:@"alarmDate"]];
        [self setAlarmID:[coder decodeObjectForKey:@"alarmID"]];
        [self setLastFireDate:[coder decodeObjectForKey:@"lastFireDate"]];
        
	}
    return self;
}


#pragma mark - Class Methods

+ (void) saveAlarm:(JAAlarm*)theAlarm
{
    if (!theAlarm)
        return;
    
    //reset last fire date
    theAlarm.lastFireDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    //grab current saved alarms
    NSMutableArray *alarms = [[NSMutableArray alloc] initWithArray:[JAAlarm savedAlarms]];
    
    //add alarm if it doesn't exist
    if (theAlarm.alarmID.intValue == -1) {
        
        //get unique alarm id
        int uID = alarms.count;
        BOOL unique = NO;
        
        while (!unique) {
            unique = YES;
            for (JAAlarm *thisAlarm in alarms) {
                if (uID == thisAlarm.alarmID.intValue) {
                    unique = NO;
                    uID++;
                    break;
                }
            }
        }
        
        //set alarm id
        theAlarm.alarmID = [NSNumber numberWithInt:uID];
        
        [alarms addObject:theAlarm];
    }
    else {
        
        //check for existing alarm
        int currentIndex = 0;
        for (JAAlarm *thisAlarm in alarms) {
            if (thisAlarm.alarmID.intValue == theAlarm.alarmID.intValue) {
                currentIndex = [alarms indexOfObject:thisAlarm];
            }
        }
        
        [alarms replaceObjectAtIndex:currentIndex withObject:theAlarm];
    }
    
    
    //save current alarms
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *yourArrayAsData = [NSKeyedArchiver archivedDataWithRootObject:alarms];
    [ud setObject:yourArrayAsData forKey:@"savedAlarms"];
}


//return saved alarms
+ (NSArray*) savedAlarms
{
    NSArray *localAlarms;
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingSavedArray = [currentDefaults objectForKey:@"savedAlarms"];
    if (dataRepresentingSavedArray != nil) {
        NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
        if (oldSavedArray != nil)
            localAlarms = [[NSArray alloc] initWithArray:oldSavedArray];
        else
            localAlarms = [[NSArray alloc] init];
    }

    return localAlarms;
}

//desc
- (NSString*) description {
    
    NSString *desc = @"";
    
    desc = [NSString stringWithFormat:@"%@ alarmID:%i", desc, self.alarmID.intValue, nil];
    desc = [NSString stringWithFormat:@"%@ hour:%i; minute:%i;", desc, self.timeComponents.hour, self.timeComponents.minute, nil];
    desc = [NSString stringWithFormat:@"%@ lastFireDate:%@;", desc, self.lastFireDate, nil];
    
    return desc;
    
}

@end
