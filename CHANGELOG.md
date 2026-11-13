# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.8.0] - 2026-11-13

### Added

- Update code and estimates for Classic Era (1.15.9).
- Convert previous Classic Era data when opening the continent's flight map.

### Changed

- `/ftc mute` sets the login message and the flight report separately (`login`, `report`, `all`, `none`). A saved on/off mute becomes both settings.
- Route estimates prefer historic dataset times. A direct flight those records do not contain is still estimated from the path length. When game specific direct path estimates differ by more than 2 seconds, the path estimate is used.

### Fixed

- Known long flights are no longer too high. Before, takeoff and landing at every flight master was part of the estimate, which, for example, increased routes only passing by Ironforge by 40 seconds.
- Ratchet and Marshal's Refuge keep no single time. Alliance and Horde fly different routes there, so the timer adds the stops of the route being flown.

## [0.7.0] - 2026-11-11

### Added

- Support for WoW Forever!
- Estimated times for direct routes, from the flight path length. A route with stops adds those legs until a character has flown the whole route.
- Frequent Flier support. Saved times stay the duration without the perk, and a character who has it sees the shorter time.
- Player-facing text follows the client language: English, German, Spanish, French, Italian, Korean, Portuguese, Russian, Simplified Chinese, and Traditional Chinese. A missing line stays English. The addon name and `/ftc` stay as they are.

### Changed

- Targets WoW Forever (16001) and Classic Era (11509). Forever estimates live in DataForever.lua.
- Routes are stored and looked up by flight-master node id, for both factions. On Forever, a 0.6 save is left unused.
- The flight map tooltip says "Estimated time" or "Recorded time".
- The clock starts when the character is on the taxi, not when the flight master is clicked.
- `/ftc show` shows a static placeholder time.
- Chat tag is [FTC]. Command replies name the command that reverses them.
- Login message is "Ready." and points at `/ftc help`.
- Shift-click the timer while typing to paste an arrival line. An overdue timer says it is landing any second.

### Fixed

- Hiding the timer box still records the flight, before liftoff and after. Takeoff and landing share one ticker. A slow connection has 10 seconds to start the taxi.
- Declining a battleground no longer throws away the flight in progress.

### Removed

- The debug window that listed flight-map node positions.

## [0.6.1] - 2023-08-27

### Changed

- Bumped Interface Version
- Changed beta to release

## [0.6.0] - 2022-01-10

### Added

- Horde Data (thanks to Nezzie-Shadowstrike)
- User Contributed Data (thanks to Excid-Kingsfall)
- Auto GitHub to CurseForge Deployment (thanks to [bison92](https://github.com/bison92))

## [0.5.1] - 2021-12-19

### Fixed

- AddOn now initializes correctly for Horde

## [0.5.0] - 2021-12-09

### Added

- Preserve frame position across logins
- Cancel timer upon summoning, entering battleground and early flight canceling
- new commands: `/ftc mute`, `/ftc show`, `/ftc hide`

## [0.4.0] - 2021-12-08

### Changed

- Better slash commands

## [0.3.0] - 2021-12-08

- Initial version
