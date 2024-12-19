---
title: Soar
---

# Latest Soar Download

The current version of Soar is {{ soar_version }}.
<!-- markdown-link-check-disable-next-line -->
*   [Soar Release](https://github.com/SoarGroup/Soar/releases/download/releases%2F{{soar_version}}/SoarSuite_{{soar_version}}-Multiplatform.zip
)
(see [quick start guide](../../home/QuickStart.md) for setup instructions)
<!-- markdown-link-check-disable-next-line -->
*   [Soar Manual PDF](https://github.com/SoarGroup/Soar/releases/download/releases%2F{{soar_version}}/SoarManual.pdf)
<!-- markdown-link-check-disable-next-line -->
*   [VisualSoar Manual PDF](https://github.com/SoarGroup/Soar/releases/download/releases%2F{{soar_version}}/VisualSoar_UsersManual.pdf)

If you would like to build Soar from the current source code, you'll need to
acquire the source from our git repository [on GitHub](https://github.com/SoarGroup/Soar).

## Soar 9.6.3 Release Notes

July, 2024

This release of Soar includes lots of VisualSoar goodies.

## Addendum Aug. 19, 2024

The release was re-created due to issues running on Intel Macs. If you have an
Intel Mac and downloaded previous to this date, please download again to
successfully run Soar.

## Breaking Changes

*   New chunking setting, automatically-create-singletons, on by default
*   In our work we've found that we usually want all attributes to be singletons
by default unless explicitly specified otherwise. This setting attempts creating
singletons for every string attribute. We expect this to be a saner default for
all users, and think it unlikely to have a negative effect on existing projects.
If you have a project that relies on non-singleton attributes, you can disable
this setting by setting `chunking automatically-create-singletons off`.

*   Linux users: Soar was compiled on the recent Ubuntu 24.04, so you may need
to update your system or libstdc++ to run the included binaries (or else build
from source yourself).

## New Features

*   Visual-Soar improvements (thanks to amnuxoll)
    *   A datamap can import the datamap of another project
    *   Projects can be opened read-only
    *   Less change noise, i.e. more friendly towards version control
    *   Automatically opens the last project on startup; new "Open Recent" menu option
    *   Parser now supports LTI predicates
    *   Lots more smaller improvements

*   You can pip-install Soar! (thanks to Jonathan de Jong)
    *   `pip install soar-sml[compat]` is a drop-in replacement for manually
    installing Soar somewhere and adding its path to your PYTHONPATH environment
    variable.
    *   Note that this does not come with the debugger or other Java applications.
*   New svs commands `--disable-in-substates` and `--enable-in-substates`. By
default SVS copies the entire scene graph into each substate. This can be
disabled with `--disable-in-substates` to save memory and improve performance.
This can be re-enabled with `--enable-in-substates` if you need to access the
scene graph in substates.
*   Python bindings are now compatible with all Python versions 3.2 and up,
rather than only with the minor version that was used to build Soar. This is
thanks to the work of Jonathan de Jong.

## New Website

Thanks to Moritz Schmidt, we have a new website! The URL remains the same:
<https://soar.eecs.umich.edu>. New features include:

*   HTML versions of the manual and the tutorial
*   Snappy full-text search based on lunr.js
*   Much improved editing/deployment workflow based on GitHub pages. We also get
the full power of GitHub actions, and use it to automatically check for dead
links, for example.

Note that some pages and download links still need to be ported. The manual and
tutorial still need to be fully inspected for correctness, and the images in
particular still need work.

## Other Changes
