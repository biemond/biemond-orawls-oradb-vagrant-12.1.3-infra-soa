sleep { 5: }

sleep { "sleep until /etc/passwd exists":
  bedtime       => 5,
  wakeupfor     => 'test -f /etc/passwd',
  dozetime      => '1',
  failontimeout => true,
}
