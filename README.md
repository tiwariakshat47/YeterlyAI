# YeterlyAI





## Future Deployment to TestFlight

### Sign the app
To publish on the Play Store, you need to sign your app with a digital certificate.

Android uses two signing keys: upload and app signing.

Developers upload an .aab or .apk file signed with an upload key to the Play Store.
The end-users download the .apk file signed with an app signing key.
To create your app signing key, use Play App Signing as described in the official Play Store documentation.

To sign your app, use the following instructions.

### Create an upload keystore

If you have an existing keystore, skip to the next step. Follow this:
Follow the Android Studio key generation steps (https://developer.android.com/studio/publish/app-signing#generate-key)

Create a file named [project]/android/key.properties that contains a reference to your keystore. Don't include the angle brackets (< >). They indicate that the text serves as a placeholder for your values.

storePassword=<password-from-previous-step>
keyPassword=<password-from-previous-step>
keyAlias=upload
storeFile=<keystore-file-location>
content_copy
The storeFile might be located at /Users/<user name>/upload-keystore.jks on macOS or C:\\Users\\<user name>\\upload-keystore.jks on Windows.

### Build App Bundle
From the command line:

Enter cd [project]
Run flutter build appbundle
(Running flutter build defaults to a release build.)
The release bundle for your app is created at [project]/build/app/outputs/bundle/release/app.aab.


Upload your bundle to Google Play to test it. You can use the internal test track, or the alpha or beta channels to test the bundle before releasing it in production.
Follow these steps to upload your bundle to the Play Store: https://developer.android.com/studio/publish/upload-bundle



Full Docs Here: 
https://docs.flutter.dev/deployment/android





