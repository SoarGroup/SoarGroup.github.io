---
Tags:
    - chunking
    - hierarchical task decomposition
---

# Arithmetic

An agent that performs multi-column addition and subtraction with
borrowing and carrying, all the way down to counting. No math functions
are used.

This program supports arithmetic ands subtraction between two multi-digit
numbers. It formulates the problem in multiple columns. It does not use
any math functions. As currently formulated, it uses a table of all single
digit addition facts (for addition and one subtraction strategy) and
tables of simple subtraction facts and addition by ten to single digits
(for a second subtraction strategy). These facts can be converted to a
semantic memory access (in the application of compute-result).

Each primitive operator is relatively simple: without complex proposal
conditions, control rules, lots of control flags or complex conditional
operator applications. The actual execution trace is sometimes a bit
tricky, especially for subtraction.

The project supports the automatic generation of random 3 column addition
and subtraction problems which are created in generate-problem. The
project will execute N of these (set as the value of `^count` in `initialize-arithmetic`).

The project checks that all answers are computed correctly by using Soar's
math functions (computed in elaborations/Verify and finish-problem) if an
incorrect answer is computed, it is printed out and Soar halts

The two subtraction strategies differ in what initial facts they assume.
One of the subtraction strategies assumes the same knowledge as addition
(the sum of two single digit numbers and the resulting carry), but
involves remapping that knowledge so that it is appropriate for
subtraction. For example it knows that if 7 is subtracted from 6 that the
answer is 9 and there must be a borrow from the column to the left.

The second subtraction strategy assumes that the system knows how to
subtract any single digit (0-9) from the numbers 0-18, and that it has
facts to add ten to any single digit (0-9).

The actual trace of a strategy arises from the available operator
applications and impasses that arise. For example, in the second strategy,
if a larger number is being subtracted from a smaller number, there is an
operator no-change impasse because no fact is available for that
situation. This is the standard american approach to subtraction. The key
rules for this are in process-column/compute-result.soar

The only differences between the two strategies are the available facts
and a single rule in process-column that applies the process-column
operator by accessing the facts
(`process-column*apply*compute-result*subtraction`). There are rules that
only are used by the second strategy (in the compute-result substate), but
there is no explicit control to invoke them and they do not have to be
disabled during addition or the other subtraction strategy.

Works with chunking (`learn --on`).

## External Environment

None

## Soar Capabilities

*   Hierarchical task decomposition
*   Chunking
*   Doing math with just symbol manipulation

## Download Links

*   [Arithmetic_Agent.zip](https://github.com/SoarGroup/website-downloads/raw/main/Agents/Arithmetic_Agent.zip)

## Default Rules

None

## Associated Publications

None

## Developers

John Laird

## Soar Versions

*   Soar 9.2+

## Project Type

VisualSoar
