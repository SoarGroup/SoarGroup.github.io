## epmem

Control the behavior of episodic memory.

#### Synopsis

```
epmem
epmem -e|--enable|--on
epmem -d|--disable|--off
epmem -i|--init
epmem -c|--close
epmem -g|--get <parameter>
epmem -s|--set <parameter> <value>
epmem -S|--stats [<statistic>]
epmem -t|--timers [<timer>]
epmem -v|--viz <episode id>
epmem -p|--print <episode id>
epmem -b|--backup <file name>
```

#### Options:

| **Option** | **Description** |
|:-----------|:----------------|
| `-e, --enable, --on` | Enable episodic memory. |
| `-d, --disable, --off` | Disable episodic memory. |
| `-i, --init` | Re-initialize episodic memory |
| `-c, --close` | Disconnect from episodic memory |
| `-g, --get` | Print current parameter setting |
| `-s, --set` | Set parameter value |
| `-S, --stats` | Print statistic summary or specific statistic |
| `-t, --timers` | Print timer summary or specific statistic |
| `-v, --viz` | Print episode in graphviz format |
| `-p, --print` | Print episode in user-readable format |
| `-b, --backup` | Creates a backup of the episodic database on disk |

#### Description

The `epmem` command is used to change all behaviors of the episodic memory module, except for watch output, which is controlled by the `trace --epmem` command.

### Parameters

Due to the large number of parameters, the `epmem` command uses the 
`--get|--set <parameter> <value>` convention rather than individual switches for each parameter.  Running `epmem` without any switches displays a summary of the parameter settings.

#### Main Parameters:

| **Parameter** | **Description** | **Possible values** | **Default** |
|:--------------|:----------------|:--------------------|:------------|
| `append`      | Controls whether database is overwritten or appended when opening or re-initializing | `on`, `off`         | `off`       |
| `balance`     | Linear weight of match cardinality (1) vs. working memory activation (0) used in calculating match score | `[`0, 1`]`          | 1           |
| `database`    | Database storage method | `file`, `memory`    | `memory`    |
| `exclusions`  | Toggle the exclusion of an attribute string constant | _any string_        | `epmem, smem` |
| `force`       | Forces episode encoding/ignoring in the next storage phase | `ignore`, `remember`, `off` | `off`       |
| `learning`    |  Episodic memory enabled  | `on`, `off`         | `off`       |
| `merge`       | Controls how retrievals interact with long-term identifiers in working memory | `none`, `add`       | `none`      |
| `path`        |  Location of database file | _empty_, _some path_ | _empty_     |
| `phase`       | Decision cycle phase to encode new episodes and process epmem link commands | `output`, `selection` | `output`    |
| `trigger`     | How episode encoding is triggered | `dc`, `output`, `none` | `output`    |

#### Performance Parameters:

| **Parameter** | **Description** | **Possible values** | **Default** |
|:--------------|:----------------|:--------------------|:------------|
| `cache-size`  | Number of memory pages used in the SQLite cache | 1, 2, ...           | 10000       |
| `graph-match` | Graph matching enabled | `on`, `off`         | `on`        |
| `graph-match-ordering` | Ordering of identifiers during graph match | `undefined`, `dfs`, `mcv` | `undefined` |
| `lazy-commit` | Delay writing semantic store changes to file until agent exits | `on`, `off`         | `on`        |
| `optimization` |  Policy for committing data to disk | `safety`, `performance` | `performance` |
| `page-size`   | Size of each memory page used in the SQLite cache | 1k, 2k, 4k, 8k, 16k, 32k, 64k | 8k          |
| `timers`      | Timer granularity | `off`, `one`, `two`, `three` | `off`       |

The `learning` parameter turns the episodic memory module on or off. When `learning` is set to `off`, no new episodes are encoded and no commands put on the epmem link are processed.  This is the same as using the enable and disable commands.

The `phase` parameter determines which decision cycle phase episode encoding and retrieval will be performed.

The `trigger` parameter controls when new episodes will be encoded.  When it is set to `output`, new episodes will be encoded only if the agent made modifications to the output-link during that decision cycle.  When set to 'dc', new episodes will be encoded every decision cycle.

The `exclusions` parameter can be used to prevent episodic memory from encoding parts of working memory into new episodes.  The value of `exclusions` is a list of string constants.  During encoding, episodic memory will walk working memory starting from the top state identifier.  If it encounters a WME whose attribute is a member of the `exclusions` list, episodic memory will ignore that WME and abort walking the children of that WME, and they will not be included in the encoded episode.  Note that if the children of the excluded WME can be reached from top state via an alternative non-excluded path, they will still be included in the encoded episode.  The `exclusions` parameter behaves differently from other parameters in that issuing `epmem --set exclusions <val>` does not set its value to `<val>`. Instead, it will toggle the membership of `<val>` in the `exclusions` list.

The `path` parameter specifies the file system path the database is stored in.  When `path` is set to a valid file system path and database mode is set to file, then the SQLite database is written to that path.

The append parameter will determine whether all existing episodes recorded in a database on disk will be erased when epmem loads it. Note that this affects episodic memory re-initialization also, i.e. if the append setting is off, all episodic memories stored to disk will be lost when an init-soar is performed. Note that episodic memory cannot currently append to an in-memory database.  If you perform an init-soar while using an in-memory database, all current episodes stored will be cleared.

Note that changes to database, path and append will not have an effect until the database is used after an initialization. This happens either shortly after launch (on first use) or after a database initialization command is issued.  To switch databases or database storage types after running, set your new parameters and then perform an `epmem --init`.

The `epmem --backup` command can be used to make a copy of the current state of the database, whether in memory or on disk. This command will commit all outstanding changes before initiating the copy.

When the database is stored to disk, the `lazy-commit` and `optimization` parameters control how often cached database changes are written to disk.  These parameters trade off safety in the case of a program crash with database performance.  When `optimization` is set to `performance`, the agent will have an exclusive lock on the database, meaning it cannot be opened concurrently by another SQLite process such as SQLiteMan. The lock can be relinquished by setting the database to memory or another database and issuing init-soar/`epmem --init` or by shutting down the Soar kernel.

The `balance` parameter sets the linear weight of match cardinality vs. cue activation. As a performance optimization, when the value is 1 (default), activation is not computed. If this value is not 1 (even close, such as 0.99), and working memory activation is enabled, this value will be computed for each leaf WME, which may incur a noticeable cost, depending upon the overall complexity of the retrieval.

The `graph-match-ordering` parameter sets the heuristic by which identifiers are ordered during graph match (assuming `graph-match` is `on`). The default, `undefined`, does not enforce any order and may be sufficient for small cues. For more complex cues, there will be a one-time sorting cost, during each retrieval, if the parameter value is changed. The currently available heuristics are depth-first search (`dfs`) and most-constrained variable (`mcv`). It is advised that you attempt these heuristics to improve performance if the `query_graph_match` timer reveals that graph matching is dominating retrieval time.

The `merge` parameter controls how the augmentations of retrieved long-term identifiers (LTIs) interact with an existing LTI in working memory. If the LTI is not in working memory or has no augmentations in working memory, this parameter has no effect. If the augmentation is in working memory and has augmentations, by default (`none`), episodic memory will not augment the LTI. If the parameter is set to `add` then any augmentations that augmented the LTI in a retrieved episode are added to working memory.

### Statistics

Episodic memory tracks statistics over the lifetime of the agent. These can be accessed using `epmem --stats <statistic>`.  Running `epmem --stats` without a statistic will list the values of all statistics.  Unlike timers, statistics will always be updated. 
Available statistics are:

| **Name** | **Label** | **Description** |
|:---------|:----------|:----------------|
| `time`   | Time      | Current episode ID |
| `db-lib-version` | SQLite Version | SQLite library version |
| `mem-usage` | Memory Usage | Current SQLite memory usage in bytes |
| `mem-high` | Memory Highwater | High SQLite memory usage watermark in bytes |
| `queries` | Queries   | Number of times the **query** command has been processed |
| `nexts`  | Nexts     | Number of times the **next** command has been processed |
| `prevs`  | Prevs     | Number of times the **previous** command has been processed |
| `ncb-wmes` | Last Retrieval WMEs | Number of WMEs added to working memory in last reconstruction |
| `qry-pos` | Last Query Positive | Number of leaf WMEs in the **query** cue of last cue-based retrieval |
| `qry-neg` | Last Query Negative | Number of leaf WMEs in the **neg-query** cue of the last cue-based retrieval |
| `qry-ret` | Last Query Retrieved | Episode ID of last retrieval |
| `qry-card` | Last Query Cardinality | Match cardinality of last cue-based retrieval |
| `qry-lits` | Last Query Literals | Number of literals in the DNF graph of last cue-based retrieval |

### Timers

Episodic memory also has a set of internal timers that record the durations of certain operations.  Because fine-grained timing can incur runtime costs, episodic memory timers are off by default. Timers of different levels of detail can be turned on by issuing `epmem --set timers <level>`, where the levels can be `off`, `one`, `two`, or `three`, `three` being most detailed and resulting in all timers being turned on.  Note that none of the episodic memory statistics nor timing information is reported by the `stats` command.

All timer values are reported in seconds.

Level one

| **Timer** | **Description** |
|:----------|:----------------|
| `_total`  | Total epmem operations |

Level two

| **Timer** | **Description** |
|:----------|:----------------|
| `epmem_api` | Agent command validation |
| `epmem_hash` | Hashing symbols |
| `epmem_init` | Episodic store initialization |
| `epmem_ncb_retrieval` | Episode reconstruction |
| `epmem_next` | Determining next episode |
| `epmem_prev` | Determining previous episode |
| `epmem_query` | Cue-based query |
| `epmem_storage` | Encoding new episodes |
| `epmem_trigger` | Deciding whether new episodes should be encoded |
| `epmem_wm_phase` | Converting preference assertions to working memory changes |

Level three

| **Timer** | **Description** |
|:----------|:----------------|
| `ncb_edge` | Collecting edges during reconstruction |
| `ncb_edge_rit` | Collecting edges from relational interval tree |
| `ncb_node` | Collecting nodes during reconstruction |
| `ncb_node_rit` | Collecting nodes from relational interval tree |
| `query_cleanup` | Deleting dynamic data structures |
| `query_dnf` | Building the first level of the DNF |
| `query_graph_match` | Graph match     |
| `query_result` | Putting the episode in working memory |
| `query_sql_edge` | SQL query for an edge |
| `query_sql_end_ep` | SQL query for the end of the range of an edge |
| `query_sql_end_now` | SQL query for the end of the now of an edge |
| `query_sql_end_point` | SQL query for the end of the point of an edge |
| `query_sql_start_ep` | SQL query for the start of the range of an edge |
| `query_sql_start_now` | SQL query for the start of the now of an edge |
| `query_sql_start_point` | SQL query for the start of the point of an edge |
| `query_walk` | Walking the intervals |
| `query_walk_edge` | Expanding edges while walking the intervals |
| `query_walk_interval` | Updating satisfaction while walking the intervals |

#### Visualization

When debugging agents using episodic memory it is often useful to inspect the contents of individual episodes.  Running
`epmem --viz <episode id>` will output the contents of an episode in graphviz format.  For more information on this format and visualization tools, see http://www.graphviz.org. The `epmem --print` option has the same syntax, but outputs text that is similar to using the `print` command to get the substructure of an identifier in working memory, which is possibly more useful for interactive debugging.

### See Also

[trace](./cmd_trace.md) 
[wm](./cmd_wm.md)
