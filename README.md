# ff-open-in-systembrowser

Firefox addon to open a link in system browser using native messaging host

## Features

- Open links in your system's default browser via context menu
- Use Alt+Middle-Click on any link to open in system browser
- Works with any default browser configured in your system

## Installation

### Extension Installation

#### From Release (Recommended)
1. Download the latest `.xpi` file from the [Releases](https://github.com/clitters/ff-open-in-systembrowser/releases) page
2. Open Firefox and navigate to `about:addons`
3. Click the gear icon and select "Install Add-on From File..."
4. Select the downloaded `.xpi` file

#### From Source
```bash
npm install
npm run build
# The .xpi file will be in the dist/ directory
```

### Native Messaging Host Installation

The extension requires a native messaging host to communicate with your system.

#### Using the Install Script
```bash
cd host
./install.sh
```

#### Using Nix
```nix
# In your NixOS configuration or home-manager
{
  imports = [ (builtins.fetchGit {
    url = "https://github.com/clitters/ff-open-in-systembrowser";
    ref = "main";
  }).nixosModules.default ];
  
  programs.firefox-open-in-system-browser.enable = true;
}
```

## Development

### Prerequisites
- Node.js 20+ and npm
- Firefox Developer Edition (recommended for testing)

### Building

```bash
# Install dependencies
npm install

# Build the extension
npm run build

# Or use the build script
./scripts/build.sh

# Package the extension
./scripts/package.sh
```

### Linting
```bash
npm run lint
```

### Testing Locally
```bash
npm install -g web-ext
web-ext run --source-dir=src
```

## GitHub Actions

This repository includes automated workflows for building and releasing:

### Automatic Builds
- Builds run on every push to `main` and on pull requests
- Artifacts are uploaded for each build

### Signing and Releases
- Signing happens automatically when you push a tag like `v1.1.3`
- Requires `WEB_EXT_API_KEY` and `WEB_EXT_API_SECRET` secrets to be set in repository settings
- Get your API credentials from [Firefox Add-ons Developer Hub](https://addons.mozilla.org/developers/addon/api/key/)

### Creating a Release
```bash
# Update version in src/manifest.json and package.json
# Commit your changes
git add .
git commit -m "Bump version to 1.1.3"

# Create and push a tag
git tag v1.1.3
git push origin v1.1.3

# GitHub Actions will automatically build, sign, and create a release
```

## Project Structure

```
ff-open-in-systembrowser/
├── .github/
│   └── workflows/
│       └── build-and-release.yml  # CI/CD workflow
├── src/                           # Extension source files
│   ├── manifest.json
│   ├── background.js
│   ├── content.js
│   └── icons/
│       ├── icon-48.png
│       └── icon-96.png
├── host/                          # Native messaging host
│   ├── install.sh
│   ├── open_in_systembrowser.json.template
│   └── open_in_systembrowser.py
├── scripts/                       # Build scripts
│   ├── build.sh
│   └── package.sh
├── package.json                   # NPM configuration
├── web-ext-config.js             # web-ext configuration
└── flake.nix                     # Nix build configuration
```

## License

MIT
