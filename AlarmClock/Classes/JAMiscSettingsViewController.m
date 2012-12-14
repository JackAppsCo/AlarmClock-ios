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
@end

@implementation JAMiscSettingsViewController

- (id)init
{
    self = [super init];
    if (self) {
        
        //setup tableview
        [self setTableView:[[UITableView alloc] initWithFrame:CGRectInset(self.view.frame, 0, 0)]];
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:self.tableView];
        
        // Weather switch
        [self setWeatherSwitch:[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Farenheight", @"Celsius", nil]]];
        [self.weatherSwitch setSegmentedControlStyle:UISegmentedControlStyleBar];
        [self.weatherSwitch setSelectedSegmentIndex:([JASettings farenheit]) ? 0 : 1];
        [self.weatherSwitch addTarget:self action:@selector(weatherSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
        //set picker and sound
        _selectedPicker = 0;
        _selectedSound = 0;
        _selectedTime = [JASettings sleepLength];
        
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
        
        //shine switch
        [self setShineSwitch:[[UISwitch alloc] init]];
        [self.shineSwitch setOn:[JASettings shine]];
        [self.shineSwitch addTarget:self action:@selector(shineSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)weatherSwitchChanged:(id)sender
{
    [JASettings setFarenheit:([self.weatherSwitch selectedSegmentIndex] == 0) ? YES : NO];
}

- (void)shineSwitchChanged:(id)sender
{
    [JASettings setShine:[self.shineSwitch isOn]];
}

#pragma mark - Table view data source
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0f;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? NSLocalizedString(@"Sleep Sound", nil) : (section == 1) ? NSLocalizedString(@"Weather", nil) : NSLocalizedString(@"Misc", nil);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return (section == 0) ? 2 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        UIImageView *whiteBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [whiteBG setImage:[UIImage imageNamed:@"rowBG.png"]];
        cell.backgroundView = whiteBG;
    }
    
    // Configure the cell...
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            cell.textLabel.text = NSLocalizedString(@"Length", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i %@", _selectedTime, NSLocalizedString(@"minutes", nil), nil];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
        }
        else if (indexPath.row == 1) {
            
            cell.textLabel.text = NSLocalizedString(@"Sleep Sound", nil);
            cell.detailTextLabel.text = [[self.sounds objectAtIndex:_selectedSound] objectForKey:@"name"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
    }
    else if (indexPath.section == 1) {
        cell.textLabel.text = NSLocalizedString(@"Scale", nil);
        cell.accessoryView = self.weatherSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        cell.textLabel.text = NSLocalizedString(@"Rise & Shine", nil);
        cell.accessoryView = self.shineSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        else {
            [self.pickerView reloadAllComponents];
            [self.pickerView selectRow:_selectedSound inComponent:0 animated:NO];
            [self raisePicker];
        }
    }
    
    
}



- (void) raisePicker
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height - self.pickerView.frame.size.height);
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
        
        [JASettings setSleepLength:_selectedTime];
        
    }
    else {
        
        [JASettings setSleepSound:[self.sounds objectAtIndex:row]];
        _selectedSound = row;
        
    }
    
    [self.tableView reloadData];
    [self lowerPicker];
}

@end
