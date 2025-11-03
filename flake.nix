{
  description = "Firefox addon to open links in system default browser";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          # Native messaging host package
          native-host = pkgs.stdenv.mkDerivation {
            pname = "ff-open-in-systembrowser-host";
            version = "1.1.2";

            src = ./host;

            nativeBuildInputs = [ pkgs.makeWrapper ];
            buildInputs = [ pkgs.python3 ];

            installPhase = ''
              mkdir -p $out/bin $out/lib/mozilla/native-messaging-hosts

              # Install Python script
              cp open_in_systembrowser.py $out/bin/;
              chmod +x $out/bin/open_in_systembrowser.py

              # Wrap with Python interpreter
              wrapProgram $out/bin/open_in_systembrowser.py \
                --prefix PATH : ${pkgs.lib.makeBinPath [
                  pkgs.xdg-utils  # For xdg-open on Linux
                ]}

              # Generate manifest
              substitute ${./host/open_in_systembrowser.json.template} \
                $out/lib/mozilla/native-messaging-hosts/open_in_systembrowser.json \
                --replace "HOST_PATH" "$out/bin/open_in_systembrowser.py"
            '';

            meta = with pkgs.lib; {
              description = "Native messaging host for opening URLs in system browser";
              license = licenses.mit;
              platforms = platforms.linux ++ platforms.darwin;
            };
          };

          # Firefox addon package
          addon = pkgs.stdenv.mkDerivation {
            pname = "ff-open-in-systembrowser-addon";
            version = "1.1.2";

            src = ./.;

            nativeBuildInputs = [ pkgs.zip ];

            buildPhase = ''
              mkdir -p build
              cd build
              cp ${./manifest.json} manifest.json
              cp ${./background.js} background.js
              cp ${./content.js} content.js
              mkdir -p icons
              # Add placeholder icons if they don't exist
              touch icons/icon-48.png icons/icon-96.png
              zip -r ../ff-open-in-systembrowser.xpi .
              cd ..
            '';

            installPhase = ''
              mkdir -p $out
              cp ff-open-in-systembrowser.xpi $out/
            '';

            # Add passthru for NUR/Waterfox compatibility
            passthru = {
              addonId = "open-in-systembrowser@clitters.github.io";
              xpiPath = "$out/ff-open-in-systembrowser.xpi";
            };

            meta = with pkgs.lib; {
              description = "Firefox addon to open links in system browser";
              license = licenses.mit;
              platforms = platforms.all;
            };
          };

          default = self.packages.${system}.native-host;
        };
      }
    )) // {
      # NixOS module
      nixosModules.default = { config, lib, pkgs, ... }:
        with lib;
        let
          cfg = config.programs.firefox-open-in-systembrowser;
        in
        {
          options.programs.firefox-open-in-system-browser = {
            enable = mkEnableOption "Firefox open in system browser addon";
          };

          config = mkIf cfg.enable {
            environment.systemPackages = [
              self.packages.${pkgs.system}.native-host
            ];

            # Install native messaging host manifest system-wide
            environment.etc."mozilla/native-messaging-hosts/open_in_systembrowser.json".source =
              "${self.packages.${pkgs.system}.native-host}/lib/mozilla/native-messaging-hosts/open_in_systembrowser.json";
          };
        };

      # Home Manager module for per-user installation
      homeManagerModules.default = { config, lib, pkgs, ... }:
        with lib;
        let
          cfg = config.programs.firefox.extensions.openInSystemBrowser;
        in
        {
          options.programs.firefox.extensions.openInSystemBrowser = {
            enable = mkEnableOption "Firefox open in system browser addon";
          };

          config = mkIf cfg.enable {
            home.packages = [ self.packages.${pkgs.system}.native-host ];

            # Install native messaging host manifest
            home.file.".mozilla/native-messaging-hosts/open_in_systembrowser.json".source =
              "${self.packages.${pkgs.system}.native-host}/lib/mozilla/native-messaging-hosts/open_in_systembrowser.json";

            # For NUR Firefox addons compatibility
            programs.firefox.extensions = [
              self.packages.${pkgs.system}.addon
            ];
          };
        };

      # Overlay for NUR compatibility
      overlays.default = final: prev: {
        firefox-addons = (prev.firefox-addons or {}) // {
          open-in-systembrowser = self.packages.${prev.system}.addon;
        };
      };
    };
}
