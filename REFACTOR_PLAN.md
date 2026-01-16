# Refactor Plan

Goal: migrate components into the registry one-by-one with minimal shared surface area and CLI-ready metadata.

## Checklist

- [x] button
- [x] card
- [x] badge
- [x] input/textfield
- [x] dialog
- [x] popover
- [x] drawer
- [x] dropdown/menu
- [x] sortable
- [x] tabs
- [x] table

## Workflow per Component

1) Audit: confirm size, dependencies, and any oversized sections to split.
2) Registry move: create `registry/components/<name>/` with `component.dart`, `_impl/`, `README.md`, and `meta.json`.
3) Split: keep files under ~300 LOC where practical; move helpers into `_impl/`.
4) Shared: extract truly shared primitives into `registry/shared/` only when reused.
5) Registry: update `registry/components.json` with file mappings, shared deps, and pubspec deps.
6) Validation: run analysis/tests if available; ensure examples compile if possible.
7) Commit: `refactor(registry): <component>` with migration notes if needed.
