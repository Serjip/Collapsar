//
//  AppDelegate.h
//  Collapsar
//
//  Created by Sergey P on 25.01.14.
//  Copyright (c) 2014 SergeyP. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Settings.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,NSSharingServicePickerDelegate>
@property (weak) IBOutlet NSPopUpButton *fontPopup;
@property (weak) IBOutlet NSPopUpButton *sizePopup;
@property (weak) IBOutlet NSPopUpButton *userPopup;

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSColorWell *color;

@property (weak) IBOutlet NSButton *login;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (weak) IBOutlet NSLayoutConstraint *heightOfSettings;

- (IBAction)fontPopupAction:(id)sender;
- (IBAction)fontSizePopupAction:(id)sender;
- (IBAction)colorAction:(id)sender;
- (IBAction)usersPopupAction:(id)sender;
- (IBAction)makeATweet:(id)sender;
- (IBAction)setImage:(id)sender;
- (IBAction)loginAct:(id)sender;

@end
