# Credits & Attribution

This repository distributes both original plugins and unofficial forks of other
developers' work. The forks exist only to keep builds current with Dalamud API
levels — **all original credit belongs to the authors listed below.**

If you are one of these authors and would like your plugin removed from this
repository, open an issue and it will be taken down.

---

## Forked plugins

### PingPlugin — by [karashiiro](https://github.com/karashiiro)

- **Original project:** https://github.com/karashiiro/PingPlugin
- **Licence:** MIT — Copyright (c) 2020 karashiiro
- **Full licence text:** [`licenses/PingPlugin-LICENSE`](licenses/PingPlugin-LICENSE)
- **What changed in this fork:** rebuilt against the current Dalamud API level.
  No functional rewrites.

The MIT licence permits redistribution provided the copyright notice and licence
text travel with the software; both are preserved in this repository.

### Teleporter — by [pohky](https://github.com/pohky)

- **Original project:** https://github.com/pohky/TeleporterPlugin
- **What changed in this fork:** rebuilt against the current Dalamud API level.
- **Licence:** the upstream repository does not ship a licence file. This fork is
  redistributed as a convenience build; if the author objects it will be removed
  immediately.

---

## Original plugins

The following are written and maintained by **T3chnicalD3ath Inc.**:

- Hunter v2
- Party Monitor
- Party Recruitment Helper

**Hunter v2** additionally takes design inspiration from
[GatherBuddyReborn](https://github.com/FFXIV-CombatReborn/GatherBuddyReborn)
(movement/mount handling patterns and list-management UI conventions). No
GatherBuddyReborn code is redistributed here.

---

## Runtime dependencies

Hunter v2 talks to these plugins over IPC or chat commands; it does not bundle them:

- [vnavmesh](https://github.com/awgil/ffxiv_navmesh) — pathfinding
- Rotation Solver Reborn — combat rotations
- [Lifestream](https://github.com/NightmareXIV/Lifestream) — teleports
- [Artisan](https://github.com/PunishXIV/Artisan) — optional crafting-list import
