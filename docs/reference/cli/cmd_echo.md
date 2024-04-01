# echo

Print a string to the current output device.

## Synopsis

```bash
echo [--nonewline] [string]
```

## Options

| **Option**        | **Description**                           |
| :---------------- | :---------------------------------------- |
| `string`          | The string to print.                      |
| `-n, --nonewline` | Supress printing of the newline character |

## Description

This command echos the args to the current output stream. This is normally
stdout but can be set to a variety of channels. If an arg is `--nonewline` then
no newline is printed at the end of the printed strings. Otherwise a newline is
printed after printing all the given args. Echo is the easiest way to add user
comments or identification strings in a log file.

## Example

This example will add these comments to the screen and any open log file.

```bash
echo This is the first run with disks = 12
```

## See Also

[clog](./cmd_output.md#default-aliases)
