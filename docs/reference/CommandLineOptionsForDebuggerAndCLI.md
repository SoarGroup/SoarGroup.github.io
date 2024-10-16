---
date: 2016-09-30
tags:
    - debugger
    - cli
authors:
    - soar
---

# Command-Line Options for the Java Debugger and CLI

## Soar Java Debugger Command Line Options

-   `-remote`: Use a remote connection (with default ip and port values)
-   `-ip <ip>`: Use the specified IP value (implies remote connection)
-   `-port <port>`: Use the specified port (implies remote connection)
-   `-agent <name>`: On a remote connection, select the specified agent as
initial agent; on a local connection, assign the specified name to the initial agent
-   `-source <path>`: Source the specified .soar file on launch (only valid for local
kernel)
-   `-quitonfinish`: When combined with `-source`, causes the debugger to exit after
sourcing that one file
-   `-listen <port>`: Use the specified port to listen for remote connections (only
valid for a local kernel)
-   `-maximize`: Start with maximized window
-   `-width <width>`: Start with the specified window width
-   `-height <height>`: Start with the specified window height
-   `-x <x> -y <y>`: Start with the specified window position
-   `-cascade`: Cascade each opened window (offsetting from the -x `<x>` -y `<y>`
    if given). This option is always on. (Providing width/height/x/y => not a
    maximized window)
-   `-layout <xml file>`: Load the layout (window positions, types of windows etc.)
from the specified XML file. You can also store the layout file in the debugger settings
folder and refer to it by just the file name.

## Soar-CLI Command Line Options

-   `-l`: Listen on, i.e. launches Soar kernel in new thread
-   `-n`: No syntax coloring
-   `-p <port>`: Listens on port `<port>`
-   `-s <file>`: Sources file `<file>` on load

To manage multiple agents, you can use the commands "create", "list", and "switch".

## Troubleshooting

If you have problems with the debugger, try deleting any .soar files in your
home directory. Corrupt settings can cause the java debugger to fail to launch.
