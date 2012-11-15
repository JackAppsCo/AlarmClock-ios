//
//  MKWeatherLoadingView.h
//  MKKit
//
//  Created by Matthew King on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MKWeatherLoadingView : UIView {
	UILabel *_loadingLabel;
}

@property (nonatomic, retain) UILabel *loadingLabel;     //Text to display while weather request is loading

@end
