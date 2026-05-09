# shadcn-flutter-registry

Production registry distribution for Flutter shadcn components.

This repository is consumed by `flutter_shadcn_cli` and exposes a copy/paste
registry under `registry/`.

## Registry URL

```bash
https://raw.githubusercontent.com/ibrar-x/shadcn-flutter-registry/master/registry
```

## QA

```bash
dart analyze
dart run tool/verify_registry.dart
```

The verifier checks that:

- `registry/components.json` and `registry/components.schema.json` are valid JSON.
- every component has an id and file list.
- every declared source file exists inside this repository.
- duplicate component ids and duplicate source entries are rejected.

The canonical Flutter analysis and widget tests for the component source run in
the upstream mono-repo before the registry is mirrored here.
