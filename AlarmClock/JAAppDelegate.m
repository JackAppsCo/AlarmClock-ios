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
#import "Flurry.h"
#import "Appirater.h"

#define kUniqueIDKey @"fm_uniqueID"

@implementation UITabBarController (Rotation)

void uncaughtExceptionHandler(NSException *exception) {
    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
    //execption loggin
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    
    //increment launch count
    [JASettings increaseLaunchCount];
    
    //get Unique ID
    NSString *uID;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUniqueIDKey]) {
        uID = [[NSUserDefaults standardUserDefaults] objectForKey:kUniqueIDKey];
    }
    else {
        uID = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:uID forKey:kUniqueIDKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //call flurry
    [Flurry startSession:@"5TJ5GGNGYW7S6Z7W7CSW"];
    [Flurry setUserID:uID];
    
    //capture brightness
    _initalBrightness = [UIScreen mainScreen].brightness;
    
    //setup audio session
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayAndRecord
                    error: &setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */ }
    
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                             sizeof (doChangeDefaultRoute),
                             &doChangeDefaultRoute
                             );
    
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
    
    //call appirator
    [Appirater appLaunched:YES];
    [Appirater setAppId:JA_APP_ID];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([notification userInfo] && [[notification userInfo] objectForKey:@"alarm"]) {
        JAAlarm *notificationAlarm = [NSKeyedUnarchiver unarchiveObjectWithData:[[notification userInfo] objectForKey:@"alarm"]];
        
        //if (notificationAlarm)
            //[ClockManager snoozeAlarm:notificationAlarm];
        
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
    
    //call appirator
    [Appirater appEnteredForeground:YES];
    
    //cancel all notificaitons
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //enable or disable alarms with no repeat
    NSArray *temp = [JAAlarm savedAlarms];
    for (JAAlarm *thisAlarm in temp) {
        if (thisAlarm.enabled && thisAlarm.repeatDays.count == 0) {
            
            NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
            NSDate *alarmDate = [calendar dateFromComponents:thisAlarm.timeComponents];
            
            if ([alarmDate compare:[NSDate date]] == NSOrderedAscending) {
                [thisAlarm setEnabled:NO];
                [JAAlarm saveAlarm:thisAlarm];
            }
            
        }
    }
    

    
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
                    
                    //increase the day if it's in the past
                    if ([itemDate compare:[NSDate date]] != NSOrderedAscending) {
                        
                        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                        if (localNotif == nil)
                            return;
                        
                        localNotif.fireDate = itemDate;
                        localNotif.timeZone = [NSTimeZone defaultTimeZone];
                        localNotif.repeatInterval = NSWeekCalendarUnit;
                        localNotif.alertBody = thisAlarm.name;
                        
                        localNotif.soundName = thisAlarm.sound.soundFilename;
                        
                        NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[NSKeyedArchiver archivedDataWithRootObject:thisAlarm] forKey:@"alarm"];
                        localNotif.userInfo = infoDict;
                        
                        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
                        
                    }
                }
            }
            else {
                NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
                NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:[NSDate date]];
                [dateComps setHour:thisAlarm.timeComponents.hour];
                [dateComps setMinute:thisAlarm.timeComponents.minute];
                [dateComps setDay:thisAlarm.timeComponents.day];
                NSDate *itemDate = [calendar dateFromComponents:dateComps];
                
                //increase the day if it's in the past
                if ([itemDate compare:[NSDate date]] != NSOrderedAscending) {
                    
                    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                    if (localNotif == nil)
                        return;
                    localNotif.fireDate = itemDate;
                    localNotif.timeZone = [NSTimeZone defaultTimeZone];
                    localNotif.alertBody = thisAlarm.name;
                    localNotif.repeatInterval = 0;
                    
                    localNotif.soundName = @"Background__Alarm__cut.m4a";
                    
                    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[NSKeyedArchiver archivedDataWithRootObject:thisAlarm] forKey:@"alarm"];
                    localNotif.userInfo = infoDict;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
                    
                }
                
                
            }
        }
    }
    NSLog(@"%@", [ClockManager instance].snoozeAlarms);
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
                    
                    //increase the day if it's in the past
                    if ([itemDate compare:[NSDate date]] != NSOrderedAscending) {
                    
                    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                    if (localNotif == nil)
                        return;
                    
                    localNotif.fireDate = itemDate;
                    localNotif.timeZone = [NSTimeZone defaultTimeZone];
                    localNotif.repeatInterval = NSWeekCalendarUnit;
                    localNotif.alertBody = thisAlarm.name;
                    
                    
                    
                    
                    localNotif.soundName = thisAlarm.sound.soundFilename;
                    
                    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[NSKeyedArchiver archivedDataWithRootObject:thisAlarm] forKey:@"alarm"];
                    localNotif.userInfo = infoDict;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
                        
                    }
                }
            }
            else {
                NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
                NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:[NSDate date]];
                [dateComps setHour:thisAlarm.timeComponents.hour];
                [dateComps setMinute:thisAlarm.timeComponents.minute];
                [dateComps setDay:thisAlarm.timeComponents.day];
                NSDate *itemDate = [calendar dateFromComponents:dateComps];
                
                //increase the day if it's in the past
                if ([itemDate compare:[NSDate date]] != NSOrderedAscending) {
                    
                    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                    if (localNotif == nil)	
                        return;
                    localNotif.fireDate = itemDate;
                    localNotif.timeZone = [NSTimeZone defaultTimeZone];
                    localNotif.alertBody = thisAlarm.name;
                    localNotif.repeatInterval = 0;
                    
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
    
    if ([JASettings flashlightDisabled])
        return;
    
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
