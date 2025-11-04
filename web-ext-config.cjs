module.exports = {
  // Source directory containing the extension files
  sourceDir: 'src/',
  
  // Output directory for build artifacts
  artifactsDir: 'dist/',
  
  // Files to ignore when building
  ignoreFiles: [
    '**/*.md',
    '**/.*',
    'web-ext-config.js',
    'package.json',
    'package-lock.json',
    'node_modules'
  ],
  
  // Build configuration
  build: {
    overwriteDest: true
  },
  
  // Lint configuration
  lint: {
    selfHosted: false,
    pretty: true
  }
};
