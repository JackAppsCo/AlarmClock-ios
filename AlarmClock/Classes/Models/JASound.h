//
//  JASound.h
//  AlarmClock
//
//  Created by Brian C. Singer on 11/17/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface JASound : NSObject


@property (nonatomic, retain) NSString *name, *soundFilename;
@property (nonatomic, retain) MPMediaItemCollection *collection;

+ (void) saveSound:(JASound*)theSound;
+ (NSArray*) savedSounds;
+ (JASound*) defaultSound;

@end
