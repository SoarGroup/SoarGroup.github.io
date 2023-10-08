# Introduction

Soar has been developed to be an architecture for constructing general intelligent systems.
It has been in use since 1983, and has evolved through many different versions. This manual
documents the most current of these: version 9.6.1.

Our goals for Soar include that it ultimately be an architecture that can:

- be used to build systems that work on the full range of tasks expected of an
intelligent agent, from highly routine to extremely difficult, open-ended problems;
- represent and use appropriate forms of knowledge, such as procedural, declarative,
episodic, and possibly iconic;
- employ the full range of possible problem solving methods;
- interact with the outside world; and
- learn about all aspects of the tasks and its performance on those tasks.

In other words, our intention is for Soar to support all the capabilities required of a general
intelligent agent. Below are the major principles that are the cornerstones of Soar’s design:

1. The number of distinct architectural mechanisms should be minimized. Classically
   Soar had only a single representation of permanent knowledge (production rules), a
   single representation of temporary knowledge (objects with attributes and values), a
   single mechanism for generating goals (automatic subgoaling), and a single learning
   mechanism (chunking). It was only as Soar was applied to diverse tasks in complex
   environments that we found these mechanisms to be insufficient and added new long-
   term memories (semantic and episodic) and learning mechanisms (semantic, episodic,
   and reinforcement learning) to extend Soar agents with crucial new functionalities.
2. All decisions are made through the combination of relevant knowledge at run-time.
   In Soar, every decision is based on the current interpretation of sensory data and any
   relevant knowledge retrieved from permanent memory. Decisions are never precompiled
   into uninterruptible sequences.


## Using this Manual

We expect that novice Soar users will read the manual in the order it is presented. Not
all users will makes use of the mechanisms described in chapters 4-8, but it is important to
know that these capabilities exist.

[Chapter 2](./02_TheSoarArchitecture.md#the-soar-architecture) and [Chapter
3](./03_SyntaxOfSoarPrograms.md#the-syntax-of-soar-programs) describe Soar from
different perspectives: Chapter 2 describes the Soar architecture, but avoids
issues of syntax, while Chapter 3 describes the syntax of Soar, including the
specific conditions and actions allowed in Soar productions.

[Chapter 4](./04_ProceduralKnowledgeLearning.md#procedural-knowledge-learning)
describes chunking, Soar’s mechanism to learn new procedural knowledge
(productions).

[Chapter 5](./05_ReinforcementLearning.md#reinforcement-learning) describes
reinforcement learning (RL), a mechanism by which Soar’s procedural knowledge is
tuned given task experience.

[Chapter 6](./06_SemanticMemory.md#semantic-memory) and [Chapter
7](./07_EpisodicMemory.md#episodic-memory) describe Soar’s long-term declarative
memory systems, semantic and episodic.

[Chapter 8](./08_SpatialVisualSystem.md#spatial-visual-system) describes the
Spatial Visual System (SVS), a mechanism by which Soar can convert complex
perceptual input into practical semantic knowledge.

[Chapter 9](./09_SoarUserInterface.md#the-soar-user-interface) describes the
Soar user interface — how the user interacts with Soar. The chapter is a catalog
of user-interface commands, grouped by functionality. The most accurate and
up-to-date information on the syntax of the Soar User Interface is found online,
at the Soar web site, at <https://github.com/SoarGroup/Soar/wiki/CommandIndex>.

Advanced users will refer most often to Chapter 9, flipping back to Chapters 2 and 3 to
answer specific questions.

Chapters 2 and 3 make use of a Blocks World example agent. The Soar code for
this agent can be downloaded at
<https://web.eecs.umich.edu/~soar/blocksworld.soar> or found
[here](blocksworld.md).

### Additional Back Matter

After these chapters is an index; the last pages of this manual contain a
summary and index of the user-interface functions for quick reference.

### Not Described in This Manual

Some of the more advanced features of Soar are not described in this manual,
such as how to interface with a simulator, or how to create Soar applications
using multiple interacting agents. The Soar project website (see link below)
has additional help documents and resources.

For novice Soar users, try [*The Soar 9 Tutorial*](../tutorials/soar_tutorial/index.md),
which guides the reader through several example tasks and exercises.

## Contacting the Soar Group

The primary website for Soar is:

<http://soar.eecs.umich.edu/>

Look here for the latest Soar-related downloads, documentation, FAQs, and announcements,
as well as links to information about specific Soar research projects and researchers.

Soar kernel development is hosted on GitHub at

<https://github.com/SoarGroup>

This site contains the public GitHub repository, a wiki describing the command-line interface,
and an issue tracker where users can report bugs or suggests features.

To contact the Soar group or get help, or to receive notifications of significant developments
in Soar, we recommend that you register with one or both of our email lists:

For questions about using Soar, you can use the soar-help list. For other discussion or to
receive announcements, use the soar-group list.

Also, please do not hesitate to file bugs on our issue tracker:

<https://github.com/SoarGroup/Soar/issues>

To avoid redundant entries, please search for duplicate issues first.

## For Those Without Internet Access

Mailing Address:

```
The Soar Group
Artificial Intelligence Laboratory
University of Michigan
2260 Hayward Street
Ann Arbor, MI 48109-2121
USA
```

## Different Platforms and Operating Systems

Soar runs on a wide variety of platforms, including Linux, Unix (although not heavily tested),
Mac OS X, and Windows 10, 7, possibly 8 and Vista, XP, 2000 and NT). We currently test
Soar on both 32-bit and 64-bit versions of Ubuntu Linux, OS X 10, and Windows 10.

This manual documents Soar generally, although all references to files and directories use
Unix format conventions rather than Windows-style folders.
