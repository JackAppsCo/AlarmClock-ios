//
//  MKWeatherRequestDelegate.h
//  MKKit
//
//  Created by Matthew King on 9/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKWeatherRequest.h"

@class MKWeatherRequest;

@protocol MKWeatherRequestDelegate <NSObject>

//*** REQUIRED ***//

//** Called when weather data is ready
- (void)weatherData:(NSArray *)data fromRequest:(MKWeatherRequest *)request;

@optional

//** Called when a weather data request is made
- (void)didRequestWeatherData:(MKWeatherRequest *)request;

//** Called when cached Data is loaded
- (void)didLoadCachedDataFrom:(NSDate *)date forRequest:(MKWeatherRequest *)request;

//** Return Yes to load cached data in the event of an error
- (BOOL)shouldLoadCachedDataOnError:(NSError *)error forRequest:(MKWeatherRequest *)request;

//** Called when a request Errors
- (void)request:(MKWeatherRequest *)request didError:(NSError *)error;

////////////////** ONLY USE IS DELEGATE IS A SUBCLASS OF UIVIEW **////////////////////////////

//** Return Yes to display loading indicator while waiting for the request
- (BOOL)shouldDisplayLoadingViewForRequest:(MKWeatherRequest *)request;

//** Return the Frame to display the loading view Defalt is (0.0, 0.0, 130.0, 77.0)
- (CGRect)loadingViewFrameForRequest:(MKWeatherRequest *)request;

//** Return Yes to display an error view if th and error occours
- (BOOL)shouldDisplayErrorViewForRequest:(MKWeatherRequest *)request;

//** Return the Frame to display the error view Defalt is (0.0, 0.0, 130.0, 77.0)
- (CGRect)errorViewFrameForRequest:(MKWeatherRequest *)request;

@end