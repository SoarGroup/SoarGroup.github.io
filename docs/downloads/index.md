# Downloads

The current version of Soar is {{ soar_version }}.

*   [Soar Release](https://github.com/SoarGroup/Soar/releases/download/releases%2F{{soar_version}}/Soar-Release-{{soar_version}}.zip)
(see [quick start guide](../home/QuickStart.md) for setup instructions)
*   [Soar Manual PDF](https://github.com/SoarGroup/Soar/releases/download/releases%2F{{soar_version}}/SoarManual.pdf)
*   [VisualSoar Manual PDF](https://github.com/SoarGroup/Soar/releases/download/releases%2F{{soar_version}}/VisualSoar_UsersManual.pdf)

## Soar 9.6.2 Release Notes

March 20, 2023

This release of Soar includes mostly quality of life improvements, but also many
bug fixes and code improvements.

### Breaking Changes

*   Revert AddRhsFunction and RegisterForClientMessageEvent changes from 9.6.1
    *   9.6.1 introduced breaking changes to these two functions for C/C++ clients.
    We revert the change here (which breaks compatibility with 9.6.1, but restores
    it with 9.6.0).

### New Features

*   Lots of goodies for VisualSoar (thanks to amnuxoll)
    *   New user's manual (1.03)
    *   Support creating custom templates! See the manual for details.
    *   Parser now supports productions with multiple types
    *   Persist preferences for font size and divider location
    *   "Find all productions" search option
    *   New bottom status bar
    *   New template for compare operator

*   More ergonomic RHS and client message handler registration
    *   We add new overloads for AddRhsFunction and RegisterForClientMessageEvent
    utilizing std::function to simplify usage in C++ clients. Clients using class
    methods for handlers will no longer need to pass the class instance separately
    as (void*)userData, and can instead simply pass in the result of std::bind.

*   Improved production validity tests and warnings
    *   Soar now properly detects ungrounded (LHS not connected to a state)
    productions, refuses to source them, and tells the user how to fix them.
    *   Some warnings related to bad production structure were previously hidden
    behind tracing flags for chunking, and are now exposed by default.
    *   See <https://github.com/SoarGroup/Soar/issues/377>

*   More output filtering options in the debugger
    We rename "hide all" to "show only errors and top-level", then add a true
    "hide all" filter to complement that. We also separate messages from RHS
    writes, and add additional filter options for error and top-level. This covers
    all 14 output types, while still providing convenient checkboxes for common settings.

*   Ergonomic improvements to the debugger
    *   Previous versions of the debugger were very difficult to read on Mac in
    dark mode due to displaying black text on a dark background. The text now
    correctly shows as white.
    *   Scrolling behavior has been improved and stabilized. When the cursor is at
    the end of the main window, newly-printed text triggers a scroll. Otherwise,
    the window stays put where the user's cursor is.
    *   Shortcuts for copy/paste have been changed from ctrl to cmd on Mac
    *   New shortcuts have been added zooming in and out (increasing/decreasing
    the text size)

*   Documentation in generated Python SML bindings
    Doxygen comments from SML are now added as docstrings to the generated Python
    bindings using SWIG's autodoc feature (thanks to Moritz Schmidt).

### Other Changes

*   Bug fixes
    *   `smem --init` now connects to the DB so that a following `smem --clear`
    will not error out.
    *   `smem -x ...` when the DB is not yet loaded now fails gracefully instead
    of segfaulting
    *   Improved stability of Python SML bindings
    *   SoarCLI now properly exits on EOF. This means that it can be gracefully
    exited with
        Ctrl-D, it no longer hangs when reading from a pipe, and it can be
        controlled with the `expect` Unix utility.

*   VisualSoar bug fixes (thanks to amnuxoll):
    *   Several issues with undo manager
    *   Highlighted text replace bug
    *   More Robust Handling of 'file already exists' error

*   Infrastructure improvements
    *   `load library` demo has been folded into automated tests
    *   CI now runs Python and Tcl SML tests
    *   Added support files for developing Soar with VSCode
    *   Python version is now pinned in CI. This release, the compiled Python
    SML bindings are compatible with Python 3.12.X. The generated Python code is
    compatible with older versions of Python, but the compiled bindings are not,
    so users with different version needs will need to compile their own bindings.
    *   Setup logic is now encapsulated in setup.bat and setup.sh, which is easier
    and less error-prone for other tools dependent on Soar to re-use.

*   Cruft and cleanup
    *   stopped exporting a large number of internal SML classes to SWIG clients
    *   documented portability requirements for building SWIG clients
    *   eliminated potentially dangerous pointer size warnings from CSharp SML bindings
    *   removed broken IDE project files from the repository
