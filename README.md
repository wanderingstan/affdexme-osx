![Affectiva Logo](http://developer.affectiva.com/images/logo.png)

###Copyright (c) 2016 Affectiva Inc. <br> See the file [license.txt](license.txt) for copying permission.

*****************************

**AffdexMe** is an app that demonstrates the use of the Affectiva Mac OS X SDK.  It uses the camera on your Mac to view, process and analyze live video of your face. Start the app and you will see your face on the screen and metrics describing your expressions.

This is an Xcode 7 project.

In order to use this project, you will need to:
- Obtain the Affectiva Mac OS X SDK (visit http://www.affectiva.com/solutions/apis-sdks/)
- Copy Affdex.framework into the project's folder.
- Add the contents of the license file near the top of the ViewController.m file. For example:

```
#define YOUR_AFFDEX_LICENSE_STRING_GOES_HERE @"{\"token\": \"01234567890abcdefghijklmnopqrstuvwxyz01234567890abcdefghijklmnop\", \"licensor\": \"Affectiva Inc.\", \"expires\": \"2016-11-20\", \"developerId\": \"developer@mycompany.com\", \"software\": \"Affdex SDK\"}"
```

- Build the project
- Run the app and smile!

