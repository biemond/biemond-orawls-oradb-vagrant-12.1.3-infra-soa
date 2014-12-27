# == Class: oradb::installasm
#
#
define oradb::installasm(
  $version                 = undef,
  $file                    = undef,
  $gridType                = 'HA_CONFIG', #CRS_CONFIG|HA_CONFIG|UPGRADE|CRS_SWONLY
  $gridBase                = undef,
  $gridHome                = undef,
  $oraInventoryDir         = undef,
  $user                    = 'grid',
  $userBaseDir             = '/home',
  $group                   = 'asmdba',
  $group_install           = 'oinstall',
  $group_oper              = 'asmoper',
  $group_asm               = 'asmadmin',
  $sys_asm_password        = 'Welcome01',
  $asm_monitor_password    = 'Welcome01',
  $asm_diskgroup           = 'DATA',
  $disk_discovery_string   = undef,
  $disk_redundancy         = 'NORMAL',
  $disks                   = undef,
  $downloadDir             = '/install',
  $zipExtract              = true,
  $puppetDownloadMntPoint  = undef,
  $remoteFile              = true,
  $cluster_name            = undef,
  $scan_name               = undef,
  $scan_port               = undef,
  $cluster_nodes           = undef,
  $network_interface_list  = undef,
  $storage_option          = undef,
)
{

  $file_without_ext = regsubst($file, '(.+?)(\.zip*$|$)', '\1')
  #notify {"oradb::installasm file without extension ${$file_without_ext} ":}

  if($cluster_name){ # We've got a RAC cluster. Check the cluster specific parameters
    if ( $scan_name == undef or is_string($scan_name) == false) {fail('You must specify scan_name if cluster_name is defined') }
    if ( $scan_port == undef or is_integer($scan_port) == false) {fail('You must specify scan_port if cluster_name is defined') }
    if ( $cluster_nodes == undef or is_string($cluster_nodes) == false) {fail('You must specify cluster_nodes if cluster_name is defined') }
    if ( $network_interface_list == undef or is_string($network_interface_list) == false) {fail('You must specify network_interface_list if cluster_name is defined') }
    if ( $storage_option == undef or is_string($storage_option) == false) {fail('You must specify storage_option if cluster_name is defined') }
    unless $storage_option in ['ASM_STORAGE', 'FILE_SYSTEM_STORAGE'] {fail 'storage_option must be either ASM_STORAGE of FILE_SYSTEM_STORAGE'}
  }

  if (!( $version in ['11.2.0.4','12.1.0.1'] )){
    fail('Unrecognized database grid install version, use 11.2.0.4 or 12.1.0.1')
  }

  if ( !($::kernel in ['Linux','SunOS'])){
    fail('Unrecognized operating system, please use it on a Linux or SunOS host')
  }

  if ( !($gridType in ['CRS_CONFIG','HA_CONFIG','UPGRADE','CRS_SWONLY'])){
    fail('Unrecognized database grid type, please use CRS_CONFIG|HA_CONFIG|UPGRADE|CRS_SWONLY')
  }

  if ( $gridBase == undef or is_string($gridBase) == false) {fail('You must specify an gridBase') }
  if ( $gridHome == undef or is_string($gridHome) == false) {fail('You must specify an gridHome') }

  if ( $gridBase in $gridHome == false ){
    fail('gridHome folder should be under the gridBase folder')
  }


  # check if the oracle software already exists
  $found = oracle_exists( $gridHome )

  if $found == undef {
    $continue = true
  } else {
    if ( $found ) {
      $continue = false
    } else {
      notify {"oradb::installasm ${gridHome} does not exists":}
      $continue = true
    }
  }

  if $oraInventoryDir == undef {
    $oraInventory = "${gridBase}/oraInventory"
  } else {
    $oraInventory = "${oraInventoryDir}/oraInventory"
  }

  oradb::utils::dbstructure{"grid structure ${version}":
    oracle_base_home_dir => $gridBase,
    ora_inventory_dir    => $oraInventory,
    os_user              => $user,
    os_group_install     => $group_install,
    download_dir         => $downloadDir,
  }

  if ( $continue ) {

    $execPath     = '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:'

    if $puppetDownloadMntPoint == undef {
      $mountPoint     = 'puppet:///modules/oradb/'
    } else {
      $mountPoint     = $puppetDownloadMntPoint
    }

    if ( $zipExtract ) {
      # In $downloadDir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.

      if ( $version == '12.1.0.1') {
        $file1 =  "${file}_1of2.zip"
        $file2 =  "${file}_2of2.zip"
      }
      if ( $version  == '11.2.0.4' ) {
        $file1 =  $file
      }

      if $remoteFile == true {

        file { "${downloadDir}/${file1}":
          ensure  => present,
          source  => "${mountPoint}/${file1}",
          mode    => '0775',
          owner   => $user,
          group   => $group,
          require => Oradb::Utils::Dbstructure["grid structure ${version}"],
          before  => Exec["extract ${downloadDir}/${file1}"],
        }

        if ( $version == '12.1.0.1' ) {
          file { "${downloadDir}/${file2}":
            ensure  => present,
            source  => "${mountPoint}/${file2}",
            mode    => '0775',
            owner   => $user,
            group   => $group,
            require => File["${downloadDir}/${file1}"],
            before  => Exec["extract ${downloadDir}/${file2}"]
          }
        }

        $source = $downloadDir
      } else {
        $source = $mountPoint
      }

      exec { "extract ${downloadDir}/${file1}":
        command   => "unzip -o ${source}/${file1} -d ${downloadDir}/${file_without_ext}",
        timeout   => 0,
        logoutput => false,
        path      => $execPath,
        user      => $user,
        group     => $group,
        creates   => "${downloadDir}/${file_without_ext}",
        require   => Oradb::Utils::Dbstructure["grid structure ${version}"],
        before    => Exec["install oracle grid ${title}"],
      }
      if ( $version == '12.1.0.1' ) {
        exec { "extract ${downloadDir}/${file2}":
          command   => "unzip -o ${source}/${file2} -d ${downloadDir}/${file_without_ext}",
          timeout   => 0,
          logoutput => false,
          path      => $execPath,
          user      => $user,
          group     => $group,
          require   => Exec["extract ${downloadDir}/${file1}"],
          before    => Exec["install oracle grid ${title}"],
        }
      }
    }

    oradb::utils::dborainst{"grid orainst ${version}":
      ora_inventory_dir => $oraInventory,
      os_group          => $group_install,
    }

    if ! defined(File["${downloadDir}/grid_install_${version}.rsp"]) {
      file { "${downloadDir}/grid_install_${version}.rsp":
        ensure  => present,
        content => template("oradb/grid_install_${version}.rsp.erb"),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        require => Oradb::Utils::Dborainst["grid orainst ${version}"],
      }
    }

    exec { "install oracle grid ${title}":
      command     => "/bin/sh -c 'unset DISPLAY;${downloadDir}/${file_without_ext}/grid/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${downloadDir}/grid_install_${version}.rsp'",
      creates     => $gridHome,
      environment => ["USER=${user}","LOGNAME=${user}"],
      timeout     => 0,
      returns     => [6,0],
      path        => $execPath,
      user        => $user,
      group       => $group_install,
      cwd         => $gridBase,
      logoutput   => true,
      require     => [Oradb::Utils::Dborainst["grid orainst ${version}"],
                      File["${downloadDir}/grid_install_${version}.rsp"]],
    }

    if ! defined(File["${userBaseDir}/${user}/.bash_profile"]) {
      file { "${userBaseDir}/${user}/.bash_profile":
        ensure  => present,
        # content => template('oradb/grid_bash_profile.erb'),
        content => regsubst(template('oradb/grid_bash_profile.erb'), '\r\n', "\n", 'EMG'),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        require => Oradb::Utils::Dbstructure["grid structure ${version}"],
      }
    }

    exec { "run root.sh grid script ${title}":
      timeout   => 0,
      command   => "${gridHome}/root.sh",
      user      => 'root',
      group     => 'root',
      path      => $execPath,
      cwd       => $gridBase,
      logoutput => true,
      require   => Exec["install oracle grid ${title}"],
    }

    file { $gridHome:
      ensure  => directory,
      recurse => false,
      replace => false,
      mode    => '0775',
      owner   => $user,
      group   => $group_install,
      require => Exec["install oracle grid ${title}","run root.sh grid script ${title}"],
    }

    # cleanup
    if ( $zipExtract ) {
      exec { "remove oracle asm extract folder ${title}":
        command => "rm -rf ${downloadDir}/${file_without_ext}",
        user    => 'root',
        group   => 'root',
        path    => $execPath,
        require => Exec["install oracle grid ${title}"],
      }

      if ( $remoteFile == true ){
        if ( $version == '12.1.0.1') {
          exec { "remove oracle asm file2 ${file2} ${title}":
            command => "rm -rf ${downloadDir}/${file2}",
            user    => 'root',
            group   => 'root',
            path    => $execPath,
            require => Exec["install oracle grid ${title}"],
          }
        }

        exec { "remove oracle asm file1 ${file1} ${title}":
          command => "rm -rf ${downloadDir}/${file1}",
          user    => 'root',
          group   => 'root',
          path    => $execPath,
          require => Exec["install oracle grid ${title}"],
        }
      }
    }

    if ( $gridType == 'CRS_SWONLY' ) {
      exec { 'Configuring Grid Infrastructure for a Stand-Alone Server':
        command   => "${gridHome}/perl/bin/perl -I${gridHome}/perl/lib -I${gridHome}/crs/install ${gridHome}/crs/install/roothas.pl",
        user      => 'root',
        group     => 'root',
        path      => $execPath,
        cwd       => $gridBase,
        logoutput => true,
        require   => [Exec["run root.sh grid script ${title}"],File[$gridHome],],
      }
    } else {
      file { "${downloadDir}/cfgrsp.properties":
        ensure  => present,
        content => template('oradb/grid_password.properties.erb'),
        mode    => '0600',
        owner   => $user,
        group   => $group,
        require => [Exec["run root.sh grid script ${title}"],File[$gridHome],],
      }

      exec { "run configToolAllCommands grid tool ${title}":
        timeout   => 0, # This can sometimes take a long time
        command   => "${gridHome}/cfgtoollogs/configToolAllCommands RESPONSE_FILE=${downloadDir}/cfgrsp.properties",
        user      => $user,
        group     => $group_install,
        path      => $execPath,
        provider  => 'shell',
        cwd       => "${gridHome}/cfgtoollogs",
        logoutput => true,
        returns   => [0,3], # when a scan adress is not defined in the DNS, it fails, buut we can continue
        require   => [File["${downloadDir}/cfgrsp.properties"],
                      Exec["run root.sh grid script ${title}"],
                      Exec["install oracle grid ${title}"],
                      ],
      }
    }

  }
}
