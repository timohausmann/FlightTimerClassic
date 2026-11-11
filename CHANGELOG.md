# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Estimated times for direct routes, from the flight path length. A route with stops adds those legs until this character has flown the whole route.
- Frequent Flier support. Saved times stay the duration without the perk, and a character who has it sees the shorter time.

### Changed
- Targets the WoW Forever interface (16001). 
- Routes are stored and looked up by flight-master node id, for both factions. Saved times from 0.6 are not reused.
- The flight map tooltip says "Estimated time" or "Recorded time".
- The clock starts when the character is on the taxi, not when the flight master is clicked.
- `/ftc show` shows a static placeholder time.

### Fixed
- Hiding the box before the mount leaves still records the flight. A slow connection has 30 seconds to start the taxi.
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