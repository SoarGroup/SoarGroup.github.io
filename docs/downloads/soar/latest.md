---
title: Soar
---

# Latest Soar Download

The current version of Soar is {{ soar_version }}.
<!-- markdown-link-check-disable-next-line -->
*   [Soar Release](https://github.com/SoarGroup/Soar/releases/download/releases%2F{{soar_version}}/SoarSuite_{{soar_version}}-Multiplatform.zip)
(see [quick start guide](../../home/QuickStart.md) for setup instructions)
<!-- markdown-link-check-disable-next-line -->
*   [Soar Manual PDF](https://github.com/SoarGroup/Soar/releases/download/releases%2F{{soar_version}}/SoarManual.pdf)
<!-- markdown-link-check-disable-next-line -->
*   [VisualSoar Manual PDF](https://github.com/SoarGroup/Soar/releases/download/releases%2F{{soar_version}}/VisualSoar_UsersManual.pdf)

If you would like to build Soar from the current source code, you'll need to
acquire the source from our git repository [on GitHub](https://github.com/SoarGroup/Soar).

## Soar 9.6.5 Release Notes

### New Features

*   New `$` / `$$` operator in production conditions marks a constant test as
    literal so the chunker will not variabilize it.
    See the Soar Manual section
    [Constant match literalization with `$`](../../soar_manual/03_SyntaxOfSoarPrograms.md).
*   `wm add` (alias `add-wme`) now accepts an explicit identifier as the value.
    Soar will reuse the identifier if it already exists, or create it at the
    parent id's level otherwise. Chunking does not backtrace through wmes
    added this way.
*   Negative numbers can now be used as CLI arguments without being
    misinterpreted as command flags.

### Build & Packaging

*   CMake is now the primary build system. SCons is still supported.
*   Multi-platform release workflow covers Windows, Linux, and macOS
    (x86-64 and ARM64).
*   CPack produces `.tar.gz` on all platforms, `.zip` on Windows, and
    `.deb` on Linux. `compile_commands.json` is emitted for IDE/tooling use.

### Bindings

*   SWIG bindings for Python, Java, Tcl, C#, and JavaScript are now built
    via CMake.
*   Python bindings use the stable ABI (`Py_LIMITED_API`), producing a
    single `.pyd` on Windows that works across Python 3.8+.
*   TclSoarLib is a first-class CMake target.

### Bug Fixes

*   **Chunking:** refcount-decrement fix during state cleanup when
    justifications held OSK knowledge; workaround for a conjunctive-conditions
    chunking bug; first-instance literalization path fixed.
*   **Episodic Memory:** refcount / id-reservation fix around exclusions and
    orphaned wmes (previously surfaced as UNIQUE-constraint violations).
*   **Semantic Memory:** use-after-free on orphaned justifications fixed.
    When SMem tracing is enabled, each store now prints a single `@` marker
    (analogous to `*` for rule fires) instead of a multi-line block per wme.
*   Atomic operations now work correctly on 32-bit architectures.

### API

*   `GetParameterValue` now throws on bad calls
    ([PR #465](https://github.com/SoarGroup/Soar/pull/465)). SWIG bindings
    propagate exceptions instead of silently returning defaults.
*   64-bit integer extensions in the kernel.

### Platform Support

*   Java 11 is the minimum supported JRE for the Debugger and Java bindings.
*   In Release builds, the Java Debugger launcher silences GTK/SWT stderr
    noise on Linux. Debug builds still show stderr.

## Soar 9.6.4 Release Notes

### New Features

*   New special-purpose RHS functions for working with headings and range in
navigation domains:
    *   `extrapolate-x-position`
    *   `extrapolate-y-position`
    *   `select-point-closest-to-vector`
    *   `haversine`
*   Scene names (`S1`, `S2`, etc.) used in SVS commands are now case-insensitive,
which is consistent with Soar's handling of state names ([#426](https://github.com/SoarGroup/Soar/issues/426))
*   Soar now supports LTI aliases. Thanks to Aaron Mininger!
    *   This means you can assign permanent aliases to LTIs in commands such as
    `smem --add { (@test1 ^name test1 ^info @info1) (@info1 ^number 1) }`.
    *   These are then referenceable in commands such as `smem --query` and
    `smem --remove`.
    *   Also printed in the output of `print`, as well as `smem --history`,
    `smem --export` and `visualize smem`.
*   Java SML bindings: Don't throw exception in static block when Soar lib isn't
found ([#491](https://github.com/SoarGroup/Soar/issues/491))
    *   Previous behavior was to throw an exception at class load time, which would
    completely prevent an application from loading

## Bug fixes

*   Fix compilation with `--no-scu` ([#500](https://github.com/SoarGroup/Soar/issues/500)).
Thanks to James Boggs!
*   Escape empty strings when printing symbols in productions, etc. ([#484](https://github.com/SoarGroup/Soar/issues/484))
    *   Without the escaping, productions printed this way are not correct Soar
    syntax and therefore are not sourceable!
*   Don't ignore duplicate justifications ([#529](https://github.com/SoarGroup/Soar/issues/529))
    *   O-supported justifications that are duplicates can be created when the
    state changes but returns to its original value again. Previously Soar would
    ignore duplicate justifications, which would then prevent the expected RHS
    changes from being applied. Now, the previous justification is removed and
    the new one is added.
*   `cd` command with no parameters now works as documented in the manual (previous
behavior was a simple segfault!) ([#494](https://github.com/SoarGroup/Soar/issues/494))

### Infrastructure improvements

*   In-progress CMake-based build system (thanks to Moritz Schmidt!)
*   Look specifically for Tcl 8 when building (Soar is not yet compatible with
Tcl 9)

### Cruft and cleanup

*   Lots of compiler warning fixes
*   Compiler strictness increased

## VisualSoar

### Project Stability Improvements

*   Newly designed JSON format for VisualSoar projects combining the datamap, operator
hierarchy/project layout, and comment files into one file ([#38](https://github.com/SoarGroup/VisualSoar/issues/38),
[#5](https://github.com/SoarGroup/VisualSoar/issues/5))
    *   Far less likely to be corrupted
    *   More human-readable
    *   More machine readable (tool developers welcome!)
    *   More robust to collaboration (no non-deterministic output, fewer git conflicts,
    easier to resolve if they do occur)
    *   Handles arbitrary enum strings, attribute and operator names, etc.
    *   VisualSoar will write your project in the new format automatically, but
    will ask you to delete the old project files yourself. Effort was taken to
    eliminate any chance of data loss or other unwanted surprises.
*   Read/write project and config files atomically
    *   Prevents corruption if an error occurs during read/write
*   Fix cross-platform incompatibility issues in config files
*   Improve error messages, fewer hidden from users
*   Improve undo stack management
    *   Compound edits such as the comment/uncomment actions are now applied atomically,
    meaning they can be undone/redone in one step
    *   Fixed issues that caused the undo stack to be unexpectedly cleared
*   Improve close/save action workflows to reduce surprises (such as closing and
saving everything without confirmation!)

### CLI Support

VisualSoar can now run project datamap validation from the command line by passing
the arguments `--check productionsAgainstDatamap --project <path>`, where `<path>`
is the path to your project `.vsa` or `.vsa.json`.

There is a also a [new GitHub Action](https://github.com/marketplace/actions/soar-datamap-validation)
to enable you to check your projects automatically when you push to GitHub.

### Ergonomics and Bug Fixes

*   Fix Soar Runtime menu functions (connect to kernel, source agent, etc.) ([#33](https://github.com/SoarGroup/VisualSoar/issues/33))
*   Make comment/uncomment actions inverses of each other and fix issues with extra
lines getting commented
*   Display number of feedback messages in the status bar
    *   A quick way to see if you are making progress on eliminating datamap errors
*   allow underscores in attribute names ([#32](https://github.com/SoarGroup/VisualSoar/issues/32))
*   Support ctrl-A "select all" shortcut
*   Fix undo/redo shortcuts
*   Fix website links in help menu, and open the browser automatically
*   Improve searchbox and related ergonomics (#57)
    *   Wrap search by default
    *   Don't close the searchbox after searching
    *   Populate the searchbox with selected text (for the editor view)
    *   Fix shortcuts for searchbox and many other commands
    *   Use command on Mac instead of ctrl for all shortcuts
    *   Allow closing any dialog box with the escape key
*   New shortcut: ctrl/cmd-, to open preferences
*   New preferences:
    *   Save project when datamap check passes
    *   Run datamap check after saving project
*   ctrl/cmd-= and ctrl/cmd-- to increase/decrease font size
*   Responsively re-tile all frames when main window is resized
*   Better resizing of feedback list when the main window is resized
*   Improved auto-complete UI
*   Auto-complete for variables that match their attribute name

### Infrastructure

*   Add continuous integration (via GitHub actions)
*   Introduce JUnit for unit testing
*   Build native binaries in CI via jpackage
*   Update to Java 11, which is already required by other Soar tools ([#29](https://github.com/SoarGroup/VisualSoar/issues/29))

## Debugger

*   Update links in help menu and open them in a browser automatically ([#482](https://github.com/SoarGroup/Soar/issues/482))
*   Add new "Browse settings files..." option in file menu
*   Support select-all shortcut in all text windows via cmd/ctrl-a
*   Copy/paste fixes
    *   Paste directly into command box instead of the output window
    *   Fix issue causing paste of 'c' or 'v' into the command box upon copy/paste
*   Account for half-scrolled lines in right-click ([#417](https://github.com/SoarGroup/Soar/issues/417))
*   Fix preference file issues ([#509](https://github.com/SoarGroup/Soar/issues/509))
    *   Don't enter infinite loop when reading an incomplete XML file
    *   Read/write preference XML file atomically to avoid corruption
*   Fix broken `cd` button on Windows ([#452](https://github.com/SoarGroup/Soar/issues/452))
*   Improved CLI parameter handling for debugger ([#510](https://github.com/SoarGroup/Soar/issues/510))
    *   Parameters are now parsed with the `commons-cli` library
    *   `--help` and incorrect parameters now show CLI parameter documentation,
    so users don't have to go to the website
