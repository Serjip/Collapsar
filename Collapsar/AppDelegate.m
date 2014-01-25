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
    
    _accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *twitterType =
    [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    NSLog(@"%@",[self.accountStore accountsWithAccountType:twitterType]);
    
    
    [self.fontPopup addItemsWithTitles:[[NSFontManager sharedFontManager] availableFontFamilies]];

}


- (IBAction)setImage:(id)sender {
    
    
    NSString * text = [self.textView string];
    
    NSFont *font = [[NSFontManager sharedFontManager] fontWithFamily:[[self.fontPopup selectedItem] title]
                                                              traits:0
                                                              weight:5
                                                                size:[[[self.sizePopup selectedItem] title] floatValue]];
    
    
    
    
    NSDictionary *attributes = @{NSFontAttributeName : font,NSForegroundColorAttributeName:[self.color color]};
    

    NSLog(@"%@",attributes);

//    NSLog(@"%f  %f",[text sizeWithAttributes:attributes].width,[text sizeWithAttributes:attributes].height);
    
    NSSize size = NSMakeSize([text sizeWithAttributes:attributes].width , [text sizeWithAttributes:attributes].height);
    
    NSImage * im = [[NSImage alloc] initWithSize:size];
    
    [im lockFocus];

    [text drawInRect:NSMakeRect(0, 0, size.width, size.height) withAttributes:attributes];
    
    [im unlockFocus];
    
    [self.imageView setImage:im];
    
    [[im TIFFRepresentation] writeToFile:@"/Users/serji/Desktop/foo.tiff" atomically:NO];
    
    [self postImage:im withStatus:@"Hello there"];
    

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

@end
