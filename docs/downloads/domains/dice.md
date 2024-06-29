---
Tags: 
    - environments
    - liar's dice
    - reinforcement learning
---

# Dice

Dice is a java implementation of a game often called *Liar's Dice*.

Here is an abbreviated description of the rules used in our implementation of
this domain:

*   Each player gets five six-sided dice and a cup to conceal their dice from
other players.
*   To begin each round, all players roll their dice under their cups and look
at their new 'hand' while keeping it concealed from the other players. The first
player begins bidding, picking a quantity of a face number. The quantity states
the player's opinion on how many of the chosen face have been rolled in total on
the table.
*   Each player has two choices during his turn: make a higher bid, or challenge
the previous bid as being wrong. Raising the bid means either increasing the
quantity, or the face value, or both, according to the specific bidding rules used.
*   The 1s ("aces") are wild and count as two in a bid, for example to outbid a
bid of 2 one's, you must bid at least 5 of a non-wild face.
*   If the current player thinks the previous player's bid is wrong, he
challenges it, and then all dice are revealed to determine whether the bid was
valid. If the number of the relevant face revealed is at least as high as the
bid, then the bid is valid, in which case the bidder wins. Otherwise, the
challenger wins.

\* Description of game rules derived from its [Wikipedia page](
https://en.wikipedia.org/wiki/Liar%27s_dice)
and is released under the [Creative Commons license](http://creativecommons.org/licenses/by-sa/3.0/).

## Environment Properties

*   Uncertainty
*   incomplete knowledge
*   multi-player

## Download Links

[Dice.zip](https://github.com/SoarGroup/website-downloads/raw/main/Domains/Dice.zip)

## Associated Agents

A variety of agents is included in the environment download.

## Documentation

*   Requires these jars on the classpath:
    *   sml.jar
    *   soar-qna-9.3.1.jar
    *   soar-smljava-9.3.1.jar

*   Also needs the environment variables `SOAR_HOME` set and `LD_LIBRARY_PATH` on
Linux (`DYLD_LIBRARY_PATH` on OSX, `PATH` on Windows) set to `$SOAR_HOME/lib`.

*   To import into Eclipse, go to File > New > Java Project, un-check "Use Default
Location" and under "Location" select the root directory of the project. All
other default settings should be fine.

*   To run, right-click on the SoarMatch?.java file and select Run As > Java Application.

### IO link Specification

#### Code

```plaintext
input-link
        dice-probability
                id (any) copied from request
                probability (float) (0..1)

output-link
        compute-dice-probability
                id (any) user-data to be copied to input-link to correlate result
                number-of-dice (int) (1..)
                number-of-faces (int) (1..) usually 3 (normal, ones wild) or 6 (ones or special rules)
                count (int) (1..number-of-dice) Target number
                predicate (string) (eq ne ge gt le lt)

Predicate shorthand:
        eq: equal ==
        ne: not equal !=
        ge: greater than or equal >=
        gt: greater than >
        le: less than or equal <=
        lt: less than <
```

#### Examples

```text
id: 1, number-of-dice: 3, number-of-faces: 6, count: 2, predicate: eq
yields: id: 1, probability: 0.06944

id: 2.0, number-of-dice: 5, number-of-faces: 3, count: 3, predicate: ge
yields: id: 2.0, probability: 0.20988

id: charlie, number-of-dice: 24, number-of-faces: 6, count: 6, predicate lt
yields: id: charlie, probability: 0.80047

Quick test using add-wme on empty agent:
aw i3 compute-dice-probability *
aw i4 id 1
aw i4 number-of-dice 5
aw i4 number-of-faces 3
aw i4 count 3
aw i4 predicate ge
```

## Associated Publications

Pending

## Developer

Miller Tinkerhess

## Soar Versions

Soar 9

## Language

Java
