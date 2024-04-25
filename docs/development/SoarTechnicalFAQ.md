---
date: 2014-08-14
authors:
    - soar
tags:
    - Java
    - C++
    - agent development
    - sml
    - kernel programming
---

<!-- markdown-link-check-disable-next-line -->
<!-- old URL: https://soar.eecs.umich.edu/articles/articles/faqs-and-guides/
75-soar-technical-faq -->

# Soar Technical FAQ

## Getting Soar

### Where are the latest Soar releases?

Check the downloads page for pointers to downloads and release notes.
Alternatively you can check out the development trunk from git. See the build
documents for more information.

## Running Soar

### How do I run Soar?

If you downloaded a Soar release, navigate inside the extracted archive and run
the shell scripts or batch files to run the various Soar components. The scripts
set essential environment variables so the different Soar components can find
their libraries and resources.

### Java: What JREs/JDKs can I use?

Use Sun JDK 6+. Other versions and vendors may work but we do not support them.

## Using the Soar Java Debugger

### What command line options does the debugger accept?

Command line options:

*   remote => use a remote connection (with default ip and port values)
*   ip xxx => use this IP value (implies remote connection)
*   port ppp => use this port (implies remote connection)
    Without any remote options we start a local kernel
*   agent => on a remote connection select this agent as initial agent
*   agent => on a local connection use this as the name of the initial agent
*   source "" => load this file of productions on launch (only valid for local kernel)
*   listen port => use this port to listen for remote connections (only valid
for a local kernel)
*   maximize => start with maximized window
*   width => start with this window width
*   height => start with this window height
*   x -y => start with this window position (Providing width/height/x/y => not a
maximized window)

<!-- markdownlint-disable MD013 -->
### If I run the debugger for a while, it starts to slow down, stutter, and then crashes, or runs out of memory

The problem here is that the trace window in the debugger is using more and more
memory over time, since it doesn't get rid of old stuff until you clear the
window. Especially at `watch 5`, there's a lot of text being stored (even if
it's mostly hidden). Long before your OS runs out of memory, though, Java runs
out of heap space. You can allocate more heap space to most Java implementations
using the -Xmxm flag when executing Java. For example:

```bash
java -Xmx512m -jar SoarJavaDebugger.jar
```

This will allocate 512 megs of memory for Java's heap (the default is 64 megs),
and should allow you to run the debugger significantly longer.

<!-- markdownlint-disable MD013 -->
### How do I use the debugger with the graphical demos like JavaTOH and JavaMissionaries? (or any other Soar application)?

1.  Start the application
1.  Start the debugger (in Linux the debugger must be started after the
   application--order doesn't matter in Windows)
1.  In the debugger, on the top menuBar, pull down the "Kernel" selection and
   choose "Connect to Remote Soar..."
1.  In the popup window "Would you like to shutdown the local kernel now" enter
   "OK"
1.  In the next popup window, if the application is on your local machine, press
   "OK" to use the default settings. If your application is running on another
   machine, enter the IP addr and press "OK"
1.  If the connection succeeds, then you can use the debugger and the application
   interchangeably to control the agent. If the connection fails, then the
   application either is not properly configured for SML, or no agent currently
   exists in the application.

### How can I copy/paste a production into the debugger?

There are several ways to do this:

*   You can paste a production into the trace window.
*   You can use the "edit_production" window in the lower-right corner. If you
    supply the name of an existing production, it will fill in the window with that
    production. You can then edit it and load the new version using the "Load
    Production" button.
*   If your production is in Visual Soar, you can do "Soar Runtime" -> "Connect"
    to connect to the debugger. Then, open the file with your production and do
    "Runtime" -> "Send Production" or "Send File" to load your production(s) into
    Soar.

## Developing Soar

## SCons is adding a lot of ridiculous include directories and the build fails

Seeing something like this means you should define `JAVA_HOME`:

```bash
g++ -o Core/CLI/CommandLineInterface.o -c -DSCONS -fvisibility=hidden -g3 -Wall -Werror -O3 -m64 -fPIC -ICore/CLI/src -ICore/CLI/include -ICore/SoarKernel/include -ICore/ElementXML/include -ICore/ConnectionSML/include -ICore/KernelSML/include -ICore/shared -I/usr/include -I/usr/include/netatalk -I/usr/include/netinet -I/usr/include/protocols -I/usr/include/dbus-1.0 -I/usr/include/blkid -I/usr/include/netax25 -I/usr/include/nfs -I/usr/include/rdma -I/usr/include/netpacket -I/usr/include/X11 -I/usr/include/c++ -I/usr/include/neteconet -I/usr/include/xen -I/usr/include/rpc -I/usr/include/gnu -I/usr/include/netash -I/usr/include/asm -I/usr/include/sound -I/usr/include/mtd -I/usr/include/asm-generic -I/usr/include/netrom -I/usr/include/compiz -I/usr/include/arpa -I/usr/include/net -I/usr/include/rpcsvc -I/usr/include/netiucv -I/usr/include/linux -I/usr/include/netrose -I/usr/include/video -I/usr/include/bits -I/usr/include/netipx -I/usr/include/uuid -I/usr/include/python2.5 -I/usr/include/sys -I/usr/include/python2.6
```

See the build document for more details.

## How do I get the trace for the initial S1 creation?

The initial state is created right after the agent is created but before the
agent pointer is passed back to the client. Therefore, if you create the client
and then register for print (or xml) output, you do not ever see the initial S1
creation.

To get these initial print callbacks, you need to register for the
after-agent-created event and register your print handlers in that function.
This callback fires right after the agent is created but before S1 is created.

## How can I look up a wme on the input link if I know its attribute?

Use the `Indentifier::FindByAttribute` method like this:

```c++
pAgent->GetInputLink()->FindByAttribute("location", 0);
```

This works for any identifier, not just at the top level of the input link.

## How do I increase the performance of my SML application?

It is often desirable to maximize the performance of your SML application. This
section assumes that you just want to make things as fast as possible after you
have finished debugging your application. Debugging is an inherently slow
process, so these tips will be less helpful while you’re still debugging.

Compile with optimizations turned on. In Visual Studio this means doing a
release build. On Linux and OS X, the default settings are probably sufficient,
but you can experiment with new settings if you want (let us know if you find
better settings).

Put primary application and Soar in the same process. That is, use
`CreateInNewThread` or `CreateInCurrentThread`, not `CreateRemoteConnection`.
Using a remote kernel means socket communication is used, which is slow.

Don’t register for unnecessary events. Every event that is registered for causes
extra work to be done. Try to find an appropriate event to register for so you
don’t end up getting more event calls than you actually need – that is, try to
avoid registering for events which occur more frequently than you need and then
filtering them on the application side.

Don’t connect the debugger. Connecting the debugger creates a remote connection
and also registers for several events. Set `watch level 0`. Even if you don’t
have a client registered for any of the print or XML events, work is still done
internally to generate some of the information that would have been sent out.
Setting `watch level 0` avoids this work.

Disable monitor productions. Again, even if no client is registered to print out
the text of monitor productions, work is still done internally to prepare the
text. Monitor productions can be disabled by excising them or commenting them
out, but an easier method is to have each monitor production test a debug flag
in working memory which is set by some initialization production or operator.
Thus all of the monitor productions can be turned on or off by changing one line
of code.

Disable timers. Soar uses timers internally to generate the output of the stats
command. If you don’t need this information, you can use the `timers –off`
command to disable this bookkeeping. This can make a significant difference in
the `watch 0` case.

Avoid running agents separately. Instead of calling `RunSelf` or
`RunSelfTilOutput` on each agent, just call RunAllAgents? on the kernel itself.
This runs all agents together and avoids the overhead of running them
separately. The absolute best you can do is to call `RunAllAgentsForever` as
described in section 2.4 – this avoids repeatedly calling the `run` functions at
all and will make it easier to stop and restart your application from the
debugger (or other clients).

In the case where the absolute best performance under SML is desired, use
`CreateKernelInCurrentThread` instead of `CreateKernelInNewThread` and set the
“optimized” flag to true in the parameters passed to
`CreateKernelInCurrentThread`. This means Soar will execute in the same thread as
your application. Without this each call to and from the Soar kernel requires a
context switch (assuming a single processor machine). This method also
eliminates the thread which polls for new events. This means you must poll for
the events yourself by periodically calling `CheckForIncommingCommands`, which
is a little more work for the programmer.

Turn off `autocommits`. By default, SML sends WME changes to the kernel as soon as
they are requested. Performance can be improved by telling SML to buffer all WME
changes until an explicit call is made to commit the changes. Turning off
`autocommits` is done via a call to `mykernel->SetAutoCommit(false)`. Explicitly
committing WME changes is done via a call to `myagent->Commit()`. Sending all the
changes at once will give a small performance boost in cases where Soar and the
environment are in the same process, and a large performance boost when they are
communicating over sockets. Be careful, though - the agent won't see any WMEs
until they have been committed (and then not until the next input phase, as
usual), and all WMEs must be committed before doing an `init-soar`, which
generally means before giving the user control (since someone could call
`init-soar` from an attached debugger). This typically means committing all WMEs
after updating an agent's `input-link`.

## When can I safely make changes to the input-link?

A Soar agent only receives input during the input phase and it does this through
an input phase callback while the agent is running. SML allows the environment
to change the input-link at other times and those changes are buffered until the
next input phase. This means you have several options for handling input: You
can register for `smlEVENT_BEFORE_INPUT_PHASE` and make changes to the input link
at that time. This is very close to the way the kernel naturally handles input
but will often be relatively slow if Soar is running a lot faster than the
environment is changing (a common situation) as this event needs to be sent each
decision cycle for each agent, generating a lot of communications traffic.

Another option is to register for an update event
(`smlEVENT_AFTER_ALL_OUTPUT_PHASES` and `smlEVENT_AFTER_ALL_GENERATED_OUTPUT`),
check for output at that time and create new inputs immediately. These events
are called after the output phase has completed and the new input link changes
will be buffered until the next input phase. This is the most common choice in
existing SML environments.

A third option is to register an output event handler, which looks for a
particular attribute to be added to the output link and only then calls the
registered function. This handler will be called during the output phase and
again, new input will be collected and buffered until the next input phase of
the agent. In general, any run event (`smlRunEventId`) or update event
(`smlUpdateEventId`) is a good candidate to use for changing the input-link. Other
events may not be appropriate to use. One particular example is
`smlEVENT_BEFORE_AGENT_REINITIALIZED` and `smlEVENT_AFTER_AGENT_REINITIALIZED`.
These events fire during an init-soar call and are dangerous to use because the
system is actively destroying the entire input link and then recreating it to
match the last structure defined by the environment. This happens automatically
and gives the agent its best chance to continue executing again. However, if you
register for these events yourself and try to change the input link during those
events, the resulting behavior is likely to depend on whether the system
callback occurs before or after your callback. With care this can probably all
work out correctly, but you should be aware of what's going on. Similarly,
making changes to I/O in response to a production firing or other such events is
potentially dangerous as you might be changing input within a given execution
phase rather than before or after it, leading to unpredictable results. These
events are best used for monitoring Soar's behavior rather than changing it.

## What do I need to know about threads in my SML applications?

You generally want to keep all interactions with the kernel in a single thread.
You can make calls from other threads, but they will block if Soar is busy doing
something else - like running - until the command completes. This requirement
raises a few issues: If you're working with a GUI, then the handler for a "run
button" shouldn't just call run on the kernel. If it does the GUI will wait for
the run to complete before responding. This is usually not acceptable as
requests to repaint the screen, other button presses etc. will be ignored. The
solution is to create a new thread and run Soar in that thread. Now that Soar
is running on a separate thread, when the user presses a "stop" button if you
try to call Stop on the kernel from the UI thread it'll block. What you need to
do instead is set a flag within the thread that is running Soar and use an event
to check whether that flag has been set and if so call Stop then. The
`smlEVENT_INTERRUPT_CHECK` event is a good candidate for this as it fires
infrequently and generates little overhead.

Similarly, as the environment changes you'll want to update the input link in
the thread that is running Soar.

The normal way to do this is again inside an event handler. The update family of
events (`smlEVENT_AFTER_ALL_OUTPUT_PHASES` and
`smlEVENT_AFTER_ALL_GENERATED_OUTPUT`) are good candidates to consider.

If all of this seems a bit confusing, take a look at the Java Towers of Hanoi
example that's included in the release. It demonstrates all of this behavior and
is a good model to follow. If you're working on a command line application
without a GUI, then the _TestCommandLine_ application is a good reference as it
demonstrates how to support interruption in a single-threaded application.

A detailed explanation about threads in Soar is provided [here](../development/soar/ThreadsInSML.md).

## How do I properly manage memory in my SML application?

Memory management is actually really easy. Generally, the only objects you
should explicitly delete are the kernel object and any objects you directly
allocated through a call to new. In Java and Tcl, this generally means you can
just let things go out of scope when you’re done with them. There are a couple
special cases you should be aware of, though: Agent objects are automatically
deleted when the owning Kernel object is deleted (actually, when the call to
`Kernel::Shutdown` is made, which you should always make before deleting the
kernel). If you want to destroy an agent earlier, you can by making a call to
`Kernel:destroyAgent`. Under no circumstances should you delete (in the C++
sense) an Agent object.

In Java if you create a `ClientXML` object through `xml = new ClientXML()` you
should call `xml.delete()` on it when you're done. This isn't strictly required
(the garbage collector will get it eventually) but is good practice and will
avoid messages about leaked memory when the application shuts down. As per the
general rule, in C++ if you create it with new you’re responsible for destroying
it with delete.

Since there can be multiple clients interacting with the same kernel and agents,
your application needs to be listening for the appropriate events so if some
other client deletes/destroys a kernel or agent your application is using, you
don’t crash. Specifically, listen for the `BEFORE_AGENT_DESTOYED` and
`BEFORE_SHUTDOWN` events so you can clean things up as needed in your
application.

<!-- markdownlint-disable MD013 -->
## What are the differences in the SML interface between C++ and Java (and other languages)?

For the most part, the exact same classes and methods are available in all
languages. In some cases there are differences with obvious mappings -- for
example, in C++ a method might take a char whereas in Java it takes a String.
One exception to this rule is in the way event callbacks are handled. The
callbacks look very similar from language to language, but some languages have
constraints that make a direct conversion of the C++ style impossible. In C++,
event callbacks are global functions.

In Java, it's not possible to have global functions, so the callback must belong
to some class. Thus, for Java we provide an interface for each event type that
the class containing the callback method must implement, and then the handling
object is passed in as part of the registration. You can look at any of the
example Java code to see examples of this (e.g. TestJavaSML or JavaTOH are good
places to start).

Another important difference is that in C++ and Tcl, the kernel object must be
explicitly deleted after `Shutdown()`. In C++ this is just calling `delete mykernel;`
whereas in Tcl it takes the form `$kernel -delete`. In Java and C#,
deletion is handled internally by the `Shutdown()` method (this isn't done in C++
to make debugging easier).

## How should I get started on my first C++/Java SML application?

See the HelloWorld document for simple example environments Start by building
and running these and then replace the code with your code. Also don't forget to
read the [SMLQuickStartGuide](../tutorials/SMLQuickStartGuide.md). The complete
documentation for the SML interface is provided in the ClientSML C++ headers
(which are thoughly commented). Using a different language - don't worry, the
interface is virtually the same.

## How do I make a copy of an existing project?

Go into the SoarSuite\Tools folder and copy the TestClientSML folder as
MyProject Within that folder, rename `TestClientSML.vcproj` as `MyProject.vcproj`
Open the `SoarSuite\SML.sln` solution file (or make a copy of this file and open
that) Select "File | Add Project | Existing Project" and add the
`MyProject.vcproj` to the solution It will be added as "TestClientSML". Select it
in Solution Explorer, right click and choose Rename to rename it as MyProject.
(Make sure you're not accidentally renaming the real TestClientSML project - you
can open the TestClientSML.cpp file in the editor and then move your mouse over
the tab at the top of the editor window for the open file to see the path just
to be sure).

At this point you should be able to build the project to create MyProject.exe
Remove TestClientSML.cpp from the project and start adding your own code. What
are the required Visual Studio project settings for my SML application?

Your project needs to reference the `!ClientSML`, `!ConnectionSML`, and `!ElementXML`
projects. Additionally, add the include directories for the src folder of each
of those projects.

## The Java Virtual Machine segfaults when running Soar

See the next question.

<!-- markdownlint-disable MD013 -->
## SML WMElement/Identifier/StringElement/IntElement/FloatElement pointers become invalid without my knowledge

First, usage of `WMElement` in this answer refers to any of
`WMElement`/`Identifier`/`StringElement`/`IntElement`/`FloatElement` (all of
which are or extend `WMElement`).

A few things to remember about WMElement pointers returned by SML methods such as
CreateIdentifier:

*   `WMElement` objects returned by pointers are owned by SML (don't delete them),
*   Pointers to `WMElement` objects may be destroyed without calling `DestroyWME`,
*   Pointers to `WMElement` objects may be destroyed by SML triggered by the
agent as it runs.
*   A general rule: you need to keep track of whether or not a `WMElement` is
valid before you use it. It will stay valid if
*   You do not call `DestroyWME` on it or on a WME that causes it to get disconnected,
*   You do not return control back to Soar letting it run.
*   If you call `DestroyWME`, you need to be sure that you don't hang on to any
    WMElement objects that the WME you destroyed was keeping valid. Most of the time
    your working memory structure is a tree so you only need to keep track of the
    children of any Identifier you destroy.

In Java/Python/Tcl/CSharp, `WMElement ConvertToIdentifier` or other Convert-
function returns something that should be equal to something else but isn't.

In our language interfaces covered by SWIG, such as Java, Python, Tcl, and
CSharp, `ConvertToIdentifier`, `ConvertToStringElement`, `ConvertToIntElement`, and
`ConvertToFloatElement` issue references to objects that wrap pointers. If these
pointers were compared, they would be equal. Unfortunately, comparing references
to these objects wrapping equivalent pointers returns `false` - that they are
unequal.

A workaround is to not compare references, or use other language supported
reference equality in this case. Instead, compare the `time tags` by calling
`GetTimeTag` on the reference.
