# Dignified Elpa

Reusable GitHub Actions workflow for building and distributing Emacs Lisp packages.

## Features

- Uses `package-inception` to create proper package directory structure
- Automatic package name and version extraction
- Matrix testing across Emacs versions and OS platforms
- Distribution tarball creation and upload
- Zero boilerplate for consumers

## Usage

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

The workflow automatically:
1. Downloads `package-inception.el` from the package-inception repository
2. Filters your files list to separate `.el` files from other files
3. Calls `package-inception` to create the package directory structure
4. Creates a tarball of the generated package
5. Uploads artifacts named `<os>-<emacs-version>.tar`

No Makefile needed in your repository!

## License

MIT
