{
  description = "blumb";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ninjabrain-bot-xwayland = {
      url = "github:Ktrompfl/ninjabrain-bot-xwayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcsr-nixos.url = "git+https://git.uku3lig.net/tom-ricci/mcsr-nixos.git";
            
    jay = {
      url = "github:Ktrompfl/jay/warp-mouse-to-outputs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, jay, mcsr-nixos, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      
      specialArgs = { 
        inherit inputs; 
        mcsrPkgs = mcsr-nixos.packages."x86_64-linux";
      };
      
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.sharedModules = [ 
            jay.homeManagerModules.default
          ];
          home-manager.users.xv = import ./home.nix;
        }
      ];
    };
  };
}
