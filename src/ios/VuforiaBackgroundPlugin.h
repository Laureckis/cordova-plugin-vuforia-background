#import <Cordova/CDV.h>
#import "ViewController.h"
#import <Cordova/CDVCommandDelegate.h>

@interface VuforiaBackgroundPlugin : CDVPlugin

- (void) launchVuforia:(CDVInvokedUrlCommand *)command;
- (void) cordovaStopVuforia:(CDVInvokedUrlCommand *)command;
- (void) cordovaStopTrackers:(CDVInvokedUrlCommand *)command;
- (void) cordovaStartTrackers:(CDVInvokedUrlCommand *)command;
- (void) cordovaUpdateTargets:(CDVInvokedUrlCommand *)command;
- (void) pauseAR:(CDVInvokedUrlCommand *)command;
- (void) resumeAR:(CDVInvokedUrlCommand *)command;
- (void) prepareVuforiaMarkerEvent:(CDVInvokedUrlCommand *)command;

+ (void) triggerReadyEvent;

+ (ViewController*) imageRecViewController;
+ (void) setImageRecViewController:(ViewController*)viewCtrl;
+ (CDVInvokedUrlCommand*) markerCommand;
+ (void) setMarkerCommand:(CDVInvokedUrlCommand*)markerCommand;
+ (id) markerCommandDelegate;
+ (void) setMarkerCommandDelegate:(id)markerCommandDelegate;
+ (id) readyCommandDelegate;
+ (void) setReadyCommandDelegate:(id)readyCommandDelegate;
+ (CDVInvokedUrlCommand*) readyCommand;
+ (void) setReadyCommand:(CDVInvokedUrlCommand*)readyCommand;


@end
