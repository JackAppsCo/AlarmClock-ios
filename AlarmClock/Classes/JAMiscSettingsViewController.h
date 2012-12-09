//
//  JAMiscSettingsViewController.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/28/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAMiscSettingsViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) UISegmentedControl *weatherSwitch;
@property (strong, nonatomic) UITextField *sleepLengthField;

@end
