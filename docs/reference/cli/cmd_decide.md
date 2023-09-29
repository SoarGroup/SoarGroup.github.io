## decide

Commands and settings related to the selection of operators during the Soar decision process

#### Synopsis
```
=============================================================================
-                      Decide Sub-Commands and Options                      -
=============================================================================
decide                          [? | help]
-----------------------------------------------------------------------------
decide numeric-indifferent-mode [--avg --sum]
-----------------------------------------------------------------------------
decide indifferent-selection
decide indifferent-selection   <policy>
                               <policy> = [--boltzmann | --epsilon-greedy |
                                           --first | --last | -- softmax ]
decide indifferent-selection   <param> [value]
                               <param> = [--epsilon --temperature]
decide indifferent-selection   [--reduction-policy| -p] <param> [<policy>]
decide indifferent-selection   [--reduction-rate| -r] <param> <policy> [<rate>]
decide indifferent-selection   [--auto-reduce] [setting]
decide indifferent-selection   [--stats]
----------------------------------------------------------------------------
decide predict
decide select                  <operator ID>
-----------------------------------------------------------------------------
decide set-random-seed         [<seed>] 
-----------------------------------------------------------------------------
For a detailed explanation of sub-commands:    help decide

```
### Summary Screen

Using the `decide` command without any arguments will display key elements of Soar's current decision settings:
```
=======================================================
                     Decide Summary
=======================================================
Numeric indifference mode:                          sum
-------------------------------------------------------
Exploration Policy:                             softmax
Automatic Policy Parameter Reduction:               off
Epsilon:                                       0.100000
Epsilon Reduction Policy:                   exponential
Temperature:                                  25.000000
Temperature Reduction Policy:               exponential
-------------------------------------------------------

Use 'decide ?' for a command overview or 'help decide' for the manual page.
```

### decide numeric-indifferent-mode

The `numeric-indifferent-mode` command sets how multiple numeric indifferent preference values given to an operator are combined into a single value for use in random selection.

The default procedure is `--sum` which sums all numeric indifferent preference values given to the operator, defaulting to 0 if none exist.  The alternative `--avg` mode will average the values, also defaulting to 0 if none exist.

### decide indifferent-selection

The `indifferent-selection` command allows the user to set options relating to selection between operator proposals that are mutually indifferent in preference memory.

The primary option is the exploration policy (each is covered below). When Soar starts, _softmax_ is the default policy.

**Note**:  As of version 9.3.2, the architecture no longer automatically changes the policy to _epsilon-greedy_ the first time Soar-RL is enabled.

Some policies have parameters to temper behavior. The indifferent-selection command provides basic facilities to automatically reduce these parameters exponentially and linearly each decision cycle by a fixed rate. In addition to setting these policies/rates, the _auto-reduce_ option enables the automatic reduction system (disabled by default), for which the Soar decision cycle incurs a small performance cost.

#### indifferent-selection options:

|**Option**|**Description**|
|:---------|:--------------|
| `-s, --stats` | Summary of settings |
| `policy` | Set exploration policy |
| `parameter [exploration policy parameters]`| Get/Set exploration policy parameters (if value not given, returns the current value) |
| `parameter [reduction_policy](value]`| Get/Set exploration policy parameter reduction policy (if policy not given, returns the current) |
| `parameter reduction_policy [exploration policy parameter]`| Get/Set exploration policy parameter reduction rate for a policy (if rate not give, returns the current)|
| `-a, --auto-reduce [on,off](reduction-rate]`| Get/Set auto-reduction setting (if setting not provided, returns the current) |

#### indifferent-selection exploration policies:

|**Option**|**Description**|
|:---------|:--------------|
| `-b, --boltzmann` | Tempered softmax (uses temperature) |
| `-g, --epsilon-greedy` | Tempered greedy (uses epsilon) |
| `-x, --softmax` | Random, biased by numeric indifferent values (if a non-positive value is encountered, resorts to a uniform random selection) |
| `-f, --first` | Deterministic, first indifferent preference is selected |
| `-l, --last` | Deterministic, last indifferent preference is selected |

#### indifferent-selection exploration policy parameters:

| **Parameter Name** | **Acceptable Values** | **Default Value** |
|:-------------------|:----------------------|:------------------|
| `-e, --epsilon`    | `[0, 1]`              | `0.1`             |
| `-t, --temperature` | `(0, inf)`            | `25`              |

#### indifferent-selection auto-reduction policies:

|**Parameter Name**|**Acceptable Values**|**Default Value**|
|:-----------------|:--------------------|:----------------|
| `exponential default` | `[0, 1]`            | `1`             |
| `linear`         | `[0, inf]`          | `0`             |


### decide predict

The predict command determines, based upon current operator proposals, which operator will be chosen during the next decision phase. If predict determines an operator tie will be encountered, "tie" is returned. If predict determines no operator will be selected (state no-change), "none" is returned. If predict determines a conflict will arise during the decision phase, "conflict" is returned. If predict determines a constraint failure will occur, "constraint" is returned. Otherwise, predict will return the id of the operator to be chosen. If operator selection will require probabilistic selection, and no alterations to the probabilities are made between the call to predict and decision phase, predict will manipulate the random number generator to enforce its prediction.

### decide select

The select command will force the selection of an operator, whose id is supplied as an argument, during the next decision phase. If the argument is not a proposed operator in the next decision phase, an error is raised and operator selection proceeds as if the select command had not been called. Otherwise, the supplied operator will be selected as the next operator, regardless of preferences. If select is called with no id argument, the command returns the operator id currently forced for selection (by a previous call to select), if one exists.

#### Example

Assuming operator "O2" is a valid operator, this would select it as the next operator to be selected:

```
decide select O2
```

### decide set-random-seed

Seeds the random number generator with the passed seed. Calling `decide set-random-seed` (or equivalently, `decide srand`) without providing a seed will seed the generator based on the contents of /dev/urandom (if available) or else based on time() and clock() values.

#### Example

```
decide set-random-seed 23
```

### Default Aliases
```
inds           indifferent-selection
srand          set-random-seed
```

### See Also

[rl](./cmd_rl.md)
