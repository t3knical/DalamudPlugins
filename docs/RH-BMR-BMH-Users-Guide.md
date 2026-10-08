# Beastmaster + Crucible: User Guide

How **Beast Master Helper (BMH)**, **BossMod Reborn Tekz (BMR)** and **Reaction Helper (RH)** fit together, what each one does, how to
set them up, and what is finished and what still needs work.

> **Status words used below**
> **Works** = built and used in real runs. **Needs testing** = built, but not confirmed in the game yet (most of what changed in the last
> round is here - it says so). **Not built** = planned or asked for, not there.
> This guide was written on 2026-10-07 from the current code. If something in the game disagrees with it, the game is right - please report it.

---

## 1. The three plugins in one minute

| Plugin | Command | Its job |
|---|---|---|
| **Beast Master Helper** | `/bmh` | Plays the Beastmaster for you (rotation, familiars, Shield Charge, capture) and runs the Crucible of the Unbroken menus: entry, teams, shops, items, treasure, campsites. |
| **BossMod Reborn Tekz** | `/bmr` | A fork of BossMod Reborn with extra **Crucible fight modules**: it draws the telegraphs, steers the AI around them and tells BMH about interrupts, dispels, tank busters and raidwides. |
| **Reaction Helper** | `/rhr` | Runs each fight from a **timeline profile**: it flips BMH's switches at the right moments, summons the right familiar, targets in order, and presses the borrowed ability (Soul Crush, a defensive skin...). |

How they talk: BMH owns the rotation and exposes its **switches** (AoE, Cooldowns, Gap close, Borrow, Tempered Release, ...). BMR sees the fight
(telegraphs, predicted tank busters/raidwides) and moves/aims. RH knows the *plan* for each fight and uses BMH's switches and BMR's predictions
to carry it out. You can run BMH alone; BMR and RH make the Crucible fights work properly.

**Recommended set-up for the Crucible:** BMH + BMR Tekz + RH, all three from this repository.

---

## 2. Installing and first run

1. Add the repository URL (see the main README), then install the three plugins from `/xlplugins`.
2. **BMR Tekz replaces BossMod Reborn** - do not run both. In BMR's settings set the modules setting to **WIP** (the Crucible modules are marked WIP).
3. BMH: type `/bmh`. Optional helpers: **vnavmesh** (walking inside zones) and **Lifestream** (teleports). Without them BMH still tracks everything but cannot walk you anywhere.
4. RH: type `/rhr`. The shipped Crucible timelines and profiles install themselves when the plugin starts. A profile only runs if its timeline is the fight you are in.
5. In BMH > *Crucible Board(s) Options*, tick **Let Reaction Helper run this fight** for fights RH has a profile for, so BMH does not also plan them.

---

## 3. Beast Master Helper

### 3.1 The rotation

Switch **AI Assist** on and BMH presses the next best action on the target *you* selected. It never picks targets. It scales to your level.

**The switches** (all in the Rotation / Familiar overlay windows, and in *Rotation Stuff > Settings*). Reaction Helper can flip any of them.

| Switch | What it does |
|---|---|
| AI Assist | The master switch: the rotation plays for you. |
| Capture | Capture beasts you still need once they are under the HP threshold. |
| AoE | Area actions once enough enemies are clustered on the target. |
| Opener | Run the opener from a standing start. |
| Cooldowns | Allows Rally, Rallying Cheer, Shield Charge and One with Nature. |
| Rally / Rallying Cheer | Spend Mastered / Natural Instinct (cooldowns must be on). |
| Power actions | Trick and the TP-spending axes. |
| Burn | Spend everything as it comes up instead of holding for the instinct wheel. There is also a slider: **Burn when the enemy is under X% HP**. |
| Auto-attack | On = normal. **Off = BMH switches the game's auto-attack off whenever it is running** (it checks every frame). |
| Gap close | Shield Charge to close on a target out of reach. |
| Charge AoE | Also use Shield Charge for AoE on a pack (off by default). |
| Trick waits TP | Hold Trick until your own TP is full. |
| Beast Mode / Wave in melee / Cloud Skim | The borrowed kinship action - see 3.2. |
| Auto-summon / Cycle / Kin order | Summon a familiar when none is out; swap them with Parting Blow; choose by kinship. |
| Keep Covered | Snarl upkeep so the familiar tanks for you (Challenge when off). |
| Cover me below HP % | Emergency cover (default 20%, 0 = off): when your HP is under it and a familiar is out, Snarl is pressed so the familiar takes the damage - whatever Keep Covered says and whatever Reaction Helper is doing. Set in *Options > Familiar Selection*. |
| Parting Blow / Need Vantage / Spend power | When the familiar may be sent away. |
| **Borrow / Tempered Release** | What the summon's *One with Nature* charge is spent on. See 3.2. |

### 3.2 Borrow, Tempered Release and the borrowed ability

Every summon gives one *One with Nature* charge. You choose **one**:

- **Tempered Release** - the familiar's own damage move. This is the default.
- **Borrow** - lends you the familiar's **kinship action** for ~60-90 s. The Beast Mode button becomes that action (Quelling Wave, Soul Crush, Scouring Ash, Beastskin/Scaleskin/Vileskin, Seedsower, Cloud Skim).

How BMH decides: **only by the two switches** (Borrow, Tempered Release). Both off = nothing is spent. Nothing else second-guesses them -
Reaction Helper flips them per fight. Borrow is meant to be used only where the strategy needs a specific kinship (an interrupt, a cleanse, a
dispel, a defensive for a tank buster) or when you are being hurt.

**The borrowed action is not pressed automatically** - except **Quelling Wave** (a ranged attack, used when the target is out of reach) and the
opt-in **Cloud Skim**. Soul Crush, the defensive skins, Scouring Ash and Seedsower are pressed by Reaction Helper profiles, because only the
profile knows *when* (the buster, the interrupt, the debuff).

### 3.3 The overlay windows

- **Main overlay** - status, familiar, gauge, next action. Click its header to start/stop, right-click for settings.
- **Rotation** and **Familiar** windows - grids of the switches above. **Actions** window - icons that ask the rotation to use an ability next, including **Sprint** and the **Gemdraught of Strength** potion (best grade in your bag, Grade 1-4): click once and it is used as soon as it can be.
- Everything is yours to arrange: in *Rotation Stuff > Settings > Quick Toggles / Hotbar* you can
  **drag a toggle (or action) up and down in the Keybinds list and the overlay follows**, move a toggle to the other window, hide its button
  (**Show Button**), turn it on/off (**Enabled**), give it a **key combination**, and change spacing, button height, text size and colours.

### 3.4 Crucible of the Unbroken

BMH can enter the Crucible (via Lauda), pick teams, and handle the board's menus.

| Feature | Status |
|---|---|
| Entry to a board, Recommended Team preview | Works (experimental) |
| **Suggested Team Mode** - the guide's team and plan per fight (Crucible Board(s) Options). Teams are editable, with a reset button. Each fight page now only *suggests* Borrow/Tempered per familiar; Reaction Helper does the switching | Works for the Second Master's Board; the other boards use the guide's teams with general behaviour |
| Level Up Beasts mode | Experimental |
| Shops, treasure choice, loot priority, healing items, feeding | Works (tuned over many runs); some rare cases still slip |
| Campsite handling (prefer the branch when hurt, check team HP) | Works, needs more live confirmation |
| Board loop (repeat a board) | Experimental |
| Keep Covered / Smart Snarl and Challenge | Works, with rough edges (below) |

### 3.5 Known gaps (BMH)

- **`??` card paths** are not handled yet. An "ignore the ?? paths" option is wanted, but needs the board layouts first.
- **Point farm mode** (skip items, tents etc. for the highest score, for resilience farming) and **staggered cover** (cover for N seconds instead of the whole fight) are **Not built**.
- Several things from the last update are **Needs testing**: the new settings tabs and drag-to-reorder, the auto-attack stop, Sprint, the Gemdraught potion, and "Borrow only lends".
- Kinship actions other than Quelling Wave depend on a Reaction Helper reaction; if a profile has none for a fight, that action simply is not used.

---

## 4. BossMod Reborn Tekz

### 4.1 What it is

The community BossMod Reborn with extra, hand-built **Crucible of the Unbroken** modules (all five boards) and a few interfaces for BMH and RH:
it reports interrupts, dispels, forbidden targets, tank busters and raidwides, and accepts hints back from Reaction Helper.

Use it for **Suggested Team Mode**. For the other team modes (arbitrary teams) the fork's modules cannot rely on the familiars they expect, and
the official BossMod Reborn may do just as well.

### 4.2 Which fights have modules

| Board | Modules |
|---|---|
| First Board | Bone Knight / Bone Bishop, Arch Demon, Banemite, Ogre, Pas de Seul, Piscodemon |
| Second Board | Manticore, Wyvern, Voidmancer, Taurus, Tablitaur, Loosefrox/Chewchum, Popoto and demon pieces |
| Third Board | Cavalier, Ymir + Sahagin, Catoblepas, Lakhamu, Siren (upstream's), Zu, Campeador, Guttler |
| First Master's Board | Strix, Treant, Gargoyle, Corpse Flower, Ice Dragon, Borgny, Golem, Administrator, Morbol, Progenitrix |
| Second Master's Board | Flauros, Drake, Durga, Gigantis, Sphinx, Lauda, King Ahriman, Atomos, Boogeyman, Chimera, Medusa, Mind Flayer |

All of these are marked **WIP**: they work in real runs but are still being tuned fight by fight. Where the Tekz fork and upstream both have a module
for the same boss, the better-tested one is used.

### 4.3 Recent changes (1.0.67.0)

- Merged 114 upstream commits (new numbered Crucible folders, upstream Third Board modules).
- **Catoblepas**: the Demonic Eye telegraphs no longer flicker and the AI dodges them (**Needs testing** - no replay of the fight to measure against yet).

### 4.4 Known gaps (BMR)

- Fights with no module yet, or only upstream's version, may have thinner AI steering.
- Catoblepas and the other fights tuned from only a few pulls are the least certain.

---

## 5. Reaction Helper

### 5.1 What it does

RH holds, for each fight, a **timeline** (what the boss does and when, recorded from real pulls) and a **profile** (what you should do about it).
A profile is a list of **reactions**: *when* (timeline point, a cast, a condition) + *if* (conditions) + *do* (actions: flip a BMH switch, press a skill, target
something, summon a familiar, set a variable, show an alert...). It also **records every pull** and can build new timelines from your own recordings.

### 5.2 What ships with it

- **29 recorded Crucible timelines** and **30 Beastmaster profiles** (all five boards). Third Board: Cavalier, Ymir, Catoblepas (1 pull only), Zu, Lakhamu, Siren, Guttler. **Campeador has neither yet.**
- The shared general profile *BST - Safe Familiar Cycling*.

### 5.3 The recipe every board profile follows

1. **Start of the fight: Gap close, Borrow and Tempered Release are switched OFF.**
2. **Turn a switch ON in the reaction that needs it.** Tempered Release is the **default**, decided once per summon (while *One with Nature* is up). Borrow is switched on only where the strategy asks for a kinship (a Soulkin interrupt, a cleanse, a dispel...) or when you are hurting (under 50% HP: Borrow a defensive kinship, then use it).
3. **Meteor waits**: Behemoth's Tempered Release (Meteor) is held until the enemies are together on Pas de Seul, Cavalier and Siren; Drake has its own Barbmole plan.
4. **The borrowed ability is pressed by a reaction**: Soul Crush on the named casts, and the defensive skin about 5 s before a tank buster / Scaleskin before a raidwide that **BossMod predicts**.
5. These are **plain switch changes**, so you can flip any switch by hand and RH will not fight you.

### 5.4 Building your own profile

See **How To Use RHR** (in the plugin folder / repository) for conditions, actions, recipes and debugging with replays. The short version:

1. Do the fight once with recording on (`/rhr record` or automatic) - RH saves the pull.
2. *Replays* tab: **Build Timeline** from one or more pulls of the fight.
3. Make a profile for that timeline and add reactions: start-of-fight OFF, switch ON when needed, press skills at casts.
4. Use the same pattern as 5.3 - it keeps profiles readable.

### 5.5 Known gaps (RH)

- Some switches are still *holds* that RH renews while a reaction matches (AutoSummon, Cycle, Keep Covered, Parting Blow, Rally and a few others) - they override your hand clicks while active. Converting them to plain on/off reactions is planned.
- Mitigation reactions rely on BossMod flagging the mechanic as a tank buster/raidwide; anything it does not flag needs a hand-written reaction.
- There are no reactions yet for Seedsower, and the Ashkin cleanse exists only in the profiles that already had one.
- Profiles are tuned from limited pulls and are **Needs testing** after the switch-pattern rewrite.

---

## 6. A typical Crucible run

1. Start with the **guide's team** (Suggested Team Mode) and enter the board with BMH.
2. BMR draws the fight's telegraphs and steers the AI; RH's timeline for that fight loads when the boss is present.
3. At the start RH switches Gap close/Borrow/Tempered OFF, summons the plan's opening familiar, and then decides Borrow or Tempered once per summon.
4. BMH plays the rotation; RH presses the borrowed ability when the plan calls for it; you can change any switch by hand at any time.

---

## 7. Troubleshooting

| Problem | Try |
|---|---|
| Nothing happens in a fight | Is **AI Assist** on? Is there a profile/timeline for this fight in `/rhr`? Is BMR's AI on (BMR > AI)? |
| Tempered Release / Borrow not used | Look at the two switches in the Familiar window; a Reaction Helper reaction may be holding both OFF on purpose (e.g. waiting for the enemies to gather). |
| The wrong timeline runs | One zone holds many fights; RH picks by the boss that is in combat. Check `/rhr` > the active timeline. |
| A switch keeps flipping back | A Reaction Helper hold is renewing it; see 5.5. |
| A Crucible menu step stalls | Turn on *Handle board windows* and send the diagnostics copy from the BMH Crucible page. |

**Reporting**: issues and feature requests go to https://github.com/t3knical/DalamudPlugins/issues. A replay file (`BossModRebornTekz\replays`) or an RH recording is the most useful thing to attach.

---

## 8. Roadmap (what still needs doing)

1. Test the last round of changes live: new BMH settings/drag-reorder, Auto-attack stop, Sprint, Potion, "Borrow only lends", the RH profile rewrite.
2. Campeador and the other unrecorded pieces: record, build timelines, add profiles.
3. `??` card paths: map the layouts, then add the ignore option.
4. Point-farm mode and staggered cover.
5. Convert RH's remaining holds to plain on/off reactions.
6. More Catoblepas pulls for BMR and the timeline.
