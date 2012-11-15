//
//  MKClock.h
//  MKKit
//
//  Created by Matthew King on 1/28/10.
//  Copyright 2010-2011 Matt King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKObject.h"

@protocol MKClockDelegate;

/**------------------------------------------------------------------------------------------
 The MKClock class is used to run a timer clock.  Once the clock is initalized caling the start method
 will make it start counting. The clock will start to return delegate methods giving a NSString that tells
 the current time on the clock. This clock start couniting from `0:00` and contunies up unitl the stop method
 is called.
--------------------------------------------------------------------------------------------*/

@interface MKClock : MKObject {
	NSTimer *timer;
	id delegate;
	
	NSInteger _seconds;
	NSInteger _minutes;
}

///------------------------------------
/// @name Initalizing
///------------------------------------

/** Initalize and set the delegate.
 
 @param theDelegate An object that conforms to the MKClockDelegate protocol.
*/
- (id)initWithDelegate:(id<MKClockDelegate>)theDelegate;

///------------------------------------
/// @name Contorlling the Clock
///------------------------------------

/** Starts the Clock */
- (void)start;

/** Stops the Clock */
- (void)stop;

///-------------------------------------
/// @name Accessing the clock values
///-------------------------------------

/** The current seconds value of the clocck */
@property (nonatomic, assign, readonly) NSInteger seconds;

/** The current minutes value of the clock */
@property (nonatomic, assign, readonly) NSInteger minutes;

///-------------------------------------
/// @name The Timer
///-------------------------------------

/** The NSTimer that is controlling the clock */
@property (nonatomic, retain) NSTimer *timer;

///-------------------------------------
/// @name Delegate
///-------------------------------------

/** An MKClockDelegate */
@property (nonatomic, assign) id<MKClockDelegate> delegate;	

@end

/**------------------------------------------------------------------------------------------
 The MKClockDelegate protocol send information about an instance of MKClock. These methods can be used
 to monitor the clocks activity and get the clocks time. Class that use this must conform to the 
 MKClockDelegate protocol.  All of this delegates methods are optional.
--------------------------------------------------------------------------------------------*/

@protocol MKClockDelegate <NSObject>

@optional

///-----------------------------------
/// @name Monitoring clock behaviors
///-----------------------------------

/** Called when the clock starts. 
 
 @param clock The MKClock the started.
*/
- (void)clockDidStart:(MKClock *)clock;

/** Called when the clock stops. 
 
 @param clock The clock that stoped
*/
- (void)clockDidStop:(MKClock *)clock;

///---------------------------------------
/// @name Geting the clocks current time
///---------------------------------------

/** Called when the timer sets a new string. This method is called every time a clocks time changes. The new time
 is sent in the form of an NSString with this format `0:00`.
 
 @param clock The clock that set a new string.
 @param theString The new string set by the clock.
*/
- (void)clock:(MKClock *)clock didSetNewString:(NSString *)theString;

@end
