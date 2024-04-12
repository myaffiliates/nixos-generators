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
    extraConfig = ''
      [PHP]
      engine = On
      short_open_tag = on
      precision = 14
      output_buffering = 4096
      zlib.output_compression = Off
      implicit_flush = Off
      unserialize_callback_func =
      serialize_precision = -1
      disable_classes =
      zend.enable_gc = On
      zend.exception_ignore_args = Off
      expose_php = On
      max_execution_time = 300
      max_input_time = 60
      memory_limit = 512M

      error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
      display_errors = stderr
      display_startup_errors = Off
      log_errors = On
      log_errors_max_len = 1024
      ignore_repeated_errors = Off
      ignore_repeated_source = Off
      report_memleaks = On
      track_errors = Off
      html_errors = On
      error_log = /var/log/php-fpm.log;

      variables_order = "GPCS"
      request_order = "GP"
      register_argc_argv = Off
      auto_globals_jit = On

      post_max_size = 8M
      auto_prepend_file =
      auto_append_file =
      default_mimetype = "text/html"
      default_charset = "UTF-8"
      doc_root =
      user_dir =
      enable_dl = Off
      file_uploads = On
      upload_max_filesize = 6M
      max_file_uploads = 20
      allow_url_fopen = On
      allow_url_include = Off
      default_socket_timeout = 60

      [XDEBUG]
      xdebug.output_dir="/tmp"
      xdebug.trace_output_name="trace.%c"
      xdebug.trace_format="0"
      xdebug.trace_options="0"
      xdebug.collect_return="0"
      xdebug.extended_info="1"
      xdebug.force_display_errors="1"
      xdebug.manual_url="http://www.php.net"
      xdebug.max_nesting_level="1000"
      xdebug.show_exception_trace="0"
      xdebug.show_local_vars="0"
      xdebug.show_mem_delta="0"
      xdebug.dump.COOKIE="NULL"
      xdebug.dump.ENV="NULL"
      xdebug.dump.FILES="NULL"
      xdebug.dump.GET="NULL"
      xdebug.dump.POST="NULL"
      xdebug.dump.REQUEST="NULL"
      xdebug.dump.SERVER="NULL"
      xdebug.dump.SESSION="NULL"
      xdebug.dump_globals="1"
      xdebug.dump_once="1"
      xdebug.dump_undefined="0"
      xdebug.profiler_output_dir="/tmp"
      xdebug.profiler_append="0"
      xdebug.profiler_aggregate="0"
      xdebug.start_with_request=trigger
      xdebug.client_host="192.168.33.1"
      xdebug.client_port="9003"
      xdebug.log="/vagrant/xdebug.log"
      xdebug.idekey=""
      xdebug.var_display_max_data="2560"
      xdebug.var_display_max_depth="10"
      xdebug.var_display_max_children="128"

      [CLI Server]
      cli_server.color = On

      [Date]
      date.timezone = UTC

      [filter]

      [iconv]

      [intl]

      [sqlite3]

      [Pcre]

      [Pdo]

      [Pdo_mysql]
      pdo_mysql.cache_size = 2000
      pdo_mysql.default_socket=

      [Phar]

      [mail function]
      SMTP = localhost
      smtp_port = 25
      mail.add_x_header = On

      [SQL]
      sql.safe_mode = Off

      [ODBC]
      odbc.allow_persistent = On
      odbc.check_persistent = On
      odbc.max_persistent = -1
      odbc.max_links = -1
      odbc.defaultlrl = 4096
      odbc.defaultbinmode = 1

      [Interbase]
      ibase.allow_persistent = 1
      ibase.max_persistent = -1
      ibase.max_links = -1
      ibase.timestampformat = "%Y-%m-%d %H:%M:%S"
      ibase.dateformat = "%Y-%m-%d"
      ibase.timeformat = "%H:%M:%S"

      [MySQLi]
      mysqli.max_persistent = -1
      mysqli.allow_persistent = On
      mysqli.max_links = -1
      mysqli.cache_size = 2000
      mysqli.default_port = 3306
      mysqli.default_socket =
      mysqli.default_host =
      mysqli.default_user =
      mysqli.default_pw =
      mysqli.reconnect = Off

      [mysqlnd]
      mysqlnd.collect_statistics = On
      mysqlnd.collect_memory_statistics = Off

      [OCI8]

      [PostgreSQL]
      pgsql.allow_persistent = On
      pgsql.auto_reset_persistent = Off
      pgsql.max_persistent = -1
      pgsql.max_links = -1
      pgsql.ignore_notice = 0
      pgsql.log_notice = 0

      [bcmath]
      bcmath.scale = 0

      [browscap]

      [Session]
      session.save_handler = redis
      session.save_path = "tcp://localhost:6379"
      session.use_strict_mode = 0
      session.use_cookies = 1
      session.use_only_cookies = 1
      session.name = PHPSESSID
      session.auto_start = 0
      session.cookie_lifetime = 0
      session.cookie_path = /
      session.cookie_domain =
      session.cookie_httponly =
      session.serialize_handler = php
      session.gc_probability = 1
      session.gc_divisor = 1000
      session.gc_maxlifetime = 172800
      session.referer_check =
      session.cache_limiter = nocache
      session.cache_expire = 180
      session.use_trans_sid = 0
      session.sid_length = 26
      session.trans_sid_tags = "a=href,area=href,frame=src,form="
      session.sid_bits_per_character = 5

      [Assertion]
      zend.assertions = -1

      [COM]

      [mbstring]

      [gd]
      [exif]

      [Tidy]
      tidy.clean_output = Off

      [soap]
      soap.wsdl_cache_enabled=1
      soap.wsdl_cache_dir="/tmp"
      soap.wsdl_cache_ttl=86400
      soap.wsdl_cache_limit = 5

      [sysvshm]

      [ldap]
      ldap.max_links = -1

      [mcrypt]

      [dba]

      [opcache]

      [curl]
      #curl.cainfo="$NIX_SSL_CERT_FILE"
      
      [openssl]
      #openssl.cafile="$NIX_SSL_CERT_FILE"      

      
      sendmail_path = /usr/bin/env ${pkgs.mailcatcher}/bin/catchmail -f test@local.test
    '';
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
    pkgs.mailcatcher
    pkgs.yarn
    pkgs.mailutils
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
  systemd.services.nginx.serviceConfig.ReadWritePaths = [ "/var" "/run" ];
  systemd.services.nginx.unitConfig = { 
    RuntimeDirectory = "nginx";
    LogsDirectory = "nginx";
    CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
    ConditionPathExists = "/myaffiliates/_bootstrap/nginx/clients-test.conf"; 
  };

  services.nginx = {
    enable = true;
    user = "nginx";
    group = "nginx";
    eventsConfig = ''
      worker_connections 1024;
      use epoll;
    '';
    config = ''
      worker_processes 1;
    '';
    commonHttpConfig = ''
      default_type        text/html;
      proxy_http_version 1.1;
      proxy_set_header Connection "";
      keepalive_requests 1000;
      keepalive_time 1h;
      keepalive_timeout 75 20;
    '';
    appendHttpConfig = ''
      log_format main
        '$remote_addr - $remote_user [$time_local] '
        '"$request" $status $bytes_sent '
        '"$http_referer" "$http_user_agent" '
        '"$gzip_ratio"';

      log_format log_req_resp '$remote_addr - $remote_user [$time_local] '
        '"$request" $status $body_bytes_sent '
        '"$http_referer" "$http_user_agent" $request_time req_body:"$request_body" resp_body:"$resp_body" '
        'req_headers:"$req_header" resp_headers:"$resp_header"';

      lua_need_request_body on;
 
      set $resp_body "";
      body_filter_by_lua '
        local resp_body = string.sub(ngx.arg[1], 1, 1000)
        ngx.ctx.buffered = (ngx.ctx.buffered or "") .. resp_body
        if ngx.arg[2] then
          ngx.var.resp_body = ngx.ctx.buffered
        end
      ';

      set $req_header "";
      set $resp_header "";
      header_filter_by_lua '
        local h = ngx.req.get_headers()
        for k, v in pairs(h) do
          if (type(v) == "table") then
            ngx.var.req_header = ngx.var.req_header .. k.."="..table.concat(v,",").." "
          else
            ngx.var.req_header = ngx.var.req_header .. k.."="..v.." "
          end
        end
        local rh = ngx.resp.get_headers()
        for k, v in pairs(rh) do
          ngx.var.resp_header = ngx.var.resp_header .. k.."="..v.." "
        end
        ';
              
      client_header_timeout 10m;
      client_body_timeout 10m;
      send_timeout 10m;

      connection_pool_size 256;
      client_header_buffer_size 1k;
      large_client_header_buffers 4 2k;
      request_pool_size 4k;

      gzip off;

      output_buffers 1 32k;
      postpone_output 1460;

      reset_timedout_connection on;
      sendfile off;
      tcp_nopush on;
      tcp_nodelay on;

      ignore_invalid_headers on;

      index index.html index.php;

      access_log /var/log/nginx/localhost.access_log main;
      error_log /var/log/nginx/localhost.error_log info;
    '';
    httpConfig =  builtins.readFile "/myaffiliates/_bootstrap/nginx/clients-test.conf";
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

