# sp

Define a Soar production.

## Synopsis

```bash
sp {production_body}
```

## Options

| **Option**        | **Description**    |
| :---------------- | :----------------- |
| `production_body` | A Soar production. |

## Description

The `sp` command creates a new production and loads it into production memory.
`production_body` is a single argument parsed by the Soar kernel, so it should
be enclosed in curly braces to avoid being parsed by other scripting languages
that might be in the same process. The overall syntax of a rule is as follows:

```bash
  name
      ["documentation-string"]
      [FLAG*]
      LHS
      -->
      RHS
```

The first element of a rule is its name. If given, the documentation-string must
be enclosed in double quotes. Optional flags define the type of rule and the
form of support its right-hand side assertions will receive. The specific flags
are listed in a separate section below. The LHS defines the left-hand side of
the production and specifies the conditions under which the rule can be fired.
Its syntax is given in detail in a subsequent section. The --> symbol serves to
separate the LHS and RHS portions. The RHS defines the right-hand side of the
production and specifies the assertions to be made and the actions to be
performed when the rule fires. The syntax of the allowable right-hand side
actions are given in a later section. (See the _Syntax of Soar Programs_ chapter
of the manual for naming conventions and discussion of the design and coding of
productions.)

If the name of the new production is the same as an existing one, the old
production will be overwritten (excised).

Rules matching the following requirement are flagged upon being created/sourced:
a rule is a Soar-RL rule if and only if its right hand side (RHS) consists of a
single numeric preference and it is not a template rule (see FLAGs below). This
format exists to ease technical requirements of identifying/updating Soar-RL
rules, as well as to make it easy for the agent programmer to add/maintain RL
capabilities within an agent. (See the _Reinforcement Learning_ chapter of the
manual for further details.)

## Rule Flags

The optional flags are given below. Note that these switches are preceded by a
colon instead of a dash -- this is a Soar parser convention.

```bash
:o-support      specifies that all the RHS actions are to be given
                o-support when the production fires

:i-support     specifies that all the RHS actions are only to be given
                i-support when the production fires

:default        specifies that this production is a default production
                (this matters for excise -task and trace task)

:chunk          specifies that this production is a chunk
                (this matters for learn trace)

:interrupt      specifies that Soar should stop running when this
                production matches but before it fires
                (this is a useful debugging tool)

:template       specifies that this production should be used to generate
                new reinforcement learning rules by filling in those
                variables that match constants in working memory
```

Multiple flags may be used, but not both of `o-support` and `no-support`.

Although you could force your productions to provide o-support or i-support by
using these commands --- regardless of the structure of the conditions and
actions of the production --- this is not proper coding style. The `o-support`
and `i-support` flags are included to help with debugging, but should not be
used in a standard Soar program.

## Examples

```Soar
sp {blocks*create-problem-space
     "This creates the top-level space"
     (state <s1> ^superstate nil)
     -->
     (<s1> ^name solve-blocks-world ^problem-space <p1>)
     (<p1> ^name blocks-world)
}
```

### See Also

-   [production](./cmd_production.md)
-   [chunk](./cmd_chunk.md)
-   [trace](./cmd_trace.md)
