//
//  MKWeatherRequest.m
//  MKKit
//
//  Created by Matthew King on 8/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MKWeatherRequest.h"

#define CURRENT_TIME_STAMP @"currentTimeStamp"
#define FORCAST_TIME_STAMP @"forcastTimeStamp"
#define CACHE_DATA_CURRENT @"cacheDataCurrent"
#define CACHE_DATA_FORCAST @"cacheDataForcast"

@implementation MKWeatherRequest

@synthesize delegate, APIKey=_APIKey, location=_location, type;

@synthesize loadingView=_theLoadingView, errorView=_errorView;

static NSString *baseURL = @"http://www.worldweatheronline.com/feed/weather.ashx";
static NSMutableString *currentString = nil;
static NSString *currentKey = nil;

static BOOL APIError = NO;

#pragma mark -
#pragma mark Initalizers

- (id)initWithLocation:(NSString *)aLocation APIKey:(NSString *)key delegate:(id)aDelegate {
	if (self = [super init]) {
		self.delegate = aDelegate;
		
		_APIKey = [[NSString stringWithFormat:@"key=%@", key] copy]; 
		_location = [[NSString stringWithFormat:@"q=%@", aLocation] copy];
	}
	return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate APIKey:(NSString *)key delegate:(id)aDelegate {
	if (self = [super init]) {
		self.delegate = aDelegate;
				
		_APIKey = [[NSString stringWithFormat:@"key=%@", key] copy];
		
		NSString *longitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
		NSString *latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
		
		_location = [[NSString stringWithFormat:@"q=%@,%@", latitude,longitude] copy];
	}
	return self;
}

#pragma mark -
#pragma mark Instance Methods

#pragma mark Requests

- (void)currentWeather {
	self.type = MKWeatherRequestTypeCurrent;
	APIError = NO;
	
	NSString *url = [[NSString alloc] initWithFormat:@"%@?%@&%@&cc=yes&fx=yes&format=xml&includeLocation=yes", baseURL, _APIKey, _location];
	NSString *codedURL = [url stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	NSURL *theURL = [NSURL URLWithString:codedURL];
	
	[url release];
		
	NSDate *now = [NSDate date];
	
	NSDate *lastRequest = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_TIME_STAMP];
	
	if (lastRequest == nil) {
		[self request:theURL];
	}
	
	if (lastRequest) {
		if ([now timeIntervalSinceDate:lastRequest] > (60.0 * 60.0)) {
			[self request:theURL];
		} else {
			[delegate weatherData:[self cachedRequestData] fromRequest:self];
		}
	}
}

- (void)weatherForcast {
	self.type = MKWeatherRequestTypeForcast;
	APIError = NO;
	
	NSString *url = [[NSString alloc] initWithFormat:@"%@?%@&%@&cc=yes&fx=yes&format=xml&includeLocation=yes&num_of_days=5", baseURL, _APIKey, _location];
	NSString *codedURL = [url stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	NSURL *theURL = [NSURL URLWithString:codedURL];
	
	[url release];
	
	NSDate *now = [NSDate date];
	
	NSDate *lastRequest = [[NSUserDefaults standardUserDefaults] objectForKey:FORCAST_TIME_STAMP];
	
	if (lastRequest == nil) {
		[self request:theURL];
	}
	
	if (lastRequest) {
		if ([now timeIntervalSinceDate:lastRequest] > (60.0 * 60.0)) {
			[self request:theURL];
		} else {
			[delegate weatherData:[self cachedRequestData] fromRequest:self];
		}
	}
}

- (NSArray *)cachedRequestData {
	if (_errorView) {
		[_errorView removeFromSuperview];
		[_errorView release];
	}
	
	//*** DELEGATE CALLS ***//
	if ([delegate respondsToSelector:@selector(didLoadCachedDataFrom:forRequest:)]) {
		NSDate *timeStamp = nil;
		if (type == MKWeatherRequestTypeCurrent) {
			timeStamp = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_TIME_STAMP];
		}
		if (type == MKWeatherRequestTypeForcast) {
			timeStamp = [[NSUserDefaults standardUserDefaults] objectForKey:FORCAST_TIME_STAMP];
		}
		[delegate didLoadCachedDataFrom:timeStamp forRequest:self];
	}
	//*** END DELEGATE CALLS **//
	
	NSArray *data = nil;
	
	if (type == MKWeatherRequestTypeCurrent) {
		data = [[NSUserDefaults standardUserDefaults] objectForKey:CACHE_DATA_CURRENT];
	}
	if (type == MKWeatherRequestTypeForcast) {
		data = [[NSUserDefaults standardUserDefaults] objectForKey:CACHE_DATA_FORCAST];
	}
	
	return data;
}

#pragma mark URL Request 

- (void)request:(NSURL *)url {
	if (_errorView) {
		[_errorView removeFromSuperview];
		[_errorView release];
	}
	
	//*** DELEGATE CALLS ***//
	if ([delegate respondsToSelector:@selector(didRequestWeatherData:)]) {
		[delegate didRequestWeatherData:self];
	}
	
	if ([delegate respondsToSelector:@selector(shouldDisplayLoadingViewForRequest:)]) {
		if ([delegate shouldDisplayLoadingViewForRequest:self]) {
			CGRect viewFrame;
			
			if ([delegate respondsToSelector:@selector(loadingViewFrameForRequest:)]) {
				viewFrame = [delegate loadingViewFrameForRequest:self];
			} else {
				viewFrame = CGRectMake(0.0, 0.0, 130.0, 77.0);
			}
					
			_theLoadingView = [[[MKWeatherLoadingView alloc] initWithFrame:viewFrame] retain];
			_theLoadingView.loadingLabel.text = @"Loading...";
				
			if ([delegate isKindOfClass:[UIView class]]) {
				[delegate addSubview:_theLoadingView];
			}
		}
	}
	//*** END DELEGATE CALLS **//
	
	theRequest = [[NSMutableURLRequest alloc] initWithURL:url];
	 
	theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	if (theConnection) {
		receivedData=[[NSMutableData data] retain];
	} else {
		NSError *error = [NSError errorWithDomain:NO_CONNECTION code:100 userInfo:nil];
		[self notificationOfError:error];
	}	
}

#pragma mark Error Handeling

- (void)notificationOfError:(NSError *)error {
	//*** DELEGATE CALLS ***//
	if ([delegate respondsToSelector:@selector(request:didError:)]) {
		[delegate request:self didError:error];
	}
	
	if ([delegate respondsToSelector:@selector(shouldDisplayErrorViewForRequest:)]) {
		if ([delegate shouldDisplayErrorViewForRequest:self]) {
			CGRect viewFrame;
			
			if ([delegate respondsToSelector:@selector(errorViewFrameForRequest:)]) {
				viewFrame = [delegate errorViewFrameForRequest:self];
			} else {
				viewFrame = CGRectMake(0.0, 0.0, 130.0, 77.0);
			}
			
			_errorView = [[[MKWeatherErrorView alloc] initWithFrame:viewFrame] retain];
			_errorView.errorDiscription = [error localizedDescription];
			_errorView.request = self;
			
			if ([delegate isKindOfClass:[UIView class]]) {
				[delegate addSubview:_errorView];
				
				if (_theLoadingView) {
					[_theLoadingView removeFromSuperview];
					[_theLoadingView release];
				}
			}
		}
	}
	
	if ([delegate respondsToSelector:@selector(shouldLoadCachedDataOnError:forRequest:)]) {
		if ([delegate shouldLoadCachedDataOnError:error forRequest:self]) {
			[delegate weatherData:[self cachedRequestData] fromRequest:self];
		}
	}
	//*** END DELEGATE CALLS ***//	
}	

#pragma mark -
#pragma mark Delegates

#pragma mark Connection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSHTTPURLResponse *HTTPResponse = [response copyWithZone:NULL];
	BOOL isError = NO;
	
	if ([HTTPResponse statusCode] == 304) {
		[delegate weatherData:[self cachedRequestData] fromRequest:self];
	} 
	
	[HTTPResponse release];
	
	if (isError) {
		NSError *error = [NSError errorWithDomain:HTTP_ERROR code:200 userInfo:nil];
		[self notificationOfError:error];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[connection release];
	[receivedData release];
	[theRequest release];
	
	[self notificationOfError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	aParser = [[NSXMLParser alloc] initWithData:receivedData];
	aParser.delegate = self;
	[aParser parse];
	
	[theConnection release];
	[receivedData release];
	[theRequest release];
}

#pragma mark XMLParser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"data"]) {
		if (!weatherData) {
			weatherData = [[[NSMutableArray alloc] initWithCapacity:2] retain];
		}
	} else if ([elementName isEqualToString:@"nearest_area"]) {
		if (!weatherDict) {
			weatherDict = [[NSMutableDictionary alloc] initWithCapacity:5];
		}
	} else if ([elementName isEqualToString:@"current_condition"]) {
		if (!weatherDict) {
			weatherDict = [[NSMutableDictionary alloc] initWithCapacity:15];
		}
	} else if ([elementName isEqualToString:@"weather"]) {
		if (!weatherDict) {
			weatherDict = [[NSMutableDictionary alloc] initWithCapacity:15];
		}
	} else if ([elementName isEqualToString:@"error"]) {
		currentKey = nil;
	} else if ([elementName isEqualToString:@"msg"]) {
		currentKey = nil;
	} else {
		currentKey = elementName;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (!currentString) {
		currentString = [[NSMutableString alloc] initWithCapacity:12];
	}
	
	[currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
	if (!currentString) {
		currentString = [[NSMutableString alloc] initWithData:CDATABlock encoding:NSMacOSRomanStringEncoding];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"nearest_area"]) {
		[weatherData addObject:weatherDict];
		
		[weatherDict release];
		weatherDict = nil;
	} else if ([elementName isEqualToString:@"current_condition"]) {
		[weatherData addObject:weatherDict];
		
		[weatherDict release];
		weatherDict = nil;
	} else if ([elementName isEqualToString:@"weather"]) {
		[weatherData addObject:weatherDict];
		
		[weatherDict release];
		weatherDict = nil;
	} else if ([elementName isEqualToString:@"data"]) {
		if ([weatherData count] < 2) {
			APIError = YES;
			
			NSError *error = [NSError errorWithDomain:API_ERROR_NO_DATA code:402 userInfo:nil];
			[self notificationOfError:error];
		}
	} else if ([elementName isEqualToString:@"error"]) {
		APIError = YES;
	} else if ([elementName isEqualToString:@"msg"]) {
		NSError *error = [NSError errorWithDomain:currentString code:400 userInfo:nil];
		[self notificationOfError:error];
	} else {
		[weatherDict setObject:currentString forKey:currentKey];
	}

	[currentString release];
	currentString = nil;
	currentKey = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	//*** DELEGATE CALLS ***//
	if ([delegate respondsToSelector:@selector(shouldDisplayLoadingViewForRequest:)]) {
		if ([delegate shouldDisplayLoadingViewForRequest:self]) {
			[_theLoadingView removeFromSuperview];
			if (_theLoadingView) {
				//[_theLoadingView release];
			}
		}
	}
	
	//*** END DELEGATE CALLS ***//
	
	if (!APIError) {
		[delegate weatherData:weatherData fromRequest:self];
			
		if (type == MKWeatherRequestTypeCurrent) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:CURRENT_TIME_STAMP];
			[[NSUserDefaults standardUserDefaults] setObject:weatherData forKey:CACHE_DATA_CURRENT];
		}
		if (type == MKWeatherRequestTypeForcast) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:FORCAST_TIME_STAMP];
			[[NSUserDefaults standardUserDefaults] setObject:weatherData forKey:CACHE_DATA_FORCAST];
		}
	}
	
	[weatherData release];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSError *error = [NSError errorWithDomain:PARSE_ERROR code:300 userInfo:nil];
	[self notificationOfError:error];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[super dealloc];
	
//    if (baseURL != nil)
//        [baseURL release];
//	
//    if (delegate != nil)
//        [delegate release];
//	
//    if (_APIKey != nil)
//        [_APIKey release];
//
//    if (_location != nil)
//        [_location release];
}

@end

