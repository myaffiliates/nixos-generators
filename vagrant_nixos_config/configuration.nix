# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}: {
  # You can import other NixOS modules here
  disabledModules = [ "services/networking/dante.nix" "services/mail/mailcatcher.nix" ];
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    outputs.nixosModules.cachix
    outputs.nixosModules.dante
    outputs.nixosModules.mailcatcher
    outputs.nixosModules.mysql-docker
    outputs.nixosModules.services
    outputs.nixosModules.vagrant

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    #./hardware-configuration.nix
  ];
  
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["/etc/nix/path"];
  environment.etc =
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  nix.settings = {
    # Enable flakes and new 'nix' command
    experimental-features = "nix-command flakes";
    # Deduplicate and optimize nix store
    auto-optimise-store = true;
    trusted-users = [ "root" "vagrant" ];
  };

  # FIXME: Add the rest of your current configuration

  # Hostname is in vagrant config
  #networking.hostName = "your-hostname";

  virtualisation.docker.enable = true;

  # Enable guest additions.
  virtualisation.virtualbox.guest.enable = true;

    # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  #boot.loader.grub.devices = [ "/dev/sda" ];
  boot.loader.grub.useOSProber = true;


  fileSystems."/var/lib/mysql" =
  { device = "/dev/disk/by-label/mysql";
    fsType = "ext4";
  };

  environment.variables = {
  NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  CACHIX_AUTH_TOKEN = "eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI2ZmQ0ZmZlOS1iNjM0LTQ2MzQtOTkxZS0yYjUxNTMwYWYzNDIiLCJzY29wZXMiOiJ0eCJ9.3tAld2bHkgtsTo6piycVaIduP5ruWSu7u2oL6DQ2z0w";
 };

  fileSystems."/vagrant" = {
    device = "vagrant";
    fsType = "vboxsf";
    options = [ "rw" "dmode=777" "fmode=777" ];
    };
    
    # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  programs = {
    bash = {
      interactiveShellInit = ''
        export NIX_ENFORCE_PURITY=0
        cachix use zban-nixcache    
        if [[ $PATH = *ZBan* ]]; then
          echo "PATHs already exist"
        else
          echo "Adding PATHs"
          export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/myaffiliates/test/devtools/bin:/myaffiliates/test/ZBan/vendor/bin:/myaffiliates/test/ZBan/bin
        fi
        echo "Welcome to the MyAffiliates Vagrant Environment!" | cowsay | lolcat
        eval "$(starship init bash)"
      '';
    };
  };

  system.activationScripts = {
    symlinks.text = ''
    ln -sfn /run/current-system/sw/bin/cut /usr/bin/
    ln -sfn /run/current-system/sw/bin/env /usr/bin/    
    ln -sfn /run/current-system/sw/bin/getent /usr/bin/
    ln -sfn /run/current-system/sw/bin/git /usr/bin/
    ln -sfn /run/current-system/sw/bin/head /usr/bin/ 
    ln -sfn /run/current-system/sw/bin/openssl /usr/bin/ 
    ln -sfn /run/current-system/sw/bin/sort /usr/bin/
    ln -sfn /run/current-system/sw/bin/tr /usr/bin/
    ln -sfn /run/current-system/sw/bin/cat /bin/ 
    ln -sfn /run/current-system/sw/bin/chmod /bin/ 
    ln -sfn /run/current-system/sw/bin/chown /bin/ 
    ln -sfn /run/current-system/sw/bin/cp /bin/
    ln -sfn /run/current-system/sw/bin/grep /bin/
    ln -sfn /run/current-system/sw/bin/mkdir /bin/
    ln -sfn /run/current-system/sw/bin/mount /bin/
    ln -sfn /run/current-system/sw/bin/mv /bin/  
    ln -sfn /run/current-system/sw/bin/setfacl /bin/ 
    ln -sfn /run/current-system/sw/bin/getfacl /bin/
    '';
  };

  boot.kernel.sysctl = { "vm.overcommit_memory" = 1; };

  environment.systemPackages = with pkgs; [
    findutils
    gnumake
    iputils
    jq
    nettools
    netcat
    nfs-utils
    cachix
    direnv
    rsync
    vim
    wget
    cron
    unzip
    screen
    bash-completion
    git
    openssl
    docker
    docker-compose
    glibc
    mysql
    cacert
    acl
    starship
    lolcat
    cowsay   
   ];

  fonts.packages = with pkgs; [
    font-awesome
    powerline-fonts
    powerline-symbols
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];

  # Create Nginx group
  users.groups.nginx = {
        name = "nginx";
    members = [ "vagrant" ];
  };

  # Creates a "vagrant" group & user with password-less sudo access
  users.groups.vagrant = {
    name = "vagrant";
    members = [ "vagrant" ];
  };
  users.users.vagrant = {
    description     = "Vagrant user account";
    name            = "vagrant";
    group           = "vagrant";
    isNormalUser = true;
    extraGroups     = [ "users" "wheel" "vboxsf" "nginx" "root" "docker" ];
    password        = "vagrant";
    home            = "/home/vagrant";
    createHome      = true;
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
    ];
  };

  users.extraUsers.root.openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" ];

  security.pki.certificates  = [(builtins.readFile ./auth.myaffiliates.com-ca.crt)];
  security.sudo.extraConfig =
    ''
      Defaults:root,%wheel env_keep+=LOCALE_ARCHIVE
      Defaults:root,%wheel env_keep+=NIX_PATH
      Defaults:root,%wheel env_keep+=TERMINFO_DIRS
      Defaults env_keep+=SSH_AUTH_SOCK
      Defaults lecture = never
      root   ALL=(ALL) SETENV: ALL
      %wheel ALL=(ALL) NOPASSWD: ALL, SETENV: ALL
    '';

  # This setups a SSH server. Very important if you're setting up a headless system.
  services.openssh = {
    enable = true;
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "no";
      # Use keys only. Remove if you want to SSH using password (not recommended)
      PasswordAuthentication = false;
    };
    extraConfig = ''
      PubkeyAcceptedKeyTypes +ssh-rsa
      ClientAliveInterval 1000
      ClientAliveCountMax 10
      TCPKeepAlive yes
      '';
    };

  # Enable DBus
  services.dbus.enable = true;

  # Replace ntpd by timesyncd
  services.timesyncd.enable = true;  

  services.cachix-watch-store = {
    enable = true;
    package = pkgs.cachix;
    cacheName = "zban-nixcache";
    cachixTokenFile = "/etc/nixos/zban-nixcache";
  };

  services.cachix-agent = {
    enable = true;
    name = "vagrant";
    credentialsFile = "/etc/nixos/agent-token";
  };

    networking.enableIPv6 = false;
    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = [ 22 80 443 1025 3306 6379 1080 10080 9001 9002 9003 ];
    networking.domain = "test";
    networking.extraHosts =
      ''
      172.18.0.1      localhost
      127.0.0.1       localhost myaffiliates.test myaffiliates media.myaffiliates.test www.myaffiliates.test admin.myaffiliates.test affiliates.myaffiliates.test xml.myaffiliates.test js.myaffiliates.test record.myaffiliates.test
      192.168.33.10   localhost myaffiliates.test myaffiliates media.myaffiliates.test www.myaffiliates.test admin.myaffiliates.test affiliates.myaffiliates.test xml.myaffiliates.test js.myaffiliates.test record.myaffiliates.test 
      '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
