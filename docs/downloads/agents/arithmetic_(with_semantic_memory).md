---
Tags:
    - chunking
    - hierarchical task decomposition
    - semantic memory
---

# Arithmetic (with Semantic Memory)

This agent demonstrates the use of semantic memory by extending the
capabilities of the [Arithmetic Agent](./arithmetic.md). The description
of that agent also applies here.

This agent supports using semantic memory through in three different ways
controlled by parameters set in initialize-arithmetic.

1.  If the semantic or working memory is pre-loaded with problems, it will
use those problems. If not it will generate problems at random.

    *   problems-5000.soar and problems-10000.soar contain the rules to
    generate the working memory problems.
    *   problems-5000-smem.soar contains the structure to initialize semantic memory.
    *   Controlled by loading one of those files at run time and setting
    ^parameters.problems-source [wm smem]

1.  Control whether arithmetic facts are computed/stored in working memory
or semantic memory. If in semantic memory, will dynamically generated
using counting (process-column/compute-result/add-via-counting)

    *   Controlled by parameters.fact-source [wm smem]
    *   To experiment with impact of semantic memory, can control whether
    facts are stored in semantic memory (or will always be counted) via
    parameters.store [yes no] and whether they are attempted to be retrieved
    parameters.retrieve [yes no]
    *   Number of problems attempted is set by count, which is usually 5000 or 10000.

*Note*: This agent does not currently work with Soar 9.6.0+ due to changes
in the semantic memory model.

## External Environment

None

## Soar Capabilities

*   Semantic Memory
*   Hierarchical task decomposition
*   Chunking

## Download Links

*   [Arithmetic-SMem_Agent.zip](https://github.com/SoarGroup/website-downloads/raw/main/Agents/Arithmetic-SMem_Agent.zip)

## Associated Agents

None TODO (not for agents)

## Default Rules

None

## Associated Publications

None

## Developers

John Laird

## Soar Versions

*   Soar 9.2 - 9.4.0

## Project Type

VisualSoar
