//
//  JASettings.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/22/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JASettings.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+fixOrientation.h"

static JASettings *sharedInstance = nil;

#define BG_KEY @"backgroundImage"
#define BG_NAME_KEY @"backgroundImageName"
#define COLOR_KEY @"clockColor"
#define COLOR_NAME_KEY @"clockColorName"
#define SECONDS_KEY @"showSeconds"
#define DATE_KEY @"showDate"
#define FARENHEIT_KEY @"farenheight"
#define ALARMS_ENABLED_KEY @"alarmsEnabled"
#define SLEEP_LENGTH_KEY @"sleepLength"
#define SLEEP_SOUND_KEY @"sleepSound"
#define SHINE_KEY @"riseAndShine"

#define CLOCK_COLORS [NSArray arrayWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:[UIColor whiteColor], @"color", @"White", @"name", nil], [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor], @"color", @"Black", @"name", nil], [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor yellowColor], @"color", @"Yellow", @"name", nil], [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor colorWithRed:141.0/255.0 green:192.0/255.0 blue:236.0/255.0 alpha:1.0], @"color", @"Light Blue", @"name", nil], [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor colorWithRed:7.0/255.0 green:47.0/255.0 blue:81.0/255.0 alpha:1.0], @"color", @"Blue", @"name", nil], [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor colorWithRed:255.0/255.0 green:162.0/255.0 blue:0.0/255.0 alpha:1.0], @"color", @"Orange", @"name", nil], [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor colorWithRed:53.0/255.0 green:123.0/255.0 blue:53.0/255.0 alpha:1.0], @"color", @"Green", @"name", nil], nil]

@implementation JASettings

- (id) init
{
    if ((self = [super init])) {
        
    }
    
    return self;
}

+ (UIImage *)backgroundImage
{
    UIImage *image = [UIImage imageNamed:@"BlackBG"];

    //check for bg image
    if ([[NSUserDefaults standardUserDefaults] objectForKey:BG_KEY]) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:BG_KEY] rangeOfString:@"custom"].location != NSNotFound) {
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
            NSString *filePath = [documentsPath stringByAppendingPathComponent:@"customBG.png"]; //Add the file name
            NSData *pngData = [NSData dataWithContentsOfFile:filePath];
            image = [UIImage imageWithData:pngData];

            
        }
        else {
            image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:BG_KEY]];
        }
    }
    
    return [image  normalizedImage];
}

+ (void) setBackgroundImage:(NSString*)image
{

    [[NSUserDefaults standardUserDefaults] setObject:image forKey:BG_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (NSString *)backgroundImageName
{
    NSString *imageName = @"Default";
    
    //check for bg image name
    if ([[NSUserDefaults standardUserDefaults] objectForKey:BG_NAME_KEY]) {
        imageName = [[NSUserDefaults standardUserDefaults] objectForKey:BG_NAME_KEY];
    }
    
    return imageName;
}

+ (void) setBackgroundImageName:(NSString*)imageName
{
    
    [[NSUserDefaults standardUserDefaults] setObject:imageName forKey:BG_NAME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (UIColor*) clockColor
{
    UIColor *clockColor = [UIColor whiteColor];
    
    //check for bg image name
    if ([[NSUserDefaults standardUserDefaults] valueForKey:COLOR_NAME_KEY]) {
        NSString *clockColorStr = [[NSUserDefaults standardUserDefaults] valueForKey:COLOR_NAME_KEY];
        
        for (NSDictionary *color in CLOCK_COLORS) {
            if ([[color objectForKey:@"name"] isEqualToString:clockColorStr])
                clockColor = [color objectForKey:@"color"];
        }
        
        /*if ([clockColorStr isEqualToString:@"White"]) {
            clockColor = [UIColor whiteColor];
        }
        else if ([clockColorStr isEqualToString:@"Black"]) {
            clockColor = [UIColor blackColor];
        }
        else if ([clockColorStr isEqualToString:@"Yellow"]) {
            clockColor = [UIColor yellowColor];
        }
        else if ([clockColorStr isEqualToString:@"Green"]) {
            clockColor = [UIColor greenColor];
        }
        else if ([clockColorStr isEqualToString:@"Blue"]) {
            clockColor = [UIColor blueColor];
        }*/
    }
    
    return clockColor;
}

+ (NSString*) clockColorName
{
    NSString *clockColorName = @"White";
    
    //check for bg image name
    if ([[NSUserDefaults standardUserDefaults] objectForKey:COLOR_NAME_KEY]) {
        clockColorName = [[NSUserDefaults standardUserDefaults] objectForKey:COLOR_NAME_KEY];
    }
    
    return clockColorName;
}

+ (void) setClockColorName:(NSString*)cColorName
{
    
    [[NSUserDefaults standardUserDefaults] setObject:cColorName forKey:COLOR_NAME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (BOOL) showSeconds
{
    BOOL showSeconds = NO;
    
    //check for bg image name
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SECONDS_KEY]) {
        showSeconds = [[NSUserDefaults standardUserDefaults] boolForKey:SECONDS_KEY];
    }
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:SECONDS_KEY];
}

+ (void) setShowSeconds:(BOOL)show
{

    [[NSUserDefaults standardUserDefaults] setBool:show forKey:SECONDS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (BOOL) showDate
{
    BOOL showDate = NO;
    
    //check for bg image name
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DATE_KEY]) {
        showDate = [[NSUserDefaults standardUserDefaults] boolForKey:DATE_KEY];
    }
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:DATE_KEY];
}

+ (void) setShowDate:(BOOL)show
{
    
    [[NSUserDefaults standardUserDefaults] setBool:show forKey:DATE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (BOOL) farenheit
{
    BOOL far = NO;
    
    //check for bg image name
    if ([[NSUserDefaults standardUserDefaults] boolForKey:FARENHEIT_KEY]) {
        far = [[NSUserDefaults standardUserDefaults] boolForKey:FARENHEIT_KEY];
    }
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:FARENHEIT_KEY];
}

+ (void) setFarenheit:(BOOL)farenheit
{
    [[NSUserDefaults standardUserDefaults] setBool:farenheit forKey:FARENHEIT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) alarmsEnabled
{
    BOOL en = YES;
    
    //check for bg image name
    if ([[NSUserDefaults standardUserDefaults] boolForKey:ALARMS_ENABLED_KEY]) {
        en = [[NSUserDefaults standardUserDefaults] boolForKey:ALARMS_ENABLED_KEY];
    }
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:ALARMS_ENABLED_KEY];
}

+ (void) setAlarmsEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:ALARMS_ENABLED_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (int) sleepLength
{
    int len = 10;
    
    //check for bg image name
    if ([[NSUserDefaults standardUserDefaults] integerForKey:SLEEP_LENGTH_KEY]) {
        len = [[NSUserDefaults standardUserDefaults] integerForKey:SLEEP_LENGTH_KEY];
    }
    
    return len;
}

+ (void) setSleepLength:(int)length
{
    [[NSUserDefaults standardUserDefaults] setInteger:length forKey:SLEEP_LENGTH_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)sleepSound
{
    NSDictionary * sound = [[NSDictionary alloc] initWithObjectsAndKeys:@"", @"", @"", @"", nil];
    
    //check for bg image name
    if ([[NSUserDefaults standardUserDefaults] objectForKey:SLEEP_SOUND_KEY]) {
        sound = [[NSUserDefaults standardUserDefaults] objectForKey:SLEEP_SOUND_KEY];
    }
    
    return sound;
}

+ (void) setSleepSound:(NSDictionary*)sleepSound
{
    [[NSUserDefaults standardUserDefaults] setObject:sleepSound forKey:SLEEP_SOUND_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) setShine:(BOOL)shine
{
    [[NSUserDefaults standardUserDefaults] setBool:shine forKey:SHINE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) shine
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SHINE_KEY];
}

#pragma mark - Class Methods

+ (JASettings *)instance {
	@synchronized(self)	{
		//initialize the shared singleton if it has not yet been created
		if (sharedInstance == nil) {
			sharedInstance = [[JASettings alloc] init];
		}
	}
	return sharedInstance;
}

@end
