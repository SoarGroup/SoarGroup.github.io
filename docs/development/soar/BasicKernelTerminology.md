---
date: 2014-10-07
authors:
   - soar
tags:
   - kernel programming
---

<!-- markdown-link-check-disable-next-line -->
<!-- old URL: https://soar.eecs.umich.edu/articles/articles/
technical-documentation/198-basic-kernel-terminology -->

# Basic Kernel Terminology

This is a document that defines some of the basic data structures, files and
terminology used in the Soar kernel code. It is very incomplete but a good
starting point for understanding the kernel.

"But where can I start?"

In a nutshell: The Soar Kernel is a very object-oriented, structured set of
code. If you don't understand the basic Soar execution cycle and its phases, the
source code won't help you. You should start by reading the introductory
material in the [Soar Tutorials](../../tutorials/soar_tutorial/index.md)
that are bundled with the releases (in the Documents directory). Then read the
first four chapters of the [Soar Manual](../../soar_manual/index.md),
"Introduction" thru "Learning" Basic code execution

## Data Structures

All of the structures are well-commented in the header files. In earlier
versions of Soar (up thru 8.3.5), the single header file "soarkernel.h" defined
all the common structures used throughout the code. I still find it the easiest
place to search for information even though it's a very large file as code goes.
**In 8.6. and later, the header file was separated by function into many smaller
files which can be found in "Core/SoarKernel/include".**

The `agent_struct` defined in agent.h includes all the system parameters,
counters, variables, and pointers to all the other structures used by an agent
(WMEs, productions, hash tables, memory_pools, formats, etc etc). It's a BIG
structure, tough to read, and includes a lot of detailed comments. But if it
isn't defined or allocated here, the agent doesn't know about it.

Chances are you will never modify any structures in the rete, lexer, hash
tables, or backtracing facilities, but you should know that they exist. If you
do start to muck with these structures, you better know what you are doing.
Changes here can greatly impact performance and even whether or not Soar will
run properly. Several structures require their members to be defined in specific
order and are commented appropriately.

Structures that you should familiarize yourself with are symbols (a typedef'd
union!!), wmes, productions, instantiations, preferences, and (eventually)
memory pools.

*   `symbol_struct` is in `symtab.h`, everything in Soar boils down to some kind
of symbol.
*   `wme_struct` is in `wmem.h`, defines the working memory elements of an agent
*   `production_struct` is in `production.h`, these are the productions as loaded
into Soar and stored in the rete. instantiations are in instantiation.h, these store
the bindings of productions as they are matched in the rete. Instantiations whose
conditions all match are fired during specific phases - meaning their actions are
executed: preferences are asserted to create wmes, and/or RHS actions are executed.
*   `preference_struct` is defined in `preference.h`, stores a pointer to the
instantiation that created it, and when the instantiation no longer matches,the
preference is retracted.

## I want to add a new link!

Existing links include input/output and reward links. Instructions on how to
make your own are [HowTo: IO and reward links](./IOAndRewardLinks.md).

## Things to add

A lot of topics are in the [Soar FAQ](../SoarTechnicalFAQ.md)

*   Basic structure of how critical code works (e.g. decision procedure is a big
    switch statement, how printing/XML generation works)
*   Locations of critical code (e.g. decision procedure, preference procedure, scheduler)
*   Union basics (most people don't know what unions are)
    *   see Kernigan and Ritchie
    *   Unions are a data structure that can have multiple data-dependent ways of
        storing and accessing information, much like (but better than) overloading
        methods in C++.
*   Explain how sysparams work (e.g. how they are set/used, how to add a new one)
*   sysparams are just an array of agent parameters that store settings for
    runtime switches. Most of the sysparams are either True/False, or can take on
    some enum value. Setting a sysparam is easy, cf. init_soar.c for
    initializing and setting values. Search the code for "set_sysparams" to see
    examples.
*   To add a sysparam, see gsysparams.h (although that file MUST be renamed or
    folded into another header when gSKI removed). The code depends on looping over
    HIGHEST_SYSPARAM, so make sure it's always equal to the last one in the set of
    definitions.
*   When is it a sysparam, and when is it part of the agent struct? Depends what
    you are using it for, and whether it needs to be exposed for the user interface.
    If its a user-controlled setting, it should definitely be a sysparam.
*   What is a slot

From John:

> "We used to select more than just the operator (state, problem space, and goal)
> and all together this was the context. Slots were for things that can be
> selected, so there was a slot for each of those. Now there is just a slot for
> the operator and although some of that language might have bled over to
> selection of values for non-operator attributes. In general they are an out of
> date terminology."

*   Basics of how wme changes are done in parallel (i.e. explain do_buffered_wm_and_ownership_changes)
*   Difference between wme and input_wme (and any other wmes there might be)
*   Where/how to add new links (e.g. ep-mem link, RL link, etc)
*   Explain memory pool basics

*   Basics of bit manipulations that are used (unless this is rete-only, in which
    case don't bother)
    *   I think the rete is the only place bit manipulations occur. Bit
        manipulations are extremely fast. If you can guarantee your raw data
        structure, you can shift registers instead of calling complex instructions
        to go very fast. Compilers hide this from you, but don't always know when
        they can optimize.
*   Explain transitive closure and tc_num
*   What all the Soar kernel STL-like data structures are (e.g. lists, hash
tables, growable strings, others?) and how to use them.
Ref counting (link to Tracking down memory leaks)

## Some Definitions

### slot

From John Laird:

> We used to select more than just the operator (state, problem space, and goal)
> all together this was the context. Slots were for things that can be selected,
> so there was a slot for each of those. Now there is just a slot for the
> operator, although some of that language might have bled over to selection of
> values for non-operator attributes. In general they are an out of date
> terminology.

Slots are contained by identifiers, and hold all the preferences associated with
the identifier, including acceptable wme preferences. Each identifier can have
multiple slots, which can be accessed via the prev and next fields in the slot
structure. Operator preferences are held incontext slots, which are identified
by the isa_context_slot flag.

### tc

transitive closure

### match goal

The lowest goal (biggest number after the "S") that an instantiation of the LHS
of a production matches on. Part of the instantiation structure.

### potential

Also referred to as _backtracing_.

condition whose id is instantiated on a symbol linked from both the current goal
and a higher goal, and is tested for in the production's LHS using a path from
the current goal.

For example, if the following wmes are in working memory

```Soar
(S1 ^foo F1)
(S2 ^bar F1)
(F1 ^baz B1)
(S2 ^superstate S1)

and this production was backtraced through
Code:
sp {example
   (<s> ^bar <b>)
   (<b> ^baz <z>)
-->
   ...}
```

then `(<b> ^baz <z>)` would be a potential condition.

### potential (life)  

abstract invented concept that actually has no real meaning.

### tm

temporary memory. I believe that any preference that is currently valid in Soar
(either they are o-supported or the instantiation that generated them still
matches) is in temporary memory. Once a preference is no longer valid, it is
taken out of temporary memory (which involves setting the in_tm flag to false,
and taking them off the preferences array and all_preferences lists on the slot
they're on).

### clone (preference)

a copy of a preference that is the result of a subgoal. While the inst pointer
of the original preference points to the instantiation of the rule that fired in
the subgoal to create the result, the inst pointer of the clone points to the
newly created chunk or justification. Therefore, the preference and its clone
exist on different match goals, and hence different match goal levels.

### instantiation

a particular match of a production in working memory, and the preferences generated

### DEBUG_MEMORY

if this flag is defined, the contents of freed memory locations in the memory
pools are memset to `0xBB`

### Refraction

Via [Wikipedia](https://en.wikipedia.org/wiki/Rete_algorithm#Production_execution):

>Each production instance will fire only once, at most, during any one
match-resolve-act cycle. This characteristic is termed _refraction_.

Refracting a fired instance means to prevent it from firing again.

### Rete Structures

#### CN

Conjunctive negation

#### NVN

Node variable names
