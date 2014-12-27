#
# This is a manifest to install a beaker test node with a dababse
#
$oracle_base  = '/opt/oracle'
$oracle_home  = '/opt/oracle/app/11.04'
$groups       = ['oinstall', 'dba']
$full_version = '11.2.0.4'
$version      = '11.2'
$dbname       = 'test'
$domain_name  = 'example.com'



contain oracle_os_settings
contain database

Class['oracle_os_settings'] -> Class['Database']

class oracle_os_settings
{

  exec { "create swap file":
    command => "/bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=8192",
    creates => "/var/swap.1",
  }

  exec { "attach swap file":
    command => "/sbin/mkswap /var/swap.1 && /sbin/swapon /var/swap.1",
    require => Exec["create swap file"],
    unless => "/sbin/swapon -s | grep /var/swap.1",
  }

  #add swap file entry to fstab
  exec {"add swapfile entry to fstab":
    command => "/bin/echo >>/etc/fstab /var/swap.1 swap swap defaults 0 0",
    require => Exec["attach swap file"],
    user => root,
    unless => "/bin/grep '^/var/swap.1' /etc/fstab 2>/dev/null",
  }

  service { iptables:
      enable    => false,
      ensure    => false,
      hasstatus => true,
  }

  $groups = ['oinstall','dba' ,'oper' ]

  group { $groups :
    ensure      => present,
  }

  user { 'oracle' :
    ensure      => present,
    uid         => 500,
    gid         => 'oinstall',  
    groups      => $groups,
    shell       => '/bin/bash',
    password    => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
    home        => "/home/oracle",
    comment     => "This user oracle was created by Puppet",
    require     => Group[$groups],
    managehome  => true,
  }

  $packages = [ 'binutils.x86_64', 'compat-libstdc++-33.x86_64', 'glibc.x86_64','ksh.x86_64','libaio.x86_64',
               'libgcc.x86_64', 'libstdc++.x86_64', 'make.x86_64', 'gcc.x86_64',
               'gcc-c++.x86_64','glibc-devel.x86_64','libaio-devel.x86_64','libstdc++-devel.x86_64',
               'sysstat.x86_64','unixODBC-devel','glibc.i686', 'unzip']
         

  package { $packages:
    ensure  => present,
  }

  class { 'limits':
     config => {
                '*'       => { 'nofile'  => { soft => '2048'   , hard => '8192',   },},
                'oracle'  => { 'nofile'  => { soft => '65536'  , hard => '65536',  },
                                'nproc'  => { soft => '2048'   , hard => '16384',  },
                                'stack'  => { soft => '10240'  ,},},
                },
     use_hiera => false,
  }
  sysctl { 'kernel.msgmnb':                 ensure => 'present', permanent => 'yes', value => '65536',}
  sysctl { 'kernel.msgmax':                 ensure => 'present', permanent => 'yes', value => '65536',}
  sysctl { 'kernel.shmmax':                 ensure => 'present', permanent => 'yes', value => '2588483584',}
  sysctl { 'kernel.shmall':                 ensure => 'present', permanent => 'yes', value => '2097152',}
  sysctl { 'fs.file-max':                   ensure => 'present', permanent => 'yes', value => '6815744',}
  sysctl { 'net.ipv4.tcp_keepalive_time':   ensure => 'present', permanent => 'yes', value => '1800',}
  sysctl { 'net.ipv4.tcp_keepalive_intvl':  ensure => 'present', permanent => 'yes', value => '30',}
  sysctl { 'net.ipv4.tcp_keepalive_probes': ensure => 'present', permanent => 'yes', value => '5',}
  sysctl { 'net.ipv4.tcp_fin_timeout':      ensure => 'present', permanent => 'yes', value => '30',}
  sysctl { 'kernel.shmmni':                 ensure => 'present', permanent => 'yes', value => '4096', }
  sysctl { 'fs.aio-max-nr':                 ensure => 'present', permanent => 'yes', value => '1048576',}
  sysctl { 'kernel.sem':                    ensure => 'present', permanent => 'yes', value => '250 32000 100 128',}
  sysctl { 'net.ipv4.ip_local_port_range':  ensure => 'present', permanent => 'yes', value => '9000 65500',}
  sysctl { 'net.core.rmem_default':         ensure => 'present', permanent => 'yes', value => '262144',}
  sysctl { 'net.core.rmem_max':             ensure => 'present', permanent => 'yes', value => '4194304', }
  sysctl { 'net.core.wmem_default':         ensure => 'present', permanent => 'yes', value => '262144',}
  sysctl { 'net.core.wmem_max':             ensure => 'present', permanent => 'yes', value => '1048576',}

}

class database{
  oradb::installdb{ '112040_Linux-x86-64':
    version                => $full_version,
    file                   => 'p13390677_112040_Linux-x86-64',
    databaseType           => 'EE',
    oracleBase             => $oracle_base,
    oracleHome             => $oracle_home,
    puppetDownloadMntPoint => '/software',
    remoteFile             => false,
  }

  oradb::net{ 'config net8':
    oracleHome   => $oracle_home,
    version      => $version,
    downloadDir  => '/tmp',
    require      => Oradb::Installdb['112040_Linux-x86-64'],
  }

  oradb::listener{'start listener':
    oracleBase   => $oracle_base,
    oracleHome   => $oracle_home,
    action       => 'start',
    require      => Oradb::Net['config net8'],
  }

  oradb::database{ $dbname:
    oracleBase              => $oracle_base,
    oracleHome              => $oracle_home,
    version                 => $version,
    dbName                  => $dbname,
    dbDomain                => $domain_name,
    dataFileDestination     => "/opt/oracle/oradata",
    recoveryAreaDestination => "/oracle/flash_recovery_area",
    initParams              => "open_cursors=1000,processes=600,job_queue_processes=4",
    require                 => Oradb::Listener['start listener'],
  }

  oradb::dbactions{ "start_${dbname}":
    oracleHome              => $oracle_home,
    dbName                  => $dbname,
    require                 => Oradb::Database[$dbname],
  }

  oradb::autostartdatabase{ 'autostart oracle':
    oracleHome              => $oracle_home,
    dbName                  => $dbname,
    require                 => Oradb::Dbactions["start_${dbname}"],
  }
}
