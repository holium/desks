/-  sur=notif-db
/+  db-lib=notif-db
::
|_  db=(list notif-row:sur)
++  grad  %noun
++  grow
  |%
  ++  noun  db
  ++  json  (rows:enjs:db-lib db)
  --
::
++  grab
  |%
  ++  noun  (list notif-row:sur)
  --
--
