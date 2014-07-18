# Tado for OSX

A simple application to show the current temperature of your [Tado](http://www.tado.com/de-en/) heating device in the OSX status bar.

## How it works

It is rather simple. On first load, the application will ask you for your username and password your Tado device (these are what you use to login to `my.tado.com`). It then saves those details in the keychain and starts fetching the Tado API every 5 minutes for the latest temperature.

The temperature is displayed in the OSX status bar:

![Screenshot](http://i.imgur.com/mnZdAHm.png)

## Usage

- [Download](https://github.com/rdougan/tado-osx/releases/tag/1.0) and run the application
- Login
- Add the application to your login items (System Preferences > Users & Groups > Login Items)

## Thanks

- [SSKeychain](https://github.com/soffes/sskeychain)
- [Mac App Icon Template](http://blog.dfilimonov.com/2013/07/08/mac-app-icon-template-for-photoshop.html)
