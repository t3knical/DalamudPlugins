# Credits & Acknowledgements

All plugins in this repository are written and maintained by **T3chnicalD3ath Inc.**:

- Hunter v2
- Party Monitor
- Party Recruitment Helper

---

## Acknowledgements

**Hunter v2** takes design inspiration from
[GatherBuddyReborn](https://github.com/FFXIV-CombatReborn/GatherBuddyReborn) — its
movement and mount-handling patterns, and its list-management UI conventions. No
GatherBuddyReborn code is redistributed here.

---

## Runtime dependencies

Hunter v2 talks to these plugins over IPC or chat commands. It does not bundle them —
install them separately:

- [vnavmesh](https://github.com/awgil/ffxiv_navmesh) — pathfinding
- Rotation Solver Reborn — combat rotations
- [Lifestream](https://github.com/NightmareXIV/Lifestream) — teleports
- [Artisan](https://github.com/PunishXIV/Artisan) — optional, for crafting-list import

---

## A note on forks

This repository previously distributed unofficial forks of
[PingPlugin](https://github.com/karashiiro/PingPlugin) (karashiiro) and
[TeleporterPlugin](https://github.com/pohky/TeleporterPlugin) (pohky). Both have been
removed — their original authors keep them current, and Dalamud rightly prevents
third-party repositories from shadowing plugins available in the official repository.

Please install those from the official Dalamud plugin repository instead. All credit
for them belongs to their respective authors.
