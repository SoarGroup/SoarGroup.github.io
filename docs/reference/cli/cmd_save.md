# save

Saves chunks, rete networks and percept streams.

## Synopsis

```bash
======================================================
-            Save Sub-Commands and Options           -
======================================================
save [? | help]
------------------------------------------------------
save agent                           <filename>
save chunks                          <filename>
------------------------------------------------------
save percepts                        --open <filename>
save percepts                        [--close --flush]
------------------------------------------------------
save rete-network                    --save <filename>
------------------------------------------------------
For a detailed explanation of sub-commands:  help save
```

### save agent

The `save agent` command will write all procedural and semantic memory to disk,
as well as many commonly used settings. This command creates a standard `.soar`
text file, with semantic memory stored as a series of `smem --add` commands.

### save chunks

The `save chunks` command will write all chunks in memory to disk. This command
creates a standard `.soar` text file.

### save rete-network

The `save rete-network` command saves the current Rete net to a file. The Rete
net is Soar's internal representation of production memory; the conditions of
productions are reordered and common substructures are shared across different
productions. This command provides a fast method of saving and loading
productions since a special format is used and no parsing is necessary. Rete-net
files are portable across platforms that support Soar.

Note that justifications cannot be present when saving the Rete net. Issuing a
[production excise -j](./cmd_production.md) before saving a Rete net will remove
all justifications.

If the filename contains a suffix of `.Z`, then the file is compressed
automatically when it is saved and uncompressed when it is loaded. Compressed
files may not be portable to another platform if that platform does not support
the same uncompress utility.

```bash
save rete-network -s <filename>
```

### save percepts

Store all incoming input wmes in a file for reloading later. Commands are
recorded decision cycle by decision cycle. Use the command [load
percepts](./cmd_load.md) to replay the sequence.

Note that this command seeds the random number generator and writes the seed to
the capture file.

| **Option**    | **Description**                                                                                                          |
| :------------ | :----------------------------------------------------------------------------------------------------------------------- |
| `filename`    | Open filename and begin recording input.                                                                                 |
| `-o, --open`  | Writes captured input to file overwriting any existing data.                                                             |
| `-f, --flush` | Writes input to file as soon as it is encountered instead of storing it in RAM and writing when capturing is turned off. |
| `-c, --close` | Stop capturing input and close the file, writing captured input unless the flush option is given.                        |

```bash
save percepts -o <filename>
...
save percepts -c
```

## Default Aliases

```bash
capture-input        save percepts
```

### See Also

-   [production](./cmd_production.md)
-   [soar](./cmd_soar.md)
-   [load](./cmd_load.md)
