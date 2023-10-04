## rl

Control how numeric indifferent preference values in RL rules are updated via reinforcement learning.

#### Synopsis

```
rl -g|--get <parameter>
rl -s|--set <parameter> <value>
rl -t|--trace <parameter> <value>
rl -S|--stats <statistic>
```

#### Options:

| **Option** | **Description** |
|:-----------|:----------------|
| `-g, --get` | Print current parameter setting |
| `-s, --set` | Set parameter value             |
| `-t, --trace` | Print, clear, or init traces    |
| `-S, --stats` | Print statistic summary or specific statistic |

#### Description

The `rl` command sets parameters and displays information related to reinforcement learning.  The `print` and `trace` commands display additional RL related information not covered by this command.

### Parameters

Due to the large number of parameters, the `rl` command uses the `--get|--set <parameter> <value>` convention rather than individual switches for each parameter.  Running `rl` without any switches displays a summary of the parameter settings.

| **Parameter** | **Description** | **Possible values** | **Default** |
|:--------------|:----------------|:--------------------|:------------|
| chunk-stop  | If enabled, chunking does not create duplicate RL rules that differ only in numeric-indifferent preference value | `on`, `off`         | `on`        |
| decay-mode  | How the learning rate changes over time | `normal`, `exponential`, `logarithmic`, `delta-bar-delta` | `normal`    |
| discount-rate | Temporal discount (gamma) | `[`0, 1`]`          | 0.9         |
| eligibility-trace-decay-rate | Eligibility trace decay factor (lambda) | `[`0, 1`]`          | 0           |
| eligibility-trace-tolerance | Smallest eligibility trace value not considered 0 | (0, inf)            | 0.001       |
| hrl-discount | Discounting of RL updates over time in impassed states | `on`, `off`         | `off`       |
| learning    | Reinforcement learning enabled | `on`, `off`         | `off`       |
| learning-rate | Learning rate (alpha) | `[`0, 1`]`          | 0.3         |
| step-size-parameter | Secondary learning rate  | `[`0,1`]`         | 1           |
| learning-policy | Value update policy | `sarsa`, `q-learning`, `off-policy-gq-lambda`, `on-policy-gq-lambda` | `sarsa`     |
| meta        | Store rule metadata in header string | `on`, `off`         | `off`       |
| meta-learning-rate | Delta-Bar-Delta learning parameter | `[`0, 1`]`        | 0.1         |
| temporal-discount | Discount RL updates over gaps  | `on`, `off`         | `on`        |
| temporal-extension | Propagation of RL updates over gaps  | `on`, `off`         | `on`        |
| trace       | Update the trace | `on`, `off`         | `off`       |
| update-log-path | File to log information about RL rule updates  | `""`, `<filename>`  | `""`        |

#### Apoptosis Parameters:

| **Parameter** | **Description** | **Possible values** | **Default** |
|:--------------|:----------------|:--------------------|:------------|
| `apoptosis`   | Automatic excising of productions via base-level decay  | `none`, `chunks`, `rl-chunks` | `none`      |
| `apoptosis-decay` | Base-level decay parameter | `[`0, 1`]`          | 0.5         |
| `apoptosis-thresh` | Base-level threshold parameter (negates supplied value) | (0, inf)            | 2           |

**Apoptosis** is a process to automatically excise chunks via the base-level decay model (where rule firings are the activation events). A value of `chunks` has this apply to any chunk, whereas `rl-chunks` means only chunks that are also RL rules can be forgotten.

### RL Statistics

Soar tracks some RL statistics over the lifetime of the agent. These can be accessed using `rl --stats <statistic>`. Running `rl --stats` without a statistic will list the values of all statistics.

| **Option** | **Description** |
|:-----------|:----------------|
| `update-error` | Difference between target and current values in last RL update |
| `total-reward` | Total accumulated reward in the last update                    |
| `global-reward` | Total accumulated reward since agent initialization            |

### RL Delta-Bar-Delta

This is an experimental feature of Soar RL. It based on the work in Richard S. Sutton's paper "Adapting Bias by Gradient Descent: An Incremental Version of Delta-Bar-Delta", available online at http://incompleteideas.net/papers/sutton-92a.pdf.
Delta Bar Delta (DBD) is implemented in Soar RL as a decay mode. It changes the way all the rules in the eligibility trace get their values updated. In order to implement this, the agent gets an additional learning parameter **`meta-learning-rate`** and each rule gets two additional decay parameters: beta and h. The meta learning rate is set manually; the per-rule features are handled automatically by the DBD algorithm. The key idea is that the meta parameters keep track of how much a rule's RL value has been updated recently, and if a rule gets updates in the same direction multiple times in a row then subsequent updates in the same direction will have more effect. So DBD acts sort of like momentum for the learning rate.

To enable DBD, use `rl --set decay-mode delta-bar-delta`. To change the meta learning rate, use e.g. `rl --set meta-learning-rate 0.1`. When you execute `rl`, under the "Experimental" section of output you'll see the current settings for `decay-mode` and `meta-learning-rate`. Also, if a rule gets printed concisely (e.g. by executing `p`), and the rule is an RL rule, and the decay mode is set to delta-bar-delta, then instead of printing the rule name followed by the update count and the RL value, it will print the rule name, beta, h, update count, and RL value.

Note that DBD is a different feature than `meta`. Meta determines whether metadata about a production is stored in its header string. If meta is on and DBD is on, then each rule's beta and h values will be stored in the header string in addition to the update count, so you can print out the rule, source it later and that metadata about the rule will still be in place.

### RL GQ($\lambda$)

Linear GQ($\lambda$) is a gradient-based off-policy temporal-difference learning algorithm, as developed by Hamid Maei and described by Adam White and Rich Sutton (https://arxiv.org/pdf/1705.03967.pdf). This reinforcement learning option provides off-policy learning quite effectively. This is a good approach in cases when agent training performance is less important than agent execution performance. GQ($\lambda$) converges despite irreversible actions and other difficulties approaching the training goal. Convergence should be guaranteed for stable environments.

To change the secondary learning rate that only applies when learning with GQ($\lambda$), set the rl **`step-size-parameter`**. It controls how fast the secondary set of weights changes to allow GQ($\lambda$) to improve the rate of convergence to a stable policy. Small learning rates such as 0.01 or even lower seems to be good practice.

`rl --set learning-policy off-policy-gq-lambda` will set Soar to use linear GQ($\lambda$). It is preferable to use GQ($\lambda$) over sarsa or q-learning when multiple weights are active in parallel and sequences of actions required for agents to be successful are sufficiently complex that divergence is possible. To take full advantage of GQ($\lambda$), it is important to set `step-size-parameter` to a reasonable value for a secondary learning rate, such as 0.01.

`rl --set learning-policy on-policy-gq-lambda` will set Soar to use a simplification of GQ($\lambda$) to make it on-policy while otherwise functioning identically. It is still important to set `step-size-parameter` to a reasonable value for a secondary learning rate, such as 0.01.

For more information, please see the relevant slides on http://www-personal.umich.edu/~bazald/b/publications/009-sw35-gql.pdf

### RL Update Logging

Sets a path to a file that Soar RL will write to whenever a production's RL value gets updated. This can be useful for logging these updates without having to capture all of Soar's output and parse it for these updates. Enable with e.g. `rl --set update-log-path rl\_log.txt`. Disable with `rl --set update-log-path ""` - that is, use the empty string "" as the log path. The current log path appears under the experimental section when you execute "rl".

### RL Trace

If `rl --set trace on` has been called, then proposed operators will be recorded in the trace for all goal levels. Along with operator names and other attribute-value pairs, transition probabilities derived from their numeric preferences are recorded.

Legal arguments following `rl -t` or `rl --trace` are as follows:

| **Option** | **Description** |
|:-----------|:----------------|
| `print` |  Print the trace for the top state. |
| `clear` |  Erase the traces for all goal levels. |
| `init`  | Restart recording from the beginning of the traces for all goal levels. |

These may be followed by an optional numeric argument specifying a specific goal level to print, clear, or init. `rl -t init` is called automatically whenever Soar is reinitialized. However, `rl -t clear` is never called automatically.

The format in which the trace is printed is designed to be used by the program dot, as part of the <a href='http://www.graphviz.org/'>Graphviz</a> suite. The command `ctf rl.dot rl -t` will print the trace for the top state to the file "rl.dot". (The default behavior for `rl -t` is to print the trace for the top state.)

Here are some sample dot invocations for the top state:

| **Option** | **Description** |
|:-----------|:----------------|
| `dot -Tps rl.dot -o rl.ps` | `ps2pdf rl.ps` | Generate a .ps file and convert it to .pdf. |
| `dot -Tsvg rl.dot -o rl.svg` | `inkscape -f rl.svg -A rl.pdf` | Generate a .svg file and convert it to .pdf. |

The .svg format works better for large traces.

### See Also

[excise](./cmd_excise.md) 
[print](./cmd_print.md) 
[trace](./cmd_trace.md)
