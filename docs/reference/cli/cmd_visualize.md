## visualize

Creates visualizations of Soar's memory systems or processing.

#### Synopsis

```
======= Visualization Commands and Settings =======
visualize ?                                           Print this help listing
visualize [wm | smem | epmem] [id] [depth]            Visualize from memory system
visualize [ identity_graph | ebc_analysis]            Visualize EBC explainer analysis
------------------ Presentation -------------------
rule-format                          [ name | FULL]   Print all conditions and 
                                                      actions or just the rule name
memory-format                      [ node | RECORD]   Print memories as records 
                                                      or just simple nodes
line-style                                 polyline   GraphViz line style that will
                                                      be used
separate-states                        [ ON | off ]   Whether to create links
                                                      between goal states
architectural-wmes                     [ on | OFF ]   Whether to include WMEs 
                                                      created by the Soar architecture
color-identities                       [ on | OFF ]   Color identities in visualization
use-joined-identities                  [ ON | off ]   Color using final joined identities
------------------ File Handling ------------------
file-name                                  soar_viz
use-same-file                          [ on | OFF ]   Whether to create new files each time
generate-image                         [ ON | off ]   Whether an image should be created
image-type                                      svg   Image type that will be generated
------------------ Post Actions -------------------
viewer-launch                          [ ON | off ]   Launch image in viewer
editor-launch                          [ on | OFF ]   Open data file in editor
print-debug                            [ on | OFF ]   Print data file to screen
                                                      for debugging
```

### Description

The `visualize` command will generate graphical representations of either Soar memory structure or the analysis that explanation-based chunking performed to learn a rule.  

This command can be instructed to automatically launch a viewer to see the visual representation.  If you have an editor that can open graphviz files, you can have Soar launch that automatically as well. (Such editors allow you to move things around and lay out the components of the visualization exactly as you want them.)

### Visualizing Memory
`visualize [wm | smem | epmem] [id] [depth] `

The first argument is the memory system that you want to visualize.

The optional id argument allows you to specify either a root identifier from which to start working memory or semantic memory visualizations, or an episode ID for episodic memory visualization.

The depth argument specifies how many levels of augmentation that will be printed.

### Visualizing How a Rule was Learned

`visualize [ identity_graph | ebc_analysis]`

`visualize identity_graph` will create a visualization of how the final identities used in a learned rule were determined. This shows all identities involved and how the identity analysis joined them based on the problem-solving that occurred.

`visualize ebc_analysis` will create a visualization of the chunk that was learned and all rules that fired in a substate that contributed to a rule being learned. In addition to all of the dependencies between rules that fired, this visualization also shows which conditions in the instantiations tested knowledge in the superstate and hence contributed to a conditions in the final learned rule.

### Presentation Settings

`rule-format`:  This setting only applies to visualizing EBC processing. The `full` format will print all conditions and actions of the rule. The `name` format will only print a simple object with the rule name.

`memory-format`:  This setting only applies to visualizing memory systems. The `node` format will print a single graphical object for every symbol, using a circle for identifiers and a square for constants.  The `record` format will print a database-style record for each identifier with all of its augmentations as fields.  Links to other identifiers appear as arrows.

`line-style` is a parameter that is passed to Graphviz and affects how lines are drawn between objects. See the Graphviz documentation for legal values.

`separate-states` is a parameter that determines whether a link to a state symbol is drawn. When this setting is on, Soar will not connect states and instead will represent it as a constant. This setting only applies to visualizing memory systems.

`architectural-wmes` is a parameter that determines whether working memory elements created by the architecture, for example I/O and the various memory sub-system links, will be included in the visualization. This setting only applies to visualizing memory systems.

### File Handling Settings

`file-name` specifies the base file name that Soar will use when creating both graphviz data files and images. You can specify a path as well, for example "visualization/soar_viz", but make sure the directory exists first!

`use-same-file` tells the visualizer to always overwrite the same files for each visualization. When off, Soar will create a new visualization each time by using the base file name and adding a new number to it each time. Note that this command does not yet handle file creation as robustly as it could. If the file already exists, it will simply overwrite it rather than looking for a new file name. 

`generate-image` specifies whether the visualizer should render the graphviz file into an image. This setting is overridden if the viewer-launch setting is enabled. 

`image-type` specifies what kind of image that visualizer should create. Graphviz is capable of rendering to a staggering number of different image types. The default that the visualizer uses is SVG, which is a vector-based format that can be scaled without loss of clarity. For other legal formats, see the Graphviz or DOT documentation. 

### Post Action Settings

After the data and image files are generated, the visualizer can automatically launch an external program to view or edit the output.

`viewer-launch` specifies whether to launch an image viewer. Most web browser can view SVG files.

`editor-launch` specifies whether to launch whatever program is associated with `.gv` files. For example, on OSX, the program OmniGraffle can be used to great effect.

`print-debug` specifies whether to print the raw Graphviz output to the screen. If you are having problems, you may want to use this setting to see what it is generating for your agent.

Note that your operating system chooses which program to launch based on the file type. This feature has not been tested extensively on other platforms. Certain systems may not allow Soar to launch an external program.
  
### See Also

[explain](./cmd_explain.md) 
[epmem](./cmd_epmem.md) 
[smem](./cmd_smem.md) 
[chunk](./cmd_chunk.md)
