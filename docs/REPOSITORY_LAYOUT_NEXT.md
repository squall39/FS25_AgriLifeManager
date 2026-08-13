# Target repository layout

The GitHub repository must become the full unzipped source tree of the current AgriLife Manager test build.

The ZIP remains the player-facing test and distribution artifact, but `main` should contain the same active mod tree so the source can be reviewed, maintained, and rebuilt without relying on a separate partial mirror.

## Root

Keep only the project files that are useful for development, testing, documentation, and the FS25 mod package.

## Active mod tree

The repository should track:

- `modDesc.xml`
- `src/`
- `gui/`
- `translations/`
- `data/`
- `vehicles/`
- `placeables/`
- textures and binary assets used by the mod when redistribution is allowed
- package resources required by XML, Lua, I3D, GUI, vehicle, or placeable references

## Development tree

Keep:

- `tests/`
- `tools/`
- `docs/`
- GitHub issue and workflow configuration that is still actively useful

## Do not keep

- `builds/` archives that duplicate Git history
- split transfer chunks
- one-shot synchronization workflows
- duplicate Lua sources
- obsolete version-specific test plans on `main`
- stale helper scripts that only served a removed workflow
- temporary screenshots or logs

Git history preserves previous versions. `main` should represent the current working state, not every historical state at once.
