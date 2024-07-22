
## What works


- login/logout
- location
- In app updates
- Export data 
- AI based summarization 
- Profile settings
- View other people 


## Enable AI 

- For the free version of AI using LM studio
- Download LM studio and load any model from huggingface 
- Start the server which would load a localhost:1234/completions endpoint 
- Connect your phone and laptop on the same wifi and then start the application 

## Building the app from source 

- Cd to the file directory with pubspec.yaml 
- Run `flutter build apk` for the .apk file to test on your mobile 
- Run `flutter run` if debugging on laptop.
- Changing backend: We use firebase and you can easily overrride the current firebase config files by 
1. go to https://console.firebase.google.com/
2. create a new app 
3. Select firebase and run the suggested commands 
Install and run the FlutterFire CLI
From any directory, run this command:

`dart pub global activate flutterfire_cli`
Then, at the root of your Flutter project directory, run this command:

`flutterfire configure --project=app-01-fcbae`

4. Click yes on all options and let it override 
5. Then enable the firestore in firebase.
6. Run it !








## Paid version
- Remove the local host LLM endpoint and instead add any paid API (no need to do anything extra or changing code, just replace the endpoint and it will work)

## Imporant!

- The features should work on your phone with the storage access and others without changing anything when installing the .apk 
- If you build with source code then make sure to delete the .gradle file and let it build up again from source to save from any inconsistency.
 
 
