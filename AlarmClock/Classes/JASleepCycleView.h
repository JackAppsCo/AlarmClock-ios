//
//  JASleepCycleView.h
//  AlarmClock
//
//  Created by Brian Singer on 12/20/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JASleepCycleView : UIView


@property (strong, nonatomic) UISegmentedControl *sleepWakeControl;
@property (strong, nonatomic) UIButton *timeButton, *createButton;
@property (strong, nonatomic) UIBarButtonItem *dateDoneButton;
@property (strong, nonatomic) UITableView *timesTableView;
@property (strong, nonatomic) UILabel *sleepLabel;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIToolbar *dateToolbar;

- (void) raisePicker;
- (void) lowerPicker;
- (void) togglePicker;

@end
