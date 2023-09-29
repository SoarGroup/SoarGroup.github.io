## alias

Define a new alias of existing commands and arguments.

#### Synopsis

```
alias
alias <name> [args]
alias -r <name>
```
### Adding a new alias

This command defines new aliases by creating Soar procedures with the given
name. The new procedure can then take an arbitrary number of arguments which are
post-pended to the given definition and then that entire string is executed as a
command. The definition must be a single command, multiple commands are not
allowed. The alias procedure checks to see if the name already exists, and does
not destroy existing procedures or aliases by the same name. Existing aliases
can be removed by using the [unalias](./cmd_unalias.md) command.

### Removing an existing alias

To undefine a previously created alias, use the `-r` argument along with the name of the alias to remove.

```alias -r existing-alias```

Note:  If you are trying to create an alias for a command that also has a `-r` option, make sure to enclose it in quotes.  For example:

```alias unalias "alias -r"```

### Printing Existing Aliases

With no arguments, alias returns the list of defined aliases. With only the name given, alias returns the current definition.  

### Examples

The alias `wmes` is defined as:

```
alias wmes print -i
```

If the user executes a command such as:

```
wmes {(* ^superstate nil)}
```

... it is as if the user had typed this command:

```
print -i {(* ^superstate nil)}
```

To check what a specific alias is defined as, you would type

```
alias wmes
```
### Default Alias Aliases

```
a               alias
unalias, un     alias -r     
```

