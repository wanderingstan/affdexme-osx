AffdexMe OSC for Wekinator
===

This app uses the [Affectiva SDK](http://developer.affectiva.com) to perform face and emotion detection and output this as OSC data, suitable for [Wekinator](http://www.wekinator.org/) machine learning. 

DMG download at: http://wanderingstan.com/drop/AffdexMeOSC.dmg

1. Launch app
2. Press "Show all features" to list all facial features that can be measured.
3. Edit list of available features to only those that you want. (This is a simple text edit field for now. It will ignore any feature name not recognized)
4. Enter number of faces to track. _Note: Data will only be send when this many faces are detected._
5. If needed, edit OSC host and port.
6. Press "Connect OSC" to begin transmitting data.
7. For now, you must close and restart app to chage settings.

NOTE: This is a minimally working program. :)

It is forked from the [Affectiva OSX Demo app](https://github.com/Affectiva/affdexme-osx) and uses [CocoaOSC](https://github.com/danieldickison/CocoaOSC) for OSC communication.
