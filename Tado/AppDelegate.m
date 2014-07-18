//
//  AppDelegate.m
//  Tado
//
//  Created by Robert Dougan on 17/07/14.
//  Copyright (c) 2014 Robert Dougan. All rights reserved.
//

#import "AppDelegate.h"

#import <SSKeychain/SSKeychain.h>

@interface AppDelegate () <NSTextFieldDelegate>

@property (nonatomic, weak) IBOutlet NSTextField *usernameField;
@property (nonatomic, weak) IBOutlet NSSecureTextField *passwordField;
@property (nonatomic, weak) IBOutlet NSButton *loginButton;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.highlightMode = NO;
    
    // Check if the user has logged in
    if (![self loginDetails]) {
        [self.loginWindow makeKeyAndOrderFront:self];
        return;
    }
    
    [self startFetching];
}

- (NSDictionary *)loginDetails
{
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    if (!username) {
        return nil;
    }
    
    NSString *password = [SSKeychain passwordForService:@"Tado" account:username];
    if (!password) {
        return nil;
    }
        
    return @{
             @"username": username,
             @"password": password
             };
}

- (void)startFetching
{
    [self fetchTemperatue];
    
    [NSTimer scheduledTimerWithTimeInterval:60.0f * 5.0f
                                     target:self
                                   selector:@selector(fetchTemperatue)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)fetchTemperatue
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSDictionary *loginDetails = [self loginDetails];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://my.tado.com/mobile/1.3/getCurrentState?username=%@&password=%@", [loginDetails valueForKey:@"username"], [loginDetails valueForKey:@"password"]]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:10];
        
        NSError *requestError;
        NSURLResponse *urlResponse = nil;
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
        
        if (requestError) {
            return;
        }
        
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        
        if (error) {
            return;
        }
        
        NSString *temperature = [NSString stringWithFormat:@"%.1f°", [[json valueForKey:@"insideTemp"] floatValue]];
        self.statusItem.title = temperature;
    });
}

- (IBAction)login:(id)sender
{
    NSString *username = self.usernameField.stringValue;
    NSString *password = self.passwordField.stringValue;
    
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
    [SSKeychain setPassword:password forService:@"Tado" account:username];
    
    [self.loginWindow close];
    self.loginWindow = nil;
    
    [self startFetching];
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)notification
{
    NSString *username = self.usernameField.stringValue;
    NSString *password = self.passwordField.stringValue;
    
    BOOL disabled = !username || !password || [username isEqualToString:@""] || [password isEqualToString:@""];
    [self.loginButton setEnabled:!disabled];
}

@end
