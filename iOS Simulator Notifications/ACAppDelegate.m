//
//  ACAppDelegate.m
//  iOS Simulator Notifications
//
//  Created by Arnaud Coomans on 22/02/14.
//  Copyright (c) 2014 acoomans. All rights reserved.
//

#import "ACAppDelegate.h"

#import "ACSimulatorRemoteNotificationsService.h"


static NSString * const ACAppDelegatePayloadUserDefaultsKey = @"ACAppDelegatePayloadUserDefaultsKey";

@implementation ACAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSDictionary *payload = [[NSUserDefaults standardUserDefaults] objectForKey:ACAppDelegatePayloadUserDefaultsKey];
    
    if (![payload isKindOfClass:NSDictionary.class]) {
        [self resetAction:self];
    } else {
        NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingPrettyPrinted error:nil];
        if (data) {
            self.payloadTextView.string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
}

#pragma mark - Actions

- (IBAction)resetAction:(id)sender {
    
    NSDictionary *dict = @{
                           @"aps" : @{
                                   @"alert" : @"Message",
                                   @"badge" : @0,
                                   @"content-available" : @1,
                                   @"sound" : @"default"
                                   },
                           @"mh"  : @{
                                   @"created_at" : @"2016-04-29T20:32:34.250-05:500",
                                   @"menu_icon"  : @"<null>",
                                   @"parameters" : @{
                                           @"url" : @"https://www.google.com"
                                           },
                                   @"type" : @"internal_link"
                                   }
                           };
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    self.payloadTextView.string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (IBAction)sendAction:(id)sender {
    
    self.errorTextField.hidden = YES;
    
    NSError *error;
    
    NSData *data = [self.payloadTextView.string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (!payload) {
        self.errorTextField.stringValue = [NSString stringWithFormat:@"Invalid JSON: %@", error.localizedFailureReason];
        self.errorTextField.hidden = NO;
        return;
    }
    
    if (![payload isKindOfClass:NSDictionary.class]) {
        self.errorTextField.stringValue = @"Invalid JSON: Not a dictionary";
        self.errorTextField.hidden = NO;
        return;
    }
    
    // reformat payload
    data = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingPrettyPrinted error:&error];
    self.payloadTextView.string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [[ACSimulatorRemoteNotificationsService sharedService] send:payload];
    
    [[NSUserDefaults standardUserDefaults] setObject:payload forKey:ACAppDelegatePayloadUserDefaultsKey];
}

@end
