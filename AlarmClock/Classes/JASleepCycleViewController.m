//
//  JASleepCycleViewController.m
//  AlarmClock
//
//  Created by Brian Singer on 12/20/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JASleepCycleViewController.h"
#import "JAAlarm.h"
#import "JAAlarmSettingsController.h"

@interface JASleepCycleViewController ()
- (void)controlChanged:(id)sender;
@end

@implementation JASleepCycleViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [self setSleepView:[[JASleepCycleView alloc] initWithFrame:self.view.frame]];
        self.view = self.sleepView;
        
        [self.sleepView.createButton addTarget:self action:@selector(createButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.sleepView.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self.sleepView.sleepWakeControl addTarget:self action:@selector(controlChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self.sleepView.timesTableView setDelegate:self];
        [self.sleepView.timesTableView setDataSource:self];
        
        //date formatter
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"h:mm a"];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    self.sleepView.sleepLabel.text = NSLocalizedString(@"You try to fall asleep at one of these times:", nil);
    self.sleepView.createButton.enabled = NO;
    
    [self.sleepView.timesTableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.sleepView.timeButton.titleLabel.text.length == 0) {
        [self.sleepView.datePicker setDate:[NSDate dateWithTimeInterval:(60 * 10) sinceDate:[NSDate date]]];
        [self.sleepView.timeButton.titleLabel setText:[_formatter stringFromDate:self.sleepView.datePicker.date]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) createButtonPressed:(id)sender
{
    JAAlarm *_alarm = [[JAAlarm alloc] init];
    _alarm.alarmID = [NSNumber numberWithInt:-1];
    _alarm.enabled = YES;
    _alarm.gradualSound = YES;
    _alarm.repeatDays = [[NSArray alloc] init];
    _alarm.sound = [JASound defaultSound];
    _alarm.name = @"Sleep Smart Alarm";
    _alarm.snoozeTime = [NSNumber numberWithInt:10];
    
    //time comps
    NSDate *alarmDate;
    if (self.sleepView.sleepWakeControl.selectedSegmentIndex == 0) {
        alarmDate = self.sleepView.datePicker.date;
    }
    else {
        int timeInterval = (60 * 90) * (10 - [self.sleepView.timesTableView indexPathForSelectedRow].row);
        alarmDate = [NSDate dateWithTimeInterval:timeInterval sinceDate:self.sleepView.datePicker.date];
    }
    
    //set time components
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:alarmDate];
    [timeComponents setSecond:0];
    _alarm.timeComponents = timeComponents;
    
    
    //Alarm Settings View
    JAAlarmSettingsController *newAlarmController =[[JAAlarmSettingsController alloc] initWithAlarm:_alarm];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleDone target:self action:@selector(dismissModalViewControllerAnimated:)];
    [saveButton setTitle:NSLocalizedString(@"Save", nil)];
    [newAlarmController.navigationItem setLeftBarButtonItem:saveButton];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newAlarmController];
    [self presentViewController:navController animated:YES completion:nil];
    
    
}

//set the alarm's date
- (void)dateChanged:(id)sender
{
    self.sleepView.timesTableView.alpha = 1;
    
    if (self.sleepView.sleepWakeControl.selectedSegmentIndex == 0) {
        
        
        //break the chosen date down so we just have the hour and minute with a zero'd seconds
        NSDate *theTime = self.sleepView.datePicker.date;
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:theTime];
        [timeComponents setSecond:0];
        
        //set time button label
        [self.sleepView.timeButton setTitle:[_formatter stringFromDate:theTime] forState:UIControlStateNormal];
        
        //set the alarm's date
        self.timeComponents = timeComponents;
        
        //enable create buton
        [self.sleepView.createButton setEnabled:YES];
    }
    else {
        
        //break the chosen date down so we just have the hour and minute with a zero'd seconds
        NSDate *theTime = self.sleepView.datePicker.date;
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:theTime];
        [timeComponents setSecond:0];
        
        //set time button label
        [self.sleepView.timeButton setTitle:[_formatter stringFromDate:theTime] forState:UIControlStateNormal];
        
    }
    
    //reload times table
    [self.sleepView.timesTableView reloadData];
}

- (void)controlChanged:(id)sender
{
    if (self.sleepView.sleepWakeControl.selectedSegmentIndex == 0) {
        self.sleepView.sleepLabel.text = NSLocalizedString(@"You try to fall asleep at one of these times:", nil);
        self.sleepView.createButton.enabled = YES;
    }
    else {
        self.sleepView.sleepLabel.text = NSLocalizedString(@"Select one of these times to wake up at:", nil);
        self.sleepView.createButton.enabled = NO;
    }
    
    
    [self.sleepView.timesTableView deselectRowAtIndexPath:[self.sleepView.timesTableView indexPathForSelectedRow] animated:YES];
    [self.sleepView.timesTableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"infoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
    }
    
    if (self.sleepView.sleepWakeControl.selectedSegmentIndex == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    int timeInterval = (60 * 90) * (10 - indexPath.row);
    NSDate *newDate = [NSDate dateWithTimeInterval:(self.sleepView.sleepWakeControl.selectedSegmentIndex == 0) ? -timeInterval : timeInterval sinceDate:self.sleepView.datePicker.date];
    
    cell.textLabel.text = [_formatter stringFromDate:newDate];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.sleepView.createButton.enabled = YES;
}


@end
