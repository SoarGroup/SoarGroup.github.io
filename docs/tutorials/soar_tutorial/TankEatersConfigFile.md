---
date: 2014-10-07
authors:
  - soar
tags:
  - eaters
---

<!-- markdown-link-check-disable-next-line -->
<!-- old URL: https://soar.eecs.umich.edu/articles/articles/technical-documentation/201-memory-leak-debugging-with-visual-studio -->

## Tank Eaters Configuration File

Soar2D is a general framework that includes both Eaters and TankSoar. This
document describes how to modify these environments using the configuration
settings files.

### Configuration Files

Soar2D configuration files are stored in the Soar2D folder. When running the
soar2d jar, you may specify the configuration file to use on the command line,
or run without specifying any and a dialog window will pop-up.

```bash
java -jar soar2d.jar configs/tanksoar.cnf
java -jar soar2d.jar configs/eaters.cnf
java -jar soar2d.jar configs/room.cnf
java -jar soar2d.jar
```

Configuration entries are of the format:

```
''key'' = ''value''; # Note the trailing semicolon.
```

Use the pound sign for comments. Start them anywhere on a line.

```
## Comments go here
Configuration keys are simple identifiers. Stick to alphanumeric characters and underscores.
```

```
exampleKey = ''value'';
example_key = ''value'';
```

Configuration keys have an optional hierarchy separated by dots or braces. These
are equivalent:

```
path.to.key = ''value'';
path.to.another = ''value'';

path
{
   to
   {
      key = ''value'';
      another = ''value'';
   }
}

path
{
   to
   {
      key = ''value'';
   }
}
path.to.another = ''value'';
```

Configuration values are strings or an array of strings using the following
notation:

```
single = data;
single_element_array = [ data ];
trailing_comma_ok = [ data, ];
two_element_array = [ data, banks ];
two_element_array_with_trailer = [ data, banks, ];
```

Most whitespace is stripped out of the configuration file. These lines are all
equivalent:

```
path.to.key = databanks;        # Value is "databanks"
path.to.key = data banks;       # Value is "databanks"
path . to.key = databanks;      # Value is "databanks"
path.t o.key = d a t a banks;   # Value is "databanks"
pa th. to. k ey = "databanks";  # Value is "databanks"
pa th. to. k ey
= "databanks";                  # Value is "databanks"
```

Preserve spaces using quotes:

```
path.to.key = "data banks";     # Value is "data banks" with a space.
arrays_too = [ "data banks", "another value" ]; # Values are "data banks" and "another value"
```

Don't split keys or values across lines:

```
crazy.                 # Syntax error
spacing = "databanks"; #
crazy.spacing = "data  # Value truncated
banks";                # Syntax error
OK to split other things along lines (or not). These are all legal entires:
```

```
key1 = value1;
key2 =
       value2;
key3 = [ value3.1, value3.2, value3.3 ];
key4
=
[ value4.1, value4.2 ];
key5 = [
     value5.1,
     value5.2,
];
key6 { subkey6.1 = value6.1; subkey6.2 = value6.2; }
```

Backslash doesn't escape anything (this is a change from the original behavior).

Code exists to easily pull out types boolean, string, int, double, or arrays of
these types:

```
parameter = 5.434; # config.requireDouble("parameter");
switch = false;    # config.requireBoolean("switch");
count = 4;         # config.requireInt("count");
players = [7, 8]   # config.requireInts("players"); // returns int [] length 2
```

Defaults can be enforced in code:

```
config.getInt("some.value.not.in.config.file", 4); // returns 4
```

### Clients

Clients are encoded in a clients block using their names for their sub block.
Additionally, their names must be enumerated in an `active_clients` array. For
example:

```
clients
{
   active_clients = [ "watchdog", "timer" ];
   watchdog
   {
      command = "run-watchdog.bat";
   }
   timer
   {
      command = "run-timer.bat";
   }
   disabled # not enumerated, so it is ignored.
   {
      command = "run-something-someothertime.bat";
   }
}
```

Note that there is a default, hidden client named "java-debugger". Don't use this name or put it in the active_clients list.

| Path                     | Type         | Values | Default | Comment                                                                                     |
| ------------------------ | ------------ | ------ | ------- | ------------------------------------------------------------------------------------------- |
| clients.active_clients   | string array |        |         | Each active client. Clients not listed in this array but defined in this block are ignored. |
| clients.''name''.command | string       |        |         | Command to run from cwd                                                                     |
| clients.''name''.timeout | int          |        | 0       | Seconds to wait for client to report in                                                     |
| clients.''name''.after   | boolean      |        | true    | true: spawn after all agents are created, false: spawn before all agents are created        |

### eaters

| Path                    | Type   | Values            | Default | Comment                           |
| ----------------------- | ------ | ----------------- | ------- | --------------------------------- |
| eaters.vision           | int    | number of cells   | 2       | How far can the eater see?        |
| eaters.wall_penalty     | int    | points (negative) | -5      | Penalty for running in to walls   |
| eaters.jump_penalty     | int    | points (negative) | -5      | Penalty for executing a jump      |
| eaters.low_probability  | double | probability       | 0.25    | Used during random map generation |
| eaters.high_probability | double | probability       | 0.75    | Used during random map generation |

### general

| Path                     | Type    | Values                                | Default               | Comment                                                                                                                |
| ------------------------ | ------- | ------------------------------------- | --------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| general.cycle_time_slice | double  |                                       | 50                    | How much simulation time passes per tick (ms)                                                                          |
| general.default_points   | int     |                                       | 0                     | Starting points                                                                                                        |
| general.game             | string  | tanksoar, eaters, room, kitchen, taxi |                       | What game                                                                                                              |
| general.map              | string  | path                                  |                       | Path to map file                                                                                                       |
| general.headless         | boolean |                                       | false                 | Run headless                                                                                                           |
| general.preferences_file | string  |                                       | "preferences"         | Path to preferences file (used for common settings to preserve across runs such as last productions, window location). |
| general.runs             | int     |                                       | 1                     | How many back-to-back runs to execute                                                                                  |
| general.seed             | int     |                                       | null (random default) | Seed Java and SML                                                                                                      |
| general.force_human      | boolean |                                       | false                 | Force human input, overrides agent input. Great for debugging input link.                                              |

### soar

| Path                  | Type    | Values          | Default        | Comment                               |
| --------------------- | ------- | --------------- | -------------- | ------------------------------------- |
| soar.max_memory_usage | int     | bytes           | kernel default | Call command max-memory-usage         |
| soar.port             | int     | valid TCP ports | 12121          | Connect/listen on this port           |
| soar.remote           | string  | IP address      | null           | Connect to a remote kernel at this IP |
| soar.spawn_debuggers  | boolean |                 | true           | Spawn debuggers on agent creation     |
| soar.soar_print       | boolean |                 | false          | Log print events to file              |

### players

Players are encoded in a players block using arbitrary identifiers for their sub
blocks. Active player IDs must be enumerated in an `active_players` array. For
example, the following configuration file defines 3 players but only uses two of
them for the run:

```
players
{
   active_players = [ "obscure", "simple" ];
   obscure
   {
      productions = "agents/tanksoar/obscure-bot.soar";
   }
   simple
   {
      productions = "agents/tanksoar/tutorial/simple-bot.soar";
   }
   mapping
   {
      productions = "agents/tanksoar/tutorial/mapping-bot.soar";
      shutdown_commands = [ "echo shutting down", "print" ];
   }
}
```

Do not id players with the prefix "gui" or "clone", the players created at
runtime use those.

| Path                             | Type         | Values                                          | Default      | Comment                                       |
| -------------------------------- | ------------ | ----------------------------------------------- | ------------ | --------------------------------------------- |
| players.''id''.name              | string       |                                                 | color        | Agent name                                    |
| players.''id''.productions       | string       |                                                 | null (human) | Productions                                   |
| players.''id''.script            | string       |                                                 | null (human) | Do not use (yet), for testing                 |
| players.''id''.color             | string       | red, blue, yellow, purple, orange, green, black | random       | desired color                                 |
| players.''id''.pos               | int array    |                                                 | random       | Starting x,y coordinate (int array, length 2) |
| players.''id''.facing            | string       | north, south, east, west                        | random       | Starting facing direction, cardinal           |
| players.''id''.points            | int          |                                                 | 0            | Starting points                               |
| players.''id''.energy            | int          |                                                 | game default | Starting energy (tanksoar)                    |
| players.''id''.health            | int          |                                                 | game default | Starting health (tanksoar)                    |
| players.''id''.missiles          | int          |                                                 | game default | Starting missiles (tanksoar)                  |
| players.''id''.shutdown_commands | string array | valid Soar commands                             | null         | Commands to run before destroying agent       |

### room

There are currently no configuration options for the Room environment.

### taxi

| Path                       | Type    | Values | Default | Comment                              |
| -------------------------- | ------- | ------ | ------- | ------------------------------------ |
| taxi.disable_fuel          | boolean |        | false   | If disabled, ignore effects of fuel  |
| taxi.fuel_starting_minimum | int     |        | 5       | Fuel starts between this and maximum |
| taxi.fuel_starting_maximum | int     |        | 12      | Fuel starts between this and minimum |
| taxi.fuel_maximum          | int     |        | 14      | Fuel goes to here when refueled      |

### tanksoar

| Path                                 | Type | Values | Default | Comment                                                                               |
| ------------------------------------ | ---- | ------ | ------- | ------------------------------------------------------------------------------------- |
| tanksoar.max_missiles                |      |        | 15      | Maximum missile count                                                                 |
| tanksoar.max_energy                  |      |        | 1000    | Maximum energy count                                                                  |
| tanksoar.max_health                  |      |        | 1000    | Maximum health count                                                                  |
| tanksoar.collision_penalty           |      |        | -100    | Penalty for colliding with another tank or wall                                       |
| tanksoar.max_missile_packs           |      |        | 3       | Maximum number of missile packs to spawn at a time                                    |
| tanksoar.missile_pack_respawn_chance |      |        | 5       | Chance per turn that a missile pack spawns when below max                             |
| tanksoar.shield_energy_usage         |      |        | -20     | Energy usage per turn that shields are on                                             |
| tanksoar.missile_hit_award           |      |        | 2       | Points awarded when your missile connects with a tank                                 |
| tanksoar.missile_hit_penalty         |      |        | -1      | Points lost when hit by a missile                                                     |
| tanksoar.frag_award                  |      |        | 3       | Points awarded when your missile frags a tank                                         |
| tanksoar.frag_penalty                |      |        | -2      | Points lost when fragged by a missile                                                 |
| tanksoar.max_sound_distance          |      |        | 7       | Maximum distance for the sound sensor                                                 |
| tanksoar.missile_reset_threshold     |      |        | 100     | Max amount of updates that can pass without a missile firing before resetting the map |

### terminals

| Path                          | Type    | Values | Default | Comment                                               |
| ----------------------------- | ------- | ------ | ------- | ----------------------------------------------------- |
| terminals.max_updates         | int     |        | 0       | World cycle count limit                               |
| terminals.agent_command       | boolean |        | false   | Agent issues stop command (input-link, not stop-soar) |
| terminals.points_remaining    | boolean |        | false   | No more points available on map                       |
| terminals.winning_score       | int     |        | 0       | At least one agent has at least this many points      |
| terminals.food_remaining      | boolean |        | false   | There is no more food on the map (eaters)             |
| terminals.unopened_boxes      | boolean |        | false   | There are no unopened boxes on the map (eaters)       |
| terminals.fuel_remaining      | boolean |        | false   | Run out of fuel (taxi)                                |
| terminals.passenger_delivered | boolean |        | false   | Passenger successfully delivered (taxi)               |
| terminals.passenger_pick_up   | boolean |        | false   | Passenger removed from map (taxi)                     |

### Logging

<http://logging.apache.org/log4j/1.2/index.html>

### Map Files

Maps are now stored in the config/maps/game folder where game is the game type,
such as eaters.

### Map file

- `objects_file (string)`
    - This file defines objects in the world, see Object File below. The path is
        relative to the map file.
- `objects (string array)`
    - This is an array of objects ids that are available for use on the map. Often
        time these ids are one character so the map is easily human-readable.
- `cells (block)`
    - This sub-block defines the cells in the map, or properties about the cells
        that will be randomly generated.
- `cells.size (int)`
    - Width and height of map.
- `cells.random_walls (boolean)`
    - Randomly generate the walls on this map.
- `cells.random_food (boolean)`
    - Randomly place food on the map.
- `cells.rows (block)`
    - Cell instances
- `cells.rows.INTEGER (string array)`
    - The rows the map, from 0 to size - 1, represented as an array of strings.
        The strings maps to object ids. Separate multiple objects with dashes. Use a
        single dash for an empty cell.

### Objects File

Objects are under an objects sub-block, and then an id block where the name of
the block is their id used in the human-readable map file. Objects need a name
property, which is how they are referred to in the code and logs. The rest of
the properties are mostly domain specific.

```
## <ignored> means that the value is ignored, key presence is used for "true"
## objects {
##    +<id> {
##       name = <name>;
##       *<p1> = <value>;                     # user property
##       *<p1> = [<value1>, <value2>];        # user property
##       ?apply.points = <int>;               # number of points to apply
##       ?apply.energy = <int>;               # amount of energy to apply
##       ?apply.energy.shields = <boolean>;   # condition for energy apply
##       ?apply.health = <int>;               # amount of health to apply
##       ?apply.health.shields-down = <boolean>; # condition for health apply
##       ?apply.missiles = <int>;             # number of missiles to apply
##       ?apply.remove = <boolean>;           # remove on apply
##       ?box-id = <int>;                     # this box's id number (set after load)
##       ?apply.reward-info = <boolean>;      # contains reward information
##       ?apply.reward-info.positive-id = <int>; # correct box id (set after load)
##       ?apply.reward = <boolean>;           # is reward box
##       ?apply.reward.correct = <boolean>;   # is the correct box (set randomly after load)
##       ?apply.reward.positive = <int>;      # reward if correct
##       ?apply.reward.negative = <int>;      # "reward" if incorrect, different from wrong box
##       ?apply.reset = <boolean>;            # reset sim on apply
##       ?apply.properties {                  # these get moved to top level on applyProperties call
##          ?<p1> = <value>;                  # user apply property
##          ?<p1> = [<value1>, <value2>];     # user apply property
##       }
##       ?update.decay = <int>;               # decay apply.points by this amount on update
##       ?update.fly-missile = <int>;         # increment update.fly-missile phase on update
##       ?update.linger = <int>;              # decrement update.linger on update, remove at 0
##    }
#}
```
