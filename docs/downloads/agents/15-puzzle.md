---
tags:
    - chunking
    - look-ahead search
---

# 15-Puzzle Agent

This agent is a straightforward implementation of the fifteen-puzzle. It uses
look-ahead search to solve the puzzle with a simple evaluation function. This
agent also demonstrates chunking.

The puzzle consists of fifteen sliding tiles, numbered by digits from 1 to 15
arranged in a 4 by 4 array of sixteen cells. One of the cells is always empty,
and any adjacent tile can be moved into the empty cell. The initial state is
some arbitrary arrangement of the tiles. The goal state is the arrangement of
tiles such that they are ordered from lowest to highest value. The problem is to
find a sequence of moves from the initial state to the goal state.

## Soar Capabilities

-   Look-ahead subgoaling
-   Chunking

## Download Links

-   [Fifteen_Puzzle_Agent.zip](https://github.com/SoarGroup/website-downloads/raw/main/Agents/Fifteen_Puzzle_Agent.zip)

## External Environment

None.

## Default Rules

selection.soar

## Associated Publications

None

## Developer

John Laird

## Soar Versions

-   Soar 8
-   Soar 9

## Project Type

VisualSoar
