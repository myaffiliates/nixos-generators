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
    outputs.nixosModules.services
    outputs.nixosModules.mysql-docker
    outputs.nixosModules.mailcatcher
    outputs.nixosModules.dante

    "${modulesPath}/virtualisation/amazon-image.nix"
    ./hardware-configuration.nix
    ./cachix.nix 
  ];
  

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      inputs.nix-shell.overlays.default

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
    trusted-users = [ "root" "ec2-user" ];
  };


  virtualisation.docker.enable = true;

  # Enable guest additions.
  virtualisation.virtualbox.guest.enable = true;

    # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "/dev/sda" ];


  environment.variables = {
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    CACHIX_AUTH_TOKEN = "eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI2ZmQ0ZmZlOS1iNjM0LTQ2MzQtOTkxZS0yYjUxNTMwYWYzNDIiLCJzY29wZXMiOiJ0eCJ9.3tAld2bHkgtsTo6piycVaIduP5ruWSu7u2oL6DQ2z0w";
  };

  environment.variables = {

  };
    
    # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

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
        echo "Hi, Im Stef. Welcome to the MyAffiliates Vagrant Environment" | cowsay -f stegosaurus | lolcat
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
    syslogng
    aws-vault
    ecs-agent
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
    members = [ "nginx" ];
  };

  # Creates a "ec2-user" group & user with password-less sudo access
  users.groups.ec2-user = {
    name = "ec2-user";
  };
  users.users.ec2-user = {
    description     = "ec2-user";
    name            = "ec2-user";
    group           = "ec2-user";
    isNormalUser = true;
    extraGroups     = [ "users" "wheel" "docker" ];
    password        = "password";
    home            = "/home/ec2-user";
    createHome      = true;
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB9zVHu0MAW2HMtk0e0UGYAcFH1Rs/6oPMzmpAQOwCzc nixos"
    ];
  };

  users.extraUsers.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB9zVHu0MAW2HMtk0e0UGYAcFH1Rs/6oPMzmpAQOwCzc nixos" ];

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

  services.openssh = {
    enable = true;
    settings = {
      # Forbid root login through SSH.
      PermitRootLogin = "no";
      # Use keys only. Remove if you want to SSH using password (not recommended)
      PasswordAuthentication = false;
    };
    extraConfig = ''
      PubkeyAcceptedKeyTypes +ssh-rsa,ssh-ed25519
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
    cachixTokenFile = "./keys/zban-nixcache";
  };

  services.cachix-agent = {
    enable = true;
    name = "vagrant";
    credentialsFile = "./keys/agent-token";
  };

    networking.enableIPv6 = false;
    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = [ 22 80 443 1025 3306 6000 6379 1080 10080];
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
