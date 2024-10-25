# Firebase Demo

This demonstrates how to use the `@Shared` property wrapper with Firebase's remote config feature.
It allows you to use the values stored in a remote config in your features' models and views in
order to control their logic and behavior.

To run this demo you will need to create a Firebase project and configure the application
accordingly:

 1. Visit https://firebase.google.com and create a new Firebase project

 2. Configure the Firebase project for this iOS application

     1. Click the "iOS" button under "Get started by adding Firebase to your app"

     2. Enter "co.pointfree.FirebaseDemo" as the Apple bundle ID and register the application

     3. Download the "GoogleService-Info.plist" config file, drag it into this Xcode project, and
        add it to the "FirebaseDemo" application target

     4. Click "Next" on each step and finally click "Continue to console"

 3. Add a remote config boolean to your Firebase project

     1. Navigate to the "Remote Config" section of your project

     2. Click "Create configuration" to create your first parameter

     3. Create a parameter with the name (key) "showPromo", the data type "Boolean", provide a
        default value of "false", and click "Save"

     4. Click the "Publish changes" button and confirm to roll out the parameter

 4. Run the iOS demo

     1. In Xcode, build and run FirebaseDemo in the simulator

     2. In the Firebase project's web console, "Edit" the "showPromo" parameter and flip the
        default value to "true"

     3. Click the "Publish changes" button and confirm to roll out the parameter and watch the
        simulator live-update in seconds. (You can edit and re-publish the parameter as many times
        as you'd like to see the change reflected in the simulator.)
