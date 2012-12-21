//
//  JASleepCycleViewController.h
//  AlarmClock
//
//  Created by Brian Singer on 12/20/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASleepCycleView.h"

@interface JASleepCycleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSDateFormatter *_formatter;    
}
@property (strong, nonatomic) JASleepCycleView *sleepView;
@property (strong, nonatomic) NSDateComponents *timeComponents;

- (void) createButtonPressed:(id)sender;
- (void)dateChanged:(id)sender;


@end
