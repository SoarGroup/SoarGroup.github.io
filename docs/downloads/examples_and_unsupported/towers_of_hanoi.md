---
Tags:
    - environments
---

# Towers of Hanoi

The classic Towers of Hanoi puzzle implemented as an external, graphical environment
using Java and interfaced with Soar via SML. To see how the agent performs the task,
you must launch the Soar debugger and tell it to connect to a remote Soar agent.

The Towers of Hanoi is a puzzle that consists of three rods and a number of disks
of different sizes which can slide onto any rod. The puzzle starts with the disks
in a neat stack in ascending order of size on one rod, the smallest at the top,
thus making a conical shape. The objective of the puzzle is to move the entire
stack to another rod, obeying the following rules:

*   Only one disk may be moved at a time.
*   Each move consists of taking the upper disk from one of the rods and sliding
it onto another rod, on top of the other disks that may already be present on
that rod.
*   No disk may be placed on top of a smaller disk.

*Description of game rules derived from [its Wikipedia page](https://web.archive.org/web/20211023052945/http://en.wikipedia.org/wiki/Towers_of_Hanoi)
and is released under the [Creative Commons license](https://web.archive.org/web/20211023052945/http://creativecommons.org/licenses/by-sa/3.0/).*

## Download Links

*   [Java_Tower_of_Hanoi_Example.zip](https://github.com/SoarGroup/website-downloads/raw/main/Examples-and-Unsupported/Java_Tower_of_Hanoi_Example.zip)

## Associated Agents

There is one basic agent embedded within the environment that will automatically
be sourced when you launch it.

**Note**: You cannot run the many Towers of Hanoi agents available in the
*Agents* downloads section with this environment. Those ones are not designed to
be run with the I/O interface of this external environment.

## Documentation

While there is no explicit documentation, the Soar Debugger tutorial does have a
section that explains how to hook up the debugger to this type of environment.

## Associated Publications

None

## Developers

Taylor Lafrinere

## Soar Versions

*   Soar 8
*   Soar 9

## Language

Java
