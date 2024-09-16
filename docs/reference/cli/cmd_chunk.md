# chunk

Sets the parameters for explanation-based chunking.

## Synopsis

```bash
===================================================
           Chunk Commands and Settings
===================================================
? | help                                              Print this help listing
timers                                 [ on | OFF ]   Timing statistics (no args to print stats)
stats                                                 Print statistics on learning
------------------- Settings ----------------------
always | NEVER | only | except                        When Soar will learn new rules
bottom-only                            [ on | OFF ]   Learn only from bottom sub-state
naming-style                     [ numbered | RULE]   Numeric names or rule-based names
max-chunks                                 50         Max chunks learned per phase
max-dupes                                   3         Max duplicate chunks (per rule, per phase)
------------------- Debugging ---------------------
interrupt                              [ on | OFF ]   Stop after learning from any rule
explain-interrupt                      [ on | OFF ]   Stop after learning rule watched
warning-interrupt                      [ on | OFF ]   Stop after detecting learning issue
------------------- Fine Tune ---------------------
singleton                                             Print all WME singletons
singleton                <type> <attribute> <type>    Add a WME singleton pattern
singleton -r             <type> <attribute> <type>    Remove a WME singleton pattern
----------------- EBC Mechanisms ------------------
add-ltm-links                          [ on | OFF ]   Recreate LTM links in results
add-osk                                [ on | OFF ]   Incorporate operator selection rules
merge                                  [ ON | off ]   Merge redundant conditions
lhs-repair                             [ ON | off ]   Add conds for unconnected LHS IDs
rhs-repair                             [ ON | off ]   Add conds for unconnected RHS IDs
user-singletons                        [ ON | off ]   Unify with domain singletons
---------- Correctness Guarantee Filters ----------     Allow rules to form that...
allow-local-negations                  [ ON | off ]   ...used local negative reasoning
allow-opaque*                          [ ON | off ]   ...used knowledge from a LTM recall
allow-missing-osk*                     [ ON | off ]   ...tested operators selected through OSK
allow-uncertain-operators*             [ ON | off ]   ...tested operators selected probabilistically
* disabled
---------------------------------------------------

To change a setting:                                  chunk <setting> [<value>]
For a detailed explanation of these settings:         help chunk
```

## Description

The `chunk` command controls the parameters for explanation-based chunking. With
no arguments, this command prints out a basic summary of the current learning
parameters, how many rules have been learned and which states have learning
active. With an `?` argument, it will list all sub-commands, options and their
current values.

## Turning on Explanation-Based Chunking

Chunking is _disabled_ by default. Learning can be turned on or off at any point
during a run. Also note that Soar uses most aspects of EBC to create
justifications as well, so many aspects of the chunking algorithm still occur
even when learning is off.

```bash
chunk always:      Soar will always attempt to learn rules from sub-state
                   problem-solving.
chunk never:       Soar will never attempt to learn rules.
chunk unflagged:   Chunking is on in all states _except_ those that have had RHS
                   `dont-learn` actions executed in them.
chunk flagged:     Chunking is off for all states except those that are flagged
                   via a RHS `force-learn` actions.
```

The `flagged` argument and its companion `force-learn` RHS action allow Soar
developers to turn learning on in a particular problem space, so that they can
focus on debugging the learning problems in that particular problem space
without having to address the problems elsewhere in their programs at the same
time. Similarly, the `unflagged` flag and its companion `dont-learn` RHS action
allow developers to temporarily turn learning off for debugging purposes. These
facilities are provided as debugging tools, and do not correspond to any theory
of learning in Soar.

The `bottom-only` setting control when chunks are formed when there are multiple
levels of subgoals. With bottom-up learning, chunks are learned only in states
in which no subgoal has yet generated a chunk. In this mode, chunks are learned
only for the "bottom" of the subgoal hierarchy and not the intermediate levels.
With experience, the subgoals at the bottom will be replaced by the chunks,
allowing higher level subgoals to be chunked.

## Debugging Explanation-Based Chunking

The best way to understand why and how rules formed is to use the `explain`
command. It will create detailed snapshots of everything that existed when a
rule or justification formed that you can interactively explore. See
[explain](./cmd_explain.md) for more information. You can even use it in
conjunction with the visualizer to create graphs depicting the dependency
between rules in a sub-state.

The `stats` command will print a detailed table containing statistics about all
chunking activity during that run.

The `interrupt` setting forces Soar to stop after forming any rule.

The `explain-interrupt` setting forces Soar to stop when it attempts to form a
rule from a production that is being watched by the explainer. See
[explain](./cmd_explain.md) for more information.

The `warning interrupts` setting forces Soar to stop when it attempts to form a
rule but detects an issue that may be problematic.

The `record-utility` command is a tool to determine how much processing may be
saved by a particular learned rule. When enabled, Soar will detect that a chunk
matched, but will not fire it. Assuming that the rule is correct, this should
lead to an impasse that causes a duplicate chunk to form. The amount of time and
decision cycles spent in that impasse are recorded and stored for the rule.
Rules are also flagged if a duplicate is not detected or if an impasse is not
generated.

This feature is not yet implemented.

## Preventing Possible Correctness Issues

It is theoretically possible to detect nearly all of the sources of correctness
issues and prevent rules from forming when those situations are detected. In
Soar 9.6.0, though, only one filter is available, `allow-local-negations`. Future
versions of Soar will include more correctness filters.

Note that it is still possible to detect that your agent may have encountered a
known source of a correctness issue by looking at the output of the chunk
stats command. It has specific statistics for some of the sources, while others
can be gleaned indirectly. For example, if the stats show that some rules
required repair, you know that your agent testing or augmenting a previous
result in a substate.

### chunk allow-local-negations

The option `allow-local-negations` control whether or not chunks can be created
that are derived from rules that check local WMEs in the substate don't exist.
Chunking through local negations can result in overgeneral chunks, but disabling
this ability will reduce the number of chunks formed. The default is to enable
chunking through local negations.

If chunking through local negations is disabled, to see when chunks are
discarded (and why), set `watch --learning print` (see [trace](./cmd_trace.md)
command).

The following commands are not yet enabled. Soar will currently allow all of
these situations.

### allow-missing-osk

Used operator selection rules to choose operator

### allow-opaque

Used knowledge from opaque knowledge retrieval

### allow-uncertain-operators

Used operators selected probabilistically

### allow-conflated-reasoning

Tests a WME that has multiple reasons it exists

## Other Settings that Control WHEN Rules are Learned

### chunk max-chunks

The `max-chunks` command is used to limit the maximum number of chunks that may
be created during a decision cycle. The initial value of this variable is 50;
allowable settings are any integer greater than 0.

The chunking process will end after max-chunks chunks have been created, even if
there are more results that have not been backtraced through to create chunks,
and Soar will proceed to the next phase. A warning message is printed to notify
the user that the limit has been reached.

This limit is included in Soar to prevent getting stuck in an infinite loop
during the chunking process. This could conceivably happen because newly-built
chunks may match immediately and are fired immediately when this happens; this
can in turn lead to additional chunks being formed, etc.

Important note:

If you see this warning, something is seriously wrong; Soar will be unable to
guarantee consistency of its internal structures. You should not continue
execution of the Soar program in this situation; stop and determine whether your
program needs to build more chunks or whether you've discovered a bug (in your
program or in Soar itself).

### chunk max-dupes

The `max-dupes` command is used to limit the maximum number of duplicate chunks
that can form from a particular rule in a single decision cycle. The initial
value of this variable is 3; allowable settings are any integer greater than 0.
Note that this limit is per-rule, per-state. With the default value, each rule
can match three times in a sub-state and create two duplicate, reject rules
before Soar will stop attempting to create new rules based on that rule. The
limit is reset the next decision cycle.

This limit is included in Soar to prevent slowing down when multiple matches of
a rule in a substate produce the same general rule. Explanation-based chunking
can now produce very general chunks, so this can happen in problem states in
which the logic leads to multiple matches, which leads to results being created
multiple times in the same decision cycle.

## Settings that Alter the Mechanisms that EBC Uses

### chunk add-osk

The option `add-osk` control whether or not operator selection knowledge is
backtraced through when creating justifications and chunks. When this option is
disabled, only requirement preferences (requires and prohibits) will be added
backtraced through. When this option is enabled, relevant desirability prefs
(better, best, worse, worst, indifferent) will also be added, producing more
specific and possibly correct chunks. This feature is still experimental, so the
default is to not include operator selection knowledge.

The following commands are not yet enabled. Soar will always use the EBC
mechanisms listed below.

### variablize-identity

Variablize symbols based on identity analysis

### variablize-rhs-funcs

Variablize and compose RHS functions

### enforce-constraints

Track and enforce transitive constraints

### repair

Repair rules that aren't fully connected

### merge

Merge redundant conditions

### user-singletons

Unify identities using domain-specific singletons

If backtracing traces through the same WME multiple times via different
backtrace paths, a resulting chunk may have duplicate conditions for that WME.
This could be undesirable. Enabling user-singletons allows the user to specify
duplicate conditions that should be merged.

Singletons are defined using the `chunk singleton <type> <attr> <type>` command,
where `<type>` is either "state", "identifier", or "constant", and `<attr>` is
the domain-specific attribute to unify within chunks.

## Chunk Naming Style

The numbered style for naming newly-created chunks is:

```bash
<prefix><chunknum>
```

The rule-based (default) style for naming chunks is:

```bash
<prefix>*<original-rule-name>*<impassetype>*<dc>-<dcChunknum>
```

where:

-   prefix is either chunk or justification, depending on whether learning was
    on for that state,
-   chunknum is a counter starting at 1 for the first chunk created,
-   original-rule-name is the name of the production that produced the result
    that resulted in this chunk,
-   dc is the number of the decision cycle in which the chunk was formed,
-   impassetype is one of Tie, Conflict, Failure, StateNoChange, OpNoChange,
-   dcChunknum is the number of the chunk within that specific decision cycle.

Note that when using the rule-based naming format, a chunk based on another
chunk will have a name that begins with prefix followed by `-xN`, for example
`chunk-x3*apply-rule*42-2`.

## Default Aliases

```bash
learn    chunk
cs       chunk --stats
```

## See Also

-   [explain](./cmd_explain.md)
-   [trace](./cmd_trace.md)
-   [visualize](./cmd_visualize.md)
