# debug

Contains commands that provide access to Soar's internals. Most users will not need to access these commands.

## Synopsis

```bash
======================================================================
                     Debug Commands and Settings
======================================================================
allocate [pool blocks]         Allocates extra memory to a memory pool
internal-symbols                                   Prints symbol table
port                                             Prints listening port
time <command> [args]           Executes command and prints time spent
```

## debug allocate

```bash
debug allocate [pool blocks]
```

This `allocate` command allocates additional blocks of memory for a specified
memory pool. Each block is 32 kilobyte.

Soar allocates blocks of memory for its memory pools as it is needed during a
run (or during other actions like loading productions). Unfortunately, this
behavior translates to an increased run time for the first run of a
memory-intensive agent. To mitigate this, blocks can be allocated before a run
by using this command.

Issuing the command with no parameters lists current pool usage, exactly like
[stats](./cmd_stats.md) command's memory flag.

Issuing the command with part of a pool's name and a positive integer will
allocate that many additional blocks for the specified pool. Only the first few
letters of the pool's name are necessary. If more than one pool starts with the
given letters, which pool will be chosen is unspecified.

Memory pool block size in this context is approximately 32 kilobytes, the exact
size determined during agent initialization.

### debug internal-symbols

The `internal-symbols` command prints information about the Soar symbol table.
Such information is typically only useful for users attempting to debug Soar by
locating memory leaks or examining I/O structure.

### debug port

The `port` command prints the port the kernel instance is listening on.

### debug time

```bash
debug time command [arguments]
```

The `time` command uses a system clock timer to record the time spent while
executing a command. The most common use for this is to time how long an agent
takes to run.

### See Also

-   [stats](./cmd_stats.md)
