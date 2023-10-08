# Semantic Memory

Soar’s semantic memory is a repository for long-term declarative knowledge, supplement-
ing what is contained in short-term working memory (and production memory). Episodic
memory, which contains memories of the agent’s experiences, is described in [Chapter 7](./07_EpisodicMemory.md). The
knowledge encoded in episodic memory is organized temporally, and specific information is
embedded within the context of when it was experienced, whereas knowledge in semantic
memory is independent of any specific context, representing more general facts about the
world.

This chapter is organized as follows: [semantic memory structures in working
memory](#working-memory-structure); [representation of knowledge in semantic
memory](#knowledge-representation); [storing semantic
knowledge](#storing-semantic-knowledge); [retrieving semantic
knowledge](#retrieving-semantic-knowledge); and a [discussion of
performance](#performance). The detailed behavior of semantic memory is
determined by numerous parameters that can be controlled and configured via the
**smem** command. Please refer to the documentation for that command in Section
9.5.1 on page 243.

## Working Memory Structure

Upon creation of a new state in working memory (see Section 2.7.1 on page 28; Section 3.4 on
page 85), the architecture creates the following augmentations to facilitate agent interaction
with semantic memory:

```Soar
(<s> ^smem <smem>)
(<smem> ^command <smem-c>)
(<smem> ^result <smem-r>)
```

As rules augment the command structure in order to access/change semantic knowledge (6.3,
6.4), semantic memory augments the result structure in response. Production actions
should not remove augmentations of the result structure directly, as semantic memory will
maintain these WMEs.

Figure 6.1: Example long-term identifier with four augmentations.

## Knowledge Representation

The representation of knowledge in semantic memory is similar to that in working memory
(see Section 2.2 on page 14) – both include graph structures that are composed of symbolic
elements consisting of an identifier, an attribute, and a value. It is important to note,
however, key differences:

Currently semantic memory only supports attributes that are symbolic constants
(string, integer, or decimal), but not attributes that are identifiers

Whereas working memory is a single, connected, directed graph, semantic memory can
be disconnected, consisting of multiple directed, connected sub-graphs

From Soar 9.6 onward, **Long-termidentifiers** (LTIs) are defined as identifiers that
exist in semantic memory only. Each LTI is permanently associated with a specific number
that labels it (e.g. @5 or @7). Instances of an LTI can be loaded into working memory as
regular short-term identifiers (STIs) linked with that specific LTI. For clarity, when printed,
a short-term identifier associated with an LTI is followed with the label of that LTI. For
example, if the working memory ID L7 is associated with the LTI named `@29`, printing that
STI would appear as `L7` (`@29`).

When presented in a figure, long-term identifiers will be indicated by a
double-circle. For instance, Figure 6.1 depicts the long-term identifier @68,
with four augmentations, representing the addition fact of `6 + 7 = 13` (or,
rather, 3, carry 1, in context of multi-column arithmetic).

### Integrating Long-Term Identifiers with Soar

Integrating long-term identifiers in Soar presents a number of theoretical and
implementation challenges. This section discusses the state of integration with
each of Soar’s memories/learning mechanisms.


####  Working Memory

Long-term identifiers themselves never exist in working memory. Rather, instances of long
term memories are loaded into working memory as STIs through queries or retrievals, and
manipulated just like any other WMEs. Changes to any STI augmentations do not directly
have any effect upon linked LTIs in semantic memory. Changes to LTIs themselves only
occur though store commands on the command link or through command-line directives
such as `smem --add` (see below).

Each time an agent loads an instance of a certain LTI from semantic memory into working
memory using queries or retrievals, the instance created will always be a new unique STI.
This means that if same long-term memory is retrieved multiple times in succession, each
retrieval will result in a different STI instance, each linked to the same LTI. A benefit of this
is that a retrieved long-term memory can be modified without compromising the ability to
recall what the actual stored memory is.^1

(^1) Before Soar 9.6, LTIs were themselves retrieved into working memory. This meant all augmentations
to such IDs, whether from the original retrieval or added after retrieval, would always be merged under the
same ID, unless deep-copy was used to make a duplicate short-term memory.

####  Procedural Memory

Soar productions can use various conditions to test whether an STI is associated with an
LTI or whether two STIs are linked to the same LTI (see Section 3.3.5.3 on page 53). LTI
names (e.g. `@6`) may not appear in the action side of productions.

####  Episodic Memory

Episodic memory (see Section 7 on page 157) faithfully captures LTI-linked STIs, including
the episode of transition. Retrieved episodes contain STIs as they existed during the episode,
regardless of any changes to linked LTIs that transpired since the episode occurred.

## Storing Semantic Knowledge

###Store command

An agent stores a long-term identifier in semantic memory by creating a **^store** command:
this is a WME whose identifier is the command link of a state’s smem structure, the attribute
is store, and the value is a short-term identifier.

```Soar
<s> ^smem.command.store <identifier>
```

Semantic memory will encode and store all WMEs whose identifier is the value of the store
command. Storing deeper levels of working memory is achieved through multiple store commands.

Multiple store commands can be issued in parallel. Storage commands are processed on
every state at the end of every phase of every decision cycle. Storage is guaranteed to
succeed and a status WME will be created, where the identifier is the **^result** link of the
smem structure of that state, the attribute is success, and the value is the value of the store
command above.

```Soar
<s> ^smem.result.success <identifier>
```

If the identifier used in the store command is not linked to any existing LTIs, a new LTI
will be created in smem and the stored STI will be linked to it. If the identifier used in
the store command is already linked to an LTI, the store will overwrite that long-term
memory. For example, if an existing LTI@5had augmentations^A do ^B re ^C mi, and a
storecommand stored short-term identifierL35which was linked to@5but had only the
augmentation^D fa, the LTI@5would be changed to only have^D fa.

### Store-new command

The **^store-new** command structure is just like the ^store command, except that smem
will always store the given memory as an entirely new structure, regardless of whether the
given STI was linked to an existing LTI or not. Any STIs that don’t already have links will
get linked to the newly created LTIs. But if a stored STI was already linked to some LTI,
Soar will not re-link it to the newly created LTI.

If this behavior is not desired, the agent can add a **^link-to-new-LTM yes** augmentation
to override this behavior. One use for this setting is to allow chunking to backtrace through
a stored memory in a manner that will be consistent with a later state of memory when the
newly stored LTI is retrieved again.

### User-Initiated Storage

Semantic memory provides agent designers the ability to store semantic knowledge via the
**add** switch of the **smem** command (see Section 9.5.1 on page 243). The format of the
command is nearly identical to the working memory manipulation components of the RHS
of a production (i.e. no RHS-functions; see Section 3.3.6 on page 67). For instance:

```Soar
smem --add {
(<arithmetic> ^add10-facts <a01> <a02> <a03>)
(<a01> ^digit1 1 ^digit-10 11)
(<a02> ^digit1 2 ^digit-10 12)
(<a03> ^digit1 3 ^digit-10 13)
}
```

Unlike agent storage, declarative storage is automatically recursive. Thus, this
command instance will add a new long-term identifier (represented by the
temporary ’arithmetic’ variable) with three augmentations. The value of each
augmentation will each become an LTI with two constant attribute/value pairs.
Manual storage can be arbitrarily complex and use standard dot-notation. The add
command also supports hardcoded LTI ids such as@1in place of variables.

### Storage Location

Semantic memory uses SQLite to facilitate efficient and standardized storage and querying of
knowledge. The semantic store can be maintained in memory or on disk (per the database
and path parameters; see Section 9.5.1). If the store is located on disk, users can use any
standard SQLite programs/components to access/query its contents. However, using a disk-
based semantic store is very costly (performance is discussed in greater detail in Section 6.5
on page 155), and running in memory is recommended for most runs.

Note that changes to storage parameters, for example database, path and append will
not have an effect until the database is used after an initialization. This happens either
shortly after launch (on first use) or after a database initialization command is issued. To
switch databases or database storage types while running, set your new parameters and then
perform an –init command.

The **path** parameter specifies the file system path the database is stored in. When path is
set to a valid file system path and database mode is set to file, then the SQLite database is
written to that path.

The **append** parameter will determine whether all existing facts stored in a database on
disk will be erased when semantic memory loads. Note that this affects soar init also. In
other words, if the append setting is off, all semantic facts stored to disk will be lost when
a soar init is performed. For semantic memory,append mode is on by default.

Note: As of version 9.3.3, Soar used a new schema for the semantic memory database.
This means databases from 9.3.2 and below can no longer be loaded. A conversion utility is
available in Soar 9.4 to convert from the old schema to the new one.

The **lazy-commit** parameter is a performance optimization. If set to on(default), disk
databases will not reflect semantic memory changes until the Soar kernel shuts down. This
improves performance by avoiding disk writes. The optimization parameter (see Section
<!-- TODO Text missing here? -->

## Retrieving Semantic Knowledge

An agent retrieves knowledge from semantic memory by creating an appropriate command
(we detail the types of commands below) on the command link of a state’s smem structure.
At the end of the output of each decision, semantic memory processes each state’s smem
`^command` structure. Results, meta-data, and errors are added to the result structure of
that state’s smems tructure.

Only one type of retrieval command (which may include optional modifiers) can be issued
per state in a single decision cycle. Malformed commands (including attempts at multiple
retrieval types) will result in an error:

```Soar
<s> ^smem.result.bad-cmd <smem-c>
```

Where the `<smem-c>` variable refers to the command structure of the state.

After a command has been processed, semantic memory will ignore it until some aspect of
the command structure changes (via addition/removal of WMEs). When this occurs, the
result structure is cleared and the new command (if one exists) is processed.

### Non-Cue-Based Retrievals

A non-cue-based retrieval is a request by the agent to reflect in working memory the current
augmentations of an LTI in semantic memory. The command WME has a **retrieve**
attribute and an LTI-linked identifier value:

```Soar
<s> ^smem.command.retrieve <lti>
```

If the value of the command is not an LTI-linked identifier, an error will result:

```Soar
<s> ^smem.result.failure <lti>
```

Otherwise, two new WMEs will be placed on the result structure:

```Soar
<s> ^smem.result.success <lti>
<s> ^smem.result.retrieved <lti>
```

All augmentations of the long-term identifier in semantic memory will be created as new
WMEs in working memory.

### Cue-Based Retrievals

A cue-based retrieval performs a search for a long-term identifier in semantic memory whose
augmentations exactly match an agent-supplied cue, as well as optional cue modifiers.

A cue is composed of WMEs that describe the augmentations of a long-term identifier. A
cue WME with a constant value denotes an exact match of both attribute and value. A
cue WME with an LTI-linked identifier as its value denotes an exact match of attribute and
linked LTI. A cue WME with a short-term identifier as its value denotes an exact match of
attribute, but with any value (constant or identifier).

A cue-based retrieval command has a **query** attribute and an identifier value, the cue:

```Soar
<s> ^smem.command.query <cue>
```

For instance, consider the following rule that creates a cue-based retrieval command:

```Soar
sp {smem*sample*query
(state <s> ^smem.command <scmd>
^lti <lti>
^input-link.foo <bar>)
-->
(<scmd> ^query <q>)
(<q> ^name <any-name>
^foo <bar>
^associate <lti>
^age 25)
}
```

In this example, assume that the `<lti>` variable will match a short-term identifier which is
linked to a long-term identifier and that the `<bar>` variable will match a constant. Thus,
the query requests retrieval of a long-term memory with augmentations that satisfy ALL of
the following requirements:

- Attribute name with ANY value
- Attribute foo with value equal to that of variable `<bar>` at the time this rule fires
- Attribute associate with value that is the same long-term identifier as that linked to
by the `<lti>` STI at the time this rule fires
- Attribute age with integer value 25

If no long-term identifier satisfies ALL of these requirements, an error is returned:

```Soar
<s> ^smem.result.failure <cue>
```

Otherwise, two WMEs are added:

```Soar
<s> ^smem.result.success <cue>
<s> ^smem.result.retrieved <retrieved-lti>
```

The result `<retrieved-lti>` will be a new short-term identifier linked to the result LTI.

As with non-cue-based retrievals, all of the augmentations of the long-term identifier in
semantic memory are added as new WMEs to working memory. If these augmentations
include other LTIs in smem, they too are instantiated into new short-term identifiers in
working memory.

It is possible that multiple long-term identifiers match the cue equally well. In this case, se-
mantic memory will retrieve the long-term identifier that was most recently stored/retrieved.
(More accurately, it will retrieve the LTI with the greatest activation value. See below.)

The cue-based retrieval process can be further tempered using optional modifiers:

The prohibit command requires that the retrieved long-term identifier is not equal
to that linked with the supplied long-term identifier:

```
<s> ^smem.command.prohibit <bad-lti>
```


Multiple prohibit command WMEs may be issued as modifiers to a single cue-based
retrieval. This method can be used to iterate over all matching long-term identifiers.

The neg-query command requires that the retrieved long-term identifier does NOT
contain a set of attributes/attribute-value pairs:

```Soar
<s> ^smem.command.neg-query <cue>
```

The syntax of this command is identical to that of regular/ positive query command.

The math-query command requires that the retrieved long term identifier contains
an attribute value pair that meets a specified mathematical condition. This condition
can either be a conditional query or a superlative query.
Conditional queries are of the format:

```Soar
<s> ^smem.command.math-query.<cue-attribute>.<condition-name> <value>
```

Superlative queries do not use a value argument and are of the format:

```Soar
<s> ^smem.command.math-query.<cue-attribute>.<condition-name>
```

Values used in math queries must be integer or float type values. Currently supported
condition names are:

- less A value less than the given argument
- greater A value greater than the given argument
- less-or-equal A value less than or equal to the given argument
- greater-or-equal A value greater than or equal to the given argument
- max The maximum value for the attribute
- min The minimum value for the attribute

####  Activation

When an agent issues a cue-based retrieval and multiple LTIs match the cue, the LTI which
semantic memory provides to working memory as the result is the LTI which not only
matches the cue, but also has the highest **activation** value. Semantic memory has several
activation methods available for this purpose.

The simplest activation methods are **recency** and **frequency** activation. Recency activa-
tion attaches a time-stamp to each LTI and records the time of last retrieval. Using recency
activation, the LTI which matches the cue and was also most-recently retrieved is the one
which is returned as the result for a query. Frequency activation attaches a counter to each
LTI and records the number of retrievals for that LTI. Using frequency activation, the LTI
which matches the cue and also was most frequently used is returned as the result of the
query. By default, Soar uses recency activation.

**Base-level activation** can be thought of as a mixture of both recency and frequency.
Soar makes use of the following equation (known as the Petrov approximation^2 ) for calculating base-level activation:


<!-- TODO forumlas -->
where n is the number of activation boosts, tnis the time since the first boost, tkis the time
of the kth boost, dis the decay factor, and kis the number of recent activation boosts which
are stored. (In Soar,kis hard-coded to 10.) To use base-level activation, use the following
CLI command when sourcing an agent:

```bash
smem --set activation-mode base-level
```

**Spreading activation** is new to Soar 9.6.0 and provides a secondary type of
activation beyond the previous methods. First, spreading activation requires that
base-level activation is also being used. They are considered additive. This
value does not represent recency or frequency of use, but rather
context-relatedness. Spreading activation increases the activation of LTIs which
are linked to by identifiers currently present in working memory.^3 Such LTIs
may be thought of as spreading sources.

Spreading activation values spread according to network structure. That is, spreading sources
will add to the spreading activation values of any of their child LTIs, according to the directed
graph structure with in smem(not working memory). The amount of spread is controlled by
the
**spreading-continue-probability** parameter. By default this value is set to0.9.
This would mean that90%of an LTI’s spreading activation value would be divided among
its direct children (without subtracting from its own value). This value is multiplicative with
depth. A "grandchild" LTI, connected at a distance of two from a source LTI, would receive
spreading according to 0. 9 × 0 .9 = 0.81 of the source spreading activation value.

Spreading activation values are updated each decision cycle only as needed for specific
smem retrievals. For efficiency, two limits exist for the amount of spread calculated. The
**spreading-limit** parameter limits how many LTIs can receive spread from a given
spreading source LTI. By default, this value is ( 300 ). Spread is distributed in a magnitude-
first manner to all descendants of a source. (Without edge-weights, this simplifies to breadth-
first.) Once the number of LTIs that have been given spread from a given source reaches
the max value indicated by spreading-limit, no more is calculated for that source that
update cycle, and the next spreading source’s contributions are calculated. The maximum
depth of descendants that can receive spread contributions from a source is similarly given
by the **spreading-depth-limit** parameter. By default, this value is ( 10 ).

In order to use spreading activation, use the following command:

```bash
smem --set spreading on
```

(^2) Petrov, Alexander A. "Computationally efficient approximation of the base-level learning equation in
ACT-R."Proceedings of the seventh international conference on cognitive modeling.2006.
(^3) Specifically, linked to by STIs that have augmentations.

Also, spreading activation can make use of working memory activation for adjusting edge
weights and for providing nonuniform initial magnitude of spreading for sources of spread.
This functionality is optional. To enable the updating of edge-weights, use the command:

```bash
smem --set spreading-edge-updating on
```

and to enable working memory activation to modulate the magnitude of spread from sources,
use the command:

```bash
smem --set spreading-wma-source on
```

For most use-cases, base-level activation is sufficient to provide an agent with relevant knowl-
edge in response to a query. However, to provide an agent with more context-relevant results
as opposed to results based only on historical usage, one must use spreading activation.

### Retrieval with Depth

For either cue-based or non-cue-based retrieval, it is possible to retrieve a long-term identifier
with additional depth. Using the **depth** parameter allows the agent to retrieve a greater
amount of the memory structure than it would have by retrieving not only the long-term
identifier’s attributes and values, but also by recursively adding to working memory the
attributes and values of that long-term identifier’s children.

Depth is an additional command attribute, like query:

```Soar
<s> ^smem.command.query <cue>
^smem.command.depth <integer>
```

For instance, the following rule uses depth with a cue-based retrieval:

```Soar
<s> ^smem.command.query <cue>
sp {smem*sample*query
(state <s> ^smem.command <sc>
^input-link.foo <bar>)
-->
(<sc> ^query <q>
^depth 2)
(<q> ^name <any-name>
^foo <bar>
^associate <lti>
^age 25)
}
```

In the example above and without using depth, the long-term identifier referenced by

```Soar
^associate <lti>
```

would not also have its attributes and values be retrieved. With a depth of 2 or more, that
long-term identifier also has its attributes and values added to working memory.

Depth can incur a large cost depending on the specified depth and the structures stored in
semantic memory.

## Performance

Initial empirical results with toy agents show that semantic memory queries
carry up to a 40% overhead as compared to comparable rete matching. However, the
retrieval mechanism implements some basic query optimization: statistics are
maintained about all stored knowledge. When a query is issued, semantic memory
re-orders the cue such as to minimize expected query time. Because only perfect
matches are acceptable, and there is no symbol variablization, semantic memory
retrievals do not contend with the same combinatorial search space as the rete.
Preliminary empirical study shows that semantic memory maintains sub-millisecond
retrieval time for a large class of queries, even in very large stores (millions
of nodes/edges).

Once the number of long-term identifiers overcomes initial overhead (about 1000 WMEs),
initial empirical study shows that semantic storage requires far less than 1KB per stored
WME.

### Math queries

There are some additional performance considerations when using math queries
during retrieval. Initial testing indicates that conditional queries show the
same time growth with respect to the number of memories in comparison to
non-math queries, however the actual time for retrieval may be slightly longer.
Superlative queries will often show a worse result than similar non-superlative
queries, because the current implementation of semantic memory requires them to
iterate over any memory that matches all other involved cues.

### Performance Tweaking

When using a database stored to disk, several parameters become crucial to performance.
The first is **lazy-commit** , which controls when database changes are written to disk.
The default setting (on) will keep all writes in memory and only commit to disk upon re-
initialization (quitting the agent or issuing the init command). The off setting will write
each change to disk and thus incurs massive I/O delay.

The next parameter is **thresh**. This has to do with the locality of
storing/updating activation information with semantic augmentations. By default,
all WME augmentations are incrementally sorted by activation, such that
cue-based retrievals need not sort large number of candidate long-term
identifiers on demand, and thus retrieval time is independent of cue
selectivity. However, each activation update (such as after a retrieval) incurs
an update cost linear in the number of augmentations. If the number of
augmentations for a long-term identifier is large, this cost can dominate. Thus,
the thresh parameter sets the upper bound of augmentations, after which
activation is stored with the long-term identifier. This allows the user to
establish a balance between cost of updating augmentation activation and the
number of long-term identifiers that must be pre-sorted during a cue-based
retrieval. As long as the threshold is greater than the number of augmentations
of most long-term identifiers, performance should be fine (as it will bound the
effects of selectivity).

The next two parameters deal with the SQLite cache, which is a memory store used to speed
operations like queries by keeping in memory structures like levels of index B+-trees. The
first parameter, **page-size** , indicates the size, in bytes, of each cache page. The second
parameter, **cache-size** , suggests to SQLite how many pages are available for the cache.
Total cache size is the product of these two parameter settings. The cache memory is not pre-
allocated, so short/small runs will not necessarily make use of this space. Generally speaking,
a greater number of cache pages will benefit query time, as SQLite can keep necessary meta-
data in memory. However, some documented situations have shown improved performance
from decreasing cache pages to increase memory locality. This is of greater concern when
dealing with file-based databases, versus in-memory. The size of each page, however, may be
important whether databases are disk- or memory-based. This setting can have far-reaching
consequences, such as index B+-tree depth. While this setting can be dependent upon a
particular situation, a good heuristic is that short, simple runs should use small values of
the page size (1k,2k,4k), whereas longer, more complicated runs will benefit from larger
values (8k,16k,32k,64k). The episodic memory chapter (see Section 7.4 on page 163) has
some further empirical evidence to assist in setting these parameters for very large stores.

The next parameter is **optimization**. The safety parameter setting will use
SQLite default settings. If data integrity is of importance, this setting is
ideal. The performance setting will make use of lesser data consistency
guarantees for significantly greater performance. First, writes are no longer
synchronous with the OS (synchronous pragma), thus semantic memory won’t wait
for writes to complete before continuing execution. Second, transaction
journaling is turned off (journalmode pragma), thus groups of modifications to
the semantic store are not atomic (and thus interruptions due to
application/os/hardware failure could lead to inconsistent database state).
Finally, upon initialization, semantic mem- ory maintains a continuous exclusive
lock to the database (locking mode pragma), thus other applications/agents
cannot make simultaneous read/write calls to the database (thereby reducing the
need for potentially expensive system calls to secure/release file locks).

Finally, maintaining accurate operation timers can be relatively expensive in Soar. Thus,
these should be enabled with caution and understanding of their limitations. First, they
will affect performance, depending on the level (set via the **timers** parameter). A level
of three, for instance, times every modification to long-term identifier recency statistics.
Furthermore, because these iterations are relatively cheap (typically a single step in the
linked-list of a b+-tree), timer values are typically unreliable (depending upon the system,
resolution is 1 microsecond or more).