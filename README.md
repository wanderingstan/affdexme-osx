AffdexMe OSC for Wekinator
===

This app uses the [Affectiva SDK](http://developer.affectiva.com) to perform face and emotion detection and output this as OSC data, suitable for [Wekinator](http://www.wekinator.org/) machine learning.  It is a fork of the [AffdexMe OSX](https://github.com/Affectiva/affdexme-osx) demo app.

DMG download at: http://wanderingstan.com/drop/AffdexMeOSC.dmg

![Animated gif of face detection in action](http://wanderingstan.com/drop/Affdex-OSC.gif)

1. Launch app
2. Press "Show all features" to list all facial features that can be measured.
3. Edit list of available features to only those that you want. (This is a simple text edit field for now. It will ignore any feature name not recognized)
4. Enter number of faces to track. _Note: Data will only be send when this many faces are detected._
5. If needed, edit OSC host and port.
1. In Wekintor, press "Begin Listening". (This app doesn't behave well when it can't connect.)
6. Press "Connect OSC" to begin transmitting data.
7. For now, you must close and restart app to chage settings.

NOTE: This is a minimally working program. :)

Current features that can be exposed via OSC:

- expressions.attention
- expressions.browFurrow
- expressions.browRaise
- expressions.cheekRaise
- expressions.chinRaise
- expressions.dimpler
- expressions.eyeClosure
- expressions.eyeWiden
- expressions.innerBrowRaise
- expressions.jawDrop
- expressions.lidTighten
- expressions.lipCornerDepressor
- expressions.lipPress
- expressions.lipPucker
- expressions.lipStretch
- expressions.lipSuck
- expressions.mouthOpen
- expressions.noseWrinkle
- expressions.smile
- expressions.upperLipRaise
- emotions.anger
- emotions.contempt
- emotions.disgust
- emotions.engagement
- emotions.joy
- emotions.sadness
- emotions.surprise
- emotions.valence
- orientation.yaw
- orientation.pitch
- orientation.roll
- orientation.interocularDistance
- extra.faceToFaceDistance (The distance between this and adjacent face)

---

In order to use this project, you will need to:
- Obtain the Affectiva OSX SDK (visit http://www.affectiva.com/solutions/apis-sdks/)
- Have a valid CocoaPods installation on your machine
- Install the Affdex SDK on your machine using the Podfile:
```
pod install
```

- Open the Xcode workspace file AffdexMe-OSX.xcworkspace -- not the .xcodeproj file.
- Build the project.
- Run the app and smile!

More info, including licence, at the original Affdex me repo:
https://github.com/Affectiva/affdexme-osx
