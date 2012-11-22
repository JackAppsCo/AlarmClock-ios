//
//  JASoundSelectorTableViewController.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/17/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "JASound.h"
#import <MediaPlayer/MediaPlayer.h>

@protocol JASoundSelectorTableViewControllerDelegate;

@interface JASoundSelectorTableViewController : UITableViewController <MPMediaPickerControllerDelegate>
{
    SystemSoundID soundID;
}

- (id)initWithDelegate:(id <JASoundSelectorTableViewControllerDelegate>)theDelegate;
- (id)initWithDelegate:(id <JASoundSelectorTableViewControllerDelegate>)theDelegate sound:(JASound*)aSound;

@property (strong, nonatomic) NSArray *soundList;
@property (strong, nonatomic) id <JASoundSelectorTableViewControllerDelegate> delegate;
@property (strong, nonatomic) JASound *selectedSound;



@end



@protocol JASoundSelectorTableViewControllerDelegate

- (void) soundSelectorTableViewController:(JASoundSelectorTableViewController*)controller choseSound:(JASound*)sound;

@end