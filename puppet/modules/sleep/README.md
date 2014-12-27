This is a puppet module to provide a sleep type and provider for posix and Windows systems
____

Defaults to refreshonly => true

Parameters:

    bedtime: Total potential time to sleep for

    wakeupfor: An optional test which will exit the sleep, runs every 10s, or as defined by...

    dozetime: Period to sleep to between testing whether we should return

    failontimeout: whether to fail the resource if the test never succeeds by the timeout - default false

Sample code:

    sleep { 'until i need to wake up':
      bedtime       => 300,                              # how long to sleep for
      wakeupfor     => 'nc thedatabaseserver 3306 -w 1', # an optional test, run in a shell
      dozetime      => 10,                               # dozetime for the test interval, defaults to 10s
      failontimeout => true,                             # whether to fail the resource if the test times out
    }
