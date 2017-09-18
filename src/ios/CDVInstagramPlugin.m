/*
    The MIT License (MIT)
    Copyright (c) 2013 - 2014 Vlad Stirbu
    
    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    
    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Cordova/CDV.h>
#import "CDVInstagramPlugin.h"

static NSString *InstagramId = @"com.burbn.instagram";

@implementation CDVInstagramPlugin

@synthesize toInstagram;
@synthesize callbackId;
@synthesize interactionController;

-(void)isInstalled:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    CDVPluginResult *result;
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    }
    
}

- (void)share:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    self.toInstagram = FALSE;
    NSString    *objectAtIndex0 = [command argumentAtIndex:0];
    NSString    *caption = [command argumentAtIndex:1];
    
    CDVPluginResult *result;
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        NSLog(@"open in instagram");
        
        NSData *imageObj = [[NSData alloc] initWithBase64EncodedString:objectAtIndex0 options:0];
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *path = [tmpDir stringByAppendingPathComponent:@"instagram.igo"];
        
        [imageObj writeToFile:path atomically:true];
        
        self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
        self.interactionController.UTI = @"com.instagram.exclusivegram";
        if (caption) {
            self.interactionController.annotation = @{@"InstagramCaption" : caption};
        }
        self.interactionController.delegate = self;
        [self.interactionController presentOpenInMenuFromRect:CGRectZero inView:self.webView animated:YES];
        
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:1];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    }
}

- (void)shareAsset:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    NSString    *localIdentifier = [command argumentAtIndex:0];
    
    CDVPluginResult *result;
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        NSLog(@"open asset in instagram");
        
		NSString *localIdentifierEscaped = [localIdentifier stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
		NSURL *instagramShareURL   = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?LocalIdentifier=%@", localIdentifierEscaped]];
		
		[[UIApplication sharedApplication] openURL:instagramShareURL];

		result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];

    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:1];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    }
}

- (void)shareUrl:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    self.toInstagram = FALSE;
    NSString *mediaUrl = [command argumentAtIndex:0];

    CDVPluginResult *result;

    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        NSLog(@"open in instagram");

        if ([mediaUrl isEqualToString:self.lastDownloadedMediaUrl]) {
            NSString *tmpDir = NSTemporaryDirectory();
            NSString *extension = [mediaUrl pathExtension];
            if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"png"]) {
                extension = @"igo";
            }
            NSString *fileName = [NSString stringWithFormat:@"instagram.%@", extension];
            NSString *path = [tmpDir stringByAppendingPathComponent:fileName];
            self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];

            if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"png"]) {
                self.interactionController.UTI = @"com.instagram.exclusivegram";
            } else {
                self.interactionController.UTI = @"com.instagram.video";
            }
            self.interactionController.delegate = self;
            [self.interactionController presentOpenInMenuFromRect:CGRectZero inView:self.webView animated:YES];

            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:1];
            [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
        }

        // get image from URL
        /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"Loading %@", mediaUrl);
            NSData *mediaData = [NSData dataWithContentsOfURL:[NSURL URLWithString:mediaUrl]];

            if (mediaData) {
                NSLog(@"Saving %@", mediaUrl);
                NSString *tmpDir = NSTemporaryDirectory();
                NSString *extension = [mediaUrl pathExtension];
                if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"png"]) {
                    extension = @"igo";
                }
                NSString *fileName = [NSString stringWithFormat:@"instagram.%@", extension];
                NSString *path = [tmpDir stringByAppendingPathComponent:fileName];

                [mediaData writeToFile:path atomically:true];

                if (progressCallbackName) {
                    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@);", progressCallbackName, "1"]];
                }

                self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];

                if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"png"]) {
                    self.interactionController.UTI = @"com.instagram.exclusivegram";
                } else {
                    self.interactionController.UTI = @"com.instagram.video";
                }
                self.interactionController.delegate = self;
                [self.interactionController presentOpenInMenuFromRect:CGRectZero inView:self.webView animated:YES];
            }
        });*/

    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:1];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    }
}

- (void)downloadFromUrl:(CDVInvokedUrlCommand*)command {
    self.downloadProgressCallbackId = command.callbackId;
    NSString *mediaUrl = [command argumentAtIndex:0];
    self.downloadProgressCallbackName = [command argumentAtIndex:1];

    CDVPluginResult *result;

    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        NSLog(@"Download from URL");

        NSURL *url = [NSURL URLWithString:mediaUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:1];
        [self.commandDelegate sendPluginResult:result callbackId: self.downloadProgressCallbackId];
    }
}

- (void) documentInteractionController: (UIDocumentInteractionController *) controller willBeginSendingToApplication: (NSString *) application {
    if ([application isEqualToString:InstagramId]) {
        self.toInstagram = TRUE;
    }
}

- (void) documentInteractionControllerDidDismissOpenInMenu: (UIDocumentInteractionController *) controller {
    CDVPluginResult *result;
    
    if (self.toInstagram) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:2];
        [self.commandDelegate sendPluginResult:result callbackId: self.callbackId];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)urlResponse {
    NSLog(@"Loading %@", [connection currentRequest]);

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) urlResponse;
    NSDictionary *dict = httpResponse.allHeaderFields;
    NSString *lengthString = [dict valueForKey:@"Content-Length"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *length = [formatter numberFromString:lengthString];
    self.totalBytes = length.unsignedIntegerValue;

    self.mediaData = [[NSMutableData alloc] initWithCapacity:self.totalBytes];

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.mediaData appendData:data];
    self.receivedBytes += data.length;

    NSLog(@"Loading %lu / %lu", (unsigned long)self.receivedBytes, (unsigned long)self.totalBytes);

    if (self.downloadProgressCallbackName) {
        if ([self.webView isKindOfClass:[UIWebView class]]) {
            NSString *mediaUrl = [[[connection currentRequest] URL] absoluteString];
            NSString *jsString = [NSString stringWithFormat:@"%@('%@', %lu, %lu);", self.downloadProgressCallbackName, mediaUrl, self.receivedBytes, self.totalBytes];
            NSLog(@"Calling %@", jsString);
            [(UIWebView*)self.webView stringByEvaluatingJavaScriptFromString:jsString];
        }
    }

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Finished loading %@", [connection currentRequest]);

    CDVPluginResult *result;
    NSString *mediaUrl = [[[connection currentRequest] URL] absoluteString];
    self.lastDownloadedMediaUrl = [[[connection currentRequest] URL] absoluteString];
    NSData *mediaData = [NSData dataWithData:self.mediaData];

    if (mediaData) {
        NSLog(@"Saving media locally");
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *extension = [mediaUrl pathExtension];
        if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"png"]) {
            extension = @"igo";
        }
        NSString *fileName = [NSString stringWithFormat:@"instagram.%@", extension];
        NSString *path = [tmpDir stringByAppendingPathComponent:fileName];

        [mediaData writeToFile:path atomically:true];

        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId: self.downloadProgressCallbackId];
    } else {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:2];
        [self.commandDelegate sendPluginResult:result callbackId: self.downloadProgressCallbackId];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error loading %@", [connection currentRequest]);
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:2];
    [self.commandDelegate sendPluginResult:result callbackId: self.downloadProgressCallbackId];
}

@end
