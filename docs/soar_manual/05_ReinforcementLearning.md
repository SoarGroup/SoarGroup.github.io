# Reinforcement Learning

Soar has a reinforcement learning (RL) mechanism that tunes operator selection
knowledge based on a given reward function. This chapter describes the RL
mechanism and how it is integrated with production memory, the decision cycle,
and the state stack. We assume that the reader is familiar with basic
reinforcement learning concepts and notation. If not, we recommend first
reading *Reinforcement Learning: An Introduction* (1998) by Richard S. Sutton and
Andrew G. Barto. The detailed behavior of the RL mechanism is determined by
numerous parameters that can be controlled and configured via the `rl` command.
Please refer to the documentation for that command in section 9.4.2 on page 238.

## RL Rules

Soar’s RL mechanism learns Q-values for state-operator<sup>[1](#footnote1)</sup>
pairs. Q-values are stored as numeric-indifferent preferences created by
specially formulated productions called **RL rules**.  RL rules are identified
by syntax. A production is a RL rule if and only if its left hand side tests for
a proposed operator, its right hand side creates a single numeric-indifferent
preference, and it is not a template rule (see Section 5.4.2 for template
rules). These constraints ease the technical requirements of identifying/
updating RL rules and makes it easy for the agent programmer to add/ maintain RL
capabilities within an agent. We define an
**RL operator** as an operator with numeric-indifferent preferences created by
RL rules.

The following is an RL rule:

```Soar
sp {rl*3*12*left
  (state <s> ^name task-name
    ^x 3
    ^y 12
    ^operator <o> +)
  (<o> ^name move
    ^direction left)
-->
(<s> ^operator <o> = 1.5)
}
```



Note that the LHS of the rule can test for anything as long as it contains a
test for a proposed operator. The RHS is constrained to exactly one action:
creating a numeric-indifferent preference for the proposed operator.

The following are not RL rules:

```Soar
sp {multiple*preferences
(state <s> ^operator <o> +)
-->
(<s> ^operator <o> = 5, >)
}

sp {variable*binding
(state <s> ^operator <o> +
^value <v>)
-->
(<s> ^operator <o> = <v>)
}

sp {invalid*actions
(state <s> ^operator <o> +)
-->
(<s> ^operator <o> = 5)
(write (crlf) |This is not an RL rule.|)
}
```

The first rule proposes multiple preferences for the proposed operator and thus
does not comply with the rule format. The second rule does not comply because it
does not provide a constant for the numeric-indifferent preference value. The
third rule does not comply because it includes a RHS function action in addition
to the numeric-indifferent preference action.

In the typical RL use case, the user intends for the agent to learn the best
operator in each possible state of the environment. The most straightforward way
to achieve this is to give the agent a set of RL rules, each matching exactly
one possible state-operator pair.  This approach is equivalent to a table-based
RL algorithm, where the Q-value of each state- operator pair corresponds to the
numeric-indifferent preference created by exactly one RL rule.

In the more general case, multiple RL rules can match a single state-operator
pair, and a single RL rule can match multiple state-operator pairs. That is, in
Soar, a state-operator pair corresponds to an operator in a specific working
memory context, and multiple rules can modify the preferences for a single
operator, and a single rule can be instantiated multiple ways to modify
preferences for multiple operators. For RL in Soar, all numeric-indifferent
preferences for an operator are summed when calculating the operator’s
Q-value<sup>[2](#footnote2)</sup>. In this context, RL rules can be interpreted more generally as binary
features in a linear approximator of each state-operator pair’s Q-value, and
their numeric-indifferent preference values their weights. In other words,

$$Q(s, a) = w_1 \phi_2 (s, a) + w_2 \phi_2 (s, a) + \ldots + w_n \phi_n (s, a)$$

where all RL rules in production memory are numbered $1 \dots n$, $Q(s, a)$ is
the Q-value of the state-operator pair $(s, a)$, $w_i$ is the
numeric-indifferent preference value of RL rule $i$, $\phi_i (s, a) = 0$ if RL
rule $i$ does not match $(s, a)$, and $\phi_i (s, a) = 1$ if it does.  This
interpretation allows RL rules to simulate a number of popular function
approximation schemes used in RL such as tile coding and sparse coding.


## Reward Representation

RL updates are driven by reward signals. In Soar, these reward signals are given
to the RL mechanism through a working memory link called the **reward-link**.
Each state in Soar’s state stack is automatically populated with
a reward-link structure upon creation. Soar will check each structure for a
numeric reward signal for the last operator executed in the associated state at
the beginning of every decision phase. Reward is also collected when the agent
is halted or a state is retracted.

In order to be recognized, the reward signal must follow this pattern:

```Soar
(<r1> ^reward <r2>)
(<r2> ^value [val])
```

where `<r1>` is the reward-link identifier, `<r2>` is some intermediate
identifier, and `[val]` is any constant numeric value. Any structure that does not
match this pattern is ignored. If there are multiple valid reward signals, their
values are summed into a single reward signal.  As an example, consider the
following state:

```Soar
(S1 ^reward-link R1)
(R1 ^reward R2)
(R2 ^value 1.0)
(R1 ^reward R3)
(R3 ^value -0.2)
```

In this state, there are two reward signals with values 1.0 and -0.2. They will
be summed together for a total reward of 0.8 and this will be the value given to
the RL update algorithm.


There are two reasons for requiring the intermediate identifier. The first is so
that multiple reward signals with the same value can exist simultaneously. Since
working memory is a set, multiple WMEs with identical values in all three
positions (identifier, attribute, value) cannot exist simultaneously. Without an
intermediate identifier, specifying two rewards with the same value would
require a WME structure such as


```Soar
(S1 ^reward-link R1)
(R1 ^reward 1.0)
(R1 ^reward 1.0)
```

which is invalid. With the intermediate identifier, the rewards would be specified as

```Soar
(S1 ^reward-link R1)
(R1 ^reward R2)
(R2 ^value 1.0)
(R1 ^reward R3)
(R3 ^value 1.0)
```

which is valid. The second reason for requiring an intermediate identifier in
the reward signal is so that the rewards can be augmented with additional
information, such as their source or how long they have existed. Although this
information will be ignored by the RL mechanism, it can be useful to the agent
or programmer. For example:

```Soar
(S1 ^reward-link R1)
(R1 ^reward R2)
(R2 ^value 1.0)
(R2 ^source environment)
(R1 ^reward R3)
(R3 ^value -0.2)
(R3 ^source intrinsic)
(R3 ^duration 5)
```

The `(R2 ^source environment)`,`(R3 ^source intrinsic)`, and `(R3 ^duration 5)`
WMEs are arbitrary and ignored by RL, but were added by the agent to keep track
of where the rewards came from and for how long.

Note that the reward-link is not part of the io structure and is not modified
directly by the environment. Reward information from the environment should be
copied, via rules, from the input-link to the reward-link. Also note that when
collecting rewards, Soar simply scans the reward-link and sums the values of all
valid reward WMEs. The WMEs are not modified and no bookkeeping is done to keep
track of previously seen WMEs. This means that reward WMEs that exist for
multiple decision cycles will be collected multiple times if not removed or
retracted.

## Updating RL Rule Values

Soar’s RL mechanism is integrated naturally with the decision cycle and performs
online updates of RL rules. Whenever an RL operator is selected, the values of
the corresponding RL rules will be updated. The update can be on-policy (Sarsa)
or off-policy (Q-Learning), as controlled by the **learning-policy** parameter
of the rl command. (See page 238.) Let $\delta_t$ be the amount of change for the
Q-value of an RL operator in a single update. For Sarsa, we have

$$ \delta_t = \alpha \left[ r_{t+1} + \gamma Q(s_{t+1}, a_{t+1}) - Q(s_t, a_t)
\right] $$

where

- $Q(s_t, a_t)$ is the Q-value of the state and chosen operator in decision cycle $t$.
- $Q(s_{t+1}, a_{t+1})$ is the Q-value of the state and chosen RL operator in the next decision cycle.
- $r_{t+1}$ is the total reward collected in the next decision cycle.
- $\alpha$ and $\gamma$ are the settings of the learning-rate and discount-rate parameters of the `rl` command, respectively.

Note that since $\delta_t$ depends on $Q(s_{t+1}, a_{t+1})$, the update for the
operator selected in decision cycle $t$ is not applied until the next RL
operator is chosen.  For Q-Learning, we have
$$ \delta_t = \alpha \left[ r_{t+1} + \gamma \underset{a \in A_{t+1}}{\max} Q(s_{t+1}, a) - Q(s_t, a_t) \right] $$
where $A_{t+1}$ is the set of RL operators proposed in the next decision cycle.

Finally, $\delta_t$ is divided by the number of RL rules comprising the Q-value
for the operator and the numeric-indifferent values for each RL rule is updated
by that amount.

An example walkthrough of a Sarsa update with $\alpha = 0.3$ and $\gamma = 0.9$
(the default settings in Soar) follows.


1. In decision cycle $t$, an operator `O1` is proposed, and RL rules **rl-1**
  and **rl-2** create the following numeric-indifferent preferences for it:
  ```
  rl-1: (S1 ^operator O1 = 2.3)
  rl-2: (S1 ^operator O1 = -1)
  ```
  The Q-value for `O1` is $Q(s_t, \textbf{O1}) = 2.3 - 1 = 1.3$.

2. `O1` is selected and executed, so  $Q(s_t, a_t) = Q(s_t, \textbf{O1}) = 1.3$.

3. In decision cycle $t+1$, a total reward of 1.0 is collected on the
  reward-link, an operator O2is proposed, and another RL rule **rl-3** creates the
  following numeric-indifferent preference for it:
  ```
  rl-3: (S1 ^operator O2 = 0.5)
  ```

  So $Q(s_{t+1}, \textbf{O2}) = 0.5$.

4. `O2` is selected, so  $Q(s_{t+1}, a_{t+1}) = Q(s_{t+1}, \textbf{O2}) = 0.5$ Therefore,

$$\delta_t = \alpha \left[r_{t+1} + \gamma Q(s_{t+1}, a_{t+1}) - Q(s_t, a_t) \right] = 0.3 \times [ 1.0 + 0.9 \times 0.5 - 1.3 ] = 0.045$$

Since rl-1 and rl-2 both contributed to the Q-value of O1, $\delta_t$ is evenly divided
amongst them, resulting in updated values of

```
rl-1: (<s> ^operator <o> = 2.3225)
rl-2: (<s> ^operator <o> = -0.9775)
```

5. **rl-3** will be updated when the next RL operator is selected.

### Gaps in Rule Coverage

The previous description had assumed that RL operators were selected in both decision
cyclestandt+ 1. If the operator selected int+ 1 is not an RL operator, thenQ(st+1,at+1)
would not be defined, and an update for the RL operator selected at timetwill be undefined.
We will call a sequence of one or more decision cycles in which RL operators are not selected
between two decision cycles in which RL operators are selected agap. Conceptually, it is
desirable to use the temporal difference information from the RL operator after the gap to
update the Q-value of the RL operator before the gap. There are no intermediate storage
locations for these updates. Requiring that RL rules support operators at every decision
can be difficult for agent programmers, particularly for operators that do not represent steps
in a task, but instead perform generic maintenance functions, such as cleaning processed
output-link structures.

To address this issue, Soar's RL mechanism supports automatic propagation of updates over gaps.
For a gap of length $n$, the Sarsa update is
$$\delta_t = \alpha \left[ \sum_{i=t}^{t+n}{\gamma^{i-t} r_i} + \gamma^{n+1} Q(s_{t+n+1}, a_{t+n+1}) - Q(s_t, a_t) \right]$$
and the Q-Learning update is
$$\delta_t = \alpha \left[ \sum_{i=t}^{t+n}{\gamma^{i-t} r_i} + \gamma^{n+1} \underset{a \in A_{t+n+1}}{\max} Q(s_{t+n+1}, a) - Q(s_t, a_t) \right]$$

Note that rewards will still be collected during the gap, but they are discounted based on the number of decisions they are removed from the initial RL operator.

Gap propagation can be disabled by setting the **temporal-extension** parameter of the
rl command to off. When gap propagation is disabled, the RL rules preceding a gap are
updated usingQ(st+1,at+1) = 0. The rl setting of the watch command (see Section 9.6.1
on page 259) is useful in identifying gaps.

![Example Soar substate operator trace.](Images/rl-optrace.svg)

### RL and Substates

When an agent has multiple states in its state stack, the RL mechanism will treat each
substate independently. As mentioned previously, each state has its own reward-link.
When an RL operator is selected in a stateS, the RL updates for that operator are only
affected by the rewards collected on the reward-link for Sand the Q-values of subsequent
RL operators selected inS.

The only exception to this independence is when a selected RL operator forces an
operator- no-change impasse. When this occurs, the number of decision cycles the
RL operator at the superstate remains selected is dependent upon the processing
in the impasse state. Consider the operator trace in Figure 5.1.

At decision cycle 1, RL operatorO1is selected inS1and causes an
operator-no-change impass for three decision cycles.  In the substateS2,
operatorsO2,O3, andO4are selected and applied sequentially.  Meanwhile inS1,
rewardsr 2 ,r 3 , andr 4 are put on thereward-linksequentially.  Finally, the
impasse is resolved by O4, the proposal for O1 is retracted, and RL operatorO5is
selected inS1.

In this scenario, only the RL update forQ(s 1 ,O1) will be different from the
ordinary case.  Its value depends on the setting of the **hrl-discount**
parameter of the rlcommand.  When this parameter is set to the default valueon,
the rewards onS1and the Q-value of O5are discounted by the number of decision
cycles they are removed from the selection of O1. In this case the update for  $Q(s_1, \textbf{O1})$ is

$$\delta_1 = \alpha \left[ r_2 + \gamma r_3 + \gamma^2 r_4 + \gamma^3 Q(s_5, \textbf{O5}) - Q(s_1, \textbf{O1}) \right]$$

which is equivalent to having a three decision gap separating `O1` and `O5`.

When hrl-discount is set to off, the number of cycles O1has been impassed will be
ignored. Thus the update would be

$$\delta_1 = \alpha \left[ r_2 + r_3 + r_4 + \gamma Q(s_5, \textbf{O5}) - Q(s_1, \textbf{O1}) \right]$$

For impasses other than operator no-change, RL acts as if the impasse hadn’t
occurred. If O1is the last RL operator selected before the impasse,r 2 the
reward received in the decision cycle immediately following, and On, the first
operator selected after the impasse, thenO1 is updated with 

$$\delta_1 = \alpha \left[ r_2 + \gamma Q(s_n, \textbf{O}_\textbf{n}) - Q(s_1, \textbf{O1}) \right]$$

If an RL operator is selected in a substate immediately prior to the state’s
retraction, the RL rules will be updated based only on the reward signals
present and not on the Q-values of future operators. This point is not covered
in traditional RL theory. The retraction of a substate corresponds to a
suspension of the RL task in that state rather than its termination, so the last
update assumes the lack of information about future rewards rather than the
discontinuation of future rewards. To handle this case, the numeric-indifferent
preference value of each RL rule is stored as two separate values, the expected
current reward(ECR) and expected future reward (EFR). The ECR is an estimate of
the expected immediate reward signal for executing the corresponding RL
operator. The EFR is an estimate of the time discounted Q-value of the next RL
operator. Normal updates correspond to traditional RL theory (showing the Sarsa
case for simplicity):

$$ \delta_{ECR} = \alpha \left[ r_t - ECR(s_t, a_t) \right] $$

$$ \delta_{EFR} = \alpha \left[ \gamma Q(s_{t+1}, a_{t+1}) - EFR(s_t, a_t) \right] $$ 

$$ \delta_t = \delta_{ECR} + \delta_{EFR} $$

$$ = \alpha \left[ r_t + \gamma Q(s_{t+1}, a_{t+1}) - \left( ECR(s_t, a_t) + EFR(s_t, a_t) \right) \right] $$

$$ = \alpha \left[ r_t + \gamma Q(s_{t+1}, a_{t+1}) - Q(s_t, a_t) \right] $$

During substate retraction, only the ECR is updated based on the reward signals
present at the time of retraction, and the EFR is unchanged.

Soar’s automatic subgoaling and RL mechanisms can be combined to naturally implement
hierarchical reinforcement learning algorithms such as MAXQ and options.

### Eligibility Traces

The RL mechanism supports eligibility traces, which can improve the speed of
learning by updating RL rules across multiple sequential steps. The
**eligibility-trace-decay-rate** and **eligibility-trace-tolerance** parameters
*control this mechanism. By setting eligibility-trace-decay-rate to 0
(de- fault), eligibility traces are in effect disabled. When eligibility traces
are enabled, the particular algorithm used is dependent upon the learning
policy. For Sarsa, the eligibility trace implementation isSarsa($\lambda$). For
Q-Learning, the eligibility trace implementation is *Watkin's Q($\lambda$)*.

####  Exploration

The decide indifferent-selection command (page 198) determines how operators are
selected based on their numeric-indifferent preferences. Although all the
indifferent selection settings are valid regardless of how the
numeric-indifferent preferences were arrived at, the epsilon-greedy and
boltzmann settings are specifically designed for use with RL and cor- respond to
the two most common exploration strategies. In an effort to maintain backwards
compatibility, the default exploration policy is soft max. As a result, one
should change to epsilon-greedy or boltzmann when the reinforcement learning
mechanism is enabled.

### GQ($\lambda$)

Sarsa($\lambda$) and Watkin’s Q($\lambda$) help agents to solve the temporal
credit assignment problem more quickly. However, if you wish to implement
something akin to CMACs to generalize from experience, convergence is not
guaranteed by these algorithms. GQ($\lambda$) is a gradient descent algorithm
designed to ensure convergence when learning off-policy. Soar’s learning-policy
can be set to
**on-policy-gq-lambda** or **off-policy-gq-lambda** to increase the likelihood
of convergence when learning under these conditions. If you should choose to use
one of these algorithms, we recommend setting the rl **step-size-parameter** to
something small, such as 0.01 in order to ensure that the secondary set of
weights used by GQ($\lambda$)change slowly enough for efficient convergence.

## Automatic Generation of RL Rules

The number of RL rules required for an agent to accurately approximate operator
Q-values is usually unfeasibly large to write by hand, even for small domains.
Therefore, several methods exist to automate this.

### The gp Command

The gp command can be used to generate productions based on simple patterns.
This is useful if the states and operators of the environment can be
distinguished by a fixed number of dimensions with finite domains. An example is
a grid world where the states are described by integer row/column coordinates,
and the available operators are to move north, south, east, or west. In this
case, a single gp command will generate all necessary RL rules:

```Soar
gp {gen*rl*rules
(state <s> ^name gridworld
^operator <o> +
^row [ 1 2 3 4 ]
^col [ 1 2 3 4 ])
(<o> ^name move
^direction [ north south east west ])
-->
(<s> ^operator <o> = 0.0)
}
```

For more information see the documentation for this command on page 205.

### Rule Templates

Rule templates allow Soar to dynamically generate new RL rules based on a
predefined pattern as the agent encounters novel states. This is useful when
either the domains of environment dimensions are not known ahead of time, or
when the enumerable state space of the environment is too large to capture in
its entirety using gp, but the agent will only encounter a small fraction of
that space during its execution. For example, consider the grid world example
with 1000 rows and columns. Attempting to generate RL rules for each grid cell
and action a priori will result in $1000 \times 1000 \times 4 = 4 \times 10^6$
productions. However, if most of those cells are unreachable due to walls, then
the agent will never fire or update most of those productions. Templates give
the programmer the convenience of the gp command without filling production
memory with unnecessary rules.

Rule templates have variables that are filled in to generate RL rules as the
agent encounters novel combinations of variable values. A rule template is valid
if and only if it is marked with the **:template** flag and, in all other
respects, adheres to the format of an RL rule.  However, whereas an RL rule may
only use constants as the numeric-indifference preference value, a rule template
may use a variable. Consider the following rule template:

```Soar
sp {sample*rule*template
:template
(state <s> ^operator <o> +
^value <v>)
-->
(<s> ^operator <o> = <v>)
}
```

During agent execution, this rule template will match working memory and create new
productions by substituting all variables in the rule template that matched against constant
values with the values themselves. Suppose that the LHS of the rule template matched
against the state

```Soar
(S1 ^value 3.2)
(S1 ^operator O1 +)
```

Then the following production will be added to production memory:

```Soar
sp {rl*sample*rule*template*1
(state <s> ^operator <o> +
^value 3.2)
-->
(<s> ^operator <o> = 3.2)
}
```

The variable `<v>` is replaced by3.2on both the LHS and the RHS, but `<s>` and
`<o>` are not replaced because they matches against identifiers (S1andO1). As
with other RL rules, the value of3.2on the RHS of this rule may be updated later
by reinforcement learning, whereas the value of 3.2 on the LHS will remain
unchanged.  If `<v>` had matched against a non-numeric constant, it will be
replaced by that constant on the LHS, but the RHS numeric-indifference
preference value will be set to zero to make the new rule valid.

The new production’s name adheres to the following pattern:rl*template-name*id,
where template-name is the name of the originating rule template and id is
monotonically increasing integer that guarantees the uniqueness of the name.

If an identical production already exists in production memory, then the newly
generated production is discarded. It should be noted that the current process
of identifying unique template match instances can become quite expensive in
long agent runs. Therefore, it is recommended to generate all necessary RL rules
using the gp command or via custom scripting when possible.

### Chunking

Since RL rules are regular productions, they can be learned by chunking just
like any other production. This method is more general than using the gp command
or rule templates, and is useful if the environment state consists of
arbitrarily complex relational structures that cannot be enumerated.

## Footnotes

- <a name="footnote1">[1]</a>: In this context, the term "state" refers to the
state of the task or environment, not a state identifier.  For the rest of this
chapter, bold capital letter names such as S1 will refer to identifiers and italic
lowercase names such as $s_1$ will refer to task states.
- <a name="footnote2">[2]</a>: This is assuming the value of
**numeric-indifferent-mode** is set to
**sum**. In general, the RL mechanism only works correctly when this is the
case, and we assume this case in the rest of the chapter. See page 198 for more
information about this parameter.