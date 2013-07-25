//
//  ViewController.m
//  OAuth1Sample-iOS
//
//  Created by Michael Katz on 12/10/12.
//
//  Copyright 2013 Kinvey, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ViewController.h"

#import "GTMOAuthAuthentication.h"
#import "GTMOAuthViewControllerTouch.h"
#import "GTMOAuthSignIn.h"

#import <KinveyKit/KinveyKit.h>

static NSString *const kLinkedInKeychainItemName = @"OAuth Sample: LinkedIn";

@interface ViewController ()
@property BOOL loggedIn;
@property (nonatomic, copy) NSArray* connections;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.connections = @[];
}

- (void) viewDidAppear:(BOOL)animated
{
    if (!_loggedIn) {
        [self signInToLinkedIn];
    }
}



#pragma mark - Getting Data


- (void) fetchNetwork:(GTMOAuthAuthentication *)auth
{
    //Query the 'FetchConnections' data integration collection
    KCSCollection* linkedInDLCollection = [KCSCollection collectionFromString:@"FetchConnections" ofClass:[NSDictionary class]];
    KCSAppdataStore* linkedInStore = [KCSAppdataStore storeWithCollection:linkedInDLCollection options:nil];
    
    //Send the auth token info over to Kinvey using query parameters
    KCSQuery* authQuery = [KCSQuery queryOnField:@"accesstoken" withExactMatchForValue:auth.token];
    [authQuery addQueryOnField:@"accesstokensecret" withExactMatchForValue:auth.tokenSecret];
    
    [linkedInStore queryWithQuery:authQuery withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
        if (objectsOrNil) {
            // success
            self.connections = objectsOrNil;
            [self.tableView reloadData];
        } else {
            // error
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failed To Fetch Connections"
                                                            message:[errorOrNil localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    } withProgressBlock:nil];
}


#pragma mark - OAuth

- (GTMOAuthAuthentication *)authForLinkedIn {
    // Note: to use this sample, you need to fill in a valid api key and
    // secret key provided by LinkedIn
    //
    // https://www.linkedin.com/secure/developer
    //
    
    NSString *apiKey = @"<#API Key#>";
    NSString *secretKey = @"<#Secret Key#>";
    
    GTMOAuthAuthentication *auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                                               consumerKey:apiKey
                                                                                privateKey:secretKey];
    
    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    [auth setServiceProvider:@"LinkedIn"];
    
    return auth;
}

- (void)signInToLinkedIn
{
    NSURL *requestURL = [NSURL URLWithString:@"https://api.linkedin.com/uas/oauth/requestToken"];
    NSURL *accessURL = [NSURL URLWithString:@"https://api.linkedin.com/uas/oauth/accessToken"];
    NSURL *authorizeURL = [NSURL URLWithString:@"https://api.linkedin.com/uas/oauth/authorize"];
    NSString *scope = @"r_network";
    
    GTMOAuthAuthentication *auth = [self authForLinkedIn];
    if (auth == nil) {
        // perhaps display something friendlier in the UI?
        NSAssert(NO, @"A valid consumer key and consumer secret are required for signing in to LinkedIn");
    }
    
    // set the callback URL to which the site should redirect, and for which
    // the OAuth controller should look to determine when sign-in has
    // finished or been canceled
    //
    // This URL does not need to be for an actual web page; it will not be
    // loaded
    [auth setCallback:@"http://kinvey-tutorials.com/accept"];
    
    NSString *keychainItemName = kLinkedInKeychainItemName;
    
    // Display the authentication view.
    GTMOAuthViewControllerTouch *viewController;
    viewController = [[GTMOAuthViewControllerTouch alloc] initWithScope:scope
                                                               language:nil
                                                        requestTokenURL:requestURL
                                                      authorizeTokenURL:authorizeURL
                                                         accessTokenURL:accessURL
                                                         authentication:auth
                                                         appServiceName:keychainItemName
                                                               delegate:self
                                                       finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    // You can set the title of the navigationItem of the controller here, if you want.
    
    [[self navigationController] pushViewController:viewController animated:YES];
}


- (void)viewController:(GTMOAuthViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuthAuthentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        NSLog(@"Authentication error: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:@"data"];
        if ([responseData length] > 0) {
            // show the body of the server's authentication failure response
            NSString *str = [[NSString alloc] initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
            NSLog(@"%@", str);
        }
    } else {
        // Authentication succeeded
        _loggedIn = YES;
        [self fetchNetwork:auth];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.connections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseId = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    
    NSDictionary* person = [self.connections objectAtIndex:indexPath.row];
    NSString* fname = [person objectForKey:@"first-name"];
    cell.textLabel.text = (fname != nil) ? fname : @"";
    
    
    
    return cell;
}
@end
