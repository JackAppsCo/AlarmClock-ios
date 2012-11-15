//
//  MKClock.m
//  MKKit
//
//  Created by Matthew King on 1/28/10.
//  Copyright 2010-2011 Matt King. All rights reserved.
//

#import "MKClock.h"

@interface MKClock ()

- (void)timerFireMethod:(NSTimer *)theTimer;

@end


@implementation MKClock

@synthesize timer, delegate;

@synthesize seconds, minutes;

#pragma mark --
#pragma mark Initalization

- (id)initWithDelegate:(id<MKClockDelegate>)theDelegate {
	self = [super init];
	if (self) {
		if (theDelegate) {
			[self setDelegate:theDelegate];
		}
		
		timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
		
		_seconds = 0;
		_minutes = 0;
	}	
	return self;
}

#pragma mark --
#pragma mark Run Loop

//** Call to start the Clock
- (void)start {
	[timer fire];
	
	if ([delegate respondsToSelector:@selector(clcokDidStart:)]) {
		[delegate clockDidStart:self];
	}
}

//** Call to stop the Clock
- (void)stop {
	[timer invalidate];
	
	if ([delegate respondsToSelector:@selector(clockDidStop:)]) {
		[delegate clockDidStop:self];
	}
}

//** Timer Fire method
- (void)timerFireMethod:(NSTimer *)theTimer {
	if (_seconds == 59) {
		_seconds = 0;
		_minutes++;
	}
	else {
		_seconds++;
	}
	
	NSString *secondsString = nil;
	
	if (_seconds < 10) {
		secondsString = [NSString stringWithFormat:@"0%i", _seconds];
	}
	else {
		secondsString = [NSString stringWithFormat:@"%i", _seconds];	
	}
	
	NSString *clock = [[NSString alloc] initWithFormat:@"%i:%@", _minutes, secondsString];
		
	if ([delegate respondsToSelector:@selector(clock:didSetNewString:)]) {
		[delegate clock:self didSetNewString:clock];
	}
	
	[clock release];
}

#pragma mark --
#pragma mark Memory Management

- (void)dealloc {
	[super dealloc];
	
	[timer release];
}

@end
