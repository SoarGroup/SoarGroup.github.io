## production

Commands to manipulate Soar rules and analyze their usage.

#### Synopsis

```
==================================================================
-               Production Sub-Commands and Options              -
==================================================================
production                    [? | help]
------------------------------------------------------------------
production break              [--clear --print]
production break              --set <prod-name>
------------------------------------------------------------------
production excise             <production-name>
production excise             [--all --chunks --default ]
                              [--never-fired --rl       ]
                              [--task --templates --user]
------------------------------------------------------------------
production find               [--lhs --rhs         ] <pattern>
                              [--show-bindings     ]
                              [--chunks --nochunks ]
------------------------------------------------------------------
production firing-counts      [--all --chunks --default --rl]  [n]
                              [--task --templates --user --fired]
production firing-counts      <prod-name>
------------------------------------------------------------------
production matches            [--names --count  ]  <prod-name>
                              [--timetags --wmes]
production matches            [--names --count  ] [--assertions ]
                              [--timetags --wmes] [--retractions]
------------------------------------------------------------------
production memory-usage       [options] [max]
production memory-usage       <production_name>
------------------------------------------------------------------
production optimize-attribute [symbol [n]]
------------------------------------------------------------------
production watch              [--disable --enable] <prod-name>
------------------------------------------------------------------

For a detailed explanation of sub-commands:    help production
```

### Summary Screen
Using the `production` command without any arguments will display a summary of how many rules are loaded into memory:

```
=======================================================
-                     Productions                     -
=======================================================
User rules                                            0
Default rules                                         0
Chunks                                                0
Justifications                                        0
-------------------------------------------------------
Total                                                 0
-------------------------------------------------------
Use 'production ?' to learn more about the command
```

### production break

Toggles the `:interrupt` flag on a rule at run-time, which stops the Soar decision cycle when the rule fires. The `break` command can be used to toggle the `:interrupt` flag on production rules which did not have it set in the original source file, which stops the Soar decision cycle when the rule fires. This is intended to be used for debugging purposes.

#### Synopsis

```
production break -c|--clear <production-name>
production break -p|--print
production break -s|--set <production-name>
production break <production-name>
```
#### Options:

| **Parameter** | **Argument** | **Description** |
|:--------------|:-------------|:----------------|
| `-c, --clear` | &lt;production-name&gt; | Clear :interrupt flag from a production. |
| `-p, --print` | (none)       | Print which production rules have had their :interrupt flags set. |
|  (none)       | (none)       | Print which production rules have had their :interrupt flags set. |
| `-s, --set`   | &lt;production-name&gt; | Set :interrupt flag on a production rule. |
| (none)        | &lt;production-name&gt; | Set flag :interrupt on a production rule. |

### production excise

This command removes productions from Soar's memory. The command must be called with either a specific production name or with a flag that indicates a particular group of productions to be removed. 

Note:  As of Soar 9.6, using the flag `-a` or `--all` no longer causes a `soar init`.

#### Synopsis

```
production excise production_name
production excise options
```
#### Options:

| **Option** | **Description** |
|:-----------|:----------------|
| `-a, --all` | Remove all productions from memory **and** perform an [init-soar](./cmd_init_soar.md) command |
| `-c, --chunks` | Remove all chunks (learned productions) and justifications from memory                      |
| `-d, --default` | Remove all default productions (`:default`) from memory                                     |
| `-n, --never-fired`  | Excise rules that have a firing count of 0                                              |
| `-r, --rl`  | Excise Soar-RL rules                                                                        |
| `-t, --task` | Remove chunks, justifications, and user productions from memory                             |
| `-T, --templates` | Excise Soar-RL templates                                                                    |
| `-u, --user` | Remove all user productions (but not chunks or default rules) from memory                   |
| `production_name` | Remove the specific production with this name.                                              |

#### Examples:

This command removes the production `my*first*production` and all chunks:

```
production excise my*first*production --chunks
```

This removes all productions:

```
production excise --all
```

### production find

Find productions by condition or action patterns.

#### Synopsis

```
production find [-lrs[n|c]] pattern
```

#### Options:

| **Option** | **Description** |
|:-----------|:----------------|
| `-c, --chunks` | Look _only_ for chunks that match the pattern. |
| `-l, --lhs`    | Match pattern only against the conditions (left-hand side) of productions (default). |
| `-n, --nochunks` | _Disregard_ chunks when looking for the pattern. |
| `-r, --rhs`    | Match pattern against the actions (right-hand side) of productions. |
| `-s, --show-bindings` | Show the bindings associated with a wildcard pattern. |
| `pattern`      | Any pattern that can appear in productions.    |

#### Description

The `production find` command is used to find productions in production memory that include conditions or actions that match a given `pattern`. The pattern given specifies one or more condition elements on the left hand side of productions (or negated conditions), or one or more actions on the right-hand side of productions. Any pattern that can appear in productions can be used in this command. In addition, the asterisk symbol, `*`, can be used as a wildcard for an attribute or value. It is important to note that the whole pattern, including the parenthesis, must be enclosed in curly braces for it to be parsed properly.

The variable names used in a call to production find do not have to match the variable names used in the productions being retrieved.

The `production find` command can also be restricted to apply to only certain types of productions, or to look only at the conditions or only at the actions of productions by using the flags.

#### Production Find Examples:

Find productions that test that some object `gumby` has an attribute `alive` with value `t`. In addition, limit the rules to only those that test an operator named `foo`:

```
production find (<state> ^gumby <gv> ^operator.name foo)(<gv> ^alive t)
```

Note that in the above command, `<state>` does not have to match the exact variable name used in the production.

Find productions that propose the operator `foo`:

```
production find --rhs (<x> ^operator <op> +)(<op> ^name foo)
```

Find chunks that test the attribute ^pokey:

```
production find --chunks (<x> ^pokey *)
```

Examples using the water-jugs demo:

```
source demos/water-jug/water-jug.soar
production-find (<s> ^name *)(<j> ^volume *)
production-find (<s> ^name *)(<j> ^volume 3)
production-find --rhs (<j> ^* <volume>)
```
### production firing-counts

Print the number of times productions have fired.

#### Synopsis

```
production firing-counts [type] [n]
production firing-counts production_name
```
#### Options:

If given, an option can take one of two forms -- an integer or a production name:

| **Option** | **Description** |
|:-----------|:----------------|
| `n` | List the top `n` productions. If `n` is 0, only the productions which haven't fired are listed |
| `production_name ` | Print how many times a specific production has fired |
| `-f, --fired` | Prints only rules that have fired |
| `-c, --chunks` | Print how many times chunks (learned rules) fired |
| `-j, --justifications` | Print how many times justifications fired |
| `-d, --default` | Print how many times default productions (`:default`) fired |
| `-r, --rl`  | Print how many times Soar-RL rules fired |
| `-T, --templates` | Print how many times Soar-RL templates fired |
| `-u, --user` | Print how many times user productions (but not chunks or default rules) fired |

#### Description

The `production firing-counts` command prints the number of times each production has fired; production names are given from most frequently fired to least frequently fired. With no arguments, it lists all productions. If an integer argument, `n`, is given, only the top `n` productions are listed.  If `n` is zero (0), only the productions that haven't fired at all are listed. If --fired is used, the opposite happens.  Only rules that have fired are listed. If a production name is given as an argument, the firing count for that production is printed.

Note that firing counts are reset by a call to [soar init] (cmd_soar).

#### Examples:

This example prints the 10 productions which have fired the most times along with their firing counts:

```
production firing-counts 10
```

This example prints the firing counts of production `my*first*production`:

```
production firing-counts my*first*production
```

This example prints all rules that have fired at least once:

```
production firing-counts -f
```
### production matches

The `production matches` command prints a list of productions that have instantiations in the match set, i.e., those productions that will retract or fire in the next _propose_ or _apply_ phase. It also will print partial match information for a single, named production.

#### Synopsis

```
production matches [options] production_name
production matches [options] -[a|r]
```

#### Options:

| **Option** | **Description** |
|:-----------|:----------------|
| `production_name` | Print partial match information for the named production. |
| `-n, --names, -c, --count` | For the match set, print only the names of the productions that are about to fire or retract (the default). If printing partial matches for a production, just list the partial match counts. |
| `-t, --timetags`  | Also print the timetags of the wmes at the first failing condition |
| `-w, --wmes`      | Also print the full wmes, not just the timetags, at the first failing condition. |
| `-a, --assertions` | List only productions about to fire.                      |
| `-r, --retractions` | List only productions about to retract.                   |

#### Printing the match set

When printing the match set (i.e., no production name is specified), the default action prints only the names of the productions which are about to fire or retract. If there are multiple instantiations of a production, the total number of instantiations of that production is printed after the production name, unless `--timetags` or `--wmes` are specified, in which case each instantiation is printed on a separate line.

When printing the match set, the `--assertions` and `--retractions` arguments can be specified to restrict the output to print only the assertions or retractions.

#### Printing partial matches for productions

In addition to printing the current match set, the `matches` command can be used to print information about partial matches for a named production. In this case, the conditions of the production are listed, each preceded by the number of currently active matches for that condition. If a condition is negated, it is preceded by a minus sign `-`. The pointer `>>>>` before a condition indicates that this is the first condition that failed to match.

When printing partial matches, the default action is to print only the counts of the number of WME's that match, and is a handy tool for determining which condition failed to match for a production that you thought should have fired. At levels `--timetags` and `--wmes` the `matches` command displays the WME's immediately after the first condition that failed to match -- temporarily interrupting the printing of the production conditions themselves.

#### Notes:

When printing partial match information, some of the matches displayed by this command may have already fired, depending on when in the execution cycle this command is called. To check for the matches that are about to fire, use the matches command without a named production.

In Soar 8, the execution cycle (decision cycle) is input, propose, decide, apply output; it no longer stops for user input after the decision phase when [running](./cmd_run.md) by decision cycles (`run -d 1`). If a user wishes to print the match set immediately after the decision phase and before the apply phase, then the user must run Soar by _phases_ (`run -p 1`).

#### Examples:

This example prints the productions which are about to fire and the WMEs that match the productions on their left-hand sides:

```
production matches --assertions --wmes
```

This example prints the WME timetags for a single production.

```
production matches -t my*first*production
```
### production memory-usage

Print memory usage for partial matches.

#### Synopsis

```
production memory-usage [options] [number]
production memory-usage production_name
```

#### Options:

| **Option** | **Description** |
|:-----------|:----------------|
| `-c, --chunks` | Print memory usage of chunks. |
| `-d, --default` | Print memory usage of default productions. |
| `-j, --justifications` | Print memory usage of justifications. |
| `-u, --user`   | Print memory usage of user-defined productions. |
| `production_name` | Print memory usage for a specific production. |
| `number`       | Number of productions to print, sorted by those that use the most memory. |
| `-T, --template` | Print memory usage of Soar-RL templates. |

#### Description

The `memory-usage` command prints out the internal memory usage for full and partial matches of production instantiations, with the productions using the most memory printed first. With no arguments, the `memory-usage` command prints memory usage for all productions.  If a `production_name` is specified, memory usage will be printed only for that production. If a positive integer `number` is given, only `number` productions will be printed: the `number` productions that use the most memory. Output may be restricted to print memory usage for particular types of productions using the command options.

Memory usage is recorded according to the tokens that are allocated in the Rete network for the given production(s). This number is a function of the number of elements in working memory that match each production. Therefore, this command will not provide useful information at the beginning of a Soar run (when working memory is empty) and should be called in the middle (or at the end) of a Soar run.

The `memory-usage` command is used to find the productions that are using the most memory and, therefore, may be taking the longest time to match (this is only a heuristic). By identifying these productions, you may be able to rewrite your program so that it will run more quickly. Note that memory usage is just a heuristic measure of the match time: A production might not use much memory relative to others but may still be time-consuming to match, and excising a production that uses a large number of tokens may not speed up your program, because the Rete matcher shares common structure among different productions.

As a rule of thumb, numbers less than 100 mean that the production is using a small amount of memory, numbers above 1000 mean that the production is using a large amount of memory, and numbers above 10,000 mean that the production is using a **very** large amount of memory.

### production optimize-attribute

Declare a symbol to be multi-attributed so that conditions in productions that test that attribute are re-ordered so that the rule can be matched more efficiently.

#### Synopsis

```
production optimize-attribute [symbol [n]]
```

#### Options:

| **Option** | **Description** |
|:-----------|:----------------|
| `symbol` | Any Soar attribute. |
| `n`      | Integer greater than 1, estimate of degree of simultaneous values for attribute. |

#### Description:

This command is used to improve efficiency of matching against attributes that can have multiple values at once.
```
(S1 ^foo bar1)
(S1 ^foo bar2)
(S1 ^foo bar3)
```
If you know that a certain attribute will take on multiple values, `optimize-attribute` can be used to provide hints to the production condition reorderer so that it can produce better orderings that allow the Rete network to match faster. This command has no effect on the actual contents of working memory and is only used to improve efficiency in problematic situations.

`optimize-attribute` declares a symbol to be an attribute which can take on multiple values. The optional `n` is an integer (greater than 1) indicating an upper limit on the number of expected values that will appear for an attribute. If `n` is not specified, the value 10 is used for each declared multi-attribute. More informed values will tend to result in greater efficiency.

Note that `optimize-attribute` declarations must be made before productions are loaded into soar or this command will have no effect.

#### Example:

Declare the symbol "thing" to be an attribute likely to take more than 1 but no more than 4 values:

```
production optimize-attribute thing 4
```
### production watch

Trace firings and retractions of specific productions.

#### Synopsis

```
production watch [-d|e] [production name]
```
#### Options:

| **Option** | **Description** |
|:-----------|:----------------|
| `-d, --disable, --off` | Turn production watching off for the specified production. If no production is specified, turn production watching off for all productions. |
| `-e, --enable, --on`   | Turn production watching on for the specified production. The use of this flag is optional, so this is watch's default behavior. If no production is specified, all productions currently being watched are listed. |
| `production name`      | The name of the production to watch.                                                                                                        |

#### Description

The `production watch` command enables and disables the tracing of the firings and retractions of individual productions. This is a companion command to [watch](./cmd_watch.md), which cannot specify individual productions by name.

With no arguments, production watch lists the productions currently being traced. With one production-name argument, production watch enables tracing the production; `--enable` can be explicitly stated, but it is the default action.

If `--disable` is specified followed by a production-name, tracing is turned off for the production. When no production-name is specified, `--enable` lists all productions currently being traced, and `--disable` disables tracing of all productions.

Note that `production watch` now only takes one production per command. Use multiple times to watch multiple functions.

### Default Aliases
```                
ex                         production excise
excise                     production excise
fc                         production firing-counts
firing-counts              production firing-counts
matches                    production matches
memories                   production memory-usage
multi-attributes           production optimize-attribute
pbreak                     production break
production-find            production find
pw                         production watch
pwatch                     production watch
```
### See Also

[soar init](./cmd_soar.md)  
[sp](./cmd_sp.md) 
[trace](./cmd_trace.md)
