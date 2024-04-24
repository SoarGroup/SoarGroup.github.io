---
date: 2014-10-07
authors:
    - soar
tags:
    - kernel programming
---

<!-- markdown-link-check-disable-next-line -->
<!-- old URL: https://soar.eecs.umich.edu/articles/articles/technical-documentation/200-i-o-and-reward-links -->

# I/O and Reward Links

## Introduction

Soar provides several links on various states: the io, input-link, and
output-link exist on the top state, whereas a reward-link exists on every state.
This page will describe how to add your own link, using the emotion link as an
example (since that's what I'm working on at the moment). Note that this is
actually a couple links (like io has a couple links) and it's only on the top
state. If you only want a single link and/or you want links on all states, just
search the code for reward-link to see how that's different (most of the
differences for reward-link are because it is on every state).

When adding a new link, there are several things you need to deal with:

- adding the link on agent creation
- removing the link on agent destruction
- recreating the link during an init-soar

Depending on what the link is for, you may also need to deal with:

- reading things off of the link
- putting things on the link

## Adding the link on agent creation

Adding a new link involves several steps:

-   Creating and saving the link symbols and WMEs

## Creating and saving the link symbols and WMEs

Commonly-used symbols are often created once and stored on the agent structure.
This includes link names (the attribute of the link wme). Let's suppose I want
the following link structure (I'm using concrete identifiers for clarity; the
actual identifiers that get created may be different):

```
S1 [COLOR=#666600]^[/COLOR]emotion E1 E1 [COLOR=#666600]^[/COLOR]appraisal[COLOR=#666600]-[/COLOR]link A1 [COLOR=#666600]^[/COLOR]feeling[COLOR=#666600]-[/COLOR]link F1
```

I need to create and save symbols for "emotion", "appraisal-link" and
"feeling-link", and the WMEs that contain those symbols. To do this, go to the
agent structure (agent.h) and find the section labeled "Predefined Symbols". At
the end of this section, add a Symbol pointer for each new symbol:

```
[COLOR=#660066]Symbol[/COLOR] [COLOR=#666600]*[/COLOR] emotion_symbol[COLOR=#666600];[/COLOR]
[COLOR=#660066]Symbol[/COLOR] [COLOR=#666600]*[/COLOR] appraisal_link_symbol[COLOR=#666600];[/COLOR]
[COLOR=#660066]Symbol[/COLOR] [COLOR=#666600]*[/COLOR] feeling_link_symbol[COLOR=#666600];[/COLOR]
```

Now find the part of the agent structure labeled "I/O stuff" and add the Symbols
corresponding to the identifier values of the WMEs and the wme structures
themselves (generally speaking, you only need to save the WMEs that you plan on
directly manipulating in other code):

```
Symbol            * emotion_header;
wme               * emotion_header_link;

Symbol            * emotion_header_appraisal;
Symbol            * emotion_header_feeling;
```

Now go to the `create_predefined_symbols` function (in symtab.cpp) and create your symbols at the end:

```c++
thisAgent->emotion_symbol = make_sym_constant (thisAgent, "emotion");
thisAgent->appraisal_link_symbol = make_sym_constant( thisAgent, "appraisal-link" );
thisAgent->feeling_link_symbol = make_sym_constant( thisAgent, "feeling-link" );
```

Finally, go to the init_agent_memory function in init_soar.cpp and create the
identifier values and WMEs corresponding to the desired structure:

```c++
thisAgent->emotion_header = get_new_io_identifier (thisAgent, 'E'); // E1
thisAgent->emotion_header_appraisal = get_new_io_identifier (thisAgent, 'A');  // A1
thisAgent->emotion_header_feeling = get_new_io_identifier (thisAgent, 'F'); // F1

// (S1 ^emotion E1)
thisAgent->emotion_header_link = add_input_wme (thisAgent,
                                                thisAgent->top_state,
                                                thisAgent->emotion_symbol,
                                                thisAgent->emotion_header);
// (E1 ^appraisal-link A1)
add_input_wme (thisAgent, thisAgent->emotion_header,
               thisAgent->appraisal_link_symbol,
               thisAgent->emotion_header_appraisal);
// (E1 ^feeling-link F1)
add_input_wme (thisAgent, thisAgent->emotion_header,
               thisAgent->feeling_link_symbol,
               thisAgent->emotion_header_feeling);
```

## Removing the link on agent destruction

On agent destruction, we need to remove all of those symbols we saved on the
agent structure. To do this, go to the release_predefined_symbols function (in
symtab.cpp) and add the following to the end:

```c++
release_helper( thisAgent, &( thisAgent->emotion_symbol ) );
release_helper( thisAgent, &( thisAgent->appraisal_link_symbol ) );
release_helper( thisAgent, &( thisAgent->feeling_link_symbol ) );
```

Note that this function is called from destroy_soar_agent in agent.cpp.

In general, you do not need to explicitly release the WMEs, since those will
automatically be cleaned up when the wme memory pool is cleaned up during agent
destruction.

## Recreating the link during an init-soar

Perhaps counter-intuitively, link recreation is handled in the do_input_cycle
function in io.cpp. (Historically, initial link creation was handled here as
well). Basically, the reinitialize_soar function calls clear_goal_stack which
destroys the entire state and then calls do_input_cycle to recreate the top
state. Find the part of do_input_cycle inside the if clause labeled "top state
was just removed" and release the identifier values we created and set the
corresponding pointers (including to WMEs) on the agent structure to NIL:

```c++
release_io_symbol (thisAgent, thisAgent->emotion_header);
release_io_symbol (thisAgent, thisAgent->emotion_header_appraisal);
release_io_symbol (thisAgent, thisAgent->emotion_header_feeling);
thisAgent->emotion_header = NIL;
thisAgent->emotion_header_appraisal = NIL;
thisAgent->emotion_header_feeling = NIL;
thisAgent->emotion_header_link = NIL;
```

Failure to do this properly will result in memory leak warnings when you do an init-soar.

## Reading things off of the link

To read things off the link, you need to loop over any WMEs that might be on the
link. In our example, suppose the following structure exists:

```Soar
S1 ^emotion E1
E1 ^appraisal-link A1
A1 ^frame F1
F1 ^conduciveness 1.0
```

We have a pointer to the appraisal-link on the agent structure already, so we
can start there. First, make sure it exists (depending on when you call this
function, it might not):

```c++
void get_appraisals(agent* thisAgent)
{
  if(!thisAgent->emotion_header_appraisal) return;
```

Next, we have to loop over the slots. Slots are simply a list of WMEs that have
the same id and attribute - that is, they support multi-valued attributes. If
you don't have any multi-valued attributes, then each slot will only have one
wme.

```c++
slot* frame_slot = thisAgent->emotion_header_appraisal->id.slots;
slot* appraisal_slot;
wme *frame, *appraisal;

if ( frame_slot )
{
  for ( ; frame_slot; frame_slot = frame_slot->next )
{
```

Each slot has an id, attr, and list of WMEs. In this case, we are looking for the "frame" slot. We will skip any other slots we see:

Code:

```c++
if(frame_slot->attr->sc.common_symbol_info.symbol_type == SYM_CONSTANT_SYMBOL_TYPE
        && !strcmp(frame_slot->attr->sc.name, "frame")) /* BADBAD: should store "frame" symbol in common symbols so can do direct comparison */
{
```

When we find a "frame" slot, we will loop over its WMEs (each of which have the
same id and the "frame" attribute). For the structure above, the only wme on
this list will be A1 ^frame F1. For each wme that has an id value (just one in
this case), we will loop over its slots and WMEs:

```c++
for ( frame = frame_slot->wmes ; frame; frame = frame->next)
{
if (frame->value->common.symbol_type == IDENTIFIER_SYMBOL_TYPE)
{
  for ( appraisal_slot = frame->value->id.slots; appraisal_slot; appraisal_slot = appraisal_slot->next )
  {
    for ( appraisal = appraisal_slot->wmes; appraisal; appraisal = appraisal->next )
    {
      // do stuff with the WMEs; in this example, will get the F1 ^conduciveness 1.0 wme here
    }
```

Here's the complete example:

```c++
void get_appraisals(agent* thisAgent)
{
  if(!thisAgent->emotion_header_appraisal) return;

  slot* frame_slot = thisAgent->emotion_header_appraisal->id.slots;
  slot* appraisal_slot;
  wme *frame, *appraisal;

  if ( frame_slot )
  {
    for ( ; frame_slot; frame_slot = frame_slot->next )
    {
      if(    frame_slot->attr->sc.common_symbol_info.symbol_type == SYM_CONSTANT_SYMBOL_TYPE
         && !strcmp(frame_slot->attr->sc.name, "frame")) /* BADBAD: should store "frame" symbol in common symbols so can do direct comparison */
      {
        for ( frame = frame_slot->wmes ; frame; frame = frame->next)
        {
          if (frame->value->common.symbol_type == IDENTIFIER_SYMBOL_TYPE)
          {
            for ( appraisal_slot = frame->value->id.slots; appraisal_slot; appraisal_slot = appraisal_slot->next )
            {
              for ( appraisal = appraisal_slot->wmes; appraisal; appraisal = appraisal->next )
              {
                // do stuff with the WMEs; in this example, will get the F1 ^conduciveness 1.0 wme here
              }
            }
          }
        }
      }
    }
  }
}
```

Of course, we need to call this function from somewhere. In this example, we'll
read this link during the input phase, so we'll call it from do_input_cycle (in
io.cpp), in the block of code marked "if there is a top state, do the normal
input cycle":

```c++
/* --- if there is a top state, do the normal input cycle --- */

if (thisAgent->top_state) {
  soar_invoke_callbacks(thisAgent, INPUT_PHASE_CALLBACK, (soar_call_data) NORMAL_INPUT_CYCLE);

  get_appraisals(thisAgent);  // added this line
}

```

## Putting things on the link

To put things on the link, you'll want to use these two functions: add_input_wme
and remove_input_wme. In my example, I want to replace a wme that may exist on
the feeling-link:

```Soar
S1 ^emotion E1
E1 ^feeling-link F1
F1 ^frame F2  <-- I want to blink this
```

First, let's suppose I already have a pointer to this wme saved on the agent structure:

```c++
wme * feeling_frame;
```

And also assume that I initialized this to 0 in init_agent_memory:

```c++
thisAgent->feeling_frame = 0;
```

Now I can update it like this:

```c++
void generate_feeling_frame(agent* thisAgent)
{
  // clear previous feeling frame (stored on agent structure)
  if(thisAgent->feeling_frame) { remove_input_wme(thisAgent, thisAgent->feeling_frame); }

  // generate new frame
  thisAgent->feeling_frame = add_input_wme(thisAgent, thisAgent->emotion_header_feeling, make_sym_constant(thisAgent, "frame"), make_new_identifier(thisAgent, 'F', TOP_GOAL_LEVEL));
}
```

Actually, that's not quite right - this will result in a memory leak (which
will cause init-soar to fail, among other things). What will happen here is the
call to make_sym_constant will create a new Symbol with a reference count of 1,
and then add_input_wme will add another ref count to it. When this function is
called later, remove_input_wme will decrement the ref count by 1, still leaving
it with a non-zero ref count. The way to fix this is to decrement the ref count
after we pass the Symbol off to add_input_wme (in effect, we are relinquishing
control of the Symbol to the wme):

```c++
void generate_feeling_frame(agent* thisAgent)
{
  // clear previous feeling frame (stored on agent structure)
  if(thisAgent->feeling_frame) { remove_input_wme(thisAgent, thisAgent->feeling_frame); }

  // generate new frame
  Symbol* frame_att = make_sym_constant(thisAgent, "frame");
  thisAgent->feeling_frame = add_input_wme(thisAgent, thisAgent->emotion_header_feeling, frame_att, make_new_identifier(thisAgent, 'F', TOP_GOAL_LEVEL));
  symbol_remove_ref(thisAgent, frame_att);
}
```

Of course, we need to call this function from somewhere. In this example, we
want to generate a new frame right after we read in the appraisals, so we call
the function from the same block of code as above (in do_input_phase in io.cpp):

```c++
/* --- if there is a top state, do the normal input cycle --- */

if (thisAgent->top_state) {
  soar_invoke_callbacks(thisAgent, INPUT_PHASE_CALLBACK, (soar_call_data) NORMAL_INPUT_CYCLE);

  get_appraisals(thisAgent);  // added this line above
  generate_feeling_frame(thisAgent); // added this line
}
```
