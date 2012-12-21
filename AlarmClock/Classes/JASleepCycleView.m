//
//  JASleepCycleView.m
//  AlarmClock
//
//  Created by Brian Singer on 12/20/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JASleepCycleView.h"

@implementation JASleepCycleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor whiteColor]];
        
        //sleep control
        [self setSleepWakeControl:[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Wake By", nil), NSLocalizedString(@"Sleep By", nil), nil]]];
        [self.sleepWakeControl setFrame:CGRectMake(15, 15, frame.size.width - 30, 40)];
        [self.sleepWakeControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [self.sleepWakeControl setSelectedSegmentIndex:0];
        

        
        //time button
        [self setTimeButton:[UIButton buttonWithType:UIButtonTypeRoundedRect]];
        [self.timeButton setFrame:CGRectOffset(self.sleepWakeControl.frame, 0, self.sleepWakeControl.frame.size.height + 15)];
        [self.timeButton setBackgroundColor:[UIColor whiteColor]];
        [self.timeButton setTitle:@"Select a Time" forState:UIControlStateNormal];
        [self.timeButton addTarget:self action:@selector(togglePicker) forControlEvents:UIControlEventTouchUpInside];
        [self.timeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.timeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        
        //label
        [self setSleepLabel:[[UILabel alloc] initWithFrame:CGRectMake(15, self.timeButton.frame.size.height + self.timeButton.frame.origin.y + 15, frame.size.width - 30, 50)]];
        [self.sleepLabel setBackgroundColor:[UIColor clearColor]];
        [self.sleepLabel setNumberOfLines:0];
        [self.sleepLabel setText:@"THIS IS THE LABEL/nLINE TWO"];
        
        //table
        [self setTimesTableView:[[UITableView alloc] initWithFrame:CGRectMake(15, self.sleepLabel.frame.size.height + self.sleepLabel.frame.origin.y + 15, frame.size.width - 30, frame.size.height - (self.sleepLabel.frame.size.height + self.sleepLabel.frame.origin.y + 100))]];
        [self.timesTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self.timesTableView setAlpha:0.0];
         
        //create button
        [self setCreateButton:[UIButton buttonWithType:UIButtonTypeRoundedRect]];
        [self.createButton setFrame:CGRectMake(15, self.timesTableView.frame.size.height + self.timesTableView.frame.origin.y + 15, frame.size.width - 30, 45.0)];
        [self.createButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [self.createButton setTitle:NSLocalizedString(@"Create Alarm", nil) forState:UIControlStateNormal];
        [self.createButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [self.createButton setEnabled:NO];
        
        
        
        //setup companies toolbar
        [self setDateToolbar:[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 35.0)]];
        UIBarButtonItem *flexSpace3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [self setDateDoneButton:[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(lowerPicker)]];
        [self.dateToolbar setItems:[NSArray arrayWithObjects:flexSpace3, self.dateDoneButton, nil]];
        
        //date picker
        [self setDatePicker:[[UIDatePicker alloc] init]];
        [self.datePicker setDatePickerMode:UIDatePickerModeTime];
        CGRect pickerFrame = self.datePicker.frame;
        pickerFrame.origin.y = self.frame.size.height + self.dateToolbar.frame.size.height;
        [self.datePicker setFrame:pickerFrame];
        
        //add subview
        [self addSubview:self.sleepWakeControl];
        [self addSubview:self.timeButton];
        [self addSubview:self.sleepLabel];
        [self addSubview:self.timesTableView];
        [self addSubview:self.createButton];
        [self addSubview:self.datePicker];
        [self addSubview:self.dateToolbar];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark - Date Picker
- (void) togglePicker
{
    if (self.dateToolbar.frame.origin.y < self.frame.size.height) {
        [self lowerPicker];
    }
    else {
        [self raisePicker];
    }
    
}

- (void) raisePicker
{
    [UIView animateWithDuration:0.3f
                     animations:^{
  
                         self.dateToolbar.frame = CGRectMake(0, self.frame.size.height - self.datePicker.frame.size.height - self.dateToolbar.frame.size.height, self.frame.size.width, self.dateToolbar.frame.size.height);
                         self.datePicker.frame = CGRectMake(0, self.frame.size.height - self.datePicker.frame.size.height, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void) lowerPicker
{
    [UIView animateWithDuration:0.3f
                     animations:^{

                         self.dateToolbar.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.dateToolbar.frame.size.height);
                         self.datePicker.frame = CGRectMake(0, self.frame.size.height + self.dateToolbar.frame.size.height, self.datePicker.frame.size.width, self.datePicker.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    

}


@end
