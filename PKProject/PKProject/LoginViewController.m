//
//  LoginViewController.m
//  PKProject
//
//  Created by Jordan on 11/5/14.
//  Copyright (c) 2014 Byjor. All rights reserved.
//

#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController ()

@property (nonatomic) BOOL loggedIn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // check if user is logged in and set BOOL
    
    // FB login
//    FBLoginView *loginView = [[FBLoginView alloc] init];
//    loginView.center = self.view.center;
//    [self.view addSubview:loginView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // if loggedIn go to mapVC
    
    // else use login popup
//    [self loginPopup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Login
-(void)loginPopup {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login"
                                                    message:@"Typos are the enemy."
                                                   delegate:self
                                          cancelButtonTitle:@"I'm New"
                                          otherButtonTitles:@"Login!",nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert show];
}

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

#pragma mark - Alert Delegates
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
