<!-- markdownlint-disable-next-line -->
{{manual_wip_warning}}

# Procedural Knowledge Learning

## Chunking

Chunking is Soar’s experience-based mechanism for learning new procedural
knowledge. Chunking utilizes Soar’s impasse-driven model of problem
decomposition into sub-goals to create new productions dynamically during task
execution. These new productions, called **chunks**, summarize the substate
problem-solving that occurred which led to new knowledge in a superstate.
Whenever a rule fires and creates such new superstate knowledge, which are
called **results**, Soar learns a new rule and immediately adds it to production
memory. In future similar situations, the new chunk will fire and create the
appropriate results in a single step, which eliminates the need to spawn another
subgoal to perform similar problem-solving. In other words, rather than
contemplating and figuring out what to do, the agent immediately knows what to
do.

Chunking can effect both speed-up and transfer learning. A chunk can effect
speed-up learning because it compresses all of the problem-solving needed to
produce a result into a single step. For some real-world agents, hundreds of
rule firings can be compressed into a single rule firing. A chunk can effect
transfer learning because it generalizes the problem-solving in such a way that
it can apply to other situations that are similar but have not yet been
experienced by the agent.

Chunks are created whenever one subgoal creates a result in a superstate; since
most Soar programs are continuously sub-goaling and returning results to
higher-level states, chunks are typically created continuously as Soar runs.
Note that Soar builds the chunk as soon as the result is created, rather than
waiting until the impasse is resolved.

While chunking is a core capability of Soar, procedural learning is disabled by
default. Refer to the following CLI commands for more information about enabling
and using chunking:

1.  [chunk](../reference/cli/cmd_chunk.md)
1.  [trace](../reference/cli/cmd_trace.md)
1.  [explain](../reference/cli/cmd_explain.md)
1.  [visualize](../reference/cli/cmd_visualize.md)

## Explanation-based Chunking

Explanation-based chunking improves on previous versions of chunking by learning
rules that are qualitatively more general and expressive. In fact, any element
of a learned rule can now be variablized, and learned rules now have the full
expressive power of hand-written rules.

The following side-by-side code comparison shows an example of an
explanation-based chunk and how it differs from a chunk learned from the
original algorithm. It is interesting to note that in Soar 9.4, the arithmetic
agent learns 1263 rules like the one on the left-side of the figure. In Soar
9.6, the same agent only learns 8 rules like the one on the right because they
are so much more general.

<div class="grid cards" markdown>

```Soar title="Soar 9.4.0 chunk"
sp {chunk-94*process-column*apply
   (state <s1> ^operator <o1>
           ^arithmetic-problem <a1>
           ^one-fact 1

           ^top-state <s1>
           ^arithmetic <a2>
           ^arithmetic <a3>)
   (<o1> ^name process-column)
   (<a1> ^operation subtraction
          ^current-column <c1>)
   (<c1> -^new-digit1 <n1>
           ^digit1 0
           ^digit2 7
           ^next-column <n2>)
   (<n2> ^digit1 0
           ^new-digit1 9
           ^next-column <n3>)
   (<n3> ^digit1 5
           ^new-digit1 4)
   (<a2> ^subtraction-facts <s2>
           ^subtraction-facts <s3>
           ^subtraction-facts <s4>)
   (<a3> ^add10-facts <a4>)

   (<a4> ^digit1 0
           ^digit-10 10)


   (<s2> ^digit1 10 ^digit2 1
           ^result 9)
   (<s3> ^digit1 5 ^digit2 1
           ^result 4)
   (<s4> ^digit1 10 ^digit2 7
           ^result 3)
   -->
   (<c1> ^result 3)}
```

<!-- markdownlint-disable-next-line -->
```Soar hl_lines="4 5 13 14 16 17 19 20 25-35 37" title="Soar 9.6.0 explanation-based chunk"
sp {chunk-96*process-column*apply
   (state <s1> ^operator <o1>
           ^arithmetic-problem <a1>
           ^one-fact <o2>
           ^one-fact <o3>
           ^top-state <t1>
           ^arithmetic <a2>
           ^arithmetic <a3>)
   (<o1> ^name process-column)
   (<a1> ^operation subtraction
          ^current-column <c1>)
   (<c1> -^new-digit1 <n1>
           ^digit1 { <d2> < <d1> }
           ^digit2 <d1>
           ^next-column <n2>)
   (<n2> ^digit1 { <d3> < <o3> }
           ^new-digit1 <n3>
           ^next-column <n4>)
   (<n4> ^digit1 { <d4> >= <o2> }
           ^new-digit1 <n5>)
   (<a2> ^subtraction-facts <s2>
           ^subtraction-facts <s3>
           ^subtraction-facts <s4>)
   (<a3> ^add10-facts <a4>
           ^add10-facts <a5>)
   (<a4> ^digit1 <d2>
           ^digit-10 { <d5> >= <d1> })
   (<a5> ^digit1 <d3>
           ^digit-10 { <d6> >= <o3> })
   (<s2> ^digit1 <d6> ^digit2 <o3>
           ^result <n3>)
   (<s3> ^digit1 <d4> ^digit2 <o2>
           ^result <n5>)
   (<s4> ^digit1 <d5> ^digit2 <d1>
           ^result <r1>)
   -->
   (<c1> ^result <r1>)}
```

</div>

To achieve this generality, chunking needs information about why rules matched
in a sub-state and how those rules interacted. This allows it to determine what
is generalizable and what limits there are on those generalizations.
Unfortunately, the information necessary to determine this information was not
readily available in prior versions of Soar which only recorded a trace of all
WMEs that were tested in the substate. This trace, which we call the working
memory trace possesses limited explanatory information, which limited chunking
to learning very specific rules in which only Soar identifiers were variablized
and all other elements tested the exact values found in the working memory
trace.

To remedy this limitation and produce more general chunks, EBC instead analyzes
two traces simultaneously: the working memory trace and a corresponding trace of
the hand-written rules that matched in the substate. This new network of rule
matches is called the explanation trace:

![A close-up of a trace showing differences between a working memory trace (left) and an explanation trace (right). The working memory trace only contains the literal values of the WMEs that matched. The explanation trace, on the other hand, contains variables and various constraints on the values those variables can hold.](Images/chunking-wm-vs-exp-trace.png)

Note that this trace is generated dynamically as rules match. Whenever a rule
matches during agent execution, Soar creates an internal record of the rule that
fired, which is called a rule instantiation. (Each box in the explanation traces
of this chapter represents an instantiation that was created during task
execution within a particular substate.) The instantiation contains both
instance information about what matched (the working memory elements) and
explanatory information about why they matched (the rules and actions in the
original rules that contains variables, constraint tests, RHS actions, etc.).

Note that WMEs that were automatically created by the architecture have special
instantiations that explain why they were created. For example, an architectural
instantiation is created for each `^item` attribute automatically created in
operator tie impasse substates; the explanation causes the `^item` augmentation
to be dependent on the operator in the super-state that led to it, which means
that chunks learned which tested that `^item` augmentation will cause the chunk to
also be dependent on the operator in the superstate.

Similarly, architectural instantiations are created for structures recalled by
semantic and episodic memory in the substate.

All of the instantiations that were created in a substate form the
_instantiation graph_ of that substate. As chunking **backtraces** through the
instantiation graph, it determines the subset of instantiations that contributed
to a result. This set of instantiations and the connections between them
composes the explanation trace for a learning episode. (So, the explanation
trace is a subgraph of the instantiation graph.)

![A visualization of the explanation trace of a chunk learned by the arithmetic agent. Each box represents a rule that fired in the substate. Arrows show dependencies between rules that create working memory elements and conditions that test those working memory elements.](Images/chunking-trace.png)

EBC uses the explanation trace to determine (1) how variables were used during a
problem-solving episode and (2) what constraints on those variables had to be
met in order for the substate rules to match. EBC then uses the results of this
analysis to create more expressive and general rules, which can contain the full
gamut of tests that hand-written rules can and can have any element variablized.

<!-- TODO What is gamut? -->

## Overview of the EBC Algorithm

**Basic concepts**:

-   Every condition and action in the explanation trace has three elements:
    -   For conditions, the three elements refer to the symbol in the positive
        equality test for the identifier, attribute and value of the condition.
        For example, the last condition of rule 2 in the
        <a href="#fig_explanation_trace">explanation trace figure</a> has `<s>` as
        the identifier element, number as the attribute element, and `<y>` as
        the value element.
    -   For actions, the three elements refer to the identifier, attribute and
        value of the WME being created.
-   An element is either a variable, like `<s>` or a literal constant, like `23`,
    `3.3`, or `someString`

### Identity

Before we can discuss the algorithm, we must first define one of its central
concepts: _identity_.

-   **An identity is the set of all variables in a trace that refer to the same
    underlying object.** - So we can say that two _variables_ are said to _share
    an identity_ if they both refer to the same underlying object.
-   **The NULL identity is a special identity that indicates an element which
    cannot be generalized and must contain a specific value.** - All elements in
    the original rule that reference specific constant values are trivially
    assigned the NULL identity. - A variable’s identity can also be _mapped to the
    NULL identity_. When this happens, we say the identity has been
    **literalized**.

EBC traverses an explanation trace of the problem-solving that occurred in the
substate to determine which variables in different rule instances refer to the
same underlying object. There are two ways that an explanation trace can show a
shared identity:

1.  Variables that have the same name and are in the same rule firing will share
    an identity This is the trivial case. The basic semantics of rules implies that
    the same variable in a rule references the same underlying object.
2.  If a RHS action of one rule creates a WME and a LHS condition of another
    rules tests that same WME, then all variables in the condition and actions will
    possess the same identity as their counterpart’s corresponding element. The
    interaction between the two rules indicates a shared identity between their
    corresponding variables.

<p id="fig_explanation_trace"/>
![An explanation trace of two simple rules that matched in a substate.](Images/chunking-trace2.png)

To get a better picture of what a shared identity is, consider the two simple
rules and the explanation trace of how they matched in a substate as shown in
the <a href="#fig_explanation_trace">explanation trace figure</a>.
The connection between rule 2 and rule 1 will unify the identities
of `<s>` ,`<x>` an `<y>` in rule 1 with the identities of `<s>` ,`<x>` an `<y2>`
in rule 2. So, the `<x>` in rule 2 shares the same identity as the `<x>` in rule

1.  Similarly, the `<y2>` in rule 2 shares the same identity as `<y>` in rule 1.
    In contrast, the `<y>` in rule 2 does NOT share the same identity as the `<y>`
    in rule 1.

It doesn’t matter that the `<y>` in rule 1 uses the same variable name as
the`<y>` in rule 2. It also doesn’t matter that both conditions with `<y>`
happen to match the same working memory element, `(S1 ^number 3)`. In terms of
sharing an identity, the only thing that matters is how the rules interact,
namely whether there’s a connection between elements in the condition of one
rule and elements in the actions of another rule.

All literal values, for example all of the attribute in the
<a href="#fig_explanation_trace">explanation trace figure</a> (superstate,
number, intermediate1, etc.) are considered members of the `NULL` identity.

Variable identities can also be mapped to the NULL identity, which means that
any elements in the final rule that share that identity will not be variablized.
When this happens, we say that the identity has been literalized. There are two
ways that a rule interaction can effect an identity literalization:

1.  If a RHS action of one rule creates a WME element using a constant, literal
    value in an element and a LHS condition tests that element, then the
    identity of the condition’s variables is literalized and mapped to the NULL
    identity.  Because the variable in the condition matched a rule that will
    always create the same constant, literal value, the condition’s variable
    must have that same value. Otherwise, it would not have matched.
2.  If a RHS action of one rule creates a WME element using a variable and a LHS
    condition tests that that element is a specific value, then the identity of the
    action’s variables is literalized and mapped to the NULL identity. Because the
    condition requires that the rule that created the matched WME to have a specific
    constant, literal value, the action’s variable must have that same value.
    Otherwise, it would not have created something that matched the condition.

Identities are the basis of nearly every mechanism in explanation-based
chunking. EBC’s identity analysis algorithm, which is a fairly complicated
process, determines all shared identities in an explanation trace. The following
<a href="#fig_explanation_trace_after_identity_analysis">figure</a>
shows an explanation trace after identity analysis has been performed. Elements
that share an identity in the figure are colored the same.

<p id="fig_explanation_trace_after_identity_analysis"/>
![An explanation trace after identity analysis.](Images/chunking-trace-identity.png)

While it’s not readable in this figure, note that each identity is assigned a
numeric ID. Both the explainer and the visualizer annotate elements of an
explanation with the identity ID in square brackets. These numbers are simply
syntactic sugar to ease debugging and make traces easier to understand.
Underneath the hood, every test in a condition has a pointer to more complicated
identity data structure that will be discussed in more detail in Section
[Identity Assignment and Propagation](#identity-assignment-and-propagation)
on the identity graph.

![Note that the two rows on the bottom indicate when each component occurs during Soar’s processing.](Images/chunking-ebc-components.png)

### The Five Main Components of Explanation-Based Chunking

1.  **Identity analysis**
    This component determines which variables in an explanation trace share the
    same identity. It also determines which identities are ineligible for
    variablization because they were tested against literal values in some
    rules.  Note that this component has two distinct mechanisms that occur at
    very different times. The first mechanism, identity propagation, occurs
    constantly while problem-solving in the substate. The second mechanism,
    identity graph manipulation, occurs during the learning episode.
2.  **Relevant operator selection knowledge tracking**
    This component also occurs before the learning episode. Whenever an operator
    is selected, it analyzes what rule firings contributed necessary operator
    selection preferences and caches them in all rule instances that tests that
    operator.
3.  **Constraint tracking**
    This component keeps track of every value or relational constraint (e.g. `<>
    <x>,>= 3.14,<< disjunction of constants >>`) placed on the various variables
    that share an identity. It is used by the rule formation component to make
    sure that the learned rule only fires when all constraints required are met.
4.  **Operationality analysis**
    This component determines which conditions in an
    explanation trace tested working memory elements in a superstate. The rule
    formation component will use these conditions as a basis for the left-hand side
    of the chunk. While it does have a few key new differences, this is the one step
    that is similar to previous versions of chunking.
5.  **Rule Formation**
    The above four components performed the analysis that EBC needs to form a
    general but correct rule. This final component uses the results of that
    analysis to actually build the new rule. This is a complex component that has
    seven different stages. If a valid rule is created, Soar immediately adds the
    rule to production memory.

The following sections will describe each component in more detail.

## What EBC Does Prior to the Learning Episode

While most of the work that explanation-based chunking performs occurs during
the learning episode, i.e. after a rule in a substate fires and Soar detects
that a result will be created, some critical aspects of the analysis it performs
also occur prior to the learning episode, during problem-solving in the
substate. The two points when that happens is when a rule fires in a substate
and when an operator is selected in a substate.

### Identity Assignment and Propagation

Each instantiation describes the working memory elements that matched each
condition and the working memory elements and preferences that are created by
each action. With the introduction of EBC, all instantiations now also store the
underlying explanation behind each condition and action as defined by the
original rule: which elements in conditions are variables and which ones are
literal constants, which variables are the same variables, what constraints must
be met on the values of each variable and any relationships between variables.

EBC uses this underlying logic to determine the identities of objects used
during the problem-solving. Identities are not simply IDs. Each identity is a
declarative object that describes a set of variables across multiple rule
firings and the various properties they hold.

_When an instantiation is created, EBC assigns all elements of every condition
and action to an identity, creating new identities as necessary._ Identities are
created and propagated using the following rules:

1.  If the same variable appears in multiple places in the same rule, it must be
    assigned the same identity.
1.  The NULL Identity is assigned to any element with a literal value in the
    original rule.
1.  A new identity is created and assigned for:
    -   All right-hand side action elements that produce a new Soar identifier in
        the substate These are also known as unbound RHS variables.
    -   All variable elements of conditions that matched superstate WMEs It is
        important to note that if two conditions both match the same superstate
        WME, each condition is considered independent. This means that each
        condition is assigned new identities for each of its elements and will
        produce its own condition in the final learned rule. This is a key way
        that EBC differs from previous versions of chunking.
1.  An existing identity is propagated for:
    1.  Any condition element that matched a substate WME with existing identities
        Each element is assigned the identity found in the corresponding element
        of the action of the rule that created that WME. This propagates
        identities forward through the explanation trace, which allows us to
        represent that the variable in the condition refers to the same object
        as the variable in the action of the other rule.
    1.  Any element that matches special working memory elements called singletons
        are assigned the same identity. Singletons are working memory elements
        that are guaranteed to only have a single possible value in a state. The
        most important singleton is the local `^superstate` singleton, which is
        an architecturally created WME that links the substate to the
        superstate, for example `(S2 ^superstate S1)`. Since we know that it’s
        impossible for there to be two superstate features in a state, all
        conditions that test that singleton WME will be assigned the same
        identities. While there are a variety of built-in singletons for
        architecturally-created WMEs, users can also specify their own
        domain-specific singletons to eliminate unnecessary generality when
        learning. The full list of architecturally-created singletons can be
        found in the [`chunk` command’s](../reference/cli/cmd_chunk.md) help
        entry.

Note that rule 1 may conflict with other rules. For example, if a variable
appears in two different conditions, then two different identities may propagate
into each one of them. In such cases, rule 1 is always enforced and propagation
is ignored. During the second phase of identity analysis, which occurs during
the actual learning episode, EBC will re-examine all of the condition-action
pairs as it performs a backward traversal of the explanation trace and fix the
missing propagations. It does this by creating and manipulating an identity
graph that can correctly incorporate all identity relationships.

### Relevant Operator Selection Knowledge Tracking

As described in the beginning of this chapter, chunking summarizes the
processing required to produce the results of subgoals. Traditionally, the
philosophy behind how an agent should be designed was that the path of operator
selections and applications from an initial state in a substate to a result
would always have all necessary tests in the operator proposal conditions and
any goal test, so only those items would need to be summarized. The idea was
that in a properly designed agent, a substate’s operator evaluation preferences
lead to a more efficient search of the space but do not influence the
correctness of the result. As a result, the knowledge used by rules that produce
such evaluation preferences should not be included in any chunks produced from
that substate.

In practice, however, it may make sense to design an agent so that search
control does affect the correctness of search. Here are just two examples:

1.  Some of the tests for correctness of a result are included in productions
    that prefer operators that will produce correct results. The system will work
    correctly only when those productions are loaded.
2.  An operator is given a worst preference, indicating that it should be used
    only when all other options have been exhausted. Because of the semantics of
    worst, this operator will be selected after all other operators; however, if
    this operator then produces a result that is dependent on the operator occurring
    after all others, this fact will not be captured in the conditions of the chunk.

In both of these cases, part of the test for producing a result is implicit in
search control productions. This move allows the explicit state test to be
simpler because any state to which the test is applied is guaranteed to satisfy
some of the requirements for success. However, chunks created in such a problem
space will not be correct because important parts of the superstate that were
tested by operator evaluation rules do not appear as conditions. The chunks
would not accurately summarize the processing in that problem state. The
tracking of **Relevant Operator Selection Knowledge** (ROSK) is a way to address
this issue.

Relevant operator selection knowledge is the set of necessary operator
evaluation preferences that led to the selection of an operator in a subgoal. As
previously described, whenever Soar learns a rule, it recursively backtraces
through rule instances to determine which conditions to include in the final
chunk or justification. With the ROSK, not only does Soar backtrace through each
rule instance that created a matched working memory element, but it also
backtraces through every rule instance that created preferences in the ROSK for
any operator that gave those matched WMEs o-support. By backtracing through that
additional set of preferences at each step of the backtrace, an agent will
create more specific chunks that incorporate the goal-attainment knowledge
encoded in the operator evaluation rules.

Specifically, this component does two things:

1.  When an operator is selected, it analyzes the operator preferences that led
    to the decision, and caches any operator selection knowledge that played a
    necessary role in the selection.
    All necessity preferences, i.e. prohibit and require preferences, are always
    included in the ROSK since they inherently encode the correctness of whether
    an operator is applicable in a problem space. In contrast, some desirability
    preferences (rejects, betters, worses, bests, worsts and indifferents) are
    included in the ROSK depending on the role they play in the selection of the
    operator. How Soar determines which of those preferences to include in the
    ROSK is determined by the preference semantics it uses to choose an
    operator. During the decision phase, operator preferences are evaluated in a
    sequence of seven steps or filters, in an effort to select a single
    operator, as described in
    [how preferences are evaluated to decide an operator](02_TheSoarArchitecture.md#how-preferences-are-evaluated-to-decide-an-operator).
    Each step, or filter, handles a
    specific type of preference. As the preference semantics are applied at each
    step to incrementally filter the candidate operators to a potential selected
    operator, EBC incrementally adds operator preferences to the ROSK based on
    the preferences that were instrumental in applying each filter. A more
    detailed explanation of the logic used at each step can be found in
    [determining which OSK preferences are relevant](#determining-which-osk-preferences-are-relevant).
2.  When an o-supported rule matches, EBC caches the operator’s ROSK in the
    instantiation of that rule. Since that selection knowledge was necessary to
    select the operator needed for the rule to match, chunking must backtrace
    through that knowledge. The operationality analysis component uses the cached
    ROSK to do this and incorporate the necessary operator selection reasoning
    knowledge into the learned rule. For some types of agent designs, including
    operator selection knowledge is needed to ensure correctness.

## What EBC Does During the Learning Episode

All of the previously discussed steps occurred during problem-solving in the
substate as rules matched and operators were selected. It is worth noting that
the analysis performed prior to the learning episode is persistent and can be
shared across learning episodes. In other words, EBC can repeatedly re-use that
analysis if it learns multiple chunks in the same substate.

Every time a rule fires in a substate, Soar checks to see if any of the working
memory elements created by the rule qualify as results. This is when the actual
learning episode begins.

### Calculating the Complete Set of Results

A chunk’s actions are built from the results of a subgoal. Aresultis any
working memory element created in the substate that is linked to a superstate.
A working memory element is linked if its identifier is either the value of a
superstate WME, or the value of an augmentation for an object that is linked to
a superstate.

The results produced by a single production firing are the basis for creating
the actions of a chunk. A new result can lead to other results by linking a
superstate to a WME in the substate. This WME may in turn link other WMEs in the
substate to the superstate, making them results. Therefore, the creation of a
single WME that is linked to a superstate can lead to the creation of a large
number of results. All of the newly created results become the basis of the
chunk’s actions.

### Backtracing and the Three Types of Analysis Performed

When learning a new rule, EBC performs a dependency analysis of the productions
that fired in a substate – a process called backtracing. Backtracing works as
follows. For each instantiated production that creates a subgoal result,
backtracing examines the explanation trace to determine which working memory
elements matched each condition. If the working memory element is local to the
substate, then backtracing recursively examines the instantiation that created
that condition’s matched working memory element. Thus, backtracing traces
backwards through all rules that fired and created working memory elements that
were used to produce a result.

If an instantiation being backtraced through tested a selected operator, EBC
will backtrace through each instantiation that created a preference in that
operator’s relevant operator selection knowledge set. This behavior is off by
default and can be enabled with [`chunk add-osk on`](../reference/cli/cmd_chunk.md).

Multiple components of EBC perform their work during backtracing: operationality
analysis, identity analysis and constraint tracking. The following sections will
discuss what aspects of the agent’s problem-solving are analyzed during
backtracing.

#### Operationality Analysis

The traditional core function of chunking’s backtracing is to determine which
conditions in the working memory trace tested working memory elements accessible
to the superstate. These conditions will form the left-hand side of the rule.

The determination of which conditions to include is analogous to the concept of
operationality in explanation-based techniques. In classic EBL literature,
operationality is typically defined as nodes in the explanation trace that are
"efficiently calculatable". In terms of Soar’s problem-state computational
model, operationality can be defined as any condition that tests knowledge
linked to a superstate.

As EBC is backtracing through rules that fired in a substate, it collects all of
these operational conditions. Once the entire explanation trace is traversed,
the operationality analysis will have determined exactly what superstate
knowledge was tested during the process of creating a result, which it then uses
as the basis for the left-hand side of the newly learned rule.

Note: Soar 9.6.0’s explanation-based approach has led to one key change to
Soar’s operationality analysis. In previous versions of chunking, chunking would
never add two conditions to a chunk that matched the same superstate working
memory element. This made sense because chunking was based on a generalization
of the working memory trace. More than one condition that tested the same WME
would be redundant. Explanation-based chunking, though, learns based on the
reasoning within the original hand-written rules. Since the reasoning behind
each of the two conditions may be different even if they matched the same WME,
EBC must always add both conditions. (Note that there are some exceptions. See
[chunk singletons](../reference/cli/cmd_chunk.md#user-singletons)
on superstate singletons and user singletons.)

Negated conditions are included in a trace in the following way: when a
production fires, its negated conditions are fully instantiated with its
variables’ appropriate values. This instantiation is based on the working
memory elements that matched the production’s positive conditions. If the
variable is not used in any positive conditions, such as in a conjunctive
negation, a dummy variable is used that will later become a variable in a chunk.
If the identifier used to instantiate a negated condition’s identifier field is
linked to the super-state, then the instantiated negated condition is added to
the trace as a negated condition. In all other cases, the negated condition is
ignored because the system cannot determine why a working memory element was not
produced in the subgoal and thus allowed the production to fire.

#### Identity Analysis

The first phase of identity analysis, forward identity propagation, occurred as
rules fired and instantiations were recorded. Unfortunately, forward propagation
alone will not produce correct identities. We previously gave one reason why
this is the case – conditions may have conflicting identities propagated forward
– but there are other, more complicated reasons as well that are beyond the
scope of this document. What is important to know is that a second phase of
identity analysis will be performed during backtracing that will refine and
correct the limitations of the initial forward propagation of identity. This
second phase achieves these corrections by building an identity graph, which
represent the identities involved during problem-solving, and manipulating it as
it backtraces through the explanation trace.

##### The Identity Graph

The identity graph initially contains a node for each identity used in the
explanation trace. Each node can have multiple edges that point to children
identities and a single directed join edge that initially points back to itself.
As the agent backtraces through the explanation trace, EBC will manipulate the
identity graph based on the condition-action pairs it encounters.

1.  **Joining identities**
    If a condition matches an action with a conflicting identity, EBC performs a
    join operation between the two identities. This chooses one identity as
    the joined identity and points the join edges of the other identity and any
    previously joined identities to the new joined identity. Note that any time
    EBC uses an element’s identity, it is actually using the joined identity.
2.  **Literalizing identities**
    If a condition/action with a variable element matches an action/condition
    with a literal element, EBC marks the identity as literalized. This means
    that any conditions in the final chunk that have elements with that identity
    will be considered to have the NULL identity, just like constants, and will
    not be variablized. Instead, the matched value will be used for that
    element.

#### Constraint Tracking

Our definition of operationality is very clear and allows us to almost trivially
determine which conditions we should include in a learned rule, but it does have
one shortcoming: non-operational conditions, which are ones that don’t test
working memory elements in the superstate, can transitively place constraints on
the values of variables in operational conditions that will appear in a chunk. If
our learning algorithm does not include these constraints, the learned rule can
apply to situations where the previous substate reasoning could not have
occurred, which means that the learned rule is over-general.

To handle this limitation,EBC keeps track of all constraints found in
non-operational conditions that it encounters while backtracing in the following
manner:

-   It stores constraints on the value a single identity, for example>= 0,< 23.
-   It stores relational constraints between two identities, for example>
    `<min>`, `< <max>` or `<> <other>`.
-   EBC stores all of these constraints based on the underlying identities, not
    the variables used. For example, if a variable `<foo>` had the constraint `<>
    <other>`, EBC would record that the variables that share the identity of
    `<foo>` cannot have the same value as variables that share the identity of
    `<other>`.

### Rule Formation

There are seven distinct, sequential stages to rule formation.
The following sections will give a brief overview of each one.

1.  Conditions and Action Generation
2.  Constraint Enforcement
3.  Identity-based Generalization
4.  Condition Merging
5.  Condition Polishing
6.  Rule Repair and Validation
7.  Condition Re-Ordering

#### Condition and Action Creation

This stage creates the basis for the left-hand and right-hand side of the rule.
To create the initial conditions of the chunk, it copies all conditions in the
explanation trace that were flagged as operational during backtracing. These
initial conditions contain literal values for each element. To form the actions
of the chunk, it creates copies of the actions that produced each of the result
and all children of those results that came along for the ride.

#### Enforcement of Constraints

This stage adds all constraints on non-operational conditions that were
collected during backtracing. As previously described, each constraint is
indexed in terms of the identity it constrains. So,if the identity being
constrained exists in one of the conditions of the learned rule, EBC will
enforce the constraint by adding a new test to that condition.

One situation in which attaching a constraint can be tricky occurs when the
constrained identity has been literalized but the constraint itself refers to an
identity that has not been literalized, for example `{ > <x> 3 }`. While that
constraint references a condition element that can only match a value of 3 , the
relationship between 3 and the identity o `<x>` must still hold (assuming `<x>`
appears in a different element somewhere else in the rule.) Since these
constraints still need to be enforced to ensure a correct rule, EBC will invert
the constraint and attach it to a variable in another condition. In this
example, it would add `a < 3` to some other condition with an element that had
`<x>`’s identity.

#### Identity-Based Variablization

To achieve any useful generality in chunks, identifiers of actual objects must
be replaced by variables when the chunk is created; otherwise chunks will only
ever fire when the exact same objects are matched. At this point in the
algorithm, all of the real work needed to determine the most general but correct
variablization has already been performed by the identity analysis component.

So, this step simply needs to replace all elements with non-NULL identities with
variables, making sure that elements with the same joined identity are assigned
the same variable. This step also makes sure to skip and elements with
identities that have been flagged as literalized.

#### Merging Redundant Conditions

Any two conditions in the learned rule that share the same identities in all
three elements can be combined. In such cases, it is logically impossible for
those two conditions to match two different WMEs and cause the same rules to
match in the substate. (If the two conditions were to match two different WMEs,
at least one of the other rules in the explanation trace that had unified the
two conditions would not have matched.) As a result, EBC can safely merge those
two conditions without losing generality.

#### Polishing Conditions

EBC polishes the conditions of the learned rule by pruning unnecessary
constraints on literalized elements and replacing multiple disjunction
constraints with a single simplified disjunction.

1.  Merging disjunctions: If an element in a condition has two disjunction
    tests, the constraints will be merged into a single disjunction that
    contains only the shared values. `{ << a b c >> << b c d >> <x>}` becomes `{
<<b c >> <x> }`, because it is impossible fo `<x>` to be either a or b. This
    will also eliminate any duplicate disjunctions.
2.  Throwing out unnecessary constraints: If an element in a condition has been
    literalized but also has a literal constraint on its value, then the
    constraint is unnecessary and will be thrown out. For example, `<s> ^value{ <
33 23 }` becomes `<s> ^value 23`.

#### Validating Rule and Repairing Unconnected Conditions

At this point, the rule is essentially formed. Chunking must now make sure that
the learned rule is fully operational and can be legally added to production
memory. A fully operational rule does not have any conditions or actions that
are not linked to a goal state specified in the rule.

If an unconnected action or condition is found, EBC will attempt to repair the
rule by adding new conditions that provide a link from a state that is already
tested somewhere else in the rule to the unconnected condition or action.

To repair the rule, EBC performs a search through working memory to find the
shortest path of working memory elements that lead from a state identifier in
the rule to a WME with the identifier in the unconnected condition or action. A
new condition is then added for every WME in that found path, which is then
variablized.

Note that there may be multiple paths from a state to the unconnected
identifier. EBC does a breadth-first search, so it will find one with the
shortest distance.

#### Re-ordering Conditions

Since the efficiency of the Rete matcher depends heavily upon the order of a
production’s conditions, the chunking mechanism attempts to sort the chunk’s
conditions into the most favorable order. At each stage, the condition-ordering
algorithm tries to determine which eligible condition, if placed next, will lead
to the fewest number of partial instantiations when the chunk is matched. A
condition that matches an object with a multi-valued attribute will lead to
multiple partial instantiations, so it is generally more efficient to place
these conditions later in the ordering. This is the same process that internally
reorders the conditions in user-defined productions, as mentioned briefly in
[the structure of a production](02_TheSoarArchitecture.md#the-structure-of-a-production).

## Subtleties of EBC

### Relationship Between Chunks and Justifications

Chunks are closely related to another type of rule called a justification.
Justifications are also created when a substate creates a result for a
superstate, the difference being that justifications are only built when
learning is off. These justifications are needed to decide whether the working
memory elements in the result should get i-support or o-support in the
superstate. To do that, Soar needs to determine whether any rules involved in
the creation of the result tested the selected operator in the superstate, which
is exactly the same type of analysis that chunking does.

As a result, Soar uses a limited version of the chunking algorithm to do that.
It analyzes the substate problem-solving and learns a new, temporary rule, a
"justification", which is added to production memory. If this temporary rule
tests an operator in the superstate, it gives the result o-support. (Note that
when learning is on, a justification is not needed since the chunk will provide
the correct support.)

Justifications use all the components described in the following sections and
are even affected by the current chunk settings. You
can even print justifications out like other rules. The only differences between
chunks and justifications are:

???+ info
    Even though justifications don’t contain variables, justifications can be over-general
    because they don’t incorporate enough knowledge, for example, operator
    selection knowledge.

1.  Every condition and action in a justification contain the literal values
    that matched. Justifications contain no variables.

    ???+ info
        Justifications can have variables in the negated conditions and negated
        conjunctions of conditions. They just don’t have any variables in its
        positive conditions.

2.  Justifications don’t contain any of the value constraints that a chunk would
    have.
3.  Justifications get removed from production memory as soon as their
    conditions no longer match.

### Chunk Inhibition

If a newly learned chunk was immediately added to production memory, it would
immediately match with the same working memory elements that participated in its
creation. This can be problematic if the production’s actions create new working
memory elements. Consider the case where a substate proposes a new operator,
which causes a chunk to be learned that also proposes a new operator. The chunk
would immediately fire and create a preference for another new operator, which
duplicates the operator preference that was the original result of the subgoal.

To prevent this, Soar uses inhibition. This means that each production that is
built during chunking is considered to have already fired with an instantiation
based on the exact set of working memory elements used to create it.

Note that inhibition does not prevent a newly learned chunk from immediately matching
other working memory elements that are present and creating a new instantiation.

### Chunks Based on Chunks

When a problem has been decomposed into more than one substate, a single result
can produce multiple chunks. This process is called bottom-up chunking. The
first chunk is produced in the substate where the problem-solving that produced
the result occurred. The next chunk is based on the implicit match of the first
chunk in one of the higher level problem-spaces. If that match is lower than
the state that the result is being returned to, Soar will backtrace through the
chunk match and learn a second chunk (relative to the substate that the chunk
matched in). This process continues until it learns a chunk that only creates
working memory elements in the same state that it matched in.

### Mixing Chunks and Justifications

If an agent is using the only or except setting, then justifications will be
built in states where learning is disabled and chunks will be built in states
where learning is enabled. In these situations, justifications also serve
another purpose: they provide an explanation of the results for future learning
episodes in states that do have learning on. EBC does this by retaining all of
the extra information that chunks have but justifications do not, namely those
extra tests and how things would have been variablized. This allows EBC to learn
chunks from justifications as readily as it can from hand-written rules and
other chunks.

When mixing justifications and chunks, users may want to set the explainer to
record the learning episodes behind justifications. This allows one to examine
the reasoning behind a justification just like you would a chunk, which may be
important if that justification later participates in the formation a chunk. See
the [explainer’s settings](../reference/cli/cmd_explain.md) for more information.

### Generality and Correctness of Learned Rules

Chunking is intended to produce the most general rule that is also correct.

Generality is a measure of the space of similar situations that a rule can apply
to. A more general rule can be applied to a larger space of similar situations.
A rule is considered over-general if it can apply to situations in which the
original problem-solving would have never occurred.

Correctness is a requirement that the learned rule produces the exact same
results that the original problem-solving would have produced. In other words,
if we inhibited a correct chunk so that it did not fire, the agent should
subgoal, execute the same substate reasoning that it previously performed when
learning the chunk, and produce the same results that the learned chunk
produces.

Note that an over-general rule is an incorrect rule, but not all incorrect
rules are over-general.

### Over-specialization and Over-generalization

Explanation-based chunking was pursued to address the main limitation of
traditional chunking: over-specialized rules that were very specific and could
not be applied to many other situations. Specifically, EBC’s identity-based
variablization and constraint tracking/enforcement has eliminated the core
source of this issue.

The nature of EBC’s algorithm does add two new situations in which rules may
become over-specialized. [Generalizing knowledge retrieved](#generalizing-knowledge-retrieved-from-semantic-or-episodic-memory)
discusses how variables used in certain RHS functions need to be literalized to
maintain correctness, which can cause
overspecialization. [Previous results and rule repair](#previous-results-and-rule-repair)
discusses how testing or augmenting a previous result creates non-operational
rules that require repair, a process which may sometimes over-specialize a rule.
Note that this situation can easily be avoided and, even when it does occur, may
not add much unnecessary specificity to learned rules.

While over-specialization may no longer be a common problem, it is still
possible to get over-general rules. Several of the sources of correctness issues
listed in the next section can produce over-general rules in certain situations.

### Previous Results and Rule Repair

An agent may learn a slightly over-specialized rule when EBC repairs a rule that
has unconnected conditions, which are conditions that have an identifier that
is not linked to one of the states referenced in the rule. Such rules are
illegal and cannot be added to Soar’s production memory.

Rules that require repair are caused by substate problem-solving that tests or
augments a previous result. A previous result is a working memory element that
was originally created locally in the substate but then later became a result
when a rule fired and connected it to the superstate. (At which point a chunk
must have been learned.). If another substate rules later matches or augments
such a previous result WMEusing a path relative to the local substate, then EBC
will have problems. It will know that the WME is in the superstate so conditions
that test the WME are considered operational and augmentations on that
identifier are considered results – but it won’t know where in the superstate
that working memory is located is and how it should be referenced in the learned
rule, because the problem solving referenced the result relative to the local
substate.

As described in [validating rule and repairing unconnected conditions](#validating-rule-and-repairing-unconnected-conditions),
EBC repairs the rule by adding new grounding
conditions that provide a link from a state, which is tested somewhere else in
the rule, to the unconnected condition or action. It does this by searching
through working memory to find the shortest path from a state to the identifier
behind the unconnected element. It then variablizes those conditions
appropriately.

Since the conditions are based purely on what happened to be in working memory
at that point and nothing in the explanation dictated that particular path found
during the search, the learned rule may be over-specialized. The chunk will only
match future situations where the previous result can be found on that same
path. Fortunately, new chunks can be learned to ameliorate this. If a similar
situation is encountered in the future, but with a different path to the
unconnected element, the chunk won’t fire, because the added grounding
conditions won’t match, which should cause the agent to subgoal and learn a
similar chunk with a different set of grounding conditions.

Note that if an agent designer expects that the path to the previous result
found by the search will always exist, a repaired rule should match just as
generally as an unrepaired rule.

But if this is not the case, an agent designer can avoid this situation by
modifying the rules that test or augment the substructure of a previous result.
If those rules are modified so that they match the previous results by
referencing them relative to the superstate than the the local substate, EBC
will be able create a valid rule without any repair.

To detect when this is happening, use the ['chunk' stats command](../reference/cli/cmd_chunk.md).
It will tell you if any of an agent’s learned rules that required repair. If
you instruct the explainer to record the chunk, you can also see whether a
specific chunk was repaired by looking at the chunk’s individual stats

### Missing Operator Selection Knowledge

If an agent uses rules that create operator preferences to choose amongst
multiple operators in the substate, it is possible that the reasoning behind
those rules needs to be incorporated in any rule learned. This topic is
discussed in greater detail in [ROSK tracking](#relevant-operator-selection-knowledge-tracking).

EBC will incorporate relevant operator selection knowledge if you enable the
[chunk setting add-osk](../reference/cli/cmd_chunk.md), which is off by default.

### Generalizing Over Operators Selected Probabilistically

If the problem-solving in a substate involves operators that were selected
probabilistically, chunking will not be able to summarize the agent’s reasoning
into a correct rule. For a rule to be correct, it must always produce the same
result that the substate would have produced if the learned rule was not in
production memory. Since a different operator could have been selected which
could have resulted in different problem-solving, the substate could easily
produce different results than any chunk learned in that substate.

Future versions of chunking will provide an option to prevent rules from forming
when a probabilistically-selected operator was chosen during problem-solving.
Until then, agent engineers can disable learning in states that involve such
reasoning.

### Collapsed Negative Reasoning

Over-general chunks can be created when conditions in the explanation trace test
for the absence of a working memory elements in the substate. Since there is no
clear way for chunking to generate a set of conditions that describe when a
given working memory element would not exist in a substate, chunking can’t
represent that aspect of the problem-solving.

Chunking can include negated tests if they test for the absence of working
memory elements in the superstate, though. So, the agent engineer can avoid
using negated conditions for local substate data by either (1) designing the
problem-solving so that the data that is being tested in the negation is already
in the superstate or (2) making the data a result by attaching it to the
superstate. This increases the number of chunks learned, but a negated condition
of knowledge in the superstate can be incorporated correctly into learned rules.

Note that there are agent design patterns where local negations are perfectly
safe to ignore, so Soar allows local negations by default. In some agents, they
are common enough that turning the filter on prevents any rules from being
learned.

If you suspect that a rule may be over-general because of locally negated
condition, you can verify whether such a condition was encountered during
backtracing by using the chunk stats command and explain stats command. See
[Debugging Explanation-Based Chunking](../reference/cli/cmd_chunk.md#debugging-explanation-based-chunking)
and [explain stats](../reference/cli/cmd_explain.md#explain-stats) for more information.

If such chunks are problematic, turning off chunking’s correctness filter
allow-local-negations will force Soar to reject chunks whose problem-solving
involved a local negation.

### Problem-Solving That Doesn’t Test The Superstate

Over-general chunks can be created if a result of a subgoal is dependent on the
creation of an impasse within the substate. For example, processing in a subgoal
may consist of exhaustively applying all the operators in the problem space. If
so, then a convenient way to recognize that all operators have applied and
processing is complete is to wait for a state no-change impasse to occur. When
the impasse occurs, a production can test for the resulting substate and create
a result for the original subgoal. This form of state test builds over-general
chunks because no pre-existing structure is relevant to the result that
terminates the subgoal. The result is dependent only on the existence of the
substate within a substate.

In these cases, EBC will learn a chunk with no conditions, which it will reject.
But the superstate result is still created by the substate rule that matched. If
a new rule is learned that uses that result, it will be over-general since the
rule does not summarize the reasoning that led to the result, namely that all
operators were exhaustively applied.

The current solution to this problem is a bit of a hack. Soar allows an agent to
signal to the architecture that a test for a substate is being made by testing
for the^quiescence t augmentation of the subgoal. If this special test is found
in the explanation trace, EBC will not build a chunk. The history of this test
is maintained, so that if the result of the substate is then used to produce
further results for a superstate, no higher chunks will be built.

### Disjunctive Context Conflation

An incorrect rule can be learned when multiple rules fire in a substate that
test different structures in the superstate but create the same WME in the
substate. For example, there may be a rule that can match the superstate in
several different ways, each time elaborating the local state with a WME
indicating that at least one of these qualifying superstate WMEs existed. In
such a situation, the rule would fire multiple times, but the result of the rule
firings will be collapsed into creating a single WME in the substate.

If this WME is then tested to create a result on the superstate, the chunk that
is subsequently created can produce different behavior than the substate would
have. In the original subgoal processing, multiple matches produced one substate
WME, but that one substate WME only created a single result in the superstate.
The chunk on the other hand will match multiple times for each of the items that
previously created the substate WME. And then, each one of those matches will
create its own distinct result in the superstate. Since this is different
behavior than the original substate, this rule would be considered incorrect.

If it were possible, EBC should learn a disjunctive conjunctive condition, with
each disjunction being the superstate conditions tested by each substate rule
that had previously created the substate WME that was repeatedly asserted. This
is why this potential source of incorrect rules is called disjunctive context
conflation.

If this type of reasoning is needed, agents can move the conflating WME to the
superstate. The rule learned would then produce only one result regardless of
the number of rules that repeatedly created that WME.

### Generalizing knowledge retrieved from semantic or episodic memory

Generalizing problem-solving based on knowledge recalled from an external memory
system can be problematic for three main reasons.

1.  **Knowledge can change after the learning episode**
    Semantic knowledge can be modified by the agent. Different semantic
    knowledge can effect different problem-solving, in which case a rule based on
    the original problem-solving would be incorrect.
2.  **Justification for a memory recall is opaque to agent**
    EBC does not have access
    to the reasoning behind why a piece of knowledge was recalled from a memory
    system. For example, consider the case of a semantic memory that is recalled
    because it has the highest level of activation at a particular time. In a future
    situation, the same semantic memory may not be the most active, in which case
    something else would be recalled and different problem-solving could occur.
    Because of that possibility, the original rule is not guaranteed to produce the
    same result and hence has the potential to be incorrect. (Note that this can
    also occur with episodic memory queries.)
3.  **Knowledge from semantic or episodic memory recalled directly into the
    substate is considered local**
    To understand why this is a problem, remember that a chunk’s conditions are
    based on the conditions in the explanation trace that tested knowledge linked
    to a superstate. (See [operational analysis](#operationality-analysis)
    for more information.) If semantic or
    episodic memory is recalled directly into the substate, then any conditions
    that test that recalled knowledge is considered local to the substate and
    will not be included as a condition in the chunk. So, even though the
    substate reasoning required some piece of semantic knowledge to exist, the
    chunk will not require it. And, since the learned rule is not incorporating
    some of the reasoning and constraints that involved the recalled knowledge,
    the rule may be over-general. To avoid this situation, an agent can retrieve
    the knowledge in a higher-level state rather than the substate in which the
    rule is learned.

### Learning from Instruction

Note that some agent designs, for example an agent that learns by instruction,
can take advantage of the fact that knowledge recalled from semantic or episodic
memory directly into the substate is considered local. For such agents, a rule
that is directly dependent on the instructions being in working memory would be
useless. The agent would need to get the instruction every time it wanted to
perform the task again, defeating the purpose of learning by instruction.

One technique that can be used to produce a more general rule which is not
directly dependent on the instruction being in working memory is to first
store the instructions in semantic or episodic memory. When the agent is in a
substate that it wants to learn a rule based on the instructions, it recalls the
instructions from semantic or episodic memory directly into the substate.
Because that knowledge is not linked to the superstate, any rules learned in
that substate will not be directly dependent on the existence of the
instructions.

Since conditions that test the recalled knowledge are not incorporated into the
learned rule, it is very easy to learn over-general chunks. To avoid this, any
substate rules which test recalled knowledge must also test superstate
structures that correspond to the recalled knowledge. Doing so removes the need
for the instructions to exist while avoiding over-generality by ensuring that
structures in the superstate corresponding to those instructions are still being
tested. Those conditions that test superstate WMEs will be generalized and
included in the chunk, but the undesired portion of the reason that they matched
will not be, namely the fact that the superstate knowledge corresponded to
recalled instructions.

### Determining Which OSK Preferences are Relevant

The following outline describes the logic that happens at each step. For a more
detailed description of the [various filters](02_TheSoarArchitecture.md#how-preferences-are-evaluated-to-decide-an-operator)
(but not the ROSK).  Note that depending on the set of preferences being
processed, impasses may occur at some of these stages, in which case, no
operator is selected and the ROSK is emptied. Moreover, if the candidate set is
reduced to zero or one, the decision process will exit with a finalized ROSK.
For simplicity’s sake, this explanation assumes that there are no impasses and
the decision process continues.

-   **Require Filter** If an operator is selected based on a require preference,
    that preference is added to the ROSK. The logic behind this step is
    straightforward, the require preference directly resulted in the selection of
    the operator.

-   **Prohibit/Reject Filters** If there exists at least one prohibit or reject
    preference, all prohibit and reject preferences for the eliminated candidates
    are added to the ROSK. The logic behind this stage is that the conditions that
    led to the exclusion of the prohibited and rejected candidates is what allowed
    the final operator to be selected from among that particular set of surviving
    candidates.

-   **Better/Worse Filter** For every candidate that is not worse than some
    other candidate, add all better/worse preferences involving the candidate.

-   **Best Filter** Add any best preferences for remaining candidates to the ROSK.

-   **Worst Filter** If any remaining candidate has a worst preference which
    leads to that candidate being removed from consideration, that worst preference
    is added to the ROSK. Again, the logic is that the conditions that led to that
    candidate not being selected allowed the final operator to be chosen.

-   **Indifferent Filter** This is the final stage, so the operator is now selected
    based on the agent’s exploration policy. How indifferent preferences are added
    to the ROSK depends on whether any numeric indifferent preferences exist.

    1.  If there exists at least one numeric indifferent preference, then every
        numeric preference for the winning candidate is added to the ROSK. There
        can be multiple such preferences. Moreover, all binary indifferent
        preferences between that winning candidate and candidates without a
        numeric preference are added.
    2.  If all indifferent preferences are non-numeric, then any unary indifferent
        preferences for the winning candidate are added to the ROSK. Moreover, all
        binary indifferent preferences between that winning candidate and other
        candidates are added.

    The logic behind adding binary indifferent preferences between the selected
    operator and the other final candidates is that those binary indifferent
    preferences prevented a tie impasse and allowed the final candidate to be chosen
    by the exploration policy from among those mutually indifferent preferences.

Note that there may be cases where two or more rules create the same type of
preference for a particular candidate. In those cases, only the first preference
encountered is added to the ROSK. Adding all of them can produce over-specific
chunks. It may still be possible to learn similar chunks with those other
preferences if the agent subgoals again in a similar context.

Note also that operator selection knowledge is not tracked and incorporated into
chunks by default. The setting must be turned on via the
[chunk command’s add-osk setting.](../reference/cli/cmd_chunk.md#chunk-add-osk).

The ROSK also affects the conditions of justifications, so the
`add-desirability-prefs` setting does have an effect on the agent even if
learning is turned off.

### Generalizing Knowledge From Math

and Other Right-Hand Side Functions

Explanation-based chunking introduces the ability to learn more expressive rules
whose actions perform arbitrary right-hand side functions with variablized
arguments.

It is important to note that this ability is limited. EBC can only learn rules
with generalized RHS functions in its actions when the rule that created the
result contained a RHS function. In many cases, RHS functions will be used in
the intermediate rule firings in the explanation trace. Not only will these
intermediate RHS function not appear in the chunk, but any chunk learned based
on their output will become more specific. This is one of the sources of
over-specialization referenced in [over-specialization and over-generalization](#over-specialization-and-over-generalization)
on over-specialization.

RHS function calls in intermediate rule firings are a challenge for EBC to deal
with because the problem-solving may have placed constraints on the intermediate
results that cannot be represented in a single Soar rule.

For example, consider the case of one rule that used a RHS function to add two
numbers. Now consider another rule that matched the output of the RHS function,
but only if it was less than 5. If the second rule matched, it would return the
total as a result. How could we encode the reasoning of those two rules into one
rule? Since Soar’s production syntax does not allow using RHS function as
constraints in conditions, there is no way to insure that the two numbers add up
to something less than 5 in a single rule. This is why RHS functions in
intermediate rule firings can cause over-specialization.

Because the chunk’s conditions can’t represent constraints on the output of
intermediate RHS functions, EBC must literalize both the identities of the
variables that appear as arguments to the intermediate RHS function, as well as
the identities in any conditions that test the output of the RHS function. That
fixes the value of the RHS function and guarantees that any constraints in
conditions that test the output of that RHS function will be met. While this
will make the learned rule more specific, it will also ensure that the rule is
correct.

### Situations in which a Chunk is Not Learned

Soar learns a chunk every time a subgoal produces a result, unless one of the following
conditions is true:

1.  Chunking is off
    This corresponds to the [command chunk never](../reference/cli/cmd_chunk.md).
2.  Chunking was only enabled for some states, and the subgoal in question is not
    one of them When chunking is enabled via the only or except command, the agent
    must specify which states learning either occurs in or doesn’t occur in,
    respectively. For the except setting, Soar will learn rules in all states in
    which a `dont-learn` RHS production action was not executed. Similarly, for the
    only setting, Soar will learn rules in all states where a `force-learn` RHS
    production action was executed, cf. [Controlling chunking](03_SyntaxOfSoarPrograms.md#controlling-chunking)
    for more information. This capability is provided for debugging and
    practical system development, but it is not part of the theory of Soar.
3.  The chunk learned is a duplicate of another production or chunk already in
    production memory In some rare cases, a duplicate production will not be
    detected because the order of the conditions or actions is not the same as an
    existing production.
4.  The problem-solving in the substate violated one of the enabled correctness
    guarantee filters During the development of explanation-based chunking, we have
    developed a list of possible causes of incorrect chunks. EBC’s correctness
    guarantee filters detect when those situations occur and prevents a chunk from
    being learned. For example, the allow-local-negations filter will prevent a rule
    from being formed if the problem-solving that led to the result was
    dependent on a condition that tested whether a subgoal WME doesn’t exist.
    Since there is no practical way to determine why a piece of knowledge
    doesn’t exist, testing a local negation can result in an over-general and
    incorrect chunk, cf. [prohibiting known sources for correctness issues](../reference/cli/cmd_chunk.md#preventing-possible-correctness-issues)
    for more information. Note that correctness filters have not yet been
    implemented for all the identified potential sources of correctness issues.
5.  The chunking option bottom-only is on and a chunk was already built in the
    bottom subgoal that generated the results With bottom-only chunking, chunks are
    learned only in states in which no subgoal has yet generated a chunk. In this
    mode, chunks are learned only for the "bottom" of the subgoal hierarchy and not
    the intermediate levels. With experience, the subgoals at the bottom will be
    replaced by the chunks, allowing higher level subgoals to be chunked. See
    [chunk reference](../reference/cli/cmd_chunk.md) for details of chunk used
    with the bottom-only setting.
6.  The problem-solving that led to the result contained a condition that tested
    the architecturally-created `<state> ^quiescence t` augmentation This mechanism
    is motivated by the chunking from exhaustion problem, where the results of a
    subgoal are dependent on the exhaustion of alternatives
    (see [Problem-Solving that does not test the superstate](04_ProceduralKnowledgeLearning.md#problem-solving-that-doesnt-test-the-superstate)).
    If this substate augmentation is encountered when determining the
    conditions of a chunk, then no chunk will be built for the currently considered
    action. This is recursive, so that if an un-chunked result is relevant to a
    second result, no chunk will be built for the second result. This does not
    prevent the creation of a chunk that would include^quiescence tas a condition.
7.  The problem-solving in the substate did not test any knowledge in the
    superstate In these cases, the chunk learned does not have any conditions
    and is not a legal production. Note that this creates an unusual persistence
    issue for any results that came out of the substate. Since a justification
    or chunk was not learned, there is no rule in the superstate that can
    provide either i-support or o-support for the result that came out of the
    substate. Consequently, those result WMEs will be completely dependent on
    the rules that fired within the substate. So, when the substate is removed,
    those results will also be removed.
