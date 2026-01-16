# Style Guide

## File Layout

- Registry components live in `registry/components/<component>/`.
- Public API: `<component>.dart`.
- Internals: `_impl/` with focused files (target <= 300 LOC).
- Required docs: `README.md` and `meta.json` per component.

## Naming

- Files: `snake_case.dart`.
- Private helpers: prefix with `_` and place under `_impl/`.
- Types: `PascalCase`; constants: `camelCase` or `SCREAMING_SNAKE` if truly constant.

## Imports

- Use relative imports inside components.
- Shared utilities should come from `registry/shared/...`.

## Theming

- No app-level wrapper required.
- Use `Theme.of(context)` from `registry/shared/theme/theme.dart`.
- If a theme extension is introduced, document it in `registry/INIT.md`.

## Docs

- Keep README examples minimal and runnable.
- Note any migration steps in `MIGRATIONS.md` per component if APIs change.
