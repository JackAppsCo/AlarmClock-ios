//
//  MKWeatherRequestErrorCodes.h
//  MKKit
//
//  Created by Matthew King on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NO_CONNECTION @"100 Connection cannot be made"
#define CONNECTION_ERROR @"102 Error with connection"
#define CONNECTION_TIME_OUT @"104 Connection timed out"

#define HTTP_ERROR @"200 Error communicating with server"

#define PARSE_ERROR @"300 XML Parsing error"

#define API_ERROR @"400 Incorect API code presented"
#define API_ERROR_NO_DATA @"402 No data was able to be retrived"