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


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [self setUserlist];
    
    NSLog(@"Settings:%@",[Settings sharedInstance]);
    
    [self.fontPopup addItemsWithTitles:[[NSFontManager sharedFontManager] availableFontFamilies]];

    
    for (int i=8; i<73; ++i)
        [self.sizePopup addItemWithTitle:[NSString stringWithFormat:@"%i pt",i]];

    
    NSFont * font =[Settings sharedInstance].settings.font;
    [self.sizePopup selectItemWithTitle:[NSString stringWithFormat:@"%i pt",(int)font.pointSize]];
    [self.fontPopup selectItemWithTitle:font.familyName];
    [self.textView setFont:font];
    
    [self.color setColor:[Settings sharedInstance].settings.textColor];
    [self.textView setTextColor:[Settings sharedInstance].settings.textColor];
}


-(void) setUserlist{
    _accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    if ([[self.accountStore accountsWithAccountType:twitterType] count]<1) {
        NSLog(@"NEED TO LOGIN");
    }
}

-(NSString*)trimMessageWithString:(NSString*)str{
    if ([str length]>(140-40)) {
        str=[str substringToIndex:140-40];
        str=[str stringByAppendingString:@"..."];
    }
    str=[str stringByAppendingString:@" #Collapsar"];
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
            }
            else {
                
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
            NSArray *accounts = [self.accountStore accountsWithAccountType:twitterType];
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
            imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
            
            [request addMultipartData:imageData
                             withName:@"media[]"
                                 type:@"image/jpeg"
                             filename:@"image.jpg"];
            [request setAccount:[accounts lastObject]];
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

- (IBAction)usersPopupAction:(id)sender {
}

- (IBAction)makeATweet:(id)sender{
    
}
- (IBAction)setImage:(id)sender {
    
    if ([[self.textView string] length]<2)
        return;
    
//    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:@"/System/Library/PreferencePanes/InternetAccounts.prefPane"]];
    
    NSSize size = NSMakeSize([[self.textView attributedString] size].width , [[self.textView attributedString] size].height);
    NSImage * im = [[NSImage alloc] initWithSize:size];
    [im lockFocus];
    [[self.textView attributedString] drawInRect:NSMakeRect(0, 0, size.width, size.height)];
    [im unlockFocus];
    [self.imageView setImage:im];
//    [[im TIFFRepresentation] writeToFile:@"/Users/serji/Desktop/foo.tiff" atomically:NO];
//    [self postImage:im withStatus:[self trimMessageWithString:[self.textView string]]];
}

@end
