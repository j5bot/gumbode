GUmBoDE
==============

Puts together the many moving pieces required for a comprehensive experience debugging mobile devices on Android and iOS platforms.

The Moving Pieces
---------------------------

The biggest moving pieces involved are:

* Privoxy proxy server to inject scripts / alter script tags
* Weinre (WEb INspector REmote) a remote console and DOM viewer (no js debugging)
* Aardwolf, a remote js debugging tool
* JSConsole, a remote js console
* jsHybugger, an android debugging proxy app
* iOS Webkit Debug Proxy (for debugging iOS in chrome)
* Android debug log watcher (from sdk)
* Android Emulator
* iPhone Simulator

Prerequisites
------------------

Gumbode assumes that you already have XCode installed and the iOS Simulator. It also assumes that you have a version of the android SDK installed and that the tools/bin and platform-tools/bin directories are in your PATH.