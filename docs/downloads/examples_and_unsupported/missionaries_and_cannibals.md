---
Tags:
    - puzzle
    - domain
---

# Missionaries and Cannibals

**The classic missionaries and cannibals puzzle implemented as an external,
graphical environment using Java and interfaced with Soar via SML. To see how the
agent performs the task, you must launch the Soar debugger and tell it to connect
to a remote Soar agent.**

In the missionaries and cannibals problem, three missionaries and three cannibals
must cross a river using a boat which can carry at most two people, under the
constraint that, for both banks, if there are missionaries present on the bank,
they cannot be outnumbered by cannibals (if they were, the cannibals would eat the
missionaries.) The boat cannot cross the river by itself with no people on board.

\* Description of game rules derived from its
[Wikipedia page](https://en.wikipedia.org/wiki/Missionaries_and_cannibals_problem)
and is released under the [Creative Commons license](https://creativecommons.org/licenses/by-sa/3.0/).

## Download Links

*   [Java_Missionaries_and_Cannibals_Example.zip](https://github.com/SoarGroup/website-downloads/raw/main/Examples-and-Unsupported/Java_Missionaries_and_Cannibals_Example.zip)

## Associated Agents

*   There is one basic agent embedded within the environment that will automatically
be sourced when you launch it.

**Note:** You cannot run the many Missionary and Cannibals agents available in the
Agents downloads section with this environment. Those ones are not designed to be
run with this external environment.

## Documentation

While there is no explicit documentation, the
[Soar Debugger tutorial](../../tutorials/IntroSoarDebugger/index.md) does have
a section that explains how to hook up the debugger to this type of environment.

### IO Links Specification

```soar
(I2 ^left-bank L1 ^right-bank R4)
  (L1 ^boat 1 ^cannibals 3 ^missionaries 3 ^other-bank R4)
  (R4 ^boat 0 ^cannibals 0 ^missionaries 0 ^other-bank L1)

(I3 ^move-boat M1)
  (M1 ^boat 1 ^cannibals 2 ^from-bank L1)
```

## Developers

Taylor Lafrinere

## Soar Versions

*   Soar 8
*   Soar 9

## Language

Java
