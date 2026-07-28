# Credits & Acknowledgements

## Original plugins

Written and maintained by **T3chnicalD3ath Inc.**:

- Hunter
- Party Monitor
- Party Recruitment Helper

---

## Forked plugins

### PingWatcher — forked from PingPlugin by [karashiiro](https://github.com/karashiiro)

- **Original project:** https://github.com/karashiiro/PingPlugin
- **Licence:** MIT — Copyright (c) 2020 karashiiro
- **Full licence text:** [`licenses/PingWatcher-LICENSE`](licenses/PingWatcher-LICENSE)
- **Why the fork exists:** it adds game-server address detection that works under
  Linux/Wine, where the standard client-state method does not resolve an address.
- **Why the rename:** Dalamud does not allow a third-party repository to shadow a
  plugin published in the official repository, and PingPlugin is available there.
  Distributing under a distinct name keeps both installable side by side.

The MIT licence permits redistribution and modification provided the copyright notice
and licence text travel with the software; both are preserved here. All credit for the
plugin belongs to karashiiro.

**On Windows, install the official PingPlugin instead** — it is maintained by its
author and stays more current than this fork.

---

## Acknowledgements

**Hunter** takes design inspiration from
[GatherBuddyReborn](https://github.com/FFXIV-CombatReborn/GatherBuddyReborn) — its
movement and mount-handling patterns, and its list-management UI conventions. No
GatherBuddyReborn code is redistributed here.

---

## Runtime dependencies

Hunter talks to these plugins over IPC or chat commands. It does not bundle them —
install them separately:

- [vnavmesh](https://github.com/awgil/ffxiv_navmesh) — pathfinding
- Rotation Solver Reborn — combat rotations
- [Lifestream](https://github.com/NightmareXIV/Lifestream) — teleports
- [Artisan](https://github.com/PunishXIV/Artisan) — optional, for crafting-list import

---

## Removals

This repository previously distributed a fork of
[TeleporterPlugin](https://github.com/pohky/TeleporterPlugin) (pohky). It was removed:
the author keeps it current, it is available in the official repository, and the
upstream project ships no licence file granting redistribution. Install it from the
official Dalamud repository instead.
