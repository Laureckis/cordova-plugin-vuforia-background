# Cordova Vuforia Background Plugin
Cordova-Plugin-Vuforia-Background is a [Cordova][cordova] plugin that uses [Vuforia][vuforia] to perform image recognition. 
The plugin puts the Vuforia camera view below the Cordova WebView. Settings your HTML
elements transparent will allow you to use HTML UI on your Vuforia app.

The plugin is based on the [Cordova-Plugin-Vuforia][cordova-plugin-vuforia] by [Matt Rayner][matt-rayner].

Example app is available a [Cordova-Plguin-Vuforia-Background-Example repo][example-repo-link].


### Contents
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Supported Platforms](#supported-platforms)
- [Requirements](#requirements)
  - [Dependencies](#dependencies)
- [Getting Started](#getting-started)
  - [Plugin Installation](#plugin-installation)
  - [JavaScript](#javascript)
    - [`launchVuforia` - Start your Vuforia session](#startvuforia---start-your-vuforia-session)
      - [`options` object](#options-object)
        - [Examples](#examples)
      - [Success callback `data` API](#success-callback-data-api)
    - [`stopVuforia` - Stop your Vuforia session](#stopvuforia---stop-your-vuforia-session)
    - [`stopVuforiaTrackers` - Stop Vuforia image trackers](#stopvuforiatrackers---stop-vuforia-image-trackers)
    - [`startVuforiaTrackers` - Start Vuforia image trackers](#startvuforiatrackers---start-vuforia-image-trackers)
    - [`updateVuforiaTargets` - Update the list of targets Vuforia is searching for](#updatevuforiatargets---update-the-list-of-targets-vuforia-is-searching-for)
    - [`pauseAR` - Pause AR](#pausear---pauses-the-ar-tracking-and-freezes-the-camera)
    - [`resumeAR` - Resume AR](#resumear---resumes-ar-tracking-and-unfreezes-the-camera)
  - [Using your own data](#using-your-own-data)
    - [`www/targets/`](#wwwtargets)
    - [JavaScript](#javascript-1)
      - [`launchVuforia(...)`](#launchVuforia)
    - [`config.xml`](#configxml)
- [Contributing](#contributing)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Supported Platforms
Android (Minimum 4) (iOS coming soon)


## Requirements
> **NOTE:** You will require an Android or iOS device for development and testing. Cordova-Plugin-Vuforia-Background-Background requires hardware and software support that is not present in either the iOS or Android simulators.

Cordova-Plugin-Background-Vuforia requires the following:
* [npm][npm]
* [Cordova 6.*][cordova] - 6.* is required as of v2.1 of this plugin, it adds support for Android 6 (Marshmellow) and iOS 9.
  * If you haven't yet installed the Cordova CLI, grab the latest version by following [these steps][install-cordova].
  * If you've already got a project running with an older version of Cordova, [see here][updating-cordova] for instructions on how to update your project's Cordova version.
  * Or if you want to upgrade to the latest version on a platform-by-platform basis, see either [upgrading to cordova-ios 4][upgrading-ios] or [upgrading to cordova-android 5][upgrading-android].

### Dependencies
At present there is one major dependency for Cordova-Plugin-Vuforia-Background:
* [Cordova-Plugin-Vuforia-Background-SDK][cordova-plugin-vuforia-sdk] - This plugin is used to inject the Vuforia SDK into our Cordova applications


## Getting Started
### Plugin Installation
```bash
cordova plugin add https://github.com/Laureckis/cordova-plugin-vuforia-background
```

### JavaScript
Cordova-Plugin-Vuforia-Background-Background comes with the following JavaScript methods:

Method | Description
--- | ---
[`launchVuforia`][start-vuforia-doc-link] | **Launch a Vuforia activity with a Cordova WebView overlay** - Launch the camera and begin searching for images to recognise. Used `vuforia_index.html` to overlay the camera view.
[`stopVuforia`][stop-vuforia-doc-link] | **Stop a Vuforia session** - Close the camera and return back to Cordova.
[`stopVuforiaTrackers`][stop-vuforia-trackers-doc-link] | **Stop the Vuforia tracking system** - Leave the Vuforia camera running, just stop searching for images.
[`startVuforiaTrackers`][start-vuforia-trackers-doc-link] | **Start the Vuforia tracking system** - Leave the Vuforia camera running and start searching for images again.
[`updateVuforiaTargets`][update-vuforia-targets-doc-link] | **Update Vuforia target list** - Update the list of images we are searching for, but leave the camera and Vuforia running.
[`pauseAR`][pause-ar-doc-link] | **Pauses AR tracking and freezes the camera.** - Useful for when you do not need Vuforia in all sections of the app.
[`resumeAR`][resume-ar-doc-link] | **Resumes AR tracking and unfreezes the camera.** - Useful for when you do not need Vuforia in all sections of the app.

#### `launchVuforia` - Start your Vuforia session
From within your JavaScript file, add the following to launch the [Vuforia][vuforia] session with Cordova WebView overlay.

```javascript
var options = {
  databaseXmlFile: 'PluginTest.xml',
  targetList: [ 'logo', 'iceland', 'canterbury-grass', 'brick-lane' ],
  vuforiaLicense: 'YOUR_VUFORIA_KEY'
};

navigator.VuforiaBackgroundPlugin.launchVuforia(
  options,
  function(data) {
    // To see exactly what `data` can return, see 'Success callback `data` API' within the plugin's documentation.
    console.log(data);
    
    if (data.status.manuallyClosed) {
      alert("User manually closed Vuforia by pressing back!");
      // if you start Vuforia on app launch, this is where you should exit the app
    }
  },
  function(data) {
    alert("Error: " + data);
  }
);
```

From antother JavaScript file, that is loaded by `vuforia_index.html`:
```javascript
document.addEventListener('vuforiaready', function(){
    // code to execute when vuforia is loaded
}, false);

document.addEventListener('vuforiamarker', function(event){
    // code to execute when a marker is detected
    console.log('Marker detected: ', event.detail.result.name, event.detail);

    // tracking will be paused now, call navigator.VuforiaBackgroundPlugin.startVuforiaTrackers() to resume when needed, else this event will be triggered each frame the marker is in view
}, false);
```

> **NOTES:**
> * You will need to replace `YOUR_VUFORIA_KEY` with a valid license key for the plugin to launch correctly.
> * For testing you can use the `targets/PluginTest_Targets.pdf` file inside the plugin folder; it contains all four testing targets.
> * The "vuforiamarker" event triggers when a marker is detected. Once it triggers, detection stops. You need to enabled it again by calling `navigator.VuforiaBackgroundPlugin.startVuforiaTrackers()` to receive more events.

##### `options` object
The options object has a number of properties, some of which are required, and some which are not. Below if a full reference and some example options objects

Option | Required | Default Value | Description
--- | --- | --- | ---
`databaseXmlFile` | `true` | `null` | The Vuforia database file (.xml) with our target data inside.
`targetList` | `true` | `null` | An array of images we are going to search for within our database. For example you may have a database of 100 images, but only be interested in 5 right now.
`vuforiaLicense` | `true` | `null` | Your application's Vuforia license key.

###### Examples
**Minumum required**
```javascript
var options = {
  databaseXmlFile: 'PluginTest.xml',
  targetList: [ 'logo', 'iceland', 'canterbury-grass', 'brick-lane' ],
  vuforiaLicense: 'YOUR_VUFORIA_KEY'
};
```

##### Success callback `data` API
`launchVuforia` takes two callbacks - one for `success` and one for `faliure`. When `success` is called, a `data` object is passed to Cordova. This will be in one of the following formats:

**Manually Closed** - when a user has exited Vuforia via pressing the close/back button, `data` returns: 

```json
{
  "status": {
    "manuallyClosed": true,
    "message": "User manually closed the plugin."
  }
}
```

#### `stopVuforia` - Stop your Vuforia session
From within your JavaScript file, add the following to stop the [Vuforia][vuforia] session. `stopVuforia` takes two callbacks - one for `success` and one for `faliure`.

**Why?** - Well, you could pair this with a setTimeout to give users a certain amount of time to search for an image.

```javascript
navigator.VuforiaBackgroundPlugin.stopVuforia(
  function (data) {
    console.log(data);

    if (data.success == 'true') {
        alert('Stopped Vuforia');
    } else {
        alert('Couldn\'t stop Vuforia\n'+data.message);
    }
  },
  function (data) {
    console.log("Error: " + data);
  }
);
```

This script could be paired with a timer, or other method to trigger the session close.

> **NOTE:** You do not need to call `stopVuforia()` other than to force the session to end. If the user scans an image, or chooses to close the session themselves, the session will be automatically closed.


#### `stopVuforiaTrackers` - Stop Vuforia image trackers
From within your JavaScript file, add the following to stop the [Vuforia][vuforia] image trackers (but leave the camera running). `stopVuforiaTrackers` takes two callbacks - one for `success` and one for `faliure`.

**Why?** - Well, you may want to play a sound after an image rec, or have some kind of delay between recognitions.

```javascript
navigator.VuforiaBackgroundPlugin.stopVuforiaTrackers(
  function (data) {
    console.log(data);
    
    alert('Stopped Vuforia Trackers');
  },
  function (data) {
    console.log("Error: " + data);
  }
);
```


#### `startVuforiaTrackers` - Start Vuforia image trackers
From within your JavaScript file, add the following to start the [Vuforia][vuforia] image trackers. This method only makes sense when called after `stopVuforiaTrackers`. `startVuforiaTrackers` takes two callbacks - one for `success` and one for `faliure`.

**Why?** - Well, you may want to play a sound after an image rec, or have some kind of delay between recognitions.

```javascript
navigator.VuforiaBackgroundPlugin.startVuforiaTrackers(
  function (data) {
    console.log(data);
    
    alert('Started Vuforia Trackers');
  },
  function (data) {
    console.log("Error: " + data);
  }
);
```


#### `updateVuforiaTargets` - Update the list of targets Vuforia is searching for
From within your JavaScript file, add the following to update the list of images [Vuforia][vuforia] is searching for. `updateVuforiaTargets` takes three options, an array of images you want to scan for, a callback for `success` and a callback for `faliure`.

**Why?** - Well, you may want to change the images you are searching for after launching Vuforia. For example, consider a scenario where a game requires users to scan images one after another in a certain order. For example, a museum app may want you to scan all of the Rembrandt paintings in a room from oldest to newest to unlock some content. This method can offload the burdon of decision from your app to Vuforia, instead of writing login in your JavaScript, we're letting Vuforia take care of it.

```javascript
navigator.VuforiaBackgroundPlugin.updateVuforiaTargets(
    ['iceland', 'canterbury-grass'], // Only return a success if the 'iceland' or 'canterbury-grass' images are found.
    function(data){
        console.log(data);
        
        alert('Updated trackers');
    },
    function(data) {
        alert("Error: " + data);
    }
);
```

#### `pauseAR` - Pauses the AR tracking and freezes the camera.

**Why?** - You may want to not use the camera for all sections of your app.

```javascript
navigator.VuforiaBackgroundPlugin.pauseAR(
    function(data){
        console.log(data);
        
        alert('AR Paused');
    },
    function(data) {
        alert("Error: " + data);
    }
);
```

#### `resumeAR` - Resumes AR tracking and unfreezes the camera.

**Why?** - You may want to not use the camera for all sections of your app.

```javascript
navigator.VuforiaBackgroundPlugin.resumeAR(
    function(data){
        console.log(data);
        
        alert('AR Paused');
    },
    function(data) {
        alert("Error: " + data);
    }
);
```


### Using your own data
We know that eventually you're going to want to use your own data. To do so, follow these extra steps.

#### `www/targets/`
First, create a `targets/` folder inside `www/` and place your own `.xml` and `.dat` files inside.

> **NOTE:** Adding a `.pdf` file isn't required, but might be helpful for testing and development purposes.

#### JavaScript
##### `launchVuforia(...)`
There are two pieces you will need to replace:

1. `PluginTest.xml` - Replace with a reference to your custom data file e.g. `www/targets/CustomData.xml`
1. `[ 'logo', 'iceland', 'canterbury-grass', 'brick-lane' ]` - Replace with the specific images for your data file that you are searching for.

> **NOTES:**
> * You don't have to search for all of the images in your data file each time. Your data file may contain 20 images, but for this particular action you may be only interested in two.
> * Data file paths can be either from the **resources folder** (which is the default) or **absolute** (in which case you'd start the `src` with `file://`). Absolute paths are useful if you'd like to access files in specific folders, like the iTunes sharing document folder for iOS, or the app root folder for Android.


#### `config.xml`
Add the following to your `config.xml` file:

```xml
<platform name="android">
    <resource-file src="www/targets/CustomData.xml" target="assets/CustomData.xml" />
    <resource-file src="www/targets/CustomData.dat" target="assets/CustomData.dat" />
</platform>

<platform name="ios">
    <resource-file src="targets/CustomData.xml" />
    <resource-file src="targets/CustomData.dat" />
</platform>
```


## Contributing
If you wish to submit a bug fix or feature, you can create a pull request and it will be merged pending a code review.

1. Clone it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request


## License
Cordova-Plugin-Vuforia-Background is licensed under the [MIT License][info-license].

[logo]: https://cdn.rawgit.com/mattrayner/cordova-plugin-vuforia/d14d00720569fea02d29cded4de3c6e617c87537/images/logo.svg

[cordova]: https://cordova.apache.org/
[vuforia]: https://www.vuforia.com/
[example-repo]: https://github.com/dsgriffin/cordova-vuforia-example
[npm]: https://www.npmjs.com
[install-cordova]: https://cordova.apache.org/docs/en/latest/guide/cli/index.html#installing-the-cordova-cli
[updating-cordova]: https://cordova.apache.org/docs/en/latest/guide/cli/index.html#updating-cordova-and-your-project
[upgrading-ios]: https://cordova.apache.org/docs/en/latest/guide/platforms/ios/upgrade.html#upgrading-360-projects-to-400
[upgrading-android]: https://cordova.apache.org/docs/en/latest/guide/platforms/android/upgrade.html#upgrading-to-5xx
[cordova-plugin-vuforia-sdk]: https://github.com/mattrayner/cordova-plugin-vuforia-sdk
[issue-16]: https://github.com/mattrayner/cordova-plugin-vuforia/issues/16
[cordova-orientation-issue]: https://github.com/apache/cordova-lib/pull/260
[cordova-plugin-vuforia]: https://github.com/mattrayner/cordova-plugin-vuforia
[matt-rayner]: https://github.com/mattrayner
[example-repo-linl]: github.com:Laureckis/cordova-plugin-vuforia-background-example

[info-license]: LICENSE

[start-vuforia-doc-link]: #startvuforia---start-your-vuforia-session
[stop-vuforia-doc-link]: #stopvuforia---stop-your-vuforia-session
[stop-vuforia-trackers-doc-link]: #stopvuforiatrackers---stop-vuforia-image-trackers
[start-vuforia-trackers-doc-link]: #startvuforiatrackers---start-vuforia-image-trackers
[update-vuforia-targets-doc-link]: #updatevuforiatargets---update-the-list-of-targets-vuforia-is-searching-for
[pause-ar-doc-link]: #pausear---pauses-the-ar-tracking-and-freezes-the-camera
[resume-ar-doc-link]: #resumear---resumes-ar-tracking-and-unfreezes-the-camera
