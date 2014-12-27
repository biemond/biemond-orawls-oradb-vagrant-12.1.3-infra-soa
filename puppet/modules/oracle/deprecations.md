Deprecations
============

As of version 0.9.0, using the SID at the beginning of a title, is deprecated:

Change:

```puppet
tablespace{'sid/my_tablespace':
  ensure => present,
}
```

To:

```puppet
tablespace{'my_tablespace@sid':
  ensure => present,
}
```

Like before, you can leave it to the default. The default sid is the first database sid in the `/etc/oratab`.

We changed to this syntax because is is more like the syntax Oracle uses for connecting to a remote instance. Also it helps us identify certain parts of the title.

