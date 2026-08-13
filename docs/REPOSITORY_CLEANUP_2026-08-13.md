# Repository cleanup - 13 August 2026

## Goal

`main` must become the clean, maintainable, unzipped source tree of the current AgriLife Manager build.

The repository should not contain temporary transfer helpers, one-shot synchronization workflows, duplicate active sources, or old build folders. Git history already preserves previous states.

## Cleanup performed

The following legacy automation is obsolete and must stay removed:

- one-shot insurance claims assembly workflow;
- Step 8 roadmap synchronization workflow;
- Step 9 modDesc synchronization workflow;
- Step 9 roadmap synchronization workflow;
- automatic validated-ideas synchronization workflow.

The old Step 8 synchronization helper is also obsolete once its workflow is removed.

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
- project documentation at repository root

## Next source synchronization

The target is a full unzipped mirror of the current test build, not a partial documentation repository. Before replacing `main` with that full tree, compare every path against the build and classify each extra repository file as active, development-only, historical, or obsolete.

Do not delete an asset required by `modDesc.xml`, XML, Lua, I3D, GUI, vehicle, placeable, or translation references.
