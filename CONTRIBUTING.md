# Contributing

## Development Setup

```bash
npm install
```

## Building

The action uses [@vercel/ncc](https://github.com/vercel/ncc) to compile TypeScript and dependencies into a single file:

```bash
npm run build
```

This creates `dist/index.js` which must be committed to the repository.

## Testing Locally

You can test the compiled action locally:

```bash
npm run build
node dist/index.js
```

Set inputs via environment variables:

```bash
export INPUT_PACKAGE-FILE="test.el"
export INPUT_COMPILE-ALL="false"
node dist/index.js
```

## Testing in GitHub Actions

Create a test repository and reference your branch:

```yaml
- uses: commercial-emacs/elisp-native-compile-action@your-branch
  with:
    package-file: 'test.el'
```

## Release Process

1. Make changes
2. Update version in `package.json`
3. Build: `npm run build`
4. Commit changes including `dist/`
5. Tag: `git tag -a v1.x.x -m "Description"`
6. Push: `git push origin v1.x.x`
7. Update major version tag: `git tag -fa v1 -m "Update v1 tag"` && `git push origin v1 --force`

## Code Style

- Use TypeScript strict mode
- Format with Prettier: `npm run format`
- Lint with ESLint: `npm run lint`
