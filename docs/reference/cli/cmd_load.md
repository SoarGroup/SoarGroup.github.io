## load

Loads soar files, rete networks, saved percept streams and external libraries.

#### Synopsis

```
============================================================
-               Load Sub-Commands and Options              -
============================================================
load                            [? | help]
------------------------------------------------------------
load file                       [--all --disable] <filename>
load file                       [--verbose]     ]
------------------------------------------------------------
load library                    <filename> <args...>
------------------------------------------------------------
load rete-network               --load <filename>
------------------------------------------------------------
load percepts                   --open <filename>
load percepts                   --close
------------------------------------------------------------
```

### load file

Load and evaluate the contents of a file. The `filename` can be a relative path or a fully qualified path. The source will generate an implicit push to the new directory, execute the command, and then pop back to the current working directory from which the command was issued. This is traditionally known as the source command.

#### Options:

| **Option** | **Description** |
|:-----------|:----------------|
| `filename` | The file of Soar productions and commands to load. |
| `-a, --all` | Enable a summary for each file sourced             |
| `-d, --disable` | Disable all summaries                              |
| `-v, --verbose` | Print excised production names                     |

#### Summaries

After the source completes, the number of productions sourced and excised is summarized:

```
agent> source demos/mac/mac.soar
******************
Total: 18 productions sourced.
Source finished.
agent> source demos/mac/mac.soar
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
Total: 18 productions sourced. 18 productions excised.
Source finished.
```
This can be disabled by using the `-d` flag.

#### Multiple Summaries

A separate summary for each file sourced can be enabled using the `-a` flag:

```
agent> source demos/mac/mac.soar -a
_firstload.soar: 0 productions sourced.
all_source.soar: 0 productions sourced.
**
goal-test.soar: 2 productions sourced.
***
monitor.soar: 3 productions sourced.
****
search-control.soar: 4 productions sourced.
top-state.soar: 0 productions sourced.
elaborations_source.soar: 0 productions sourced.
_readme.soar: 0 productions sourced.
**
initialize-mac.soar: 2 productions sourced.
*******
move-boat.soar: 7 productions sourced.
mac_source.soar: 0 productions sourced.
mac.soar: 0 productions sourced.
Total: 18 productions sourced.
Source finished.
```

#### Listing Excised Productions

```
agent> source demos/mac/mac.soar -d
******************
Source finished.
agent> source demos/mac/mac.soar -d
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
Source finished.
```

A list of excised productions is available using the `-v` flag:

```
agent> source demos/mac/mac.soar -v
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
Total: 18 productions sourced. 18 productions excised.
Excised productions:
        mac*detect*state*success
        mac*evaluate*state*failure*more*cannibals
        monitor*move-boat
        monitor*state*left
...
```
Combining the `-a` and `-v` flags add excised production names to the output
for each file.

### load rete-network

The `load rete-network` command loads a Rete net previously saved. The Rete net is Soar's internal representation of production memory; the conditions of productions are reordered and common substructures are shared across different productions. This command provides a fast method of saving and loading productions since a special format is used and no parsing is necessary. Rete-net files are portable across platforms that support Soar.

If the filename contains a suffix of `.Z`, then the file is compressed automatically when it is saved and uncompressed when it is loaded. Compressed files may not be portable to another platform if that platform does not support the same uncompress utility.

#### Usage:

```
load rete-network -l <filename>
```
### load percepts

Replays input stored using the capture-input command. The replay file also includes a random number generator seed and seeds the generator with that.

#### Synopsis

```
load percepts --open filename
load percepts --close
```

#### Options

| **Option** | **Description** |
|:-----------|:----------------|
| `filename` | Open filename and load input and random seed. |
| `-o, --open` | Reads captured input from file in to memory and seeds the random number generator. |
| `-c, --close` | Stop replaying input.                         |

### load library

Load a shared library into the local client (for the purpose of, e.g., providing custom event handling).

#### Options:

| **Option** | **Description** |
|:-----------|:----------------|
| `library_name` | The root name of the library (without the .dll or .so extension; this is added for you depending on your platform). |
| `arguments`     | Whatever arguments the library's initialization function is expecting, if any.  |

#### Technical Details

Sometimes, a user will want to extend an existing environment. For example, the person may want to provide custom RHS functions, or register for print events for the purpose of logging trace information. If modifying the existing environment is cumbersome or impossible, then the user has two options: create a remote client that provides the functionality, or use load library. `load library` creates extensions in the local client, making it orders of magnitude faster than a remote client.

To create a loadable library, the library must contain the following function:

```
#ifdef __cplusplus
extern "C" {
#endif

    EXPORT char* sml_InitLibrary(Kernel* pKernel, int argc, char** argv) {
        // Your code here
    }

#ifdef __cplusplus
} // extern "C"
#endif
```

This function is called when `load library` loads your library. It is responsible for any initialization that you want to take place (e.g.  registering custom RHS functions, registering for events, etc).

The `argc` and `argv` arguments are intended to mirror the arguments that a standard SML client would get. Thus, the first argument is the name of the library, and the rest are whatever other arguments are provided. This is to make it easy to use the same codebase to create a loadable library or a standard remote SML client (e.g. when run as a standard client, just pass the arguments main gets into `sml_InitLibrary`).

The return value of `sml_InitLibrary` is for any error messages you want to return to the load-library call. If no error occurs, return a zero-length string.

An example library is provided in the `Tools/TestExternalLibraryLib` project. This example can also be compiled as a standard remote SML client. The 
`Tools/TestExternalLibraryExe` project tests loading the `TestExternalLibraryLib` library.

#### Load Library Examples

To load `TestExternalLibraryLib`:

```
load library TestExternalLibraryLib
```

To load a library that takes arguments (say, a logger):

```
load library my-logger -filename mylog.log
```

### Default aliases
```
source               load file            
rete-net, rn         load rete-network    
replay-input         load input           
load-libarary        load library         
```
### See Also

[file system](./cmd_file_system.md)
[decide](./cmd_decide.md)
[production](./cmd_production.md) 
[save](./cmd_save.md)
