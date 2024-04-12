# This script is overwritten by vagrant. See
# https://github.com/mitchellh/vagrant/blob/master/templates/guests/nixos/hostname.erb
{ pkgs, ... }:
{
  networking.hostName = "myaffiliates";
}
