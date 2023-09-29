## smem

Controls the behavior of and displays information about semantic memory. 

#### Synopsis

```
=======================================================
-             Semantic Memory Sub-Commands            -
=======================================================
smem [? | help]                                           Print help screen
smem [--enable | --disable ]                              Turn smem on/off
smem [--get | --set]                 <option> [<value>]   Print or set a parameter
smem --add                        { (id ^attr value)* }   Add memory to smem
smem --backup                                <filename>   Save copy of database
smem --clear                                              Delete contents of smem
smem --export                        <filename> [<LTI>]   Save database to file
smem --init                                               Reinit smem store
smem --query                           {(cue)* [<num>]}   Query smem via given cue
smem --remove                 { (id [^attr [value]])* }   Remove smem structures
------------------------ Printing ---------------------
print                                                 @   Print all smem contents
print                                             <LTI>   Print specific smem memory
smem --history                                    <LTI>   Print memory activation history
=======================================================
-        Semantic Memory Parameters  (use --set)      -
=======================================================
enabled                                             off
database                              [ MEMORY | file ]   Store database in memory or file
append                                               on   Append or overwrite after init
path                                                      Path to database on disk
---------------------- Activation ---------------------
activation-mode    [ RECENCY | frequency | base-level ]   
activate-on-query                          [ ON | off ]
base-decay                                          0.5   Decay amount for base-level activation
base-update-policy     [ STABLE | naive | incremental ]   
base-incremental-threshes                            10   Integer > 0
thresh                                              100   Integer >= 0
base-inhibition                            [ on | OFF ]   
---------- Experimental Spreading Activation ----------
spreading                                  [ on | OFF ]   
spreading-limit                                     300   integer > 0
spreading-depth-limit                                10   integer > 0
spreading-baseline                               0.0001   1 > decimal > 0
spreading-continue-probability                      0.9   1 > decimal > 0
spreading-loop-avoidance                   [ on | OFF ]
spreading-edge-updating                    [ on | OFF ]
spreading-wma-source                       [ on | OFF ]
spreading-edge-update-factor                       0.99   1 > decimal > 0
------------- Database Optimization Settings ----------
lazy-commit                                          on   Delay writing store until exit
optimization                   [ safety | PERFORMANCE ]   
cache-size                                        10000   Number of memory pages for SQLite cache
page-size                                            8k   Size of each memory page
----------------- Timers and Statistics ---------------
timers                      [ OFF | one | two | three ]   How detailed timers should be
smem --timers                                 [<timer>]   Print summary or specifics
smem --stats                                   [<stat>]   Print summary or specifics
                  ---------------------
Timers: smem_api, smem_hash, smem_init, smem_query,
        smem_ncb_retrieval, three_activation
        smem_storage, _total
Stats:  act_updates, db-lib-version, edges, mem-usage,
        mem-high, nodes, queries, retrieves, stores
-------------------------------------------------------
For a detailed explanation of these settings:             help smem
```

### Summary Output

With no arguments, `smem` will return a quick summary of key aspects of semantic memory.
```
====================================================
              Semantic Memory Summary
====================================================
Enabled                                          off
Storage                                       Memory   (append after init)
----------------------------------------------------
Nodes                                              2
Edges                                              1
Memory Usage                                  406784   bytes
----------------------------------------------------
For a full list of smem's sub-commands and settings:  smem ?
```

#### Options:

| **Commands** | **Description** |
|:-----------|:----------------|
| `-e, --enable, --on` | Enable semantic memory. |
| `-d, --disable, --off` | Disable semantic memory. |
| `-g, --get` | Print current parameter setting |
| `-s, --set` | Set parameter value |
| `-c, --clear` | Deletes all memories |
| `-x, --export` | Creates an agent-sourceable copy of semantic memory on disk |
| `-i, --init` | Deletes all memories if append is off |
| `-S, --stats` | Print statistic summary or specific statistic |
| `-t, --timers` | Print timer summary or specific statistic |
| `-a, --add` | Add concepts to semantic memory |
| `-r, --remove`| Remove concepts from semantic memory|
| `-q, --query`| Print concepts in semantic store matching some cue|
| `-h, --history`| Print activation history for some LTI|
| `-b, --backup` | Creates a backup of the semantic database on disk |

#### Printing

To print from semantic memory, the standard print command can be used, for example, to print a specific LTI:

`p @23`

To print the entire semantic store:

`p @`

Note that such print commands will honor the --depth parameter passed in.

The command `trace --smem` displays additional trace information for semantic memory not controlled by this command.

### Parameters

Due to the large number of parameters, the `smem` command uses the 
`--get|--set <parameter> <value>` convention rather than individual switches for each parameter.  Running `smem` without any switches displays a summary of the parameter settings.

| **Parameter** | **Description** | **Possible values** | **Default** |
|:--------------|:----------------|:--------------------|:------------|
| `append`      | Controls whether database is overwritten or appended when opening or re-initializing | `on`, `off`         | `off`       |
| `database`    | Database storage method | `file`, `memory`    | `memory`    |
| `learning`    | Semantic memory enabled | `on`, `off`         | `off`       |
| `path`        |  Location of database file | _empty_, _some path_ | _empty_     |

The `learning` parameter turns the semantic memory module on or off. This is the same as using the enable and disable commands.

The `path` parameter specifies the file system path the database is stored in. When `path` is set to a valid file system path and database mode is set to file, then the SQLite database is written to that path.

The `append` parameter will determine whether all existing facts stored in a database on disk will be erased when semantic memory loads. Note that this affects semantic memory re-initialization also, i.e. if the append setting is off, all semantic facts stored to disk will be lost when a `soar init` is performed. For semantic memory,
`append` mode is by default on.

Note that changes to database, `path` and `append` will not have an effect until the database is used after an initialization.  This happens either shortly after launch (on first use) or after a database initialization command is issued.  To switch databases or database storage types while running, set your new parameters and then perform an `smem --init` command.


#### Activation Parameters:
| **Parameter** | **Description** | **Possible values** | **Default** |
|:--------------|:----------------|:--------------------|:------------|
| activation-mode | Sets the ordering bias for retrievals that match more than one memory | `recency`, `frequency`, `base-level` | `recency`   |
| activate-on-query | Determines if the results of queries should be activated | `on`, `off`         | `on`        |
| base-decay  | Sets the decay parameter for base-level activation computation | `>` 0               | 0.5         |
| base-update-policy | Sets the policy for re-computing base-level activation | `stable`, `naive`, `incremental` | `stable`    |
| base-incremental-threshes | Sets time deltas after which base-level activation is re-computed for old memories | 1, 2, 3, ...        | 10          |
| thresh      | Threshold for activation locality | 0, 1, ...           | 100         |
| base-inhibition | Sets whether or not base-level activation has a short-term inhibition factor. | `on`, `off`         | `off`        |

If `activation-mode` is `base-level`, three parameters control bias values. The `base-decay` parameter sets the free decay parameter in the base-level model. Note that we do implement the (Petrov, 2006) approximation, with a history size set as a compile-time parameter (default=10). The `base-update-policy` sets the frequency with which activation is recomputed. The default, `stable`, only recomputes activation when a memory is referenced (through storage or retrieval). The `naive` setting will update the entire candidate set of memories (defined as those that match the most constraining cue WME) during a retrieval, which has severe performance detriment and should be used for experimentation or those agents that require high-fidelity retrievals. The `incremental` policy updates a constant number of memories, those with last-access ages defined by the `base-incremental-threshes` set. The `base-inhibition` parameter switches an additional prohibition factor `on` or `off`.

#### Performance Parameters:
| **Parameter** | **Description** | **Possible values** | **Default** |
|:--------------|:----------------|:--------------------|:------------|
| cache-size  | Number of memory pages used in the SQLite cache | 1, 2, ...           | 10000       |
| lazy-commit | Delay writing semantic store changes to file until agent exits | `on`, `off`         | `on`        |
| optimization |  Policy for committing data to disk | `safety`, `performance` | `performance` |
| page-size   | Size of each memory page used in the SQLite cache | 1k, 2k, 4k, 8k, 16k, 32k, 64k | 8k          |
| timers      | Timer granularity | `off`, `one`, `two`, `three` | `off`       |

When the database is stored to disk, the `lazy-commit` and `optimization` parameters control how often cached database changes are written to disk.  These parameters trade off safety in the case of a program crash with database performance.  When `optimization` is set to `performance`, the agent will have an exclusive lock on the database, meaning it cannot be opened concurrently by another SQLite process such as SQLiteMan.  The lock can be relinquished by setting the database to memory or another database and issuing init-soar/`smem --init` or by shutting down the Soar kernel.

### Statistics

Semantic memory tracks statistics over the lifetime of the agent. These can be accessed using `smem --stats <statistic>`.  Running `smem --stats` without a statistic will list the values of all statistics.  Unlike timers, statistics will always be updated. 

Available statistics are:

| **Name** | **Label** | **Description** |
|:---------|:----------|:----------------|
| `act_updates` | Activation Updates | Number of times memory activation has been calculated |
| `db-lib-version` | SQLite Version | SQLite library version |
| `edges`  | Edges     | Number of edges in the semantic store |
| `mem-usage` | Memory Usage | Current SQLite memory usage in bytes |
| `mem-high` | Memory Highwater | High SQLite memory usage watermark in bytes |
| `nodes`  | Nodes     | Number of nodes in the semantic store |
| `queries` | Queries   | Number of times the **query** command has been issued |
| `retrieves` | Retrieves | Number of times the **retrieve** command has been issued |
| `stores` | Stores    | Number of times the **store** command has been issued |

### Timers

Semantic memory also has a set of internal timers that record the durations of certain operations.  Because fine-grained timing can incur runtime costs, semantic memory timers are off by default. Timers of different levels of detail can be turned on by issuing `smem --set timers <level>`, where the levels can be `off`, `one`, `two`, or `three`, `three` being most detailed and resulting in all timers being turned on.  Note that none of the semantic memory statistics nor timing information is reported by the `stats` command.

All timer values are reported in seconds.

Level one

| **Timer** | **Description** |
|:----------|:----------------|
| `_total`  | Total smem operations |

Level two

| **Timer** | **Description** |
|:----------|:----------------|
| `smem_api` | Agent command validation |
| `smem_hash` | Hashing symbols |
| `smem_init` | Semantic store initialization |
| `smem_ncb_retrieval` | Adding concepts (and children) to working memory |
| `smem_query` | Cue-based queries |
| `smem_storage` | Concept storage |

Level three

| **Timer** | **Description** |
|:----------|:----------------|
| three\_activation | Recency information maintenance |

### smem --add

Concepts can be manually added to the semantic store using the
`smem --add <concept>`
command.  The format for specifying the concept is similar to that of adding WMEs to working memory on the RHS of productions.
For example:

```
smem --add {
   (<arithmetic> ^add10-facts <a01> <a02> <a03>)
   (<a01> ^digit1 1 ^digit-10 11)
   (<a02> ^digit1 2 ^digit-10 12)
   (<a03> ^digit1 3 ^digit-10 13)
}
```

Although not shown here, the common "dot-notation" format used in writing productions can also be used for this command. Unlike agent storage, manual storage is automatically recursive. Thus, the above example will add a new concept (represented by the temporary "arithmetic" variable) with three children.  Each child will be its own concept with two constant attribute/value pairs.

### smem --remove

Part or all of the information in the semantic store of some LTI can be manually removed from the semantic store using the

```
smem --remove <concept>
```

command. The format for specifying what to remove is similar to that of adding WMEs to working memory on the RHS of productions. 
For example:
```
smem --remove {
   (@34 ^good-attribute |gibberish value|)
}
```
If `good-attribute` is multi-valued, then all values will remain in the store except `|gibberish value|`. If `|gibberish value|` is the only value, then `good-attribute` will also be removed. It is not possible to use the common "dot-notation" for this command. Manual removal is not recursive.

Another example highlights the ability to remove all of the values for an attribute:
```
smem --remove {
   (@34 ^bad-attribute)
}
```
When a value is not given, all of the values for the given attribute are removed from the LTI in the semantic store.

Also, it is possible to remove all augmentations of some LTI from the semantic store:
```
smem --remove {
   (@34)
}
```
This would remove all attributes and values of `@34` from the semantic store. The LTI will remain in the store, but will lack augmentations.

(Use the following at your own risk.)  Optionally, the user can force removal even in the event of an error:
```
smem -r {(@34 ^bad-attribute ^bad-attribute-2)} force
```
Suppose that LTI `@34` did not contain `bad-attribute`. The above example would remove `bad-attribute-2` even though it would indicate an error (having not found `bad-attribute`).

### smem --query

Queries for LTIs in the semantic store that match some cue can be initialized external to an agent using the
`smem --query <cue> [<num>]`
command. The format for specifying the cue is similar to that of adding a new identifier to working memory in the RHS of a rule:
```
smem --query {
    (<cue> ^attribute <wildcard> ^attribute-2 |constant|)
}
```
Note that the root of the cue structure must be a variable and should be unused in the rest of the cue structure. This command is for testing and the full range of queries accessible to the agent are not yet available for the command. For example, math queries are not supported.

The additional option of `<num>` will trigger the display of the top `<num>` most activated LTIs that matched the cue.

The result of a manual query is either to print that no LTIs could be found or to print the information associated with LTIs that were found in the `print <lti>` format.

### smem --history

When the activation-mode of a semantic store is set to base-level, some history of activation events is stored for each LTI. This history of when some LTI was activated can be displayed:
```
        smem --history @34
```
In the event that semantic memory is not using base-level activation, `history` will mimic `print`.

### Experimental Spreading Activation
| **Parameter** | **Description** | **Possible values** | **Default** |
|:--------------|:----------------|:--------------------|:------------|
| spreading      | Controls whether spreading activation is on or off. | `on`, `off`         | `off`       |
| spreading-limit    | Limits amount of spread from any LTI | 0, 1, ...    | 300    |
| spreading-depth-limit    | Limits depth of spread from any LTI | 0, 1, ..., 10         | 10       |
| spreading-baseline        |  Gives minimum to spread values. | 0, ..., 1 | 0.0001     |
| spreading-continue-probability        |  Gives 1 - (decay factor of spread with distance) | 0, ..., 1 | 0.9     |
| spreading-loop-avoidance        |  Controls whether spread traversal avoids self-loops | `on`, `off` | `off`     |

Spreading activation has been added as an additional mechanism for ranking LTIs in response to a query. Spreading activation is only compatible with base-level activation. `activation-mode` must be set to `base-level` in order to also use spreading. They are additive. Spreading activation serves to rank LTIs that are connected to those currently instanced in Working Memory more highly than those which are unconnected. Note that spreading should be turned on before running an agent. Also, be warned that an agent which loads a database with spreading activation active at the time of back-up currently has undefined behavior and will likely crash as spreading activation currently maintains state in the database.

Spreading activation introduces additional parameters. `spreading-limit` is an absolute cap on the number of LTIs that can receive spread from a given instanced LTI. `spreading-depth-limit` is an absolute cap on the depth to which a Working Memory instance of some LTI can spread into the SMem network. `spreading-baseline` provides a minimum amount of spread that an element can receive. `spreading-continue-probability` sets the amount of spread that is passed on with greater depth. (It can also be thought of as 1-decay where decay is the loss of spread magnitude with depth.) `spreading-loop-avoidance` is a boolean parameter which controls whether or not any given spread traversal can loop back onto itself.

Note that the default settings here are not necessarily appropriate for your application. For many applications, simply changing the structure of the network can yield wildly different query results even with the same spreading parameters.

### See Also

[print](./cmd_print.md)
[trace](./cmd_trace.md) 
[visualize](./cmd_visualize.md)
