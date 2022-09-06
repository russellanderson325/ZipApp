# Zip Gameday App 🚗

uber. but for golf carts.
#### Resources

[Flutter UI Builder](https://www.dhiwise.com/flutter)

# Installation
---

Change directory into the `zip-master3`

#### Software Requirements
- [Install Flutter](https://docs.flutter.dev/get-started/install)
- [Cocoa Pods Installation](https://guides.cocoapods.org/using/getting-started.html#installation)

#### Setup IOS Simulator

*Mac Instructions*

In order to setup the iOS simulator first we have to install Xcode onto our computer, which can both be downloaded online or in the app store. After that we can configure the Xcode command-line tools to use our newly installed version with the following command typed into our console.

`sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`

We can then open up the iOS simulator with the following command.

`open -a Simulator`

![simulator image](https://miro.medium.com/max/320/1*Q34htDxYW43DeC6d6W7mNg.gif)

#### Create stable Flutter channel

```
// set flutter to stable channel
flutter channel stable

// check flutter channel
flutter channel

// output
Flutter channels:
  master
  dev
  beta
* stable
```

#### Flutter Version Management (FVM)
---
Ensure Flutter Version Management (FVM) is installed

`flutter pub global activate fvm`

`dart pub global activate fvm`
#### Add FVM to Path

The installation above will give you a suggestion to add the flutter config file to your path. The message will look something like this:

```
Warning: Pub installs executables into /opt/homebrew/Caskroom/flutter/3.0.5/flutter/.pub-cache/bin, which is not on your path.
You can fix that by adding this to your shell's config file (.bashrc, .bash_profile, etc.):

  export PATH="$PATH":"/opt/homebrew/Caskroom/flutter/3.0.5/flutter/.pub-cache/bin"
```

#### Install Flutter Version 1.22.5
`fvm install 1.22.5`

#### Set Flutter Version to 1.22.5

`fvm use 1.22.5`

#### Run IOS Simulator
*On MacOS*

`open -a Simulator`

#### Install Packages with CocoaPod
In the `zip-master3/ios` directory run. This can take a long time.

`pod install --verbose`
#### Run Flutter Install

In `zip-master3` directory

`fvm flutter run`

*The output should be similar to this*

```
Launching lib/main.dart on iPhone 8 in debug mode...
Running Xcode build...                                          
Xcode build done.                                           14.1s
Waiting for iPhone 8 to report its views...                          6ms
Syncing files to device iPhone 8...                                309ms

Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h Repeat this help message.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
An Observatory debugger and profiler on iPhone 8 is available at: http://127.0.0.1:50900/E25X8NkTw1I=/
```