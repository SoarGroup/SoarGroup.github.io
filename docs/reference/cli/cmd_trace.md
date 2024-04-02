# trace

Control the run-time tracing of Soar.

## Synopsis

```bash
============================================================
                    Soar Trace Messages
============================================================
------------------------- Level 1 --------------------------
Operator decisions and states                             on     -d
------------------------- Level 2 --------------------------
Phases                                                   off     -p
State removals caused by GDS violation                   off     -g
------------------ Level 3: Rule firings -------------------
Default rules                                            off     -D
User rules                                               off     -u
Chunks                                                   off     -c
Justifications                                           off     -j
Templates                                                off     -T
Firings inhibited by higher-level firings                off     -W
------------------------- Level 4 --------------------------
WME additions and removals                               off     -w
------------------------- Level 5 --------------------------
Preferences                                              off     -r
---------------- Additional Trace Messages -----------------
Chunking dependency analysis                             off     -b
Goal dependency set changes                              off     -G
Episodic memory recording and queries                    off     -e
Numeric preference calculations                          off     -i
Learning Level                                           off     -L 0-2
Reinforcement learning value updates                     off     -R
Semantic memory additions                                off     -s
Working memory activation and forgetting                 off     -a

WME Detail Level                                        none     -n, -t, -f
```

## Trace Levels

```bash
trace 0-5
```

Use of the `--level` (`-l`) flag is optional but recommended.

| **Option** | **Description**                                                                      |
| :--------- | :----------------------------------------------------------------------------------- |
| `0`        | trace nothing; equivalent to `-N`                                                    |
| `1`        | trace decisions; equivalent to `-d`                                                  |
| `2`        | trace phases, gds, and decisions; equivalent to `-dpg`                               |
| `3`        | trace productions, phases, and decisions; equivalent to `-dpgP`                      |
| `4`        | trace wmes, productions, phases, and decisions; equivalent to `-dpgPw`               |
| `5`        | trace preferences, wmes, productions, phases, and decisions; equivalent to `-dpgPwr` |

It is important to note that trace level `0` turns off ALL trace options,
including backtracing, indifferent selection and learning. However, the other
trace levels do not change these settings. That is, if any of these settings is
changed from its default, it will retain its new setting until it is either
explicitly changed again or the trace level is set to `0`.

### Options

```bash
trace [options]
```

| **Option Flag**               | **Argument to Option**                | **Description**                                                                                                               |
| :---------------------------- | :------------------------------------ | :---------------------------------------------------------------------------------------------------------------------------- |
| `-l, --level`                 | `0` to `5` (see _Trace Levels_ below) | This flag is optional but recommended. Set a specific trace level using an integer `0` to `5`, this is an inclusive operation |
| `-N, --none`                  | No argument                           | Turns off all printing about Soar's internals, equivalent to `--level 0`                                                      |
| `-b, --backtracing`           | `remove` (optional)                   | Print backtracing information when a chunk or justification is created                                                        |
| `-d, --decisions`             | `remove` (optional)                   | Controls whether state and operator decisions are printed as they are made                                                    |
| `-e, --epmem`                 | `remove` (optional)                   | Print episodic retrieval traces and IDs of newly encoded episodes                                                             |
| `-g, --gds`                   | `remove` (optional)                   | Controls printing of warnings when a state is removed due to the GDS                                                          |
| `-G, --gds-wmes`              | `remove` (optional)                   | Controls printing of warnings about wme changes to GDS                                                                        |
| `-i, --indifferent-selection` | `remove` (optional)                   | Print scores for tied operators in random indifferent selection mode                                                          |
| `-p, --phases`                | `remove` (optional)                   | Controls whether decisions cycle phase names are printed as Soar executes                                                     |
| `-r, --preferences`           | `remove` (optional)                   | Controls whether the preferences generated by the traced productions are printed when those productions fire or retract       |
| `-P, --productions`           | `remove` (optional)                   | Controls whether the names of productions are printed as they fire and retract, equivalent to `-Dujc`                         |
| `-R, --rl`                    | `remove` (optional)                   | Print RL debugging output                                                                                                     |
| `-s, --smem`                  | `remove` (optional)                   | Print log of semantic memory storage events                                                                                   |
| `-w, --wmes`                  | `remove` (optional)                   | Controls the printing of working memory elements that are added and deleted as productions are fired and retracted.           |
| `-a, --wma`                   | `remove` (optional)                   | Print log of working memory activation events                                                                                 |
| `-A, --assertions`            | `remove` (optional)                   | Print assertions of rule instantiations and the preferences they generate.                                                    |

When appropriate, a specific option may be turned off using the `remove`
argument. This argument has a numeric alias; you can use `0` for `remove`. A mix
of formats is acceptable, even in the same command line.

## Tracing Productions

By default, the names of the productions are printed as each production fires
and retracts (at trace levels `3` and higher). However, it may be more helpful
to trace only a specific _type_ of production. The tracing of firings and
retractions of productions can be limited to only certain types by the use of
the following flags:

| **Option Flag**        | **Argument to Option** | **Description**                                           |
| :--------------------- | :--------------------- | :-------------------------------------------------------- |
| `-D, --default`        | `remove` (optional)    | Control only default-productions as they fire and retract |
| `-u, --user`           | `remove` (optional)    | Control only user-productions as they fire and retract    |
| `-c, --chunks`         | `remove` (optional)    | Control only chunks as they fire and retract              |
| `-j, --justifications` | `remove` (optional)    | Control only justifications as they fire and retract      |
| `-T, --template`       | `remote` (optional)    | Soar-RL template firing trace                             |

**Note:** The [production watch](./cmd_production.md) command is used to trace
*individual productions specified by name rather than trace a type of
*productions, such as `--user`.

Additionally, when tracing productions, users may set the level of detail to be
displayed for WMEs that are added or retracted as productions fire and retract.
Note that detailed information about WMEs will be printed only for productions
that are being traced.

| **Option Flag**  | **Description**                                                            |
| :--------------- | :------------------------------------------------------------------------- |
| `-n, --nowmes`   | When tracing productions, do not print any information about matching wmes |
| `-t, --timetags` | When tracing productions, print only the timetags for matching wmes        |
| `-f, --fullwmes` | When tracing productions, print the full matching wmes                     |

## Tracing Learning

| **Option Flag**  | **Argument to Option**                               | **Description**                                                    |
| :--------------- | :--------------------------------------------------- | :----------------------------------------------------------------- |
| `-L, --learning` | `noprint`, `print`, or `fullprint` (see table below) | Controls the printing of chunks/justifications as they are created |

As Soar is running, it may create justifications and chunks which are added to
production memory. The trace command allows users to monitor when chunks and
justifications are created by specifying one of the following arguments to the
`--learning` command:

| **Argument** | **Alias** | **Effect**                                                    |
| :----------- | :-------- | :------------------------------------------------------------ |
| `noprint`    | `0`       | Print nothing about new chunks or justifications (default)    |
| `print`      | `1`       | Print the names of new chunks and justifications when created |
| `fullprint`  | `2`       | Print entire chunks and justifications when created           |

## Description

The `trace` command controls the amount of information that is printed out as
Soar runs. The basic functionality of this command is to trace various _levels_
of information about Soar's internal workings. The higher the _level_, the more
information is printed as Soar runs. At the lowest setting, `0` (`--none`),
nothing is printed. The levels are cumulative, so that each successive level
prints the information from the previous level as well as some additional
information. The default setting for the _level_ is `1`, (`--decisions`).

The numerical arguments _inclusively_ turn on all levels up to the number
specified. To use numerical arguments to turn off a level, specify a number
which is less than the level to be turned off. For instance, to turn off tracing
of productions, specify `--level 2` (or 1 or 0). Numerical arguments are
provided for shorthand convenience. For more detailed control over the trace
settings, the named arguments should be used.

With no arguments, this command prints information about the current trace
status, i.e., the values of each parameter.

For the named arguments, including the named argument turns on only that
setting. To turn off a specific setting, follow the named argument with `remove`
or `0`.

The named argument `--productions` is shorthand for the four arguments
`--default`, `--user`, `--justifications`, and `--chunks`.

## Examples

The most common uses of trace are by using the numeric arguments which indicate
trace levels. To turn off all printing of Soar internals, do any one of the
following (not all possibilities listed):

```bash
trace --level 0
trace -l 0
trace -N
```

Note: You can turn off printing at an even lower level using the `output` command.

Although the `--level` flag is optional, its use is recommended:

```bash
trace --level 5   ## OK
trace 5           ## OK, avoid
```

Be careful of where the level is on the command line, for example, if you want
level 2 and preferences:

```bash
trace -r -l 2 ## Incorrect: -r flag ignored, level 2 parsed after it and overrides the setting
trace -r 2    ## Syntax error: 0 or remove expected as optional argument to -r
trace -r -l 2 ## Incorrect: -r flag ignored, level 2 parsed after it and overrides the setting
trace 2 -r    ## OK, avoid
trace -l 2 -r ## OK
```

To turn on printing of decisions, phases and productions, do any one of the
following (not all possibilities listed):

```bash
trace --level 3
trace -l 3
trace --decisions --phases --productions
trace -d -p -P
```

Individual options can be changed as well. To turn on printing of decisions and
WMEs, but not phases and productions, do any one of the following (not all
possibilities listed):

```bash
trace --level 1 --wmes
trace -l 1 -w
trace --decisions --wmes
trace -d --wmes
trace -w --decisions
trace -w -d
```

To turn on printing of decisions, productions and WMEs, and turns phases off, do
any one of the following (not all possibilities listed):

```bash
trace --level 4 --phases remove
trace -l 4 -p remove
trace -l 4 -p 0
trace -d -P -w -p remove
```

To trace the firing and retraction of decisions and _only_ user productions, do
any one of the following (not all possibilities listed):

```bash
trace -l 1 -u
trace -d -u
```

To trace decisions, phases and all productions _except_ user productions and
justifications, and to see full WMEs, do any one of the following (not all
possibilities listed):

```bash
trace --decisions --phases --productions --user remove --justifications remove --fullwmes
trace -d -p -P -f -u remove -j 0
trace -f -l 3 -u 0 -j 0
```

## Default Aliases

```bash
v           trace -A
w           trace
watch       trace
```

## See Also

-   [epmem](./cmd_epmem.md)
-   [production](./cmd_production.md)
-   [output](./cmd_output.md)
-   [print](./cmd_print.md)
-   [run](./cmd_run.md)
-   [wm](./cmd_wm.md)
