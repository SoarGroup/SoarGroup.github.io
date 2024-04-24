---
date: 2014-10-07
authors:
  - soar
tags:
  - io
  - event
  - sml
---

<!-- old URL: https://soar.eecs.umich.edu/articles/articles/soar-markup-language-sml/202-sml-output-link-guide -->

# SML Output Link Guide

General Advice: Read the output link after the agent's output phase but before
the next decision cycle's input phase.

This is usually accomplished by registering for an event that fires in this
range and reading the output link in there.

Exercise care if you save commands (or other working memory elements on the
output-link) to use later and return control back to Soar.

Working memory elements can be removed by the Soar agent and freed by SML.
Referring to them (to add, say ^status complete) will cause a segmentation
fault.

Be careful not to dereference working memory elements you have disconnected with
`DestroyWME`.

Destroyed pointers are freed by SML and will cause a segmentation fault if used.

## Events During Which Output May Be Read

Recommended: Register for the Update event `smlEVENT_AFTER_ALL_OUTPUT_PHASES`.

Run Events (agent-specific):

```
# Register using Agent::RegisterForRunEvent
smlEVENT_AFTER_OUTPUT_PHASE   # All three of these are essentially equivalent
smlEVENT_AFTER_DECISION_PHASE
smlEVENT_AFTER_DECISION_CYCLE
```

Update Events:

```
# Register using Kernel::RegisterForUpdateEvent
smlEVENT_AFTER_ALL_OUTPUT_PHASES    # Fires after all agents' output phases are done
smlEVENT_AFTER_ALL_GENERATED_OUTPUT # Fires as above but only after all agents also have output or reached max-nil-output-cycles
```

## Reading the Output Link

There are a number of different ways to read information from the output link,
each with pros and cons. Choose whichever method seems easiest to you.

Examine In Detail

- Use `GetOutputLink`, `GetNumberChildren`, `GetChild`, and other similar
  methods to examine working memory in its raw state.
- Can't use `IsJustAdded` and `AreChildrenModified` - these require
  `SetTrackOutputLinkChanges` true

Advantages:

- Most flexible.
- Can disable change tracking `Agent::SetTrackOutputLinkChanges(false)`

Disadvantages:

- Most verbose.

## Command Interface

Use Commands, `GetCommand`, and `GetParamValue` to get top level WMEs that have been
added since the last cycle.

This method is closest to the original SGIO and should be sufficient for most
cases. "Commands" used in this context refer to identifier WMEs on the top-level
of the output link. "Parameters" refer to valued attributes that are children of
a top-level command (identifier).

Advantages:

- Easiest.

Disadvantages:

- Do not save identifiers and return control back to Soar - they could be deleted.
- Not good for commands that span multiple decision cycles, retained so that
  `^status` complete can be added.
- Must follow "command" format: top level identifier.

```Soar
# "Command" format
<s> ^io.output-link <ol>
<ol> ^move <c>            # Command name "move"
<c> ^direction north      # Parameter "direction"

# Not "Command" format
<s> ^io.output-link <ol>
<ol> ^move north
```

## Changes Interface

Use `GetNumberOutputLinkChanges`, `GetOutputLinkChange`, and `IsOutputLinkChangeAdd`
to get the list of all WMEs added and removed since the last decision cycle.

All WMEs count as an output link change.

Advantages:

- Full access to output link.
- Output link removals can be detected using `IsOutputLinkChangeAdd() == false`
- Great for commands that can span multiple decision cycles because of removal
  notification.

Disadvantages:

- Need to parse changes to figure out what's attached to what.

```Soar
# This structure:
<s> ^io.output-link <ol>
<ol> ^move <c>            # Command name "move"
<c> ^direction north      # Parameter "direction"

# ... generates these two separate changes:
(I3 ^move M1)
(M1 ^direction north)
```

## Output Handler

Use `AddOutputHandler` to register functions that are called when a specific
attributes are added to the output link.

Here you specify specific attributes that fire events when added.

Advantages:

- Other update events do not need to be registered (such as smlEVENT_AFTER_ALL_OUTPUT_PHASES)
- Event handling model, can be very clear.

Disadvantages:

- Full command set needs to be known before hand (only get events when
  identifiers with registered attributes are added to the output link).
- Do not save identifiers and return control back to Soar--they could be
  deleted.
- Not good for commands that span multiple decision cycles, retained so that
  `^status` complete can be added.
- Must follow "command" format: top level identifier. See Command Interface
  above.

## IO Without Event Handlers

**Not recommended.** Reading the output link without event registration is
possible. Generalized steps for this are:

1. Set the stop phase to before-input.
1. Call `RunTillOutput` or Run (one step only - multiple steps will lose tracked
   changes).
1. Read the output link.
