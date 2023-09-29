## svs

Control the behavior of the Spatial Visual System

Syntax:
```
svs <elements to inspect>
svs [--enable | -e | --on | --disable | -d | --off]
```

#### Synopsis
```
svs <path> dir
svs <path> help
svs connect_viewer <port>
svs disconnect_viewer
svs filters
svs filters.<filter_name>
svs commands
svs commands.<command_name>
svs <state>.scene.world
svs <state>.scene.world.<path-to-node>
svs <state>.scene.properties
svs <state>.scene.sgel <sgel-command>
svs <state>.scene.draw on|off
svs <state>.scene.clear
```

### Paths

SVS can be navigated by specifying a path after the svs command. This path mimicks a directory structure and is specified by dot notation.

| **Path** | **Argument** | **Description** |
|:---------|:-------------|:----------------|
| connect_viewer | &lt;port&gt;     | Connects to a svs\_viewer listening on the given port |
| disconnect_viewer |              | Disconnects from an active svs\_viewer |
| filters |              | Prints out a list of all the filters |
| filters.&lt;filter_name&gt; |              | Prints information about a specific filter |
| commands |              | Prints out a list of all the soar commands |
| commands.&lt;command_name&gt; |              | Prints information about a specific command |
| &lt;state&gt;.scene.world |              | Prints information about the world |
| &lt;state&gt;.scene.&lt;node-path&gt; |              | Prints information about a specific node |
| &lt;state&gt;.scene.properties |              | Prints pos/rot/scale/tag info about all nodes |
| &lt;state&gt;.scene.sgel | &lt;sgel&gt;     | Sends an sgel command to the scene |
| &lt;state&gt;.scene.draw | on         | Causes this scene to be the one drawn on the viewer |
| &lt;state&gt;.scene.draw | off        | Stops this scene from being drawn in the viewer |
| &lt;state&gt;.scene.clear|              | Removes all objects from the given scene |

### Description

Each path can be followed by `help` to print some help info, or followed by `dir` to see the children of that path.
The `<state>` variable is the identifier for the substate you want to examine. For example, to do things to the topstate scene you would use `svs S1.scene`.

### Examples

Print the full SVS directory structure
```
svs . dir
```
Print help information about connect\_viewer
```
svs connect_viewer help
```
Print information about a distance filter
```
svs filters.distance
```
Print all the nodes in the scene for substate S17
```
svs S17.scene.world dir
```
Print information about the node wheel2 on car5
```
svs S1.scene.world.car5.wheel2
```
Add a new node to the scene using SGEL
```
svs S1.scene.sgel add ball3 world ball .5 position 1 1 1
```
