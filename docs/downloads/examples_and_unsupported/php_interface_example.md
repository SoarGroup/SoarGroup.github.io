---
Tags:
    - PHP
    - SML
---

# PHP Interface Example

**This project contains an example PHP project that interfaces with Soar. It
includes a sample agent that is a slight modification of the water-jug-rl demo
agent included with Soar. The main difference is that the initialization
application and the goal-detection elaboration rules condition upon server-side
input-link structures to dynamically generate water-jug problem instances.**

## Download Links

*   [PHP_Interface_Example.zip](https://github.com/SoarGroup/website-downloads/raw/main/Examples-and-Unsupported/PHP_Interface_Example.zip)

## Documentation

For the PHP bindings to build correctly, SWIG Version 1.3.40 is required.

For Soar to interact with PHP, there are a couple of required manual steps:

1.  Open `php.ini` and set the `enable_dl = On`

2.  Copy (or, preferably, create a symbolic link) of
`libPHP_sml_ClientInterface?.so` (in lib) to the PHP `extension_dir` (sans the lib
prefix). You can find this via `phpInfo()` (search for `extension_dir`) or
`php-config --extension-dir`.

For Soar to work with Apache via PHP, there are a couple more required steps:

1.  The module needs to be loaded by default. Open `php.ini` and add
`extension=PHP_smlClientInterface.so` at the end of the list of extensions.

2.  The SML shared library (i.e. `libSoarKernelSML`) needs to be accessible to Apache.
The easiest way to do this is to copy the library to system library path (i.e. 
`/usr/local/lib` on Linux).

## Developers

Nate Derbinsky

## Soar Versions

*   Soar 8
*   Soar 9

## Language

PHP
