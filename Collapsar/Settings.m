//
//  Settings.m
//  b-music
//
//  Created by Sergey P on 27.09.13.
//  Copyright (c) 2013 Sergey P. All rights reserved.
//

#import "Settings.h"
@implementation SettingsC

#define userDefaults @"com.collapsar.settings"//String where is the data located

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _font=[coder decodeObjectForKey:@"font"];
        _textColor=[coder decodeObjectForKey:@"textColor"];
        _preferences =[coder decodeBoolForKey:@"preferences"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_font      forKey:@"font"];
    [aCoder encodeObject:_textColor forKey:@"textColor"];
    [aCoder encodeBool:_preferences forKey:@"preferences"];
}

@end

@implementation Settings


+ (Settings *)sharedInstance {
    static dispatch_once_t pred;
    static Settings *sharedInstance = nil;
    dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [defaults dataForKey:userDefaults];
        
        //[defaults removeObjectForKey:userDefaults];
        if (data) {
            _settings = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        } else {
            NSLog(@"First Launching");
            _settings = [[SettingsC alloc] init];
            
            self.settings.font=[NSFont fontWithName:@"Helvetica" size:15];
            self.settings.textColor = [NSColor blackColor];
            self.settings.preferences = NO;
            
            [self saveSettings];
        }
    }
    return self;
}
- (void)saveSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:_settings] forKey:userDefaults];
    [defaults synchronize];
}

-(NSString *)description{
    NSMutableDictionary * list= [[NSMutableDictionary alloc]init];
    
    [list setValue:self.settings.font           forKey:@"font"];
    [list setValue:self.settings.textColor      forKey:@"textColor"];
    [list setValue:@(self.settings.preferences) forKey:@"preferences"];
    
    return [NSString stringWithFormat:@"%@", list];
}

@end
