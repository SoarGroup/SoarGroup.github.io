# output

Controls settings related to Soar's output

## Synopsis

```bash
=======================================================
-           Output Sub-Commands and Options           -
=======================================================
output                                       [? | help]
-------------------------------------------------------
enabled                                              on   Globally toggle all output
console                                             off   Send output to std::out for debugging
callbacks                                            on   Send output to standard print callback
-------------------------------------------------------
agent-logs                  <channel-number> [ON | off]   Whether agent log channel prints
agent-writes                                         on   Allow RHS-funtion output
-------------------------------------------------------
output log                   [--append | -A] <filename>   Log all output to file
output log                               --add <string>
output log                                    [--close]
-------------------------------------------------------
output command-to-file         [-a] <file> <cmd> [args]   Log output from single command
-------------------------------------------------------
echo-commands                                       off   Echo commands to debugger
print-depth                                           1   Default print depth
warnings                                             on   Print all warnings
-------------------------------------------------------
To view/change a setting:                                 output <setting> [<value>]

For a detailed explanation of these settings:             help output
```

## Summary Screen

Using the `output` command without any arguments will display some key output settings:

```bash
=======================================================
-                   Output Status                     -
=======================================================
Printing enabled                                    Yes
Printing to std::out                                Yes
-------------------------------------------------------
Agent RHS write output                               on
All agent log channels enabled.
-------------------------------------------------------
Warnings                                             on
-------------------------------------------------------
Soar release compilation                            OFF
Debug printing                                       ON
-------------------------------------------------------
```

## output command-to-file

This command logs a single command. It is almost equivalent to opening a log
using [clog](./cmd_output.md#default-aliases), running the command, then closing
the log, the only difference is that input isn't recorded.

Running this command while a log is open is an error. There is currently not
support for multiple logs in the command line interface, and this would be an
instance of multiple logs.

This command echoes output both to the screen and to a file, just like clog.

### Options

| **Option**     | **Description**                               |
| :------------- | :-------------------------------------------- |
| `-a, --append` | Append if file exists.                        |
| `filename`     | The file to log the results of the command to |
| `command`      | The command to log                            |
| `args`         | Arguments for command                         |

## output log

The `output log` command allows users to save all user-interface input and
output to a file. When Soar is logging to a file, everything typed by the user
and everything printed by Soar is written to the file (in addition to the
screen).

Invoke `output log` with no arguments to query the current logging status. Pass
a filename to start logging to that file (relative to the command line
interface's home directory). Use the `close` option to stop logging.

### Usage

```bash
output log [-A] filename
output log --add string
output log --close
```

### Options

| **Option**         | **Description**                                                                       |
| :----------------- | :------------------------------------------------------------------------------------ |
| `filename`         | Open filename and begin logging.                                                      |
| `-c, --close`      | Stop logging, close the file.                                                         |
| `-a, --add string` | Add the given string to the open log file.                                            |
| `-A, --append`     | Opens existing log file named `filename` and logging is added at the end of the file. |

### Examples

To initiate logging and place the record in foo.log:

```bash
output log foo.log
```

To append log data to an existing foo.log file:

```bash
output log -A foo.log
```

To terminate logging and close the open log file:

```bash
output log -c
```

### Known Issues with log

Does not log everything when structured output is selected.

## General Output Settings

Invoke a sub-command with no arguments to query the current setting. Partial
commands are accepted.

| **Option**      | **Valid Values** | **Default** |
| :-------------- | :--------------- | :---------- |
| `echo-commands` | yes or no        | off         |
| `print-depth`   | >= 1             | 1           |
| `verbose`       | yes or no        | no          |
| `warnings`      | yes or no        | yes         |

## output agent-logs

A Soar agent has 100 log channels available. By default, all are turned on. The
`log` RHS-function allows printing as with the `write` function, but limits
output to only the specified log channel.

## output echo-commands

`output echo-commands` will echo typed commands to other connected debuggers.
Otherwise, the output is displayed without the initiating command, and this can
be confusing.

## output print-depth

The `print-depth` command reflects the default depth used when working memory
elements are printed (using the [print](./cmd_print.md)). The default value is
`1`. This default depth can be overridden on any particular call to the
[print](./cmd_print.md) command by explicitly using the `--depth` flag, e.g.
`print --depth 10 args`.

By default, the [print](./cmd_print.md) command prints _objects_ in working
memory, not just the individual working memory element. To limit the output to
individual working memory elements, the `--internal` flag must also be specified
in the [print](./cmd_print.md) command. Thus when the print depth is `0`, by
default Soar prints the entire object, which is the same behavior as when the
print depth is `1`. But if `--internal` is also specified, then a depth of `0`
prints just the individual WME, while a depth of `1` prints all WMEs which share
that same identifier. This is true when printing timetags, identifiers or WME
patterns.

When the depth is greater than `1`, the identifier links from the specified
WME's will be followed, so that additional substructure is printed. For example,
a depth of `2` means that the object specified by the identifier, wme-pattern,
or timetag will be printed, along with all other objects whose identifiers
appear as values of the first object. This may result in multiple copies of the
same object being printed out. If `--internal` is also specified, then
individuals WMEs and their timetags will be printed instead of the full objects.

## output verbose

The `verbose` command enables tracing of a number of low-level Soar execution
details during a run. The details printed by `verbose` are usually only valuable
to developers debugging Soar implementation details.

## output warnings

The `warnings` command enables and disables the printing of warning messages. At
startup, warnings are initially enabled. If warnings are disabled using this
command, then some warnings may still be printed, since some are considered too
important to ignore.

The warnings that are printed apply to the syntax of the productions, to notify
the user when they are not in the correct syntax. When a lefthand side error is
discovered (such as conditions that are not linked to a common state or impasse
object), the production is generally loaded into production memory anyway,
although this production may never match or may seriously slow down the matching
process. In this case, a warning would be printed only if warnings were `on`.
Righthand side errors, such as preferences that are not linked to the state,
usually result in the production not being loaded, and a warning regardless of
the warnings setting.

## Default Aliases

```bash
ctf                        output command-to-file
clog                       output log
default-wme-depth          output print-depth
echo-commands              output echo-commands
verbose                    output verbose
warnings                   output warnings
```
