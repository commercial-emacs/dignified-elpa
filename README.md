# Elisp Native Compile Action

GitHub Action to native-compile Emacs Lisp packages across multiple Emacs versions and architectures.

## Features

- Automatically native-compiles across major Emacs versions (28.2, 29.4, snapshot)
- Default builds for both Linux (Ubuntu) and macOS
- Compile individual `.el` files or entire directories
- Cross-platform support (Linux, macOS, Windows)
- Parallel compilation across versions and platforms
- Automatic dependency installation
- Custom load-path support

## Usage

### Recommended: Compile Across All Emacs Versions (Reusable Workflow)

This automatically native-compiles your package across major Emacs versions (28.2, 29.4, snapshot) on both Ubuntu and macOS on tagged releases:

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

### Custom Version Matrix

Compile for specific Emacs versions:

```yaml
jobs:
  compile:
    uses: your-username/elisp-native-compile-action/.github/workflows/compile.yml@v1
    with:
      package-file: 'my-package.el'
      emacs-versions: '["29.4", "snapshot"]'
```

### Multi-Platform Compilation

Compile across operating systems:

```yaml
jobs:
  compile:
    uses: your-username/elisp-native-compile-action/.github/workflows/compile.yml@v1
    with:
      package-dir: '.'
      compile-all: true
      os-matrix: '["ubuntu-latest", "macos-latest", "windows-latest"]'
      emacs-versions: '["29.4", "snapshot"]'
```

### Advanced: Direct Action Use

For custom workflows where you manage Emacs setup yourself:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: purcell/setup-emacs@master
        with:
          version: '29.4'

      - uses: your-username/elisp-native-compile-action@v1
        with:
          package-file: 'my-package.el'
          install-deps: true
```

## Workflow Inputs

When using the reusable workflow:

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `emacs-versions` | JSON array of Emacs versions to compile for | No | `["28.2", "29.4", "snapshot"]` |
| `os-matrix` | JSON array of operating systems to compile on | No | `["ubuntu-latest", "macos-latest"]` |
| `package-file` | Main package file to compile | No | - |
| `package-dir` | Directory containing .el files | No | `.` |
| `compile-all` | Compile all .el files recursively | No | `false` |
| `load-path` | Additional load-path dirs (colon-separated) | No | - |
| `install-deps` | Install package dependencies first | No | `false` |

## Action Inputs

When using the action directly:

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `package-file` | Main package file to compile | No | - |
| `package-dir` | Directory containing .el files | No | `.` |
| `compile-all` | Compile all .el files recursively | No | `false` |
| `load-path` | Additional load-path dirs (colon-separated) | No | - |
| `install-deps` | Install package dependencies first | No | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `eln-files` | Number of .eln files generated |

## Artifacts

The workflow automatically uploads compiled `.eln` files as GitHub Actions artifacts for each platform/version combination:
- **Artifact names**:
  - `eln-files-emacs-28.2-ubuntu-latest`
  - `eln-files-emacs-28.2-macos-latest`
  - `eln-files-emacs-29.4-ubuntu-latest`
  - `eln-files-emacs-29.4-macos-latest`
  - `eln-files-emacs-snapshot-ubuntu-latest`
  - `eln-files-emacs-snapshot-macos-latest`
- **Contents**: All `.eln` files generated during compilation
- **Access**: Download from the Actions tab in your repository

### Downloading Artifacts

End users can download the latest `.eln` files using the provided script:

```bash
curl -O https://raw.githubusercontent.com/your-username/elisp-native-compile-action/v1/download-eln.sh
chmod +x download-eln.sh
./download-eln.sh owner/repo 29.4 linux
```

Or directly:

```bash
bash <(curl -s https://raw.githubusercontent.com/your-username/elisp-native-compile-action/v1/download-eln.sh) owner/repo
```

Arguments:
- `owner/repo`: GitHub repository (required)
- `emacs-version`: Emacs version, e.g., `29.4` (default: 29.4)
- `os`: Operating system: `linux` or `darwin` (default: auto-detect)

For private repositories, set `GITHUB_TOKEN`:
```bash
GITHUB_TOKEN=ghp_xxx ./download-eln.sh owner/private-repo
```

## Development

### Setup

```bash
npm install
```

### Build

```bash
npm run build
```

This compiles TypeScript and packages everything into `dist/index.js` using `@vercel/ncc`.

### Release

1. Update version in `package.json`
2. Run `npm run build`
3. Commit `dist/index.js`
4. Create and push git tag:
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```

## License

MIT
