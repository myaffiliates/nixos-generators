{ config, pkgs, ...}:
{
  networking.usePredictableInterfaceNames = true;
  networking.useDHCP = true;
  networking.interfaces = {
    eth1 = {
      ipv4 = {
        addresses = [
          {
          address = "192.168.33.10";
          prefixLength = 24;
          }
        ];
      };
    };
  };
}