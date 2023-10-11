:: -realm!send-backlog path ship
/-  spider, chat-db, realm-chat
/+  *strandio, realm-chat

|^
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
~&  "send-backlog starting"
=/  axn=(unit [=path =ship])  !<((unit [=path =ship]) arg)
?~  axn  (strand-fail %no-arg ~)
~&  axn
;<  our=@p   bind:m  get-our
;<  now=@da  bind:m  get-time
=/  msgs  (scry-messages-for-path:realm-chat path.u.axn our now)
|-
  ?:  =((lent msgs) 0)
    (pure:m !>(~))
  ~&  (lent msgs)
  =/  next  (turn (scag 1.000 msgs) |=([k=uniq-id:chat-db v=msg-part:chat-db] v))
  ;<  ~  bind:m  (poke [ship.u.axn %chat-db] chat-db-action+!>([%insert-backlog next]))
  ;<  ~  bind:m  (sleep ~s1)
  $(msgs (oust [0 1.000] msgs))
--
