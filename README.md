# T3chnicalD3ath Plugin Repository

A third-party plugin repository for **[Dalamud](https://github.com/goatcorp/Dalamud)** (FINAL FANTASY XIV / XIVLauncher).

<p align="center">
  <a href="#installation"><img alt="Plugins" src="https://img.shields.io/badge/plugins-5-blue"></a>
  <a href="#installation"><img alt="API" src="https://img.shields.io/badge/Dalamud%20API-15-brightgreen"></a>
  <a href="CREDITS.md"><img alt="Credits" src="https://img.shields.io/badge/credits-attribution-orange"></a>
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
4. Press the **+** button, then **Save and Close**
5. Open `/xlplugins` — the plugins below will now appear in the installer

---

## Plugins

### Hunter v2
Automatically hunts mobs to farm specific items. Teleports to the right zone, mounts
and flies to spawn points, engages and chains kills, tracks your inventory live, and
heads home once every item is complete.

- Organise items into **hunt lists** you can toggle on and off
- **Import from Artisan** — pulls a crafting list's ingredients, keeping only the ones
  that actually drop from mobs
- Edit the mob database in game: spawn points, loot tables and zones
- Compact overlay showing live status and progress

> **Requires** [vnavmesh](https://github.com/awgil/ffxiv_navmesh), Rotation Solver Reborn
> and [Lifestream](https://github.com/NightmareXIV/Lifestream).
> [Artisan](https://github.com/PunishXIV/Artisan) is optional, for ingredient import.

### Party Monitor
Watches your party and reports changes — members joining and leaving, with optional
FFLogs lookups and Discord relay.

> Discord and FFLogs integration are **optional** and require your own credentials,
> entered in the plugin's settings. Nothing is bundled with or sent through this
> repository.

### Party Recruitment Helper
Saves your Party Finder slot layouts and automatically reapplies them when members
leave — no more reconfiguring slots after every join.

### PingPlugin
A ping display for Dalamud. Unofficial fork kept building against current API levels.
Original by **[karashiiro](https://github.com/karashiiro)**.

### Teleporter
Chat commands for teleporting by name — `/tp Quarrymill`, `/tpm South Shroud`, with
aliases like `/tp home`. Unofficial fork kept building against current API levels.
Original by **[pohky](https://github.com/pohky)**.

---

## Attribution

**PingPlugin** and **Teleporter** are unofficial forks of other developers' work,
redistributed only to keep builds current with Dalamud API levels. All original credit
belongs to their authors, and karashiiro's MIT licence travels with the plugin.

Full details in **[CREDITS.md](CREDITS.md)**. If you authored one of these and would
like it removed, open an issue and it will be taken down.

---

## Support

Found a bug or have a request? [Open an issue](https://github.com/t3knical/DalamudPlugins/issues).

For issues with the **forked** plugins, please check whether the problem also exists
upstream before reporting it here.

---

<sub>Not affiliated with SQUARE ENIX. FINAL FANTASY is a registered trademark of Square Enix Holdings Co., Ltd.</sub>
