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
    uses: commercial-emacs/dignified-elpa/.github/workflows/build.yml@v1
    with:
      files: "your-package.el your-package-pkg.el README.md"
```

### Inputs

| Input | Default | Description |
|-------|---------|-------------|
| `files` | - | **Required.** Space-separated list of files to include in distribution |
| `emacs-versions` | `["29.4", "30.2", "snapshot", "snapshot-commercial"]` | JSON array of Emacs versions |
| `os-matrix` | `["ubuntu-latest", "macos-latest"]` | JSON array of operating systems |

### Example with Custom Matrix

```yaml
jobs:
  build:
    uses: commercial-emacs/dignified-elpa/.github/workflows/build.yml@v1
    with:
      files: "foo.el foo-pkg.el"
      emacs-versions: '["29.4", "30.2"]'
      os-matrix: '["ubuntu-latest"]'
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `dist` | Create distribution tarball (requires FILES variable) |
| `dist-clean` | Remove generated tarballs and directories |
| `compile` | Byte-compile with dependency installation, then clean up |

## License

MIT
