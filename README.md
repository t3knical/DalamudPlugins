# T3chnicalD3ath Dalamud Plugin Repository

A third-party plugin repository for [Dalamud](https://github.com/goatcorp/Dalamud) (FFXIV / XIVLauncher).

## Installation

1. In game, open the Dalamud settings: `/xlsettings`
2. Go to **Experimental**
3. Under **Custom Plugin Repositories**, paste this URL into an empty row:

```
https://raw.githubusercontent.com/t3knical/DalamudPlugins/main/repo.json
```

4. Click the **+** button, then **Save and Close**
5. Open the plugin installer (`/xlplugins`) — the plugins below will appear in the list

---

## Plugins

| Plugin | What it does | Author |
|---|---|---|
| **Hunter v2** | Automatically hunts mobs to farm specific items — teleports, flies to spawns, fights, chains kills, tracks inventory, goes home when done. Supports hunt lists and Artisan ingredient import. | T3chnicalD3ath |
| **Party Monitor** | Monitors party joins/leaves, with optional FFLogs lookups and Discord relay. | T3chnicalD3ath |
| **Party Recruitment Helper** | Saves Party Finder slot layouts and auto-reapplies them when members leave. | T3chnicalD3ath |
| **PingPlugin** | Ping display. Unofficial fork kept current with the Dalamud API. | [karashiiro](https://github.com/karashiiro) |
| **Teleporter** | `/tp` chat commands to teleport to aetherytes by name. Unofficial fork kept current with the Dalamud API. | [pohky](https://github.com/pohky) |

Two of these are **forks of other developers' plugins**, redistributed to keep
builds working with current Dalamud API levels. See [CREDITS.md](CREDITS.md) for
full attribution and licences.

### Hunter v2 requirements

Hunter v2 drives other plugins and needs these installed and enabled:
[vnavmesh](https://github.com/awgil/ffxiv_navmesh) (pathfinding), Rotation Solver
Reborn (combat), and [Lifestream](https://github.com/NightmareXIV/Lifestream)
(teleports). [Artisan](https://github.com/PunishXIV/Artisan) is optional, for
importing crafting-list ingredients.

### Party Monitor privacy note

Discord and FFLogs integration are **optional** and require you to enter your own
credentials in the plugin's settings. Those are stored in your local Dalamud
plugin config and are never bundled with, or transmitted through, this repository.

---

## Repository layout

```
repo.json                     the plugin master list Dalamud reads
plugins/<InternalName>/
  latest.zip                  the packaged plugin
  <InternalName>.json         its resolved manifest
licenses/                     upstream licences for forked plugins
tools/
  plugins.json                maps each plugin to its source project
  Update-Repo.ps1             builds, packages and regenerates repo.json
CREDITS.md                    attribution for forks and inspirations
```

Plugin **source** is not stored here — this repo only distributes builds. That
keeps the forks pointed at their upstream remotes so they can still pull changes
from the original authors.

---

## Publishing an update (maintainer)

From the repo root:

```powershell
# Build, package and regenerate repo.json for every plugin
.\tools\Update-Repo.ps1

# ...or just one
.\tools\Update-Repo.ps1 -Plugin Hunter

# Reuse existing build output instead of rebuilding
.\tools\Update-Repo.ps1 -NoBuild

git add -A
git commit -m "Update plugins"
git push
```

Dalamud picks up the new version the next time it refreshes the repository.

**Bump the version first.** Dalamud only offers an update when `AssemblyVersion`
increases, so raise `<AssemblyVersion>`/`<Version>` in the plugin's `.csproj`
before publishing.

### The safety gate

`Update-Repo.ps1` refuses to publish a zip that contains `.pdb` files, `.env` or
`*.local.json` files, credential-shaped JSON values (tokens, secrets, passwords,
webhook URLs), or absolute `C:\Users\...` paths. If a plugin is blocked, it is
skipped and reported rather than published. Builds also run with
`ContinuousIntegrationBuild=true` so local directory names are not embedded in the
compiled assemblies.

Adding a new plugin is just a new entry in [`tools/plugins.json`](tools/plugins.json)
pointing at its `.csproj`.
