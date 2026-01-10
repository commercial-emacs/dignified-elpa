# Dignified Elpa

Reusable GitHub Actions workflow and Makefile for building and distributing Emacs Lisp packages.

## Features

- Uses `package-inception` to create proper package directory structure
- Automatic package name and version extraction
- Matrix testing across Emacs versions and OS platforms
- Distribution tarball creation and upload
- Clean Makefile abstraction for local and CI builds

## Setup

1. Copy `Makefile` to your Elisp package repository
2. Ensure you have `package-inception.el` available (the Makefile will download it)

## Usage

### Local Usage

```bash
# Create distribution tarball
make FILES="foo.el foo-pkg.el README.md" dist

# Test byte compilation (compiles then removes .elc files)
make FILES="foo.el foo-pkg.el" compile

# Clean build artifacts
make FILES="foo.el" dist-clean
```

### GitHub Actions

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

## How It Works

The workflow uses the Makefile to:
1. Extract package name and version from your .el files
2. Call `package-inception` to create the package directory structure
3. Create a tarball of the generated package
4. Upload artifacts named `<os>-<emacs-version>.tar`

The Makefile provides a clean abstraction that works both locally and in CI.

## License

MIT
