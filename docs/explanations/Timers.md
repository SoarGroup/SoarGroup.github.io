---
date: 2014-10-07
authors:
    - soar
tags:
    - kernel programming
---

<!-- markdown-link-check-disable-next-line -->
<!-- old URL: https://soar.eecs.umich.edu/articles/articles/technical-documentation/206-timers -->

# Timers

This document describes how Soar's internal timers work.

## Preprocessor Symbols

Core/SoarKernel/src/kernel.h contains a few relevant preprocessor symbols:

- `NO_TIMING_STUFF`: Defining this symbol removes most timer code from the kernel.
    The stats command output will be much shorter as well, as it will not include
    timing statistics.
- `DETAILED_TIMING_STATS`: Only valid when `NO_TIMING_STUFF`
    is not defined. Defining this turns on more timers for more detailed stats for
    things like chunking and GDS. Compiling out timer code can result in much
    faster runs. Timers are compiled-in by default, but not detailed timing stats.

## Stats Output

Some more information regarding the stats command.

| stats                                            | Output agent struct                          | Detailed | Description                                                                                |
| ------------------------------------------------ | -------------------------------------------- | -------- | ------------------------------------------------------------------------------------------ |
| Total CPU Time                                   | timers_total_cpu_time                        | No       | Most encompassing, includes some scheduling code and all callbacks.                        |
| Kernel CPU Time                                  | timers_total_kernel_time                     | No       | Total CPU minus callbacks and a few other smaller things.                                  |
| Kernel / Phase (table)                           | timers_decision_cycle_phase[NUM_PHASE_TYPES] | No       | Time spent in each phase but not in callbacks.                                             |
| Callbcks / Phase (table)                         | timers_monitors_cpu_time[NUM_PHASE_TYPES]    | No       | Time spent in callbacks for each phase, but notINPUT_PHASE_CALLBACK or output functions.   |
| Input fn (table)                                 | timers_input_function_cpu_time               | No       | Time spent in INPUT_PHASE_CALLBACK.                                                        |
| Outpt fn (table)                                 | timers_output_function_cpu_time              | No       | Time spent in output functions.                                                            |
| stats --max                                      | timers_decision_cycle, max_dc_time_msec      | No       | Used to collect max per-cycle statistics. Essentially a sum of timers_decision_cycle_phase |
| sml_Names::kParamStatsOwnershipTime...(XML only) | timers_ownership_cpu_time                    | Yes      | Time spent in do_buffered_link_changes. Included in the decision cycle phase timers.       |
| sml_Names::kParamStatsChunkingTime...(XML only)  | timers_chunking_cpu_time                     | Yes      | Time spent chunking. Included in decision cycle phase timers.                              |
| sml_Names::kParamStatsMatchTime...(XML only)     | timers_match_cpu_time                        | Yes      | Time spent adding/removing WMEs to/from rete. Included in decision cycle phase timers.     |
| sml_Names::kParamStatsGDSTime... (XML only)      | timers_gds_cpu_time                          | Yes      | Time spent in the GDS code. Included in the decision cycle phase timers.                   |

## Timers Command

There is a timers command to enable/disable timers at run-time. This should
result in a performance improvement but not as much as compiling out the timers
completely by defining `NO_TIMING_STUFF` in kernel.h.

### Timer Implementation

The timers are currently implemented using the STLSoft library. The STLSoft code
is wrapped in another layer in Core/shared/misc.h which define
`soar_wallclock_timer` and `soar_process_timer`. Here are the comments from that
file:

Code:

```c++
// Instantiate soar_wallclock_timer or soar_process_timer objects to measure
// "wall" (real) time or process (cpu) time. Call reset if you are unsure of
// the timer's state and want to make sure it is stopped. Call start and then
// stop to deliniate a timed period, and then call get_usec to get the value
// of that period's length, in microseconds. It is OK to call get_usec after
// calling start again. Resolution varies by platform, and may be in the
// millisecond range on some.
//
// Use soar_timer_accumulator to rack up multiple timer periods. Instead of
// calling get_usec on the timer, simply pass the timer to a
// soar_timer_accumulator instance with it's update call. Use reset to clear
// the accumulated time.

// Platform-specific inclusions and typedefs
//
// The STLSoft timers used in the kernel have platform-specific namespaces
// even though they share very similar interfaces. The typedefs here
// simplify the classes below by removing those namespaces.
//
// We are using two different types of timers from STLSoft,
// performance_counter and processtimes_counter. The performance timer is
// a high-performance wall-clock timer. The processtimes_counter is a cpu-
// time timer. Keep in mind that as of 11/2010 the resolution of process-time
// counters on windows is 16 milliseconds.
```

## Simple Usage

```c++
soar_process_timer timer;
soar_timer_accumulator stat;
...
timer.reset(); // initialize/reset
stat.reset();  // initialize/reset
...
timer.start();
// do stuff that takes time
timer.stop();
stat.update(timer); // read the timer, add elapsed to stat
...
stat.get_sec(); // total time accumulated with update();
```

## Increasing Resolution

By default, the`soar_process_timer` uses an STLSoft interface called
`processtimes_counter`. This is fine on most systems, but has a somewhat
unacceptable 16 millisecond resolution on Windows platforms. The other kind of
timer available is performance_counter which is used by the `soar_wall`
`clock_timer`. This counter has higher resolution but the timer itself takes
more time to execute (on most systems). To increase resolution on Windows
system, uncomment the symbol `USE_PERFORMANCE_FOR_BOTH` in
Core/shared/misc.h so that`soar_process_timer` uses the performance_counter.
Note that this higher-resolution timer is measuring things in different way than
the process times_counter and the results should probably not be compared.

## Old Stats Comments in Kernel

```c++
/*
For Soar 7, the timing code has been completely revamped.  When the compile
flag NO_TIMING_STUFF is not set, statistics will be now be collected on the
total cpu time, total kernel time, time spent in the individual phases of a
decision cycle, time spent executing the input and output functions, and time
spent executing callbacks (or monitors).  When the DETAILED_TIMING_STATS flag
is set, additional statistics will be collected for ownership, match, and
chunking computations according to the phase in which they occur. (Notice
that DETAILED_TIMING_STATS can only be collected when NO_TIMING_STUFF is not
true.)

The total_cpu_time is turned on when one of the run_<x> functions is
initiated.  This timer is not turned off while the do_one_top_level_phase()
function is executing.  The total_kernel_time timer is turned on just after
the total_cpu_time timer and turned off just before the other is turned off.
This guarantees that the total kernel time -- including the time it takes to
turn on and off the kernel timer -- is a part of the total cpu time.  The
total_kernel_time is also turned off whenever a callback is initiated or when
the input and output functions are executing.

The decision_cycle_phase_timers measure the kernel time for each phase of the
decision cycle (ie, INPUT_PHASE, PREFERENCE_PHASE, WM_PHASE, OUTPUT_PHASE,
and DECISION_PHASE).  Each is turned on at the beginning of its corresponding
phase in do_one_top_level_phase and turned off at the end of that phase.
These timers are also turned off for callbacks and during the execution of
the input and output functions.

The monitors_cpu_time timers are also indexed by the current phase.  Whenever
a callback is initiated, both the total_kernel_time and
decision_cycle_phase_timer for the current phase are turned off and the
monitors_cpu_time turned on.  After the callback has terminated, the kernel
timers are turned back on.  Notice that the same relationship holds here as
it did between the total_cpu_time and total_kernel_time timers.  The
total_kernel_time is always turned off last and turned on first, in
comparison to the decision_cycle_phase_timer.  This means that turning the
decision_cycle_phase_timers on and off is included as part of the kernel time
and helps ensure that the total_kernel_time is always greater than the sum of
the decision_cycle_timers.

The input_function_cpu_time and output_function_cpu_time timers measure the
time it takes to execute the input and output functions respectively.  Both
the total_kernel_time and decision_cycle_phase_timers are turned off when
these timers are turned on (with the same ordering as discussed previously).
The input function is a little tricky.  Because add-wme can be called by the
input routine, which then calls do_buffered_wm_and_ownership_changes, we
can't just turn off the kernel timers for input and expect to get numbers for
both match_time (see next para) and kernel time.  The solution implemented in
the 28.07.96 changes is to not turn off the kernel timers until the actual
INPUT_PHASE_CALLBACK is initiated.  This takes care of all but direct
additions and removals of WMEs.  Since these are done through the add-wme and
remove-wme commands, the input_timer is turned off there was well, and the
kernel timers turned back on (for the buffered wm changes).  However, this is
a hack and may introduce problems when add-wme and remove-wme are used at the
command line or someplace in the decision cycle other than input (probably
rare but possible).

The DETAILED_TIMING_STATS flag enables collection of statistics on match,
ownership and chunking calculations performed in each part of the decision
cycle.  An 'other' value is reported which is simply the difference between
the sum of the detailed timers and the kernel timer for some phase.  The other
value should always be greater than or equal to zero.

The "stats" command (in soarCommandUtils) has been updated to report these
new timing values.  The output is provided in a spreadsheet-style format to
display the information in a succinct form.  There are also some derived
totals in that report.  The derived totals in the right column are simply the
sum of the all the other columns in a particular row; for example, the
derived total for the first row, kernel time, is just the sum of all the
decision_cycle_phase_timers.  The derived totals in the bottom row are the
sum of all the basic timers in that row (i.e., no DETAILED statistics are
included in the sum).  For example, the derived total under input is equal to
the sum of decision_cycle_phase_timer and the monitors_time for the
INPUT_PHASE, and the input_function_cpu_time and represents the total time
spent in the input phase for the current run.  The number in the lower
right-hand corner is the sum of the derived totals above it in that right
column (and should always be equal to the numbers to the left of it in that
row).

Also reported with the stats command are the values of total_cpu_time and
total_kernel_time.  If the ordering discussed above is strictly enforced,
total_kernel_time should always be slightly greater than the derived total
kernel time and total_cpu_time greater than the derived total CPU time. REW */
```
