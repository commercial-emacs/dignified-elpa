# Elisp Native Compile Action

Native-compile Emacs Lisp packages across Emacs versions (28.2, 29.4, snapshot) and platforms (Ubuntu, macOS).

## Usage

Create `.github/workflows/native-compile.yml`:

```yaml
name: Native Compilation
on:
  push:
    tags:
      - 'v*'

jobs:
  compile:
    uses: your-username/elisp-native-compile-action/.github/workflows/compile.yml@v1
    with:
      package-file: 'my-package.el'
```

Runs `make dist` and uploads `dist/` as artifact: `<os>-<version>`

## Inputs

| Input | Default |
|-------|---------|
| `emacs-versions` | `["28.2", "29.4", "snapshot"]` |
| `os-matrix` | `["ubuntu-latest", "macos-latest"]` |
| `package-file` | - |
| `package-dir` | `.` |
| `compile-all` | `false` |

## License

MIT
