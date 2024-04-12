{ pkgs, config, lib, inputs, systems, ... }:
let
  myPhp = pkgs.php81.buildEnv {
    extensions = { all, enabled, ... }: with all; [ 
      redis 
      xdebug 
      curl
      mbstring 
      iconv 
      pdo_mysql
      openssl
      ctype 
      dom
      fileinfo 
      filter 
      gd
      gettext
      pdo
      soap   
      gmp
      intl
      mysqlnd
      pcntl
      posix
      session
      sockets
      sodium
      tokenizer
      simplexml
      xmlreader
      xmlwriter
      zip
      zlib
    ];
    extraConfig = builtins.readFile "/myaffiliates/_bootstrap/php/php81-fpm.ini";
  };

in
{
  systemd.tmpfiles.rules = [
    "d /var/log/nginx 0777 nginx nginx  0 -"
    "f /var/log/nginx/error.log 0777 nginx nginx  - -"
    "f /var/log/nginx/access.log 0777 nginx nginx  - -"
    "f /var/log/nginx/nginx.pid 0777 nginx nginx  - -"
    "d /var/log/php-fpm 0777 vagrant vagrant  0 -"
    "d /run/php-fpm 0777 vagrant vagrant - -"
    "f /var/log/redis.log 0777 redis vagrant - -"
    "f /var/log/sockd.log 0777 redis vagrant - -"
    "d /myaffiliates 0777 vagrant nginx  - -"
    "Z /myaffiliates 0777 vagrant nginx - -"
    "d /etc/ssl/crt 0650 root nginx - -"
    "z /etc/ssl/crt/test.crt 0650 root nginx - -"
    "z /etc/ssl/crt/test.key 0650 root nginx - -"
    "d /etc/cron.d 0777 vagrant nginx - -"
  ];

  environment.systemPackages = [
    myPhp
    pkgs.php81Packages.composer
    pkgs.phpunit
    pkgs.yarn
    pkgs.symfony-cli
    pkgs.sqlite
    pkgs.mysql
    pkgs.nodejs-slim
    pkgs.curl
  ];

  environment.etc.nginx.source = "${pkgs.nginx}/bin";
  environment.etc.conf.source = "${pkgs.nginx}/conf";
  environment.etc.php.source = "${myPhp}/bin";
  environment.pathsToLink = [ "/etc/php" "/etc/nginx" "/usr/bin" ];

  system.activationScripts = {
    symlinks.text = ''
      ln -sfn /run/current-system/sw/bin/php /usr/bin/
      ln -sfn /etc/nginx/nginx /usr/bin/
      ln -sfn /myaffiliates/test/scheme /vagrant/scheme
    '';
  };

  services.mailcatcher.enable = true;
  services.mailcatcher.smtp.port = 1025;
  services.mailcatcher.http.port = 10080;
  services.mailcatcher.http.ip = "0.0.0.0";

  services.redis.servers."" = {
    enable = true;
    port = 6379;
    bind = null;
    logfile = "/var/log/redis.log";
  };

  systemd.services.redis.serviceConfig = {
    ReadWritePaths = [ "/var/log" "/var/lib/redis" "/run/redis" ];
    TimeoutStartSec = 60;
    TimeoutStopSec = 60;
  };

  systemd.services.nginx.serviceConfig.ProtectHome = false;
  systemd.services.nginx.serviceConfig.ReadWritePaths = [ "/var/logs/nginx" "/run/nginx" ];
  systemd.services.nginx.unitConfig = { 
    RuntimeDirectory = "nginx";
    LogsDirectory = "nginx";
    CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
    ConditionPathExists = "/myaffiliates/_bootstrap/nginx/cloudflare"; 
  };

  services.nginx = {
    enable = true;
    user = "nginx";
    group = "nginx";
    config = builtins.readFile "/myaffiliates/_bootstrap/nginx/nginx.conf";
  };



  services.phpfpm.pools = {
    test = {
      phpPackage = myPhp;
      socket = "/run/php-fpm/php-fpm-test.sock";
      settings = {
        "listen" = "/run/php-fpm/php-fpm-$pool.sock";
        "listen.owner" = config.services.nginx.user;
        "listen.group" = config.services.nginx.group;
        "php_admin_value[date.timezone]" = "UTC";
        "user" = "vagrant";
        "group" = "vagrant";
        "pm" = "ondemand";
        "pm.process_idle_timeout" = 10;
        "pm.max_children" = 100;
        "pm.max_requests" = 1000;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 1;
        "pm.start_servers" = 1;
        "php_admin_value[open_basedir]" = "/dev/urandom:/share/tags:/myaffiliates/$pool:/vagrant:/proc/uptime";
        "php_admin_value[upload_tmp_dir]" = "/myaffiliates/$pool/storage/tmp";
        "php_admin_value[sys_temp_dir]" = "/myaffiliates/$pool/storage/tmp";
        "php_admin_value[error_log]" = "/var/log/php-fpm.$pool.log";
        "php_admin_value[disable_functions]" = "exec,passthru,shell_exec,system,proc_open,popen,phpinfo";
        "php_admin_flag[log_errors]" = true;
        "catch_workers_output" = true;
      };
    };
  };
}

