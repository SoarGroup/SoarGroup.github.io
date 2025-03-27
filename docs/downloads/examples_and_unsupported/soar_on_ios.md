---
Tags:
    - iOS
    - SML
---

# Soar on iOS

This project demonstrates how you can run a Soar-enabled application on an iOS
device like an iPhone or iPad.

**Note:** This was originally published circa 2010, and is likely very out of date!

## Download Links

*   [Soar931-iOS43](https://github.com/SoarGroup/website-downloads/raw/main/Examples-and-Unsupported/Soar931-iOS43.tar.gz):
Contains all include files from the 9.3.1 release, as well as built libraries for
the iOS simulator, armv6, and armv7 architectures. It has been tested with iOS 4.3.
*   [iSoar](https://github.com/SoarGroup/website-downloads/raw/main/Examples-and-Unsupported/ios-example.tar.gz):
A self-contained sample application that works out-of-the-box on the iOS simulator
(it has copies of the includes and simulator libs from the previous link).

## Documentation

Here are the basic steps, with more detail below:

1.  Add Soar includes to the XCode header search path
2.  Add static Soar libraries to the XCode project
3.  Rename appropriate source files to .mm (to enable C++)
4.  Include the appropriate headers in your source

### Soar Includes

The easiest way to do this is to download a release and point XCode to the
`include` directory. In Build Path, look for "Header Search Paths".

### Soar Static Libraries

The basic process is to compile Soar statically for an iPhone-specific architecture
and SDK:

1.  Checkout Core from GitHub
2.  `make ios-simulator` or `make ios-armv6` or `make ios-armv7`

All `lib*.a` files in the `out/lib` folder should be added to your project
(drag+drop), except for SQLite.

### Rename Source Files

XCode allows you to use C++ if your source file is named with a `.mm` (`vs.`, `.m`)
extension. This will make for the easiest transition for non-Objective-C programmers.

### Include Headers

In addition to the usual SML headers:

*   `sml_Connection.h`
*   `sml_Client.h`
*   `ElementXML.h`

XCode needs one more, which must go before the others:

*   `portability.h`

## Developers

Nate Derbinsky

## Soar Versions

*   Soar 9

## Language

C++
