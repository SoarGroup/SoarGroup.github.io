---
date: 2014-10-07
authors:
    - soar
tags:
    - kernel programming
---

<!-- old URL: https://soar.eecs.umich.edu/articles/articles/technical-documentation/201-memory-leak-debugging-with-visual-studio -->

# Memory Leak Debugging with Visual Studio

This document summarizes one technique for fixing memory leaks in the Soar
kernel using Visual Studio's Leak Detection tools.

First, choose a program you will use for testing. I recommend TestCLI or
TestClientSML or some other program that can repeatably cause leaks.

At the top of the file containing main.cpp, add this:

```c++
#ifdef _MSC_VER
// Use Visual C++'s memory checking functionality
#define _CRTDBG_MAP_ALLOC
#include <crtdbg.h>
#endif // _MSC_VER
```

This enables the leak-detection versions of the memory allocation and
de-allocation functions.

At the beginning of the main function, add this code:

```c++
#ifdef _MSC_VER
        //_crtBreakAlloc = 1828;
        _CrtSetDbgFlag ( _CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF );
#endif // _MSC_VER
```

The #ifdef's make sure that we don't try this with any other compiler. _The
CrtSetDbgFlag line says "report detected leaks when the program exits." This is
the preferred method -- it is possible to put a similar line at the end of main
that says "report detected leaks now", but this is subtly different -- objects
allocated in the main function may not be deallocated yet, and dlls are not yet
unloaded. This can lead to false leak reports. So do it the way I have shown._

I will describe the purpose of the commented line in a moment.

This is enough to get your test program to report any leaks. The program (and
any code you're testing) needs to be compiled in Debug mode for this to work. A
leak report will look something like this:

```
Detected memory leaks!
Dumping objects ->
{19907} normal block at 0x00B24688, 11 bytes long.
Data: <    <#d*1> > 0B 00 00 00 3C 23 64 2A 31 3E 00
{19906} normal block at 0x00B60360, 104 bytes long.
 Data: <                > 00 00 00 00 01 00 00 00 00 CD CD CD CD CD CD CD
{3840} normal block at 0x00B2B240, 12 bytes long.
 Data: <    desired > 0C 00 00 00 64 65 73 69 72 65 64 00
{3839} normal block at 0x00B2B198, 104 bytes long.
 Data: <                > 00 00 00 00 01 00 00 00 02 CD CD CD CD CD CD CD
{1828} normal block at 0x00AE4BC8, 8 bytes long.
 Data: <H       > 48 02 AF 00 00 00 00 00
{1699} normal block at 0x00B195C0, 56 bytes long.
 Data: <                > 00 00 00 00 CD CD CD CD CD CD CD CD CD CD CD CD
{1698} normal block at 0x00B19550, 48 bytes long.
 Data: <@               > 40 CD CD CD CD CD CD CD 00 00 00 00 00 00 00 00
Object dump complete.
```

What this means is that there were 7 leaks in this run. The number in {} is the
allocation number of the leaked memory (e.g. {1698} means the 1698th malloc
wasn't freed). The leaks are reported in reverse order for some reason. The Data
line can sometimes give you a clue as to what is leaking. But the key is the
number in the {}. In the code you added at the beginning of main, change the
number in the commented line to one of the leak numbers (e.g. 1698 in the above
report) and uncomment the line. I recommend doing this in the order in which the
leaks occur (i.e. start at the bottom of the list), because some leaks can cause
others or appear many times, so if you fix them in order some of the later ones
may go away.

Now run the program again. The code will break on the allocation number you
specified (I recommend running the code from within Visual Studio as this will
make bringing up the line of code easier). It is very important that this run be
exactly like the previous run so that the same allocations occur in the same
order. Otherwise the code will break on some irrelevant allocation. This means
removing any randomness in the code execution. For multithreaded code this can
be a pain, so I recommend coming up with the simplest possible test case that
reproduces the leak you're working on. Sometimes the leak number will change
over time because of threading issues, but will remain the same for a while. So
it's important to regenerate the report periodically to make sure the allocation
number you're working with is still accurate.

When the code breaks, it will probably dump you in a low-level system file like
dgbheap.c where the actual malloc is taking place. This is probably not
interesting to you. You want to look at your callstack and find the relevant
place in your code that you can actually do something about.

## Soar Kernel Gotchas

Most leaks reported in the kernel will be in the allocate_memory function. You
will need to look higher up in the callstack to find the real source of the
problem. This will often be in a call to a function like get_new_io_identifier
or add_input_wme. Often, these functions return a pointer that is not saved, and
thus cannot be released when it goes away or the agent is destroyed (much of the
memory cleanup occurs in destroy_soar_agent).

When working with Soar kernel code, some of the leak locations can be confusing.
For example, if a hashtable is leaking, the reported leak may not occur where
the hashtable was originally allocated, but rather where the hashtable was last
resized. This kind of leak can appear to move around depending on what Soar code
is run, because some code will require more allocations than others, but only
the last one leaks. A similar thing can happen with memory pools (BTW, I believe
all hashtable and memory pool leaks have been fixed now).

It's also very common for symbols to leak. This is usually because the ref
counts have not gone to zero for some reason, but it can also be because a
pointer to the symbol was not saved so that it could be released. Most
"built-in" symbols are released in the release_predefined_symbols function.

## Finding Leaks to the Memory Pools

Soar uses memory pools for efficiency. These pools are deallocated when the
agent is destroyed. Thus, if code takes memory from the pool without returning
it, the leak detection will not see this because all of the pool memory is
returned to the OS at the end. These kinds of leaks can cause memory usage to
climb while Soar is running, however.

In order to find these leaks, the memory pools must be disabled. This will hurt
performance, but it will allow the leaks to be detected.

To disable the memory pools, find the functions allocate_with_pool and
free_with_pool in mem.h. Comment out everything in those functions, and
uncomment the last line. Now, calls to get memory from a pool and to release
memory back to the pool will just do a standard malloc and free.

It should be noted that this can sometimes uncover bad pointer bugs. When the
pool is in use, memory returned to the pool is probably not overwritten
immediately. So if a pointer to that released memory is accessed, there is a
good chance that it will work. When the pools are disabled, though, that memory
is overwritten (in a DEBUG build, at least), and so such accesses will fail.
Thus, you should periodically disable the pools even if you aren't looking for
leaks to check your code in this way.

## Finding leaks in DLLs and modules for other languages

If the .exe you are using has the memory leak detection code as described above
and you are using Multithreaded Debug DLL code generation setting, then leaks in
DLLs used by that .exe will also be reported.

If the above conditions are not met and you want to check for leaks in a DLL,
you need to add some special code to the DLL:

```

// Check for memory leaks
#if defined(_DEBUG) && defined(_WIN32)
#define _CRTDBG_MAP_ALLOC
#include <stdlib.h>
#include <crtdbg.h>

bool __stdcall DllMain( void _ hModule,
unsigned long ul_reason_for_call,
void _ lpReserved)
{
//_crtBreakAlloc = 1397;
_CrtSetDbgFlag ( _CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF );
return 1;
}
#endif
```

This will report leaks for the DLL just as the .exe did before. Note that if you
have the leak detection in both places, then the DLL leaks will get reported
twice.

For detecting leaks in programs written in other languages (e.g. Java), this
code needs to be in the SWIG-generated DLL. We've already put it in there for
you, so all you need is a debug build to see it (be sure to run from the command
line so you can see this output at the end). The reported leaks should not be in
the languages themselves, but rather in the SWIG or SML DLLs. Note that the Tcl
and Python modules report lots of leaks (the SWIG people tell me this is because
of the nature of memory management in those languages), so it may be difficult
to pick out the leaks you are interested in for those languages.
