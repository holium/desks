:: the point of this is to give js clients a await api.thread({ ... })
:: call they can more conveniently use to get back an actual response
:: from their "poke" instead of the stupid urbit CQRS model
:: it will give back the id of the `%create`ed object

/-  spider, chat-db, realm-chat
/+  *strandio

|^
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  axn=(unit action:realm-chat)  !<((unit action:realm-chat) arg)
?~  axn  (strand-fail %no-arg ~)
;<  our=@p   bind:m  get-our
;<  now=@da  bind:m  get-time
=/  =wire  /chat-vent/(scot %da now)
?+  -.u.axn    (strand-fail %bad-action ~)
  %create-chat
    ;<  ~          bind:m  (watch wire [our %chat-db] wire)
    ;<  ~          bind:m  (poke [our %realm-chat] chat-action+!>([%vented-create-chat now +.u.axn]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))
  %send-message
    ;<  ~          bind:m  (watch wire [our %chat-db] wire)
    ;<  ~          bind:m  (poke [our %realm-chat] chat-action+!>([%vented-send-message now +.u.axn]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))
  %add-ship-to-chat
    ~&  %add-ship-to-chat
    =/  act=[t=@da =path =ship host=(unit ship)]  [now +>.u.axn]
    :: if we are trying to add ourselves, then we need to watch the host
    :: ship, otherwise we watch our own ship
    =/  watch-ship=@p
      ?:  =(our ship.act)
        (need host.act)
      our
    ~&  watch-ship
    ;<  ~          bind:m  (watch wire [watch-ship %chat-db] wire)
    ;<  ~          bind:m  (poke [our %realm-chat] chat-action+!>([%add-ship-to-chat now +>.u.axn]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))
==
::
++  take-fact-or-kick
  |=  =wire
  =/  m  (strand ,(unit cage))
  ^-  form:m
  |=  tin=strand-input:strand
  ?+  in.tin  `[%skip ~]
      ~  `[%wait ~]
    ::
      [~ %agent * %fact *]
    ?.  =(watch+wire wire.u.in.tin)
      `[%skip ~]
    `[%done (some cage.sign.u.in.tin)]
    ::
      [~ %agent * %kick *]
    ?.  =(watch+wire wire.u.in.tin)
      `[%skip ~]
    `[%done ~]
  ==
--
