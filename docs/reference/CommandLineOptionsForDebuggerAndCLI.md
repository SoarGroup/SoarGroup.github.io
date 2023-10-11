---
source: https://soar.eecs.umich.edu/articles/articles/documentation/224-command-line-options-for-the-java-debugger-and-cli
date: 2016-09-30
tags:
    - debugger
authors:
    - soar
---

# Command-Line Options for the Java Debugger and CLI

## Soar Java Debugger Command Line Options

- remote Use a remote connection (with default ip and port values)
- ip xxx Use this IP value (implies remote connection)
- port ppp Use this port (implies remote connection, without any remote options
    we start a local kernel)
- agent `<name>` On a remote connection select this agent as initial agent
- agent `<name>` On a local connection use this as the name of the initial agent
- source `<path>` Load this file of productions on launch (only valid for local kernel)
- quitonfinish When combined with source causes the debugger to exit after sourcing that one file
- listen ppp Use this port to listen for remote connections (only valid for a local kernel)
- maximize Start with maximized window
- width `<width>` Start with this window width
- height `<height>` Start with this window height
- x `<x>` -y `<y>` Start with this window position
- cascade Cascade each window that starts (offsetting from the -x `<x>` -y `<y>`
    if given). This option now always on. (Providing width/height/x/y => not a
    maximized window)

## Soar-CLI Command Line Options

- `-l` Listen on, i.e. launches Soar kernel in new thread
- `-n` No syntax coloring
- `-p` `<port>` Listens on port `<port>`
- `-s` `<file>` Sources file `<file>` on load

To manage multiple agents, you can use the commands "create", "list", and "switch".

## Troubleshooting

If you have problems with the debugger, try deleting any .soar files in your
home directory. Corrupt settings can cause the java debugger to fail to launch.
