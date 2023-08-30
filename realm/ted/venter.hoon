:: the point of this is to give js clients a await api.thread({ ... })
:: call they can more conveniently use to get back an actual response
:: from their "poke" instead of the stupid urbit CQRS model
:: it will give back the id of the `%create`ed object
/-  spider, db
/+  *strandio
|^
=,  strand=strand:spider
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  axn=(unit action:db)  !<((unit action:db) arg)
?~  axn  (strand-fail %no-arg ~)
?.  |(?=(%create -.u.axn) ?=(%relay -.u.axn) ?=(%edit -.u.axn) ?=(%remove -.u.axn) ?=(%remove-many -.u.axn))  (strand-fail %bad-action ~)
;<  our=@p   bind:m  get-our
;<  now=@da  bind:m  get-time
=/  data-path=?(path ~)
  ?+  -.u.axn  ~
    %create  path.input-row.u.axn
    %edit    path.input-row.u.axn
    %relay   path.input-row.u.axn
    %remove  path.u.axn
    %remove-many  path.u.axn
  ==
?~  data-path  (strand-fail %type-not-supported ~)
=/  scry-path=wire
  %+  weld
    /gx/bedrock/host/path
  %+  weld
    data-path
  /noun
=/  =wire  /vent/(scot %p our)/(scot %da now)
;<  host=ship  bind:m  (scry ship scry-path)
;<  ~        bind:m  (watch wire [host %bedrock] wire)
?+  -.u.axn  (strand-fail %type-not-supported ~)
  %create
    ;<  ~        bind:m  (poke [host %bedrock] db-action+!>([%create [our now] +>.u.axn]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))
  %relay
    ;<  ~        bind:m  (poke [host %bedrock] db-action+!>([%relay [our now] +>.u.axn]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))
  %edit
    ;<  ~        bind:m  (poke [host %bedrock] db-action+!>([%edit [our now] +>.u.axn]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))
  %remove
    ;<  ~        bind:m  (poke [host %bedrock] db-action+!>([%remove [our now] +>.u.axn]))
    ;<  cage=(unit cage)  bind:m  (take-fact-or-kick wire)
    ?^  cage
      (pure:m q.u.cage)
    (pure:m !>([%ack ~]))
  %remove-many
    ;<  ~        bind:m  (poke [host %bedrock] db-action+!>([%remove-many [our now] +>.u.axn]))
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
