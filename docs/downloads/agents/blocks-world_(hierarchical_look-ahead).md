---
Tags:
    - chunking
    - hierarchical task decomposition
    - look-ahead search
    - means-ends analysis
---

# Blocks-World (Hierarchical Look-Ahead)

This project augments the [Blocks-World Hierarchical Agent](./blocks-world_(hierarchical).md)
with look-ahead state evaluation. The description of the original agent applies
to this one. The main difference is that look-ahead is performed in the middle of
the three problem spaces that it uses.

## External Environment

None

## Soar Capabilities

*   Hierarchical task composition via subgoaling
*   Look-ahead subgoaling
*   Internally simulates external environment including an i/o link
*   Can learn procedural knowledge (enable with `learn always`)

## Download Links

*   [BlocksWorld_Hierarchical_Lookahead_Agent.zip](https://github.com/SoarGroup/website-downloads/raw/main/Agents/BlocksWorld_Hierarchical_Lookahead_Agent.zip)

## Default Rules

*   simple.soar
*   selection.soar

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
