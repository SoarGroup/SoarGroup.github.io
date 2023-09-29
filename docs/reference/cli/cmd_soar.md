## soar

Commands and settings related to running Soar

#### Synopsis

```
======= Soar General Commands and Settings =======
soar ?                                                 Print this help listing
soar init                                              Re-initializes Soar
soar stop [--self]                                     Stop Soar execution
soar version                                           Print version number
------------------- Settings ----------------------
keep-all-top-oprefs                    [ on | OFF ]    Keep prefs for o-supported WMEs in top-state
max-elaborations                                100    Max elaborations per decision cycle
max-goal-depth                                   23    Halt at this goal stack depth
max-nil-output-cycles                            15    Impasse after this many nil outputs
max-dc-time                                       0    Interrupt after this much time
max-memory-usage                          100000000    Threshold for memory warning
max-gp                                        20000    Max rules gp can generate
stop-phase   [input|proposal|decision|APPLY|output]    Phase before which Soar will stop
tcl                                    [ on | OFF ]    Allow Tcl code in commands
timers                                 [ ON | off ]    Profile Soar
wait-snc                               [ on | OFF ]    Wait instead of impasse
-----------------------------------------------
To change a setting:                                   soar <setting> [<value>]
For a detailed explanation of these settings:          help soar
```
### Summary View

Using the `soar` command without any arguments will display a summary of Soar's current state of execution and which capabilities of Soar are enabled:
```
=======================================================
                     Soar 9.6.0 Summary
=======================================================
Enabled:                                           Core
Disabled:                EBC, SMem, EpMem, SVS, RL, WMA
-------------------------------------------------------
Number of rules:                                     52
Decisions                                            20
Elaborations                                         61
-------------------------------------------------------
State stack                        S1, S21 ... S29, S33
Current number of states                              5
Next phase                                        apply
-------------------------------------------------------
```

****
To enable a particular capability of Soar, see the corresponding documentation for that component.

### soar init

The `init` command re-initializes Soar. It removes all elements from working memory, wiping out the goal stack, and resets all runtime statistics. The firing counts for all productions are reset to zero. The `soar init` command
allows a Soar program that has been halted to be reset and start its execution from the beginning.

`soar init` does not remove any productions from production memory; to do this, use the [production excise](./cmd_production.md) command. Note, however, that all justifications will be removed because they will no longer be supported.

### soar stop

```
soar stop [--self]
```

The `soar stop` command stops any running Soar agents. It sets a flag in the Soar kernel so that Soar will stop running at a "safe" point and return control to the user.  The `--self` option will stop only the soar agent where the command is issued. All other agents continue running as previously specified.

This command is usually not issued at the command line prompt - a more common use of this command would be, for instance, as a side-effect of pressing a button on a Graphical User Interface (GUI).

Note that if a graphical interface doesn't periodically do an "update"/flush the pending I/O, then it may not be possible to interrupt a Soar agent from the command line.

### soar version

This command prints the version of Soar to the screen.

****

### Settings

Invoke a sub-command with no arguments to query the current setting. 
Partial commands are accepted.

| **Option** | **Valid Values** | **Default** |
|:-----------|:-----------------|:------------|
| `keep-all-top-oprefs` | on or off | off |
| `max-dc-time` | >= 0 | 0 |
| `max-elaborations` | > 0 | 100 |
| `max-goal-depth` | > 0 | 23 |
| `max-gp` | > 0 | 20000 |
| `max-memory-usage` | > 0 | 100000000 |
| `max-nil-output-cycles` | > 0 | 15 |
| `stop-phase` | <phase> | apply |
| `tcl` | on or off | off |
| `timers` | on or off | on |
| `wait-snc` | >= 1 | 1 |

#### soar keep-all-top-oprefs

Enabling `keep-all-top-oprefs` turns off an optimization that reduces memory usage by discarding any internal preferences for WMEs that already have top-level o-support. Turning this setting off allows those preferences to be examined during debugging.

#### soar max-dc-time

`max-dc-time` sets a maximum amount of time a decision cycle is permitted. After output phase, the elapsed decision cycle time is checked to see if it is greater than the old maximum, and the maximum dc time stat is updated 
(see [stats](./cmd_stats.md)). At this time, this threshold is also checked. If met or exceeded, Soar stops at the end of the current output phase with an interrupted state.

#### soar max-elaborations

`max-elaborations` sets and prints the maximum number of elaboration cycles allowed in a single decision cycle. 

If `n` is given, it must be a positive integer and is used to reset the number of allowed elaboration cycles. The default value is 100. max-elaborations with no arguments prints the current value.

The elaboration phase will end after `max-elaboration` cycles have completed, even if there are more productions eligible to fire or retract; and Soar will proceed to the next phase after a warning message is printed to notify the user. This limits the total number of cycles of parallel production firing but does not limit the total number of productions that can fire during elaboration.

This limit is included in Soar to prevent getting stuck in infinite loops (such as a production that repeatedly fires in one elaboration cycle and retracts in the next); if you see the warning message, it may be a signal that you have a bug your code. However some Soar programs are designed to require a large number of elaboration cycles, so rather than a bug, you may need to increase the value of `max-elaborations`.

`max-elaborations` is checked during both the Propose Phase and the Apply Phase. If Soar runs more than the max-elaborations limit in either of these phases, Soar proceeds to the next phase (either Decision or Output) even if quiescence has not been reached.

#### soar max-goal-depth

The `max-goal-depth` command is used to limit the maximum depth of sub-states that an agent can subgoal to. The initial value of this variable is 100; allowable settings are any integer greater than 0. This limit is also included in Soar to prevent getting stuck in an infinite recursive loop, which may come about due to deliberate actions or via an agent bug, such as dropping inadvertently to state-no-change impasses.

#### soar max-gp

`max-gp` is used to limit the number of productions produced by a gp command. It is easy to write a gp rule that has a combinatorial explosion and hangs for a long time while those productions are added to memory. The `max-gp` setting bounds this.

#### soar max-memory-usage

The `max-memory-usage` setting is used to trigger the memory usage exceeded event. The initial value of this is 100MB (100,000,000); allowable settings are any integer greater than 0. 

NOTE: The code supporting this event is not enabled by default because the test can be computationally expensive and is needed only for specific embedded applications. Users may enable the test and event generation by uncommenting code in `mem.cpp`.

#### soar max-nil-output-cycles

`max-nil-output-cycles` sets and prints the maximum number of nil output cycles (output cycles that put nothing on the output link) allowed when [running](./cmd_run.md) using run-til-output (`run --output`). If `n` is not given, this command prints the current number of nil-output-cycles allowed. If `n` is given, it must be a positive integer and is used to reset the maximum number of allowed nil output cycles.

`max-nil-output-cycles` controls the maximum number of output cycles that generate no output allowed when a `run --out` command is issued. After this limit has been reached, Soar stops. The default initial setting of `n` is 15.

#### soar stop-phase

`stop-phase` allows the user to control which phase Soar stops in. When running by decision cycle it can be helpful to have agents stop at a particular point in its execution cycle.  The precise definition is that "running for _n_ decisions and stopping before phase _ph_ means to run until the decision cycle counter has increased by _n_ and then stop when the next phase is _ph_". The phase sequence (as of this writing) is: input, proposal, decision, apply,
output. Stopping after one phase is exactly equivalent to stopping before the next phase.

#### soar tcl

Enabling the `tcl` setting augments Soar's prompt with Tcl scripting capabilities. In other words, it provides the ability to run Tcl code from any Soar command line by passing all Soar commands first through a Tcl interpreter for processing. (Each agent has its own Tcl interpreter.)

This command provides Tcl capabilities to both local and remote clients, including the java-based debugger.  It processes Tcl commands in both the Soar command line and any files sourced. Productions can make Tcl calls by writing `(exec tcl  | <Tcl code> |)` clauses on the RHS of rules.  Soar symbols and variables can be included in RHS item.

Important Notes:

- If you source a file that turns tcl on, you cannot use any Tcl code until the source command returns. 

  If you'd like to have Tcl turned on automatically when Soar launches, add the `soar tcl on` command to your settings.soar file in the main Soar directory. This activates Tcl mode on initial launch, allowing you to immediately source files that use Tcl code.

- `soar tcl off` is currently not supported due to memory issues.

- Only one RHS Tcl call will produce output.

  Soar rhs commands `write` (and even something like `echo`) will always work.  But for Tcl commands that produce output, for example, a 'puts' command or a custom Tcl proc that produces output as a side effect, only the last one will display output. Note that all rhs Tcl calls do get executed, so they will do what they are supposed to do, including perhaps writing output to a file.  The print output just doesn’t get redirected to the right place, despite being produced. As a workaround, a user can make sure that there is only one Tcl call which needs to produce output and that it comes after any other Tcl RHS actions.

- Does not support Tk code.  Tk is a widget toolkit that many Tcl programs use to provide a GUI, for example, the old Soar TSI debugger.

- Tcl code that tries to do low-level Soar SML calls may or may not work.Creating and deleting a kernel will certainly not work.  But other things like creating an agent may work fine.  This caveat is inherent to the design of Tcl as a plug-in without a main event loop.

- Third-party Tcl code that requires a Tcl event loop may or may not work, for example, the Tcl `after` command. 

#### soar timers

This setting is used to control the timers that collect internal profiling information while Soar is running. With no arguments, this command prints out the current timer status. Timers are ENABLED by default. The default compilation flags for soar enable the basic timers and disable the detailed timers. The timers command can only enable or disable timers that have already been enabled with compiler directives. See the [stats](./cmd_stats.md) command for more info on the Soar timing system.

#### soar wait-snc

`wait-snc` controls an architectural wait state. On some systems, especially those that model expert knowledge, a state-no-change may represent a _wait state_ rather than an impasse. The waitsnc command allows the user to switch to a mode where a state-no-change that would normally generate an impasse (and subgoaling), instead generates a _wait_ state. At a _wait_ state, the decision cycle will repeat (and the decision cycle count is incremented) but no _state-no-change_ impasse (and therefore no substate) will be generated.

****

### Examples

```
soar init
soar stop -s
soar timers off
soar stop-phase output                 // stop before output phase
soar max-goal-depth 100
soar max-elaborations
```

### Default Aliases
```
init                             soar init
is                               soar init
init-soar                        soar init
interrupt                        soar stop
ss                               soar stop
stop                             soar stop
stop-soar                        soar stop
gp-max                           soar max-gp
max-dc-time                      soar max-dc-time 
max-elaborations                 soar max-elaborations
max-goal-depth                   soar max-goal-depth
max-memory-usage                 soar max-memory-usage
max-nil-output-cycles            soar max-nil-output-cycles 
set-stop-phase                   soar stop-phase
timers                           soar timers
version                          soar version
waitsnc                          soar wait-snc
```

### See Also

[production excise](./cmd_production.md)
[run](./cmd_run.md)
[stats](./cmd_stats.md)
