/-  store=rooms-v2
/+  *rooms-v2
::
|_  act=signal-action:store
++  grad  %noun
++  grow
  |%
  ++  noun  act
  ++  json  (signal-action:enjs act)
  --
::
++  grab
  |%
  ++  noun  signal-action:store
  ++  json  signal-action:dejs
  --
--