//
//  ProfileViewController.m
//  PKProject
//
//  Created by Jordan on 11/16/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@interface ProfileViewController ()

@property (strong, nonatomic) IBOutlet UIButton *FBLoginButton;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *profileNameLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(defaultsChanged:)
                   name:NSUserDefaultsDidChangeNotification
                 object:nil];
    
    [self setFBLoginButtonText];
    [self updateProfileName];
    [self updateProfilePicture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)setFBLoginButtonText {
    BOOL loggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedIn"];
    if (loggedIn) {
        [self.FBLoginButton setTitle:@"Facebook Logout" forState:UIControlStateNormal];
    } else {
        [self.FBLoginButton setTitle:@"Facebook Login" forState:UIControlStateNormal];
    }
}

-(void)updateProfilePicture {
    NSString *fbId = [[NSUserDefaults standardUserDefaults] objectForKey:@"thisUserFacebookId"];
    if (fbId) {
        self.profilePictureView.profileID = fbId;
    } else {
        self.profilePictureView.hidden = YES;
    }
}

-(void)updateProfileName {
    NSString *fbName = [[NSUserDefaults standardUserDefaults] objectForKey:@"thisUserFacebookName"];
    if (fbName) {
        self.profileNameLabel.text = fbName;
    } else {
        self.profileNameLabel.hidden = YES;
    }
}

#pragma mark - NSUserDefaults Change Notification
- (void)defaultsChanged:(NSNotification *)notification {
    // change button text based on loggedIn status
    [self setFBLoginButtonText];
    [self updateProfileName];
    [self updateProfilePicture];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end