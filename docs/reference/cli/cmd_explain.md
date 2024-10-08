# explain

Allows you to explore how rules were learned.

## Synopsis

```bash
======= Explainer Commands and Settings =======
explain ?                                             Print this help listing
---------------- What to Record ---------------
all                                    [ on | OFF ]   Record all rules learned
justifications                         [ on | OFF ]   Record justifications
record <chunk-name>                                   Record specific rule
list-chunks                                           List all rules learned
list-justifications                                   List all justifications
----------- Starting an Explanation -----------
chunk [<chunk name> | <chunk id> ]                    Start discussing chunk
formation                                             Describe formation
----------- Browsing an Explanation -----------
instantiation <inst id>                               Explain instantiation
explanation-trace                                     Switch explanation trace
wm-trace                                              Switch to WM trace
------------ Supporting Analysis --------------
constraints                                           Display extra transitive
                                                       constraints required by
                                                       problem-solving
identity                                              Display identity to
                                                       identity set mappings
stats                                                 Display statistics about
                                                       currently discussed chunk
------------------ Settings -------------------
after-action-report                    [ on | OFF ]   Print statistics to file
                                                       on init and exit
only-chunk-identities                  [ ON | off ]   Identity analysis only
                                                       prints identities sets
                                                       found in chunk
-----------------------------------------------

To change a setting:                               explain <setting> [<value>]
For a detailed explanation of these settings:      help explain
```

### Summary Screen

Using the `explain` command without any arguments will display a summary of
which rule firings the explainer is watching for learning. It also shows which
chunk or justification the user has specified is the current focus of its
output, i.e. the chunk being discussed.

Tip: This is a good way to get a chunk id so that you don't have to type or
paste in a chunk name.

```bash
=======================================================
                   Explainer Summary
=======================================================
Watch all chunk formations                            Yes
Explain justifications                                No
Number of specific rules watched                      0

Chunks available for discussion:                      chunkx2*apply2 (c 14)
                                                      chunk*apply*o (c 13)
                                                      chunkx2*apply2 (c 12)
                                                      chunk*apply*d (c 11)
                                                      chunkx2*apply2 (c 6)
                                                      chunk*apply* (c 15)
                                                      chunkx2*apply (c 8)
                                                      chunk*apply*c (c 5)
                                                      chunkx2*apply (c 10)
                                                      chunk*apply (c 1)

* Note:  Printed the first 10 chunks. 'explain list' to see other 6 chunks.

Current chunk being discussed:                        chunk*apply*down-gripper(c 3)

Use 'explain chunk [ <chunk-name> | id ]' to discuss the formation of that chunk.
Use 'explain ?' to learn more about explain's sub-command and settings.
```

## explain chunk

This starts the process.

Tip: Use `c`, which is an alias to `explain chunk`, to quickly start discussing
a chunk, for example:

```bash
soar % c 3
Now explaining chunk*apply*move-gripper-above*pass*top-state*OpNoChange*t6-1.
- Note that future explain commands are now relative
  to the problem-solving that led to that chunk.

Explanation Trace                                     Using variable identity IDs                  Shortest Path to Result Instantiation

sp {chunk*apply*move-gripper-above*pass*top-state*OpNoChange*t6-1
1:    (<s1> ^top-state <s2>)                          ([140] ^top-state [162])
     -{
2:    (<s1> ^operator <o*1>)                          ([140] ^operator [141])
3:    (<o*1> ^name evaluate-operator)                 ([141] ^name evaluate-operator)
     }
4:    (<s2> ^gripper <g1>)                            ([162] ^gripper [156])                       i 30 -> i 31
5:    (<g1> ^position up)                             ([156] ^position up)                         i 30 -> i 31
6:    (<g1> ^holding nothing)                         ([156] ^holding nothing)                     i 30 -> i 31
7:    (<g1> ^above <t1>)                              ([156] ^above [157])                         i 30 -> i 31
8:    (<s2> ^io <i2>)                                 ([162] ^io [163])                            i 31
9:    (<i2> ^output-link <i1>)                        ([163] ^output-link [164])                   i 31
10:   (<i1> ^gripper <g2>)                            ([164] ^gripper [165])                       i 31
11:   (<s2> ^clear { <> <t1> <b1> })                  ([162] ^clear { <>[161]  [161] })            i 30 -> i 31
12:   (<s1> ^operator <o1>)                           ([140] ^operator [149])
13:   (<o1> ^moving-block <b1>)                       ([149] ^moving-block [161])
14:   (<o1> ^name pick-up)                            ([149] ^name pick-up)
      -->
1:    (<g2> ^command move-gripper-above +)            ([165] ^command move-gripper-above +)
2:    (<g2> ^destination <c1> +)                      ([165] ^destination [161] +)
}
```

## explain formation

`explain formation` provides an explanation of the initial rule that fired which
created a result. This is what is called the 'base instantiation' and is what
led to the chunk being learned. Other rules may also be base instantiations if
they previously created children of the base instantiation's results. They also
will be listed in the initial formation output.

```bash
soar % explain formation
------------------------------------------------------------------------------------
The formation of chunk 'chunk*apply*move-gripper-above*pass*top-state*OpNoChange*t6-1' (c 1)
------------------------------------------------------------------------------------

Initial base instantiation (i 31) that fired when apply*move-gripper-above*pass*top-state matched at level 3 at time 6:

Explanation trace of instantiation # 31            (match of rule apply*move-gripper-above*pass*top-state at level 3)
 (produced chunk result)
                                                   Identities instead of variables       Operational    Creator

1:    (<s> ^operator <op>)                         ([159] ^operator [160])                   No         i 30 (pick-up*propose*move-gripper-above)
2:    (<op> ^name move-gripper-above)              ([160] ^name move-gripper-above)          No         i 30 (pick-up*propose*move-gripper-above)
3:    (<op> ^destination <des>)                    ([160] ^destination [161])                No         i 30 (pick-up*propose*move-gripper-above)
4:    (<s> ^top-state <t*1>)                       ([159] ^top-state [162])                  No         i 27 (elaborate*state*top-state)
5:    (<t*1> ^io <i*1>)                            ([162] ^io [163])                         Yes        Higher-level Problem Space
6:    (<i*1> ^output-link <o*1>)                   ([163] ^output-link [164])                Yes        Higher-level Problem Space
7:    (<o*1> ^gripper <gripper>)                   ([164] ^gripper [165])                    Yes        Higher-level Problem Space
   -->
1:    (<gripper> ^command move-gripper-above +)    ([165] ^command move-gripper-above +)
2:    (<gripper> ^destination <des> +)             ([165] ^destination [161] +)
------
```

This chunk summarizes the problem-solving involved in the following 5 rule firings:

```bash
   i 27 (elaborate*state*top-state)
   i 28 (elaborate*state*operator*name)
   i 29 (pick-up*elaborate*desired)
   i 30 (pick-up*propose*move-gripper-above)
   i 31 (apply*move-gripper-above*pass*top-state)
```

## explain instantiation

This is probably one of the most common things you will do while using the
explainer. You are essentially browsing the instantiation graph one rule at a
time.

Tip: Use `i`, which is an alias to `explain instantiation`, to quickly view an
instantiation, for example:

```bash
soar % i 30
Explanation trace of instantiation # 30            (match of rule pick-up*propose*move-gripper-above at level 3)
- Shortest path to a result: i 30 -> i 31
                                                   Identities instead of variables       Operational    Creator

1:    (<s> ^name pick-up)                          ([152] ^name pick-up)                     No         i 28 (elaborate*state*operator*name)
2:    (<s> ^desired <d*1>)                         ([152] ^desired [153])                    No         i 29 (pick-up*elaborate*desired)
3:    (<d*1> ^moving-block <mblock>)               ([153] ^moving-block [154])               No         i 29 (pick-up*elaborate*desired)
4:    (<s> ^top-state <ts>)                        ([152] ^top-state [155])                  No         i 27 (elaborate*state*top-state)
5:    (<ts> ^clear <mblock>)                       ([155] ^clear [154])                      Yes        Higher-level Problem Space
6:    (<ts> ^gripper <g>)                          ([155] ^gripper [156])                    Yes        Higher-level Problem Space
7:    (<g> ^position up)                           ([156] ^position up)                      Yes        Higher-level Problem Space
8:    (<g> ^holding nothing)                       ([156] ^holding nothing)                  Yes        Higher-level Problem Space
9:    (<g> ^above { <> <mblock> <a*1> })           ([156] ^above { <>[154]  [157] })         Yes        Higher-level Problem Space
   -->
1:    (<s> ^operator <op1> +)                      ([152] ^operator [158] +)
2:    (<op1> ^name move-gripper-above +)           ([158] ^name move-gripper-above +)
3:    (<op1> ^destination <mblock> +)              ([158] ^destination [154] +)
```

## explain explanation-trace and wm-trace

In most cases, users spend most of their time browsing the explanation trace.
This is where chunking learns most of the subtle relationships that you are
likely to be debugging. But users will also need to examine the working memory
trace to see the specific values matched.

To switch between traces, you can use the `explain e` and the `explain w` commands.

Tip: Use `et` and 'wt', which are aliases to the above two commands, to quickly
switch between traces.

```bash
soar % explain w
Working memory trace of instantiation # 30     (match of rule pick-up*propose*move-gripper-above at level 3)
1:    (S9 ^name pick-up)                               No         i 28 (elaborate*state*operator*name)
2:    (S9 ^desired D6)                                 No         i 29 (pick-up*elaborate*desired)
3:    (D6 ^moving-block B3)                            No         i 29 (pick-up*elaborate*desired)
4:    (S9 ^top-state S1)                               No         i 27 (elaborate*state*top-state)
5:    (S1 ^clear B3)                                   Yes        Higher-level Problem Space
6:    (S1 ^gripper G2)                                 Yes        Higher-level Problem Space
7:    (G2 ^position up)                                Yes        Higher-level Problem Space
8:    (G2 ^holding nothing)                            Yes        Higher-level Problem Space
9:    (G2 ^above { <> B3 T1 })                         Yes        Higher-level Problem Space
   -->
1:    (S9 ^operator O9) +
2:    (O9 ^name move-gripper-above) +
3:    (O9 ^destination B3) +
```

## explain constraints

This feature explains any constraints on the value of variables in the chunk
that were required by the problem-solving that occurred in the substate. If
these constraints were not met, the problem-solving would not have occurred.

Explanation-based chunking tracks constraints as they apply to identity sets
rather than how they apply to specific variables or identifiers. This means that
sometimes constraints that appear in a chunk may have been a result of
conditions that tested sub-state working memory element. Such conditions don't
result in actual conditions in the chunk, but they can provide constraints.
`explain constraints` allows users to see where such constraints came from.

This feature is not yet implemented. You can use `explain stats` to see if any
transitive constraints were added to a particular chunk.

## explain identity

`explain identity` will show the mappings from variable identities to identity
sets. If available, the variable in a chunk that an identity set maps to will
also be displayed. (Requires a debug build because of efficiency cost.)

Variable identities are the ID values that are displayed when explaining an
individual chunk or instantiation. An identity set is a set of variable
identities that were unified to a particular variable mapping. The null identity
set indicates identities that should not be generalized, i.e. they retain their
matched literal value even if the explanation trace indicates that the original
rule had a variable in that element.

By default, only identity sets that appear in the chunk will be displayed in the
identity analysis. To see the identity set mappings for other sets, change the
`only-chunk-identities` setting to `off`.

```bash
soar % explain identity
=========================================================================
-             Variablization Identity to Identity Set Mappings          -
=========================================================================

-== NULL Identity Set ==-

The following variable identities map to the null identity set and will
not be generalized: 282 301 138 291 355 336 227 309 328 318 128 218 345

-== How variable identities map to identity sets ==-

Variablization IDs      Identity     CVar    Mapping Type

Instantiation 36:
  125 -> 482          | IdSet 12  | <s>       | New identity set
  126 -> 493          | IdSet 11  | <o>       | New identity set
Instantiation 38:
Instantiation 41:
  146 -> 482          | IdSet 12  | <s>       | New identity set
  147 -> 493          | IdSet 11  | <o>       | New identity set
Instantiation 42:
  151 -> 180          | IdSet 1   | <ss>      | New identity set
  149 -> 482          | IdSet 12  | <s>       | New identity set
  150 -> 493          | IdSet 11  | <o>       | New identity set
  307 -> 180          | IdSet 1   | <ss>      | Added to identity set
  187 -> 180          | IdSet 1   | <ss>      | Added to identity set
  334 -> 180          | IdSet 1   | <ss>      | Added to identity set
  173 -> 180          | IdSet 1   | <ss>      | Added to identity set
  280 -> 180          | IdSet 1   | <ss>      | Added to identity set
Instantiation 53:
  219 -> 489          | IdSet 15  | <b>       | New identity set
Instantiation 61:
Instantiation 65:
  319 -> 492          | IdSet 20  | <t>       | New identity set
```

## explain stats

`explain stats` prints statistics about the chunk being discussed.

```bash
===========================================================
Statistics for 'chunk*apply*move-gripper-above*pass*top-state*OpNoChange*t6-1' (c 1):
===========================================================
Number of conditions                                       14
Number of actions                                          2
Base instantiation                                         i 31 (apply*move-gripper-above*pass*top-state)

===========================================================
                 Generality and Correctness
===========================================================

Tested negation in local substate                          No
LHS required repair                                        No
RHS required repair                                        No
Was unrepairable chunk                                     No

===========================================================
                      Work Performed
===========================================================
Instantiations backtraced through                          5
Instantiations skipped                                     6
Constraints collected                                      1
Constraints attached                                       0
Duplicates chunks later created                            0
Conditions merged                                          2
```

## After-Action Reports

The explainer has an option to create text files that contain statistics about
the rules learned by an agent during a particular run. When enabled, the
explainer will write out a file with the statistics when either Soar exits or a
`soar init` is executed. This option is still considered experimental and in
beta.

## Explaining Learned Procedural Knowledge

While explanation-based chunking makes it easier for people to now incorporate
learning into their agents, the complexity of the analysis it performs makes it
far more difficult to understand how the learned rules were formed. The
explainer is a new module that has been developed to help ameliorate this
problem. The explainer allows you to interactively explore how rules were
learned.

When requested, the explainer will make a very detailed record of everything
that happened during a learning episode. Once a user specifies a recorded chunk
to "discuss", they can browse all of the rule firings that contributed to the
learned rule, one at a time. The explainer will present each of these rules with
detailed information about the identity of the variables, whether it tested
knowledge relevant to the the superstate, and how it is connected to other rule
firings in the substate. Rule firings are assigned IDs so that user can quickly
choose a new rule to examine.

The explainer can also present several different screens that show more verbose
analyses of how the chunk was created. Specifically, the user can ask for a
description of (1) the chunk’s initial formation, (2) the identities of
variables and how they map to identity sets, (3) the constraints that the
problem-solving placed on values that a particular identity can have, and (4)
specific statistics about that chunk, such as whether correctness issues were
detected or whether it required repair to make it fully operational.

Finally, the explainer will also create the data necessary to visualize all of
the processing described in an image using the new ’visualize’ command. These
visualizations are the easiest way to quickly understand how a rule was formed.

Note that, despite recording so much information, a lot of effort has been put
into minimizing the cost of the explainer. When debugging, we often let it
record all chunks and justifications formed because it is efficient enough to do
so.

Use the explain command without any arguments to display a summary of which rule
firings the explainer is watching. It also shows which chunk or justification
the user has specified is the current focus of its output, i.e. the chunk being
discussed.

Tip: This is a good way to get a chunk id so that you don’t have to type or
paste in a chunk name.

## Visualizing an Explanation

Soar's `visualize` command allows you to create images that represent processing
that the explainer recorded. There are two types of explainer-related
visualizations.

(1) The visualizer can create an image that shows the entire instantiation graph
at once and how it contributed to the learned rule. The graph includes arrows
that show the dependencies between actions in one rule and conditions in others.
This image is one of the most effective ways to understand how a chunk was
formed, especially for particularly complex chunks. To use this feature, first
choose a chunk for discussion. You can then issue the `visualize` command with
the appropriate settings.

(2) The visualizer can also create an image that shows how identities were
joined during identity analysis. This can be useful in determining why two
elements were assigned the same variable.

## Default Aliases

```bash
c    explain chunk
i    explain instantiation

ef   explain formation
ei   explain identities
es   explain stats

et   explain explanation-trace
wt   explain wm-trace
```

## See Also

-   [chunk](./cmd_chunk.md)
-   [visualize](./cmd_visualize.md)
