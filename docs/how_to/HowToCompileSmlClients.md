---
date: 2014-08-15
authors:
  - soar
tags:
  - compile
---

<!-- old URL: https://soar.eecs.umich.edu/articles/articles/soar-markup-language-sml/79-how-to-compile-sml-clients -->

# How to compile SML Clients

## Introduction

The SML API is the standard method to get Soar agents to communicate with
external environments, such as simulations or games. The API was written
natively in C++, but has Java, Python, and Tcl bindings generated via SWIG. This
page lays out the steps required to compile C++, Java, and Python SML client
programs successfully on Linux/OSX/Windows. These instructions are for the 9.3.2
and later releases. Previous releases required a slightly more complex
compilation process.

Building a program to call the SML API is conceptually straightforward in any
language. Usually, only one or two dependencies must be specified. In practice,
this can still be painful because the operating system must be told where to
look for the dependencies. All dependencies are located in a single directory or
one of its subdirectories. This will be SoarSuite/bin if you are using a
pre-built release distribution of Soar, or (by default) SoarSuite/out if you
built Soar yourself.

For all languages, compilers and operating systems, please make sure that you
link 32-bit programs to the 32-bit version of Soar, and likewise for the 64-bit
version. The error messages compilers produce for mismatched instruction sets
tend to be cryptic, and you probably won't realize what the problem is from
reading them.

## C++

To use the SML API in a C++ program, you must include the header file
"sml*Client.h" and link to the Soar shared library. If you are using the
pre-built release package, the Soar shared library will be in SoarSuite/bin,
named \_libSoar.so* (Linux), _libSoar.dylib_ (OSX), or _Soar.dll_ (Windows). The header
will be in SoarSuite/bin/include. If you are building Soar from source, by
default the build script will put the shared library in SoarSuite/out, and the
headers in SoarSuite/out/include. Also note that when building from source, you
need to build the "kernel" target (built by default) to get the shared library,
and the "headers" target (not built by default) to produce the include
directory. See the _BuildSconsScript_ for more information. For the rest of this
section, we will assume the reader is using the pre-built release package.

For convenience, here's a Hello World program that you can use to test your
compilation process:

```C++
#include <iostream>
#include "sml_Client.h"

using namespace std;
using namespace sml;

int main(int argc, char *argv[]) {
        Kernel *k = Kernel::CreateKernelInNewThread();
        Agent *a = k->CreateAgent("soar");
        cout << a->ExecuteCommandLine("echo Hello World") << endl;

        string dummy;
        cin >> dummy;
        return 0;
}
```

## Linux / Mac OS X

It's fairly straightforward to compile an SML client program from a shell using
g++ or clang++. Both compilers take the same arguments. Supposing you unpacked
the release into /home/user/SoarSuite, the compilation command should be:

```
g++ -L/home/user/SoarSuite/bin -I/home/user/SoarSuite/bin/include your_program.cpp -lSoar
```

`-L` specifies additional library search directories, `-I` specifies additional
include search directories, and `-l` specifies libraries to link to. The linker
automatically figures out that -lSoar refers to the file libSoar.so on Linux or
libSoar.dylib on OSX. Note that even though the linker can find the Soar shared
library at link-time, the OS will still not know where it is at run-time (unless
you use the RPATH feature). Therefore, you still need to set the environment
variables `LD_LIBRARY_PATH` on Linux and `DYLD_LIBRARY_PATH` on OSX
to `/home/user/SoarSuite/bin` when running your compiled program. More details can
be found in BuildLibrarySearchPaths.

## Windows with Visual Studio

Compiling an SML program using Visual Studio is a little more tedious because
you have to navigate its cryptic configuration GUI. Here we present step-by-step
instructions for setting up a new C++ project. These steps were tested using
MSVC++ 2010 Express, but should be very similar or identical for other versions
of Visual Studio. We assume you extracted the release into C:\SoarSuite.

1. In the menu, select File/New/Project...
1. Choose the "Empty Project" template. Enter a name for the project.
1. In the Solution Explorer, under the newly created project, there should be a "Source Files" folder. Right click it, choose Add/New Item... Choose "C++ File" in the template selection window that pops up, and give the file a name. You need to do this now so that the Properties window will show options for compiling C++ programs. I also copied the contents of the above Hello World program into the new file, but you don't have to.
1. Right click on the new project (NOT the solution) in the Solution Explorer, choose Properties.
1. Click on "Configuration Manager" in the upper right corner of the Properties window. Make sure that your project's Platform matches the version of Soar you downloaded/compiled. That means if you have a 32-bit version of Soar.dll, you need to use the "Win32" platform, and if you have a 64-bit version, you need to use the "x64" platform. VC++ Express doesn't include a 64-bit compiler, so if you are using it, you must use the 32-bit Soar. When you are done, close the Configuration Manager.
1. In the "Configuration" drop-down box in the top left corner of the properties window, select "All Configurations" so that the changes you make apply to both debug and release configurations.
1. Under Configuration Properties / Debugging / Environment, enter PATH=C:\SoarSuite\out. This will set the PATH environment variable to find Soar.dll when you run your program from within the IDE.
1. Under Configuration Properties / C/C++ / General / Additional Include Directories, add the entry C:\SoarSuite\bin\include.
1. Under Configuration Properties / Linker / General / Additional Library Directories, add the entry C:\SoarSuite\bin.
1. Under Configuration Properties / Linker / Input / Additional Dependencies, add Soar.lib.
1. Click "Okay" in the Properties window to save the changes.

Now you should be able to build and run your project. Remember that if you want
to run the program outside of the Visual Studio IDE, you need to add
C:\SoarSuite\bin to your PATH environment variable, discussed in more detail in
BuildLibrarySearchPaths.

## Static Linking

You can compile Soar as a static library, as described in BuildSconsScript. To
link your program to a static Soar library, the only change you have to make is
to define the macro `STATIC_LINKED` before you include sml_Client.h. There are
macros in the Soar headers that will expand to different values depending on
whether `STATIC_LINKED` is defined. Specifically, the prefix declspec (dllimport)
is prepended to all SML API functions when compiling with MSVC++. More
information is available here, but you don't need to understand it to compile
successfully.

- With g++ and clang++, the easiest way to do this is to pass in the flag `-DSTATIC_LINKED`.
- In Windows/VC++, go to the Properties window for the project. Under
  Configuration Properties / C/C++ / Preprocessor / Preprocessor Definitions, add
  the text `STATIC_LINKED`. Click "Apply", then look under Configuration Properties
  / C/C++ / Command Line. You should see/D "STATIC_LINKED" somewhere in the
  command.

## Java

The only requirement for compiling a Java SML client is that the file sml.jar be
in your class path. This file should be located inSoarSuite/bin/java in the
release, and SoarSuite/out/java if you built Soar yourself and included the
target sml_java (built by default).

In the following, I assume you're compiling a source file HelloWorld.java with
the following contents:

```Java
import sml.Kernel;
import sml.Agent;

public class HelloWorld {
        public static void main(String[] args) {
                Kernel k = Kernel.CreateKernelInNewThread();
                Agent a = k.CreateAgent("soar");
                System.out.println(a.ExecuteCommandLine("echo Hello World"));
        }
}
```

To compile your program using javac directly from the command line, add sml.jar
to the class path using the -cp flag. The command is essentially the same for
all operating systems:

```bash
javac -cp /home/user/SoarSuite/bin/java/sml.jar HelloWorld.java (for Linux/OSX)
javac -cp C:\SoarSuite\bin\java\sml.jar HelloWorld.java (for Windows)
```

This should produce a file HelloWorld.class.

Oddly enough, running a Java SML client program is trickier than compiling it.
The classes in sml.jar use JNI to call the C++ API under the hood. The JNI
functions are compiled into a native shared library named
libJava_sml_ClientInterface.so (Linux),libJava_sml_ClientInterface.dylib (OSX),
or Java_sml_ClientInterface.dll (Windows). This file should be in SoarSuite/bin
orSoarSuite/out. When you run your program, you have to make sure the Java
virtual machine can locate this library as well as the Soar shared library. This
is explained in BuildLibrarySearchPaths.

After you set the library path correctly, you can run HelloWorld.class using the
JVM. When you run the program, sml.jar should also be in the class path.
Assuming HelloWorld.class is in the current directory, the command to run the
program is:

```bash
java -cp /home/user/SoarSuite/bin/java/sml.jar:. HelloWorld (for Linux/OSX)
java -cp C:\SoarSuite\bin\java\sml.jar;. HelloWorld (for Windows)
```

You should see "Hello World" printed to the console. If you didn't set the
library search path correctly, running your program will produce an error that
looks something like this:

```Java
java.lang.UnsatisfiedLinkError: no Java_sml_ClientInterface in java.library.path
Exception in thread "main" java.lang.UnsatisfiedLinkError: no Java_sml_ClientInterface in java.library.path
        at java.lang.ClassLoader.loadLibrary(ClassLoader.java:1856)
        at java.lang.Runtime.loadLibrary0(Runtime.java:845)
        at java.lang.System.loadLibrary(System.java:1084)
        at sml.smlJNI.<clinit>(smlJNI.java:15)
        at sml.Kernel.CreateKernelInNewThread(Kernel.java:133)
        at HelloWorld.main(HelloWorld.java:6)
```

## Eclipse

Many Java programmers use the Eclipse IDE. Here are the steps to create an SML
project in Eclipse. Note that Eclipse is a general purpose IDE and comes in many
different variations. These instructions were written for "Eclipse IDE for Java
Developers". Remember that all we are doing here is getting Eclipse to find
sml.jar at compile time and the JNI shared libraries at run time.

1. In the main menu bar, choose File / New / Java Project. Give the project a
   name, then click Next.

1. Choose the Libraries tab, then click "Add External JARs". Choose
   SoarSuite/bin/java/sml.jar in the file selection dialog. Click Finish.

1. In the "Package Explorer", right click on the "src" folder under your project
   and choose New / Class, and create a class with a main function. For example,
   you can create a HelloWorld class and paste in the contents of the Hello World
   program above.

1. Again in the "Package Explorer", right click on your project, choose
   Properties. Then choose "Run/Debug Settings", and click the "New..." button on
   the right. Choose "Java Application" in the pop-up window. In the configuration
   properties window that comes up, click "Search..." and choose the class you
   created with the main function.

1. In the same window, select the "Environment" tab, click "New..." to add a new
   environment variable. For the Name field in the pop-up, enter `LD_LIBRARY_PATH` if
   you're in Linux, `DYLD_LIBRARY_PATH` if in OSX, or PATH if in Windows. For the
   Value, enter the full path to your SoarSuite/bin directory. This will help the
   JVM find the JNI shared library when you run your project.

1. Click OK, then OK again to close the configuration properties window.

Now you should be able to run your project by choosing Run / Run in the main menu bar.

## Python

To call SML via Python, you need to import the module
`Python_sml_ClientInterface`, defined in the file `Python_sml_ClientInterface.py`.
This file should be in SoarSuite/bin in the release, and SoarSuite/out in your
own build, if you built the target sml_python. Like the Java SML bindings, the
Python bindings also depend on a native library, called
`_Python_sml_ClientInterface.so` (Linux), `_Python_sml_ClientInterface.dylib` (OSX),
or `_Python_sml_ClientInterface.dll` (Windows). Note the leading underscore in all
versions. This file should also be in SoarSuite/bin in the release or
SoarSuite/out in your own build. We will assume the reader is using the
pre-built release package and both files are in SoarSuite/bin. There are two
ways to make the Python interpreter locate these files.

1. Set the environment variable `PYTHONPATH` to include SoarSuite/bin. The
   Python interpreter will search SoarSuite/bin for modules for any program you
   run.
1. Append SoarSuite/bin to the variable `sys.path` in the script itself
   before `importing Python_sml_ClientInterface`. This method is local to the script
   you applied it to, and is recommended if you have multiple versions of Soar on
   your computer.

Here is the Hello World program in Python, using the second method:

```Python
import sys
sys.path.append('/home/user/SoarSuite/bin')
import Python_sml_ClientInterface as sml

k = sml.Kernel.CreateKernelInNewThread()
a = k.CreateAgent('soar')
print a.ExecuteCommandLine('echo hello world')
```

If you use the first method to modify the search path, the first two lines of
the script are not needed. In any case, you should be able to run the script
like a normal Python program:

```bash
$ python helloworld.py
hello world
```
