## print

Print items in working memory or production memory.

#### Synopsis

```
print [options] [production_name]
print [options] identifier|timetag|pattern
print [--gds --stack]
```
### Options

#### Production printing options:

| **Option** | **Description** |
|:-----------|:----------------|
| `-a, --all` | print the names of all productions currently loaded |
| `-c, --chunks` | print the names of all chunks currently loaded      |
| `-D, --defaults` | print the names of all default productions currently loaded |
| `-j, --justifications` | print the names of all justifications currently loaded. |
| `-r, --rl`  | Print Soar-RL rules                                 |
| `-T, --template` | Print Soar-RL templates                             |
| `-u, --user` | print the names of all user productions currently loaded |
| `production_name` | print the production named `production-name`        |

#### Production print formatting:

| **Option** | **Description** |
|:-----------|:----------------|
| `-f, --full` | When printing productions, print the whole production. This is the default when printing a named production. |
| `-F, --filename` | also prints the name of the file that contains the production.                                               |
| `-i, --internal` | items should be printed in their internal form. For productions, this means leaving conditions in their reordered (rete net) form. |
| `-n, --name` | When printing productions, print only the name and not the whole production. This is the default when printing any category of productions, as opposed to a named production. |

#### Working memory printing options:

| **Option** | **Description** |
|:-----------|:----------------|
| `-d, --depth n` | This option overrides the default printing depth (see the [default-wme-depth](./cmd_default_wme_depth.md) command for more detail). |
| `-e, --exact`   | Print only the wmes that match the pattern                                                                                        |
| `-i, --internal` | items should be printed in their internal form. For working memory, this means printing the individual elements with their timetags and activation, rather than the objects. |
| `-t, --tree`    | wmes should be printed in in a tree form (one wme per line).                                                                      |
| `-v, --varprint` | Print identifiers enclosed in angle brackets.                                                                                     |
| `identifier`    | print the object `identifier`. `identifier` must be a valid Soar symbol such as _S1_                                              |
| `pattern`       | print the object whose working memory elements matching the given `pattern`. See Description for more information on printing objects matching a specific `pattern`. |
| `timetag`       | print the object in working memory with the given `timetag`                                                                       |

#### Subgoal stack printing options:

| **Option** | **Description** |
|:-----------|:----------------|
| `-s, --stack` | Specifies that the Soar goal stack should be printed. By default this includes both states and operators. |
| `-o, --operators` | When printing the stack, print only _operators_.                                                          |
| `-S, --states` | When printing the stack, print only _states_.                                                             |

### Printing the Goal Dependency Set:

`print --gds`

The Goal Dependency Set (GDS) is described in a subsection of the `The Soar Architecture` chapter of the manual. This command is a debugging command for examining the GDS for each goal in the stack. First it steps through all the working memory elements in the rete, looking for any that are included in _any_ goal dependency set, and prints each one. Then it also lists each goal in the stack and prints the wmes in the goal dependency set for that particular goal. This command is useful when trying to determine why subgoals are disappearing unexpectedly: often something has changed in the goal dependency set, causing a subgoal to be regenerated prior to producing a result.

`print --gds` is horribly inefficient and should not generally be used except when something is going wrong and you need to examine the Goal Dependency Set.

### Description

The print command is used to print items from production memory or working memory. It can take several kinds of arguments. When printing items from working memory, the Soar objects are printed unless the `--internal` flag is used, in which case the wmes themselves are printed.

```
(identifier ^attribute value [activation] [+])
```

The activation value is only printed if activation is turned on. See [wma](./cmd_wma.md).

The pattern is surrounded by parentheses. The `identifier`, `attribute`, and `value` must be valid Soar symbols or the wildcard symbol `*` which matches all occurrences. The optional `+` symbol restricts pattern matches to acceptable preferences. If wildcards are included, an object will be printed for each pattern match, even if this results in the same object being printed multiple times.

### Examples

Print the objects in working memory (and their timetags) which have wmes with identifier `s1` and value `v2` (note: this will print the entire `s1` object for each match found):

```
print --internal (s1 ^* v2)
```

Print the Soar stack which includes states and operators:

```
print --stack
```

Print the named production in its RETE form:

```
print -if named*production
```

Print the names of all user productions currently loaded:

```
print -u
```

Default print vs tree print:

```
print s1 --depth 2
(S1 ^io I1 ^reward-link R1 ^superstate nil ^type state)
  (I1 ^input-link I2 ^output-link I3)

print s1 --depth 2 --tree
(S1 ^io I1)
  (I1 ^input-link I2)
  (I1 ^output-link I3)
(S1 ^reward-link R1)
(S1 ^superstate nil)
(S1 ^type state)
```

### Default Aliases

p              print
pc             print --chunks
ps             print --stack
wmes           print --depth 0 --internal
varprint       print --varprint --depth 100
gds_print      print --gds

### See Also

[output](./cmd_output.md) 
[trace](./cmd_trace.md) 
[wm](./cmd_wm.md)
