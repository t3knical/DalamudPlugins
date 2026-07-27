# T3chnicalD3ath Plugin Repository

A third-party plugin repository for **[Dalamud](https://github.com/goatcorp/Dalamud)** (FINAL FANTASY XIV / XIVLauncher).

<p align="center">
  <a href="#installation"><img alt="Plugins" src="https://img.shields.io/badge/plugins-4-blue"></a>
  <a href="#installation"><img alt="API" src="https://img.shields.io/badge/Dalamud%20API-15-brightgreen"></a>
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

### PingWatcher
Shows your connection latency in the server info bar, with an optional graph and
monitor window.

**Why this one:** it adds address detection that works under **Linux/Wine**, where the
standard client-state method fails to resolve the game server address.

> An unofficial fork of [PingPlugin](https://github.com/karashiiro/PingPlugin) by
> **[karashiiro](https://github.com/karashiiro)**, redistributed under the MIT License.
> All original credit goes to them. If you play on Windows, the official PingPlugin is
> the better choice — install that instead.

---

## Attribution

**PingWatcher** is a fork of another developer's work. Original credit belongs to
karashiiro, and their MIT licence ships with the plugin
([`licenses/PingWatcher-LICENSE`](licenses/PingWatcher-LICENSE)).

See **[CREDITS.md](CREDITS.md)** for full acknowledgements. If you authored something
here and would like it removed, open an issue and it will be taken down.

---

## Support

Found a bug or have a request? [Open an issue](https://github.com/t3knical/DalamudPlugins/issues).

---

<sub>Not affiliated with SQUARE ENIX. FINAL FANTASY is a registered trademark of Square Enix Holdings Co., Ltd.</sub>
