{
  description = "Local NixOS Flake with MangoWM";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcraft = {
          url = "github:loystonpais/nixcraft";
          inputs.nixpkgs.follows = "nixpkgs";
        };
        
    jay = {
          url = "github:mahkoh/jay";
          inputs.nixpkgs.follows = "nixpkgs";
        };
  };

  outputs = { self, nixpkgs, home-manager, mango, nixcraft, jay, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        mango.nixosModules.mango

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
		  home-manager.sharedModules = [ 
		              mango.hmModules.mango 
		              nixcraft.homeModules.default 
		              jay.homeManagerModules.default
		            ];
          home-manager.users.xv = import ./home.nix;
        }
      ];
    };
  };
}
