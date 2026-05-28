let
    vars = import ./variable.nix;
in

{
    description = "NixOS config - Laptop";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        zen-browser = {
            url = "github:0xc000022070/zen-browser-flake";
            inputs.nixpkgs.follows = "nixpkgs";
        };
	caelestia-shell = {
	    url = "github:caelestia-dots/shell";
            inputs.nixpkgs.follows = "nixpkgs";
        };
	silentSDDM = {
	    url = "github:uiriansan/SilentSDDM";
      	    inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs @ { self, nixpkgs, home-manager, zen-browser, caelestia-shell, ... }:
    let
        system = "x86_64-linux";
    in {
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit self inputs; };
            modules = [
                ./config.nix
                home-manager.nixosModules.home-manager {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.users.${vars.username} = import ./home.nix;
                    home-manager.extraSpecialArgs = { inherit zen-browser system inputs; };
                }
            ];
        };
    };
}
