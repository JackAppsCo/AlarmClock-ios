//
//  JAClockSettingsViewController.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/23/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JAClockSettingsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JASettings.h"

@interface JAClockSettingsViewController ()
- (void) secondsSwitchChanged:(id)sender;
- (void) dateSwitchChanged:(id)sender;
@end

@implementation JAClockSettingsViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        _selectedPicker = 0;
        
        //header view
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 76)];
        [header setBackgroundColor:[UIColor clearColor]];
        [header setClipsToBounds:NO];
        self.tableView.tableHeaderView = header;
        
        //Picker
        [self setPickerView:[[UIPickerView alloc] init]];
        [self.pickerView setFrame:CGRectMake(0, self.view.frame.size.height, self.pickerView.frame.size.width, self.pickerView.frame.size.height - 50.0f)];
        [self.pickerView setDataSource:self];
        [self.pickerView setDelegate:self];
        [self.pickerView setShowsSelectionIndicator:YES];
        [self.view addSubview:self.pickerView];
        
        //set time label
        _dateFormatter = [[NSDateFormatter alloc] init];
        if ([JASettings showSeconds])
            [_dateFormatter setDateFormat:@"h:mm:ss"];
        else
            [_dateFormatter setDateFormat:@"h:mm"];
        
        self.timeLabel.text = [_dateFormatter stringFromDate:[NSDate date]];
        
        //bgs array
        NSString *bgsLocation = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"backgroundsList.plist"];
        NSDictionary *bgsDict = [[NSDictionary alloc] initWithContentsOfFile:bgsLocation];
        _bgList = [bgsDict objectForKey:@"backgrounds"];
        
        //create colors array
        _fontColorList = [[NSArray alloc]
                          initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:[UIColor whiteColor], @"color", @"White", @"name", nil],
                          [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor], @"color", @"Black", @"name", nil],
                          [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor yellowColor], @"color", @"Yellow", @"name", nil],
                          [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor colorWithRed:141.0/255.0 green:192.0/255.0 blue:236.0/255.0 alpha:1.0], @"color", @"Light Blue", @"name", nil],
                          [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor colorWithRed:7.0/255.0 green:47.0/255.0 blue:81.0/255.0 alpha:1.0], @"color", @"Blue", @"name", nil],
                          [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor colorWithRed:255.0/255.0 green:162.0/255.0 blue:0.0/255.0 alpha:1.0], @"color", @"Orange", @"name", nil],
                          [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor colorWithRed:53.0/255.0 green:123.0/255.0 blue:53.0/255.0 alpha:1.0], @"color", @"Green", @"name", nil], nil];
        
        //secs switch
        [self setShowSecondsSwitch:[[UISwitch alloc] init]];
        [self.showSecondsSwitch setOn:[JASettings showSeconds]];
        [self.showSecondsSwitch addTarget:self action:@selector(secondsSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
        //date switch
        [self setShowDateSwitch:[[UISwitch alloc] init]];
        [self.showDateSwitch setOn:[JASettings showDate]];
        [self.showDateSwitch addTarget:self action:@selector(dateSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_backgroundPicker) {
        
        float offset = _backgroundPicker.scrollView.contentOffset.x;
        int page = offset / _backgroundPicker.scrollView.frame.size.width;
        if (page >= _backgroundPicker.backgroundList.count) {
            if (_backgroundPicker.customImageURL.length > 0) {
                [JASettings setBackgroundImage:_backgroundPicker.customImageURL];
                [JASettings setBackgroundImageName:@"Custom"];
            }
        }
        else {
            [JASettings setBackgroundImage:[[_backgroundPicker.backgroundList objectAtIndex:page] objectForKey:@"filename"]];
            [JASettings setBackgroundImageName:[[_backgroundPicker.backgroundList objectAtIndex:page] objectForKey:@"name"]];
        }
        
    }
    
    [self.bgImageView setImage:[JASettings backgroundImage]];
    self.timeLabel.textColor = [JASettings clockColor];
    [self.tableView reloadData];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) secondsSwitchChanged:(id)sender
{

    [JASettings setShowSeconds:[(UISwitch*)sender isOn]];
    
    //set time label
    _dateFormatter = [[NSDateFormatter alloc] init];
    if ([JASettings showSeconds])
        [_dateFormatter setDateFormat:@"h:mm:ss"];
    else
        [_dateFormatter setDateFormat:@"h:mm"];
    
    //set time label
    self.timeLabel.text = [_dateFormatter stringFromDate:[NSDate date]];
    
}

- (void) dateSwitchChanged:(id)sender
{
    
    [JASettings setShowDate:[(UISwitch*)sender isOn]];
    
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

#pragma mark - Rotate  Methods
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}


#pragma mark - Table view data source
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        UIImageView *whiteBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [whiteBG setImage:[UIImage imageNamed:@"rowBG.png"]];
        cell.backgroundView = whiteBG;
        
    }
    
    // Configure the cell...
    
    
    if (indexPath.row == 0) {
        [cell.layer setShadowColor:[UIColor blackColor].CGColor];
        [cell.layer setShadowOffset:CGSizeMake(0, -10)];
        [cell.layer setShadowRadius:5.0f];
        [cell.layer setShadowOpacity:0.75f];
        
        cell.textLabel.text = @"Background Image";
        cell.detailTextLabel.text = [JASettings backgroundImageName];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
    }
    else if (indexPath.row == 1) {
        [cell.layer setShadowColor:[UIColor clearColor].CGColor];
        
        cell.textLabel.text = @"Clock Text Color";
        cell.detailTextLabel.text = [JASettings clockColorName];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
    }
    else if (indexPath.row == 2) {
        [cell.layer setShadowColor:[UIColor clearColor].CGColor];
        
        cell.textLabel.text = @"Show Seconds";
        cell.accessoryView = self.showSecondsSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;        
    }
    else if (indexPath.row == 3) {
        [cell.layer setShadowColor:[UIColor clearColor].CGColor];
        
        cell.textLabel.text = @"Show Date";
        cell.accessoryView = self.showDateSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        [cell.layer setShadowColor:[UIColor clearColor].CGColor];
        
        cell.textLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *whiteBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 500.0f)];
        [whiteBG setBackgroundColor:[UIColor whiteColor]];
        [cell addSubview:whiteBG];
        
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
    
    switch (indexPath.row) {
        case 0:
        {
            if(!_backgroundPicker) {
                
                _backgroundPicker = [[JABackgroundPickerViewController alloc] initWithNibName:@"JABackgroundPickerViewController" bundle:[NSBundle mainBundle]];
                [_backgroundPicker setHidesBottomBarWhenPushed:YES];
             
            }
            
            
            
            [self.navigationController pushViewController:_backgroundPicker animated:YES];
            
            /*_selectedPicker = indexPath.row;
            [self.pickerView reloadAllComponents];
            
            int selectedIndex = 0;
            for (NSDictionary *bg in _bgList) {
                if ([[bg objectForKey:@"name"] isEqualToString:[JASettings backgroundImageName]])
                    break;
                else
                    selectedIndex += 1;
            }
            [self.pickerView selectRow:selectedIndex inComponent:0 animated:NO];
            [self raisePicker];*/
            
            break;
        }
        case 1:
        {
            
            _selectedPicker = indexPath.row;
            [self.pickerView reloadAllComponents];
            
            int selectedIndex = 0;
            for (NSDictionary *color in _fontColorList) {
                if ([[color objectForKey:@"name"] isEqualToString:[JASettings clockColorName]])
                    break;
                else
                    selectedIndex += 1;
            }
            [self.pickerView selectRow:selectedIndex inComponent:0 animated:NO];
            [self raisePicker];
            
            break;
        }
            
        default:
            break;
    }
    
}

- (void)viewDidUnload {
    [self setBgImageView:nil];
    [self setTimeLabel:nil];
    [self setTableView:nil];
    [self setPickerView:nil];
    [super viewDidUnload];
}

#pragma mark - PickerView Delegate
- (int) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (_selectedPicker == 0)
        return _bgList.count;
    else
        return _fontColorList.count;
}

- (int) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_selectedPicker == 0)
        return [[_bgList objectAtIndex:row] objectForKey:@"name"];
    else
        return [[_fontColorList objectAtIndex:row] objectForKey:@"name"];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_selectedPicker == 0) {
        NSString *imgFilename = [[_bgList objectAtIndex:row] objectForKey:@"filename"];
        UIImage *selectedImage = [UIImage imageNamed:imgFilename];
        [self.bgImageView setImage:selectedImage];
        
        [JASettings setBackgroundImageName:[[_bgList objectAtIndex:row] objectForKey:@"name"]];
        [JASettings setBackgroundImage:imgFilename];
        
    }
    else {
        self.timeLabel.textColor = [[_fontColorList objectAtIndex:row] objectForKey:@"color"];
        [JASettings setClockColorName:[[_fontColorList objectAtIndex:row] objectForKey:@"name"]];
        
    }
    
    [self.tableView reloadData];
    [self lowerPicker];
}

@end
