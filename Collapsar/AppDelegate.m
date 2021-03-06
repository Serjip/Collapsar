//
//  AppDelegate.m
//  Collapsar
//
//  Created by Sergey P on 25.01.14.
//  Copyright (c) 2014 SergeyP. All rights reserved.
//


#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "AppDelegate.h"
#import "INAppStoreWindow.h"


@implementation AppDelegate

- (id)init
{
    self = [super init];
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return self;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //set notification delegate
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    //Checking twitter accounts
    [self checkUserTwitterAccounts:nil];
    
    //NSLog(@"Settings:%@",[Settings sharedInstance]);
    
    //Adding fontnames to popup
    [self.fontPopup addItemsWithTitles:[[NSFontManager sharedFontManager] availableFontFamilies]];

    //adding fontsizes to popup
    for (int i=8; i<73; ++i)
        [self.sizePopup addItemWithTitle:[NSString stringWithFormat:@"%i pt",i]];

    //select saved font and size
    NSFont * font =[Settings sharedInstance].settings.font;
    [self.sizePopup selectItemWithTitle:[NSString stringWithFormat:@"%i pt",(int)font.pointSize]];
    [self.fontPopup selectItemWithTitle:font.familyName];
    [self.textView setFont:font];
    
    //select saved color
    [self.color setColor:[Settings sharedInstance].settings.textColor];
    [self.textView setTextColor:[Settings sharedInstance].settings.textColor];
    
    //Set size of preferences
    [self.heightOfSettings setConstant:([Settings sharedInstance].settings.preferences)?50:0];
    
    
    INAppStoreWindow *aWindow = (INAppStoreWindow *) [self window];
	aWindow.titleBarHeight = 40.0;
	aWindow.trafficLightButtonsLeftMargin = 13.0;
	aWindow.titleBarDrawingBlock = ^(BOOL drawsAsMainWindow, CGRect drawingRect, CGPathRef clippingPath) {
		CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
		CGContextAddPath(ctx, clippingPath);
		CGContextClip(ctx);
        
		NSGradient *gradient = nil;
		if (drawsAsMainWindow) {
			gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1]
													 endingColor:[NSColor colorWithCalibratedRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1]];
			[[NSColor darkGrayColor] setFill];
		} else {
			// set the default non-main window gradient colors
			gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.851f alpha:1]
													 endingColor:[NSColor colorWithCalibratedWhite:0.929f alpha:1]];
			[[NSColor colorWithCalibratedWhite:0.6f alpha:1] setFill];
		}
		[gradient drawInRect:drawingRect angle:90];
#if !__has_feature(objc_arc)
        [gradient release];
#endif
		NSRectFill(NSMakeRect(NSMinX(drawingRect), NSMinY(drawingRect), NSWidth(drawingRect), 1));
	};
    
    //setting windows color & textView color
    NSColor * windowColor=[NSColor colorWithCalibratedRed:58/255.0 green:58/255.0 blue:58/255.0 alpha:1];
    [self.window setBackgroundColor:windowColor];
    [self.textView setBackgroundColor:windowColor];
    
    
    
    
    //Added observer changing accounts
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkUserTwitterAccounts:)
                                                 name:ACAccountStoreDidChangeNotification
                                               object:nil];
    
}

// show notifications
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

-(void) checkUserTwitterAccounts:(NSNotification *) notification{
    NSLog(@"Check");
    ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self.userPopup removeAllItems];
    
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler =
    ^(BOOL granted, NSError *error) {
        if (granted) {
            
            if ([[self.accountStore accountsWithAccountType:twitterType] count]<1) {
                [self chageActionTweetButton:NO];
                [self.stateLabel setStringValue:@"Sorry, no Twitter accounts were found! Please login."];
                
            }else{
                
                [self chageActionTweetButton:YES];
                [self.stateLabel setStringValue:@""];
                
                for (id account in [self.accountStore accountsWithAccountType:twitterType]){
                    [self.userPopup addItemWithTitle:[NSString stringWithFormat:@"@%@",[account username]]];
                }
            }
            
        }
        else {
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",[error localizedDescription]);
            [self chageActionTweetButton:NO];
            [self.stateLabel setStringValue:@"Please allow access to twitter account."];
        }
    };
    
    [self.accountStore requestAccessToAccountsWithType:twitterType
                                               options:NULL
                                            completion:accountStoreHandler];
}

-(void) chageActionTweetButton:(BOOL)flag{
    if (flag){
        [[self.makeATweetBtn cell] setKBButtonType:BButtonTypeSuccess];
        [self.makeATweetBtn setTitle:@"Tweet"];
        [self.makeATweetBtn setTarget:self];
        [self.makeATweetBtn setAction:@selector(makeATweet:)];
    }else{
        NSLog(@"Change button type");
        [[self.makeATweetBtn cell] setKBButtonType:BButtonTypeDanger];
        [self.makeATweetBtn setTitle:@"Login"];
        [self.makeATweetBtn setTarget:self];
        [self.makeATweetBtn setAction:@selector(loginToTwitterAccount:)];
    }
}


-(NSString*)trimMessageWithString:(NSString*)str{
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(@(\\w+)|#(\\w+))" options:0 error:&error];
    NSArray *matches = [regex matchesInString:str
                                      options:0
                                        range:NSMakeRange(0, str.length)];
    
    NSString * hashtags=@"";
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        hashtags = [NSString stringWithFormat:@"%@ %@",hashtags,[str substringWithRange:wordRange]];
    }
    
    str = [NSString stringWithFormat:@"%@ %@",hashtags,str];
    
    if ([str length]>(140-55)) {
        str=[str substringToIndex:140-55];
        str=[str stringByAppendingString:@"..."];
    }
    str=[str stringByAppendingString:@" #Collapsar"];
    
//    NSLog(@"%@",str);
    return str;
}



- (void)postImage:(NSImage *)image withStatus:(NSString *)status
{
    ACAccountType *twitterType =
    [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    SLRequestHandler requestHandler =
    ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        if (responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *postResponseData =
                [NSJSONSerialization JSONObjectWithData:responseData
                                                options:NSJSONReadingMutableContainers
                                                  error:NULL];
                
                NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.textView setString:@""];
                    
                    NSUserNotification *notification = [[NSUserNotification alloc] init];
                    notification.title = @"Tweet has been posted";
                    //notification.informativeText = @"";
                    
                    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                    
                    if (![Settings sharedInstance].settings.firstTweet){
                        NSAlert * alert=[[NSAlert alloc] init];
                        [alert addButtonWithTitle:@"Yes"];
                        [alert addButtonWithTitle:@"No, thanks"];
                        [alert setMessageText:@"Yep! Your first tweet successfully posted!"];
                        [alert setInformativeText:@"Would you like to follow us on twitter (@HackStoreTeam) to know more about our apps and updates?"];
                    
                    
                        [alert beginSheetModalForWindow:self.window
                                          modalDelegate:self
                                         didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                                            contextInfo:nil];
                        
                        [Settings sharedInstance].settings.firstTweet=YES;
                        [[Settings sharedInstance]saveSettings];
                    }
                });
                
            }else {
                
                NSDictionary *postResponseData =
                [NSJSONSerialization JSONObjectWithData:responseData
                                                options:NSJSONReadingMutableContainers
                                                  error:NULL];
                NSLog(@"%@",postResponseData);
                
                NSLog(@"[ERROR] Server responded: status code %ld %@", (long)statusCode,
                      [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
            }
        }
        else {
            NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
        }
    };
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler =
    ^(BOOL granted, NSError *error) {
        if (granted) {
            
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                          @"/1.1/statuses/update_with_media.json"];
            NSDictionary *params = @{@"status" : status};
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodPOST
                                                              URL:url
                                                       parameters:params];
            
            
            NSData *imageData = [image TIFFRepresentation];
            NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
            NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
            imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
            
            [request addMultipartData:imageData
                             withName:@"media[]"
                                 type:@"image/png"
                             filename:@"image.png"];
            [request setAccount:[self currentAccount:twitterType]];
            [request performRequestWithHandler:requestHandler];
        }
        else {
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
                  [error localizedDescription]);
        }
    };
    
    [self.accountStore requestAccessToAccountsWithType:twitterType
                                               options:NULL
                                            completion:accountStoreHandler];
}


- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://twitter.com/HackStoreTeam"]];
    }
}

-(ACAccount*)currentAccount:(ACAccountType*)twitterType{
    NSArray *accounts = [self.accountStore accountsWithAccountType:twitterType];
    
    ACAccount * currentAcc;
    NSString * username = [[self.userPopup titleOfSelectedItem] substringFromIndex:1];
    for (id account in accounts) {
        if ([[account username] isEqualToString:username]) {
            currentAcc=account;
        }
    }
    
    
    return currentAcc;
}

#pragma mark actions
- (IBAction)fontPopupAction:(id)sender {
    CGFloat fontSize= [self.sizePopup indexOfSelectedItem]+8;
    NSString * familyName=[sender titleOfSelectedItem];
    NSFont * font = [NSFont fontWithName:familyName size:fontSize];
    [self.textView setFont:font];
    
    [Settings sharedInstance].settings.font=font;
    [[Settings sharedInstance] saveSettings];
}

- (IBAction)fontSizePopupAction:(id)sender {
    CGFloat fontSize= [sender indexOfSelectedItem]+8;
    NSString * familyName=[self.fontPopup titleOfSelectedItem];
    NSFont * font = [NSFont fontWithName:familyName size:fontSize];
    [self.textView setFont:font];
    
    [Settings sharedInstance].settings.font=font;
    [[Settings sharedInstance] saveSettings];
}

- (IBAction)colorAction:(id)sender {
    [self.textView setTextColor:[sender color]];
    [Settings sharedInstance].settings.textColor=[sender color];
    [[Settings sharedInstance] saveSettings];
}

- (IBAction)showPreferences:(id)sender{
    if([self.heightOfSettings constant]==0){
        [[self.heightOfSettings animator] setConstant:50];
        [Settings sharedInstance].settings.preferences=YES;
    }else{
        [[self.heightOfSettings animator] setConstant:0];
        [Settings sharedInstance].settings.preferences=NO;
    }
    [[Settings sharedInstance] saveSettings];
}

- (IBAction)loginToTwitterAccount:(id)sender{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:@"/System/Library/PreferencePanes/InternetAccounts.prefPane"]];
}

- (IBAction)makeATweet:(id)sender {
    
    if ([[self.textView string] length]<2)
        return;
    
    ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    if ([[self.accountStore accountsWithAccountType:twitterType] count]<1){
            [self.stateLabel setStringValue:@"No twitter accounts were found!"];
        return;
    }else{
        [self.stateLabel setStringValue:@""];
    }
    
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    NSLayoutManager *layoutManager = [self.textView layoutManager];
    NSInteger numberOfLines, index, numberOfGlyphs = [layoutManager numberOfGlyphs];
    NSRange lineRange;
    for (numberOfLines = 0, index = 0; index < numberOfGlyphs; numberOfLines++){
        
        if (index>0) {
            
            if ([[self.textView string] characterAtIndex:index-1]!=10) {
                [arr addObject:@(index-1)];
            }
        }
        
        (void) [layoutManager lineFragmentRectForGlyphAtIndex:index
                                               effectiveRange:&lineRange];
        index = NSMaxRange(lineRange);
    }
    
    int num=0;
    NSMutableString *newString=[NSMutableString stringWithString:[self.textView string]];
    for (id index in arr) {
        [newString insertString:@"\n" atIndex:[index integerValue]+num+1];
        ++num;
    }
    
    NSDictionary *attrsDictionary =@{NSFontAttributeName:self.textView.font,
                                     NSForegroundColorAttributeName:self.textView.textColor};

    NSAttributedString *attrString =
    [[NSAttributedString alloc] initWithString:newString
                                    attributes:attrsDictionary];
    
    NSSize size = NSMakeSize([attrString size].width , [attrString size].height);
    NSImage * im = [[NSImage alloc] initWithSize:size];
    [im lockFocus];
    [attrString drawInRect:NSMakeRect(0, 0, size.width, size.height)];
    [im unlockFocus];
    
    
    [self postImage:im withStatus:[self trimMessageWithString:[self.textView string]]];
}
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

@end
