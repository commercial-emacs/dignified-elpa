# Dignified Elpa

Makefile template for building and distributing Emacs Lisp packages.

## Features

- Uses `package-inception` to create proper package directory structure
- Automatic package name and version extraction
- Byte compilation with dependency management
- Distribution tarball creation
- Package installation recipe

## Usage

Copy `Makefile` to your Elisp package repository and use:

```bash
# Create distribution tarball
make FILES="foo.el foo-pkg.el README.md" dist

# Test byte compilation (compiles then removes .elc files)
make FILES="foo.el foo-pkg.el" compile

# Clean build artifacts
make FILES="foo.el" dist-clean
```

## GitHub Actions Integration

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

      - uses: dickmao/setup-emacs@dignified-elpa
        with:
          version: ${{ matrix.emacs }}

      - run: make FILES="your-package.el ..." dist

      - uses: actions/upload-artifact@v4
        with:
          name: ${{ matrix.os }}-${{ matrix.emacs }}
          path: '*.tar'
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `dist` | Create distribution tarball (requires FILES variable) |
| `dist-clean` | Remove generated tarballs and directories |
| `compile` | Byte-compile with dependency installation, then clean up |

## License

MIT
