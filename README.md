# harvest_pro

## Table of Contents


01.Application

02.API

03.Prerequisites

04.Setting Up Development Environment

05.Download Java/JDK

06.Verify JDK Installation 

07.Installing Android Studio(for Android development) and Setting Up a New Emulator

08.Setting Up Flutter in VSCode(recommended code editor) with Android Studio Emulator

09.Set up Android licenses

10.Cloning the Project

11.Running Flutter Doctor(Verify Flutter installation)

12.Modify Flutter Packages

13.Setting Up Firebase for Your Flutter Android App
14.Modifying Gradle Files for Setup Firebase

15.Running the App

16.Troubleshooting

17.Contact

---

## 01. Application 
- **Use Technology**: Flutter


## 02. API

- **Use Technology**: Flask, Swagger

---

## 03. Prerequisites

Before starting, ensure you have the following tools installed on your computer.

- [Flutter SDK](https://flutter.dev/docs/get-started/install) latest
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [Visual Studio Code](https://code.visualstudio.com/) (VS Code) with Dart and Flutter extensions
- [Android Studio](https://developer.android.com/studio) with the Flutter plugin


## 04. Setting Up Development Environment

**Preparing for Android Studio and Emulator Installation:**

Ensure Adequate Hard Disk Space: Before starting, ensure that you have at least 20GB of free hard disk space. This space is necessary for the Android Studio installation, SDKs, emulators, and system images.

Check System Requirements: Ensure that your computer meets the minimum system requirements to run Android Studio efficiently. As of my last update, these requirements include:

- **OS:** Windows (10 or later), macOS (10.14 or later), GNOME or KDE desktop on Linux
- **RAM:** Minimum 4 GB RAM, 8 GB RAM recommended
- **Disk Space:** Minimum 2 GB of available disk space, 4 GB Recommended (500 MB for IDE + 1.5 GB for Android SDK and emulator system image)
- **Screen Resolution:** 1280 x 800 minimum screen resolution

**Overall, you need 20GB on your C: drive to run Flutter and all plugins with C: drive free space for smooth running.**

For the latest requirements, check the [official Android Studio download page.](https://developer.android.com/codelabs/basic-android-kotlin-compose-install-android-studio#0)


## 05. **Download Java/JDK:**

Visit the Oracle JDK download page and download newest version: (https://www.oracle.com/java/technologies/).

1. Accept the license agreement.
2. Download the JDK appropriate for your operating system (e.g., Windows, macOS, Linux).
3. Run the downloaded JDK installer.
4. Follow the installation instructions provided by the installer.
5. Choose the installation directory for the JDK.
6. Complete the installation process.
7. Open the Start menu and search for “Environment Variables.”
8. Click on “Edit the system environment variables.”
9. Click the “Environment Variables” button at the bottom.
10. Under the “System Variables” section, click “New” to add a new variable.
11. Set the variable name as JAVA_HOME.
12. Set the variable value as the path to your JDK installation directory with your version path (e.g., C:\Program Files\Java\jdk-17\).
13. Click “OK” to save the changes.

## 06. **Verify JDK Installation**

1. Open a command prompt or PowerShell.
2. Type java — version and press Enter.

Command:

    java — version

---

3. Verify that the installed JDK version is displayed without any errors.

After completing these steps, you have successfully downloaded and installed the Java Development Kit (JDK) on your system. Android Studio should now be able to locate and utilize the JDK for Flutter app development.

## 07. **Installing Android Studio(for Android development) and Setting Up a New Emulator:**

Install Android Studio: If you haven't already installed Android Studio, download it from the official website and follow the installation instructions.

1. Download and install [Android Studio](https://developer.android.com/studio).
2. Install the Flutter plugin: Preferences \> Plugins \> Flutter, then restart Android Studio.
3. Install [Android toolchain](https://docs.flutter.dev/get-started/install/help#cmdline-tools-component-is-missing) for Android Studio

![](https://cdn.discordapp.com/attachments/1006536173189079070/1200420065888182302/image.png?ex=65c61d4e&is=65b3a84e&hm=02f8493e62a9a566c8f38c1e68202135a1951135a56acc14dd0a9bd22b29bb94&)

1. Open AVD Manager: In Android Studio, access the AVD (Android Virtual Device) Manager.
2. Remove Default Device: In the AVD Manager, locate the default device, click on the 'Actions' menu, and select 'Delete' to remove it.
3. Create a New Virtual Device:
4. Click "Create Virtual Device".
5. Choose 'Pixel 6a' from the device list. If not available, download its profile.
6. Click "Next".
7. Select System Image (SDK):
8. Choose 'API 33' (Tiramisu - Android 13). Download it if necessary.
9. After the download, select this system image and click "Next".
10. Configure and Finish:
11. Name the emulator (e.g., "Pixel 6a API 33").
12. Adjust settings as needed.
13. Click "Finish".

Launch the New Emulator: In the AVD Manager, start your new 'Pixel 6a API 33' emulator.

## 08. **Setting Up Flutter in VSCode(recommended code editor) with Android Studio Emulator:**

1. **Install Flutter and Dart Plugins in VSCode:**

1. Download and install [Visual Studio Code](https://code.visualstudio.com/) and Open VSCode
2. Go to the Extensions view by clicking on the square icon in the sidebar or pressing Ctrl+Shift+X.
3. Search for 'Flutter' and install the Flutter plugin. This should automatically install the Dart plugin as well.

1. **Verify Flutter Installation:**

1. Open a new terminal in VSCode (Terminal \> New Terminal).
2. Run flutter doctor to check if there are any dependencies you need to install. Follow any instructions given.

1. **Install Android Studio (If Not Already Installed):**

  1. Download Android Studio from the official website.
  2. Follow the below installation instructions.

1. **Set Up the Android Emulator in Android Studio(If Not Already Setuped)::**

  1. Open Android Studio.
  2. Go to the AVD Manager (Android Virtual Device Manager).
  3. Create a new device (e.g., Pixel 6a) with your desired API (e.g., API 33 - Tiramisu).
  4. Ensure you have downloaded the necessary system images and configurations.

1. **Start the Android Emulator:**

  1. From the AVD Manager, start the emulator you set up.
  2. Keep the emulator running.

1. **Configure Flutter and Dart in VSCode:**

  1. Open your Flutter project in VSCode.
  2. Ensure that the flutter and dart SDK paths are correctly set in the settings (if they are not automatically detected).

1. **Run Flutter App in Emulator:**

  1. Open the command palette in VSCode (View \> Command Palette or Ctrl+Shift+P).
  2. Type 'Flutter: Launch Emulator' and select the running emulator.
  3. Once the emulator is selected and running, open the command palette again and run 'Flutter: Run Flutter Project in Current Directory'.

1. **Debugging and Hot Reload:**

  1. VSCode will now build your Flutter app and install it on the emulator.
  2. You can use VSCode's debugging tools to set breakpoints, inspect variables, and more.
  3. Use the 'Hot Reload' feature by saving your files or using the appropriate command to see changes in real-time on the emulator.

## 09. **Set up Android licenses**

It’s important to note that accepting the licenses is a one-time process, usually performed during the initial setup or when adding new SDK components. It helps ensure compliance and grants you the legal permissions to utilize the Android SDK for development purposes.

Open a command prompt or PowerShell.
Run the following command to accept the Android licenses:

    flutter doctor — android-licenses

---

if any error comes, open Android studio, go to File->settings, drop down Appearence&Behavior then drop down Systems settings click on Android SDK and on right window, tap on SDK Tools, select Android SDK Command Line tools and download it. when downloaded, open terminal in Android studio/PowerShell and type above command again then accept packages licenses.

## 10. Cloning the Project

1. Open a terminal or command prompt.
2. Navigate to your desired folder using the `cd` command.
3. Clone the Project Cucumber repository:

Run this command:

    git clone https://github.com/navodi0912/Mobile-Application-for-Enhance-Sustainable-Tea_Farming_in_SriLanka_Research_Project.git

---

## 11. Running Flutter Doctor(Verify Flutter installation)

Before proceeding, it's important to ensure that your environment is correctly set up. Run the following command in your terminal:

    flutter doctor

---


## 12. Modify Flutter Packages

1. In the terminal, navigate to the project folder.
2. Run the following command to install necessary packages:

Run this command:

    flutter pub get

---

## 13. Setting Up Firebase for Your Flutter Android App

1. **Access the Firebase Console:** Navigate to the Firebase Console.

1. **Choose or Create a Project:** You can create a new project or use an existing one. For this example, use the project at Firebase Project.

1. **Add Your Android App:** In your Firebase project, add an Android app using the package name from your Flutter project, found in android/app/src/main/AndroidManifest.xml.

1. **Download the Configuration File:** After adding your app, download google-services.json and place it in your project's android/app directory.

1. **Complete the Setup:** Your Flutter app is now linked with Firebase, including the SHA-1 fingerprint. You can now proceed with integrating various Firebase functionalities into your app.

## 14. Modifying Gradle Files for Setup Firebase (Only If These Codes Are Not In The Project File)

1. Open `android/settings.gradle` and 
   
Add this line:

    plugins {
        id 'com.google.gms.google-services' version '4.4.2' apply false
    }

---

2. Open `android/app/build.gradle` and 

Add this lines:

    plugins {
         id 'com.google.gms.google-services'
    }

    android {
        defaultConfig {
            minSdk = 23
        }
    }

---

## 15. Running the App

1. Connect your Android device to your computer using a USB cable or start an Android emulator.
2. Navigate to the project folder in the terminal.
3. Run the app:

Run this command:

    flutter run
---

## 16. Troubleshooting

If you encounter any issues, refer to the [Flutter documentation](https://flutter.dev/docs/get-started/install) and [Firebase documentation](https://firebase.google.com/docs). You can also seek help from your development team.

## 17. Contact

Kushan Andarawewa

[kushan@silverlineit.co](mailto:kushan@silverlineit.co)
