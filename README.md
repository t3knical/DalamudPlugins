# T3chnicalD3ath Plugin Repository

A third-party plugin repository for **[Dalamud](https://github.com/goatcorp/Dalamud)** (FINAL FANTASY XIV / XIVLauncher).

<p align="center">
  <img alt="Plugins" src="https://img.shields.io/badge/plugins-5-blue">
  <img alt="API" src="https://img.shields.io/badge/Dalamud%20API-15-brightgreen">
  <img alt="License" src="https://img.shields.io/badge/license-see%20CREDITS-lightgrey">
</p>

---

## Installation

Copy this URL:

```
https://raw.githubusercontent.com/t3knical/DalamudPlugins/main/repo.json
```

Then, in game:

1. Type `/xlsettings` to open the Dalamud settings
2. Go to the **Experimental** tab
3. Paste the URL into an empty row under **Custom Plugin Repositories**
4. Press **+**, then **Save and Close**
5. Open `/xlplugins` and install from the list

---

## At a glance

| | Plugin | What it does | Command |
|:--:|---|---|---|
| <img src="plugins/HunterV2/icon.png" width="46"> | **Hunter** | Farms mob-drop items automatically, end to end | `/htr` |
| <img src="plugins/OccultHelper/icon.png" width="46"> | **Occult Helper** | Automates Occult Crescent — treasure hunts, FATEs/CEs, Illegal Mode | `/och` |
| <img src="plugins/PartyMonitor/icon.png" width="46"> | **Party Monitor** | Watches party changes, relays them to Discord | `/pm` |
| <img src="plugins/PartyRecruitmentHelper/icon.png" width="46"> | **Party Recruitment Helper** | Saves and re-applies Party Finder slot layouts | `/prh` |
| <img src="plugins/PingWatcher/icon.png" width="46"> | **PingWatcher** | Latency display that works on Linux/Wine | `/pwr` |

---

## <img src="plugins/HunterV2/icon.png" width="34" alt=""> Hunter

Point it at the items you need and it does the rest — teleports to the right zone,
mounts up, flies to spawn points, fights, chains kills, tracks your inventory, and
heads home when everything is done.

**Hunt lists.** Items live in named lists you can toggle on and off, like
GatherBuddyReborn's auto-gather lists. Build one per project ("Cooking mats", "GC
turn-ins") and switch between them instead of retyping entries. List order is priority
order, and lists reorder by drag and drop. When an item drops from more than one mob, the
**Found in** column turns into a picker so you can pin it to the mob — and therefore the
zone — you'd rather farm it from.

**Import from Artisan.** Pull a crafting list's full ingredient totals straight from
[Artisan](https://github.com/PunishXIV/Artisan). Only ingredients that actually drop
from mobs in the database are added — gatherables and vendor items are skipped and
reported, since those belong to GatherBuddy or a vendor run.

**Editable mob database.** Add or edit mobs entirely in game: base ID, zone, loot table
and spawn coordinates. The *Add current position* button captures wherever you're
standing, so building a patrol route is stand → click → repeat. Stored as `mobs.json`
in the plugin config folder, so it survives updates.

**Loot learning — the database grows itself.** Turn on *Learn drops from kills* in the
**Loot Learner** tab and Hunter watches what you actually loot. It snapshots your bags
when a fight starts, snapshots them again a couple of seconds after the mob dies, and
credits anything that went **up in quantity** to that mob — so an item you already own a
stack of still registers.

- **Known mob, new item** → the item is appended to that mob's loot table.
- **Unknown mob** → the entry is created for you, seeded with its base ID, zone and the
  spot it died at.

It works from **manual kills**; auto-hunt does not have to be running, which is the point
— the bot can only route to mobs it already knows, so discovery has to happen while
*you* are the one fighting. Only your own bags are watched, so retainer and saddlebag
movement can't be mistaken for a drop.

Everything it learns is listed in the session log on that tab, with an **Undo** button per
row. That matters, because anything you pick up in the seconds after a kill gets credited
to it — a gathering node, a desynth, or a party member's trade landing in that window can
teach it something wrong. Live diagnostics (baseline held, current watch target, awaiting
loot) are on the **Debug** tab.

**Stays out of other players' way.** If someone is already fighting at the spawn Hunter is
heading for, it backs off, marks that spawn as taken for a few minutes, and goes and works
a different item on your list instead of competing for their kills. It comes back later. A
fight already in progress is never abandoned, and party members don't count as competition.
Radius and cooldown are tunable in *Config → Sharing the World*.

**Smart travel.** Movement is a port of GatherBuddyReborn's system — vnavmesh over IPC,
real mount actions rather than simulated keypresses, and flight decided by your actual
aether-current completion per zone. Because mobs *move*, the bot snapshots a target's
position when it commits to flying, flies to that fixed point without re-pathing
mid-air, lands, and only then chases on the ground.

**Live overlay.** A compact always-on-top window showing state, per-item progress with
item icons, and the current target. Click the header to start/stop, right-click to open
the main window, click any item to toggle it. It hides itself while no list or item is
enabled and reappears the moment you enable one, so it isn't sitting on your screen doing
nothing (switchable in *Config → Overlay*).

> **Requires** [vnavmesh](https://github.com/awgil/ffxiv_navmesh) (pathfinding),
> Rotation Solver Reborn (combat) and
> [Lifestream](https://github.com/NightmareXIV/Lifestream) (teleports).
> [Artisan](https://github.com/PunishXIV/Artisan) is optional, for ingredient import.

---

## <img src="plugins/OccultHelper/icon.png" width="34" alt=""> Occult Helper

Automates the grind in **Occult Crescent** (Cosmic Exploration): routes treasure, pot, and carrot
hunts end to end, tracks FATEs and Critical Encounters with a panel that tells you what they reward
and pathfinds you there, and includes an "Illegal Mode" autopilot for when you'd rather not touch any
of it yourself.

**Hunt routing.** Treasure, pot-chest, and carrot hunts all get real route optimization rather than
"walk to the nearest thing" — 2-opt/Or-opt passes, 3D distance, and resumable progress if you get
interrupted mid-run.

**FATE/CE panel.** Shows what's active, what it rewards, and can path you straight to it.

**Illegal Mode.** A more hands-off autopilot layered on top of the CE/FATE core — parking, targeting,
reachability gating, and countdown tracking.

**Status overlay.** A small always-on-top popout with live per-mode sections (world state, AI status,
chest/carrot hunt progress) so you don't need the main window open.

**Currency & experience trackers**, gearset/Phantom Job presets per activity, and a config UI with
tabbed sections.

> An unofficial fork of [OccultHelper](https://github.com/OhKannaDuh/OccultHelper) by
> **[OhKannaDuh](https://github.com/OhKannaDuh)**, redistributed under the GNU AGPLv3. All credit for
> the original project goes to them; this fork carries ongoing maintenance and new features on top.

---

## <img src="plugins/PartyMonitor/icon.png" width="34" alt=""> Party Monitor

Keeps an eye on your party and tells you when it changes — members joining, members
leaving — so you notice a quiet departure without staring at the party list.

**Discord relay.** Optionally forward party activity to Discord, either through a simple
**webhook** or a full **bot token** if you want richer behaviour.

**Remote commands.** With a bot configured, you can enable remote commands and drive
simple actions (such as `/leave`) from Discord instead of alt-tabbing back into the
game.

**FFLogs lookups.** Supply your own FFLogs client ID and secret to pull encounter data
for party members.

**Tunable.** Set the zone it watches and how often it refreshes.

#### Why it ships with a helper process (TempScraper)

Party Monitor pulls raid progression from **[Tomestone.gg](https://tomestone.gg)**, which
renders its character pages with JavaScript. A plain HTTP request returns an empty
shell, so the data has to be read from a real browser engine. That work is done by
**TempScraper**, a small console program bundled at `TempScraper/` inside the plugin.

It runs as a **separate process** rather than inside the plugin for three reasons:

- **The game thread stays responsive.** Browser automation is slow and blocking;
  running it in-process would stutter FFXIV every time a party member was looked up.
- **A hung or crashed scrape can't take the game with it.** The worst case is a dead
  child process, which the plugin simply restarts.
- **Selenium's dependencies don't belong in the game.** Loading a browser-automation
  stack into the FFXIV process is a much larger surface than launching a sandboxed
  child.

It is fed lookups over stdin and keeps its browser warm between them, so checking a full
party is a series of requests against one session rather than a cold start per person.
The browser is treated as **disposable**: nothing launches until you actually use the
feature, it is recycled every so many lookups, and it shuts down completely once idle,
restarting on demand. A long-lived headless Chrome on a JavaScript-heavy page will
otherwise grow without bound — it was reaching multiple gigabytes before this.

> **Privacy and credentials:** Discord and FFLogs integration are entirely optional and
> require *your own* credentials, entered in the plugin's settings. They are stored in
> your local Dalamud config and passed to TempScraper through environment variables —
> never compiled into the binaries, never written to the command line, and never
> included in this repository. Diagnostic logging is off unless you set
> `PARTYMONITOR_DEBUG`, and writes to your temp folder when enabled.

---

## <img src="plugins/PartyRecruitmentHelper/icon.png" width="34" alt=""> Party Recruitment Helper

Recruiting in Party Finder means rebuilding the same slot layout every time somebody
joins and leaves. This saves that layout and puts it back for you.

**Status at a glance.** The first tab tells you in plain words what is going to happen —
whether the recruitment window is open, how many slots are filled, which preset is active,
and what the last auto-reapply actually did. One button applies the active preset.

**Presets.** A searchable list on the left, the editor on the right. Right-click any
preset to set it active, apply it, rename, duplicate or delete it. A preset stores the
whole listing: duty and category, objective, description, minimum item level, completion
status, one-player-per-job, and which jobs each of the eight slots accepts — captured
straight from the game's own Recruitment Criteria window.

**Auto-reapply.** When a member leaves, the game reverts your listing to open slots. This
puts the layout straight back, so you keep recruiting the roles you actually want. By
default it restores just the slots and leaves your criteria alone — there's an option to
re-apply the whole preset instead.

**Timing control.** It drives the game's real dropdowns, so it has to pace itself. Raise
the role-select delay if slots come out half-applied on your machine.

> Everything happens through the game's own Party Finder window — no network calls, and
> presets stay in the plugin's config folder.

---

## <img src="plugins/PingWatcher/icon.png" width="34" alt=""> PingWatcher

Shows your connection latency in the server info bar, with an optional live graph and
monitor window.

| Command | Does |
|---|---|
| `/ping` (`/pwr`) | Toggle the ping display |
| `/pinggraph` | Toggle the latency graph |
| `/pingconfig` | Open settings |

**Why this fork exists:** it adds game-server address detection that works under
**Linux / Wine**, where the standard client-state method fails to resolve an address and
the ping display stays empty.

> An unofficial fork of [PingPlugin](https://github.com/karashiiro/PingPlugin) by
> **[karashiiro](https://github.com/karashiiro)**, redistributed under the MIT License.
> All original credit goes to them.
>
> **Playing on Windows? Install the official PingPlugin instead** — it is maintained by
> its author and stays more current than this fork.

---

## Attribution

**PingWatcher** and **Occult Helper** are forks of other developers' work. Original credit for
PingWatcher belongs to karashiiro (MIT, [`licenses/PingWatcher-LICENSE`](licenses/PingWatcher-LICENSE)),
and for Occult Helper to OhKannaDuh (AGPLv3, [`licenses/OccultHelper-LICENSE`](licenses/OccultHelper-LICENSE)).

See **[CREDITS.md](CREDITS.md)** for full acknowledgements, including the projects that
inspired Hunter. If you authored something here and would like it removed, open an
issue and it will be taken down.

---

## Support

Found a bug or have a request? [Open an issue](https://github.com/t3knical/DalamudPlugins/issues).

For **PingWatcher** or **Occult Helper**, please check whether the problem also happens with the
upstream project before reporting it here.

---

<sub>Not affiliated with SQUARE ENIX. FINAL FANTASY is a registered trademark of Square Enix Holdings Co., Ltd.</sub>
