//
//  Settings.h
//  b-music
//
//  Created by Sergey P on 27.09.13.
//  Copyright (c) 2013 Sergey P. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsC : NSObject <NSCoding>

@property NSFont *font;
@property NSColor *textColor;
@property BOOL preferences;
@property BOOL firstTweet;

@end


@interface Settings : NSObject
@property SettingsC * settings;
+ (Settings *)sharedInstance;
-(void) saveSettings;
@end


