//
//  MKWeatherRequest.h
//  MKKit
//
//  Created by Matthew King on 8/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MKWeatherLoadingView.h"
#import "MKWeatherErrorView.h"
#import "MKWeatherRequestErrorCodes.h"
#import "MKWeatherRequestDelegate.h"
#import "MKWeatherRequestKeys.h"

typedef enum {
	MKWeatherRequestTypeCurrent,
	MKWeatherRequestTypeForcast,
} MKWeatherRequestType;

@class MKWeatherLoadingView;
@class MKWeatherErrorView;

@protocol MKWeatherRequestDelegate;

@interface MKWeatherRequest : NSObject <NSXMLParserDelegate> {
	id delegate;
	NSString *_APIKey;
	NSString *_location;
	MKWeatherRequestType type;
	
	MKWeatherLoadingView *_theLoadingView;
	MKWeatherErrorView *_errorView;
	
	@private
	NSMutableData *receivedData;
	NSMutableURLRequest *theRequest;
	NSURLConnection *theConnection;
	
	NSXMLParser *aParser;
	NSMutableArray *weatherData;
	NSMutableDictionary *weatherDict;
}

@property (nonatomic, retain) id<MKWeatherRequestDelegate> delegate;			//Weather Request Delegate
@property (nonatomic, copy, readonly) NSString *APIKey;							//WorldWeatherOnline API Key
@property (nonatomic, copy, readonly) NSString *location;						//User location
@property (nonatomic, assign) MKWeatherRequestType type;						//The Request Type

@property (nonatomic, retain, readonly) MKWeatherLoadingView *loadingView;		//Instance of the loading view
@property (nonatomic, retain, readonly) MKWeatherErrorView *errorView;			//Instance of the error view

//** Returns a weather object from a Location.
- (id)initWithLocation:(NSString *)aLocation APIKey:(NSString *)key delegate:(id)aDelegate;

//** Returns a weather object using Core Location
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate APIKey:(NSString *)key delegate:(id)aDelegate;

//** Requests the current weather
- (void)currentWeather;

//** Request the Forcast up to 5 days out
- (void)weatherForcast;

//** Returns Cached Data
- (NSArray *)cachedRequestData;

///*** THESE METHODS SHOULD NOT BE CALLED DIRECTLY ***///

//** Requests the given URL
- (void)request:(NSURL *)url;

//** Sends and error Notification to the Delegate
- (void)notificationOfError:(NSError *)error;

@end