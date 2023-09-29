## File System

Soar can handle the following Unix-style file system navigation commands

### pwd

Print the current working directory.

### ls

List the contents of the current working directory.

### cd

Change the current working directory. If run with no arguments, returns to the directory that the command line interface was started in, often referred to as the _home_ directory.

### dirs

This command lists the directory stack. Agents can move through a directory structure by pushing and popping directory names. The dirs command returns the stack.

### pushd

Push the directory on to the stack. Can be relative path name or a fully specified one.

### popd

Pop the current working directory off the stack and change to the next directory on the stack. Can be relative pathname or a fully specified path.


#### Default Aliases
```
chdir        cd
dir          ls
topd         pwd
```

