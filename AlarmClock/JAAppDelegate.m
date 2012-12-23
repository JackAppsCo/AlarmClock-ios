//
//  JAAppDelegate.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/13/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JAAppDelegate.h"
#import "JAViewController.h"
#import "JASettings.h"

@implementation UITabBarController (Rotation)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    /*if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
     UIViewController *rootController = [((UINavigationController *)self.selectedViewController).viewControllers objectAtIndex:0];
     return [rootController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
     }
     return [self.selectedViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];*/
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

@end

@implementation JAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //capture brightness
    _initalBrightness = [UIScreen mainScreen].brightness;
    
    //check for disabl lock
    [[UIApplication sharedApplication] setIdleTimerDisabled:[JASettings stayAwake]];
    
    //init flash
    _flashIsOn = NO;
    
    //setup shake gesture
    [UIAccelerometer sharedAccelerometer].delegate = self;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[JAViewController alloc] initWithNibName:@"JAViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([notification userInfo] && [[notification userInfo] objectForKey:@"alarm"]) {
        JAAlarm *notificationAlarm = [NSKeyedUnarchiver unarchiveObjectWithData:[[notification userInfo] objectForKey:@"alarm"]];
        
        if (notificationAlarm)
            [ClockManager snoozeAlarm:notificationAlarm];
        
        NSLog(@"%@", notificationAlarm);
    }
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
    
    [UIScreen mainScreen].brightness = _initalBrightness;
    
    [self scheduleNotifications];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    
    //cancel all notificaitons
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


//schedule notificaitons
- (void)scheduleNotifications {
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    for (JAAlarm *thisAlarm in [JAAlarm savedAlarms]) {
        if (thisAlarm.enabled) {
            if (thisAlarm.repeatDays.count != 0) {
                for (NSString *day in thisAlarm.repeatDays) {
                    
                    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
                    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSWeekCalendarUnit  fromDate:[NSDate date]];
                    
                    if ([day isEqualToString:NSLocalizedString(@"Sunday", nil)]) {
                        [dateComps setWeekday:1];
                    }
                    else if ([day isEqualToString:NSLocalizedString(@"Monday", nil)]) {
                        [dateComps setWeekday:2];
                    }
                    else if ([day isEqualToString:NSLocalizedString(@"Tuesday", nil)]) {
                        [dateComps setWeekday:3];
                    }
                    else if ([day isEqualToString:NSLocalizedString(@"Wednesday", nil) ]) {
                        [dateComps setWeekday:4];
                    }
                    else if ([day isEqualToString:NSLocalizedString(@"Thursday", nil)]) {
                        [dateComps setWeekday:5];
                    }
                    else if ([day isEqualToString:NSLocalizedString(@"Friday", nil) ]) {
                        [dateComps setWeekday:6];
                    }
                    else if ([day isEqualToString:NSLocalizedString(@"Saturday", nil)]) {
                        [dateComps setWeekday:7];
                    }
                    
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
                    localNotif.alertAction = NSLocalizedString(@"Snooza", nil);
                    
                    
                    
                    localNotif.soundName = thisAlarm.sound.soundFilename;
                    
                    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[NSKeyedArchiver archivedDataWithRootObject:thisAlarm] forKey:@"alarm"];
                    localNotif.userInfo = infoDict;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
                }
            }
            else {
                NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
                NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:[NSDate date]];
                [dateComps setHour:thisAlarm.timeComponents.hour];
                [dateComps setMinute:thisAlarm.timeComponents.minute];
                NSDate *itemDate = [calendar dateFromComponents:dateComps];
                
                if ([itemDate compare:[NSDate date]] == NSOrderedDescending) {
                
                UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                if (localNotif == nil)
                    return;
                localNotif.fireDate = itemDate;
                localNotif.timeZone = [NSTimeZone defaultTimeZone];
                localNotif.alertBody = thisAlarm.name;
                localNotif.repeatInterval = 0;
                localNotif.alertAction = NSLocalizedString(@"Snooze", nil);
                localNotif.soundName = thisAlarm.sound.soundFilename;
                
                NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[NSKeyedArchiver archivedDataWithRootObject:thisAlarm] forKey:@"alarm"];
                localNotif.userInfo = infoDict;
                
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
                    
                }
                
            }
        }
    }
    
    for (JAAlarm *thisAlarm in [ClockManager instance].snoozeAlarms) {
        if (thisAlarm.enabled) {
            if (thisAlarm.repeatDays.count != 0) {
                for (NSString *day in thisAlarm.repeatDays) {
                    
                    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
                    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSWeekCalendarUnit  fromDate:[NSDate date]];
                    
                    if ([day isEqualToString:NSLocalizedString(@"Sunday", nil)]) {
                        [dateComps setWeekday:1];
                    }
                    else if ([day isEqualToString:NSLocalizedString(@"Monday", nil)]) {
                        [dateComps setWeekday:2];
                    }
                    else if ([day isEqualToString:NSLocalizedString(@"Tuesday", nil)]) {
                        [dateComps setWeekday:3];
                    }
                    else if ([day isEqualToString:NSLocalizedString(@"Wednesday", nil) ]) {
                        [dateComps setWeekday:4];
                    }
                    else if ([day isEqualToString:NSLocalizedString(@"Thursday", nil)]) {
                        [dateComps setWeekday:5];
                    }
                    else if ([day isEqualToString:NSLocalizedString(@"Friday", nil) ]) {
                        [dateComps setWeekday:6];
                    }
                    else if ([day isEqualToString:NSLocalizedString(@"Saturday", nil)]) {
                        [dateComps setWeekday:7];
                    }
                    
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
                    localNotif.alertAction = NSLocalizedString(@"Snooze", nil);
                    
                    
                    
                    localNotif.soundName = thisAlarm.sound.soundFilename;
                    
                    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[NSKeyedArchiver archivedDataWithRootObject:thisAlarm] forKey:@"alarm"];
                    localNotif.userInfo = infoDict;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
                }
            }
            else {
                NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
                NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:[NSDate date]];
                [dateComps setHour:thisAlarm.timeComponents.hour];
                [dateComps setMinute:thisAlarm.timeComponents.minute];
                NSDate *itemDate = [calendar dateFromComponents:dateComps];
                
                if ([itemDate compare:[NSDate date]] == NSOrderedDescending) {
                    
                    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                    if (localNotif == nil)
                        return;
                    localNotif.fireDate = itemDate;
                    localNotif.timeZone = [NSTimeZone defaultTimeZone];
                    localNotif.alertBody = thisAlarm.name;
                    localNotif.repeatInterval = 0;
                    localNotif.alertAction = NSLocalizedString(@"Snooze", nil);

                    localNotif.soundName = thisAlarm.sound.soundFilename;
                    
                    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[NSKeyedArchiver archivedDataWithRootObject:thisAlarm] forKey:@"alarm"];
                    localNotif.userInfo = infoDict;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
                    
                }
                
            }
        }
    }
    
    
}


#pragma mark - Accelerometer
- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
	if (lastAcceleration) {
		if (!histeresisExcited && L0AccelerationIsShaking(lastAcceleration, acceleration, 2)) {
			histeresisExcited = YES;
            
            //toggle light
            [self toggleFlash];
            
		} else if (histeresisExcited && !L0AccelerationIsShaking(lastAcceleration, acceleration, 0.2)) {
			histeresisExcited = NO;
		}
	}
    
	lastAcceleration = acceleration;
}

//toggle flash
- (void) toggleFlash {
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (!_flashIsOn) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                _flashIsOn = YES;
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                _flashIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    }
}

@end
