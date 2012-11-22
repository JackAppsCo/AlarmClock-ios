//
//  JAAppDelegate.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/13/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JAAppDelegate.h"
#import "JAViewController.h"

@implementation JAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[JAViewController alloc] initWithNibName:@"JAViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self scheduleNotifications];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)scheduleNotifications {
    
    for (JAAlarm *thisAlarm in [JAAlarm savedAlarms]) {
        //for (NSString *day in thisAlarm.repeatDays) {
            
            NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
            NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit  fromDate:[NSDate date]];
        
            [dateComps setHour:thisAlarm.timeComponents.hour];
            [dateComps setMinute:thisAlarm.timeComponents.minute];
            NSDate *itemDate = [calendar dateFromComponents:dateComps];
            
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            if (localNotif == nil)
                return;
            
            localNotif.fireDate = itemDate;
            localNotif.timeZone = [NSTimeZone defaultTimeZone];
            localNotif.repeatInterval = NSWeekCalendarUnit;
            localNotif.alertBody = thisAlarm.name;
            localNotif.alertAction = NSLocalizedString(@"View Details", nil);
            
            NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:[[thisAlarm.sound.soundFilename componentsSeparatedByString:@"."] objectAtIndex:0]
                                                                      ofType:[[thisAlarm.sound.soundFilename componentsSeparatedByString:@"."] objectAtIndex:1]];
            //localNotif.soundName = soundFilePath;
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        
            NSDictionary *infoDict = [NSDictionary dictionaryWithObject:thisAlarm.alarmID forKey:@"alarmID"];
            localNotif.userInfo = infoDict;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        //}
    }
}

@end
