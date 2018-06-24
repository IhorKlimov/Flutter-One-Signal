flutter_one_signal

### Current Features
Current features available:

* Sign up for push notifications
* Send a user tag
* Set email
* Get user id
* Handle notification receive/open events with notification as an input
### Android Setup
Just follow these steps, and ignore all the native instructions from both Firebase and One Signal, a big chunk of that boilerplate code is handled by this plugin

Create a One Signal, Firebase projects

Open android/app/src/main/AndroidManifest.xml and copy package value

Open Firebase console/Project Settings, add Android app and paste package copied before into Android package name

Click Register app in the next step download google-services.json and paste in in android/app

Now, add an Android app in One Signal using Server key and Sender ID from Firebase Project Settings/Cloud messaging

Next, add this code to android/app/src/build.gradle, replacing APP_ID with your One Signal App ID

```gradle
android {
   defaultConfig {
      ...
      manifestPlaceholders = [
          onesignal_app_id: 'APP_ID',
          onesignal_google_project_number: 'REMOTE'
      ]
    }
 }
```
### iOS Setup
Open ios directory in Xcode and copy Bundle identifier

Now open FIrebase console, add an iOS app for your project using that Bundle ID and download GoogleService-info.plist from the next step. Click continue for the next steps, just ignore them

Open Xcode and paste GoogleService-info.plist into Runner directory, the one that has AppDelegate file in it

It's important that you paste it using Xcode, if you use just a file explorer there will be some missing setting that I think Xcode does for you and your app won't work

Now go to the General tab and make sure you have Automatically manage signing on and select your profile, this is going to save you from taking an extra step

If you don't have an Apple developer profile - set it up first

Next open Capabilities tab and turn Push Notifications on

And Background Modes with Remote notifications checkbox

Next, generate a .p12 file for your app using [this](https://onesignal.com/provisionator) tool, download it and keep the password

Add iOS app is One Signal/Settings and upload .p12 file and the password that you get before

### Flutter Part
To use this plugin, add `flutter_one_signal` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

And this code anywhere where you want to initialize One Signal push notifications in your app

```dart
var notificationsPermissionGranted = await FlutterOneSignal.startInit(
     appId: 'ONE_SIGNAL_APP_ID',
     inFocusDisplaying: OSInFocusDisplayOption.InAppAlert,
     notificationReceivedHandler: (notification) {
       print('received : $notification');
     },
     notificationOpenedHandler: (notification) {
       print('opened : $notification');
     },
     unsubscribeWhenNotificationsAreDisabled: false,
     );

print('Push notification permission granted $notificationsPermissionGranted');

FlutterOneSignal.sendTag('userId', 'demoUserId');

FlutterOneSignal.setEmail('email');

var userId = await FlutterOneSignal.getUserId();
print("Received $userId");
```

startInit method signs you up for notifications and you pass notificationReceivedHandler, notificationOpenedHandler just like in the native SDK's

The only required attribute here is appId. inFocusDisplaying by default is InAppAlert, unsubscribeWhenNotificationsAreDisabled works only on Android, it's false by default

You could've noticed that I have a duplicated way of declaring One Signal app id. This is due to a very different iOS/Android setup logic. So, for now, you have to include it in build.gradle file. In the next iterations, I'll try to  get rid of this part

On Android startInit returns Future of true instantaneously

### Notification Open Handler
By default you have your home page opened when notification is clicked. This is not a behavior you'd want for a real app. To disable this behavior on Android add this code to android/app/src/main/AndroidManifest.xml

```xml
<application
    ...>
    ...                                                                                      
    <meta-data android:name="com.onesignal.NotificationOpened.DEFAULT" android:value="DISABLE" />  
</application>
```

And now you can open the screen you want in Flutter
```dart
FlutterOneSignal.startInit(                                             
    ...             
    notificationOpenedHandler: (notification) {                                            
      Navigator.of(context).pushNamed('somePage');                       
    },                                                                  
);
```
I haven't figured out an iOS fix to disable the default open behavior. You can still use the Flutter logic, it's just that your initial page will appear before the intended one
