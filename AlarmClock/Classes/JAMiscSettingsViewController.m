//
//  JAMiscSettingsViewController.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/28/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JAMiscSettingsViewController.h"
#import "JASettings.h"
#import "JASound.h"
#import "JASettings.h"
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "Flurry.h"

@interface JAMiscSettingsViewController ()
- (void)weatherSwitchChanged:(id)sender;
- (void)awakeSwitchChanged:(id)sender;
- (void)dimSwitchChanged:(id)sender;
- (void)flashlightSwitchChanged:(id)sender;
@end

@implementation JAMiscSettingsViewController

- (id)init
{
    self = [super init];
    if (self) {
        
        //setup tableview
        [self setTableView:[[UITableView alloc] initWithFrame:CGRectInset(self.view.frame, 0, 0) style:UITableViewStyleGrouped]];
        [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:self.tableView];
        
        // Weather switch
        [self setWeatherSwitch:[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Fahrenheit", nil), NSLocalizedString(@"Celsius", nil), nil]]];
        [self.weatherSwitch setSegmentedControlStyle:UISegmentedControlStyleBar];
        [self.weatherSwitch setSelectedSegmentIndex:([JASettings celsius]) ? 1 : 0];
        [self.weatherSwitch addTarget:self action:@selector(weatherSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
        //set picker and sound
        _selectedPicker = 0;
        _selectedSound = 0;
        _selectedTime = [JASettings snoozeLength];
        
        //setup the dictionary from Settings.plist
		NSString *soundsLocation = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"sleepSoundsList.plist"];
		NSDictionary *soundsDict = [[NSDictionary alloc] initWithContentsOfFile:soundsLocation];
        [self setSounds:[soundsDict objectForKey:@"sounds"]];
        
        //check for preselected sound
        NSDictionary *soundDict = [JASettings sleepSound];
        for (NSDictionary *thisSound in self.sounds) {
            if ([[soundDict objectForKey:@"name"] isEqualToString:[thisSound objectForKey:@"name"]]) {
                _selectedSound = [self.sounds indexOfObject:thisSound];
                break;
            }
        }
        
        //setup picker
        [self setPickerView:[[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 220)]];
        [self.view addSubview:self.pickerView];
        [self.pickerView setDelegate:self];
        //[self.pickerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.pickerView setShowsSelectionIndicator:YES];
        [self.pickerView setDataSource:self];
        
        //awake switch
        [self setAwakeSwitch:[[UISwitch alloc] init]];
        [self.awakeSwitch setOn:[JASettings shine]];
        [self.awakeSwitch addTarget:self action:@selector(awakeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
        //dim switch
        [self setDimSwitch:[[UISwitch alloc] init]];
        [self.dimSwitch setOn:![JASettings dimDisabled]];
        [self.dimSwitch addTarget:self action:@selector(dimSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
        //flashlight switch
        [self setFlashlightSwitch:[[UISwitch alloc] init]];
        [self.flashlightSwitch setOn:![JASettings flashlightDisabled]];
        [self.flashlightSwitch addTarget:self action:@selector(flashlightSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
        _descView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 0)];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, 15.0, _descView.frame.size.width - 50.0f, 35)];
        [label1 setBackgroundColor:[UIColor clearColor]];
        [label1 setFont:[UIFont fontWithName:TITLE_FONT size:14]];
        [label1 setNumberOfLines:0];
        [label1 setText:NSLocalizedString(@"The Science Behind SleepSmart – Why Your Sleep Cycle Matters", nil)];
        [label1 sizeToFit];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, label1.frame.size.height + label1.frame.origin.y + 5, _descView.frame.size.width - 50.0, 700.0)];
        [label2 setBackgroundColor:[UIColor clearColor]];
        [label2 setNumberOfLines:0];
        [label2 setAdjustsFontSizeToFitWidth:YES];
        [label2 setMinimumScaleFactor:0.2];
        [label2 setLineBreakMode:NSLineBreakByWordWrapping];
        [label2 setFont:[UIFont fontWithName:CELL_DETAIL_TEXT_FONT size:14]];
        [label2 setText:NSLocalizedString(@"Think that extra hour of sleep will make you feel more rested?  Think again.  Research has shown that waking up in the middle of your body’s natural sleep cycle can make you feel groggy, disoriented and is actually counterproductive to a full night’s sleep.  Waking your body up at the end of your natural sleep cycle, when your body and brain are already close to wakefulness, can provide you with the best night’s sleep and the most refreshing of mornings.\n\nThe average sleep cycle lasts approximately 90 minutes and a well-rested adult goes through approximately 4-6 cycles a night.  During these cycles your body enters four different stages: N1, transition to sleep (5 min); N2, light sleep (10-25 min); N3, deep sleep (40-60 min); and REM, dream sleep.  Each stage is vital in restoring your body and mind and plays a different role in preparing you for the day ahead.\n\nEven if you’ve enjoyed a full night’s sleep, getting out of bed can be difficult if your alarm goes off when you’re in the middle of deep sleep (stage N3).   If you want the best night’s sleep for an optimal morning, then set your alarm to wake up at the end of your natural sleep cycle.  Simply use SleepSmart’s Sleep Cycle Calculator and you’re on your way to a great night’s sleep!", nil)];
        [label2 sizeToFit];
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, label2.frame.size.height + label2.frame.origin.y + 10, _descView.frame.size.width - 50.0f, 35)];
        [label3 setBackgroundColor:[UIColor clearColor]];
        [label3 setNumberOfLines:0];
        [label3 setFont:[UIFont fontWithName:TITLE_FONT size:14]];
        [label3 setText:NSLocalizedString(@"How Does the Rise & Shine Feature Help Wake Me Up?", nil)];
        [label3 sizeToFit];
        
        UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, label3.frame.size.height + label3.frame.origin.y + 5, _descView.frame.size.width - 50.0, 180)];
        [label4 setBackgroundColor:[UIColor clearColor]];
        [label4 setNumberOfLines:0];
        [label4 setAdjustsFontSizeToFitWidth:YES];
        [label4 setLineBreakMode:NSLineBreakByWordWrapping];
        [label4 setFont:[UIFont fontWithName:CELL_DETAIL_TEXT_FONT size:14]];
        [label4 setText:NSLocalizedString(@"Your brain responds to changes between light and dark to regulate your internal 24-hour sleep-wake cycle.  If it is dark outside when you get up, you probably find it hard to get out of bed.  Our unique and ingenious Rise & Shine feature turns your iPhone into a virtual sun! Simple turn on Rise & Shine and trick your brain into waking up, even if it’s dark outside!", nil)];
        [label4 setMinimumScaleFactor:0.2];
        [label4 sizeToFit];
        
        UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, label4.frame.size.height + label4.frame.origin.y + 15, _descView.frame.size.width - 50.0f, 35)];
        [label5 setBackgroundColor:[UIColor clearColor]];
        [label5 setNumberOfLines:0];
        [label5 setFont:[UIFont fontWithName:TITLE_FONT size:14]];
        [label5 setText:NSLocalizedString(@"Tips For Using Your White Noise Sleep Timer", nil)];
        [label5 sizeToFit];
        
        UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, label5.frame.size.height + label5.frame.origin.y + 5, _descView.frame.size.width - 50.0, 170)];
        [label6 setBackgroundColor:[UIColor clearColor]];
        [label6 setNumberOfLines:0];
        [label6 setAdjustsFontSizeToFitWidth:YES];
        [label6 setLineBreakMode:NSLineBreakByWordWrapping];
        [label6 setFont:[UIFont fontWithName:CELL_DETAIL_TEXT_FONT size:14]];
        [label6 setText:NSLocalizedString(@"Shutting your brain down at night can be difficult.  Using SleepSmart’s White Noise Sleep Timer can help.\n\nSleepSmart Premium includes 10 soothing themes to help lull you to sleep.  For best results, hook your iPhone into an audio source to improve the sound quality.", nil)];
        [label6 setMinimumScaleFactor:0.2];
        [label6 sizeToFit];
        
        _descView.frame = CGRectMake(0, 0, 290, label6.frame.origin.y + label6.frame.size.height + 30);
        
        [_descView addSubview:label1];
        [_descView addSubview:label2];
        [_descView addSubview:label3];
        [_descView addSubview:label4];
        [_descView addSubview:label5];
        [_descView addSubview:label6];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.awakeSwitch setOn:[JASettings stayAwake]];
    
    [Flurry logEvent:@"Misc Settings Opened"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)weatherSwitchChanged:(id)sender
{
    [JASettings setCelsius:([self.weatherSwitch selectedSegmentIndex] == 1) ? YES : NO];
}

- (void)dimSwitchChanged:(id)sender
{
    [JASettings setDimDisabled:![self.dimSwitch isOn]];
    
    [Flurry logEvent:@"Dim Switch Toggled" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:([self.dimSwitch isOn]) ? @"On" : @"Off", @"On or Off", nil]];
  
}

- (void)flashlightSwitchChanged:(id)sender
{
    [JASettings setFlashlightDisabled:![self.flashlightSwitch isOn]];
    
    [Flurry logEvent:@"Flashlight Switch Toggled" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:([self.flashlightSwitch isOn]) ? @"On" : @"Off", @"On or Off", nil]];
}

- (void)awakeSwitchChanged:(id)sender
{
    if (![self.awakeSwitch isOn]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Whoops!", nil) message:NSLocalizedString(@"If you don't keep auto-lock disabled the Rise & Shine feature will be disabled.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Ok", nil), nil];
        [alert setTag:1];
        [alert show];
    }
    else {
        [JASettings setStayAwake:[self.awakeSwitch isOn]];
        
        [Flurry logEvent:@"Disabled AutoLock Switch Toggled" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:([self.awakeSwitch isOn]) ? @"Disabled" : @"Enabled", @"Enabled?", nil]];
    }
    
}

#pragma mark - Table view data source
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
        return _descView.frame.size.height;
    return 45.0f;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Settings", nil);
    }
    else if (section == 1) {
        return NSLocalizedString(@"Auto-Lock", nil);
    }
    else if (section == 2) {
        return NSLocalizedString(@"Help & Information", nil);
    }
    else {
        return NSLocalizedString(@"Love SleepSmart?  We Love You Too!  Help Us Spread the Word!", nil);
    }

}

- (NSString*) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return @"";
    }
    else if (section == 1) {
        return NSLocalizedString(@"Due to multitasking limitations set by Apple, SleepSmart MUST be running in the foreground for its features to work properly.  In order to do this, you must disable your phone’s auto-lock feature./n/nIf you forget to leave the app open, we’ve got your back.  SleepSmart provides a built-in background alarm that will play a default alarm sound when your alarm goes off.   This default alarm is limited to 30 seconds so MAKE SURE you keep SleepSmart running through the night!  Background alarms work only on iPhone 4 models and above.", nil);
    }
    else if (section == 2) {
        return @"";
    }
    else {
        return @"";
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString *labelString = @"";
    
    
    if (section == 0) {
        labelString = NSLocalizedString(@"Settings", nil);
    }
    else if (section == 1) {
        labelString = NSLocalizedString(@"Auto-Lock", nil);
    }
    else if (section == 2) {
        labelString = NSLocalizedString(@"Help & Information", nil);
    }
    else {
        labelString = NSLocalizedString(@"Love SleepSmart?  We Love You Too!  Help Us Spread the Word!", nil);
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.view.frame.size.width - 30.0, (section == 3) ? 60.0f : 30.0f)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont fontWithName:TITLE_FONT size:17]];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setTextColor:[UIColor colorWithRed:59.0/255.0 green:67.0/255.0 blue:90.0/255.0 alpha:1.0]];
    [label setNumberOfLines:0];
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(0, 1)];
    [label setText:labelString];
    [label sizeToFit];
    
    return label.frame.size.height + 15;
//    if (section == 3)
//        return 70.0f;
//    return 40.0;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *labelString = @"";
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30.0f)];
    [headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    if (section == 0) {
        labelString = NSLocalizedString(@"Settings", nil);
    }
    else if (section == 1) {
        labelString = NSLocalizedString(@"Auto-Lock", nil);
    }
    else if (section == 2) {
        labelString = NSLocalizedString(@"Help & Information", nil);
    }
    else {
        labelString = NSLocalizedString(@"Love SleepSmart?  We Love You Too!  Help Us Spread the Word!", nil);
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.view.frame.size.width - 30.0, (section == 3) ? 60.0f : 30.0f)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont fontWithName:TITLE_FONT size:17]];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setTextColor:[UIColor colorWithRed:59.0/255.0 green:67.0/255.0 blue:90.0/255.0 alpha:1.0]];
    [label setNumberOfLines:0];
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(0, 1)];
    [label setText:labelString];
    [label sizeToFit];
    [headerView addSubview:label];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    if (section == 0) {
        return 4;
    }
    else if (section == 1) {
        return 1;
    }
    else if (section == 2) {
        return 1;
    }
    else {
        return ([JASettings isIOS6]) ? 4 : 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = (indexPath.section == 2) ? @"HelpCell" : @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:CELL_TEXT_FONT size:18];
        cell.detailTextLabel.font = [UIFont fontWithName:CELL_DETAIL_TEXT_FONT size:18];
    }
    
    // Configure the cell...
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            cell.textLabel.text = NSLocalizedString(@"Snooze Length", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i %@", _selectedTime, NSLocalizedString(@"minutes", nil), nil];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
        }
        else if (indexPath.row == 1) {
         
            cell.textLabel.text = NSLocalizedString(@"Weather", nil);
            cell.accessoryView = self.weatherSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

        }
        else if (indexPath.row == 2) {
            
            cell.textLabel.text = NSLocalizedString(@"Shake for Flashlight", nil);
            cell.accessoryView = self.flashlightSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        else if (indexPath.row == 3) {
            
            cell.textLabel.text = NSLocalizedString(@"Adjust Brightness", nil);
            cell.accessoryView = self.dimSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
    }
    else if (indexPath.section == 1) {
        cell.textLabel.text = NSLocalizedString(@"Disable Auto-Lock", nil);
        cell.accessoryView = self.awakeSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 2) {
        cell.textLabel.text = @"";
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, 15.0, cell.frame.size.width - 50.0f, 35)];
        [label1 setBackgroundColor:[UIColor clearColor]];
        [label1 setFont:[UIFont fontWithName:TITLE_FONT size:14]];
        [label1 setNumberOfLines:0];
        [label1 setText:NSLocalizedString(@"The Science Behind SleepSmart – Why Your Sleep Cycle Matters", nil)];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, label1.frame.size.height + label1.frame.origin.y + 5, cell.frame.size.width - 50.0, 700.0)];
        [label2 setBackgroundColor:[UIColor clearColor]];
        [label2 setNumberOfLines:0];
        [label2 setAdjustsFontSizeToFitWidth:YES];
        [label2 setMinimumScaleFactor:0.2];
        [label2 setLineBreakMode:NSLineBreakByWordWrapping];
        [label2 setFont:[UIFont fontWithName:CELL_DETAIL_TEXT_FONT size:14]];
        [label2 setText:NSLocalizedString(@"Think that extra hour of sleep will make you feel more rested?  Think again.  Research has shown that waking up in the middle of your body’s natural sleep cycle can make you feel groggy, disoriented and is actually counterproductive to a full night’s sleep.  Waking your body up at the end of your natural sleep cycle, when your body and brain are already close to wakefulness, can provide you with the best night’s sleep and the most refreshing of mornings.\n\nThe average sleep cycle lasts approximately 90 minutes and a well-rested adult goes through approximately 4-6 cycles a night.  During these cycles your body enters four different stages: N1, transition to sleep (5 min); N2, light sleep (10-25 min); N3, deep sleep (40-60 min); and REM, dream sleep.  Each stage is vital in restoring your body and mind and plays a different role in preparing you for the day ahead.\n\nEven if you’ve enjoyed a full night’s sleep, getting out of bed can be difficult if your alarm goes off when you’re in the middle of deep sleep (stage N3).   If you want the best night’s sleep for an optimal morning, then set your alarm to wake up at the end of your natural sleep cycle.  Simply use SleepSmart’s Sleep Cycle Calculator and you’re on your way to a great night’s sleep!", nil)];
                [label2 sizeToFit];
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, label2.frame.size.height + label2.frame.origin.y + 10, cell.frame.size.width - 50.0f, 35)];
        [label3 setBackgroundColor:[UIColor clearColor]];
        [label3 setNumberOfLines:0];
        [label3 setFont:[UIFont fontWithName:TITLE_FONT size:14]];
        [label3 setText:NSLocalizedString(@"How Does the Rise & Shine Feature Help Wake Me Up?", nil)];
        
        UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, label3.frame.size.height + label3.frame.origin.y + 5, cell.frame.size.width - 50.0, 180)];
        [label4 setBackgroundColor:[UIColor clearColor]];
        [label4 setNumberOfLines:0];
        [label4 setAdjustsFontSizeToFitWidth:YES];
        [label4 setLineBreakMode:NSLineBreakByWordWrapping];
        [label4 setFont:[UIFont fontWithName:CELL_DETAIL_TEXT_FONT size:14]];
        [label4 setText:NSLocalizedString(@"Your brain responds to changes between light and dark to regulate your internal 24-hour sleep-wake cycle.  If it is dark outside when you get up, you probably find it hard to get out of bed.  Our unique and ingenious Rise & Shine feature turns your iPhone into a virtual sun! Simple turn on Rise & Shine and trick your brain into waking up, even if it’s dark outside!", nil)];
        [label4 setMinimumScaleFactor:0.2];
        [label4 sizeToFit];
        
        UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, label4.frame.size.height + label4.frame.origin.y + 15, cell.frame.size.width - 50.0f, 35)];
        [label5 setBackgroundColor:[UIColor clearColor]];
        [label5 setNumberOfLines:0];
        [label5 setFont:[UIFont fontWithName:TITLE_FONT size:14]];
        [label5 setText:NSLocalizedString(@"Tips For Using Your White Noise Sleep Timer", nil)];
        
        UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(25.0f, label5.frame.size.height + label5.frame.origin.y + 5, cell.frame.size.width - 50.0, 170)];
        [label6 setBackgroundColor:[UIColor clearColor]];
        [label6 setNumberOfLines:0];
        [label6 setAdjustsFontSizeToFitWidth:YES];
        [label6 setLineBreakMode:NSLineBreakByWordWrapping];
        [label6 setFont:[UIFont fontWithName:CELL_DETAIL_TEXT_FONT size:14]];
        [label6 setText:NSLocalizedString(@"Shutting your brain down at night can be difficult.  Using SleepSmart’s White Noise Sleep Timer can help.\n\nSleepSmart Premium includes 10 soothing themes to help lull you to sleep.  For best results, hook your iPhone into an audio source to improve the sound quality.", nil)];
        [label6 setMinimumScaleFactor:0.2];
        [label6 sizeToFit];
        
//        [cell addSubview:label1];
//        [cell addSubview:label2];
//        [cell addSubview:label3];
//        [cell addSubview:label4];
//        [cell addSubview:label5];
//        [cell addSubview:label6];
        [cell addSubview:_descView];
    }
    else {
        if (indexPath.row == 0) {
            if ([JASettings isIOS6])
                cell.textLabel.text = NSLocalizedString(@"Facebook", nil);
            else
                cell.textLabel.text = NSLocalizedString(@"Text Message", nil);
        }
        else if (indexPath.row == 1) {
            if ([JASettings isIOS6])
                cell.textLabel.text = NSLocalizedString(@"Twitter", nil);
            else
                cell.textLabel.text = NSLocalizedString(@"Email", nil);
        }
        else if (indexPath.row == 2)
            cell.textLabel.text = NSLocalizedString(@"Text Message", nil);
        else
            cell.textLabel.text = NSLocalizedString(@"Email", nil);
        
        cell.detailTextLabel.text = @"";
        
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        
        _selectedPicker = indexPath.row;
        
        if (indexPath.row == 0) {
            [self.pickerView reloadAllComponents];
            [self.pickerView selectRow:(_selectedTime - 1) inComponent:0 animated:NO];
            [self raisePicker];
        }
//        else {
//            [self.pickerView reloadAllComponents];
//            [self.pickerView selectRow:_selectedSound inComponent:0 animated:NO];
//            [self raisePicker];
//        }
    }
    else if (indexPath.section == 3) {
        
        if (indexPath.row == 0)
        {
            if ([JASettings isIOS6]) {
                SLComposeViewController *composer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                [composer setInitialText:[NSString stringWithFormat:NSLocalizedString(@"Check out SleepSmart in the App Store: %@", nil), nil]];
                [composer addImage:[UIImage imageNamed:@"AlarmClockIcon57.png"]];
                NSString *urlString = ([JASettings isPaid]) ? NSLocalizedString(@"APPSTORE_URL_PAID", nil) : NSLocalizedString(@"APPSTORE_URL_FREE", nil);
                [composer addURL:[NSURL URLWithString:urlString]];
                [self presentModalViewController:composer animated:YES];
            }
            else {
                [self displaySMSComposerSheet];
            }
        }
        else if (indexPath.row == 1) {
            if ([JASettings isIOS6]) {
                SLComposeViewController *composer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [composer setInitialText:NSLocalizedString(@"Check out SleepSmart!", nil)];
                [composer addImage:[UIImage imageNamed:@"AlarmClockIcon57.png"]];
                NSString *urlString = ([JASettings isPaid]) ? NSLocalizedString(@"APPSTORE_URL_PAID", nil) : NSLocalizedString(@"APPSTORE_URL_FREE", nil);
                [composer addURL:[NSURL URLWithString:urlString]];
                [self presentModalViewController:composer animated:YES];
            }
            else {
                [self displayComposerSheet];
            }
        }
        else if (indexPath.row == 2 && [MFMessageComposeViewController canSendText]) {
            [self displaySMSComposerSheet];
        }
        else if ([MFMailComposeViewController canSendMail])
            [self displayComposerSheet];
        
        
    }
    
    
}



- (void) raisePicker
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height - self.pickerView.frame.size.height);
                         //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                         self.pickerView.frame = CGRectMake(0, self.view.frame.size.height - self.pickerView.frame.size.height, self.pickerView.frame.size.width, self.pickerView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void) lowerPicker
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height);
                         //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                         self.pickerView.frame = CGRectMake(0, self.view.frame.size.height, self.pickerView.frame.size.width, self.pickerView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


#pragma mark - PickerView Delegate
- (int) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (_selectedPicker == 0)
        return 30;
    else
        return self.sounds.count;
}

- (int) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_selectedPicker == 0)
        return [NSString stringWithFormat:@"%i mins", row + 1];
    else
        return [[self.sounds objectAtIndex:row] objectForKey:@"name"];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_selectedPicker == 0) {
        
        _selectedTime = row + 1;
        
        [JASettings setSnoozeLength:_selectedTime];
        
    }
    else {
        
        [JASettings setSleepSound:[self.sounds objectAtIndex:row]];
        _selectedSound = row;
        
    }
    
    [self lowerPicker];
    [self.tableView reloadData];
}

#pragma mark - UIAlertviewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0) {
        if (buttonIndex == 0) {
        }
        else {
            [self.awakeSwitch setOn:YES];
            
            [JASettings setStayAwake:YES];
            [JASettings setShine:YES];
            
            [Flurry logEvent:@"Disabled AutoLock Switch Toggled" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:([self.awakeSwitch isOn]) ? @"Disabled" : @"Enabled", @"Enabled?", nil]];
        }
    }
    else {
        if (buttonIndex == 0) {
            [self.awakeSwitch setOn:YES];
        }
        else {
            [self.awakeSwitch setOn:NO];
            
            [JASettings setStayAwake:NO];
            [JASettings setShine:NO];
            
            [Flurry logEvent:@"Disabled AutoLock Switch Toggled" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:([self.awakeSwitch isOn]) ? @"Disabled" : @"Enabled", @"Enabled?", nil]];
        }
    }
}


#pragma mark - Mail Composer
-(void)displayComposerSheet
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Check out SleepSmart!"];
    

    
    // Fill out the email body text.
    NSString *urlString = ([JASettings isPaid]) ? NSLocalizedString(@"APPSTORE_URL_PAID", nil) : NSLocalizedString(@"APPSTORE_URL_FREE", nil);
    NSString *emailBody = [NSString stringWithFormat:NSLocalizedString(@"Check out <a href=\"%@\">SleepSmart</a> in the App Store", nil), urlString, nil];
    [picker setMessageBody:emailBody isHTML:YES];
    
    // Present the mail composition interface.
    [self presentModalViewController:picker animated:YES];

}

// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)displaySMSComposerSheet
{
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;

    NSString *urlString = ([JASettings isPaid]) ? NSLocalizedString(@"APPSTORE_URL_PAID", nil) : NSLocalizedString(@"APPSTORE_URL_FREE", nil);
    NSString *textBody = [NSString stringWithFormat:NSLocalizedString(@"Check out SleepSmart in the App Store: %@", nil), urlString, nil];
    [picker setBody:textBody];
    
    [self presentModalViewController:picker animated:YES];

}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    
        [self dismissModalViewControllerAnimated:YES];
}

@end
