//
//  LoginViewController.m
//  PKProject
//
//  Created by Jordan on 11/5/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "SignUpViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ServerHandler.h"
#import "CoreDataHandler.h"
#import "User+Extended.h"
#import "AppDelegate.h"

@interface SignUpViewController ()

@property (nonatomic, weak) CoreDataHandler *coreDataHandler;
@property (strong, nonatomic) IBOutlet UIButton *continueLabel;


@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.coreDataHandler = [CoreDataHandler sharedCoreDataHandler];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(defaultsChanged:)
                   name:NSUserDefaultsDidChangeNotification
                 object:nil];
    
    [self setContinueButtonText];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Connections

- (IBAction)emailLogin:(id)sender {
    [self loginPopup];
}

- (IBAction)facebookLogin:(id)sender {
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
         }];
    }
}

#pragma mark - NSUserDefaults Change Notification
- (void)defaultsChanged:(NSNotification *)notification {
    // change button text based on loggedIn status
    [self setContinueButtonText];
}

-(void)setContinueButtonText {
    BOOL loggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedIn"];
    if (loggedIn) {
        [self.continueLabel setTitle:@"Continue >" forState:UIControlStateNormal];
    } else {
        [self.continueLabel setTitle:@"Continue without signing in >" forState:UIControlStateNormal];
    }
}

#pragma mark - Login
-(void)loginPopup {
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login"
                                                    message:@"Typos are the enemy."
                                                   delegate:self
                                          cancelButtonTitle:@"I'm New"
                                          otherButtonTitles:@"Login!",nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
     */
    // TODO: implement non-FB sign up and login
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Login"
                                                    message:@"This feature coming soon."
                                                   delegate:self
                                          cancelButtonTitle:@"Okay!"
                                          otherButtonTitles:nil];
    
    [alert show];
}

/*
-(void)loginTypoPopup {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed"
                                                    message:@"Typos are the enemy."
                                                   delegate:self
                                          cancelButtonTitle:@"I'm new"
                                          otherButtonTitles:@"Try again!",nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert show];
}

-(BOOL)verifyLoginCredentials:(NSString*)username password:(NSString*)password {
    if (username.length && password.length) {
        // TODO: verify for real
        // TODO: update loggedIn
        // TODO: prob update some setting in NSUserDefaults
        
        NSLog(@"N: %@    P: %@",username,password);
        return YES;
    } else {
        return NO;
    }
}
 */

#pragma mark - Alert Delegates
/*
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"alert dismissed with button %i", (int)buttonIndex);
    if ((int)buttonIndex == 1) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        NSString *pword = [alertView textFieldAtIndex:1].text;
        BOOL validLogin = [self verifyLoginCredentials:name password:pword];
        
        if (!validLogin) {
            [self loginTypoPopup];
        }
    }
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
