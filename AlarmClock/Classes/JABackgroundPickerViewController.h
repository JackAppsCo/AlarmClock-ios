//
//  JABackgroundPickerViewController.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/22/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JABackgroundPickerViewController : UIViewController <UIImagePickerControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIImageView *customImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *backgroundList;
@property (strong, nonatomic) NSString *customImageURL;
@property (strong, nonatomic) IBOutlet UIButton *doneButton, *customImageButton;

- (IBAction)doneButtonPressed:(id)sender;

@end
