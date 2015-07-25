# == Class: oradb::rcu
#    rcu for soa suite, webcenter
#
#    product = soasuite|webcenter|oim|oam|all
#
#
define oradb::rcu(
  $rcu_file                  = undef,
  $product                   = 'soasuite',
  $version                   = '11.1.1.7',
  $oracle_home               = undef,
  $user                      = 'oracle',
  $group                     = 'dba',
  $download_dir              = '/install',
  $action                    = 'create',  # delete or create
  $db_server                 = undef,
  $db_service                = undef,
  $sys_user                  = 'sys',
  $sys_password              = undef,
  $schema_prefix             = undef,
  $repos_password            = undef,
  $temp_tablespace           = undef,
  $puppet_download_mnt_point = undef,
  $remote_file               = true,
  $logoutput                 = false,
){
  case $::kernel {
    'Linux': {
      $execPath = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin'
    }
    default: {
      fail('Unrecognized or not supported operating system')
    }
  }

  if $puppet_download_mnt_point == undef {
    $mountPoint = 'puppet:///modules/oradb/'
  } else {
    $mountPoint = $puppet_download_mnt_point
  }

  # create the rcu folder
  if ! defined(File["${download_dir}/rcu_${version}"]) {
    # check rcu install folder
    file { "${download_dir}/rcu_${version}":
      ensure  => directory,
      path    => "${download_dir}/rcu_${version}",
      recurse => false,
      replace => false,
      mode    => '0775',
      owner   => $user,
      group   => $group,
    }
  }

  # unzip rcu software
  if $remote_file == true {
    if ! defined(File["${download_dir}/${rcu_file}"]) {
      file { "${download_dir}/${rcu_file}":
        ensure => present,
        mode   => '0775',
        owner  => $user,
        group  => $group,
        source => "${mountPoint}/${rcu_file}",
        before => Exec["extract ${rcu_file}"],
      }
    }
    $source = $download_dir
  } else {
    $source = $mountPoint
  }

  if ! defined(Exec["extract ${rcu_file}"]) {
    exec { "extract ${rcu_file}":
      command   => "unzip ${source}/${rcu_file} -d ${download_dir}/rcu_${version}",
      creates   => "${download_dir}/rcu_${version}/rcuHome",
      path      => $execPath,
      user      => $user,
      group     => $group,
      logoutput => false,
    }
  }

  if ! defined(File["${download_dir}/rcu_${version}/rcuHome/rcu/log"]) {
    # check rcu log folder
    file { "${download_dir}/rcu_${version}/rcuHome/rcu/log":
      ensure  => directory,
      path    => "${download_dir}/rcu_${version}/rcuHome/rcu/log",
      recurse => false,
      replace => false,
      require => Exec["extract ${rcu_file}"],
      mode    => '0775',
      owner   => $user,
      group   => $group,
    }
  }

  if $product == 'soasuite' {
    $components           = '-component SOAINFRA -component ORASDPM -component MDS -component OPSS -component BAM'
    $componentsPasswords  = [$repos_password, $repos_password, $repos_password,$repos_password,$repos_password]
  } elsif $product == 'webcenter' {
    $components           = '-component MDS -component OPSS -component CONTENTSERVER11 -component CONTENTSERVER11SEARCH -component URM -component PORTLET -component WEBCENTER -component ACTIVITIES -component DISCUSSIONS'
    # extra password for DISCUSSIONS and ACTIVITIES
    $componentsPasswords  = [$repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password]
  } elsif $product == 'oam' {
    $components           = '-component MDS -component OPSS -component IAU -component OAM'
    $componentsPasswords  = [$repos_password, $repos_password, $repos_password, $repos_password, $repos_password]
  } elsif $product == 'oim' {
    $components           = '-component SOAINFRA -component ORASDPM -component MDS -component OPSS -component BAM -component IAU -component BIPLATFORM -component OIF -component OIM -component OAM -component OAAM'
    $componentsPasswords  = [$repos_password, $repos_password, $repos_password,$repos_password,$repos_password,$repos_password, $repos_password, $repos_password,$repos_password, $repos_password, $repos_password]
  } elsif $product == 'all' {
    $components           = '-component SOAINFRA -component ORASDPM -component MDS -component OPSS -component BAM -component CONTENTSERVER11 -component CONTENTSERVER11SEARCH -component URM -component PORTLET -component WEBCENTER -component ACTIVITIES -component DISCUSSIONS'
    # extra password for DISCUSSIONS and ACTIVITIES
    $componentsPasswords  = [ $repos_password, $repos_password, $repos_password,$repos_password,$repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password, $repos_password]
  } else {
    fail('Unrecognized FMW product')
  }

  file { "${download_dir}/rcu_${version}/rcu_passwords_${title}.txt":
    ensure  => present,
    require => Exec["extract ${rcu_file}"],
    content => template('oradb/rcu_passwords.txt.erb'),
    mode    => '0775',
    owner   => $user,
    group   => $group,
  }

  if ( $oracle_home != undef ) {
    $preCommand    = "export SQLPLUS_HOME=${oracle_home};${download_dir}/rcu_${version}/rcuHome/bin/rcu -silent"
  } else {
    $preCommand    = "${download_dir}/rcu_${version}/rcuHome/bin/rcu -silent"
  }
  $postCommand     = "-database_type ORACLE -connectString ${db_server}:${db_service} -dbUser ${sys_user} -dbRole SYSDBA -schema_prefix ${schema_prefix} ${components} "
  $passwordCommand = " -f < ${download_dir}/rcu_${version}/rcu_passwords_${title}.txt"

  #optional set the Temp tablespace
  if $temp_tablespace == undef {
    $createCommand  = "${preCommand} -createRepository ${postCommand} ${passwordCommand}"
  } else {
    $createCommand  = "${preCommand} -createRepository ${postCommand} -temp_tablespace ${temp_tablespace} ${passwordCommand}"
  }
  $deleteCommand  = "${preCommand} -dropRepository ${postCommand} ${passwordCommand}"

  if $action == 'create' {
    $statement = $createCommand
  }
  elsif $action == 'delete' {
    $statement = $deleteCommand
  }

  db_rcu{ $schema_prefix:
    ensure       => $action,
    statement    => $statement,
    os_user      => $user,
    oracle_home  => $oracle_home,
    sys_user     => $sys_user,
    sys_password => $sys_password,
    db_server    => $db_server,
    db_service   => $db_service,
    require      => [Exec["extract ${rcu_file}"],
                    File["${download_dir}/rcu_${version}/rcu_passwords_${title}.txt"],],
  }

}
