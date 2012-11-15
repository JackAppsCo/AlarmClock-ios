//
//  MKWeatherLoadingView.m
//  MKKit
//
//  Created by Matthew King on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MKWeatherLoadingView.h"


@implementation MKWeatherLoadingView

@synthesize loadingLabel=_loadingLabel;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(45.0, 11.0, 37.0, 37.0)];
		activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
		[activityIndicator startAnimating];
		
		_loadingLabel = [[[UILabel alloc] initWithFrame:CGRectMake(2.0, 56.0, 122.0, 15.0)] retain];
		_loadingLabel.backgroundColor = [UIColor clearColor];
		_loadingLabel.textColor = [UIColor whiteColor];
		_loadingLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:10.0];
		_loadingLabel.textAlignment = UITextAlignmentCenter;
		
		[self addSubview:activityIndicator];
		[self addSubview:_loadingLabel];
		
		[activityIndicator release];
		[_loadingLabel release];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


@end
