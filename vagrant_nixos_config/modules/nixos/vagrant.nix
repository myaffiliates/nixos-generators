# This file is overwritten by the vagrant-nixos plugin
{ pkgs, ... }:
{
  imports = [
    ./vagrant-hostname.nix
    ./vagrant-network.nix
  ];
}
