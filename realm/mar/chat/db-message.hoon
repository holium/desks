/-  sur=chat-db
/+  db-lib=chat-db
::
|_  m=message:sur
++  grad  %noun
++  grow
  |%
  ++  noun  m
  ++  json
    a+(turn m |=(mp=msg-part:sur (messages-row:encode:db-lib [msg-id.mp msg-part-id.mp] mp)))
  --
::
++  grab
  |%
  ++  noun  message:sur
  --
--

