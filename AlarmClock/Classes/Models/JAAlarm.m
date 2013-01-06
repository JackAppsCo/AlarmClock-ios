//
//  JAAlarm.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/13/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JAAlarm.h"

@implementation JAAlarm
@synthesize timeComponents = _timeComponents, alarmID = _alarmID, lastFireDate = _lastFireDate, repeatDays = _repeatDays, enabled = _enabled, sound = _sound, snoozeTime = _snoozeTime, gradualSound = _gradualSound, enabledDate = _enabledDate;

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_timeComponents forKey:@"alarmDate"];
    [encoder encodeObject:_alarmID forKey:@"alarmID"];
    [encoder encodeObject:_lastFireDate forKey:@"lastFireDate"];
    [encoder encodeObject:_enabledDate forKey:@"enabledDate"];
    [encoder encodeObject:_name forKey:@"alarmName"];
    [encoder encodeBool:_enabled forKey:@"alarmEnabled"];
    [encoder encodeBool:_gradualSound forKey:@"gradualSound"];
    [encoder encodeObject:_repeatDays forKey:@"alarmRepeatDays"];
    [encoder encodeObject:_sound forKey:@"alarmSound"];
    [encoder encodeObject:_snoozeTime forKey:@"snoozeTime"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self != nil)
	{
		[self setTimeComponents:[coder decodeObjectForKey:@"alarmDate"]];
        [self setAlarmID:[coder decodeObjectForKey:@"alarmID"]];
        [self setLastFireDate:[coder decodeObjectForKey:@"lastFireDate"]];
        [self setEnabledDate:[coder decodeObjectForKey:@"enabledDate"]];
        [self setName:[coder decodeObjectForKey:@"alarmName"]];
        [self setEnabled:[coder decodeBoolForKey:@"alarmEnabled"]];
        [self setGradualSound:[coder decodeBoolForKey:@"gradualSound"]];
        [self setRepeatDays:[coder decodeObjectForKey:@"alarmRepeatDays"]];
        [self setSound:[coder decodeObjectForKey:@"alarmSound"]];
        [self setSnoozeTime:[coder decodeObjectForKey:@"snoozeTime"]];
        
	}
    return self;
}


#pragma mark - Class Methods

+ (int)numberOfEnabledAlarms
{
    int count = 0;
    for (JAAlarm *thisAlarm in [JAAlarm savedAlarms]) {
        count += ([thisAlarm enabled]) ? 1 : 0;
    }
    
    return count;
}

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

+ (void) removeAlarm:(JAAlarm*)theAlarm
{
    if (!theAlarm)
        return;
    
    //grab current saved alarms
    NSMutableArray *alarms = [[NSMutableArray alloc] initWithArray:[JAAlarm savedAlarms]];

    //check for existing alarm
    int currentIndex = 0;
    for (JAAlarm *thisAlarm in alarms) {
        if (thisAlarm.alarmID.intValue == theAlarm.alarmID.intValue) {
            currentIndex = [alarms indexOfObject:thisAlarm];
        }
    }
    
    [alarms removeObjectAtIndex:currentIndex];
    
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


//repeat days methods
//check if its just weekends
+ (BOOL) justWeekends:(NSArray*)days
{
    if (days.count != 2) return NO;
    
    BOOL sat = NO;
    BOOL sun = NO;
    
    for (NSString *day in days) {
        if ([[day lowercaseString] isEqualToString:[NSLocalizedString(@"Saturday", nil) lowercaseString]]) sat = YES;
        if ([[day lowercaseString] isEqualToString:[NSLocalizedString(@"Sunday", nil) lowercaseString]]) sun = YES;
    }
    
    return (sat && sun);
}

//check if its just weekdays
+ (BOOL) justWeekdays:(NSArray*)days
{
    
    if (days.count != 5) return NO;
    
    BOOL mon = NO;
    BOOL tue = NO;
    BOOL wed = NO;
    BOOL thu = NO;
    BOOL fri = NO;
    
    for (NSString *day in days) {
        if ([[day lowercaseString] isEqualToString:[NSLocalizedString(@"Monday", nil) lowercaseString]]) mon = YES;
        if ([[day lowercaseString] isEqualToString:[NSLocalizedString(@"Tuesday", nil) lowercaseString]]) tue = YES;
        if ([[day lowercaseString] isEqualToString:[NSLocalizedString(@"Wednesday", nil) lowercaseString]]) wed = YES;
        if ([[day lowercaseString] isEqualToString:[NSLocalizedString(@"Thursday", nil) lowercaseString]]) thu = YES;
        if ([[day lowercaseString] isEqualToString:[NSLocalizedString(@"Friday", nil) lowercaseString]]) fri = YES;
    }
    
    return (mon && tue && wed && thu && fri);
}

+ (BOOL) days:(NSArray*)days containsDay:(NSString*)day
{
    
    for (NSString *thisDay in days) {
        if ([[thisDay lowercaseString] isEqualToString:[day lowercaseString]]) return YES;
    }
    
    return NO;
}

+ (NSArray*) days:(NSArray*)days AfterRemovingDay:(NSString*)day
{
    NSMutableArray *newDays = [[NSMutableArray alloc] initWithArray:days];
    int theIndex = -1;
    
    for (int x = 0; x < days.count; x++) {
        if ([[[days objectAtIndex:x] lowercaseString] isEqualToString:[day lowercaseString]]) {
            theIndex = x;
            break;
        }
    }
    
    [newDays removeObjectAtIndex:theIndex];
    return newDays;
}

//desc
- (NSString*) description {
    
    NSString *desc = @"";
    
    desc = [NSString stringWithFormat:@"%@ alarmID:%i", desc, self.alarmID.intValue, nil];
    desc = [NSString stringWithFormat:@"%@ name:%@", desc, self.name, nil];
    desc = [NSString stringWithFormat:@"%@ hour:%i; minute:%i;", desc, self.timeComponents.hour, self.timeComponents.minute, nil];
    desc = [NSString stringWithFormat:@"%@ lastFireDate:%@;", desc, self.lastFireDate, nil];
    desc = [NSString stringWithFormat:@"%@ sound:%@;", desc, self.sound, nil];
    desc = [NSString stringWithFormat:@"%@ Enabled:%@;", desc, (self.enabled) ? @"YES" : @"NO", nil];
    desc = [NSString stringWithFormat:@"%@ Gradual Sound:%@;", desc, (self.gradualSound) ? @"YES" : @"NO", nil];
    desc = [NSString stringWithFormat:@"%@ Repeat Days:%@;", desc, self.repeatDays, nil];
    return desc;
    
}

+ (NSString*) labelForDays:(NSArray*)days
{
    NSString *label = @"";
    
    
    if (days.count == 0)
        label = NSLocalizedString(@"Never", nil);
    else if (days.count == 7)
        label = NSLocalizedString(@"Everyday", nil);
    else if ([self justWeekdays:days])
        label = NSLocalizedString(@"Weekdays", nil);
    else if ([self justWeekends:days])
        label = NSLocalizedString(@"Weekends", nil);
    else {
        label = [NSString stringWithFormat:@"%@", ([JAAlarm days:days containsDay:NSLocalizedString(@"Monday", nil)]) ? NSLocalizedString(@"M", nil) : @""];
        
        label = [NSString stringWithFormat:@"%@%@", label, ([JAAlarm days:days containsDay:NSLocalizedString(@"Tuesday", nil)]) ? NSLocalizedString(@" T", nil) : @""];
        
        label = [NSString stringWithFormat:@"%@%@", label, ([JAAlarm days:days containsDay:NSLocalizedString(@"Wednesday", nil)]) ? NSLocalizedString(@" W", nil) : @""];
        
        label = [NSString stringWithFormat:@"%@%@", label, ([JAAlarm days:days containsDay:NSLocalizedString(@"Thursday", nil)]) ? NSLocalizedString(@" Th", nil) : @""];
        
        label = [NSString stringWithFormat:@"%@%@", label, ([JAAlarm days:days containsDay:NSLocalizedString(@"Friday", nil)]) ? NSLocalizedString(@" F", nil) : @""];
        
        label = [NSString stringWithFormat:@"%@%@", label, ([JAAlarm days:days containsDay:NSLocalizedString(@"Saturday", nil)]) ? NSLocalizedString(@" S", nil) : @""];
        
        label = [NSString stringWithFormat:@"%@%@", label, ([JAAlarm days:days containsDay:NSLocalizedString(@"Sunday", nil)]) ? NSLocalizedString(@" Su", nil) : @""];
    }
    
    return label;
}

@end
