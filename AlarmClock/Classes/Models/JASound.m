//
//  JASound.m
//  AlarmClock
//
//  Created by Brian C. Singer on 11/17/12.
//  Copyright (c) 2012 JA. All rights reserved.
//

#import "JASound.h"

@implementation JASound

@synthesize name = _name, soundFilename = _soundFilename, collection = _collection;

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_soundFilename forKey:@"soundFilename"];
    [encoder encodeObject:_name forKey:@"soundName"];
    [encoder encodeObject:_collection forKey:@"soundCollection"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self != nil)
	{

        [self setName:[coder decodeObjectForKey:@"soundName"]];
        [self setSoundFilename:[coder decodeObjectForKey:@"soundFilename"]];
        [self setCollection:[coder decodeObjectForKey:@"soundCollection"]];
        
	}
    return self;
}


#pragma mark - Class Methods

+ (void) saveSound:(JASound *)theSound
{
    if (!theSound)
        return;
    
  
    //grab current saved sounds
    NSMutableArray *sounds = [[NSMutableArray alloc] initWithArray:[JASound savedSounds]];
    [sounds addObject:theSound];
    
    
    //save current alarms
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *yourArrayAsData = [NSKeyedArchiver archivedDataWithRootObject:sounds];
    [ud setObject:yourArrayAsData forKey:@"savedSounds"];
}


//return saved alarms
+ (NSArray*) savedSounds
{
    NSArray *localSounds;
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingSavedArray = [currentDefaults objectForKey:@"savedSounds"];
    if (dataRepresentingSavedArray != nil) {
        NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
        if (oldSavedArray != nil)
            localSounds = [[NSArray alloc] initWithArray:oldSavedArray];
        else
            localSounds = [[NSArray alloc] init];
    }
    
    return localSounds;
}

+ (JASound*)defaultSound
{
    JASound *defaultSound = [[JASound alloc] init];
    [defaultSound setName:@"Alarm"];
    [defaultSound setSoundFilename:@"Background__Alarm_.wav"];
    [defaultSound setCollection:nil];
    
    return defaultSound;
}


//desc
- (NSString*) description {
    
    NSString *desc = @"------SOUND-----\n";
    
    desc = [NSString stringWithFormat:@"%@ name:%@", desc, self.name, nil];
    desc = [NSString stringWithFormat:@"%@ soundFilename:%@;", desc, self.soundFilename, nil];
    desc = [NSString stringWithFormat:@"%@ soundCollection: %@", desc, self.collection, nil];
    
    return desc;
    
}

@end
