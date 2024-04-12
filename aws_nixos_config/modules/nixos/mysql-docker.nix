{ pkgs, config, ... }:

let
mycnfFile = pkgs.writeText "my.cnf" '' 
    [client]
    port=3306
    socket=/var/run/mysqld/mysqld.sock

    [mysql]    
    character-sets-dir = /usr/share/mysql/charsets
    default-character-set = utf8

    [mysqld]
    max_connections = 250
    sql-mode = STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO
    character-set-server = utf8MB4
    user = mysql
    port = 3306
    socket = /var/run/mysqld/mysqld.sock
    pid-file = /var/run/mysqld/mysqld.pid
    log-error = /var/log/mysql/mysqld.err
    basedir = /usr
    datadir = /var/lib/mysql
    skip-external-locking
    character-sets-dir=/usr/share/mysql/charsets
    max_allowed_packet = 128M
    table_open_cache = 64
    sort_buffer_size = 512K
    net_buffer_length	= 8K
    read_buffer_size = 256K
    read_rnd_buffer_size = 512K
    myisam_sort_buffer_size	= 8M
    binlog-format = MIXED
    lc_messages_dir = /var/log/mysql
    explicit_defaults_for_timestamp = 1
    lc_messages	= en_US
    bind-address = 0.0.0.0
    server-id	= 1
    log_bin = /var/log/mysql/mysql-bin.log
    max_binlog_size = 100M
    binlog_expire_logs_seconds = 864000
    tmpdir = /tmp/
    innodb_buffer_pool_size = 256M
    innodb_redo_log_capacity=10485760
    innodb_log_file_size = 128MB
    innodb_data_file_path = ibdata1:10M:autoextend
    innodb_log_buffer_size = 8M
    innodb_flush_log_at_trx_commit = 1
    innodb_lock_wait_timeout = 50
    innodb_file_per_table
    log_bin_trust_function_creators
    interactive_timeout = 28800
    wait_timeout = 300
  

    [mysqladmin]
    character-sets-dir=/usr/share/mysql/charsets
    default-character-set=utf8
    
    [mysqlcheck]
    character-sets-dir=/usr/share/mysql/charsets
    default-character-set=utf8
    
    [mysqldump]
    character-sets-dir=/usr/share/mysql/charsets
    default-character-set=utf8
    quick
    max_allowed_packet = 16M
    
    [mysqlimport]
    character-sets-dir=/usr/share/mysql/charsets
    default-character-set=utf8

    [myisamchk]
    character-sets-dir=/usr/share/mysql/charsets
    key_buffer = 20M
    sort_buffer_size = 20M
    read_buffer = 2M
    write_buffer = 2M
      
    [isamchk]
    key_buffer = 20M
    sort_buffer_size = 20M
    read_buffer = 2M
    write_buffer = 2M
    
    [myisampack]
    character-sets-dir=/usr/share/mysql/charsets
    
    [mysqlhotcopy] 
    interactive-timeout
    '';

  configFile = pkgs.writeText "docker-compose.yml" 
    ''
version: "3"
services:
  mysql:
    container_name: mysql
    image: mysql:8.0
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    volumes:
      - "/var/lib/mysql:/var/lib/mysql"
      - "/var/log/mysql:/var/log/mysql"
      - "/var/run/mysqld:/var/run/mysqld"
      - "/vagrant/vagrant/vagrant-scripts/service-configs/mysql/mysqlinit.sql:/docker-entrypoint-initdb.d/1.sql"
      - "${mycnfFile}:/etc/mysql/my.cnf"
    environment:
      MYSQL_ROOT_HOST: "%"
      MYSQL_ROOT_PASSWORD: ""
      MYSQL_ALLOW_EMPTY_PASSWORD: yes
      MYSQL_DATABASE: zban_test
    ports:
      - "3306:3306"
'';

in {
    systemd.tmpfiles.rules = [
    "d /run/mysqld 7777 vagrant vagrant - -"
    "d /var/lib/mysql 7777 vagrant vagrant - -"
    "d /var/log/mysql 7777 vagrant vagrant - -"
    "f /var/log/mysql/errmsg.sys 7777 vagrant vagrant - -"
    ];


   systemd.services.mysql-docker = {
    enable = true;
    serviceConfig = {
      ReadWritePaths = [ "/run/mysqld" "/var/log/mysql" "/var/lib/mysql" ];
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f ${configFile} up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
      };
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
    };  

    
}
  
  
  
