# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  # my-module = import ./my-module.nix;
  services = import ./services.nix;
  newrelic-infra = import ./newrelic-infra.nix;
  cachix = import ./cachix.nix;
  mysql-docker = import ./mysql-docker.nix;
  dante = import ./dante.nix;
  mailcatcher = import ./mailcatcher.nix;
  setup = import ./setup.nix;
}
