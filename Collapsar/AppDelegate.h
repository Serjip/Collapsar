//
//  AppDelegate.h
//  Collapsar
//
//  Created by Sergey P on 25.01.14.
//  Copyright (c) 2014 SergeyP. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface AppDelegate : NSObject <NSApplicationDelegate,NSSharingServicePickerDelegate>
@property (weak) IBOutlet NSPopUpButton *fontPopup;
@property (weak) IBOutlet NSPopUpButton *sizePopup;

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSColorWell *color;

@property (nonatomic, strong) ACAccountStore *accountStore;

- (IBAction)setImage:(id)sender;
@end