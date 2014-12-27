[![Build Status](https://travis-ci.org/hajee/oracle.png?branch=master)](https://travis-ci.org/hajee/oracle)

####Table of Contents

[![Powered By EasyType](https://raw.github.com/hajee/easy_type/master/powered_by_easy_type.png)](https://github.com/hajee/easy_type)


1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with oracle](#setup)
    * [What oracle affects](#what-oracle-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with oracle](#beginning-with-oracle)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
    * [OS support](#os-support)
    * [Oracle versions support](#oracle-version-support)
    * [Managable Oracle objects](#managable-oracle-objects)
    * [Tests - Testing your configuration](#testing)

##Overview

This module contains a couple of Puppet custom types to manage 'stuff' in an Oracle database. At this point in time we support manage tablespaces, oracle users, grants, roles, init parameters, asm diskgroups, threads and services. To learn more, check [the blog post](http://hajee.github.io/2014/02/23/using-puppet-to-manage-oracle/)

##Module Description

This module contains custom types that can help you manage DBA objects in an Oracle database. It runs **after** the database is installed. IT DOESN'T INSTALL the Oracle database software. With this module, you can setup a database to receive an application. You can:

* create a tablespace
* create a user with the required grants and quota's
* create one or more roles
* create one or more services

##Setup

###What oracle affects

The types in this module will change settings **inside** a Oracle Database. No changes are made outside of the database.

###Setup Requirements

To use this module, you need a running Oracle database. I can recommend [Edwin Biemonds Puppet OraDb module](https://github.com/biemond/puppet/tree/master/modules/oradb). The Oracle module itself is based on [easy_type](https://github.com/hajee/easy_type).

###Beginning with oracle module

After you have a running database, (See [Edwin Biemonds Puppet OraDb module](https://github.com/biemond/puppet/tree/master/modules/oradb)), you need to install [easy_type](https://github.com/hajee/easy_type), and this module.

```sh
puppet module install hajee/easy_type
puppet module install hajee/oracle
```

##Usage

The module contains the following types:

`ora_tablespace`, `ora_user`, `ora_role` and `ora_listener`. Here are a couple of examples on how to use them.

###ora_listener

This is the only module that does it's work outside of the Oracle database. It makes sure the Oracle SQL*Net listener is running.

```puppet
ora_listener {'SID':
  ensure  => running,
  require => Exec['db_install_instance'],
}
```

The name of the resource *MUST* be the sid for which you want to start the listener.

###Specifying the SID

All types have a name like `resource@sid`. The sid is optional. If you don't specify the sid, the type will use the first database instance from the `/etc/oratab`  file. We advise you to use a full name, e.g. an sid and a resource name. This makes the manifest much more resilient for changes in the environment.


###ora_user

This type allows you to manage a user inside an Oracle Database. It recognises most of the options that [CREATE USER](http://docs.oracle.com/cd/B28359_01/server.111/b28286/statements_8003.htm#SQLRF01503) supports. Besides these options, you can also use this type to manage the grants and the quota's for this user.

```puppet
ora_user{user_name@sid:
  temporary_tablespace      => temp,
  default_tablespace        => 'my_app_ts,
  password                  => 'verysecret',
  require                   => Ora_tablespace['my_app_ts'],
  grants                    => ['SELECT ANY TABLE', 'CONNECT', 'CREATE TABLE', 'CREATE TRIGGER'],
  quotas                    => {
                                  "my_app_ts"  => 'unlimited'
                                },
}
```


###ora_tablespace

This type allows you to manage a tablespace inside an Oracle Database. It recognises most of the options that [CREATE TABLESPACE](http://docs.oracle.com/cd/B28359_01/server.111/b28310/tspaces002.htm#ADMIN11359) supports.

```puppet
ora_tablespace {'my_app_ts@sid':
  ensure                    => present,
  datafile                  => 'my_app_ts.dbf',
  size                      => 5G,
  logging                   => yes,
  autoextend                => on,
  next                      => 100M,
  max_size                  => 20G,
  extent_management         => local,
  segment_space_management  => auto,
}
```

You can also create an undo tablespace:

```puppet
ora_tablespace {'my_undots_1@sid':
  ensure                    => present,
  contents                  => 'undo',
}
```

or a temporary taplespace:

```puppet
tablespace {'my_temp_ts@sid':
  ensure                    => present,
  datafile                  => 'my_temp_ts.dbf',
  content                   => 'temporary',
  size                      => 5G,
  logging                   => yes,
  autoextend                => on,
  next                      => 100M,
  max_size                  => 20G,
  extent_management         => local,
  segment_space_management  => auto,
}
```

###ora_role

This type allows you to create or delete a role inside an Oracle Database. It recognises a limit part of the options that [CREATE ROLE](http://docs.oracle.com/cd/B28359_01/server.111/b28286/statements_6012.htm#SQLRF01311) supports.


```puppet
ora_role {'just_a_role@sid':
  ensure    => present,
}
```

###ora_service

This type allows you to create or delete a service inside an Oracle Database.


```puppet
ora_service{'my_app_service@sid':
  ensure  => present,
}
```

###ora_init_param

this type allows you to manage your init.ora parameters. You can manage your `spfile` parameters and your `memory` parameters. First the easy variant where you want to change an spfile parameter on your current sid for your current sid.


```puppet
ora_init_param{'SPFILE/PARAMETER':
  ensure  => present,
  value   => 'the_value'
}
```

To manage the same parameter only the in-memory one, use:

```puppet
init_param{'MEMORY/PARAMETER':
  ensure  => present,
  value   => 'the_value'
}
```

If you are running RAC and need to specify a parameter for an other instance, you can specify the instance as well.

```puppet
init_param{'MEMORY/PARAMETER:INSTANCE':
  ensure  => present,
  value   => 'the_value'
}
```

Having more then one sid running on your node and you want to specify the sid you want to use, use `@SID` at the end.


```puppet
init_param{'MEMORY/PARAMETER:INSTANCE@SID':
  ensure  => present,
  value   => 'the_value'
}
```


###ora_asm_diskgroup

This type allows you to manage your ASM diskgroups. Like the other Oracle types, you must specify the SID. But for this type it must be the ASM sid. Most of the times, this is `+ASM1`

```puppet
ora_asm_diskgroup {'REDO@+ASM1':
  ensure          => 'present',
  redundancy_type => 'normal',
  compat_asm      => '11.2.0.0.0',
  compat_rdbms    => '11.2.0.0.0',
  failgroups      => {
    'CONTROLLER1' => { 'diskname' => 'REDOVOL1', 'path' => 'ORCL:REDOVOL1'},
    'CONTROLLER2' => { 'diskname' => 'REDOVOL2', 'path' => 'ORCL:REDOVOL2'},
  }
}

```

At this point in time the type support just the creation and the removal of a diskgroup. Modification of diskgroups is not (yet) supported.


###ora_exec

this type allows you run a specific SQL statement or an sql file on a specified instance sid.

```puppet
  ora_exec{"drop table application_users@sid":
    username => 'app_user',
    password => 'password,'
  }
```

This statement will execute the sql statement `drop table application_users` on the instance names `instance`. There is no way the type can check if it has already done this statement, so the developer must support this by using puppet `if` statements.


```puppet
ora_exec{"instance/@/tmp/do_some_stuff.sql":
  username  => 'app_user',
  password  => 'password,'
  logoutput => on_failure,  # can be true, false or on_failure
}
```

This statement will run the sqlscript `/tmp/do_some_stuff.sql` on the instance named `instance`. Like the single statement variant, there is no way to check if the statement is already done. So the developer must check for this himself.

When you don't specify the username and the password, the type will connect as `sysdba`.



###ora_thread

This type allows you to enable a thread. Threads are used in Oracle RAC installations. This type might not be very useful for regular use, but it is used in the [Oracle RAC module](https://forge.puppetlabs.com/hajee/ora_rac).


```puppet
ora_thread{"2@sid":
  ensure  => 'enabled',
}
```

This enables thread 2 on instance named `sid`

##Limitations

This module is tested on Oracle 11 on CentOS and Redhat. It will probably work on other Linux distributions. It will definitely **not** work on Windows. As far as Oracle compatibility. Most of the sql commands's it creates under the hood are pretty much Oracle version independent. It should work on most Oracle versions.

##Development

This is an open projects, and contributions are welcome.

###OS support

Currently we have tested:

* Oracle 11.2.0.2 & 11.2.0.4
* CentOS 5.8
* Redhat 5

It would be great if we could get it working and tested on:

* Oracle 12
* Debian
* Windows
* Ubuntu
* ....

###Oracle version support

Currently we have tested:

* Oracle 11.2.0.2
* Oracle 11.2.0.4

It would be great if we could get it working and tested on:

* Oracle 12

###Managable Oracle objects

Obviously Oracle has many many many more DBA objects that need management. For some of these Puppet would be a big help. It would be great if we could get help getting this module to support all of the objects.

If you have knowledge in these technologies, know how to code, and wish to contribute to this project, we would welcome the help.

###Testing

Make sure you have:

* rake
* bundler

Install the necessary gems:

    bundle install

And run the tests from the root of the source code:

    rake test

We are currently working on getting the acceptance test running as well.

