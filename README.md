# ff-open-in-systembrowser

Firefox addon to open a link in system browser using native messaging host

⚠️ **IMPORTANT: This extension requires a native messaging host to be installed on your system.** The extension alone will not work without the companion native host. See [Native Messaging Host Installation](#native-messaging-host-installation) below.

## Features

- Open links in your system's default browser via context menu
- Use Alt+Middle-Click on any link to open in system browser
- Works with any default browser configured in your system

## Installation

**Installation Order:**
1. Install the Native Messaging Host first (required)
2. Then install the Firefox Extension

### Native Messaging Host Installation

The extension requires a native messaging host to communicate with your system. **Install this first.**

#### Using the Install Script
```bash
cd host
./install.sh
```

#### Manual Installation

1. **Copy the Python script to a permanent location:**
   ```bash
   sudo mkdir -p /usr/local/bin
   sudo cp host/open_in_systembrowser.py /usr/local/bin/
   sudo chmod +x /usr/local/bin/open_in_systembrowser.py
   ```

2. **Create the native messaging host manifest:**
   
   **On Linux:**
   ```bash
   mkdir -p ~/.mozilla/native-messaging-hosts
   cat > ~/.mozilla/native-messaging-hosts/open_in_systembrowser.json << 'EOF'
   {
     "name": "open_in_systembrowser",
     "description": "Open URLs in system default browser",
     "path": "/usr/local/bin/open_in_systembrowser.py",
     "type": "stdio",
     "allowed_extensions": [
       "open-in-systembrowser@clitters.github.io"
     ]
   }
   EOF
   ```
   
   **On macOS:**
   ```bash
   mkdir -p ~/Library/Application\ Support/Mozilla/NativeMessagingHosts
   cat > ~/Library/Application\ Support/Mozilla/NativeMessagingHosts/open_in_systembrowser.json << 'EOF'
   {
     "name": "open_in_systembrowser",
     "description": "Open URLs in system default browser",
     "path": "/usr/local/bin/open_in_systembrowser.py",
     "type": "stdio",
     "allowed_extensions": [
       "open-in-systembrowser@clitters.github.io"
     ]
   }
   EOF
   ```

3. **Verify the installation:**
   ```bash
   # Check the manifest exists
   cat ~/.mozilla/native-messaging-hosts/open_in_systembrowser.json  # Linux
   # or
   cat ~/Library/Application\ Support/Mozilla/NativeMessagingHosts/open_in_systembrowser.json  # macOS
   
   # Check the script is executable
   ls -la /usr/local/bin/open_in_systembrowser.py
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

**Note:** The Nix installation installs both the native host and the extension directly from this GitHub repository (not from AMO). Updates are managed through your Nix configuration.

### Extension Installation

**After installing the native host**, install the Firefox extension:

#### Option 1: Firefox Add-ons (AMO) - Recommended
**Automatic updates enabled**
- Visit [Firefox Add-ons page](https://addons.mozilla.org/) (link TBD - upload your signed XPI)
- Click "Add to Firefox"
- Automatic updates will be handled by Mozilla

#### Option 2: Direct Installation from GitHub
**Manual updates only**
1. Download the latest signed XPI from the [Releases](https://github.com/clitters/ff-open-in-systembrowser/releases) page
   - Look for `open_in_system_browser-X.X.X-signed.xpi`
2. Open Firefox and navigate to `about:addons`
3. Click the gear icon and select "Install Add-on From File..."
4. Select the downloaded `.xpi` file

**Note:** Direct installations from GitHub won't receive automatic updates. Check the releases page periodically for new versions.

#### From Source (Development)
```bash
npm install
npm run build
# The .xpi file will be in the dist/ directory
```

### Troubleshooting

If the extension doesn't work:
1. **Check native host is installed**: Look for `open_in_systembrowser.json` in:
   - Linux: `~/.mozilla/native-messaging-hosts/`
   - macOS: `~/Library/Application Support/Mozilla/NativeMessagingHosts/`
2. **Check the host script is executable**: `chmod +x /path/to/open_in_systembrowser.py`
3. **Check Firefox console**: Open Browser Console (Ctrl+Shift+J) to see error messages
4. **Test the host manually**: Run the Python script directly to verify it works

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
- Unsigned XPI artifacts are uploaded with format: `open_in_system_browser-X.X.X-unsigned.xpi`

### Signing and Releases
- Signing happens automatically when you push a tag like `v1.1.3`
- Signed XPI is created with format: `open_in_system_browser-X.X.X-signed.xpi`
- Requires `WEB_EXT_API_KEY` and `WEB_EXT_API_SECRET` secrets to be set in repository settings
- Get your API credentials from [Firefox Add-ons Developer Hub](https://addons.mozilla.org/developers/addon/api/key/)

### Distribution Strategy
1. **GitHub Releases**: Both unsigned and signed XPIs are attached to releases
2. **AMO (Mozilla Add-ons)**: Upload the signed XPI manually to AMO for users who want automatic updates
   - Go to https://addons.mozilla.org/developers/
   - Upload the signed XPI from your GitHub release
   - AMO users will receive automatic updates
   - GitHub direct install users need to manually check for updates

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
