# Dignified Elpa

GitHub Action to byte-compile Emacs Lisp packages.

## Usage

Create `.github/workflows/release.yml`:

```yaml
name: Release
on:
  push:
    tags: ['*']

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
        emacs: ['29.4', '30.2', 'snapshot', 'snapshot-commercial']
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4

      # Install any dependencies your package needs
      - uses: actions/setup-python@v5
        if: false  # Enable if needed

      - uses: dickmao/setup-emacs@dignified-elpa
        with:
          version: ${{ matrix.emacs }}

      - run: make dist

      - uses: commercial-emacs/dignified-elpa@v1
        with:
          package-dir: '.'

      - uses: actions/upload-artifact@v4
        with:
          name: ${{ matrix.os }}-${{ matrix.emacs }}
          path: dist/
```

## Inputs

| Input | Default | Description |
|-------|---------|-------------|
| `package-dir` | `.` | Directory containing .el files to compile recursively |
| `load-path` | - | Additional directories to add to load-path (colon-separated) |

## License

MIT
