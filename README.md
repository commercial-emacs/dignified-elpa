# Dignified Elpa

Compile Emacs Lisp packages across Emacs versions (29.4, 30.2, snapshot, snapshot-commercial) and platforms (Ubuntu, macOS).

## Usage

Create `.github/workflows/compile.yml`:

```yaml
name: Compilation
on:
  push:
    tags:
      - 'v*'

jobs:
  compile:
    uses: commercial-emacs/dignified-elpa/.github/workflows/compile.yml@v1
```

Runs `make dist` and uploads `dist/` as artifact: `<os>-<version>`

## Inputs

| Input | Default |
|-------|---------|
| `emacs-versions` | `["29.4", "30.2", "snapshot", "snapshot-commercial"]` |
| `os-matrix` | `["ubuntu-latest", "macos-latest"]` |
| `package-dir` | `.` |

## License

MIT
