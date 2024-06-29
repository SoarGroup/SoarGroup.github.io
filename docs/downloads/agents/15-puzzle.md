---
capabilities:
    - Look-ahead subgoaling
    - Chunking
download_links:
    - https://web.archive.org/web/20210921233852/http://web.eecs.umich.edu/~soar/downloads/Agents/Fifteen_Puzzle_Agent.zip
default_rules:
    - selection.soar
developers:
    - John Laird
soar_versions:
    - "8"
    - "9"
project_type:
    - VisualSoar
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
