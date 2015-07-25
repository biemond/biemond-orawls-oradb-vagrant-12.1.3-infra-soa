# == Class: oradb::installdb
#
# The database_type value should contain only one of these choices.
# EE     : Enterprise Edition
# SE     : Standard Edition
# SEONE  : Standard Edition One
#
#
define oradb::installdb(
  $version                   = undef,
  $file                      = undef,
  $database_type             = 'SE',
  $ora_inventory_dir         = undef,
  $oracle_base               = undef,
  $oracle_home               = undef,
  $ee_options_selection      = false,
  $ee_optional_components    = undef, # 'oracle.rdbms.partitioning:11.2.0.4.0,oracle.oraolap:11.2.0.4.0,oracle.rdbms.dm:11.2.0.4.0,oracle.rdbms.dv:11.2.0.4.0,oracle.rdbms.lbac:11.2.0.4.0,oracle.rdbms.rat:11.2.0.4.0'
  $create_user               = undef,
  $bash_profile              = true,
  $user                      = 'oracle',
  $user_base_dir             = '/home',
  $group                     = 'dba',
  $group_install             = 'oinstall',
  $group_oper                = 'oper',
  $download_dir              = '/install',
  $zip_extract               = true,
  $puppet_download_mnt_point = undef,
  $remote_file               = true,
  $cluster_nodes             = undef,
  $cleanup_install_files      = true,
)
{
  if ( $create_user == true ){
    fail("create_user parameter on installdb ${title} is removed from this oradb module, you need to create the oracle user and its groups yourself")
  }

  if ( $create_user == false ){
    notify {"create_user parameter on installdb ${title} can be removed, create_user feature is removed from this oradb module":}
  }

  if (!( $version in ['11.2.0.1','12.1.0.1','12.1.0.2','11.2.0.3','11.2.0.4'])){
    fail('Unrecognized database install version, use 11.2.0.1|11.2.0.3|11.2.0.4|12.1.0.1|12.1.0.2')
  }

  if ( !($::kernel in ['Linux','SunOS'])){
    fail('Unrecognized operating system, please use it on a Linux or SunOS host')
  }

  if ( !($database_type in ['EE','SE','SEONE'])){
    fail('Unrecognized database type, please use EE|SE|SEONE')
  }

  if ( $oracle_base == undef or is_string($oracle_base) == false) {fail('You must specify an oracle_base') }
  if ( $oracle_home == undef or is_string($oracle_home) == false) {fail('You must specify an oracle_home') }

  if ( $oracle_base in $oracle_home == false ){
    fail('oracle_home folder should be under the oracle_base folder')
  }

  # check if the oracle software already exists
  $found = oracle_exists( $oracle_home )

  if $found == undef {
    $continue = true
  } else {
    if ( $found ) {
      $continue = false
    } else {
      notify {"oradb::installdb ${oracle_home} does not exists":}
      $continue = true
    }
  }

  $execPath     = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'

  if $puppet_download_mnt_point == undef {
    $mountPoint     = 'puppet:///modules/oradb/'
  } else {
    $mountPoint     = $puppet_download_mnt_point
  }

  if $ora_inventory_dir == undef {
    $oraInventory = "${oracle_base}/oraInventory"
  } else {
    $oraInventory = "${ora_inventory_dir}/oraInventory"
  }

  db_directory_structure{"oracle structure ${version}":
    ensure            => present,
    oracle_base_dir   => $oracle_base,
    ora_inventory_dir => $oraInventory,
    download_dir      => $download_dir,
    os_user           => $user,
    os_group          => $group_install,
  }

  if ( $continue ) {

    if ( $zip_extract ) {
      # In $download_dir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.

      if ( $version in ['11.2.0.1','12.1.0.1','12.1.0.2']) {
        $file1 =  "${file}_1of2.zip"
        $file2 =  "${file}_2of2.zip"
      }

      if ( $version in ['11.2.0.3','11.2.0.4']) {
        $file1 =  "${file}_1of7.zip"
        $file2 =  "${file}_2of7.zip"
      }

      if $remote_file == true {

        file { "${download_dir}/${file1}":
          ensure  => present,
          source  => "${mountPoint}/${file1}",
          mode    => '0775',
          owner   => $user,
          group   => $group,
          require => Db_directory_structure["oracle structure ${version}"],
          before  => Exec["extract ${download_dir}/${file1}"],
        }
        # db file 2 installer zip
        file { "${download_dir}/${file2}":
          ensure  => present,
          source  => "${mountPoint}/${file2}",
          mode    => '0775',
          owner   => $user,
          group   => $group,
          require => File["${download_dir}/${file1}"],
          before  => Exec["extract ${download_dir}/${file2}"]
        }
        $source = $download_dir
      } else {
        $source = $mountPoint
      }

      exec { "extract ${download_dir}/${file1}":
        command   => "unzip -o ${source}/${file1} -d ${download_dir}/${file}",
        timeout   => 0,
        logoutput => false,
        path      => $execPath,
        user      => $user,
        group     => $group,
        require   => Db_directory_structure["oracle structure ${version}"],
        before    => Exec["install oracle database ${title}"],
      }
      exec { "extract ${download_dir}/${file2}":
        command   => "unzip -o ${source}/${file2} -d ${download_dir}/${file}",
        timeout   => 0,
        logoutput => false,
        path      => $execPath,
        user      => $user,
        group     => $group,
        require   => Exec["extract ${download_dir}/${file1}"],
        before    => Exec["install oracle database ${title}"],
      }
    }

    oradb::utils::dborainst{"database orainst ${version}":
      ora_inventory_dir => $oraInventory,
      os_group          => $group_install,
    }

    if ! defined(File["${download_dir}/db_install_${version}.rsp"]) {
      file { "${download_dir}/db_install_${version}.rsp":
        ensure  => present,
        content => template("oradb/db_install_${version}.rsp.erb"),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        require => [Oradb::Utils::Dborainst["database orainst ${version}"],
                    Db_directory_structure["oracle structure ${version}"],],
      }
    }

    exec { "install oracle database ${title}":
      command     => "/bin/sh -c 'unset DISPLAY;${download_dir}/${file}/database/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${download_dir}/db_install_${version}.rsp'",
      creates     => "${oracle_home}/dbs",
      environment => ["USER=${user}","LOGNAME=${user}"],
      timeout     => 0,
      returns     => [6,0],
      path        => $execPath,
      user        => $user,
      group       => $group_install,
      cwd         => $oracle_base,
      logoutput   => true,
      require     => [Oradb::Utils::Dborainst["database orainst ${version}"],
                      File["${download_dir}/db_install_${version}.rsp"]],
    }

    if ( $bash_profile == true ) {
      if ! defined(File["${user_base_dir}/${user}/.bash_profile"]) {
        file { "${user_base_dir}/${user}/.bash_profile":
          ensure  => present,
          # content => template('oradb/bash_profile.erb'),
          content => regsubst(template('oradb/bash_profile.erb'), '\r\n', "\n", 'EMG'),
          mode    => '0775',
          owner   => $user,
          group   => $group,
        }
      }
    }

    exec { "run root.sh script ${title}":
      command   => "${oracle_home}/root.sh",
      user      => 'root',
      group     => 'root',
      path      => $execPath,
      cwd       => $oracle_base,
      logoutput => true,
      require   => Exec["install oracle database ${title}"],
    }

    file { $oracle_home:
      ensure  => directory,
      recurse => false,
      replace => false,
      mode    => '0775',
      owner   => $user,
      group   => $group_install,
      require => Exec["install oracle database ${title}","run root.sh script ${title}"],
    }

    # cleanup
    if ( $cleanup_install_files ) {
      if ( $zip_extract ) {
        exec { "remove oracle db extract folder ${title}":
          command => "rm -rf ${download_dir}/${file}",
          user    => 'root',
          group   => 'root',
          path    => $execPath,
          cwd     => $oracle_base,
          require => [Exec["install oracle database ${title}"],
                      Exec["run root.sh script ${title}"],],
          }

        if ( $remote_file == true ){
          exec { "remove oracle db file1 ${file1} ${title}":
            command => "rm -rf ${download_dir}/${file1}",
            user    => 'root',
            group   => 'root',
            path    => $execPath,
            cwd     => $oracle_base,
            require => [Exec["install oracle database ${title}"],
                          Exec["run root.sh script ${title}"],],
          }
          exec { "remove oracle db file2 ${file2} ${title}":
            command => "rm -rf ${download_dir}/${file2}",
            user    => 'root',
            group   => 'root',
            path    => $execPath,
            cwd     => $oracle_base,
            require => [Exec["install oracle database ${title}"],
                        Exec["run root.sh script ${title}"],],
          }
        }
      }
    }
  }
}
