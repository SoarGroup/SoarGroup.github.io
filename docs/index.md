# What is Soar?

Soar is a general cognitive architecture for developing systems that exhibit
intelligent behavior. Researchers all over the world, both from the fields of
artificial intelligence and cognitive science, are using Soar for a variety of
tasks. It has been in use since 1983, evolving through many different versions
to where it is now Soar, Version 9.

We intend ultimately to enable the Soar architecture to:

- work on the full range of tasks expected of an intelligent agent, from highly
  routine to extremely difficult, open-ended problems
- represent and use appropriate forms of knowledge, such as procedural,
  semantic, episodic, and iconic
- employ the full range of problem solving methods
- interact with the outside world, and
- learn about all aspects of the tasks and its performance on them.

In other words, our intention is for Soar to support all the capabilities
required of a general intelligent agent.

The ultimate in intelligence would be complete rationality which would imply the
ability to use all available knowledge for every task that the system
encounters. Unfortunately, the complexity of retrieving relevant knowledge puts
this goal out of reach as the body of knowledge increases, the tasks are made
more diverse, and the requirements in system response time more stringent. The
best that can be obtained currently is an approximation of complete rationality.
The design of Soar can be seen as an investigation of one such approximation.
Below is the primary principle which is the basis of Soar's design and which
guides its attempt to approximate rational behavior.

All decisions are made through the combination of relevant knowledge at
run-time. In Soar, every decision is based on the current interpretation of
sensory data, the contents of working memory created by prior problem solving,
and any relevant knowledge retrieved from long-term memory. Decisions are never
precompiled into uninterruptible sequences. For many years, a secondary
principle has been that the number of distinct architectural mechanisms should
be minimized. Through Soar 8, there has been a single framework for all tasks
and subtasks (problem spaces), a single representation of permanent knowledge
(productions), a single representation of temporary knowledge (objects with
attributes and values), a single mechanism for generating goals (automatic
subgoaling), and a single learning mechanism (chunking). We have revisited this
assumption as we attempt to ensure that all available knowledge can be captured
at runtime without disrupting task performance. This is leading to multiple
learning mechanisms (chunking, reinforcement learning, episodic learning, and
semantic learning), and multiple representations of long-term knowledge
(productions for procedural knowledge, semantic memory, and episodic memory).

Two additional principles that guide the design of Soar are functionality and
performance. Functionality involves ensuring that Soar has all of the primitive
capabilities necessary to realize the complete suite of cognitive capabilities
used by humans, including, but not limited to reactive decision making,
situational awareness, deliberate reasoning and comprehension, planning, and all
forms of learning. Performance involves ensuring that there are computationally
efficient algorithms for performing the primitive operations in Soar, from
retrieving knowledge from long-term memories, to making decisions, to acquiring
and storing new knowledge.

For further background on Soar, we recommend *Introduction to Soar* at
<https://arxiv.org/abs/2205.03854> and *The Soar Cognitive Architecture* Laird,
J.  E.(2012), The Soar Papers: *Readings on Integrated Intelligence*,
Rosenbloom, Laird, and Newell (1993), and *Unified Theories of Cognition*,
Newell (1990). Also available are *Soar: A Functional Approach to General
Intelligence* and *Soar: A comparison with Rule-Based Systems*. There is also a
full [list of publications available](./soar/Publications.md). Entries on
the Soar Knowledge Base and the older 
[Soar FAQ](http://acs.ist.psu.edu) also provide answers to many common
questions about Soar.

We would like to extend a special thank you to DARPA, ONR and AFOSR for their
continued support of Soar and projects related to Soar.
