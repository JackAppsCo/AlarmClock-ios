//
//  MKWeatherErrorView.h
//  MKKit
//
//  Created by Matthew King on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKWeatherRequest.h"

@class MKWeatherRequest;

@interface MKWeatherErrorView : UIView <UIAlertViewDelegate> {
}

@property (nonatomic, copy) NSString *errorDiscription;				//Discription of the error
@property (nonatomic, retain) MKWeatherRequest *request;			//Request that encountered an error

@end
