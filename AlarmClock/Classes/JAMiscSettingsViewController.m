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

@interface JAMiscSettingsViewController ()
- (void)weatherSwitchChanged:(id)sender;
- (void)shineSwitchChanged:(id)sender;
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
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 95.0, 0)];
        [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 95.0, 0)];
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:self.tableView];
        
        // Weather switch
        [self setWeatherSwitch:[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Farenheight", nil), NSLocalizedString(@"Celsius", nil), nil]]];
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
        [self setPickerView:[[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 220)]];
        [self.view addSubview:self.pickerView];
        [self.pickerView setDelegate:self];
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
}

- (void)flashlightSwitchChanged:(id)sender
{
    [JASettings setFlashlightDisabled:![self.flashlightSwitch isOn]];
}

- (void)awakeSwitchChanged:(id)sender
{
    if (![self.awakeSwitch isOn] && [JASettings shine]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Whoops!", nil) message:NSLocalizedString(@"If you don't keep autolock disabled the Rise & Shine feature will be disabled.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Ok", nil), nil];
        [alert setTag:1];
        [alert show];
    }
    else {
        [JASettings setStayAwake:[self.awakeSwitch isOn]];
    }
    
}

#pragma mark - Table view data source
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0f;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? NSLocalizedString(@"Settings", nil) : (section == 1) ? NSLocalizedString(@"Auto Lock", nil) : NSLocalizedString(@"Help & Information", nil);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 3;
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
    else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
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
            
            cell.textLabel.text = NSLocalizedString(@"Flashlight", nil);
            cell.accessoryView = self.flashlightSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        else if (indexPath.row == 3) {
            
            cell.textLabel.text = NSLocalizedString(@"Slide Finger", nil);
            cell.accessoryView = self.dimSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
    }
    else if (indexPath.section == 1) {
        cell.textLabel.text = NSLocalizedString(@"Disable Autolock", nil);
        cell.accessoryView = self.awakeSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {

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
            [self.pickerView selectRow:_selectedTime inComponent:0 animated:NO];
            [self raisePicker];
        }
//        else {
//            [self.pickerView reloadAllComponents];
//            [self.pickerView selectRow:_selectedSound inComponent:0 animated:NO];
//            [self raisePicker];
//        }
    }
    
    
}



- (void) raisePicker
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height - self.pickerView.frame.size.height);
                         self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
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
                         self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 95, 0);
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
        return 120;
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
    
    [self.tableView reloadData];
    [self lowerPicker];
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
        }
    }
}

@end
