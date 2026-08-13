# Repository cleanup - 13 August 2026

## Goal

`main` must become the clean, maintainable, unzipped source tree of the current AgriLife Manager build.

The repository should not contain temporary transfer helpers, one-shot synchronization workflows, duplicate active sources, old build folders, or version-specific reports that are only useful as history.

## Cleanup performed

Removed obsolete automation:

- insurance claims assembly workflow ;
- Step 8 roadmap synchronization workflow ;
- Step 9 modDesc synchronization workflow ;
- Step 9 roadmap synchronization workflow ;
- validated-ideas synchronization workflow.

Removed obsolete or duplicate documentation from `main`:

- old 0.9.2.0 and 0.9.3.x test roadmaps ;
- old 0.9.3.0 and 0.9.3.1 test-result files ;
- old 0.9.1.0 and 0.9.3.1 static audit reports ;
- old binary manifest tied to 0.9.3.0 ;
- Step 8 and Step 9 temporary implementation documents already represented in the master roadmap and Git history ;
- old tutorial/l10n synchronization report ;
- old verification report ;
- stale l10n audit ;
- duplicate writing-attribution document ;
- stale `FEATURES.md` summary.

Removed the unused `sync_validated_ideas.py` helper after its workflow was removed.

## Structure to keep

- `modDesc.xml`
- `src/`
- `gui/`
- `translations/`
- `data/`
- `vehicles/`
- `placeables/`
- distributable textures and binary assets that belong to the mod and may be redistributed
- `tests/`
- `tools/`
- `docs/`
- useful project documentation at repository root

## Current rule

Git history preserves previous versions. `main` represents the current working state only.

Do not delete an asset required by `modDesc.xml`, XML, Lua, I3D, GUI, vehicle, placeable, or translation references.

## Next source synchronization

The next structural step is the full unzipped mirror of the 0.9.3.13 test build. Compare every path in the build against `main`, then add missing active files and remove repository-only leftovers that have no development value.
