# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  # my-module = import ./my-module.nix;
  cachix = import ./cachix.nix;
  dante = import ./dante.nix;
  mailcatcher = import ./mailcatcher.nix; 
  mysql-docker = import ./mysql-docker.nix;
  services = import ./services.nix;
  vagrant = import ./vagrant.nix;
}
