## stats

Print information on Soar's runtime statistics.

#### Synopsis

```
stats [options]
```

### Options

| **Option** | **Description** |
|:-----------|:----------------|
| `-m, --memory` | report usage for Soar's memory pools |
| `-l, --learning` | report statistics about rules learned via explanation-based chunking |
| `-r, --rete`   | report statistics about the rete structure |
| `-s, --system` | report the system (agent) statistics (default) |
| `-M, --max`    | report the per-cycle maximum statistics (decision cycle time, WM changes, production fires) |
| `-R, --reset`  | zero out the per-cycle maximum statistics reported by `--max` command |
| `-t, --track`  | begin tracking the per-cycle maximum statistics reported by `--max` for each cycle (instead of only the max value) |
| `-T, --stop-track` | stop and clear tracking of the per-cycle maximum statistics |
| `-c, --cycle`  | print out collected per-cycle maximum statistics saved by `--track` in human-readable form |
| `-C, --cycle-csv` | print out collected per-cycle maximum statistics saved by `--track` in comma-separated form |
| `-S, --sort N` | sort the tracked cycle stats by column number `N`, see table below |

#### --sort parameters:

| **Option** | **Description** |
|:-----------|:----------------|
| `0` | Use default sort |
| `1, -1` | Sort by decision cycle (use negative for descending) |
| `2, -2` | Sort by DC time (use negative for descending) |
| `3, -3` | Sort by WM changes (use negative for descending) |
| `4, -4` | Sort by production firings (use negative for descending) |

### Description

This command prints Soar internal statistics. The argument indicates the component of interest, `--system` is used by default.

With the `--system` flag, the stats command lists a summary of run statistics, including the following:

  * **Version** --- The Soar version number, hostname, and date of the run.
  * **Number of productions** --- The total number of productions loaded in the system, including all chunks built during problem solving and all default productions.
  * **Timing Information** --- Might be quite detailed depending on the flags set at compile time. See note on timers below.
  * **Decision Cycles** --- The total number of decision cycles in the run and the average time-per-decision-cycle in milliseconds.
  * **Elaboration cycles** --- The total number of elaboration cycles that were executed during the run, the average number of elaboration cycles per decision cycle, and the average time-per-elaboration-cycle in milliseconds. This is not the total number of production firings, as productions can fire in parallel.
  * **Production Firings** --- The total number of productions that were fired.
  * **Working Memory Changes** --- This is the total number of changes to working memory. This includes all additions and deletions from working memory. Also prints the average match time.
  * **Working Memory Size** --- This gives the current, mean and maximum number of working memory elements.

The stats argument `--memory` provides information about memory usage and Soar's memory pools, which are used to allocate space for the various data structures used in Soar.

The stats argument `--learning` provides information about rules learned through Soar's explanation-based chunking mechanism.  This is the same output that `chunk stats` provides.  For statistics about a specific rule learned, see the `explain` command.

The stats argument `--rete` provides information about node usage in the Rete net, the large data structure used for efficient matching in Soar.

The `--max` argument reports per-cycle maximum statistics for decision cycle time, working memory changes, and production fires. For example, if Soar runs for three cycles and there were 23 working memory changes in the first cycle, 42 in the second, and 15 in the third, the `--max` argument would report the highest of these values (42) and what decision cycle that it occurred in (2nd). Statistics about the time spent executing the decision cycle and number of productions fired are also collected and reported by `--max` in this manner. `--reset` zeros out these statistics so that new maximums can be recorded for future runs. The numbers are also zeroed out with a call to [init-soar](./cmd_init_soar.md).

The `--track` argument starts tracking the same stats as the `--max` argument but records all data for each cycle instead of the maximum values. This data can be printed using the `--cycle` or `--cycle-csv` arguments. When printing the data with `--cycle`, it may be sorted using the `--sort` argument and a column integer. Use negative numbers for descending sort. Issue `--stop-track` to reset and clear this data.

#### A Note on Timers

The current implementation of Soar uses a number of timers to provide time-based statistics for use in the stats command calculations. These timers are:

  * total CPU time
  * total kernel time
  * phase kernel time (per phase)
  * phase callbacks time (per phase)
  * input function time
  * output function time

Total CPU time is calculated from the time a decision cycle (or number of decision cycles) is initiated until stopped. Kernel time is the time spent in core Soar functions. In this case, kernel time is defined as the all functions other than the execution of callbacks and the input and output functions. The total kernel timer is only stopped for these functions. The phase timers (for the kernel and callbacks) track the execution time for individual phases of the decision cycle (i.e., input phase, preference phase, working memory phase, output phase, and decision phase). Because there is overhead associated with turning these timers on and off, the actual kernel time will always be greater than the derived kernel time (i.e., the sum of all the phase kernel timers). Similarly, the total CPU time will always be greater than the derived total (the sum of the other timers) because the overhead of turning these timers on and off is included in the total CPU time. In general, the times reported by the single timers should always be greater than than the corresponding derived time.  Additionally, as execution time increases, the difference between these two values will also increase. For those concerned about the performance cost of the timers, all the run time timing calculations can be compiled out of the code by defining `NO_TIMING_STUFF` (in `kernel.h`) before compilation.

### Examples

Track per-cycle stats then print them out using default sort:

```
stats --track
run
stop
stats --cycle
```

Print out per-cycle stats sorting by decision cycle time

```
stats --cycle --sort 2
```

Print out per-cycle stats sorting by firing counts, descending

```
stats --cycle --sort -4
```

Save per-cycle stats to file `stats.csv`

```
ctf stats.csv stats --cycle-csv
```

#### Default Aliases
```
st       stats
```
### See Also

[timers](./cmd_timers.md) 
[init-soar](./cmd_init_soar.md)
[command-to-file](./cmd_command_to_file.md)
