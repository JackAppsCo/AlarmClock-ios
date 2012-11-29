//
//  JASettings.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/22/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JASettings.h"

static JASettings *sharedInstance = nil;

#define BG_KEY @"backgroundImage"
#define BG_NAME_KEY @"backgroundImageName"
#define COLOR_KEY @"clockColor"
#define COLOR_NAME_KEY @"clockColorName"
#define SECONDS_KEY @"showSeconds"
#define DATE_KEY @"showDate"

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
        image = [UIImage imageNamed:[[NSUserDefaults standardUserDefaults] objectForKey:BG_KEY]];
    }
    
    return image;
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
        
        if ([clockColorStr isEqualToString:@"White"]) {
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
        }
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
    
    return showSeconds;
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
    
    return showDate;
}

+ (void) setShowDate:(BOOL)show
{
    
    [[NSUserDefaults standardUserDefaults] setBool:show forKey:DATE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
