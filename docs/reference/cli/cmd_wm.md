## wm

Commands and settings related to working memory and working memory activation.  There are four sub-commands:  `add`, `remove`, `activation`, and `watch`.

#### Synopsis

```
=========================================================
-               WM Sub-Commands and Options             -
=========================================================
wm              [? | help]
---------------------------------------------------------
wm add          <id> [^]<attribute> <value> [+]
wm remove       <timetag>
---------------------------------------------------------
wm activation   --get <parameter>
                --set <parameter>                 <value>
                      activation             [ on | OFF ]
                      petrov-approx          [ on | OFF ]
                      forgetting             [ on | OFF ]
                      fake-forgetting        [ on | OFF ]
                      forget-wme                      all  [all, lti]
                      decay-rate                     -0.5  [0 to 1]
                      decay-thresh                     -2  [0 to infinity]
                      max-pow-cache                    10  MB
                      timers                          off  [off, one]
                --history <timetag>
                --stats                                    Print forget stats
                --timers [<timer>]                         Print timing results
                  <timer> = wma_forgetting or wma_history
---------------------------------------------------------
wm watch        --add-filter    --type <t>  pattern
                --remove-filter --type <t>  pattern
                --list-filter  [--type <t>]
                --reset-filter [--type <t>]
                              <t> = adds, removes or both
---------------------------------------------------------

For a detailed explanation of sub-commands:       help wm
```

### wm activation

The `wm activation` command changes the behavior of and displays information about working memory activation.

To get the activation of individual WMEs, use `print -i`. 
To get the reference history of an individual WME, use 
`wm activation -h|--history `<`timetag`>. For example:

```
print --internal s1
(4000016: S1 ^ct 1000000 [3.6])
(4: S1 ^epmem E1 [1])
(11: S1 ^io I1 [1])
(20: S1 ^max 1000000 [3.4])
(18: S1 ^name ct [3.4])
(4000018: S1 ^operator O1000001 [1] +)
(4000019: S1 ^operator O1000001 [1])
(3: S1 ^reward-link R1 [1])
(8: S1 ^smem S2 [1])
(2: S1 ^superstate nil [1])
(14: S1 ^top-state S1 [1])
(1: S1 ^type state [1])
```

The bracketed values are activation. To get the history of an individual element:

```
wm activation --history 18
history (60/5999999, first @ d1):
 6 @ d1000000 (-1)
 6 @ d999999 (-2)
 6 @ d999998 (-3)
 6 @ d999997 (-4)
 6 @ d999996 (-5)
 6 @ d999995 (-6)
 6 @ d999994 (-7)
 6 @ d999993 (-8)
 6 @ d999992 (-9)
 6 @ d999991 (-10)

considering WME for decay @ d1019615
```

This shows the last 60 references (of 5999999 in total, where the first occurred at decision cycle 1). For each reference, it says how many references occurred in the cycle (such as 6 at decision 1000000, which was one cycle ago at the time of executing this command). Note that references during the current cycle will not be reflected in this command (or computed activation value) until the end of output phase. If `forgetting` is `on`, this command will also display the cycle during which the WME will be considered for decay. Even if the WME is not referenced until then, this is not necessarily the cycle at which the WME will be forgotten. However, it is guaranteed that the WME will not be forgotten before this cycle.

#### Options:

| **Option** | **Description** |
|:-----------|:----------------|
| `-g, --get` | Print current parameter setting |
| `-s, --set` | Set parameter value             |
| `-S, --stats` | Print statistic summary or specific statistic |
| `-t, --timers` | Print timer summary or specific timer |
| `-h, --history` | Print reference history of a WME |

#### Parameters:

The `activation` command uses the `--get|--set <parameter> <value>` convention rather than individual switches for each parameter. Running `wm activation` without any switches displays a summary of the parameter settings.

| **Parameter** | **Description** | **Possible values** | **Default** |
|:--------------|:----------------|:--------------------|:------------|
| `activation`  | Enable working memory activation | `on`, `off`         | `off`       |
| `decay-rate`  | WME decay factor | `[`0, 1`]`          | 0.5         |
| `decay-thresh` | Forgetting threshold | `(`0, inf`)`        | 2.0         |
| `forgetting`  | Enable removal of WMEs with low activation values | `on`, `off`         | `off`       |
| `forget-wme`  | If `lti` only remove WMEs with a long-term id | `all`, `lti`        | `all`       |
| `max-pow-cache` | Maximum size, in MB, for the internal `pow` cache | 1, 2, ...           | 10          |
| `petrov-approx` | Enables the (Petrov 2006) long-tail approximation | `on`, `off`         | `off`       |
| `timers`      | Timer granularity | `off`, `one`        | `off`       |

The `decay-rate` and `decay-thresh` parameters are entered as positive decimals, but are internally converted to, and printed out as, negative.

The `petrov-approx` may provide additional validity to the activation value, but comes at a significant computational cost, as the model includes unbounded positive exponential computations, which cannot be reasonably cached.

When `activation` is enabled, the system produces a cache of results of calls to the `pow` function, as these can be expensive during runtime. The size of the cache is based upon three run-time parameters (`decay-rate`, `decay-thresh`, and `max-pow-cache`), and one compile time parameter, `WMA_REFERENCES_PER_DECISION` (default value of 50), which estimates the maximum number of times a WME will be referenced during a decision. The cache is composed of `double` variables (i.e. 64-bits, currently) and the number of cache items is computed as follows:

e^((decay\_thresh - ln(max\_refs)) / decay\_rate)

With the current default parameter values, this will incur about 1.04MB of memory. Holding the `decay-rate` constant, reasonable changes to `decay-thresh` (i.e. +/- 5) does not greatly change this value. However, small changes to `decay-rate` will dramatically change this profile. For instance, keeping everything else constant, a `decay-thresh` of 0.3 requires ~2.7GB and 0.2 requires ~50TB. Thus, the `max-pow-cache` parameter serves to allow you to control the space vs. time tradeoff by capping the maximum amount of memory used by this cache. If `max-pow-cache` is much smaller than the result of the equation above, you may experience somewhat degraded performance due to relatively frequent system calls to `pow`.

If `forget-wme` is `lti` and `forgetting` is `on`, only those WMEs whose id is a long-term identifier **at the decision of forgetting** will be removed from working memory. If, for instance, the id is stored to semantic memory after the decision of forgetting, the WME will not be removed till some time after the next WME reference (such as testing/creation by a rule).

#### Statistics

Working memory activation tracks statistics over the lifetime of the agent. These can be accessed using `wm activation --stats <statistic>`. 
Running `wm activation --stats` without a statistic will list the values of all statistics.  Unlike timers, statistics will always be updated.

Available statistics are:

| **Name** | **Label** | **Description** |
|:---------|:----------|:----------------|
| `forgotten-wmes` | Forgotten WMEs | Number of WMEs removed from working memory due to forgetting |

#### Timers

Working memory activation also has a set of internal timers that record the durations of certain operations. Because fine-grained timing can incur runtime costs, working memory activation timers are off by default. Timers of different levels of detail can be turned on by issuing `wm activation --set timers <level>`, where the levels can be `off` or `one`, `one` being most detailed and resulting in all timers being turned on. Note that none of the working memory activation statistics nor timing information is reported by the `stats` command.

All timer values are reported in seconds.

Timer Levels:

| **Option** | **Description** |
|:-----------|:----------------|
| `wma_forgetting` | Time to process forgetting operations each cycle |
| `wma_history`    | Time to consolidate reference histories each cycle |

***

### wm add

Manually add an element to working memory.

```
wm add id [^]attribute value [+]
```

#### Options:

| **Option** | **Description** |
|:-----------|:----------------|
| `id` | Must be an existing identifier. |
| `^`  | Leading `^` on attribute is optional. |
| `attribute` | Attribute can be any Soar symbol. Use `*` to have Soar create a new identifier. |
| `value` | Value can be any soar symbol. Use `*` to have Soar create a new identifier. |
| `+`  | If the optional preference is specified, its value must be `+` (acceptable). |

#### Description

Manually add an element to working memory. `wm add` is often used by an input function to update Soar's information about the state of the external world.

`wm add` adds a new wme with the given id, attribute, value and optional preference. The given id must be an existing identifier. The attribute and value fields can be any Soar symbol. If `*` is given in the attribute or value field, Soar creates a new identifier (symbol) for that field. If the preference is given, it can only have the value `+` to indicate that an acceptable preference should be created for this WME.

Note that because the id must already exist in working memory, the WME that you are adding will be attached (directly or indirectly) to the top-level state. As with other WME's, any WME added via a call to add-wme will automatically be removed from working memory once it is no longer attached to the top-level state.

#### Examples

This example adds the attribute/value pair `^message-status received` to the identifier (symbol) S1:

```
wm add S1 ^message-status received
```

This example adds an attribute/value pair with an acceptable preference to the identifier (symbol) Z2. The attribute is `message` and the value is a unique identifier generated by Soar. Note that since the `^` is optional, it has been left off in this case.

```
wm add Z2 message * +
```

#### Warnings

Be careful how you use this command. It may have weird side effects (possibly even including system crashes). For example, the chunking mechanism can't backtrace through WMEs created via `wm add` nor will such WMEs ever be removed through Soar's garbage collection. Manually removing context/impasse WMEs may have unexpected side effects.

***

### wm remove

Manually remove an element from working memory.

```
wm remove timetag
```
#### Options:

| **Option** | **Description** |
|:-----------|:----------------|
| `timetag` | A positive integer matching the timetag of an existing working memory element. |

#### Description

The `wm remove` command removes the working memory element with the given timetag. This command is provided primarily for use in Soar input functions; although there is no programming enforcement, wm remove should only be called from registered input functions to delete working memory elements on Soar's input link.

Beware of weird side effects, including system crashes.

#### Warnings

`wm remove` should never be called from the RHS of a production: if you try to match a WME on the LHS of a production, and then remove the matched WME on the RHS, Soar will crash.

If used other than by input and output functions interfaced with Soar, this command may have weird side effects (possibly even including system crashes). Removing input WMEs or context/impasse WMEs may have unexpected side effects. You've been warned.

***

### wm watch

Print information about WMEs matching a certain pattern as they are added and removed.

```
wm watch -[a|r]  -t <type>  >pattern>
wm watch -[l|R] [-t <type>]
```

#### Options:

| **Option** | **Description** |
|:-----------|:----------------|
| `-a, --add-filter` | Add a filter to print wmes that meet the type and pattern criteria. |
| `-r, --remove-filter` | Delete filters for printing wmes that match the type and pattern criteria. |
| `-l, --list-filter` | List the filters of this type currently in use. Does not use the pattern argument. |
| `-R, --reset-filter` | Delete all filters of this type. Does not use pattern arg.          |
| `-t, --type`       | Follow with a type of wme filter, see below.                        |

#### Watch Patterns:

The pattern is an id-attribute-value triplet:

```
id attribute value
```

Note that `*` can be used in place of the id, attribute or value as a wildcard that matches any string. Note that braces are not used anymore.

#### Watch Types

When using the -t flag, it must be followed by one of the following:

| **Option** | **Description** |
|:-----------|:----------------|
| `adds` | Print info when a wme is `added`. |
| `removes` | Print info when a wme is `retracted`. |
| `both` | Print info when a wme is added `or` retracted. |

When issuing a `-R` or `-l`, the `-t` flag is optional. Its absence is equivalent to `-t both`.

#### Description

This commands allows users to improve state tracing by issuing filter-options that are applied when watching WMEs. Users can selectively define which 
`object-attribute-value` triplets are monitored and whether they are monitored for addition, removal or both, as they go in and out of working memory. 

#### Examples

Users can watch an `attribute` of a particular object (as long as that object already exists):

```
soar> wm watch --add-filter -t both D1 speed *
```

or print WMEs that retract in a specific state (provided the `state` already exists):

```
soar> wm watch --add-filter -t removes S3 * *
```

or watch any relationship between objects:

```
soar> wm watch --add-filter -t both * ontop *
```

***

### Default Aliases
```
add-wme       wm add
aw            wm add
remove-wme    wm remove
rw            wm remove
watch-wmes    wm watch
wma           wm activation
```
### See Also

[print](./cmd_print.md) 
[trace](./cmd_trace.md)
