# Changelog
## Version 1.0
### 21.06.2026
- Initial Release

## Version 1.01
### 24.06.2026
- Changed name "Resource Crate" to "Ressource Crate".
- Added Video Explaining the Mod and Image on how to customise your own structure list.

## Version 1.1
### 28.06.2026
#### Added
- Added CBA Addon Options to configure the maximum resource capacity of crates and depots.
- Added a CBA Addon Option to disable building costs entirely, allowing players to build without needing resources.
- Added an Eden Attribute to set the initial resource amount inside individual crates.
- Added the new **Ressource Depot** object, which can store all resource types independently.
- Resource types can be enabled or disabled individually through Eden Attributes.
- Initial depot stock can be configured for each resource type:
- `-2` = starts full
- `-1` = infinite stock
- `0+` = exact starting amount
- Crates can now be refilled from nearby compatible depots.
- Resources can be deposited from crates into nearby compatible depots.
- Withdrawal and deposit permissions can be enabled or disabled separately through Eden Attributes.
- Depot resource stock can be inspected through an ACE interaction.
- Added a configurable depot transfer radius through Eden Attributes.

#### Fixed
- Crates now keep their load and unload interactions after being unloaded from a flatbed.

#### Known Issues
- Flatbed support is currently limited to BLUFOR/NATO vehicles. Support for flatbeds from other factions is planned for a future update.

## Version 1.11
### 15.08.2026
#### Fixed
- Eden Editor Object Attributes were broken after Update 2.22. Fixed it. Now they show up again.

## Version 1.12
### 23.08.2026
#### Added
- GitHub for Mod
- Documentation
- Commentary on code
