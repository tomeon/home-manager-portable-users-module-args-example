{
  description = "home-manager portable users module args example";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/release-21.11";
    nixpkgs.follows = "nixos";

    home.url = "github:nix-community/home-manager/release-21.11";
    home.inputs.nixpkgs.follows = "nixos";

    digga.url = "github:divnix/digga";
    digga.inputs.nixpkgs.follows = "nixos";
    digga.inputs.home-manager.follows = "home";

    fup.follows = "digga/flake-utils-plus";
  };

  outputs = { self, nixos, home, digga, fup, ... }@inputs:
    let
      hmProfile = { pkgs, ... }@args: {
        home.packages = with pkgs; [ jq ];
      };

      # Copied from https://github.com/divnix/digga/blob/feeddc0a1bce63ec73938e390ee0971f6b39462b/src/mkFlake/outputs-builder.nix#L9-L33
      # Some alterations made to accommodate absence of the "config" attrset;
      # original code retained as comments above altered lines.
      mkPortableHomeManagerConfiguration =
        { username
        , configuration
        , pkgs
        , system ? pkgs.system
        }:
        let
          homeDirectoryPrefix =
            if pkgs.stdenv.hostPlatform.isDarwin then "/Users" else "/home";
          homeDirectory = "${homeDirectoryPrefix}/${username}";
        in
        #home-manager.lib.homeManagerConfiguration {
        home.lib.homeManagerConfiguration {
          inherit username homeDirectory pkgs system;

          #extraModules = config.home.modules ++ config.home.exportedModules;
          extraModules = [];
          #extraSpecialArgs = config.home.importables // { inherit (config) self inputs; };
          extraSpecialArgs = { inherit self inputs; suites = null; };

          configuration = {
            imports = [ configuration ];
          } // (
            if pkgs.stdenv.hostPlatform.isLinux
            then { targets.genericLinux.enable = true; }
            else { }
          );
        };

      hmConfig = mkPortableHomeManagerConfiguration {
        username = "me";
        configuration = hmProfile;
        pkgs = self.pkgs.x86_64-linux.nixos;
      };

      diggaFlake = digga.lib.mkFlake {
        inherit self inputs;

        channels.nixos = { };

        nixos.hostDefaults.channelName = "nixos";

        home.users.me = hmProfile;
      };

      fupFlake = fup.lib.mkFlake {
        inherit self inputs;

        channels.nixos = { };

        hostDefaults.channelName = "nixos";

        outputsBuilder = channels:
          {
            fupHmConfig = mkPortableHomeManagerConfiguration {
              username = "me";
              configuration = hmProfile;
              pkgs = channels.nixos;
            };
          };
      };

    in diggaFlake // fupFlake // { inherit hmConfig; };
}
