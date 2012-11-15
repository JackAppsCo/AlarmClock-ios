//
//  MKWeatherErrorView.m
//  MKKit
//
//  Created by Matthew King on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MKWeatherErrorView.h"


@implementation MKWeatherErrorView

@synthesize errorDiscription, request;

#pragma mark -
#pragma mark Initalizer

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
		
		UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 15.0, 90.0, 33.0)];
		errorLabel.backgroundColor = [UIColor clearColor];
		errorLabel.textColor = [UIColor whiteColor];
		errorLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:24.0];
		errorLabel.text = @"Error";
		
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.0, 56.0, 122.0, 15.0)];
		infoLabel.backgroundColor = [UIColor clearColor];
		infoLabel.textColor = [UIColor whiteColor];
		infoLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:10.0];
		infoLabel.text = @"Tap for details.";
		
		[self addSubview:errorLabel];
		[self addSubview:infoLabel];
		
		[errorLabel release];
		[infoLabel release];
    }
    return self;
}

#pragma mark -
#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	NSInteger tapCount = [touch tapCount];
	
	if (tapCount == 1) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OPPS" message:errorDiscription delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
		[alert addButtonWithTitle:@"Retry"];
		[alert addButtonWithTitle:@"Load Last"];
		[alert addButtonWithTitle:@"Cancel"];
		[alert dismissWithClickedButtonIndex:2 animated:YES];
		[alert show];
		[alert release];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		if (request.type == MKWeatherRequestTypeCurrent) {
			[request currentWeather];
		}
		if (request.type == MKWeatherRequestTypeForcast) {
			[request weatherForcast];
		}
	}
	
	if (buttonIndex == 1) {
		[request.delegate weatherData:[request cachedRequestData] fromRequest:request];
		[self removeFromSuperview];
	}
}

#pragma mark -
#pragma mark Memory Managment

- (void)dealloc {
    [super dealloc];
	
}


@end
