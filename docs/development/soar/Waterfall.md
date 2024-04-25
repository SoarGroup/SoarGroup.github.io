---
date: 2014-10-07
authors:
    - soar
tags:
    - kernel programming
    - substate
---

<!-- markdown-link-check-disable-next-line -->
<!-- old URL: https://soar.eecs.umich.edu/articles/articles/technical-documentation/
207-waterfall -->

# Waterfall

This document describes the "Waterfall" modifications made to to Soar.

_As described by Bob Marinier..._

"Suppose I have a blocks world agent that is trying to accomplish "put A on B".
Several moves might be required to do this, and the agent doesn't know what they
are, so it goes into a subgoal and starts randomly moving blocks around. What we
want is for the agent to get a positive reward on the substate's reward link
when it succeeds. So we can have a rule that detects that A is on B and creates
a reward when that happens. However, when A is on B, the subgoal's supporting
operator proposal will retract. Even though this retraction could, in principle,
occur in parallel with the reward rule firing, the, waterfall will cause the
retraction to occur first, and thus the substate will go away before the reward
rule gets to fire, so the agent won't get the reward. In our proposed
modification, the reward rule and retraction would occur in parallel, and thus
the agent would get the reward."

## Brief description in manual

**Note**: This mechanism is not referred to by any name in the manual, including
waterfall. See the last paragraph of chapter 2.6.5:

The second change when there are multiple substates is that at each phase, Soar
goes through the substates, from oldest (highest) to newest (lowest), completing
any necessary processing at that level for that phase before doing any
processing in the next substate. When firing productions for the proposal or
application phases, Soar processes the firing (and retraction) of rules,
starting from those matching the oldest substate to the newest. Whenever a
production fires or retracts, changes are made to working memory and preference
memory, possibly changing which productions will match at the lower levels
(productions firing within a given level are fired in parallel – simulated).
Productions firings at higher levels can resolve impasses and thus eliminate
lower states before the productions at the lower level ever fire. Thus, whenever
a level in the state stack is reached, all production activity is guaranteed to
be consistent with any processing that has occurred at higher levels.

## Definitions

> **Minor quiescence**: no more i-assertions (or any retractions) ready to fire
> in the current goal

Consistency check: making sure that the currently selected operator is still
legal (e.g., it's still acceptable, it shouldn't be replaced by a better
operator or an impasse)

Available compile flags (in kernel.h)

```c++
/* For information on the consistency check routines */
/* #define DEBUG_CONSISTENCY_CHECK */

/* For information on aspects of determining the active level */
/* #define DEBUG_DETERMINE_LEVEL_PHASE */
```

## Available kernel functions

**highest_active_goal_propose**: Find the highest goal of activity among the
current i-assertions and retractions

**highest_active_goal_apply**: Find the highest goal of activity among the
current i-assertions, o-assertions and retractions

**active_production_type_at_goal**: Returns IE_PRODS if i-assertions active,
otherwise PE_PRODS

**initialize_consistency_calculations_for_new_decision**: call before functions
below?

**determine_highest_active_production_level_in_stack_apply**: implements
waterfall for apply phase (DETERMINE_LEVEL_PHASE)

-   calls itself recursively
-   called in do_one_top_level_phase (APPLY_PHASE, twice)
-   if the next active goal
    is lower in the stack than the previous one, but the stack is no longer
    consistent up to the previous goal, then proceed to output

determine_highest_active_production_level_in_stack_propose: implements
waterfall for propose phase

-   called in do_one_top_level_phase (PROPOSE_PHASE, twice)

get_next_assertion (rete.cpp): gets next production/token/wme associated with
the current goal (as determined by above) do_working_memory_phase: "commits" the
changes at the end of a phase

## Implementation thoughts

In do_one_top_level_phase, currently do this:

1.  determine highest active goal
1.  fire rules at that goal
1.  commit changes
1.  proceed to next phase

Could change it to do this:

1.  determine highest active goal
1.  fire rules at that goal, tracking the highest goal with a change
1.  determine highest active goal below highest changed goal
1.  goto 2 until past bottom goal
1.  commit changes
1.  proceed to next phase

## Test Case

```Soar
# Test case for revised waterfall model
#
# In Soar8/9.0.0 waterfall model, the change*substate rule will never fire. This is because the
# change*top-state rule will fire first, which will cause the proposal to unmatch and thus the
# substate will retract
#
# In the revised waterfall model, change*substate will fire in parallel with change*top-state, since
# the effects cannot possibly conflict.

learn --off

sp {propose*test
(state  ^superstate nil
          -^result true)
-->
( ^operator  +)
( ^name test)
}

sp {change*top-state
(state  ^superstate )
( ^operator.name test)
-->
( ^result true)
(write (crlf) |Changed top-state|)
}

sp {change*substate
(state  ^superstate )
( ^operator.name test
      ^result true)
-->
( ^substate changed)
(write (crlf) |Changed substate|)
}
```

## Test case in jSoar

The file
`/jsoar/test/org/jsoar/kernel/FunctionalTests_testWaterJugLookAhead.soar` in the
jSoar project contains the above code plus a (succeeded) rhs call that works
with JUnit so that the test can succeed once the changes to the waterfall model
work.

### Notes

-   preference phase: the inner loop that processes assertions and retractions at
    the active level and possibly below with new waterfall model
-   matches: assertion/retraction, matches **AND** unmatches coming from the rete
-   active_level: the highest level at which matches are waiting to be processed
-   previous_active_level: the active_level at the start of the previous outer
    preference loop
-   change_level: lowest level affected by matches fired during previous iteration
    of inner preference loop, always equal to or higher than active_level, matches
    firing in next iteration cannot change this level or higher.
-   next_change_level: lowest level affected by matches fired during this
    iteration of inner preference loop, becomes change_level for next iteration
-   high_match_change_level: highest level affected by a match's changes, compares
    to change_level
-   low_match_change_level: lowest level affected by a match's changes, sets
    next_change_level

## Algorithm

This describes one outer preference loop.

1.  Reset '''active_level'''=0, '''next_change_level'''=0.
1.  Set '''active_level'''.
1.  Set '''previous_active_level''' = '''active_level'''
1.  Inner preference loop start:

    1.  If '''active_level''' is invalid, break out of loop.
    1.  Set '''change_level''' = '''next_change_level'''.
    1.  For each match at the '''active_level''':

        1.  Determine '''high_match_change_level''' and '''low_match_change_level'''
        (see execute_action).
        1.  If the '''high_match_change_level''' < '''change_level''':

            1.  Fire the match (and be sure match is removed from match lists).
            1.  Set '''next_change_level''' = min('''next_change_level''', '''low_match_change_level''')

        1.  Else if '''high_match_change_level''' >= '''change_level''':

            1.  Do not fire the match (and be sure match is retained in match lists).

    1.  Set '''active_level''' to next lowest level that has activity (matches)
    below the current '''active_level'''.
    1.  Go to inner preference loop start.

1.  Set '''active_level''' = '''previous_active_level'''
1.  Commit changes (do_working_memory_phase)

## Implementation Notes

-   done in initialize_consistency_calculations_for_new_decision
-   done in determine_highest_active_production_level_in_stack \_apply/propose
-   local variable in doApplyPhase, not yet implemented for propose
-   current handling of this (in the apply phase) is to set current_phase to
    Phase.OUTPUT. May need to actually check this though because we probably won't
    be changing current_phase in 4.4.

find out what level a match will change
possibly out of date

1.  Call create_instantiation on the assertion
1.  Determine the highest level of any action (as reported by execute_action)
(see solution above)
1.  If any action's level is higher than the safe active level
    1.  Don't create the instantiation (see below)
    1.  Put the assertion back on the assertions list where we got it from (the
       pointers should still be in the right places)
1.  For each retraction at this goal, do something similar to above

## Notes on only firing the assertion

create_instantiation is going to go through all of the actions, if we find
midway through that an action is bad, we throw out the entire instantiation.
This means execute_action needs to return this sort of failure code so that the
effects of get_next_assertion on the rete listener can be undone, which is
something like pushing the assertion back on to the list for the active goal.
There are multiple lists of assertions for each goal, we need to put it back on
the correct one.
