---
date: 2014-10-07
authors:
    - soar
tags:
    - kernel programming
---

<!-- markdown-link-check-disable-next-line -->
<!-- old URL: https://soar.eecs.umich.edu/articles/articles/technical-documentation/199-command-line-interface-parsing-code -->

# Command Line Interface Parsing Code

## Overview

The command line interface (CLI) described in this document has no relation to
the lexer/parser inside the Soar kernel. CLI often refers to the actual object
instance (a member of KernelSML) but sometimes can refer to the whole component.

The CLI takes an arbitrary string and transforms it into method calls providing
a general interface to Soar as described by the help document on the Soar wiki
(on Google Code).

A command line in this context can actually be many commands, or an entire file.
In this document it will be called a command line. The syntax of what is legal
closely follows the Tcl language and is spelled out in the Doxygen help in
Core/shared/tokenizer.h. These rules are reprinted below.

The command line enters the CLI at CommandLineInterface:: DoCommand. Some quick
state is updated but then it is passed to Source (defined in cli_source.cpp), a
same function used by the source command in Soar. This is why command lines and
files are interchangeable.

Source then uses the tokenizer utility to split out the command name and its
arguments. The critical piece used by tokenizer to do this is the parser
instance (cli::Parser, cli_Parser.h, a member of CLI) which knows what all the
commands and aliases are.

The parser expands aliases, performs a partial match if necessary and then, if
there is no ambiguity, calls the appropriate command's Parse function with a
vector of the tokens used for the command. Sometimes this vector is only of
length 1 (the command name). Again, Tcl rules are used to tokenize each command
(and to split commands).

These commands' parse methods are defined in cli_Commands.h and registered with
the parser with the CLI is first created. The parser is also aware of aliases,
which are initially defined in the Aliases constructor executed when the parser
is first created. Aliases can change down the road when commands access the
parser's aliases member.

The purpose of the parse function is to process the command's options (if any)
and report syntax errors as necessary. Some input checking is done here but most
is saved for the next step (below). Few commands (such as dirs) have no
parsing--most have plenty of stuff to do in this phase. No actual processing
should happen here, the functions called as a result of parsing should be able
to be called directly elsewhere for the same effect without parsing. Example of
a command that takes no arguments:

```
dirs
```

Some commands just need to test for the presence of and get an argument or two
off of the command line before proceeding. An example of this is the
max-elaborations command. These commands are simple - the vector of tokens can be
inspected and used directly.

Example of command that has arguments:

```
max-elaborations 15
Non-option argument: 15
```

Other commands have options which are handled using the option utilities on the
Parser instance, sometimes in addition to other, non-option arguments.

More common commands (with options):

- echo-commands -y
- Option (short): y
- learn --off
- Option (long): off
- echo -n Hello world!
- Option (short): n
- Arguments: Hello, world!
- watch --chunks -L print
- Option (long): chunks
- Option (short) with argument: L, print
- Options always have both long and short forms, and a required argument,
  optional argument, or no argument setting expected. These are all defined in the
  top of the Parse function before the option handling code is called.

Once the command and options are parsed, a function call is made to actually
process the command. These are all declared initially on the Cli-interface
defined in cli_Cli.h. This interface exists to facilitate context-free testing
of the command parsing. By convention, these processing functions all start with
Do so they are easily spotted on the CLI.

The CLI implements this interface, and defines the functions and their related
helper functions in their own files. DoSource, for example, is defined in
cli_source.cpp.

The meat of the command happens in these Do functions. The function signatures
vary depending on what the commands need. Enumerations are used to pass modes
from the parsing step to the Do step. Null pointers are used often when some
parameter is optional, to indicate that it was omitted. Bit vectors are often
used to pass a number of flags from the parsing step to the processing step.

The motivation behind splitting the parsing from the processing in the commands
is both for testing and so that other parts of Soar/SML can call-these interface
functions directly without having to render command lines.

When commands complete, they return text to be printed after they execute.
Traditionally, little or nothing is printed when there is success.

There is support for more structured output for commands so that callers can
pull specific values out of command results (instead of parsing the stringified
results). This mode is optional (skip doing this until you know you need it) and
is tested by checking the m_RawOutput member on the CLI. Structured output is
built up using a form of XML.

## Tokenizing Rules

The tokenizer used by the CLI follows most of the rules of Tcl. Here they are,
copied from the tokenizer header (Core/shared/tokenizer.h):

[1] A Tcl script is a string containing one or more commands. Semi-colons
and newlines are command separators unless quoted as described below. Close
brackets are command terminators during command substitution (see below)
unless quoted. [Square brackets have no special meaning in this parser.]

[2] A command is evaluated in two steps. First, the Tcl interpreter breaks
the command into words and performs substitutions as described below. These
substitutions are performed in the same way for all commands. [The first
word of the command has no special meaning in this parser.] All of the words
of the command are passed to the command procedure [via a callback
interface]. The command procedure is free to interpret each of its words in
any way it likes, such as an integer, variable name, list, or Tcl script.
Different commands interpret their words differently.

[3] Words of a command are separated by white space (except for newlines,
which are command separators).

[4] If the first character of a word is double-quote (") then the word is
terminated by the next double-quote character. If semi-colons, close
brackets, or white space characters (including newlines) appear between the
quotes then they are treated as ordinary characters and included in the
word. Backslash substitution [but not command substitution or variable
substitution] is performed on the characters between the quotes as described
below. The double-quotes are not retained as part of the word.

[5] If the first character of a word is an open brace ({) then the word is
terminated by the matching close brace (}). Braces nest within the word: for
each additional open brace there must be an additional close brace (however,
if an open brace or close brace within the word is quoted with a backslash
then it is not counted in locating the matching close brace). No
substitutions are performed on the characters between the braces except for
backslash-newline substitutions described below, nor do semi-colons,
newlines, close brackets, or white space receive any special interpretation.
The word will consist of exactly the characters between the outer braces,
not including the braces themselves.

[6] [Square brackets are not special in this parser. No command
substitution.]

[7] [Dollar signs are not special in this parser. No variable substitution.]

[8] If a backslash `\` appears within a word then backslash substitution
occurs. In all cases but those described below the backslash is dropped and
the following character is treated as an ordinary character and included in
the word. This allows characters such as double quotes, and close brackets
[and dollar signs but they aren't special characters in this parser] to be
included in words without triggering special processing. The following table
lists the backslash sequences that are handled specially, along with the
value that replaces each sequence.

```
\a Audible alert (bell) (0x7).
\b Backspace (0x8).
\f Form feed (0xc).
\n Newline (0xa).
\r Carriage-return (0xd).
\t Tab (0x9).
\v Vertical tab (0xb).
\<newline>whiteSpace
```

A single space character replaces the backslash, newline, and all spaces
and tabs after the newline. This backslash sequence is unique in that
[...] it will be replaced even when it occurs between braces, and the
resulting space will be treated as a word separator if it isn't in
braces or quotes.
\\ Backslash (``\'').
[Not implemented: \ooo The digits ooo (one, two, or three of them) give the
octal value of the character.]
[Not implemented: \xhh The hexadecimal digits hh give the hexadecimal value
of the character. Any number of digits may be present.]

Backslash substitution is not performed on words enclosed in braces, except
for backslash-newline as described above.

[9] If a hash character (#) appears at a point where Tcl is expecting the
first character of the first word of a command, then the hash character and
the characters that follow it, up through the next newline, are treated as a
comment and ignored. The comment character only has significance when it
appears at the beginning of a command.

[10] [Talks about details regarding substitution and generally does not
apply to this parser.]

[11] [Talks about details regarding substitution and generally does not
apply to this parser.]

## Parsing

The first token of a command is used to find its parser implementation. The
command parsers are defined in cli_Commands.h and implementParserCommand. The
rest of the tokens are either options, option arguments, or non-option
arguments. Options

Options start with dashes. One dash followed by one or more letters is
interpreted as one or more short options.

```
-f: Option f
-for: Options f o r
```

Two dashes are followed by one long option

```
--foo: Option foo
```

All options have a short form and a long form.

`--level` and `-l` both represent the "level" option in the watch command.

Options can have arguments associated with them. The argument, if it accepts
one, can be required or optional. This is specified when the option is defined
in its parse function:

```
// Short option, long option, one of none, optional, required
{'f', "fullwmes", OPTARG_NONE},
{'b', "backtracing", OPTARG_OPTIONAL},
{'l', "level", OPTARG_REQUIRED},
```

Options with arguments generally accept whatever comes after them as its
argument. Optional arguments are trickier, refer to cli_Options.h for details.

```
--level 4: level takes a required argument, 4 is consumed as its argument.
```

Options can occur anywhere in the command line, except after special option -
which forces an end to option parsing. Options and any of their arguments are
moved to the beginning of the token vector, keeping their same relative order.
The number of options remaining can be obtained with `GetNonOptionArguments()` and
the actual options starting with the length of the token vector.

```c++
cli::Options opt; // Option parsing utility instance

// ... define options, parse options

int remain = opt.GetNonOptionArguments(); // Number of non-option arguments remaining

// ... assuming remain > 0

int i = argv.size() - remain; // Index of first non-option argument
argv[i];
```

Processing options and their arguments has a lot of boiler plate code, something
that could totally be improved. Write tests first.

```c++
cli::Options opt; // Option parsing utility instance

OptionsData optionsData[] =
{
// Options definitions
{'f', "fullwmes", OPTARG_NONE}
{'f', "full-wmes", OPTARG_NONE}, // multiple long options OK
{'b', "backtracing", OPTARG_OPTIONAL},
{'l', "level", OPTARG_REQUIRED},
{0, 0, OPTARG_NONE} // terminate with this, sorry
};

for (;;) // most compilers won't complain about this kind of forever
{
// this returns false only on major error
if (!opt.ProcessOptions(argv, optionsData)) return false;

    // this will be -1 if option parsing is complete
    if (opt.GetOption() == -1) break;

    switch (opt.GetOption())
    {
        case 'f':
            // remember this flag is flipped
            break;
        case 'b':
            // remember this flag is flipped
            if (!opt.GetOptionArgument.empty())
                opt.GetOptionArgument(); // Here's the optional argument
            break;
        case 'l':
            // remember this flag is flipped
            opt.GetOptionArgument(); // Here's the argument
            break;
    }

}

if (opt.GetNonOptionArguments())
int i = argv.size() - opt.GetNonOptionArguments(); // index to argument
```

Non-options are often tested for existance, count, there's a utility function for that:

```c++
// returns true if there is one or no non-option argument
opt.CheckNumNonOptArgs(0, 1); // min, max

// returns true if there are three non-option arguments
opt.CheckNumNonOptArgs(3, 3);
```

## Executing

Once a command and its options are parsed, a function is called to Do the work.
Looking at the excise command definition (cli_Cli.h):

```c++
// parsing distills the command line options down to this list
enum eExciseOptions
{
EXCISE_ALL,
EXCISE_CHUNKS,
EXCISE_DEFAULT,
EXCISE_RL,
EXCISE_TASK,
EXCISE_TEMPLATE,
EXCISE_USER,
EXCISE_NUM_OPTIONS, // must be last
};

// and stores them in this type
typedef std::bitset<EXCISE_NUM_OPTIONS> ExciseBitset;

/\*\*

- @brief excise command
- @param options The various options set on the command line
- @param pProduction A production to excise, optional
  _/ virtual bool DoExcise(const ExciseBitset& options, const std::string_ pProduction = 0) = 0;
```

This excise function takes a bitset of option flags parsed from the command
line, and optionally a pointer to a string of a specific production to excise. A
pointer is used because it is optional, and null can be passed when all of the
command's state is contained in the options set.

## Errors

Command implementations should return true if the command is successful, false
if there is an error condition. Before returning false, error state should be
set so that the user can try and figure out what went wrong. Call SetError() on
the cli::Cli instance to set the error text. Return false. SetError() always
returns false so you can just return that.

```c++
// during parsing, you should have a reference to cli
if (argv.size() > 2)
return cli.SetError("Only one argument (a directory) is allowed. Paths with spaces should be enclosed in quotes.");

// during execution, you are the cli
if (!pScheduler->VerifyStepSizeForRunType(forever, runType, interleave))
return SetError("Run type and interleave setting incompatible.");
```

## Implementing New Command Checklist

Open cli_Cli.h and define your command's functional interface.
Open cli_Commands.h and create a new cli::ParserCommand instance for your command.
Find a similar command and copy and paste it, changing what you need, or use a template:

```c++
// no option parsing
class TheCommand : public cli::ParserCommand
{
public:
TheCommand(cli::Cli& cli) : cli(cli), ParserCommand() {}

    // always virtual destructor
    virtual ~TheCommand() {}

    // the token that chooses this command
    virtual const char* GetString() const { return "the"; }

    // help string look at other commands for examples
    virtual const char* GetSyntax() const
    {
        return "Syntax: the [syntax]";
    }

    // the meat
    virtual bool Parse(std::vector< std::string >&argv)
    {
        // possibly do something with argv

        // call the function declared in Cli
        return cli.DoThe();
    }

private:
cli::Cli& cli;

    // no copy
    TheCommand& operator=(const TheCommand&);

};
// option parsing
class TheCommand : public cli::ParserCommand
{
public:
TheCommand(cli::Cli& cli) : cli(cli), ParserCommand() {}

    // always virtual destructor
    virtual ~TheCommand() {}

    // the token that chooses this command
    virtual const char* GetString() const { return "the"; }

    // help string look at other commands for examples
    virtual const char* GetSyntax() const
    {
        return "Syntax: the [syntax]";
    }

    // the meat
    virtual bool Parse(std::vector< std::string >&argv)
    {
        cli::Options opt;

        // define options
        OptionsData optionsData[] =
        {
            //{'a', "alpha", OPTARG_NONE},
            //{'b', "bravo", OPTARG_OPTIONAL},
            //{'c', "charlie", OPTARG_REQUIRED},
            {0, 0, OPTARG_NONE}
        };

        // declare state here to save during parsing

        // loop through args
        for (;;)
        {
            if (!opt.ProcessOptions(argv, optionsData))
                return cli.SetError(opt.GetError());

            if (opt.GetOption() == -1) break;

            switch (opt.GetOption())
            {
                case 'a':
                    break;
                case 'b':
                    if (!opt.GetOptionArgument.empty())
                        opt.GetOptionArgument(); // Here's the optional argument
                    break;
                case 'c':
                    opt.GetOptionArgument(); // Here's the argument
                    break;
            }
        }

        // call the function declared in Cli
        return cli.DoThe();
    }

private:
cli::Cli& cli;

    // no copy
    TheCommand& operator=(const TheCommand&);

};
```

Open up cli_CommandLineInterface.cpp and add your command in the constructor.
Create cli_the.cpp for your command and implement the command execution.
