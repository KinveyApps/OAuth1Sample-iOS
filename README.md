OAuth1Sample-iOS
================

Sample App Showing Off Kinvey Data Integration, using LinkedIn with OAuth 1a. This sample uses gtm-oauth to obtain an access token for connecting to LinkedIn, and Kinvey's Data Integration feature to load the user's connections. 

![Screen Shot 1](https://github.com/KinveyApps/OAuth1Sample-iOS/raw/master/images/OAuth1Example_screen1.png)
![Screen Shot 2](https://github.com/KinveyApps/OAuth1Sample-iOS/raw/master/images/OAuth1Example_screen2.png)

### KinveyKit
This sample application requires a minimum of iOS 5.0 and KinveyKit 1.12.0. To use the sample app, go to [Kinvey](http://console.kinvey.com) and create a new App. You'll need the App id and App secret to set in `AppDelegate.m` in order to run this sample. 

### OAuth2
This project uses Google's [gtm-oauth1](http://code.google.com/p/gtm-oauth1/) library to obtain an access token from LinkedIn. It's your responsibility to log in to [LinkedIn's API](https://www.linkedin.com/secure/developer), create an application with them and obtain the client id and secret. 

### Data Integration
There is a custom ql.io collection used by this sample app
* `FetchConnections` : Fetches the user's 1st degree network from LinkedIn

This repo contains `linkedin-get-connections_qlio_script.txt` which provides the ql.io script to use if you create the collection on your app backend. 

## Follow the Tutorial
This sample corresponds to [this tutorial](http://devcenter.kinvey.com/ios/tutorials/ios-oauth1-tutorial) on Kinvey's Devcenter. This goes through the step-by-step instructions for setting up the backend. 

## Support
Website: www.kinvey.com

Support: support@kinvey.com