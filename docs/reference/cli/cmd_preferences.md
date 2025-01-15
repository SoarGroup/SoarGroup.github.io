# preferences

Examine details about the preferences that support the specified _identifier_
and _attribute_.

## Synopsis

```bash
preferences [options] [identifier [attribute]]
```

## Options

| **Option**           | **Description**                                                                                                                    |
| :------------------- | :--------------------------------------------------------------------------------------------------------------------------------- |
| `-0, -n, --none`     | Print just the preferences themselves                                                                                              |
| `-1, -N, --names`    | Print the preferences and the names of the productions that generated them                                                         |
| `-2, -t, --timetags` | Print the information for the `--names` option above plus the timetags of the wmes matched by the LHS of the indicated productions |
| `-3, -w, --wmes`     | Print the information for the `--timetags` option above plus the entire WME matched on the LHS.                                    |
| `-o, --object`       | Print the support for all the WMEs that comprise the object (the specified _identifier_).                                          |
| `identifier`         | Must be an existing Soar object _identifier_.                                                                                      |
| `attribute`          | Must be an existing _attribute_ of the specified _identifier_.                                                                     |

## Description

The `preferences` command prints all the preferences for the given object
identifier and attribute. If identifier and attribute are not specified, they
default to the current state and the current operator. The Soar syntax attribute
caret (`^`) is optional when specifying the attribute. The optional arguments
indicates the level of detail to print about each preference.

This command is useful for examining which candidate operators have been
proposed and what relationships, if any, exist among them. If a preference has
o-support, the string, `:O` will also be printed.

When only the identifier is specified on the command line, if the identifier is
a state, Soar uses the default attribute `^operator`. If the identifier is not a
state, Soar prints the support information for all WMEs whose value is the
identifier.

When an identifier and the `--object` flag are specified, Soar prints the
preferences / WME support for all WMEs comprising the specified identifier.

For the time being, numeric-indifferent preferences are listed under the heading
`binary indifferents:`.

By default, using the `--wmes` option with a WME on the top state will only
print the timetags. To change this, the kernel can be recompiled with
`DO_TOP_LEVEL_REF_CTS`, but this has other consequences (see comments in
`kernel.h`).

## Examples

This example prints the preferences on `(S1 ^operator)` and the production names
which created the preferences:

```bash
soar> preferences S1 operator --names
Preferences for S1 ^operator:

acceptables:
  O2 (fill) + :I
    From water-jug*propose*fill

  O3 (fill) + :I
    From water-jug*propose*fill


unary indifferents:
  O2 (fill) = :I
    From water-jug*propose*fill

  O3 (fill) = :I
    From water-jug*propose*fill


selection probabilities:
  O3 (fill) + =0. :I (50.0%)
    From water-jug*propose*fill

  O2 (fill) + =0. :I (50.0%)
    From water-jug*propose*fill
```

If the current state is `S1`, then the above syntax is equivalent to:

```bash
preferences -n
```

This example shows the support for the WMEs with the ^jug attribute:

```bash
soar> preferences s1 jug

Preferences for S1 ^jug:

acceptables:
  (S1 ^jug I4)  :O
  (S1 ^jug J1)  :O
```

This example shows the support for the WMEs with value `J1`, and the productions
that generated them:

```bash
soar> pref J1 -1

Support for (33: O3 ^fill-jug J1)
  (O3 ^fill-jug J1)  =0. :I (100.0%)
    From water-jug*propose*fill

Support for (22: S1 ^jug J1)
  (S1 ^jug J1)  =0. :O (100.0%)
    From water-jug*apply*initialize-water-jug
```

This example shows the support for all WMEs that make up the object `S1`:

```bash
soar> pref -o s1

Support for S1 ^name:
  (S1 ^name water-jug)  :O
Support for S1 ^jug:
  (S1 ^jug I4)  :O
  (S1 ^jug J1)  :O
Support for S1 ^svs:
Preferences for S1 ^operator:
acceptables:
  O2 (fill) + :I
  O3 (fill) + :I

unary indifferents:
  O2 (fill) = :I
  O3 (fill) = :I
Support for S1 ^smem:
Support for S1 ^epmem:
Support for S1 ^reward-link:
Arch-created wmes for S1 :
(2: S1 ^superstate nil)
(1: S1 ^type state)
Input (IO) wmes for S1 :
(15: S1 ^io I1)
```

## Default Aliases

-   `pref`

## See Also

-   [decide](./cmd_decide.md)
