#import "VuforiaBackgroundPlugin.h"
#import "ViewController.h"

@interface VuforiaBackgroundPlugin()

@property CDVInvokedUrlCommand *command;
//@property ViewController *imageRecViewController;
@property BOOL startedVuforia;
@property BOOL autostopOnImageFound;
@property CDVInvokedUrlCommand *vuforiaReadyCommand;

@end

@implementation VuforiaBackgroundPlugin

static ViewController *imgViewCtrl = nil;
+ (ViewController *)imageRecViewController {
    return imgViewCtrl;
}
+ (void) setImageRecViewController:(ViewController*)viewCtrl {
    imgViewCtrl = viewCtrl;
}

static CDVInvokedUrlCommand *_markerCommand = nil;
+ (CDVInvokedUrlCommand *)markerCommand {
    return _markerCommand;
}
+ (void) setMarkerCommand:(CDVInvokedUrlCommand *)markerCommand{
    _markerCommand = markerCommand;
}


static CDVInvokedUrlCommand *_readyCommand = nil;
+ (CDVInvokedUrlCommand *)readyCommand {
    return _readyCommand;
}
+ (void) setReadyCommand:(CDVInvokedUrlCommand *)readyCommand{
    _readyCommand = readyCommand;
}

static id _markerCommandDelegate = nil;
+ (id) markerCommandDelegate {
    return _markerCommandDelegate;
}
+ (void) setMarkerCommandDelegate:(id)markerCommandDelegate {
    _markerCommandDelegate = markerCommandDelegate;
}

static id _readyCommandDelegate = nil;
+ (id) readyCommandDelegate {
    return _readyCommandDelegate;
}
+ (void) setReadyCommandDelegate:(id)readyCommandDelegate {
    _readyCommandDelegate = readyCommandDelegate;
}

- (void) prepareVuforiaMarkerEvent:(CDVInvokedUrlCommand *)command {
    VuforiaBackgroundPlugin.markerCommandDelegate = self.commandDelegate;
    VuforiaBackgroundPlugin.markerCommand = command;
}

- (void) prepareVuforiaReadyEvent:(CDVInvokedUrlCommand *)command {
    VuforiaBackgroundPlugin.readyCommandDelegate = self.commandDelegate;
    VuforiaBackgroundPlugin.readyCommand = command;
}

+ (void) triggerReadyEvent {
    NSLog(@"Trigger ready event!");
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: nil];
    [VuforiaBackgroundPlugin.readyCommandDelegate sendPluginResult:pluginResult callbackId:VuforiaBackgroundPlugin.readyCommand.callbackId];
}

- (void) launchVuforia:(CDVInvokedUrlCommand *)command {
    
    NSLog(@"Vuforia Plugin :: Start plugin");
    
    NSLog(@"Arguments: %@", command.arguments);
    NSLog(@"KEY: %@", [command.arguments objectAtIndex:2]);
    
    NSString *overlayText = @"";

    NSDictionary *overlayOptions =  [[NSDictionary alloc] initWithObjectsAndKeys: overlayText, @"overlayText", NO, @"showDevicesIcon", nil];
    
    self.autostopOnImageFound = NO;
    
    [self startVuforiaWithImageTargetFile:[command.arguments objectAtIndex:0] imageTargetNames: [command.arguments objectAtIndex:1] overlayOptions: overlayOptions vuforiaLicenseKey: [command.arguments objectAtIndex:2]];
    self.command = command;
    
    self.startedVuforia = true;
}

- (void) cordovaStopVuforia:(CDVInvokedUrlCommand *)command {
    self.command = command;
    
    NSDictionary *jsonObj = [NSDictionary alloc];
    
    if(self.startedVuforia == true){
        NSLog(@"Vuforia Plugin :: Stopping plugin");
        
        jsonObj = [ [NSDictionary alloc] initWithObjectsAndKeys :
                   @"true", @"success",
                   nil
                   ];
    }else{
        NSLog(@"Vuforia Plugin :: Cannot stop the plugin because it wasn't started");
        
        jsonObj = [ [NSDictionary alloc] initWithObjectsAndKeys :
                   @"false", @"success",
                   @"No Vuforia session running", @"message",
                   nil
                   ];
    }
    
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
    
    [self VP_closeView];
}

//Added custom Pause for background plugin
- (void) pauseAR:(CDVInvokedUrlCommand *)command {
    self.command = command;
    NSDictionary *jsonObj = [NSDictionary alloc];
    
    [VuforiaBackgroundPlugin.imageRecViewController pauseAR];
        
    jsonObj = [ [NSDictionary alloc] initWithObjectsAndKeys :
                   @"true", @"success",
                   @"Paused Vuforia", @"message",
                   nil
                   ];
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}

//Added custom Resume for background plugin
- (void) resumeAR:(CDVInvokedUrlCommand *)command {
    self.command = command;
    NSDictionary *jsonObj = [NSDictionary alloc];
    
    [VuforiaBackgroundPlugin.imageRecViewController resumeAR];

    jsonObj = [ [NSDictionary alloc] initWithObjectsAndKeys :
                   @"true", @"success",
                   @"Vuforia running again", @"message",
                   nil
                   ];
    
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
}


- (void) cordovaStopTrackers:(CDVInvokedUrlCommand *)command{
    bool result = [VuforiaBackgroundPlugin.imageRecViewController stopTrackers];
    
    [self handleResultMessage:result command:command];
}

- (void) cordovaStartTrackers:(CDVInvokedUrlCommand *)command{
    bool result = [VuforiaBackgroundPlugin.imageRecViewController startTrackers];
    
    [self handleResultMessage:result command:command];
}

- (void) cordovaUpdateTargets:(CDVInvokedUrlCommand *)command{
    NSArray *targets = [command.arguments objectAtIndex:0];
    
    // We need to ensure our targets are flatened, if we pass an array of items it'll crash if we dont
    NSMutableArray *flattenedTargets = [[NSMutableArray alloc] init];
    for (int i = 0; i < targets.count ; i++)
    {
        if([[targets objectAtIndex:i] respondsToSelector:@selector(count)]) {
            [flattenedTargets addObjectsFromArray:[targets objectAtIndex:i]];
        } else {
            [flattenedTargets addObject:[targets objectAtIndex:i]];
        }
    }
    
    targets = [flattenedTargets copy];
    NSString * myString = [targets componentsJoinedByString:@""];
    NSLog(@"Updating targets: %@", myString);
    
    bool result = [VuforiaBackgroundPlugin.imageRecViewController updateTargets:targets];
    NSLog(@"Result... %d", result);
    [self handleResultMessage:result command:command];
}

#pragma mark - Util_Methods
- (void) startVuforiaWithImageTargetFile:(NSString *)imageTargetfile imageTargetNames:(NSArray *)imageTargetNames overlayOptions:(NSDictionary *)overlayOptions vuforiaLicenseKey:(NSString *)vuforiaLicenseKey {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ImageMatched" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageMatched:) name:@"ImageMatched" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CloseRequest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeRequest:) name:@"CloseRequest" object:nil];
    
    VuforiaBackgroundPlugin.imageRecViewController = [[ViewController alloc] initWithFileName:imageTargetfile targetNames:imageTargetNames overlayOptions:overlayOptions vuforiaLicenseKey:vuforiaLicenseKey];
    
    [self.viewController presentViewController:VuforiaBackgroundPlugin.imageRecViewController animated:YES completion:nil];
}


- (void)imageMatched:(NSNotification *)notification {
    
    NSDictionary* userInfo = notification.userInfo;
    
    NSLog(@"Vuforia Plugin :: image matched");
    NSDictionary* jsonObj = @{@"status": @{@"imageFound": @true, @"message": @"Image Found."}, @"result": @{@"imageName": userInfo[@"result"][@"imageName"]}};
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: jsonObj];
    
    [pluginResult setKeepCallbackAsBool:TRUE];
    [VuforiaBackgroundPlugin.markerCommandDelegate sendPluginResult:pluginResult callbackId:VuforiaBackgroundPlugin.markerCommand.callbackId];
}

- (void)closeRequest:(NSNotification *)notification {
    
    NSDictionary* jsonObj = @{@"status": @{@"manuallyClosed": @true, @"message": @"User manually closed the plugin."}};
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: jsonObj];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.command.callbackId];
    [self VP_closeView];
}

- (void) VP_closeView {
    if(self.startedVuforia == true){
        [VuforiaBackgroundPlugin.imageRecViewController close];
        VuforiaBackgroundPlugin.imageRecViewController = nil;
        self.startedVuforia = false;
    }
}

-(void) handleResultMessage:(bool)result command:(CDVInvokedUrlCommand *)command {
    if(result){
        [self sendSuccessMessage:command];
    } else {
        [self sendErrorMessage:command];
    }
}

-(void) sendSuccessMessage:(CDVInvokedUrlCommand *)command {
    NSDictionary *jsonObj = [ [NSDictionary alloc] initWithObjectsAndKeys :
                             @"true", @"success",
                             nil
                             ];
    
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void) sendErrorMessage:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_ERROR
                                     messageAsString: @"Did not successfully complete"
                                     ];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
