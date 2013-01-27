//
//  JASoundSelectorTableViewController.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/17/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JASoundSelectorTableViewController.h"
#import "VoiceRecordViewController.h"
#import "JASettings.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface JASoundSelectorTableViewController ()
- (IBAction)showMediaPicker:(id)sender;
@end

@implementation JASoundSelectorTableViewController

@synthesize delegate, soundList, selectedSound;

- (id)initWithDelegate:(id <JASoundSelectorTableViewControllerDelegate>)theDelegate
{
    return [self initWithDelegate:theDelegate sound:nil];
}

- (id)initWithDelegate:(id <JASoundSelectorTableViewControllerDelegate>)theDelegate sound:(JASound*)aSound
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        _currentlyPlayingFilename = @"";
        
        [self setDelegate:theDelegate];
        
        //setup the dictionary from Settings.plist
		NSString *soundsLocation = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"soundsList.plist"];
		NSDictionary *soundsDict = [[NSDictionary alloc] initWithContentsOfFile:soundsLocation];
        [self setSoundList:[soundsDict objectForKey:@"sounds"]];
        [self setGentleSoundList:[soundsDict objectForKey:@"gentle"]];
        
        //set the selected sound
        if (!aSound) {
            JASound *newSound = [[JASound alloc] init];
            [newSound setName:[(NSDictionary*)[soundList objectAtIndex:0] objectForKey:@"name"]];
            [newSound setSoundFilename:[(NSDictionary*)[soundList objectAtIndex:0] objectForKey:@"filename"]];
            [self setSelectedSound:newSound];
        }
        else {
            [self setSelectedSound:aSound];
        }
        
        self.aPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.selectedSound.soundFilename]
                                                              error:nil];
        [self.aPlayer prepareToPlay];
        
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.aPlayer isPlaying]) {
        [self.aPlayer stop];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Alarm Sound";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIButton *) makeDetailDisclosureButtonWithImage:(NSString*)image
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, [UIImage imageNamed:image].size.width, button.imageView.image.size.height)];
    [button addTarget: self
               action: @selector(accessoryButtonTapped:withEvent:)
     forControlEvents: UIControlEventTouchUpInside];
    
    return (button);
}

- (void)stopSample:(NSTimer*)theTimer
{
    if ([self.aPlayer isPlaying]) {
        [self.aPlayer stop];
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return self.gentleSoundList.count;
    else if (section == 1)
        return self.soundList.count;
    else if (section == 2)
        return (1 + [JASound savedSounds].count);
    else
        return 1;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return NSLocalizedString(@"Gentle Alarms", nil);
    else if (section == 1)
        return NSLocalizedString(@"Alarm Sounds", nil);
    else if (section == 2)
        return NSLocalizedString(@"Custom Alarms", nil);
    else
        return NSLocalizedString(@"iPhone Music", nil);
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *labelString = @"";
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30.0f)];
    [headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    if (section == 0)
        labelString = NSLocalizedString(@"Gentle Alarms", nil);
    else if (section == 1)
        labelString = NSLocalizedString(@"Alarm Sounds", nil);
    else if (section == 2)
        labelString = NSLocalizedString(@"Custom Alarms", nil);
    else
        labelString = NSLocalizedString(@"iPhone Music", nil);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.view.frame.size.width - 30.0, 30.0f)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont fontWithName:TITLE_FONT size:17]];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setTextColor:[UIColor colorWithRed:59.0/255.0 green:67.0/255.0 blue:90.0/255.0 alpha:1.0]];
    [label setNumberOfLines:0];
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(0, 1)];
    [label setText:labelString];
    [headerView addSubview:label];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SoundCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        cell.textLabel.font = [UIFont fontWithName:CELL_TEXT_FONT size:18];
        cell.detailTextLabel.font = [UIFont fontWithName:CELL_DETAIL_TEXT_FONT size:18];
        
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    
    if (indexPath.section == 0) {
        
        if (![JASettings isPaid] && ![[(NSDictionary*)[self.gentleSoundList objectAtIndex:indexPath.row] objectForKey:@"free"] boolValue])
            cell.textLabel.textColor = [UIColor grayColor];
        
        // Configure the cell...
        cell.textLabel.text = [(NSDictionary*)[self.gentleSoundList objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        if ([[(NSDictionary*)[self.gentleSoundList objectAtIndex:indexPath.row] objectForKey:@"filename"] isEqualToString:self.selectedSound.soundFilename]) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            //cell.imageView.image = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if (indexPath.section == 1) {
        
        if (![JASettings isPaid] && ![[(NSDictionary*)[self.soundList objectAtIndex:indexPath.row] objectForKey:@"free"] boolValue])
            cell.textLabel.textColor = [UIColor grayColor];
        
        // Configure the cell...
        cell.textLabel.text = [(NSDictionary*)[soundList objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        if ([[(NSDictionary*)[soundList objectAtIndex:indexPath.row] objectForKey:@"filename"] isEqualToString:self.selectedSound.soundFilename]) {
            //cell.imageView.image = [UIImage imageNamed:@"plus"];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            //cell.imageView.image = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Record A New Sound", nil);
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = nil;
        }
        else {
            cell.textLabel.text = [(JASound*)[[JASound savedSounds] objectAtIndex:(indexPath.row - 1)] name];
            
            /*if ([[(JASound*)[[JASound savedSounds] objectAtIndex:(indexPath.row - 1)] soundFilename] isEqualToString:_currentlyPlayingFilename]) {
             [cell setAccessoryView:[self makeDetailDisclosureButtonWithImage:@"stopButton.png"]];
             }
             else {
             [cell setAccessoryView:[self makeDetailDisclosureButtonWithImage:@"playButton.png"]];
             }*/
            
            if ([[(JASound*)[[JASound savedSounds] objectAtIndex:(indexPath.row - 1)] soundFilename] isEqualToString:self.selectedSound.soundFilename]) {
                //cell.imageView.image = [UIImage imageNamed:@"plus"];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                //cell.imageView.image = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    else {
        if (self.selectedSound.collection) {
            cell.textLabel.text = [[self.selectedSound.collection.items objectAtIndex:0] valueForProperty:MPMediaItemPropertyTitle];
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.textLabel.text = NSLocalizedString(@"Choose From Library", nil);
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (void) accessoryButtonTapped: (UIControl *) button withEvent: (UIEvent *) event
{
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil )
        return;
    
    [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    //check to see if it was a stop button
    if (self.aPlayer.playing) {
        
        if (indexPath.section == 0) {
            
            if ([[(NSDictionary*)[self.gentleSoundList objectAtIndex:indexPath.row] objectForKey:@"filename"] isEqualToString:_currentlyPlayingFilename]) {
                [self.aPlayer stop];
                _currentlyPlayingFilename = @"";
                [self.tableView reloadData];
                return;
            }
            
        }
        else if (indexPath.section == 1) {
            
            if ([[(NSDictionary*)[soundList objectAtIndex:indexPath.row] objectForKey:@"filename"] isEqualToString:_currentlyPlayingFilename]) {
                [self.aPlayer stop];
                _currentlyPlayingFilename = @"";
                [self.tableView reloadData];
                return;
            }
            
        }
        else if (indexPath.section == 2 && indexPath.row != 0) {
            
            if ([[(JASound*)[[JASound savedSounds] objectAtIndex:(indexPath.row - 1)] soundFilename] isEqualToString:_currentlyPlayingFilename]) {
                [self.aPlayer stop];
                _currentlyPlayingFilename = @"";
                [self.tableView reloadData];
                return;
            }
        }
        
    }
    
    NSString *filename, *soundFilePath;
    NSURL *fileURL;
    if (indexPath.section == 0) {
        _currentlyPlayingFilename = filename = [(NSDictionary*)[self.gentleSoundList objectAtIndex:indexPath.row] objectForKey:@"filename"];
    }
    else if (indexPath.section == 1) {
        _currentlyPlayingFilename = filename = [(NSDictionary*)[soundList objectAtIndex:indexPath.row] objectForKey:@"filename"];
    }
    else if (indexPath.section == 2 && indexPath.row != 0) {
        _currentlyPlayingFilename = filename = [(JASound*)[[JASound savedSounds] objectAtIndex:(indexPath.row - 1)] soundFilename];
    }
    
    if ([filename rangeOfString:@".caf"].location == NSNotFound) {
        soundFilePath = [[NSBundle mainBundle] pathForResource:[[filename componentsSeparatedByString:@"."] objectAtIndex:0]
                                                        ofType:[[filename componentsSeparatedByString:@"."] objectAtIndex:1]];
    }
    else {
        soundFilePath = filename;
    }
    
    fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    
    NSError *err;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL
                                                                   error:&err];
    
    if (err)
        NSLog(@"ERR: %@", err);
    
    self.aPlayer = player;
    self.aPlayer.delegate = nil;
    self.aPlayer.volume = 1.0f;
    [self.aPlayer setNumberOfLoops:-1];
    [self.aPlayer play];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JASound *newSound = nil;
    
    if (indexPath.section == 2) {
        
        if (indexPath.row == 0) {
            VoiceRecordViewController *recorder = [[VoiceRecordViewController alloc] initWithNibName:@"VoiceRecordViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController pushViewController:recorder animated:YES];
            
            return;
        }
        else {
            
            [self setSelectedSound:(JASound*)[[JASound savedSounds] objectAtIndex:(indexPath.row - 1)]];
            
            newSound = [[JASound savedSounds] objectAtIndex:(indexPath.row - 1)];
            
        }
        
    }
    else if (indexPath.section == 0) {
        
        if ([JASettings isPaid] || (![JASettings isPaid] && [[(NSDictionary*)[self.gentleSoundList objectAtIndex:indexPath.row] objectForKey:@"free"] boolValue])) {
            newSound = [[JASound alloc] init];
            [newSound setName:[(NSDictionary*)[self.gentleSoundList objectAtIndex:indexPath.row] objectForKey:@"name"]];
            [newSound setSoundFilename:[(NSDictionary*)[self.gentleSoundList objectAtIndex:indexPath.row] objectForKey:@"filename"]];
            [self setSelectedSound:newSound];
        }
        else {
            UIAlertView *freeAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SleepSmart Premium\nJust Released!", nil) message:NSLocalizedString(@"Want MORE features, MORE sounds and NO ads? Then UPGRADE to SleepSmart Premium NOW!!!\n\n*******************************************\nSleepSmart Premium Upgrades Include:\n\n→ A unique “Rise & Shine” feature that emulates the rising sun. Designed to trigger your natural body clock and trick your brain into thinking it’s morning, even if it is dark outside!\n→ Full access to ALL Classic Alarm sounds and Gentle Wake sounds!\n→ Full access to ALL White Noise Sleep Timer themes including Beach, Countryside, Waterfall and many more!\n\nGet it NOW! SleepSmart. LiveSmart.\n*******************************************", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No Thanks", nil) otherButtonTitles:NSLocalizedString(@"Upgrade Me!", nil), nil];
            [freeAlert show];
            return;
        }
    }
    else if (indexPath.section == 1) {
        if ([JASettings isPaid] || (![JASettings isPaid] && [[(NSDictionary*)[self.soundList objectAtIndex:indexPath.row] objectForKey:@"free"] boolValue])) {
            
            newSound = [[JASound alloc] init];
            [newSound setName:[(NSDictionary*)[soundList objectAtIndex:indexPath.row] objectForKey:@"name"]];
            [newSound setSoundFilename:[(NSDictionary*)[soundList objectAtIndex:indexPath.row] objectForKey:@"filename"]];
            [self setSelectedSound:newSound];
        }
        else {
            UIAlertView *freeAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SleepSmart Premium\nJust Released!", nil) message:NSLocalizedString(@"Want MORE features, MORE sounds and NO ads? Then UPGRADE to SleepSmart Premium NOW!!!\n\n*******************************************\nSleepSmart Premium Upgrades Include:\n\n→ A unique “Rise & Shine” feature that emulates the rising sun. Designed to trigger your natural body clock and trick your brain into thinking it’s morning, even if it is dark outside!\n→ Full access to ALL Classic Alarm sounds and Gentle Wake sounds!\n→ Full access to ALL White Noise Sleep Timer themes including Beach, Countryside, Waterfall and many more!\n\nGet it NOW! SleepSmart. LiveSmart.\n*******************************************", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No Thanks", nil) otherButtonTitles:NSLocalizedString(@"Upgrade Me!", nil), nil];
            [freeAlert show];
            return;
        }
    }
    else {
        [self showMediaPicker:nil];
    }
    
    [self.tableView reloadData];
    
    if (newSound && self.delegate && [(id)self.delegate respondsToSelector:@selector(soundSelectorTableViewController:choseSound:)]) {
        [self.delegate soundSelectorTableViewController:self choseSound:newSound];
    }
    
    
    
    //preview sound
    if (indexPath.section < 3) {
        
        NSString *filename, *soundFilePath;
        NSURL *fileURL;
        if (indexPath.section == 0) {
            _currentlyPlayingFilename = filename = [(NSDictionary*)[self.gentleSoundList objectAtIndex:indexPath.row] objectForKey:@"filename"];
        }
        else if (indexPath.section == 1) {
            _currentlyPlayingFilename = filename = [(NSDictionary*)[soundList objectAtIndex:indexPath.row] objectForKey:@"filename"];
        }
        else if (indexPath.section == 2 && indexPath.row != 0) {
            _currentlyPlayingFilename = filename = [(JASound*)[[JASound savedSounds] objectAtIndex:(indexPath.row - 1)] soundFilename];
        }
        
        if ([filename rangeOfString:@".caf"].location == NSNotFound) {
            soundFilePath = [[NSBundle mainBundle] pathForResource:[[filename componentsSeparatedByString:@"."] objectAtIndex:0]
                                                            ofType:[[filename componentsSeparatedByString:@"."] objectAtIndex:1]];
        }
        else {
            soundFilePath = filename;
        }
        
        fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
        
        NSError *err;
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL
                                                                       error:&err];
        
        if (err)
            NSLog(@"ERR: %@", err);
        
        self.aPlayer = player;
        self.aPlayer.delegate = nil;
        self.aPlayer.volume = 1.0f;
        [self.aPlayer setNumberOfLoops:0];
        [self.aPlayer play];
        
        
        //incase the timer's already running invalidate it
        if (_stopTimer.isValid) {
            [_stopTimer invalidate];
        }
        
        _stopTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:(indexPath.section == 0) ? 5 : 3] interval:0 target:self selector:@selector(stopSample:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_stopTimer forMode:NSRunLoopCommonModes];
        
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return (indexPath.section == 2 && indexPath.row != 0) ? YES : NO;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source
        [JASound removeSound:[[JASound savedSounds] objectAtIndex:(indexPath.row - 1)]];
        [self.tableView reloadData];
        
        
    }
}


#pragma mark - Media Picker
// Configures and displays the media item picker.
- (IBAction) showMediaPicker: (id) sender {
    
	MPMediaPickerController *picker =
    [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
	picker.delegate						= self;
	picker.allowsPickingMultipleItems	= NO;
    picker.showsCloudItems              = NO;
    
	[self presentModalViewController:picker animated:YES];
	
}


// Responds to the user tapping Done after choosing music.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    
    if (mediaItemCollection.count > 0) {
        
        JASound *newSound = [[JASound alloc] init];
        newSound.name = [[[mediaItemCollection items] objectAtIndex:0] valueForProperty:MPMediaItemPropertyTitle];
        newSound.soundFilename = [[[mediaItemCollection.items objectAtIndex:0] valueForProperty:MPMediaItemPropertyAssetURL] absoluteString];
        MPMediaItem *item = [mediaItemCollection.items objectAtIndex:0];
        NSLog(@"URL: %@", [item valueForProperty:MPMediaItemPropertyAssetURL]);
        newSound.collection = mediaItemCollection;
        self.selectedSound = newSound;
        
        if (newSound && self.delegate && [(id)self.delegate respondsToSelector:@selector(soundSelectorTableViewController:choseSound:)]) {
            [self.delegate soundSelectorTableViewController:self choseSound:newSound];
        }
    }
    
    [self.tableView reloadData];
	[self dismissModalViewControllerAnimated: YES];
    
    
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated:YES];
}


// Responds to the user tapping done having chosen no music.
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    
    [self.tableView reloadData];
	[self dismissModalViewControllerAnimated: YES];
    
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated:YES];
}


@end
