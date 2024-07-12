---
Tags:
    - chunking
    - hierarchical task decomposition
---

# Blocks-World (Hierarchical)

This project contains a version of blocks world that is formulated for
hierarchical task decomposition. It involves three levels of problem spaces.
There is sufficient evaluation knowledge so that there is no search/uncertainty
at every level. The top level has a single operator: move-block, which moves a
block (moving-block) to a destination. The destination can be the top of another
block or the table.

The next level consists of two operators: pick-up and put-down and they arise in
an operator no-change for move-block. The rules for these are found under
move-block. This level introduces the gripper, which can be holding a block or
empty and is a structure on the top state.

The bottom level has a variety of operators: open-gripper, close-gripper,
move-gripper-above, move-gripper-down, and move-gripper-up. The structures
manipulated by these operators are part of the gripper structure on the top state.
These operators arise in an operator no-change for both pick-up and put-down and
the rules for them are under pick-up.

Includes gripper status to state. Execution is done through top-state rules that
simulate changes to the io-link

Works with chunking, which compiles the actions in the substates into rules that
apply at the top-state. Use the command "learn -e" to turn on chunking, run the agent
once, init-soar then run the agent again to see how the learned productions eliminate
the need to subgoal in the second run.

## Soar Capabilities

*   Hierarchical task composition via subgoaling
*   Internally simulates external environment including an i/o link
*   Can learn procedural knowledge (enable with 'learn always')

## Download Links

*   [BlocksWorld_Hierarchical_Agent.zip](https://github.com/SoarGroup/website-downloads/raw/main/Agents/BlocksWorld_Hierarchical_Agent.zip)

## Default Rules

*   simple.soar

## Associated Publications

[The Soar Cognitive Architecture](http://mitpress.mit.edu/catalog/item/default.asp?ttype=2&tid=12784):
Chapter 4

## Developers

John Laird

## Soar Versions

*   Soar 8
*   Soar 9

## Project Type

VisualSoar
