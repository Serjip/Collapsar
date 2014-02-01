//
//  AppDelegate.h
//  Collapsar
//
//  Created by Sergey P on 25.01.14.
//  Copyright (c) 2014 SergeyP. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Settings.h"
#import "KBButton.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,NSSharingServicePickerDelegate,NSUserNotificationCenterDelegate>
@property (weak) IBOutlet NSPopUpButton *fontPopup;
@property (weak) IBOutlet NSPopUpButton *sizePopup;
@property (weak) IBOutlet NSPopUpButton *userPopup;

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSColorWell *color;
@property (weak) IBOutlet KBButton *makeATweetBtn;

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (weak) IBOutlet NSLayoutConstraint *heightOfSettings;
@property (weak) IBOutlet NSTextField *stateLabel;

- (IBAction)fontPopupAction:(id)sender;
- (IBAction)fontSizePopupAction:(id)sender;
- (IBAction)colorAction:(id)sender;
- (IBAction)showPreferences:(id)sender;
- (IBAction)makeATweet:(id)sender;

@end
